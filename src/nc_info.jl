NCdata = Union{NCDataset,NCDatasets.MFDataset}
NCfiles = Union{Vector{<:AbstractString},AbstractString}

# nc_open = NCDataset
"""
    open netcdf file, `nc_open` is alias of `NCDataset`

$(TYPEDSIGNATURES)

# Arguments

- `mode`:

    + "a": append
    + "c": create

# Examples

$(METHODLIST)

@seealso [NCDatasets.NCDataset()]
"""
function nc_open(f::NCfiles, args...; kwargs...)
    NCDataset(path_mnt.(f), args...; kwargs...)
end

function nc_open(f::Function, args...; kwargs...)
    ds = nc_open(args...; kwargs...)
    try
        f(ds)
    finally
        @debug "closing netCDF NCDataset $(ds.ncid) $(NCDatasets.path(ds))"
        close(ds)
    end
end

nc_close(ds::NCdata) = close(ds)


# https://github.com/rafaqz/Rasters.jl/blob/master/src/sources/ncdatasets.jl
function nc_bands(ds::NCdata)
    # v_id = NCDatasets.nc_inq_varids(ds.ncid)
    # vars = NCDatasets.nc_inq_varname.(ds.ncid, v_id)
    vars = keys(ds)
    dims = ["x", "lon", "long", "longitude",
        "y", "lat", "latitude",
        "lev", "level", "mlev", "plev",
        "height",
        "crs",
        "prob", "probs", 
        "bnds",
        # "vertical", 
        # "x", "y", "z",
        "time", "time_bounds"]
    setdiff(vars, [dims; dims .* "_bnds"; "height"])
end

function nc_bands(file::NCfiles)
    nc_open(file) do ds
        nc_bands(ds)
    end
end

get_bandName(file, band::Integer) = nc_bands(file)[band]
get_bandName(file, band::AbstractString) = band


function nc_info(ds::NCdata)
    # vars = nc_bands(ds)[1]
    println(ds)
end

function nc_info(file::NCfiles)
    println(basename(file))
    nc_open(file) do ds
        nc_info(ds)
    end
end

function ncvar_info(file::NCfiles, band = 1)
    println(basename(file))
    # band = nc_bands(file)[1]
    bandName = get_bandName(file, band)
    nc_open(file) do ds
        print(ds[bandName])
    end
end

ncinfo = nc_info


precompile(nc_open, (NCfiles, ))
precompile(nc_info, (NCfiles, ))
precompile(nc_bands, (NCfiles, ))
precompile(nc_close, (NCdata, ))
