
import DataFrames: DataFrame
import StatsBase: countmap
table = countmap


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

export table, which_isna, which_notna, match2
