using XRayLabTool
using Test

# Test constants
const DEFAULT_TOL = 1e-6
const ENERGIES = [5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
const DENSITIES = [2.2, 1.0]
const MATERIALS = ["SiO2", "H2O"]

# Helper function for approximate equality testing
function test_approx_equal(actual, expected; tol=DEFAULT_TOL, description="")
    if !isempty(description)
        @testset "$description" begin
            @test actual ≈ expected atol=tol
        end
    else
        @test actual ≈ expected atol=tol
    end
end

# Helper function to test array approximate equality
function test_array_approx_equal(actual, expected; tol=DEFAULT_TOL, description="")
    if !isempty(description)
        @testset "$description" begin
            @test length(actual) == length(expected)
            @test all(abs.(actual .- expected) .< tol)
        end
    else
        @test length(actual) == length(expected)
        @test all(abs.(actual .- expected) .< tol)
    end
end

@testset "XRayLabTool.jl Tests" begin
    
    @testset "Basic Setup and Initialization" begin
        # Create test data
        data = Refrac(MATERIALS, ENERGIES, DENSITIES)
        
        # Test that materials are properly initialized
        @test haskey(data, "SiO2")
        @test haskey(data, "H2O")
        
        # Test data structure integrity
        @test length(data) == 2
        @test all(material in keys(data) for material in MATERIALS)
    end
    
    @testset "SiO2 Properties" begin
        data = Refrac(MATERIALS, ENERGIES, DENSITIES)
        sio2 = data["SiO2"]
        
        # Expected values for SiO2
        expected_dispersion = [
            (3, 9.451484792575434e-6),
            (5, 5.69919201789506e-06)
        ]
        
        expected_f1 = [
            (1, 30.641090313037314),
            (3, 30.46419063207884),
            (5, 30.366953850108544)
        ]
        
        expected_reSLD = [
            (3, 1.8929689855615698e-5),
            (5, 1.886926933936152e-5)
        ]
        
        # Test Dispersion values
        @testset "SiO2 Dispersion" begin
            for (idx, expected_val) in expected_dispersion
                test_approx_equal(sio2.Dispersion[idx], expected_val, 
                                description="Dispersion[$idx]")
            end
        end
        
        # Test f1 values
        @testset "SiO2 f1 values" begin
            for (idx, expected_val) in expected_f1
                test_approx_equal(sio2.f1[idx], expected_val, 
                                description="f1[$idx]")
            end
        end
        
        # Test reSLD values
        @testset "SiO2 reSLD values" begin
            for (idx, expected_val) in expected_reSLD
                test_approx_equal(sio2.reSLD[idx], expected_val, 
                                description="reSLD[$idx]")
            end
        end
    end
    
    @testset "H2O Properties" begin
        data = Refrac(MATERIALS, ENERGIES, DENSITIES)
        h2o = data["H2O"]
        
        # Expected values for H2O
        expected_dispersion = [
            (3, 4.734311949237782e-6),
            (5, 2.8574954896752405e-6)
        ]
        
        expected_f1 = [
            (1, 10.110775776847062),
            (3, 10.065881494924541),
            (5, 10.04313810715771)
        ]
        
        expected_reSLD = [
            (3, 9.482008260671003e-6),
            (5, 9.460584107129207e-6)
        ]
        
        # Test Dispersion values
        @testset "H2O Dispersion" begin
            for (idx, expected_val) in expected_dispersion
                test_approx_equal(h2o.Dispersion[idx], expected_val, 
                                description="Dispersion[$idx]")
            end
        end
        
        # Test f1 values
        @testset "H2O f1 values" begin
            for (idx, expected_val) in expected_f1
                test_approx_equal(h2o.f1[idx], expected_val, 
                                description="f1[$idx]")
            end
        end
        
        # Test reSLD values
        @testset "H2O reSLD values" begin
            for (idx, expected_val) in expected_reSLD
                test_approx_equal(h2o.reSLD[idx], expected_val, 
                                description="reSLD[$idx]")
            end
        end
    end
    
    @testset "SubRefrac Silicon Properties" begin
        si = SubRefrac("Si", [20.0], 2.33)
        
        # Expected values for Silicon
        expected_values = [
            (:Dispersion, 1, 1.20966554922812e-06),
            (:f1, 1, 14.048053047106292),
            (:f2, 1, 0.053331074920700626),
            (:reSLD, 1, 1.9777910804587255e-5),
            (:imSLD, 1, 7.508351793358633e-8)
        ]
        
        @testset "Silicon property: $(property)" for (property, idx, expected_val) in expected_values
            actual_val = getproperty(si, property)[idx]
            test_approx_equal(actual_val, expected_val, 
                            description="$(property)[$idx]")
        end
    end
    
    @testset "Edge Cases and Error Handling" begin
        # Test with empty materials (if applicable)
        @test_throws Exception Refrac(String[], ENERGIES, DENSITIES)
        
        # Test with mismatched array lengths
        @test_throws Exception Refrac(MATERIALS, ENERGIES, [1.0])  # Wrong density count
        
        # Test accessing non-existent material
        data = Refrac(MATERIALS, ENERGIES, DENSITIES)
        @test !haskey(data, "NonExistentMaterial")
    end
    
    @testset "Property Consistency" begin
        data = Refrac(MATERIALS, ENERGIES, DENSITIES)
        
        # Test that all materials have the same energy array length
        for material in MATERIALS
            material_data = data[material]
            @test length(material_data.f1) == length(ENERGIES)
            @test length(material_data.Dispersion) == length(ENERGIES)
            @test length(material_data.reSLD) == length(ENERGIES)
        end
    end
end

# Optional: Add a function to run tests with custom tolerance
function run_tests_with_tolerance(tol::Float64 = DEFAULT_TOL)
    # Temporarily modify the default tolerance
    original_tol = DEFAULT_TOL
    global DEFAULT_TOL = tol
    
    try
        # Run the test suite
        return Test.run(@testset "XRayLabTool.jl Tests" begin
            # Include all the test code here if needed
        end)
    finally
        # Restore original tolerance
        global DEFAULT_TOL = original_tol
    end
end

# =====================================================================================
# BENCHMARK TESTS
# =====================================================================================

@testset "Performance benchmarks" begin
    println("Running performance tests...")
    
    # Time single calculation
    @time single_result = SubRefrac("SiO2", collect(1.0:0.1:20.0), 2.2)
    
    # Time multi calculation
    formulas = ["SiO2", "Al2O3", "Fe2O3", "CaCO3", "MgO"]
    densities = [2.2, 3.95, 5.24, 2.71, 3.58]
    @time multi_result = Refrac(formulas, collect(1.0:0.1:20.0), densities)
    
    println("Performance tests completed!")
end
