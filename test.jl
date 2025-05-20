using PYiCSV
using Dates
using PyCall

file = PYiCSV.read("test/test.icsv")

file.metadata.field_delimiter = ","

PYiCSV.save("test_out.icsv", file)

PYiCSV.to_dict(file.fields)

profile = PYiCSV.read("test/example_profile.icsv")

profile.metadata.field_delimiter = ","

PYiCSV.save("test_out_profile.icsv", profile)

data = zeros(5, 4)
date = Dates.DateTime("2025-05-15T16:00:00")

file_new = iCSV(profile.metadata, profile.fields, Dict(date => data))

PYiCSV.save("test_out_profile_new.icsv", file_new)

PYiCSV.append_to_profile("test_out_profile_new.icsv", date, data,".")

test_data = Dict{String, Any}("timestamp" => "2020-01-01T00:01:40", "Tsurf" => 238.7889718008598)

PYiCSV.pd.DataFrame(test_data, index=[0])