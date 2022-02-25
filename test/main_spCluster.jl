# calculate statistics for `SpatioTemporalCluster` pkg
using DataFrames
using Pipe
using Statistics
using nctools.Ipaper


probs = factor2([0.90, 0.95, 0.99, 0.999, 0.9999])

# get yearly cluster data 
# # Arguments
# - `kwargs`: other attribute information add to `df`
function get_ClusterData_yearly(clusterId, anomaly = nothing; kwargs...)
    res = []
    ntime = size(clusterId) |> last

    # warn: in global scale, change `Int16` to `Int32`
    grid = @pipe LinearIndices(clusterId[:, :, 1]) |> Int16.(_)

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


function get_ClusterData_all(f_id::AbstractString, f_anorm::AbstractString)
    arr_id = Int32.(nc_read(f_id; raw = true))
    arr_anorm = nc_read(f_anorm; raw = true)
    get_ClusterData_all(arr_id, arr_anorm)
end

function get_ClusterData_all(arr_id, arr_anorm)
    # arr_id = Int32.(nc_read(f_id; raw = true))
    # arr_anorm = nc_read(f_anorm; raw = true)
    dates = nc_date(f_id)
    years = year.(dates)
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
