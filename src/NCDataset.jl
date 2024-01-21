const NCdata = Union{NCDataset,NCDatasets.MFDataset}

const NCfiles = Union{Vector{<:AbstractString},AbstractString}


Base.haskey(ds::NCDataset, pattern::Regex) =
  !isempty(grep(keys(ds), pattern))

function Base.getindex(ds::NCDataset, pattern::Regex)
  _keys = keys(ds)
  _id = grep(_keys, pattern)[1]
  _name = _keys[_id]
  ds[_name]
end
