# X-Ray Optical Constants Reference Data

This directory contains high-precision X-ray optical constants from authoritative sources (NIST, Henke tables) for accuracy testing of the XRayLabTool package.

## Materials Included

- **Silicon (Si)** - Z=14, K-edge at 1.838 keV
- **Silicon Dioxide (SiO₂)** - Quartz, O K-edge at 0.532 keV  
- **Water (H₂O)** - Standard reference material
- **Gold (Au)** - Z=79, L₃-edge at 11.919 keV

## Energy Coverage

The data spans edge cases and common X-ray energies:
- **Low energy**: 0.03 keV (edge case)
- **Absorption edges**: K-edges and L-edges for included materials
- **High energy**: 30 keV (edge case)
- **Common ranges**: 1-20 keV (typical X-ray microscopy/spectroscopy)

## File Structure

```
test/reference/
├── README.md                          # This documentation
├── ReferenceData.jl                   # Julia helper module
├── convert_nist_data.py               # Python conversion script
├── test_reference_data.jl             # Test script
│
├── Si_nist_raw.txt                    # Raw NIST data
├── Si_optical_constants.json          # Processed JSON format
├── Si_optical_constants.csv           # Processed CSV format
│
├── SiO2_nist_raw.txt                  # Raw NIST data
├── SiO2_optical_constants.json        # Processed JSON format
├── SiO2_optical_constants.csv         # Processed CSV format
│
├── H2O_nist_raw.txt                   # Raw NIST data
├── H2O_optical_constants.json         # Processed JSON format
├── H2O_optical_constants.csv          # Processed CSV format
│
├── Au_nist_raw.txt                    # Raw NIST data
├── Au_optical_constants.json          # Processed JSON format
└── Au_optical_constants.csv           # Processed CSV format
```

## Data Format

### Raw Data Files (*_nist_raw.txt)
Tab-separated values with comments:
```
# Material (Symbol) X-ray optical constants from NIST
# Energy (keV)    f1          f2
# Additional metadata comments
0.030000    13.8450    0.0082
0.035000    13.8420    0.0114
...
```

### JSON Format (*_optical_constants.json)
```json
{
  "energy_keV": [0.03, 0.035, ...],
  "f1": [13.845, 13.842, ...],
  "f2": [0.0082, 0.0114, ...],
  "metadata": {
    "material": "Si",
    "source": "NIST X-ray Form Factor, Attenuation and Scattering Tables",
    "atomic_number": 14,
    "density_g_cm3": 2.33,
    "description": "X-ray optical constants for Si",
    "columns": {
      "energy_keV": "Photon energy in keV",
      "f1": "Real part of atomic scattering factor",
      "f2": "Imaginary part of atomic scattering factor"
    }
  }
}
```

### CSV Format (*_optical_constants.csv)
```csv
energy_keV,f1,f2
0.03,13.845,0.0082
0.035,13.842,0.0114
...
```

## Usage

### Julia Helper Module

```julia
# Load the helper module
using .ReferenceData

# Get available materials
materials = get_available_materials()  # ["Si", "SiO2", "H2O", "Au"]

# Load optical constants for a specific material
si_data = load_optical_constants("Si")
energies = si_data["energy_keV"]
f1_values = si_data["f1"]
f2_values = si_data["f2"]
metadata = si_data["metadata"]

# Load data in CSV format (no metadata)
au_data = load_optical_constants("Au", format="csv")

# Load all materials at once
all_data = load_all_materials()

# Get absorption edge energies
edges = get_edge_energies()
si_k_edge = edges["Si"]  # 1.838 keV

# Get material properties
props = get_material_properties()
si_props = props["Si"]  # Z, density, formula
```

### Testing

Run the test script to verify everything works:

```bash
julia test_reference_data.jl
```

## Data Sources

- **NIST X-ray Form Factor, Attenuation and Scattering Tables**
  - https://physics.nist.gov/PhysRefData/FFast/html/form.html
  - Authoritative source for X-ray optical constants
  - Based on theoretical calculations and experimental data

- **Henke Tables** (alternative source)
  - https://henke.lbl.gov/optical_constants/
  - Widely used in X-ray optics community
  - Experimental measurements and compilations

## Notes

- **f1**: Real part of the atomic scattering factor (related to refraction)
- **f2**: Imaginary part of the atomic scattering factor (related to absorption)
- **Complex refractive index**: n = 1 - δ - iβ, where δ ∝ f1 and β ∝ f2
- **Edge jumps**: Discontinuities at absorption edges are included in the data
- **Interpolation**: For energies between data points, use appropriate interpolation

## Accuracy Testing

This reference data is intended for:

1. **Unit tests**: Verify optical constant calculations against known values
2. **Regression tests**: Ensure calculations remain consistent across versions  
3. **Benchmarking**: Compare performance and accuracy of different algorithms
4. **Validation**: Cross-check results with authoritative sources

## Maintenance

To add new materials or update data:

1. Add raw data files following the naming convention
2. Update `convert_nist_data.py` to include new materials
3. Run the conversion script: `python3 convert_nist_data.py`
4. Update `ReferenceData.jl` helper functions if needed
5. Add tests for new materials in `test_reference_data.jl`
