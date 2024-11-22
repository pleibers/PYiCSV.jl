using iCSV

file = iCSV.read("test.icsv")

file.metadata.field_delimiter = ","

iCSV.save(file,"test_out.icsv")

iCSV.to_dict(file.fields)
