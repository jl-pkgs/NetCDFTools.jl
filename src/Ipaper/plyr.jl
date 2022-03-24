function apply(x::AbstractArray, dims, fun::Function)
  mapslices(fun, x, dims = dims)
end

export apply
