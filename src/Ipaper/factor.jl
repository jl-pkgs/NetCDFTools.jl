# using PooledArrays
# factor = PooledArray
using CategoricalArrays


factor(args...) = CategoricalArray(args...) |> compress

export factor, CategoricalArrays
