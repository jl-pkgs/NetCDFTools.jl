# const RealOrMissing = Union{Missing,Real}
"""
  AbstractNaArray = AbstractArray{<:Union{T, Missing}} where T <: Real
  AbstractNanArray = AbstractArray{Union{T, Missing}} where T <: Real

- `AbstractNanArray`: must have missing value
- `AbstractNaArray` : may have missing value

# Examples
```
f(x::AbstractNanArray) = x
# f([1, 2]) # not work
f([1, 2, missing])
f([missing])

f2(x::AbstractNaArray) = x	
f2([1, 2])
f2([1, 2, missing])
f2([missing])
```
"""
# 可以含有missing、也可以不含有
AbstractNaArray = AbstractArray{<:Union{T,Missing}} where {T<:Real}
# 必须含有missing
AbstractNanArray = AbstractArray{Union{T,Missing}} where {T<:Real}


function getDataType(x)
  T = eltype(x)
  typeof(T) == Union ? x.b : x
end


"""
replace_miss

$(TYPEDSIGNATURES)

$(METHODLIST)
"""
replace_miss!(x::AbstractArray, replacement=NaN) = x

function replace_miss!(x::AbstractNanArray, replacement=NaN)
  T = getDataType(x)
  replace!(x, missing => T(replacement))
end

function replace_miss(x, replacement=NaN)
  x2 = deepcopy(x)
  replace_miss!(x2, replacement)
  x2
end
