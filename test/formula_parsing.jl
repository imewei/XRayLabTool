using Test
using XRayLabTool

@testset "Formula Parsing Tests" begin
    @testset "Single atoms" begin
        symbols, counts = XRayLabTool.parse_formula("C")
        @test symbols == ["C"]
        @test counts == [1.0]

        symbols, counts = XRayLabTool.parse_formula("U")
        @test symbols == ["U"]
        @test counts == [1.0]
    end

    @testset "Mixed case correctness" begin
        symbols, counts = XRayLabTool.parse_formula("CO")
        @test symbols == ["C", "O"]
        @test counts == [1.0, 1.0]

        symbols, counts = XRayLabTool.parse_formula("Co")
        @test symbols == ["Co"]
        @test counts == [1.0]
    end

    @testset "Fractional stoichiometry" begin
        symbols, counts = XRayLabTool.parse_formula("H0.5He0.5")
        @test symbols == ["H", "He"]
        @test counts == [0.5, 0.5]

        # Test mixed fractional and integer counts
        symbols, counts = XRayLabTool.parse_formula("H2O0.5")
        @test symbols == ["H", "O"]
        @test counts == [2.0, 0.5]

        # Test decimal with no leading integer
        symbols, counts = XRayLabTool.parse_formula("C.25")
        @test symbols == ["C"]
        @test counts == [0.25]
    end

    @testset "Long formulas" begin
        # Test formula with ≥10 elements
        symbols, counts = XRayLabTool.parse_formula("HHeLiBeBCHNOFNeNaMg")
        @test symbols ==
              ["H", "He", "Li", "Be", "B", "C", "H", "N", "O", "F", "Ne", "Na", "Mg"]
        @test counts == [1.0 for _ in 1:13]
        @test length(symbols) >= 10  # Verify it's truly a long formula

        # Test with numeric subscripts on long formula
        symbols, counts = XRayLabTool.parse_formula("H2He3Li4Be5B6C7N8O9F10Ne11")
        @test symbols == ["H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne"]
        @test counts == [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0]
        @test length(symbols) >= 10
    end

    @testset "Complex formulas and validation" begin
        # Test common chemical compounds
        symbols, counts = XRayLabTool.parse_formula("SiO2")
        @test symbols == ["Si", "O"]
        @test counts == [1.0, 2.0]

        symbols, counts = XRayLabTool.parse_formula("Al2O3")
        @test symbols == ["Al", "O"]
        @test counts == [2.0, 3.0]

        symbols, counts = XRayLabTool.parse_formula("CaCO3")
        @test symbols == ["Ca", "C", "O"]
        @test counts == [1.0, 1.0, 3.0]

        # Test formula with large numbers
        symbols, counts = XRayLabTool.parse_formula("C100H200")
        @test symbols == ["C", "H"]
        @test counts == [100.0, 200.0]

        # Test formula with very precise decimals
        symbols, counts = XRayLabTool.parse_formula("H0.123He0.876")
        @test symbols == ["H", "He"]
        @test counts ≈ [0.123, 0.876] atol=1e-10
    end

    @testset "Invalid inputs" begin
        @test_throws ArgumentError XRayLabTool.parse_formula("")
        @test_throws ArgumentError XRayLabTool.parse_formula("123")
        @test_throws ArgumentError XRayLabTool.parse_formula("xyz")

        # Additional invalid inputs
        @test_throws ArgumentError XRayLabTool.parse_formula("abc")
    end
end
