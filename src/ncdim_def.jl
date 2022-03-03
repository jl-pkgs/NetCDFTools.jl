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
ncdim_def(ds, "time",
    CFTime.timeencode.(dates, "days since 1970-01-01", eltype(dates)),
    Dict("units" => "days since 1970-01-01",
        "calendar" => "proleptic_gregorian", "long_name" => "time"))
close(ds)
```
"""
function ncdim_def(ds, name, val, attrib = Dict())
    # x = NcDim(name, val, attrib)
    # val = val |> collect
    if name in keys(ds.dim)
        @warn "Dimension `$name`: exist!"
        return
    end
    defDim(ds, name, length(val))
    defVar(ds, name, val, (name,); attrib = attrib)
end

# NcDim
function ncdim_def(ds, dim::NcDim)
    ncdim_def(ds, dim.name, dim.vals, dim.atts)
end

function ncdim_def(ds, dims::Vector{NcDim})
    for i = 1:length(dims)
        dim = dims[i]
        ncdim_def(ds, dim.name, dim.vals, dim.atts)
    end
end
