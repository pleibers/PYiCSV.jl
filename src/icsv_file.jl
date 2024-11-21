const SRID = "EPSG:4326"

struct iCSVFile
    metadata::Dict{String,Any}
    fields::Dict{String,Vector{String}}
    data::Dict{String,Vector{Any}}
end

struct Location
    x::Float64
    y::Float64
    z::Float64
end

function createMetadata(field_delimiter::String, location::Location; station_id=nothing, nodata=nothing,
                        timezone=nothing, doi=nothing, timestamp_meaning=nothing,
                        additional_metadata::Dict{String,Any})

    # Create base metadata dictionary from arguments
    metadata = Dict{String,Any}("field_delimiter" => field_delimiter,
                                "geometry" => createGeometry(location),
                                "srid" => SRID,
                                "station_id" => station_id,
                                "nodata" => nodata,
                                "timezone" => timezone,
                                "doi" => doi,
                                "timestamp_meaning" => timestamp_meaning)

    # Filter out nothing values
    metadata = Dict(k => v for (k, v) in metadata if v !== nothing)

    # Merge with additional metadata
    merge!(metadata, additional_metadata)

    return metadata
end

function createGeometry(loc::Location)
end
