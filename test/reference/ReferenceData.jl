"""
ReferenceData.jl

Helper module for loading high-precision X-ray optical constants reference data
from authoritative sources (NIST, Henke tables) for accuracy testing.

Provides functions to load JSON/CSV data files and return dictionaries
for materials: Si, SiO₂, H₂O, Au
"""

module ReferenceData

using JSON3
using CSV
using DataFrames

export load_optical_constants, load_all_materials, get_available_materials

# Path to reference data directory
const REFERENCE_DIR = @__DIR__

"""
    get_available_materials() -> Vector{String}

Returns a list of available materials for which reference data exists.
"""
function get_available_materials()
    return ["Si", "SiO2", "H2O", "Au"]
end

"""
    load_optical_constants(material::String; format::String="json") -> Dict

Load X-ray optical constants for a given material from reference data.

# Arguments
- `material::String`: Material name (one of: "Si", "SiO2", "H2O", "Au")
- `format::String`: Data format to load ("json" or "csv"), default is "json"

# Returns
- `Dict`: Dictionary containing energy_keV, f1, f2 arrays and metadata

# Examples
```julia
# Load Silicon data as JSON (includes metadata)
si_data = load_optical_constants("Si")
energies = si_data["energy_keV"]
f1_values = si_data["f1"]
f2_values = si_data["f2"]
metadata = si_data["metadata"]

# Load Gold data as CSV (data only)
au_data = load_optical_constants("Au", format="csv")
```
"""
function load_optical_constants(material::String; format::String="json")
    if !(material in get_available_materials())
        throw(ArgumentError("Material '$material' not available. Available: $(get_available_materials())"))
    end
    
    if format == "json"
        return load_json_data(material)
    elseif format == "csv"
        return load_csv_data(material)
    else
        throw(ArgumentError("Format '$format' not supported. Use 'json' or 'csv'"))
    end
end

"""
    load_json_data(material::String) -> Dict

Load optical constants from JSON file with full metadata.
"""
function load_json_data(material::String)
    filepath = joinpath(REFERENCE_DIR, "$(material)_optical_constants.json")
    
    if !isfile(filepath)
        throw(ArgumentError("Reference data file not found: $filepath"))
    end
    
    return JSON3.read(read(filepath, String), Dict)
end

"""
    load_csv_data(material::String) -> Dict

Load optical constants from CSV file and return as dictionary.
"""
function load_csv_data(material::String)
    filepath = joinpath(REFERENCE_DIR, "$(material)_optical_constants.csv")
    
    if !isfile(filepath)
        throw(ArgumentError("Reference data file not found: $filepath"))
    end
    
    df = CSV.read(filepath, DataFrame)
    
    return Dict(
        "energy_keV" => df.energy_keV,
        "f1" => df.f1,
        "f2" => df.f2
    )
end

"""
    load_all_materials(; format::String="json") -> Dict{String, Dict}

Load optical constants for all available materials.

# Arguments
- `format::String`: Data format to load ("json" or "csv"), default is "json"

# Returns
- `Dict{String, Dict}`: Dictionary mapping material names to their optical constants

# Examples
```julia
# Load all materials
all_data = load_all_materials()
si_data = all_data["Si"]
au_data = all_data["Au"]
```
"""
function load_all_materials(; format::String="json")
    materials = get_available_materials()
    data = Dict{String, Dict}()
    
    for material in materials
        try
            data[material] = load_optical_constants(material, format=format)
        catch e
            @warn "Failed to load data for $material: $e"
        end
    end
    
    return data
end

"""
    get_edge_energies() -> Dict{String, Float64}

Return K-edge energies for available materials (in keV).
"""
function get_edge_energies()
    return Dict(
        "Si" => 1.838,    # Si K-edge
        "Au" => 11.919,   # Au L3-edge (more relevant for X-ray work)
        "O" => 0.532,     # O K-edge (for SiO2 and H2O)
        "H" => 0.0136     # H K-edge (for H2O)
    )
end

"""
    get_material_properties() -> Dict{String, Dict}

Return basic material properties for reference materials.
"""
function get_material_properties()
    return Dict(
        "Si" => Dict("Z" => 14, "density_g_cm3" => 2.33, "formula" => "Si"),
        "SiO2" => Dict("Z_eff" => 10.0, "density_g_cm3" => 2.65, "formula" => "SiO2"),
        "H2O" => Dict("Z_eff" => 7.4, "density_g_cm3" => 1.00, "formula" => "H2O"),
        "Au" => Dict("Z" => 79, "density_g_cm3" => 19.32, "formula" => "Au")
    )
end

end # module ReferenceData
