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

### Single Material

```julia
using XRayLabTool

result = SubRefrac("SiO2", [8.0, 10.0, 12.0], 2.2)
```

### Multiple Materials

```julia
results = Refrac(["SiO2", "Al2O3"], [8.0, 10.0, 12.0], [2.2, 3.95])
```

### Accessing Results

```julia
res = results["SiO2"]
println(res.MW)
println(res.Dispersion)
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

The result contains:

- `Formula::String` – formula
- `MW::Float64` – molecular_weight (g/mol)
- `Number_Of_Electrons::Float64` – num_electrons (electrons/molecule)
- `Density::Float64` – mass_density (g/cm³)
- `Electron_Density::Float64` – electron_density (1/Å³)
- `Energy::Vector{Float64}` – X-ray energy (keV)
- `Wavelength::Vector{Float64}` – wavelength (Å)
- `Dispersion::Vector{Float64}` – Dispersion coefficient delta
- `Absorption::Vector{Float64}` – Absorption coefficient beta
- `f1::Vector{Float64}` – Real atomic scattering factor
- `f2::Vector{Float64}` – Imaginary atomic scattering factor
- `Critical_Angle::Vector{Float64}` – critical_angle (degrees)
- `Attenuation_Length::Vector{Float64}` – attenuation_length (cm)
- `reSLD::Vector{Float64}` – SLD_real (Å⁻²)
- `imSLD::Vector{Float64}` – SLD_imag (Å⁻²)

---

## 📘 Example

```julia
result = SubRefrac("SiO2", collect(8:0.5:10), 2.33)

println(result.Formula)         # "SiO2"
println(result.Dispersion[1])        # First value of δ
println(result.reSLD[end])   # Last value of real SLD
```

---

## 🔗 References

- [CXRO - Center for X-ray Optics](http://www.cxro.lbl.gov)
- [NIST - National Institute of Standards and Technology](http://www.nist.gov)

> This Julia module is translated from a MATLAB script originally developed by **Zhang Jiang** at the **Advanced Photon Source**, Argonne National Laboratory.

---


## 🧪 License

MIT License
