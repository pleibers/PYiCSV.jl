using Test
using PYiCSV
using Dates

# Only run tests if all dependencies are available
if PYiCSV.check_dependencies()
    @testset "iCSV.jl" begin
        @testset "Reading CSV" begin
            file = PYiCSV.read("test.icsv")
            @test file.metadata.field_delimiter == ";"
            @test length(file.data["TA"]) > 0
        end

        @testset "Writing CSV" begin
            written_data = PYiCSV.read("test.icsv")
            written_data.metadata.field_delimiter = ","
            PYiCSV.save("test_output.icsv", written_data)
            read_data = PYiCSV.read("test_output.icsv")
            @test written_data.metadata.field_delimiter == read_data.metadata.field_delimiter
            @test keys(written_data.data) == keys(read_data.data)
            rm("test_output.icsv")
        end

        @testset "Error Handling" begin
            @test_throws ArgumentError PYiCSV.read("non_existent_file.csv")
        end
    end

    @testset "Reading Profile" begin
        file = PYiCSV.read("example_profile.icsv")
        @test file.metadata.field_delimiter == "|"
        @test length(keys(file.data)) == 2
        @test length(file.data[Dates.DateTime("2005-08-23T15:30:00")]) == 4
        @test length(file.data[Dates.DateTime("2005-08-23T16:00:00")]["SSA"]) == 6 
    end

    @testset "Writing Profile" begin
        file = PYiCSV.read("example_profile.icsv")
        file.metadata.field_delimiter = ","
        PYiCSV.save("example_profile_output.icsv", file)
        read_data = PYiCSV.read("example_profile_output.icsv")
        @test file.metadata.field_delimiter == read_data.metadata.field_delimiter
        @test keys(file.data) == keys(read_data.data)
        rm("example_profile_output.icsv")
    end

else
    @warn "Skipping tests due to missing dependencies. Please install required packages first."
end
