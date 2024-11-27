using Test
using PYiCSV

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
