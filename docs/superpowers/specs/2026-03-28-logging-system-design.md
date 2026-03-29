# Logging System Design

**Goal:** Add comprehensive debug and diagnostic logging to XRayLabTool using Julia's stdlib `Logging`, with topic categories for targeted filtering and lightweight timing for key operations.

**Approach:** Inline `@debug`/`@info` calls directly in `src/XRayLabTool.jl`. No new files, no new dependencies. Zero cost when logging is off.

---

## Log Categories

Each log message is tagged with a `_group` symbol for topic-based filtering:

| Group | Scope |
|-------|-------|
| `:parser` | Formula parsing: input, group expansion, final result, errors |
| `:cache` | Cache hits, misses, writes, clears |
| `:io` | .nff file path resolution, file loading |
| `:validation` | Energy range checks, formula validation, batch error collection |
| `:computation` | Per-material calculation: MW, electron density, delta/beta, derived quantities |
| `:batch` | Batch orchestration: dispatch, thread count, timing |

## Log Levels

| Level | Used for |
|-------|----------|
| `@debug` | All 25 log points including summaries and timing |

All logging uses `@debug` to ensure zero allocation overhead when disabled (default). The original design specified `@info` for summary events (points #9, #19, #24), but `@info` always evaluates its arguments and allocates strings, which violated the performance contract (<30KB per call). Since the performance contract takes precedence, all points use `@debug`.

Existing `@warn` (deprecation) and `@error` usage unchanged.

## Log Points

### Parser (`:parser`) — 4 points

1. **`parse_formula` entry** (`@debug`): Log the raw formula string being parsed.
2. **`_parse_group` expansion** (`@debug`): Log parenthesized group result — sub-elements, sub-counts, and multiplier applied. Only fires for parenthesized formulas.
3. **`parse_formula` result** (`@debug`): Log final parsed element symbols and counts.
4. **Invalid formula** (`@debug`): Log rejection reason (already throws `ArgumentError`, this adds diagnostic context before the throw).

### Cache (`:cache`) — 5 points

5. **`atomic_number_and_mass` cache hit** (`@debug`): Log element symbol, return cached (Z, mass).
6. **`atomic_number_and_mass` cache miss + write** (`@debug`): Log element symbol, looked-up Z and mass, cache write.
7. **`load_element_interpolators` cache hit** (`@debug`): Log element symbol.
8. **`load_element_interpolators` cache miss + write** (`@debug`): Log element symbol, .nff file loaded.
9. **`clear_caches!`** (`@debug`): Log that caches were cleared.

### I/O (`:io`) — 2 points

10. **File path resolved** (`@debug`): Log the full .nff file path for the element being loaded.
11. **File loaded** (`@debug`): Log element symbol, line count (data points), elapsed time.

### Validation (`:validation`) — 3 points

12. **Energy range validated** (`@debug`): Log energy count, min, max.
13. **`_validate_formulas` result** (`@debug`): Log formula count validated, or list of invalid formulas (before throwing).
14. **Batch input summary** (`@debug`): Log formula count, energy count, density count.

### Computation (`:computation`) — 6 points

15. **Single-material entry** (`@debug`): Log formula, density, energy count.
16. **Molecular weight + electrons** (`@debug`): Log computed MW, total electrons, element count.
17. **Per-element scattering contribution** (`@debug`): Log once per element (not per energy): element symbol, atom count in formula. Logged during element_data construction, NOT inside the `accumulate_optical_coefficients!` inner loop.
18. **Derived quantities** (`@debug`): Log electron density, critical angle range, attenuation length range.
19. **Single-material exit** (`@debug`): Log formula, MW, energy count, elapsed_ms.
20. **Result summary** (`@debug`): Log formula, delta range, beta range, SLD range.

### Batch (`:batch`) — 4 points

21. **Batch entry** (`@debug`): Log formula count, energy count, thread count (`Threads.nthreads()`).
22. **Validation + cache warm-up complete** (`@debug`): Log elapsed_ms.
23. **Parallel section complete** (`@debug`): Log elapsed_ms.
24. **Batch exit** (`@debug`): Log total elapsed_ms, result count.

## Timing

- Use `time_ns()` for lightweight timing at entry/exit of key functions.
- Timing variables are only computed when the log level is active (wrap in the same scope as the log call, or use local variables that are always cheap to compute).
- Report as `elapsed_ms` (Float64, 3 decimal places).

Pattern:
```julia
function _calculate_single_material_impl(...)
    t_start = time_ns()
    # ... computation ...
    elapsed_ms = (time_ns() - t_start) / 1e6
    @debug "Material calculation complete" _group = :computation formula = formulaStr molecular_weight = molecular_weight energy_count = n_energies elapsed_ms = round(elapsed_ms; digits = 3)
    return result
end
```

The `t_start = time_ns()` call is ~5ns — negligible even when logging is off.

## User Interface

### Enable all debug logging
```julia
# Via environment variable (before loading package)
ENV["JULIA_DEBUG"] = "XRayLabTool"

# Or programmatically
using Logging
global_logger(ConsoleLogger(stderr, Logging.Debug))
```

### Filter by category
Julia's `ConsoleLogger` doesn't filter by `_group` natively, but users can create a filtered logger:

```julia
using Logging

struct GroupFilterLogger <: AbstractLogger
    inner::AbstractLogger
    groups::Set{Symbol}
end

Logging.min_enabled_level(l::GroupFilterLogger) = Logging.min_enabled_level(l.inner)
Logging.shouldlog(l::GroupFilterLogger, args...) = Logging.shouldlog(l.inner, args...)
Logging.catch_exceptions(l::GroupFilterLogger) = Logging.catch_exceptions(l.inner)

function Logging.handle_message(l::GroupFilterLogger, level, message, _module, group, id, file, line; kwargs...)
    group in l.groups || return
    Logging.handle_message(l.inner, level, message, _module, group, id, file, line; kwargs...)
end

# Use: only show :cache and :io messages
with_logger(GroupFilterLogger(ConsoleLogger(stderr, Logging.Debug), Set([:cache, :io]))) do
    result = calculate_single_material_properties("SiO2", [8.0], 2.2)
end
```

This `GroupFilterLogger` is a **documentation example only** — it goes in the docs, not in the package source. The package itself only uses stdlib logging.

## Performance Contract

- All detailed logging at `@debug` level — zero argument evaluation when debug is off.
- `time_ns()` calls (~5ns each) are the only always-executed overhead — 2 per single-material call, 6 per batch call.
- Existing performance benchmarks must still pass: <30KB allocation, <500us per single-material call.
- No new external dependencies (`Logging` is a Julia stdlib, added to `[deps]` for module access).

## Files Modified

| File | Changes |
|------|---------|
| `src/XRayLabTool.jl` | Add 25 `@debug` calls inline, add `time_ns()` timing at function entry/exit |
| `test/test_edge_cases.jl` | Add test that logging doesn't break functionality (calculate with debug logger active) |
| `docs/src/api.md` | Add "Debugging" section with usage examples |

## Non-Goals

- No custom logger types in the package (users bring their own)
- No log-to-file built-in (users configure their logger)
- No structured JSON logging (overkill for a scientific package)
- No allocation tracking in logs (use dedicated benchmarks)
- No changes to existing `@warn` deprecation messages
