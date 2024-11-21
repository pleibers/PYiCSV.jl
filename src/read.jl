
function read(filename::String)::icsv
    if !isfile(filename)
        throw(ArgumentError("File not found: $filename"))
    end
    file = snowpat.icsv.read(filename)

    field_dict = Dict(file.fields.all_fields)
    meta_dict = Dict(file.metadata.metadata)
    fields = Fields(field_dict)
    metadata = Metadata(meta_dict)

    data = convertPandasToJulia(file.data)

    return icsv(metadata, fields, data)
end

function convertPandasToJulia(dataframe::PyObject)
    data = Dict{String,Vector{Any}}()
    for column in dataframe.columns
        data[column] = convert(Array, dataframe[column].to_numpy())
    end
    return data
end
