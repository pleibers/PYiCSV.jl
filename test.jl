using PYiCSV
using Dates
file = PYiCSV.read("test/test.icsv")

file.metadata.field_delimiter = ","

PYiCSV.save("test_out.icsv", file)

PYiCSV.to_dict(file.fields)

profile = PYiCSV.read("test/example_profile.icsv")

profile.metadata.field_delimiter = ","

PYiCSV.save("test_out_profile.icsv", profile)
