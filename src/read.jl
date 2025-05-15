"""
    read(filename::String)::iCSV

Read an ICSV file from the given filename and return an iCSV object.

# Arguments
- `filename::String`: Path to the iCSV file to read

# Returns
- `iCSV`: An iCSV object containing the file's metadata, fields, and data

# Throws
- `ArgumentError`: If the specified file does not exist
"""
function read(filename::String)::iCSV
    if !isfile(filename)
        throw(ArgumentError("File not found: $filename"))
    end
    file = snowpat.icsv.read(filename)

    field_dict = Dict(file.fields.all_fields)
    meta_dict = Dict(file.metadata.metadata)
    fields = Fields(field_dict)
    metadata = Metadata(meta_dict)
    if pyisinstance(file, snowpat.icsv.iCSVSnowprofile)
        data = convertSnowProfileToJulia(file)
    else
        data = convertPandasToJulia(file.data)
    end
    return iCSV(metadata, fields, data)
end

function convertSnowProfileToJulia(file::PyObject)
    out = Dict{Dates.DateTime,Dict{String, Vector{Any}}}()
    for date in file.dates
        out[date] = convertPandasToJulia(file.data[date])
    end
    return out
end

function convertPandasToJulia(dataframe::PyObject)::Dict{String,Vector{Any}}
    data = Dict{String,Vector{Any}}()
    for column in dataframe.columns
        data[column] = convert(Array, dataframe[column].to_numpy())
    end
    return data
end
