# Graph Report - /Users/b80985/Projects/XRayLabTool  (2026-05-06)

## Corpus Check
- Corpus is ~6,537 words - fits in a single context window. You may not need a graph.

## Summary
- 72 nodes · 92 edges · 13 communities (10 shown, 3 thin omitted)
- Extraction: 96% EXTRACTED · 3% INFERRED · 1% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Scattering Calculation Core|Scattering Calculation Core]]
- [[_COMMUNITY_Public API + Batch Processing|Public API + Batch Processing]]
- [[_COMMUNITY_Dependencies and Project Root|Dependencies and Project Root]]
- [[_COMMUNITY_Caching and Performance|Caching and Performance]]
- [[_COMMUNITY_Single Material Implementation|Single Material Implementation]]
- [[_COMMUNITY_Scattering Data and Sources|Scattering Data and Sources]]
- [[_COMMUNITY_Batch Implementation + Validation|Batch Implementation + Validation]]
- [[_COMMUNITY_Documentation Build|Documentation Build]]
- [[_COMMUNITY_Element Data Loading|Element Data Loading]]
- [[_COMMUNITY_Formula Parser Internals|Formula Parser Internals]]
- [[_COMMUNITY_XRayResult and Field Migrations|XRayResult and Field Migrations]]
- [[_COMMUNITY_Cache Management|Cache Management]]
- [[_COMMUNITY_Debug Logging System|Debug Logging System]]

## God Nodes (most connected - your core abstractions)
1. `XRayLabTool` - 23 edges
2. `_calculate_single_material_impl()` - 12 edges
3. `Dispersion and Absorption Coefficients (δ, β)` - 8 edges
4. `_calculate_xray_properties_impl()` - 7 edges
5. `calculate_single_material_properties` - 6 edges
6. `_validate_formulas()` - 5 edges
7. `_parse_group()` - 5 edges
8. `parse_formula()` - 4 edges
9. `calculate_xray_properties` - 4 edges
10. `load_element_interpolators` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Dispersion and Absorption Coefficients (δ, β)` --implements--> `accumulate_optical_coefficients!`  [EXTRACTED]
  docs/src/physics.md → src/XRayLabTool.jl
- `v0.6 Performance Optimization` --conceptually_related_to--> `Thread-safe caching system`  [INFERRED]
  docs/src/changelog.md → src/XRayLabTool.jl
- `Breaking: Vector return type (v0.7)` --references--> `calculate_xray_properties`  [EXTRACTED]
  docs/src/changelog.md → src/XRayLabTool.jl
- `Migration: Strict batch validation` --references--> `calculate_xray_properties`  [EXTRACTED]
  docs/src/migration.md → src/XRayLabTool.jl
- `Migration: Field rename map (v0.5)` --references--> `XRayResult struct`  [EXTRACTED]
  docs/src/migration.md → src/XRayLabTool.jl

## Hyperedges (group relationships)
- **X-ray Property Calculation Pipeline** — XRayLabTool_parse_formula, XRayLabTool_atomic_number_and_mass, XRayLabTool_load_element_interpolators, XRayLabTool_accumulate_optical_coefficients, XRayLabTool_compute_derived_quantities [INFERRED 0.85]
- **Physics Theory → Implementation Bridge** — physics_dispersion_beta, physics_thomson_scattering, physics_atomic_scattering_factors, XRayLabTool_accumulate_optical_coefficients, physics_henke_data [INFERRED 0.80]
- **API Evolution (v0.4→v0.7)** — changelog_v05_api_rename, changelog_v06_perf, changelog_v07_breaking_dict_to_vec, migration_field_renames [INFERRED 0.80]

## Communities (13 total, 3 thin omitted)

### Community 0 - "Scattering Calculation Core"
Cohesion: 0.14
Nodes (15): accumulate_optical_coefficients!, calculate_single_material_properties, _compute_derived_quantities, parse_formula, Negative delta guard (v0.7), Parenthesized formula support (v0.7), Formula Syntax Patterns, Installation (Julia 1.10+) (+7 more)

### Community 1 - "Public API + Batch Processing"
Cohesion: 0.2
Nodes (10): Refrac (deprecated), SubRefrac (deprecated), calculate_xray_properties, Multi-threaded batch processing, Deprecated API (Refrac, SubRefrac), API Rename (v0.5): Refrac→calculate_xray_properties, Breaking: Vector return type (v0.7), Multi-threading Usage (+2 more)

### Community 2 - "Dependencies and Project Root"
Cohesion: 0.29
Nodes (5): Logging, Mendeleev, PCHIPInterpolation, XRayLabTool, Unitful

### Community 3 - "Caching and Performance"
Cohesion: 0.29
Nodes (7): atomic_number_and_mass, Thread-safe caching system, v0.6 Performance Optimization, Lock-free frozen cache optimization (v0.7.1), Migration: CSV/DataFrames removed (v0.6), Physical Constants (CODATA), Thomson Scattering Length

### Community 4 - "Single Material Implementation"
Cohesion: 0.33
Nodes (6): accumulate_optical_coefficients!(), _calculate_single_material_impl(), calculate_single_material_properties(), _compute_derived_quantities(), SubRefrac(), XRayResult

### Community 5 - "Scattering Data and Sources"
Cohesion: 0.33
Nodes (6): load_element_interpolators, Data Source: CXRO/Henke tables, Atomic Scattering Factors (f1, f2), CXRO/Henke Tables, Henke et al. 1993 Reference, PCHIP Interpolation

### Community 6 - "Batch Implementation + Validation"
Cohesion: 0.4
Nodes (5): calculate_xray_properties(), _calculate_xray_properties_impl(), Refrac(), _validate_density(), _validate_energy_range()

### Community 8 - "Element Data Loading"
Cohesion: 0.67
Nodes (3): atomic_number_and_mass(), load_element_interpolators(), _validate_formulas()

### Community 9 - "Formula Parser Internals"
Cohesion: 1.0
Nodes (3): parse_formula(), _parse_group(), _parse_number()

### Community 10 - "XRayResult and Field Migrations"
Cohesion: 0.67
Nodes (3): XRayResult struct, Snake-case field rename (v0.5), Migration: Field rename map (v0.5)

## Ambiguous Edges - Review These
- `Thomson Scattering Length` → `Lock-free frozen cache optimization (v0.7.1)`  [AMBIGUOUS]
  docs/src/changelog.md · relation: conceptually_related_to

## Knowledge Gaps
- **28 isolated node(s):** `Documenter`, `XRayLabTool`, `Logging`, `PCHIPInterpolation`, `Mendeleev` (+23 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Thomson Scattering Length` and `Lock-free frozen cache optimization (v0.7.1)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `calculate_single_material_properties` connect `Scattering Calculation Core` to `Public API + Batch Processing`, `Caching and Performance`, `Scattering Data and Sources`?**
  _High betweenness centrality (0.158) - this node is a cross-community bridge._
- **Why does `Dispersion and Absorption Coefficients (δ, β)` connect `Scattering Calculation Core` to `Caching and Performance`, `Scattering Data and Sources`?**
  _High betweenness centrality (0.106) - this node is a cross-community bridge._
- **Why does `SubRefrac (deprecated)` connect `Public API + Batch Processing` to `Scattering Calculation Core`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **What connects `Documenter`, `XRayLabTool`, `Logging` to the rest of the system?**
  _28 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Scattering Calculation Core` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._