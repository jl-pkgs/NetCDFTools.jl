"""
    nc_attr(f::NCfiles, key)
    nc_attr!(f::AbstractString, attrib = Dict())
    nc_attr_rm!(f::AbstractString, keys::Vector{<:AbstractString})
    
add or delete global attributes
"""
function nc_attr!(f::NCfiles, attr=Dict())
  nc_open(f, "a") do nc
    nc_attr!(nc, attr)
  end
end

function nc_attr!(nc::NCdata, attr=Dict())
  names = keys(attr) |> collect
  vals = values(attr) |> collect
  for i = 1:length(attr)
    nc.attrib[names[i]] = vals[i]
  end
end



function nc_attr(nc::NCdata)
  Dict(nc.attrib)
end

function nc_attr(f::AbstractString)
  nc_open(f) do nc
    nc_attr(nc)
  end
end

nc_attr(fs::Vector{<:AbstractString}) = map(nc_attr, fs)


function nc_attr(f::AbstractString, keys::Vector)
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

function nc_attr(f::AbstractString, key::AbstractString)
  nc_attr(f, [key])[1]
end


function nc_attr_rm!(f::NCfiles, keys::Vector{<:AbstractString})
  nc_open(f, "a") do nc
    for i = 1:length(keys)
      delete!(nc.attrib, keys[i])
    end
  end
end

function nc_attr_rm!(f::NCfiles)
  keys = map(x -> x.first, nc_attr(f))
  nc_attr_rm!(f, keys)
end


precompile(nc_attr!, (NCfiles, Dict))
precompile(nc_attr, (NCfiles,))
precompile(nc_attr_rm!, (NCfiles,))
