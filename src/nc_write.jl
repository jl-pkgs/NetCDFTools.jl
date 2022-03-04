"""
    nc_write(data::AbstractArray{T}, f::AbstractString, dims::Vector{NcDim}, attrib = Dict();
        varname = "x", compress = 1, kwargs..., overwrite = false, mode = "c") where {T<:Real}
    nc_write!(data::AbstractArray{T}, f::AbstractString, dims::Vector{NcDim}, attrib = Dict();
        varname = "x", compress = 1, kwargs...) where {T<:Real}
    nc_write!(data::AbstractArray{T}, f::AbstractString, dims::Vector{<:AbstractString}, attrib = Dict();
        varname = "x", compress = 1, kwargs...) where {T<:Real}

# Arguments
- `kwargs`: Parameters passed to [ncvar_def]
- `mode`(not used): one of "r", "c", "w", see [NCDatasets.nc_open()] for details

# Examples:
```julia
dims = [
    NcDim("lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
    NcDim("lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
    NcDim("time", 1:ntime)
]
nc_write(data, f, dims; varname = "x", opt...)

seealso ncvar_def
```
"""
function nc_write(data::AbstractArray{T}, f::AbstractString, dims::Vector{NcDim}, attrib = Dict();
    varname = "x", compress = 1, overwrite = false, mode = "c", kwargs...) where {T<:Real}

    # check whether variable defined
    if !check_file(f) || overwrite
        if isfile(f)
            rm(f)
        end

        ds = nc_open(f, mode)
        ncdim_def(ds, dims)
    
        dimnames = names(dims)
        ncvar_def(ds, varname, data, dimnames, attrib; compress = compress, kwargs...)
        close(ds)
    else
        println("[file exist]: $(basename(f))")
    end
end

function nc_write!(data, f::AbstractString, dims::Vector{NcDim}, attrib = Dict();
    varname = "x", compress = 1, kwargs...) where {T<:Real}

    mode = check_file(f) ? "a" : "c";
    ds = nc_open(f, mode)
    ncvar_def(ds, varname, data, dims, attrib; compress = compress, kwargs...)
    close(ds)
end

function nc_write!(data, f::AbstractString, dims::Vector{<:AbstractString}, attrib = Dict();
    varname = "x", compress = 1, kwargs...) where {T<:Real}

    mode = check_file(f) ? "a" : "c";
    ds = nc_open(f, mode)
    ncvar_def(ds, varname, data, dims, attrib; compress = compress, kwargs...)
    close(ds)
end
