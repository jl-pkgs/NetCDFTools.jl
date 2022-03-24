using DimensionalData
import Statistics: quantile


const DD = DimensionalData
const TYPE_dimname = Union{Symbol,AbstractString}
const dimnames_default = ["x", "y", "z", "t"]

# function make_dims(vals::Vector, names::Vector{<:TYPE_dimname})
#   (; zip(Symbol.(names), vals)...)
# end

# function make_dims(val, name::TYPE_dimname)
#   make_tuple([val], [name])
# end
function make_dims(array::AbstractArray, dimnames::Vector{<:TYPE_dimname} = dimnames_default)
  n = size(array) |> length
  length(dimnames) < n && error("The length of `names` is short than `dims`")
  Size = size(array)
  dimnames = Symbol.(dimnames)
  
  [Dim{dimnames[i]}(1:Size[i]) for i in 1:length(Size)]
  # vals = [1:i for i in Size] |> collect
  # make_tuple(vals, dimnames[1:n])
end

function DimensionalData.DimArray(
  array::AbstractArray, dimnames::Vector{<:TYPE_dimname} = dimnames_default; kw...)
  
  dims = make_dims(array, dimnames)
  DimArray(array, Tuple(dims), kw...) # 
end


const TYPE_DIM = Union{AbstractString,Symbol,Integer,Type{<:Dim}}

which_dim(d, dim::AbstractString) = findall(string.(name(d.dims)) .== dim)[1]
which_dim(d, dim::Symbol) = findall(name(d.dims) .== dim)[1]
which_dim(d, dim::Type{<:Dim}) = findall(name(d.dims) .== name(dim))[1]
which_dim(d, dim::Integer) = dim

# not passed test
dimnum2(d, dims::Vector{<:TYPE_DIM}) = begin
  nums = [which_dim(d, dim) for dim in dims]
  tuple(nums...)
end

dimnum2(d, dims::TYPE_DIM) = begin
  dimnum2(d, [dims])
end

# `dims`: symbol
"""
  Quantile(array::AbstractArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  Quantile(da::AbstractDimArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  
# Examples
```julia
arr = rand(200, 200, 365);
d = DimArray(arr, ["lon", "lat", "time"]);
probs = [0.5, 0.9];
Quantile(d, probs; dims = :time)
```
"""
function Quantile(da::AbstractDimArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  # dims = dimnum2(array, dims)
  if eltype(dims) <: Integer; dims = name(da.dims)[dims]; end
  if dims isa String; dims = Symbol(dims); end

  bands = collect(name(da.dims))
  r = mapslices(x -> quantile(x, probs), da, dims = dims)
  r = DimArray(r.data, bands) # dimension error, rebuild it
  set(r, dims => :prob)
end

function Quantile(array::AbstractArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  mapslices(x -> quantile(x, probs), array, dims = dims)
end

## deprecated
function Quantile_low(arr::AbstractArray{T, 3}, 
  probs::AbstractVector = [0, 0.25, 0.5, 0.75, 1]) where T<:Union{Missing, <:Real}

    nrow, ncol, _ = size(arr)
    res = zeros(T, nrow, ncol, length(probs))

    @views for i = 1:nrow, j = 1:ncol
      res[i, j, :] = quantile(arr[i, j, :], probs)
    end
    res
end

function Quantile_low(mat::AbstractArray{T, 2}, 
  probs::AbstractVector = [0, 0.25, 0.5, 0.75, 1]) where T<:Real

    nrow, _ = size(arr)
    res = zeros(T, nrow, length(probs))
    
    @views for i = 1:nrow
      res[i, :] = quantile(mat[i, :], probs);
    end
    res
end

export DimArray, Quantile, quantile, which_dim, which_dims, dimnum2, Quantile_low
