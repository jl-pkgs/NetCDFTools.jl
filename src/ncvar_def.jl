"""
    ncvar_def(ds, name, val, dims::Vector{<:AbstractString}, attrib = Dict();
        compress = 1, kw...)
    ncvar_def(ds, name, val, dims::NcDim, attrib = Dict();
        compress = 1, kw...)

# Arguments

- `val`: can be `data` or vtype

- `compress`: Compression level: 0 (default) means no compression and 9 means
    maximum compression. Each chunk will be compressed individually.

- `type`: which type to save? Julia variable types (not string), e.g.,
  `Float32`.

- `options`: Dictionary object, 

  + `fillvalue`: A value filled in the NetCDF file to indicate missing data. It
    will be stored in the _FillValue attribute.

  + `chunksizes`: Vector integers setting the chunk size. The total size of a
    chunk must be less than 4 GiB. 

  + `shuffle`: If true, the shuffle filter is activated which can improve the
    compression ratio.

  + `checksum`: The checksum method can be :fletcher32 or :nochecksum
    (checksumming is disabled, which is the default)

  + `attrib`: An iterable of attribute name and attribute value pairs, for
    example a Dict, DataStructures.OrderedDict or simply a vector of pairs (see
    example below)
    
# Examples

```julia
f = "f1.nc"
isfile(f) && rm(f)
ds = nc_open(f, "c")
compress = 1

ncdim_def(ds, "lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
ncdim_def(ds, "lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
ncdim_def(ds, "time", 1:ntime)

ncvar_def(ds, "HI", dat, ["lon", "lat", "time"], Dict("longname" => "hello"); compress = compress)
close(ds)

# append a variable
ds = nc_open(f, "a")
ncvar_def(ds, "HI2", dat, ["lon", "lat", "time"]; compress = compress)
print(ds)
close(ds)

nc_info(f)
```

@seealso [`ncdim_def`](@ref)
"""
function ncvar_def(ds, name, val, dims::Vector{D}, attrib=Dict();
  compress=1, type=nothing, overwrite=false, kw...) where {S<:AbstractString,D<:Union{NcDim,S}}

  # change datatype
  if type !== nothing && eltype(val) != type
    val = @.(type(val))
  end

  # attrib["deflatelevel"] = compress
  if name in keys(ds)
    if !overwrite
      @warn "Variable `$name`: exist! Data not written. Use `overwrite=true` to overwrite. "
      return
    else
      # @warn "Variable `$name`: exist! Overwrited."
      _var = ds[name]
      indices = ntuple(i -> :, ndims(_var))
      _var[indices...] = val
      return
    end
  end

  # 若只有string name，则无法定义dims，无奈之举
  dimnames = dims
  if D == NcDim
    ncdim_def(ds, dims) # define dimensions if previous not exist
    dimnames = map(x -> x.name, dims)
  end
  defVar(ds, name, val, dimnames; attrib, deflatelevel=compress, kw...)
end
