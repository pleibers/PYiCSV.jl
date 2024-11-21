module iCSV

include("init.jl")

include("header.jl")
# Write your package code here.
struct icsv
    metadata::Metadata
    fields::Fields
    data::Dict{String,Any}
end

include("read.jl")
include("write.jl")

export icsv
end
