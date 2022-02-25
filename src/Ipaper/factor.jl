# using PooledArrays
# factor = PooledArray
using CategoricalArrays


factor2(args...) = CategoricalArray(args...) |> compress

export factor2, CategoricalArrays
