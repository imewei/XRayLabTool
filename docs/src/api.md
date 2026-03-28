# API Reference

## Overview

```@docs
XRayLabTool
```

## Public API

### Main functions

```@docs
calculate_xray_properties
calculate_single_material_properties
```

### Result type

```@docs
XRayResult
```

## Deprecated functions

These functions still work but will issue deprecation warnings. Use the new names instead.

| Deprecated | Replacement |
|------------|-------------|
| `Refrac` | [`calculate_xray_properties`](@ref) |
| `SubRefrac` | [`calculate_single_material_properties`](@ref) |

```@docs
Refrac
SubRefrac
```

## Internal functions

These are not exported but are accessible via `XRayLabTool.function_name`.

### Element data

```@docs
XRayLabTool.atomic_number_and_mass
XRayLabTool.load_element_interpolators
```

### Formula parsing

```@docs
XRayLabTool.parse_formula
```

### Core calculation

```@docs
XRayLabTool.accumulate_optical_coefficients!
```

### Utilities

```@docs
XRayLabTool.clear_caches!
```

## Index

```@index
```
