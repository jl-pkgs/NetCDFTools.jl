# like jld2save
function nt2dims(dims::NamedTuple)
  _dims = []
  for (key, value) in pairs(dims)
    _dim = NcDim(string(key), value)
    push!(_dims, _dim)
  end
  map(identity, _dims)
end

check_dims(dims::NamedTuple) = nt2dims(dims)
check_dims(dims::Vector{NcDim}) = dims

bool2int(x::Bool) = Int(x)
bool2int(x::Integer) = x


"""
    ncsave(f::AbstractString, compress, options=(;); dims, kw...)

## Arguments
- `compress`: 0~10, 0代表不压缩, 10最大压缩，默认为1
- `options`: other keyword arguments to `nc_write!`

## Examples
```julia
dims = (; x = 1:10, y = 1:10)
ncsave("test.nc", true; dims, SM=rand(10, 10), SPI=rand(Float32, 10, 10))

# overwrite
ncsave("test.nc", true, (; overwrite=true); 
  dims, SM=rand(10, 10), SPI=rand(Float64, 10, 10))

dims = (; x = 1:10, y = 1:10, z = 1:10)
ncsave("test.nc"; dims, SM3=rand(10, 10, 10))
```
"""
function ncsave(f::AbstractString, compress=1, options=(;); dims, kw...)
  compress = bool2int(compress)
  dims = check_dims(dims)
  
  for (key, value) in pairs(kw)
    nc_write!(f, string(key), value, dims; compress=1, options...)
  end
end


export ncsave
