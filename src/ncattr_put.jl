"""
    ncattr_get(f::NCfiles, key)
    ncattr_put(f::AbstractString, attrib = Dict())
    ncattr_del(f::AbstractString, keys::Vector{<:AbstractString})
    
add or delete global attributes
"""
function ncattr_put(f::NCfiles, attr=Dict())
  nc_open(f, "a") do nc
    ncattr_put(nc, attr)
  end
end

function ncattr_put(nc::NCdata, attr=Dict())
  names = keys(attr) |> collect
  vals = values(attr) |> collect
  for i = 1:length(attr)
    nc.attrib[names[i]] = vals[i]
  end
end



function ncattr_get(nc::NCdata)
  Dict(nc.attrib)
end

function ncattr_get(f::AbstractString)
  nc_open(f) do nc
    ncattr_get(nc)
  end
end

ncattr_get(fs::Vector{<:AbstractString}) = map(ncattr_get, fs)


function ncattr_get(f::AbstractString, keys::Vector)
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

function ncattr_get(f::AbstractString, key::AbstractString)
  ncattr_get(f, [key])[1]
end


function ncattr_del(f::NCfiles, keys::Vector{<:AbstractString})
  nc_open(f, "a") do nc
    for i = 1:length(keys)
      delete!(nc.attrib, keys[i])
    end
  end
end

function ncattr_del(f::NCfiles)
  keys = map(x -> x.first, ncattr_get(f))
  ncattr_del(f, keys)
end


precompile(ncattr_put, (NCfiles, Dict))
precompile(ncattr_get, (NCfiles,))
precompile(ncattr_del, (NCfiles,))
