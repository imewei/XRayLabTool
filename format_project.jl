#!/usr/bin/env julia

"""
Script to format all Julia files in the project using JuliaFormatter.
Run this script to ensure consistent formatting across the entire codebase.
"""

using JuliaFormatter

function format_project()
    println("Formatting all Julia files in the project...")

    # Format all .jl files in src/, test/, and root directory
    dirs_to_format = ["src", "test", "."]

    for dir in dirs_to_format
        if isdir(dir)
            println("Formatting files in: $dir")
            format(dir)
        end
    end

    println("Project formatting complete!")
end

# Run the formatting if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    format_project()
end
