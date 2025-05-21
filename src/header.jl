const SRID = "EPSG:4326"

struct Location
    x::Float64
    y::Float64
    z::Union{Float64,Nothing}
end

location(latitude::Float64, longitude::Float64, elevation=nothing) = Location(longitude, latitude, elevation)

"""
    Metadata

A mutable structure containing metadata information for a timeseries dataset.

# Fields
- `field_delimiter::String`: Character used to separate fields in the data
- `geometry::String`: WKT representation of the location
- `srid::String`: Spatial reference system identifier
- `station_id::Union{String,Nothing}`: Optional identifier for the measurement station
- `nodata::Union{Union{String,Real},Nothing}`: Value used to represent missing data
- `timezone::Union{Union{String,Real},Nothing}`: Timezone information for timestamps
- `doi::Union{String,Nothing}`: Digital Object Identifier for the dataset
- `timestamp_meaning::Union{String,Nothing}`: Interpretation of timestamp values
- `additional_metadata::Dict{String,Union{String,Real}}`: Additional key-value metadata pairs

# Constructors
    Metadata(field_delimiter::String, location::Location; kwargs...)
    Metadata(dict::Dict)

Create a Metadata instance either from a field delimiter and Location object with optional
keyword arguments, or from a dictionary containing metadata fields. Required fields when
constructing from a dictionary are "field_delimiter", "geometry", and "srid".
"""
mutable struct Metadata
    field_delimiter::String
    geometry::String
    srid::String  # Assuming SRID is an Integer
    station_id::Union{String,Nothing}
    nodata::Union{Union{String,Real},Nothing}
    timezone::Union{Union{String,Real},Nothing}
    doi::Union{String,Nothing}
    timestamp_meaning::Union{String,Nothing}
    additional_metadata::Dict{String,String}
end

function Metadata(field_delimiter::String, location::Location;
                  station_id=nothing, nodata=nothing,
                  timezone=nothing, doi=nothing, timestamp_meaning=nothing,
                  additional_metadata::Dict{String,Any}=Dict{String,Any}())
    geometry = createGeometryString(location)

    return Metadata(field_delimiter,
                    geometry,
                    SRID,
                    station_id,
                    nodata,
                    timezone,
                    doi,
                    timestamp_meaning,
                    additional_metadata)
end

function Metadata(dict::Dict)
    # Define required keys
    required_keys = ["field_delimiter", "geometry", "srid"]

    # Check if all required keys are present
    missing_keys = filter(k -> !haskey(dict, k), required_keys)
    if !isempty(missing_keys)
        throw(ArgumentError("Missing required keys: $(join(missing_keys, ", "))"))
    end

    field_delimiter = dict["field_delimiter"]
    geometry = dict["geometry"]
    srid = dict["srid"]

    # Optional parameters with default values
    station_id = get(dict, "station_id", nothing)
    nodata = get(dict, "nodata", nothing)
    timezone = get(dict, "timezone", nothing)
    doi = get(dict, "doi", nothing)
    timestamp_meaning = get(dict, "timestamp_meaning", nothing)

    # Get additional metadata (any key not used for main parameters)
    known_keys = ["field_delimiter", "geometry", "srid",
                  "station_id", "nodata", "timezone", "doi",
                  "timestamp_meaning"]
    additional_metadata = Dict{String,String}(k => v for (k, v) in dict if k ∉ known_keys)

    return Metadata(field_delimiter,
                    geometry,
                    srid,
                    station_id,
                    nodata,
                    timezone,
                    doi,
                    timestamp_meaning,
                    additional_metadata)
end

function to_dict(metadata::Metadata)
    # Create initial empty dictionary
    dict = Dict{String,String}()

    # Iterate through all field names except additional_metadata
    for field in fieldnames(Metadata)[1:(end - 1)]  # Exclude additional_metadata
        value = getfield(metadata, field)
        if value !== nothing
            dict[String(field)] = value
        end
    end

    # Merge with additional metadata
    merge!(dict, metadata.additional_metadata)

    return dict
end

function createGeometryString(loc::Location)
    if loc.z === nothing
        geometry = "POINT($(loc.x) $(loc.y))"
    else
        geometry = "POINT($(loc.x) $(loc.y) $(loc.z))"
    end
    return geometry
end

const OptionalFields = Union{Nothing,Vector{String}}

"""
    Fields

A mutable structure containing field information for a timeseries dataset.

# Fields
- `fields::Vector{String}`: Names of the data fields
- `units_multiplier::OptionalFields`: Optional multipliers for unit conversions
- `units::OptionalFields`: Optional units for each field
- `long_name::OptionalFields`: Optional descriptive names for each field
- `standard_name::OptionalFields`: Optional standardized names for each field
- `additional_fields::Dict{String,Any}`: Additional field-related metadata

# Constructors
    Fields(fields::Vector{String}; kwargs...)
    Fields(dict::Dict)

Create a Fields instance either from a vector of field names with optional keyword arguments,
or from a dictionary containing field information. The only required field when constructing
from a dictionary is "fields" containing the vector of field names.
"""
mutable struct Fields
    fields::Vector{String}
    units_multiplier::OptionalFields
    units::OptionalFields
    long_name::OptionalFields
    standard_name::OptionalFields
    additional_fields::Dict{String,Vector{String}}
end

function Fields(fields::Vector{String};
                units_multiplier::OptionalFields=nothing,
                units::OptionalFields=nothing,
                long_name::OptionalFields=nothing,
                standard_name::OptionalFields=nothing,
                additional_fields::Dict{String,Vector{String}}=Dict{String,Vector{String}}())
    return Fields(fields,
                  units_multiplier,
                  units,
                  long_name,
                  standard_name,
                  additional_fields)
end

function Fields(dict::Dict)
    # Check if required "field" key is present
    if !haskey(dict, "fields")
        throw(ArgumentError("Missing required key: field"))
    end

    # Get the required field vector
    fields = dict["fields"]

    # Handle optional parameters with default values
    units_multiplier = get(dict, "units_multiplier", nothing)
    units = get(dict, "units", nothing)
    long_name = get(dict, "long_name", nothing)
    standard_name = get(dict, "standard_name", nothing)

    # Get additional fields (any key not used for main parameters)
    known_keys = ["field", "units_multiplier", "units",
                  "long_name", "standard_name"]
    additional_fields = Dict{String,Vector{String}}(k => v for (k, v) in dict if k ∉ known_keys)

    return Fields(fields,
                  units_multiplier,
                  units,
                  long_name,
                  standard_name,
                  additional_fields)
end

function to_dict(fields::Fields)
    # Create initial empty dictionary
    dict = Dict{String,Vector{String}}()

    # Iterate through all field names except additional_metadata
    for field in fieldnames(Fields)[1:(end - 1)]  # Exclude additional_metadata
        value = getfield(fields, field)
        if value !== nothing
            dict[String(field)] = value
        end
    end

    # Merge with additional metadata
    merge!(dict, fields.additional_fields)

    return dict
end
