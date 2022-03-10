import StatsBase: mode

mutable struct NcDim
    name::String
    dimlen::Int
    vals::Union{AbstractArray, Nothing}
    atts::Dict
end

"""
    NcDim(name::AbstractString, vals::AbstractArray, atts::Dict = Dict())
    
Represents a NetCDF dimension of name `name` optionally holding the dimension values.
"""
NcDim(name::AbstractString, vals::AbstractArray, atts::Dict = Dict()) =
    NcDim(name, length(vals), vals, atts)

function Ipaper.names(dims::Vector{NcDim})
    map(x -> x.name, dims)
end

function Base.getindex(dims::Vector{NcDim}, name::AbstractString)
    names = Ipaper.names(dims)
    ind = indexin([name], names)
    dims[ind]
end

# function Base.getindex(dims::Vector{NcDim}, name::Vector{AbstractString})
#     names = Ipaper.names(dims)
#     ind = indexin(name, names)
#     print(ind)
#     dims[ind]
# end
# Base.getindex(dims::Vector{NcDim}, name::AbstractString) = Base.getindex(dims, [name])
function nc_dim(ds::NCDataset, name = "time")
    if haskey(ds, name)
        x = ds[name]
        NcDim(name, x.var[:], Dict(x.attrib))
    else
        n = ds.dim[name]
        vals = 1:n
        NcDim(name, n, vals, Dict())
        # NcDim(name, n, nothing, Dict()) # TODO
    end
end

function nc_dim(file::String, name = "time")
    NCDataset(file) do ds
        nc_dim(ds, name)
    end
end

function nc_dims(ds::NCDataset)
    items = keys(ds.dim) #|> reverse    
    map(x -> nc_dim(ds, x), items)
end

function nc_dims(file::String)
    NCDataset(file) do ds
        nc_dims(ds)
    end
end

function nc_dimsize(file::String)
    NCDataset(file) do ds
        var = nc_bands(ds)[1]
        size(ds[var])
    end
end

"""
    nc_cellsize(ds::NCDataset)
"""
function nc_cellsize(ds::NCDataset)
    diflon = nc_dim(ds, "lon").vals |> diff
    diflat = nc_dim(ds, "lat").vals |> diff

    cell_x = mode(diflon)
    cell_y = mode(diflat)
    # regular or complex grid
    regular = length(unique(diflon)) == 1 && length(unique(diflat)) == 1
    cell_x, cell_y, regular
end

function nc_cellsize(file::String)
    NCDataset(file) do ds
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
