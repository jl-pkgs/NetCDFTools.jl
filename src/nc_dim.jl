import StatsBase: mode

mutable struct NcDim
  name::String
  dimlen::Int
  vals::Union{AbstractArray,Nothing}
  atts::Dict
end

"""
    NcDim(name::AbstractString, vals::AbstractArray, atts::Dict = Dict())
    
Represents a NetCDF dimension of name `name` optionally holding the dimension values.
"""
NcDim(name::AbstractString, vals::AbstractArray, atts::Dict=Dict()) =
  NcDim(name, length(vals), vals, atts)

function Ipaper.names(dims::Vector{NcDim})
  map(x -> x.name, dims)
end


function find_dim(dims::Vector{NcDim}, name::AbstractString)
  names = Ipaper.names(dims)
  ind = indexin([name], names)[1]
  ind
end

function find_dim(dims::Vector{NcDim}, pattern::Regex)
  names = Ipaper.names(dims)
  ind = grep(names, pattern)[1]
  ind
end

"""
    $(TYPEDSIGNATURES)
# Examples
```julia
f = "test/data/temp_HI.nc"
dims = nc_dims(f)
dims[["lon", "lat"]]
```
"""
function Base.getindex(dims::Vector{NcDim}, name::Union{AbstractString,Regex})
  ind = find_dim(dims, name)
  dims[ind]
end

function Base.getindex(dims::Vector{NcDim}, name::Vector{<:AbstractString})
  names = Ipaper.names(dims)
  ind = indexin(name, names)
  dims[ind]
end

function Base.getindex(dim::NcDim, inds)
  vals = dim.vals[inds]
  NcDim(dim.name, length(vals), vals, dim.atts)
end

function Base.getindex(ds::NCDataset, pattern::Regex)
  _keys = keys(ds)
  _id = grep(_keys, pattern)[1]
  _name = _keys[_id]
  ds[_name]
end


function Base.setindex!(dims::Vector{NcDim}, v::NcDim, name::Union{AbstractString,Regex})
  ind = find_dim(dims, name)
  dims[ind] = v
end


# Base.getindex(dims::Vector{NcDim}, name::AbstractString) = Base.getindex(dims, [name])
# TODO: fix Regex
function get_nc_dim(ds::NCdata, name::Union{AbstractString,Regex})
  n = ds.dim[name]
  vals = 1:n
  NcDim(name, n, vals, Dict())
  # NcDim(name, n, nothing, Dict()) # TODO
end

function nc_dim(ds::NCdata, name::Union{AbstractString,Regex})
  if haskey(ds, name)
    try
      x = ds[name]
      NcDim(name, x.var[:], Dict(x.attrib))
    catch
      get_nc_dim(ds, name)
    end
  else
    get_nc_dim(ds, name)
  end
end

function nc_dim(file::NCfiles, name::Union{AbstractString,Regex})
  nc_open(file) do ds
    nc_dim(ds, name)
  end
end

function nc_dims(ds::NCdata)
  items = keys(ds.dim) #|> reverse    
  map(x -> nc_dim(ds, x), items)
end

function nc_dims(file::NCfiles)
  nc_open(file) do ds
    nc_dims(ds)
  end
end

function nc_dimsize(file::NCfiles)
  nc_open(file) do ds
    var = nc_bands(ds)[1]
    size(ds[var])
  end
end

"""
    nc_cellsize(ds::NCdata)
"""
function nc_cellsize(ds::NCdata)
  diflon = nc_dim(ds, r"lon").vals |> diff
  diflat = nc_dim(ds, r"lat").vals |> diff

  cell_x = mode(diflon)
  cell_y = mode(diflat)
  # regular or complex grid
  regular = length(unique(diflon)) == 1 && length(unique(diflat)) == 1
  cell_x, cell_y, regular
end

function nc_cellsize(file::AbstractString)
  nc_open(file) do ds
    nc_cellsize(ds)
  end
end

function nc_cellsize(files::Vector{<:AbstractString})
  n = length(files)
  cell_x = zeros(n)
  cell_y = zeros(n)
  regular = zeros(Bool, n)
  for i = 1:n
    cell_x[i], cell_y[i], regular[i] = nc_cellsize(files[i])
  end
  cell_x, cell_y, regular
end

function ncvar_dim(ds::NCDataset, varname::Union{String,Nothing}=nothing; varid=1)
  if varname === nothing
    varname = nc_bands(ds)[varid]
  end

  ids = ds[varname].var.dimids
  ids = collect(ids) .+ 1
  dims = nc_dims(ds)
  dims[ids]
end

function ncvar_dim(file::NCfiles, varname::Union{String,Nothing}=nothing; kwargs...)
  nc_open(file) do ds
    ncvar_dim(ds, varname; kwargs...)
  end
end

# NCdata = Union{NCDataset,NCDatasets.MFDataset}
# get_dimids()
