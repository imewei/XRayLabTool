"""
XRayLabTool - Material property calculations for X-ray interactions

This module provides functions to calculate X-ray optical properties of materials
based on their chemical composition and density.

**Main Functions:**
- 'Refrac': Calculate properties for multiple chemical formulas
- 'SubRefrac': Calculate properties for a single chemical formula

**Usage Examples:**
'''julia
# Single formula
result = SubRefrac("SiO2", [8.0, 10.0, 12.0], 2.2)

# Multiple formulas
results = Refrac(["SiO2", "Al2O3"], [8.0, 10.0, 12.0], [2.2, 3.95])
'''

**Input Parameters:**
1. Chemical formula(s): Case-sensitive strings (e.g., "CO" for Carbon Monoxide vs "Co" for Cobalt)
2. Energy: Vector of X-ray energies in KeV (range: 0.03 - 30 KeV)
3. Mass density: Density in g/cm³ (single value or vector matching formula count)

**Output Properties:**
The functions return XRayResult struct(s) containing:
1. Chemical formula
2. Molecular weight (g/mol)
3. Number of electrons per molecule
4. Mass density (g/cm³)
5. Electron density (1/Å³)
6. X-ray energy (KeV)
7. X-ray wavelength (Å)
8. Dispersion coefficient
9. Absorption coefficient
10. Real part of atomic scattering factor (f1)
11. Imaginary part of atomic scattering factor (f2)
12. Critical angle (degrees)
13. Attenuation length (cm)
14. Real part of scattering length density (SLD) (Å⁻²)
15. Imaginary part of SLD (Å⁻²)
"""
module XRayLabTool

using CSV
using DataFrames
using PCHIPInterpolation
using PeriodicTable: elements
using Unitful
import Base.Threads.@threads

export Refrac, SubRefrac, XRayResult

# =====================================================================================
# DATA STRUCTURES
# =====================================================================================

"""
    XRayResult

Struct to store complete X-ray optical property calculations for a material.

Contains all computed properties including scattering factors, optical constants,
and derived quantities like critical angles and attenuation lengths.
"""
struct XRayResult
    Formula::String                   # Chemical formula
    MW::Float64                       # Molecular weight (g/mol)
    Number_Of_Electrons::Float64      # Electrons per molecule
    Density::Float64                  # Mass density (g/cm³)
    Electron_Density::Float64         # Electron density (1/Å³)
    Energy::Vector{Float64}           # X-ray energy (KeV)
    Wavelength::Vector{Float64}       # X-ray wavelength (Å)
    Dispersion::Vector{Float64}       # Dispersion coefficient
    Absorption::Vector{Float64}       # Absorption coefficient
    f1::Vector{Float64}               # Real part of atomic scattering factor
    f2::Vector{Float64}               # Imaginary part of atomic scattering factor
    Critical_Angle::Vector{Float64}   # Critical angle (degrees)
    Attenuation_Length::Vector{Float64} # Attenuation length (cm)
    reSLD::Vector{Float64}            # Real part of SLD (Å⁻²)
    imSLD::Vector{Float64}            # Imaginary part of SLD (Å⁻²)
end

# =====================================================================================
# PHYSICAL CONSTANTS
# =====================================================================================

"""
Physical constants used in X-ray calculations.
All values are in SI units unless otherwise specified.
"""
const THOMPSON = 2.8179403227e-15    # Thomson scattering length (m)
const SPEED_OF_LIGHT = 299792458.0   # Speed of light (m/s)
const PLANCK = 6.626068e-34          # Planck constant (J·s)
const ELEMENT_CHARGE = 1.60217646e-19 # Elementary charge (C)
const AVOGADRO = 6.02214199e23       # Avogadro's number (mol⁻¹)

# Pre-computed constants for efficiency
const ENERGY_TO_WAVELENGTH_FACTOR = (SPEED_OF_LIGHT * PLANCK / ELEMENT_CHARGE) / 1000.0
const SCATTERING_FACTOR = THOMPSON * AVOGADRO * 1e6 / (2 * π)

# =====================================================================================
# CACHING SYSTEM
# =====================================================================================

"""
Caches for performance optimization:
- ATOMIC_DATA_CACHE: Stores (atomic_number, atomic_mass) for elements
- F1F2_TABLE_CACHE: Stores loaded atomic scattering factor tables
"""
const ATOMIC_DATA_CACHE = Dict{String,Tuple{Int,Float64}}()
const F1F2_TABLE_CACHE = Dict{String,DataFrame}()

# =====================================================================================
# HELPER FUNCTIONS
# =====================================================================================

"""
    get_atomic_data(element_symbol::String) -> (Int, Float64)

Retrieve atomic number and atomic mass for a given element symbol.
Uses caching to avoid repeated lookups of the same element.

# Arguments
- 'element_symbol::String': Chemical symbol (e.g., "Si", "O")

# Returns
- 'Tuple{Int, Float64}': (atomic_number, atomic_mass_in_amu)

# Throws
- 'ArgumentError': If element symbol is not found in periodic table
"""
function get_atomic_data(element_symbol::String)
    # Check cache first for performance
    if haskey(ATOMIC_DATA_CACHE, element_symbol)
        return ATOMIC_DATA_CACHE[element_symbol]
    end

    # Search periodic table for element
    for (i, elem) in enumerate(elements)
        if elem.symbol == element_symbol
            atomic_number = i
            atomic_mass = ustrip(elem.atomic_mass)  # Remove units

            # Cache the result for future use
            ATOMIC_DATA_CACHE[element_symbol] = (atomic_number, atomic_mass)
            return (atomic_number, atomic_mass)
        end
    end

    # Element not found
    throw(ArgumentError("Element $element_symbol not found in periodic table"))
end

"""
    parse_formula(formulaStr::String) -> (Vector{String}, Vector{Float64})

Parse a chemical formula string into element symbols and their counts.

# Arguments
- 'formulaStr::String': Chemical formula (e.g., "SiO2", "Al2O3", "CaCO3")

# Returns
- 'Tuple{Vector{String}, Vector{Float64}}': (element_symbols, element_counts)

# Examples
'''julia
symbols, counts = parse_formula("SiO2")
# symbols = ["Si", "O"], counts = [1.0, 2.0]

symbols, counts = parse_formula("Al2O3")
# symbols = ["Al", "O"], counts = [2.0, 3.0]
'''

# Throws
- 'ArgumentError': If formula string is invalid or empty
"""
function parse_formula(formulaStr::String)
    # Regular expression to match element symbols and their counts
    # Matches: Capital letter + optional lowercase + optional number (int or float)
    elements_match = eachmatch(r"([A-Z][a-z]*)(\d*\.\d*|\d*)", formulaStr)

    if isempty(elements_match)
        throw(ArgumentError("Invalid chemical formula: $formulaStr"))
    end

    element_symbols = String[]
    element_counts = Float64[]

    for elem_match in elements_match
        push!(element_symbols, elem_match[1])  # Element symbol

        # Parse count (default to 1.0 if not specified)
        count_str = elem_match[2]
        push!(element_counts, count_str == "" ? 1.0 : parse(Float64, count_str))
    end

    return element_symbols, element_counts
end

"""
    load_f1f2_table(element_symbol::String) -> DataFrame

Load atomic scattering factor table for a given element.
Uses caching to avoid repeated file I/O operations.

# Arguments
- 'element_symbol::String': Chemical symbol (e.g., "Si", "O")

# Returns
- 'DataFrame': Table with columns E (energy in eV), f1, f2 (scattering factors)

# File Format
Expected CSV file format:
'''
E,f1,f2
30.0,0.123,0.456
40.0,0.234,0.567
...
'''

# Throws
- 'ArgumentError': If element data file cannot be found or loaded
"""
function load_f1f2_table(element_symbol::String)
    # Check cache first
    if haskey(F1F2_TABLE_CACHE, element_symbol)
        return F1F2_TABLE_CACHE[element_symbol]
    end

    # Construct filename (lowercase element symbol + .nff extension)
    fname = lowercase(element_symbol) * ".nff"
    file = normpath(joinpath(@__DIR__, "AtomicScatteringFactor", fname))

    try
        # Load CSV file and cache the result
        table = CSV.File(file) |> DataFrame
        F1F2_TABLE_CACHE[element_symbol] = table
        return table
    catch e
        throw(ArgumentError("Element $element_symbol is NOT in the table list: $e"))
    end
end

"""
    create_interpolators(energy_table, f1_table, f2_table) -> (Interpolator, Interpolator)

Create PCHIP interpolators for atomic scattering factors f1 and f2.

# Arguments
- 'energy_table::Vector{Float64}': Energy values from data table (eV)
- 'f1_table::Vector{Float64}': Real part of scattering factor
- 'f2_table::Vector{Float64}': Imaginary part of scattering factor

# Returns
- 'Tuple{Interpolator, Interpolator}': (f1_interpolator, f2_interpolator)

# Notes
Uses PCHIP (Piecewise Cubic Hermite Interpolating Polynomial) for smooth interpolation
while preserving monotonicity in the data.
"""
function create_interpolators(energy_table::Vector{Float64}, f1_table::Vector{Float64}, f2_table::Vector{Float64})
    itp1 = Interpolator(energy_table, f1_table)
    itp2 = Interpolator(energy_table, f2_table)
    return itp1, itp2
end

"""
    calculate_scattering_factors!(...)

Vectorized calculation of X-ray scattering factors and optical properties.

This function performs the core calculation of dispersion, absorption, and total
scattering factors for a material based on its elemental composition.

# Arguments
- 'energy_ev::Vector{Float64}': X-ray energies in eV
- 'wavelength::Vector{Float64}': Corresponding wavelengths in meters
- 'mass_density::Float64': Material density in g/cm³
- 'molecular_weight::Float64': Molecular weight in g/mol
- 'element_data::Vector{Tuple{Float64, Any, Any}}': Element data (count, f1_interp, f2_interp)
- 'dispersion::Vector{Float64}': Output array for dispersion coefficients
- 'absorption::Vector{Float64}': Output array for absorption coefficients
- 'f1_total::Vector{Float64}': Output array for total f1 values
- 'f2_total::Vector{Float64}': Output array for total f2 values

# Mathematical Background
The dispersion and absorption coefficients are calculated using:
- δ = (λ²/2π) × rₑ × ρ × Nₐ × (Σᵢ nᵢ × f1ᵢ) / M
- β = (λ²/2π) × rₑ × ρ × Nₐ × (Σᵢ nᵢ × f2ᵢ) / M

Where:
- λ: X-ray wavelength
- rₑ: Thomson scattering length
- ρ: Mass density
- Nₐ: Avogadro's number
- nᵢ: Number of atoms of element i
- f1ᵢ, f2ᵢ: Atomic scattering factors for element i
- M: Molecular weight
"""
function calculate_scattering_factors!(
    energy_ev::Vector{Float64},
    wavelength::Vector{Float64},
    mass_density::Float64,
    molecular_weight::Float64,
    element_data::Vector{Tuple{Float64,Any,Any}}, # (count, itp1, itp2)
    dispersion::Vector{Float64},
    absorption::Vector{Float64},
    f1_total::Vector{Float64},
    f2_total::Vector{Float64}
)
    n_energies = length(energy_ev)

    # Pre-compute density-dependent factor for efficiency
    # Factor includes: (λ²/2π) × rₑ × ρ × Nₐ / M
    common_factor = SCATTERING_FACTOR * mass_density / molecular_weight

    # Process each element in the formula
    for (count, itp1, itp2) in element_data
        # Element-specific contribution factor
        element_contribution_factor = common_factor * count

        # Vectorized calculation across all energies
        @inbounds for i in 1:n_energies
            # Interpolate scattering factors at this energy
            f1_val = itp1(energy_ev[i])
            f2_val = itp2(energy_ev[i])

            # Calculate wavelength-dependent factors
            wave_sq = wavelength[i]^2

            # Accumulate contributions to optical properties
            dispersion[i] += wave_sq * element_contribution_factor * f1_val
            absorption[i] += wave_sq * element_contribution_factor * f2_val

            # Accumulate total scattering factors
            f1_total[i] += count * f1_val
            f2_total[i] += count * f2_val
        end
    end
end

# =====================================================================================
# MAIN CALCULATION FUNCTIONS
# =====================================================================================

"""
    Refrac(formulaList, energy, massDensityList) -> Dict{String, XRayResult}

Calculate X-ray optical properties for multiple chemical formulas.

This is the main function for batch processing of multiple materials.
Uses parallel processing to improve performance for large datasets.

# Arguments
- 'formulaList::Vector{String}': List of chemical formulas
- 'energy::Vector{Float64}': X-ray energies in KeV (0.03 - 30 KeV)
- 'massDensityList::Vector{Float64}': Mass densities in g/cm³

# Returns
- 'Dict{String, XRayResult}': Dictionary mapping formula strings to results

# Examples
'''julia
# Calculate properties for multiple materials
formulas = ["SiO2", "Al2O3", "Fe2O3"]
energies = [8.0, 10.0, 12.0, 15.0]
densities = [2.2, 3.95, 5.24]

results = Refrac(formulas, energies, densities)

# Access results for specific material
sio2_result = results["SiO2"]
println("SiO2 molecular weight: ", sio2_result.MW)
'''

# Error Handling
- Validates input types and ranges
- Handles individual formula failures gracefully
- Uses thread-safe operations for parallel processing

# Performance Notes
- Uses multithreading for parallel formula processing
- Implements caching for atomic data and scattering factor tables
- Pre-allocates arrays to minimize memory allocations
"""
function Refrac(
    formulaList::Vector{String},
    energy::Vector{Float64},
    massDensityList::Vector{Float64},
)
    # ==================================================================================
    # INPUT VALIDATION
    # ==================================================================================

    # Check argument types
    if !all(isa(arg, Vector) for arg in [formulaList, energy, massDensityList])
        throw(ArgumentError("All arguments must be vectors"))
    end

    # Check for empty inputs
    if any(isempty(arg) for arg in [formulaList, energy])
        throw(ArgumentError("Formula list and energy vector must not be empty"))
    end

    # Validate energy range (X-ray energies typically 0.03-30 KeV)
    if any(energy .< 0.03) || any(energy .> 30)
        throw(ArgumentError("Energy is out of range 0.03KeV ~ 30KeV"))
    end

    # Check length consistency
    if length(formulaList) != length(massDensityList)
        throw(ArgumentError("Formula list and mass density list must have the same length"))
    end

    # ==================================================================================
    # PARALLEL PROCESSING SETUP
    # ==================================================================================

    # Sort energy array for consistent results
    energy_sorted = sort(energy)

    # Pre-allocate results dictionary
    results = Dict{String,XRayResult}()

    # Thread-safe lock for dictionary access
    results_lock = ReentrantLock()

    # ==================================================================================
    # PARALLEL CALCULATION
    # ==================================================================================

    # Process each formula in parallel using available threads
    @threads for i in 1:length(formulaList)
        formula = formulaList[i]
        mass_density = massDensityList[i]

        try
            # Calculate properties for this formula
            result = SubRefrac(formula, energy_sorted, mass_density)

            # Thread-safe insertion into results dictionary
            lock(results_lock) do
                results[formula] = result
            end
        catch e
            # Log errors but continue processing other formulas
            @warn "Failed to process formula $formula: $e"
        end
    end

    return results
end

"""
    SubRefrac(formulaStr, energy, massDensity) -> XRayResult

Calculate X-ray optical properties for a single chemical formula.

This function performs the detailed calculation of all X-ray optical properties
for a single material composition.

# Arguments
- 'formulaStr::String': Chemical formula (e.g., "SiO2", "Al2O3")
- 'energy::Vector{Float64}': X-ray energies in KeV
- 'massDensity::Float64': Mass density in g/cm³

# Returns
- 'XRayResult': Complete set of calculated optical properties

# Calculation Steps
1. Parse chemical formula into elements and counts
2. Look up atomic data (atomic number, mass) for each element
3. Calculate molecular weight and electron count
4. Convert energies to wavelengths
5. Load atomic scattering factor tables
6. Interpolate scattering factors at requested energies
7. Calculate dispersion and absorption coefficients
8. Compute derived quantities (critical angle, attenuation length, SLD)

# Mathematical Background
The calculations are based on the X-ray optical constants:
- Refractive index: n = 1 - δ - iβ
- δ (dispersion): Real part of refractive index deviation
- β (absorption): Imaginary part of refractive index deviation

# Examples
'''julia
# Calculate properties for quartz at multiple energies
result = SubRefrac("SiO2", [8.0, 10.0, 12.0], 2.2)

# Access specific properties
println("Molecular weight: ", result.MW)
println("Critical angles: ", result.Critical_Angle)
println("Attenuation lengths: ", result.Attenuation_Length)
'''
"""
function SubRefrac(formulaStr::String, energy::Vector{Float64}, massDensity::Float64)
    # ==================================================================================
    # FORMULA PARSING AND ATOMIC DATA LOOKUP
    # ==================================================================================

    # Parse the chemical formula into elements and their counts
    element_symbols, element_counts = parse_formula(formulaStr)
    n_elements = length(element_symbols)
    n_energies = length(energy)

    # Pre-allocate arrays for efficiency
    molecular_weight = 0.0
    number_of_electrons = 0.0
    atomic_data = Vector{Tuple{Int,Float64}}(undef, n_elements)

    # Look up atomic data for each element in the formula
    for i in 1:n_elements
        atomic_number, atomic_mass = get_atomic_data(element_symbols[i])
        atomic_data[i] = (atomic_number, atomic_mass)

        # Accumulate molecular weight and total electrons
        molecular_weight += element_counts[i] * atomic_mass
        number_of_electrons += atomic_number * element_counts[i]
    end

    # ==================================================================================
    # ENERGY-WAVELENGTH CONVERSION
    # ==================================================================================

    # Convert X-ray energies (KeV) to wavelengths (m)
    # λ = hc/E, where h = Planck constant, c = speed of light
    wavelength = ENERGY_TO_WAVELENGTH_FACTOR ./ energy

    # Convert energies to eV for scattering factor interpolation
    energy_ev = energy .* 1000.0

    # ==================================================================================
    # ARRAY INITIALIZATION
    # ==================================================================================

    # Pre-allocate output arrays with zeros
    dispersion = zeros(Float64, n_energies)      # δ (dispersion coefficient)
    absorption = zeros(Float64, n_energies)      # β (absorption coefficient)
    f1_total = zeros(Float64, n_energies)        # Total f1 (real scattering factor)
    f2_total = zeros(Float64, n_energies)        # Total f2 (imaginary scattering factor)

    # ==================================================================================
    # SCATTERING FACTOR TABLE LOADING AND INTERPOLATION
    # ==================================================================================

    # Load atomic scattering factor tables and create interpolators
    element_data = Vector{Tuple{Float64,Any,Any}}(undef, n_elements)

    for i in 1:n_elements
        # Load f1, f2 table for this element
        table = load_f1f2_table(element_symbols[i])

        # Create interpolators for smooth interpolation between tabulated values
        itp1, itp2 = create_interpolators(table.E, table.f1, table.f2)

        # Store element count and interpolators
        element_data[i] = (element_counts[i], itp1, itp2)
    end

    # ==================================================================================
    # MAIN SCATTERING CALCULATION
    # ==================================================================================

    # Calculate dispersion, absorption, and total scattering factors
    # This is the computationally intensive part
    calculate_scattering_factors!(
        energy_ev, wavelength, massDensity, molecular_weight,
        element_data, dispersion, absorption, f1_total, f2_total
    )

    # ==================================================================================
    # DERIVED QUANTITY CALCULATIONS
    # ==================================================================================

    # Calculate electron density (electrons per unit volume)
    # ρₑ = ρ × Nₐ × Z / M × 10⁻³⁰ (converted to electrons/Å³)
    electron_density = 1e6 * massDensity / molecular_weight * AVOGADRO * number_of_electrons / 1e30

    # Calculate critical angle for total external reflection
    # θc = √(2δ) (in radians), converted to degrees
    critical_angle = sqrt.(2 .* dispersion) .* (180 / π)

    # Calculate X-ray attenuation length
    # 1/e attenuation length = λ/(4πβ) (in cm)
    attenuation_length = wavelength ./ absorption ./ (4 * π) .* 1e2

    # Calculate scattering length densities (SLD)
    # SLD = 2π × (δ + iβ) / λ² (in units of Å⁻²)
    wavelength_sq = wavelength .^ 2
    sld_factor = 2 * π / 1e20  # Conversion factor to Å⁻²

    re_sld = dispersion .* sld_factor ./ wavelength_sq  # Real part of SLD
    im_sld = absorption .* sld_factor ./ wavelength_sq  # Imaginary part of SLD

    # ==================================================================================
    # RESULT ASSEMBLY
    # ==================================================================================

    # Create and return the complete result structure
    return XRayResult(
        formulaStr,                    # Chemical formula
        molecular_weight,              # Molecular weight (g/mol)
        number_of_electrons,           # Electrons per molecule
        massDensity,                   # Mass density (g/cm³)
        electron_density,              # Electron density (1/Å³)
        energy,                        # X-ray energy (KeV)
        wavelength .* 1e10,            # Wavelength (Å)
        dispersion,                    # Dispersion coefficient
        absorption,                    # Absorption coefficient
        f1_total,                      # Total f1
        f2_total,                      # Total f2
        critical_angle,                # Critical angle (degrees)
        attenuation_length,            # Attenuation length (cm)
        re_sld,                        # Real SLD (Å⁻²)
        im_sld                         # Imaginary SLD (Å⁻²)
    )
end

# =====================================================================================
# UTILITY FUNCTIONS
# =====================================================================================

"""
    clear_caches!()

Clear all cached data to free memory.

This function clears both the atomic data cache and the f1f2 table cache.
Useful for memory management in long-running applications or when processing
many different materials.

# Examples
'''julia
# After processing many materials, clear caches to free memory
clear_caches!()
'''
"""
function clear_caches!()
    empty!(ATOMIC_DATA_CACHE)
    empty!(F1F2_TABLE_CACHE)
    println("Caches cleared - memory freed")
end

end  # module