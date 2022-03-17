# using PooledArrays
# factor = PooledArray
using CategoricalArrays


factor(args...) = CategoricalArray(args...) |> compress

factor_value(x::CategoricalValue) = levels(x)[x.ref]

export factor, factor_value, CategoricalArrays
