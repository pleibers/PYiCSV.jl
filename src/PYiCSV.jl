"""
    PYiCSV

A Julia wrapper module for the Python iCSV library (part of snowpat), providing functionality to read and write
iCSV (Interoperable Comma-Separated Values) files.

The module provides a high-level interface to work with iCSV files through three main types:
- `iCSV`: The main structure representing an iCSV file with metadata, fields, and data
- `Metadata`: Contains metadata information for the dataset
- `Fields`: Contains field definitions and properties

# Main Functions
- `read(filename::String)`: Read an iCSV file and return an iCSV object
- `save(filename::String, file::iCSV; overwrite=true)`: Save an iCSV object to a file

# Example
```julia
# Read an existing iCSV file
file = iCSV.read("data.icsv")

# Modify some metadata
file.metadata.field_delimiter = ","

# Save the modified file
iCSV.save("output.icsv", file)
```

Note: This module requires Python with the `snowpat` package
and `pandas` installed. These dependencies are automatically managed through Julia's Conda.jl.

See also: [iCSV Format Specification](https://envidat.gitlab-pages.wsl.ch/icsv/)
"""
module PYiCSV

include("init.jl")

include("header.jl")
# Write your package code here.
struct iCSV
    metadata::Metadata
    fields::Fields
    data::Dict{String,Vector{Any}}
end

include("read.jl")
include("write.jl")

export iCSV, Metadata, Fields
# read, save not exported to avoid naming clashes
end
