using DataFrames
using CSV

# rbind(args...) = cat(args..., dims = 1)
# cbind(args...) = cat(args..., dims = 2)
abind(args...; along = 3) = cat(args..., dims = along)


rbind(args...) = vcat(args...)


cbind(args...) = hcat(args...)

# by reference
function cbind(df::DataFrame; kwargs...)
    n = length(kwargs)
    vars = keys(kwargs)

    for i = 1:n
        key = vars[i]
        val = kwargs[i]
        # @show key
        # @show val
        if !isa(val, AbstractArray) || length(val) == 1
            df[:, key] .= val
        else
            df[:, key] = val
        end
    end
    df
end

is_dataframe(d) = d isa DataFrame

# for data.frame by reference operation
function melt_list(list; kwargs...)
    if length(kwargs) > 0
        by = keys(kwargs)[1]
        vals = kwargs[1]
    else
        by = :I
        vals = 1:length(list)
    end

    for i = 1:length(list)
        d = list[i]
        if (d isa DataFrame)
            d[:, by] .= vals[i]
        end
    end
    ind = map(is_dataframe, list)
    rbind(list[ind]...)
end

# seealso: leftjoin, rightjoin, innerjoin, outerjoin
function dt_merge(x::DataFrame, y::DataFrame; by = nothing,
    all = false, all_x = all, all_y = all, makeunique = true, kwargs...)

    if by === nothing
        by = intersect(names(x), names(y))
    end
    if !all
        if all_x
            leftjoin(x, y; on = by, makeunique = true, kwargs...)
        elseif all_y
            rightjoin(x, y; on = by, makeunique = true, kwargs...)
        else
            # all_x = f && all_y = f
            innerjoin(x, y; on = by, makeunique = true, kwargs...)
        end
    else
        outerjoin(x, y; on = by, makeunique = true, kwargs...)
    end
end

fread(f) = DataFrame(CSV.File(f))
fwrite(df, file) = begin
    dirname(file) |> check_dir
    CSV.write(file, df)
end

export rbind, cbind, abind, melt_list,
    fread, fwrite, dt_merge, 
    is_dataframe,
    DataFrame, names, nrow
