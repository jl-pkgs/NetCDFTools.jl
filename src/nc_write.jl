"""
    $(TYPEDSIGNATURES)

# Arguments

- `mode`: one of "r", "c", "w", see [NCDatasets.nc_open()] for details
  + "a": append
  + "c": create

- `units`: units of the variable

- `longname`: longname of the variable

- attrib: An iterable of attribute name and attribute value pairs, for example a
  Dict, DataStructures.OrderedDict or simply a vector of pairs (see example
  below)
  
- `type`: which type to save? Julia variable types.

- `kwargs`: Parameters passed to `ncvar_def`, and further to
  [`NCDatasets.defVar`]. For examples:

  + fillvalue: A value filled in the NetCDF file to indicate missing data. It
    will be stored in the _FillValue attribute.

  + chunksizes: Vector integers setting the chunk size. The total size of a
    chunk must be less than 4 GiB. Such as `(10, 10, 1)`

  + shuffle: If true, the shuffle filter is activated which can improve the
    compression ratio.

  + checksum: The checksum method can be :fletcher32 or :nochecksum
    (checksumming is disabled, which is the default)

# Examples
```julia
dims = [
    NcDim("lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
    NcDim("lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
    NcDim_time(dates)
]

b = bbox(70, 15, 140, 55)
cellsize=1
dates = Date(2010):Day(1):Date(2010, 1, 4) |> collect
dims = NcDims(b, cellsize, dates) # one option

nc_write(f, varname, val, dims; units, longname)
```

$(METHODLIST)

@seealso `ncvar_def`
"""
function nc_write(f::AbstractString, varname::AbstractString, val,
  dims::Vector{NcDim}, attrib::Dict=Dict();
  overwrite=false, mode="c", kw...)

  if !check_file(f) || overwrite
    isfile(f) && rm(f)
    nc_write!(f, varname, val, dims, attrib; mode, kw...)
  else
    println("[file exist]: $(basename(f))")
  end
end


"""
$(TYPEDSIGNATURES)

$(METHODLIST)
"""
function nc_write!(f::AbstractString, varname::AbstractString, val,
  dims::Vector{<:Union{NcDim,AbstractString}}, attrib::Dict=Dict();
  units=nothing, longname=nothing,
  compress=1, global_attrib=Dict(), mode=nothing, kw...)

  !isnothing(units) && (attrib["units"] = units)
  !isnothing(longname) && (attrib["longname"] = longname)
  isnothing(mode) && (mode = check_file(f) ? "a" : "c")

  ds = nc_open(f, mode)
  ncatt_put(ds, global_attrib)
  ncdim_def(ds, dims; verbose=false)

  ncvar_def(ds, varname, val, dims, attrib; compress, kw...)
  close(ds)
end

function nc_write!(f::AbstractString, data::NamedTuple,
  dims::Vector{<:Union{NcDim,AbstractString}}, attrib::Dict=Dict();
  verbose=false, kw...)
  for (varname, val) in pairs(data)
    verbose && println(varname)
    nc_write!(f, string(varname), val, dims, attrib; kw...)
  end
end

function nc_write!(f::AbstractString, ra::SpatRaster, attrib::Dict=Dict(); kw...)
  _dims = NcDims(ra)
  nc_write!(f, ra.name, ra.A, _dims, attrib; kw...)
end
