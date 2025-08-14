# XRayLabTool

**Material Property Calculations for X-ray Interactions**

`XRayLabTool` is a Julia module that provides functions to calculate X-ray optical properties of materials based on their chemical formulas and densities. It is particularly useful for synchrotron scientists, materials researchers, and X-ray optics developers.

---

## 📆 Features

- Compute optical constants (δ, β), scattering factors (f1, f2), and other X-ray interaction parameters
- Support for both single and multiple material calculations
- Easy-to-use struct-based output
- Based on CXRO/NIST data tables

---

## 📦 Installation

To install this module via Julia's package manager:

```julia
using Pkg

Pkg.add(url="https://github.com/imewei/XRayLabTool.git")
```

Or

```julia
] add https://github.com/imewei/XRayLabTool.git
```

---

## 🚀 Quick Start

> **📣 New API (v0.5.0+)**: We've improved function names for better readability. Old names still work but will show deprecation warnings.

### Single Material

```julia
using XRayLabTool

# NEW API (recommended)
result = calculate_single_material_properties("SiO2", [8.0, 10.0, 12.0], 2.2)

# OLD API (deprecated but still works)
# result = SubRefrac("SiO2", [8.0, 10.0, 12.0], 2.2)
```

### Multiple Materials

```julia
# NEW API (recommended)
results = calculate_xray_properties(["SiO2", "Al2O3"], [8.0, 10.0, 12.0], [2.2, 3.95])

# OLD API (deprecated but still works)
# results = Refrac(["SiO2", "Al2O3"], [8.0, 10.0, 12.0], [2.2, 3.95])
```

### Accessing Results

```julia
res = results["SiO2"]

# NEW field names (recommended)
println(res.molecular_weight)   # Molecular weight in g/mol
println(res.dispersion)         # Dispersion coefficients
println(res.critical_angle)     # Critical angles in degrees

# OLD field names (deprecated but still work)
# println(res.MW)               # Same as molecular_weight
# println(res.Dispersion)       # Same as dispersion
# println(res.Critical_Angle)   # Same as critical_angle
```

---

## 📥 Input Parameters

| Parameter    | Type                           | Description                                                 |
| ------------ | ------------------------------ | ----------------------------------------------------------- |
| `formula(s)` | `String` or `Vector{String}`   | Case-sensitive chemical formula(s), e.g., `"CO"` vs `"Co"`  |
| `energy`     | `Vector{Float64}`              | X-ray photon energies in keV (valid range: **0.03–30 keV**) |
| `density`    | `Float64` or `Vector{Float64}` | Mass density in g/cm³ (one per formula)                     |

---

## 📤 Output: `XRayResult` Struct

> **📣 v0.5.0 Field Names**: Both old and new field names work for backward compatibility.

The result contains:

| **New Name (Recommended)** | **Old Name (Deprecated)** | **Type** | **Description** |
|----------------------------|---------------------------|----------|------------------|
| `formula` | `Formula` | `String` | Chemical formula |
| `molecular_weight` | `MW` | `Float64` | Molecular weight (g/mol) |
| `number_of_electrons` | `Number_Of_Electrons` | `Float64` | Electrons per molecule |
| `mass_density` | `Density` | `Float64` | Mass density (g/cm³) |
| `electron_density` | `Electron_Density` | `Float64` | Electron density (1/Å³) |
| `energy` | `Energy` | `Vector{Float64}` | X-ray energy (keV) |
| `wavelength` | `Wavelength` | `Vector{Float64}` | X-ray wavelength (Å) |
| `dispersion` | `Dispersion` | `Vector{Float64}` | Dispersion coefficient δ |
| `absorption` | `Absorption` | `Vector{Float64}` | Absorption coefficient β |
| `f1` | `f1` | `Vector{Float64}` | Real atomic scattering factor |
| `f2` | `f2` | `Vector{Float64}` | Imaginary atomic scattering factor |
| `critical_angle` | `Critical_Angle` | `Vector{Float64}` | Critical angle (degrees) |
| `attenuation_length` | `Attenuation_Length` | `Vector{Float64}` | Attenuation length (cm) |
| `real_sld` | `reSLD` | `Vector{Float64}` | Real part of SLD (Å⁻²) |
| `imag_sld` | `imSLD` | `Vector{Float64}` | Imaginary part of SLD (Å⁻²) |

---

## 📚 Example

```julia
# Using new API (recommended)
result = calculate_single_material_properties("SiO2", collect(8:0.5:10), 2.33)

# Access results using new field names
println(result.formula)            # "SiO2"
println(result.dispersion[1])      # First value of δ
println(result.real_sld[end])      # Last value of real SLD

# Old way still works (with deprecation warnings)
# result = SubRefrac("SiO2", collect(8:0.5:10), 2.33)
# println(result.Formula)         # "SiO2" (deprecated field name)
# println(result.Dispersion[1])   # First value of δ (deprecated field name)
# println(result.reSLD[end])      # Last value of real SLD (deprecated field name)
```

---

## 🔗 References

- [CXRO - Center for X-ray Optics](http://www.cxro.lbl.gov)
- [NIST - National Institute of Standards and Technology](http://www.nist.gov)

> This Julia module is translated from a MATLAB script originally developed by **Zhang Jiang** at the **Advanced Photon Source**, Argonne National Laboratory.

---


## 🧪 License

MIT License
