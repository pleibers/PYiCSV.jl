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
using Dates

include("init.jl")

include("header.jl")
"""
    iCSV{D<:Dict}

Main container for an iCSV file. Wraps the dataset's `metadata`, `fields`, and `data` in
Julia-native types while interoperating with the Python snowpat/iCSV ecosystem.

# Fields
- `metadata::Metadata`: Global dataset metadata (delimiter, geometry/SRID, station_id, etc.).
- `fields::Fields`: Field definitions and attributes (names, units, long_name, standard_name, …).
- `data::D`: Payload in one of the supported layouts below.

# Accepted `data` layouts
- `Dict{String,Vector}`: Columnar table; keys are field names and values are equal-length vectors.
- `Dict{String,<:Any}`: Single-row table; keys are field names and values are scalars.
- `Dict{Dates.DateTime,Dict{String,Vector}}`: 2D timeseries/profile; outer keys are timestamps and
  each value is a columnar table for that time.

# Construction
    iCSV(metadata::Metadata, fields::Fields, data::D)

Typically obtained via `read(filename::String)`. Persist using `save(filename, file; overwrite=true)`.

# Notes
- Do not mix scalar and vector values in the same flat `Dict` layout.
- The parametric type `D` captures the concrete dictionary shape for performance and clarity.
"""
struct iCSV{D <: Dict}
    metadata::Metadata
    fields::Fields
    data::D
end

include("read.jl")
include("write.jl")

export iCSV, Metadata, Fields
# read, save not exported to avoid naming clashes
end
