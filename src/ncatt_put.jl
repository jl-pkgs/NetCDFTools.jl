"""
    ncatt_get(f::NCfiles, key)
    ncatt_put(f::AbstractString, attrib = Dict())
    ncatt_del(f::AbstractString, keys::Vector{<:AbstractString})
    
add or delete global attributes
"""
function ncatt_put(f::NCfiles, atts=Dict())
  nc_open(f, "a") do nc
    ncatt_put(nc, atts)
  end
end

function ncatt_put(nc::NCdata, atts=Dict())
  names = keys(atts) |> collect
  vals = values(atts) |> collect
  for i = 1:length(atts)
    nc.attrib[names[i]] = vals[i]
  end
end

function ncatt_get(nc::NCdata)
  Dict(nc.attrib)
end

function ncatt_get(f::AbstractString)
  nc_open(f) do nc
    ncatt_get(nc)
  end
end

ncatt_get(fs::Vector{<:AbstractString}) = map(ncatt_get, fs)


function ncatt_get(f::AbstractString, keys::Vector)
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
  res
end

function ncatt_get(f::AbstractString, key::AbstractString)
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


precompile(ncatt_put, (NCfiles, Dict))
precompile(ncatt_get, (NCfiles,))
precompile(ncatt_del, (NCfiles,))
