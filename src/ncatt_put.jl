"""
    ncatt_get(f::NCfiles, key)
    ncatt_put(f::AbstractString, attrib = Dict())
    ncatt_del(f::AbstractString, keys::Vector{<:AbstractString})
    
add or delete global attributes
"""
function ncatt_put(f::NCfiles, atts = Dict())
    nc_open(f, "a") do nc
        names = keys(atts) |> collect
        vals = values(atts) |> collect
        for i = 1:length(atts)
            nc.attrib[names[i]] = vals[i]
        end
    end
    # close(nc)
end


function ncatt_get(f::NCfiles)
    nc_open(f) do nc
        nc.attrib |> collect
    end
end

function ncatt_get(f::NCfiles, keys::Vector)
    nc = nc_open(f)
    res = map(key -> begin
        if haskey(nc.attrib, key) 
            nc.attrib[key] 
        else 
            @warn("`$key` not exits in file '$(basename(f))'")
            nothing
        end
    end, keys)
    nc_close(nc)
    # filter(not_empty, res)
    res
end

function ncatt_get(f::NCfiles, key::AbstractString)
    ncatt_get(f, [key])[1]
end


function ncatt_del(f::NCfiles, keys::Vector{<:AbstractString})
    nc_open(f, "a") do nc
        for i = 1:length(keys)
            delete!(nc.attrib, keys[i])
        end
    end
end

function ncatt_del(f::NCfiles)
    keys = map(x -> x.first, ncatt_get(f))
    ncatt_del(f, keys)
end
