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

## Debugging

XRayLabTool includes comprehensive debug logging across 6 categories. All log points use `@debug` level — zero cost when disabled (default).

### Enable logging

```julia
# Via environment variable (before loading package)
ENV["JULIA_DEBUG"] = "XRayLabTool"
using XRayLabTool

result = calculate_single_material_properties("SiO2", [8.0, 10.0], 2.2)
# Prints: formula parsing, cache hits/misses, file I/O, computation steps, timing
```

### Log categories

Each log message is tagged with a `_group` for targeted filtering:

| Group | What it traces |
|-------|---------------|
| `:parser` | Formula parsing steps, parenthesized group expansion |
| `:cache` | Cache hits, misses, writes, clears |
| `:io` | .nff file path resolution, file loading with timing |
| `:validation` | Energy range checks, formula validation |
| `:computation` | Per-material calculation: MW, scattering factors, derived quantities, timing |
| `:batch` | Batch orchestration: thread dispatch, parallel timing |

### Filter by category

```julia
using Logging

# Custom logger that filters by group
struct GroupFilterLogger <: AbstractLogger
    inner::AbstractLogger
    groups::Set{Symbol}
end

Logging.min_enabled_level(l::GroupFilterLogger) = Logging.min_enabled_level(l.inner)
Logging.shouldlog(l::GroupFilterLogger, args...) = Logging.shouldlog(l.inner, args...)
Logging.catch_exceptions(l::GroupFilterLogger) = Logging.catch_exceptions(l.inner)

function Logging.handle_message(l::GroupFilterLogger, level, message, _module, group, id,
        file, line; kwargs...)
    group in l.groups || return
    Logging.handle_message(
        l.inner, level, message, _module, group, id, file, line; kwargs...)
end

# Show only cache and I/O messages
with_logger(GroupFilterLogger(ConsoleLogger(stderr, Logging.Debug), Set([:cache, :io]))) do
    result = calculate_single_material_properties("SiO2", [8.0], 2.2)
end
```

## Index

```@index
```
