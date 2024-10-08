export NcDims, NcDim_time, ncdim_def
import Dates: Date, DateTime
import CFTime: AbstractCFDateTime

const DateTimeType = Union{DateTime,AbstractCFDateTime}

function NcDim_time(dates::Vector{<:DateTimeType})
  vals = CFTime.timeencode.(dates, "days since 1970-01-01", eltype(dates))
  attrib = Dict(
    "units" => "days since 1970-01-01",
    "calendar" => "proleptic_gregorian",
    "long_name" => "time")
  NcDim("time", length(vals), vals, attrib)
end

NcDim_time(dates::Vector{Date}) = NcDim_time(DateTime.(dates))

function NcDims(lon::AbstractVector, lat::AbstractVector, dates::AbstractVector)
  [
    NcDim("lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
    NcDim("lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
    NcDim_time(dates)
  ]
end

function NcDims(b::bbox, cellsize, dates; reverse_lat=true)
  lon, lat = bbox2dims(b; cellsize, reverse_lat)
  NcDims(lon, lat, dates)
end

NcDims(ra::SpatRaster) = NcDims(ra.lon, ra.lat, ra.time)

"""
    ncdim_def(ds, name, val, attrib = Dict())
    ncdim_def(ds, dim::NcDim)
    ncdim_def(ds, dims::Vector{NcDim})
    
# Examples
```julia
## 1. by existing nc file
# f = "/mnt/j/Researches/Obs/Obs_ChinaHW_cluster/ncell_16/clusterId_HItasmax_movTRS_Obs.nc"
dims = nc_dims(f)
ds = nc_open("f2.nc", "c")
ncdim_def(ds, dims);
println(ds)
close(ds)

## 2. by assigned variables
# dates = nc_date(ds)
ds = nc_open("f3.nc", "c")
dim_t = NcDim_time(dates)
ncdim_def(ds, dim_t)
close(ds)
```
"""
function ncdim_def(ds, name, val, attrib=Dict(); verbose=false)
  # x = NcDim(name, val, attrib)
  # val = val |> collect
  if name in keys(ds.dim)
    verbose && @warn "Dimension `$name`: exist!"
    return
  end
  defDim(ds, name, length(val))
  defVar(ds, name, val, (name,); attrib=attrib)
end

# NcDim
function ncdim_def(ds, dim::NcDim; kw...)
  ncdim_def(ds, dim.name, dim.vals, dim.atts; kw...)
end

function ncdim_def(ds, dims::Vector{NcDim}; kw...)
  for i = 1:length(dims)
    dim = dims[i]
    ncdim_def(ds, dim.name, dim.vals, dim.atts; kw...)
  end
end
