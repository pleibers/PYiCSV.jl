module iCSV

include("init.jl")

include("header.jl")
# Write your package code here.
struct ICSV
    metadata::Metadata
    fields::Fields
    data::Dict{String,Vector{Any}}
end

include("read.jl")
include("write.jl")

export ICSV
end
