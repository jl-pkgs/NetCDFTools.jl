"""
    nc_write(data::AbstractArray{T}, outfile, dims;
        varname = "HI", type = nothing, compress = 1, overwrite = false

# Examples:
```julia
dims = [
    NcDim("lon", length(lon); values = lon, atts = lonatts)
    NcDim("lat", length(lat); values = lat, atts = latatts)
    NcDim("time", length(time); values = time)
]
nc_write(data, outfile, dims; opt...)
```
"""
function nc_write(data::AbstractArray{T}, outfile, dims;
    varname = "x", type = nothing, compress = 1, overwrite = false) where {T<:Real}

    if type === nothing
        type = T
    end
    var = NcVar(varname, dims; t = type, compress = compress)

    if !isfile(outfile) || overwrite
        if isfile(outfile)
            rm(outfile)
        end
        NetCDF.create(outfile, var) do nc
            NetCDF.putvar(nc, varname, data)
        end
    end
end
