using PYiCSV
using Dates
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
