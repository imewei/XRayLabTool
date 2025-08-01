# Example usage of test/utils.jl utilities
# This file demonstrates how to import and use the shared test utilities

using Test
using XRayLabTool

# Import the shared test utilities
include("utils.jl")

# Example test set using the utilities
@testset "Example Test Set Using Utilities" begin
    
    # Example 1: Using approx_vec for vector comparisons
    @testset "Vector Comparisons" begin
        a = [1.0, 2.0, 3.0]
        b = [1.000001, 2.000001, 3.000001]
        
        # Test with different tolerances
        @test approx_vec(a, b, atol=1e-5)
        @test !approx_vec(a, b, atol=1e-10)
        @test !approx_vec(a, [1.0, 2.0])  # Different lengths
    end
    
    # Example 2: Using with_cleared_caches for isolated tests
    @testset "Cache Isolation" begin
        result1 = with_cleared_caches() do
            # This test runs with cleared caches
            SubRefrac("H2O", [8.0], 1.0)
        end
        
        result2 = with_cleared_caches() do
            # This test also runs with cleared caches
            SubRefrac("SiO2", [8.0], 2.2)
        end
        
        @test result1.Formula == "H2O"
        @test result2.Formula == "SiO2"
    end
    
    # Example 3: Using @expect_error for error testing
    @testset "Error Testing" begin
        # Test with regex pattern
        @expect_error SubRefrac("InvalidFormula", [8.0], 1.0) r"Element.*not found"
        
        # Test with string pattern
        @expect_error error("Custom error message") "Custom error message"
        
        # Test invalid energy ranges
        @expect_error SubRefrac("H2O", [-1.0], 1.0) r"Energy.*must be positive"
    end
end

println("Example test usage completed successfully!")
println("Copy the patterns above to use utilities in your own test files.")
