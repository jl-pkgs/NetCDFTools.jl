# calculate statistics for `SpatioTemporalCluster` pkg
# using Pipe
using DataFrames
using Statistics
using Dates
using CFTime

using nctools
using nctools.Ipaper
using nctools.CMIP

probs = factor([0.90, 0.95, 0.99, 0.999, 0.9999])

# Int16 : 2 beers/bytes, -32768 to 32767
# Int32 : 4 beers/bytes, -2147483648 to 2147483647 (21*1e8)
# Int64 : 8 beers/bytes, -9223372036854775808 to 9223372036854775807

# get yearly cluster data 
# # Arguments
# - `kwargs`: other attribute information add to `df`
function cluster2df_yearly(clusterId::AbstractArray{<:Integer,3}, anomaly = nothing; kwargs...)
    res = []
    ntime = size(clusterId) |> last

    # warn: in global scale, change `Int16` to `Int32`
    grid = @pipe LinearIndices(clusterId[:, :, 1]) |> UInt16.(_)

    for i = 1:ntime
        x = @view clusterId[:, :, i]
        ind = findall(x .> 0)

        if length(ind) > 0
            gridId = @view grid[ind]
            d = DataFrame(doy = Int16(i), gridId = gridId, id = @view(x[ind]))
            # add anomaly data if it has
            if anomaly !== nothing
                val_anorm = @view anomaly[:, :, i]
                cbind(d, anomaly = @view(val_anorm[ind]))
            end
            push!(res, d)
        end
    end
    df = vcat(res...)

    if length(kwargs) > 0
        cbind(df; kwargs...)
    end
    df
end

# ! DEPRECATED
function cluster2df_GCM(f_id::AbstractString, f_anorm::AbstractString)
    arr_id = Int32.(nc_read(f_id; raw = true))
    arr_anorm = nc_read(f_anorm; raw = true)
    get_ClusterData_all(arr_id, arr_anorm)
end

function cluster2df_GCM(arr_id, arr_anorm)
    # arr_id = Int32.(nc_read(f_id; raw = true))
    # arr_anorm = nc_read(f_anorm; raw = true)
    dates = nc_date(f_id)
    years = Dates.year.(dates)
    grps = years |> unique |> sort

    res = []
    @time for i = 1:length(grps)
        year = grps[i]
        println("year = $year")

        for k = 1:length(probs)
            ind_year = findall(years .== year)

            data_id = @view arr_id[:, :, ind_year, k]
            data_anorm = @view arr_anorm[:, :, ind_year, k]

            ans = get_ClusterData_yearly(data_id, data_anorm; year = Int16(year), prob = probs[k])
            push!(res, ans)
        end
    end
    df = rbind(res...)
    df
end

"""
    cluster2df_Observed(
        arr_id::AbstractArray{T1,4}, arr_HI::AbstractArray{T2,3}, TRS::AbstractArray{T2,4},
        dates) where {T1<:Integer,T2<:Real}

# Arguments
- `arr_id` : `[lon, lat, time, prob]`
- `arr_HI` : `[lon, lat, time]`
- `TRSN`   : `[lon, lat, doy, prob]`
- `dates`  : `[time]`

# Examples
```
cluster2df_Observed(arr_id, arr_HI, TRS, dates)
```
"""
function cluster2df_Observed(
    arr_id::AbstractArray{T1,4}, arr_HI::AbstractArray{T2,3}, TRS::AbstractArray{T2,4},
    dates) where {T1<:Integer,T2<:Real}

    # arr_id = Int32.(nc_read(f_id; raw = true))
    # arr_anorm = nc_read(f_anorm; raw = true)
    dates = nc_date(f_id)
    years = Dates.year.(dates)
    grps = years |> unique |> sort

    # get mm-dd
    mmdds = Dates.format.(dates, "mm-dd")
    mds = mmdds |> unique |> sort

    res = []
    @time @views for i = 1:length(grps)
        year = grps[i]
        println("year = $year")

        for k = 1:length(probs)
            ind = findall(years .== year)
            ind_md = indexin(mmdds[ind], mds)

            data_id = arr_id[:, :, ind, k]
            # data_anorm = @view arr_anorm[:, :, ind, k]
            data_anorm = arr_HI[:, :, ind] - TRS[:, :, ind_md, k]

            ans = cluster2df_yearly(data_id, data_anorm; year = Int16(year), prob = probs[k])
            push!(res, ans)
        end
    end
    df = rbind(res...)
    df
end


# 按照事件统计的cluster特征
function statistic_temporal(d)
    by_E = intersect(["prob", "year", "id"], names(d)) # by event
    by_dayE = cat(by_E, "doy"; dims = 1)

    @pipe d |>
          groupby(_, by_dayE) |>
          combine(_,
              nrow => "N",
              ["anomaly", "area"] => weighted_mean => "anorm_mean", # deg
              ["anomaly", "area"] => weighted_sum => "anorm_sum",  # deg * km^2
              "area" => sum => "sa", # km^2
          ) |>
          groupby(_, by_E) |>
          combine(_,
              :doy => first,
              :doy => last,
              :doy => length => "HWD",
              "anorm_mean" => mean => "HWI",     # degC
              "anorm_mean" => sum => "HWS_mean", # degC * d
              "anorm_sum" => sum => "HWS_sum",   # degC * km^2 * d
              "N" => mean => "HWA_n_avg",        # n_pixels
              "N" => maximum => "HWA_n_max",     # n_pixels
              "N" => sum => "HWA_n_sum",         # n_pixels * d
              "sa" => mean => "HWA_avg",         # km^2
              "sa" => maximum => "HWA_max",      # km^2
              "sa" => sum => "HWA_sum",          # km^2 * d 
          )
end

# 按照网格统计的cluster特征
function statistic_spatial(d)
    by_grid = intersect(["prob", "year", "index", "gridId"], names(d)) # by event
    @pipe d |>
          groupby(_, by_grid) |>
          combine(_,
              :doy => first, # of this year
              :doy => last,
              :doy => length => "HWD",
              "anomaly" => maximum => "HWI",
              "anomaly" => sum => "HWS",
              "id" => uniqueN => "HWF"
          )
end

# ? Not tested and used 
function get_anomaly(arr::AbstractArray{T,3}, TRS::AbstractArray{T,3},
    dates::Union{Vector{<:Union{Date,DateTime,AbstractCFDateTime}},StepRange};
    fun = (x, y) -> x .-= y,
    verbose = true, parallel::Bool = false) where {T<:Real}

    mmdds = Dates.format.(dates, "mm-dd")
    mds = mmdds |> unique |> sort
    doy_max = length(mds)

    @assert doy_max == size(TRS, 3)
    # TODO: check shy strategy
    # idxs = indexin(mmdd, mds)
    # arr - TRS[idxs]
    years = year.(dates)
    year_grps = unique(years) |> sort

    # res = zeros(Bool, size(arr))
    # res = BitArray(undef, size(arr))
    res = zeros(Float32, size(arr))
    @views @par parallel for year in year_grps
        verbose && println("year = $year")

        ind = years .== year
        ind_d = indexin(mmdds[ind], mds) # allow some doys missing
        res[:, :, ind] = fun(arr[:, :, ind], TRS[:, :, ind_d])
    end
    res
end
