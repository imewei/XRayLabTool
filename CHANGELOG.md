# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2024-12-19

### 🚨 BREAKING CHANGES

This release introduces significant API improvements to enhance code readability and follow Julia naming conventions. **All changes are backward compatible through deprecation warnings until v1.0.0**.

#### New Function Names (Recommended API)

- `calculate_xray_properties()` - **NEW**: Replaces `Refrac()` for multiple materials
- `calculate_material_properties()` - **NEW**: Replaces `SubRefrac()` for single materials

#### New Struct and Field Names

- `XRayResult` struct fields have been renamed for consistency:
  - `molecular_weight` (was `MW`)
  - `electron_count` (was `Number_Of_Electrons`) 
  - `mass_density` (was `Density`)
  - `electron_density` (unchanged)
  - `energy` (was `Energy`)
  - `wavelength` (was `Wavelength`)
  - `dispersion` (was `Dispersion`)
  - `absorption` (was `Absorption`)
  - `f1_real` (was `f1`)
  - `f2_imaginary` (was `f2`)
  - `critical_angle` (was `Critical_Angle`)
  - `attenuation_length` (was `Attenuation_Length`)
  - `real_sld` (was `reSLD`)
  - `imaginary_sld` (was `imSLD`)

#### Improved Constant Names

- `THOMSON_SCATTERING_LENGTH` (was `THOMPSON`)
- `SPEED_OF_LIGHT_MPS` (was `SPEED_OF_LIGHT`)
- `PLANCK_CONSTANT` (was `PLANCK`)
- `ELEMENTARY_CHARGE` (was `ELEMENT_CHARGE`)
- `AVOGADRO_NUMBER` (was `AVOGADRO`)

### Added

- **Deprecation system**: Old function names now show warnings guiding users to new API
- **Enhanced documentation**: All functions now have comprehensive docstrings with examples
- **Better error messages**: More descriptive error messages for invalid inputs
- **Improved code organization**: Functions grouped by purpose with clear section headers

### Changed

- **Function naming**: Adopted snake_case convention following Julia best practices
- **Variable naming**: Replaced abbreviations with descriptive names throughout codebase  
- **Struct field naming**: Consistent snake_case naming for all struct fields
- **Constant naming**: More descriptive names for physical constants
- **Documentation**: Updated all examples to show new API usage

### Deprecated

- `Refrac()` - Use `calculate_xray_properties()` instead
- `SubRefrac()` - Use `calculate_material_properties()` instead
- Old struct field names - Access through new field names
- Abbreviated constant names - Use new descriptive constant names

**⚠️ Deprecation Timeline**: Old API will be removed in v1.0.0 (estimated 6 months). All deprecated functions will show warnings with migration instructions.

### Migration Guide

#### For Multiple Materials (was `Refrac`)
```julia
# OLD (deprecated)
results = Refrac(["SiO2", "Al2O3"], [8.0, 10.0], [2.2, 3.95])

# NEW (recommended)  
results = calculate_xray_properties(["SiO2", "Al2O3"], [8.0, 10.0], [2.2, 3.95])
```

#### For Single Material (was `SubRefrac`)
```julia
# OLD (deprecated)
result = SubRefrac("SiO2", [8.0, 10.0, 12.0], 2.2)

# NEW (recommended)
result = calculate_material_properties("SiO2", [8.0, 10.0, 12.0], 2.2)
```

#### Accessing Results
```julia
# OLD field names (deprecated)
println(result.MW)                    # molecular weight
println(result.Number_Of_Electrons)   # electron count
println(result.f1)                   # real scattering factor

# NEW field names (recommended)
println(result.molecular_weight)      # molecular weight  
println(result.electron_count)        # electron count
println(result.f1_real)              # real scattering factor
```

### Performance

- No performance regression - all optimizations retained
- Caching system unchanged and fully functional
- Thread safety maintained for parallel processing

### Testing

- All existing tests updated to use new API
- Backward compatibility tests added for deprecated functions
- Enhanced test coverage for edge cases and error handling

---

## [0.4.1] - Previous Release

### Bug Fixes
- Fixed interpolation edge cases for extreme energy ranges
- Improved error handling for invalid chemical formulas

## [0.4.0] - Previous Release

### Added
- Initial release of core X-ray property calculations
- Support for multiple chemical formulas
- Caching system for performance optimization
- Comprehensive test suite

---

## Migration Support

If you need assistance migrating your code to the new API, please:

1. **Check deprecation warnings**: Run your existing code - warnings will show exact replacements
2. **Review examples**: Updated documentation shows new API usage patterns  
3. **Open an issue**: For complex migration scenarios, we're happy to help

## Backward Compatibility Promise

- All deprecated functions will continue working until v1.0.0
- Warnings will clearly indicate replacement functions
- No silent behavioral changes - only naming improvements

**Questions?** Open an issue or discussion on GitHub for migration support.
