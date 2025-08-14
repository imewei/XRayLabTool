"""
    test/utils.jl

Shared test utilities for XRayLabTool test suite.

This module provides common testing utilities that can be imported across all test files
to avoid repetition and ensure consistent testing patterns.
"""

using Test
using XRayLabTool

# =====================================================================================
# VECTOR COMPARISON UTILITIES
# =====================================================================================

"""
    approx_vec(a, b; atol=1e-8, rtol=1e-5)

Compare two vectors element-wise with tolerance.

This function performs element-wise comparison of two vectors using the given
absolute and relative tolerances. It's useful for comparing floating-point
arrays where exact equality is not appropriate due to numerical precision.

This implements the requested `≈_vec(a,b; atol, rtol)` interface using
a Julia-compatible function name.

# Arguments
- `a`: First vector to compare
- `b`: Second vector to compare
- `atol`: Absolute tolerance (default: 1e-8)
- `rtol`: Relative tolerance (default: 1e-5)

# Returns
- `true` if vectors are approximately equal element-wise, `false` otherwise

# Examples
```julia
a = [1.0, 2.0, 3.0]
b = [1.000001, 2.000001, 3.000001]
@test approx_vec(a, b, atol=1e-5)

# Different sizes should return false
c = [1.0, 2.0]
@test !approx_vec(a, c)
```
"""
function approx_vec(a, b; atol = 1e-8, rtol = 1e-5)
    # Check if vectors have the same length
    length(a) == length(b) || return false

    # Check element-wise approximation
    return all(isapprox(ai, bi, atol = atol, rtol = rtol) for (ai, bi) in zip(a, b))
end

# Note: The requested ≈_vec function is implemented as approx_vec
# due to Julia parser limitations with the ≈_ character combination.
# Users should call approx_vec(a, b; atol, rtol) to get the same functionality.

# =====================================================================================
# CACHE MANAGEMENT UTILITIES
# =====================================================================================

"""
    with_cleared_caches(f)

Execute function `f()` after clearing all caches, ensuring test isolation.

This function clears all XRayLabTool caches before executing the provided function,
ensuring that tests start with a clean state and don't interfere with each other
through cached data.

# Arguments
- `f`: Function to execute after clearing caches (should take no arguments)

# Returns
- The return value of `f()`

# Examples
```julia
result = with_cleared_caches() do
    # This will run with cleared caches
    calculate_xray_properties("H2O", 8.0)
end

# Or using function reference
result = with_cleared_caches(some_test_function)
```
"""
function with_cleared_caches(f)
    # Clear all caches before executing the function
    XRayLabTool.clear_caches!()

    # Execute the provided function and return its result
    return f()
end

# =====================================================================================
# ERROR TESTING UTILITIES
# =====================================================================================

"""
    @expect_error(expr, msg_pattern)

Macro that asserts both exception type and message match a regex pattern.

This macro executes the given expression and verifies that:
1. An exception is thrown
2. The exception message matches the provided regex pattern

# Arguments
- `expr`: Expression that should throw an exception
- `msg_pattern`: Regex pattern or string that the exception message should match

# Examples
```julia
# Test that invalid formula throws appropriate error
@expect_error calculate_xray_properties("InvalidFormula", 8.0) r"Invalid.*formula"

# Test specific error message
@expect_error divide_by_zero() "division by zero"

# Test with string pattern (converted to regex internally)
@expect_error bad_function() "expected error message"
```
"""
macro expect_error(expr, msg_pattern)
    quote
        local exception_caught = false
        local caught_exception = nothing

        try
            $(esc(expr))
        catch e
            exception_caught = true
            caught_exception = e
        end

        # Assert that an exception was thrown
        if !exception_caught
            error("Expected an exception to be thrown, but none was caught")
        end

        # Convert message pattern to Regex if it's a string
        local pattern = $(esc(msg_pattern))
        if pattern isa String
            pattern = Regex(pattern)
        end

        # Get the exception message - handle different exception types
        local exception_msg = if caught_exception isa String
            caught_exception
        elseif hasproperty(caught_exception, :msg)
            caught_exception.msg
        else
            string(caught_exception)
        end

        # Test that the message matches the pattern
        if !occursin(pattern, exception_msg)
            error("Exception message \"$exception_msg\" does not match pattern $pattern")
        end

        # Return true if successful
        true
    end
end

# =====================================================================================
# EXPORTS
# =====================================================================================

# Export all utility functions and macros for easy importing
export approx_vec, with_cleared_caches, @expect_error
