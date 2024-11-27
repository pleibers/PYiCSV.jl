using PYiCSV

file = PYiCSV.read("test.icsv")

file.metadata.field_delimiter = ","

PYiCSV.save(file,"test_out.icsv")

PYiCSV.to_dict(file.fields)
