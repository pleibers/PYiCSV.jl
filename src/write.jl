"""
    save(filename::String, file::ICSV; overwrite=true) -> Bool

Save an ICSV file to disk at the specified `filename`.

# Arguments
- `filename::String`: Path where the file should be saved
- `file::ICSV`: The ICSV file object to save
- `overwrite::Bool=true`: Whether to overwrite existing file at path

# Returns
- `Bool`: `true` if file was successfully saved, `false` if saving was skipped due to existing file and `overwrite=false`
"""
function save(filename::String, file::ICSV; overwrite=true)
    if isfile(filename)
        if !overwrite
            @warn "File $filename already exists. Not overwriting."
            return false
        end
        @info "File $filename already exists. Overwriting."
    end
    py_file = snowpat.icsv.iCSVFile()
    data = pd.DataFrame(file.data)
    metadata = snowpat.icsv.MetaDataSection()
    metadata_dict = to_dict(file.metadata)
    for key in keys(metadata_dict)
        metadata.set_attribute(key, metadata_dict[key])
    end

    fields = snowpat.icsv.FieldsSection()
    fields_dict = to_dict(file.fields)
    for key in keys(fields_dict)
        fields.set_attribute(key, fields_dict[key])
    end

    py_file.metadata = metadata
    py_file.fields = fields
    py_file.setData(data)

    py_file.write(filename)
    return true
end
