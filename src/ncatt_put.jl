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

function ncatt_get(f::NCfiles, key)
    nc_open(f) do nc
        nc.attrib[key]
    end
end


function ncatt_del(f::NCfiles, keys::Vector{<:AbstractString})
    nc_open(f, "a") do nc
        for i = 1:length(keys)
            delete!(nc.attrib, keys[i])
        end
    end
end
