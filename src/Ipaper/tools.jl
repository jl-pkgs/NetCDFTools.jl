import DataFrames: DataFrame
import StatsBase: countmap, weights, mean


# import Base: length
Base.length(x::Nothing) = 0
is_empty(x) = length(x) == 0
not_empty(x) = length(x) > 0


weighted_mean(x, w) = mean(x, weights(w))
weighted_sum(x, w) = sum(x, weights(w))


function nth(x, n)
    x = sort(x)
    x[n]
end

which_isna(x) = findall(x .== nothing)
which_notna(x) = findall(x .!= nothing)

"""
    match2(x, y)

# Examples
```julia
x = [1, 2, 3, 3, 4]
y = [0, 2, 2, 3, 4, 5, 6]
match2(x, y)
```

# Note: match2 only find the element in `y`
"""
function match2(x, y)
    # find x in y
    ind = indexin(x, y)
    I_x = which_notna(ind)
    I_y = something.(ind[I_x])
    # use `something` to suppress nothing `Union`
    DataFrame(value = x[I_x], I_x = I_x, I_y = I_y)
end

uniqueN(x) = length(unique(x))

# TODO: need to test
function CartesianIndex2Int(x, ind)
    # I = 1:prod(size(x))
    I = LinearIndices(x)
    I[ind]
end


table = countmap

"""
    duplicated(x::Vector{<:Real})

```julia
x = [1, 2, 3, 4, 1]
duplicated(x)
# [0, 0, 0, 0, 1]
```
"""
function duplicated(x::Vector)
    grps = table(x)
    grps = filter(x -> x[2] > 1, grps)

    n = length(x)
    res  = BitArray(undef, n)
    res .= false
    for (key, val) in grps
        k = 0
        for i = 1:n
            if x[i] == key
                k = k + 1
                if k >= 2; res[i] = true; end
                if k == val; break; end
            end
        end
    end
    res
end

seq_along(x) = 1:length(x)
seq_len(n) = 1:n


export table, which_isna, which_notna, match2, uniqueN, duplicated, 
    is_empty, not_empty,
    weighted_mean, weighted_sum, 
    seq_along, seq_len
