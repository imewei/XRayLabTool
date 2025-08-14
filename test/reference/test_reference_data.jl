#!/usr/bin/env julia

"""
Test script for the ReferenceData helper module.
Verifies that the module can load X-ray optical constants correctly.
"""

push!(LOAD_PATH, ".")
using .ReferenceData

function test_reference_data()
    println("Testing ReferenceData.jl helper module...")
    println("=" ^ 50)

    # Test available materials
    materials = get_available_materials()
    println("Available materials: ", materials)

    # Test loading individual materials
    for material in materials
        println("\nTesting $material:")

        try
            # Test JSON loading
            data_json = load_optical_constants(material, format = "json")
            println("  ✓ JSON format loaded successfully")
            println(
                "    - Energy range: $(minimum(data_json["energy_keV"])) - $(maximum(data_json["energy_keV"])) keV",
            )
            println("    - Data points: $(length(data_json["energy_keV"]))")
            println("    - Metadata available: ", haskey(data_json, "metadata"))

            # Test CSV loading
            data_csv = load_optical_constants(material, format = "csv")
            println("  ✓ CSV format loaded successfully")
            println(
                "    - Energy range: $(minimum(data_csv["energy_keV"])) - $(maximum(data_csv["energy_keV"])) keV",
            )
            println("    - Data points: $(length(data_csv["energy_keV"]))")

            # Verify data consistency
            if data_json["energy_keV"] == data_csv["energy_keV"] &&
               data_json["f1"] == data_csv["f1"] &&
               data_json["f2"] == data_csv["f2"]
                println("  ✓ JSON and CSV data are consistent")
            else
                println("  ⚠ JSON and CSV data differ!")
            end

        catch e
            println("  ✗ Error loading $material: $e")
        end
    end

    # Test loading all materials
    println("\nTesting load_all_materials():")
    try
        all_data = load_all_materials()
        println("  ✓ Successfully loaded $(length(all_data)) materials")
        for (mat, data) in all_data
            println("    - $mat: $(length(data["energy_keV"])) data points")
        end
    catch e
        println("  ✗ Error loading all materials: $e")
    end

    # Test edge energies
    println("\nTesting edge energies:")
    edges = get_edge_energies()
    for (element, energy) in edges
        println("  $element K-edge: $energy keV")
    end

    # Test material properties
    println("\nTesting material properties:")
    props = get_material_properties()
    for (material, properties) in props
        println("  $material: Z=$(properties["Z"]), ρ=$(properties["density_g_cm3"]) g/cm³")
    end

    println("\n" * "=" ^ 50)
    println("Reference data tests completed!")
end

# Run tests if script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    test_reference_data()
end
