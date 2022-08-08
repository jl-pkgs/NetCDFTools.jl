"""
    $(TYPEDSIGNATURES)

# Arguments

- `type`: which type to save? Julia variable types.

- `kwargs`: Parameters passed to `ncvar_def`, and further to [`NCDatasets.defVar`]. 
   For examples:

    + fillvalue: A value filled in the NetCDF file to indicate missing data. It
       will be stored in the _FillValue attribute.

    + chunksizes: Vector integers setting the chunk size. The total size of a
       chunk must be less than 4 GiB.

    + shuffle: If true, the shuffle filter is activated which can improve the
       compression ratio.

    + checksum: The checksum method can be :fletcher32 or :nochecksum
       (checksumming is disabled, which is the default)

    + attrib: An iterable of attribute name and attribute value pairs, for
       example a Dict, DataStructures.OrderedDict or simply a vector of pairs
       (see example below)


- `mode`(not used): one of "r", "c", "w", see [NCDatasets.nc_open()] for details

# Examples:
```julia
dims = [
    NcDim("lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
    NcDim("lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
    NcDim("time", 1:ntime)
]
```

$(METHODLIST)

@seealso `ncvar_def`
"""
function nc_write(f::AbstractString, varname::AbstractString, val, dims::Vector{NcDim}, attrib::Dict=Dict();
    compress=1, overwrite=false, mode="c", kw...)
    # check whether variable defined
    if !check_file(f) || overwrite
        if isfile(f)
            rm(f)
        end

        ds = nc_open(f, mode)
        ncdim_def(ds, dims)

        dimnames = names(dims)
        ncvar_def(ds, varname, val, dimnames, attrib; compress=compress, kw...)
        close(ds)
    else
        println("[file exist]: $(basename(f))")
    end
end


function nc_write(val::AbstractArray, f::AbstractString, dims::Vector{NcDim}, attrib=Dict();
    varname="x", kw...)

    printstyled("Deprecated nc_write function! ", color=:red)
    nc_write(f, varname, val, dims, attrib; kw...)
end


"""
$(TYPEDSIGNATURES)

$(METHODLIST)
"""
function nc_write!(f::AbstractString, varname::AbstractString, val, dims::Vector{<:Union{NcDim,AbstractString}}, attrib::Dict=Dict();
    compress=1, kw...)

    mode = check_file(f) ? "a" : "c"
    ds = nc_open(f, mode)
    ncvar_def(ds, varname, val, dims, attrib; compress=compress, kw...)
    close(ds)
end


"""
$(TYPEDSIGNATURES)

$(METHODLIST)
"""
function nc_write!(val::AbstractArray, f::AbstractString, dims::Vector{<:Union{NcDim,AbstractString}}, attrib=Dict();
    varname="x", kw...)

    printstyled("Deprecated nc_write! function! ", color=:red)
    nc_write!(f, varname, val, dims, attrib; kw...)
end
