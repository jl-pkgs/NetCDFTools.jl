import NCDatasets: CFVariable

# MFDataset(;fs, nc, bands, ...)
"""
    MFDataset(fs) = MFDataset(; fs)
    MFDataset(fs, chunksize) = MFDataset(; fs, chunksize)

# Examples
```julia
m = MFDataset(fs)
v = m["LAI"]
data = v[i, j]
```
"""
@with_kw_noshow mutable struct MFDataset
  fs::Vector{String}
  nc::Vector{NCDataset{Nothing}} = nc_open.(fs)
  bands = nc_bands(nc[1])

  bbox::bbox = st_bbox(fs[1])
  sizes = map(nc -> size(nc[bands[1]]), nc) # variable dimension size
  ntime = sum(map(last, sizes)) # 时间在最后一维

  # chunksize = [240, 240] * 10
  chunksize = ntuple(x -> typemax(Int), length(sizes[1])) # 默认不设chunks
  chunks = GridChunks(sizes[1], chunksize)
end
MFDataset(fs) = MFDataset(; fs)
MFDataset(fs, chunksize) = MFDataset(; fs, chunksize)

nc_close(m::MFDataset) = nc_close.(m.nc)


mutable struct MFVariable{T,N}
  vars::Vector{CFVariable{T,N}}
end


function Base.getindex(m::MFDataset, key::Union{String,Symbol})
  vars = map(nc -> nc[key], m.nc)
  var = vars[1]
  MFVariable{eltype(var),ndims(var)}(vars)
end

Base.getindex(v::MFVariable, i) = v.vars[i]


# dims = 3
function Base.getindex(v::MFVariable{T,3}, i, j; progress::Bool=true) where {T}
  ntime = map(x -> size(x, 3), v.vars) |> sum
  nlon, nlat = size(v.vars[1])[1:2]
  i != Colon() && (nlon = length(i))
  j != Colon() && (nlat = length(j))
  nlon == 1 && (i = [i])
  nlat == 1 && (j = [j])

  res = zeros(T, nlon, nlat, ntime)
  i_beg = 0
  p = Progress(length(v.vars))
  
  @inbounds for var in v.vars
    progress && next!(p)

    _ntime = size(var, 3)
    inds = (i_beg+1):(i_beg+_ntime)
    res[:, :, inds] .= var[i, j, :]
    i_beg += _ntime
  end
  res
  # res = map(var -> var[i, j, :], v.vars)
  # cat(res...; dims)
end


function Base.getindex(v::MFVariable{T,2}, i, j) where {T}
  ntime = length(v.vars)
  nlon, nlat = size(v.vars[1])[1:2]
  i != Colon() && (nlon = length(i))
  j != Colon() && (nlat = length(j))
  nlon == 1 && (i = [i])
  nlat == 1 && (j = [j])

  res = zeros(T, nlon, nlat, ntime)
  k = 0
  @inbounds for var in v.vars
    k += 1
    res[:, :, k] .= var[i, j]
  end
  res
end

function get_chunk(m::MFDataset, k; InVars=m.bands)
  ii, jj, _ = m.chunks[k]
  map(band -> m[band][ii, jj], InVars)
end

function Base.show(io::IO, m::MFDataset)
  printstyled("MFDataset \n", color=:blue, bold=true, underline=true)
  println(io, "bands      : $(m.bands)")
  println(io, "nc         : $(eltype(m.nc)), size=", size(m.nc))
  println(io, "bbox       : $(m.bbox)")
  println(io, "chunksize  : $(m.chunksize)")
  println(io, "chunks     : size=", size(m.chunks)) # eltype(m.chunks), 
  println(io, "ntime      : $(m.ntime)")

  printstyled("File and size: \n", color=:blue, underline=true)
  for i in eachindex(m.fs)
    f = basename(m.fs[i])
    size = m.sizes[i]
    println(io, f => size)
  end
end
