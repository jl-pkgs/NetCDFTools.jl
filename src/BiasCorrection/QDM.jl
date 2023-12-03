# > 测试如何做偏差矫正更有效，时间序列可能出现不连续的现象
using StatsBase: ecdf, quantile


cal_tau(x::AbstractVector, xout = x) = ecdf(x)(xout)

# skip nan values
function nanquantile2(x::AbstractVector{T}, probs::AbstractVector) where {T<:Real}
  inds_good = .!isnan.(x)
  z = quantile(@view(x[inds_good]), probs) # skip nan
  z
end


"""
  $(TYPEDSIGNATURES)

# Arguments

- `type_adj`: 

  + `add`: 高斯分布的变量，如Tair
  + `mul`: 降水

# Notes

QDM: 需要使用一个滑动窗口。

- `ClimDown`使用的是10年的窗口，一次处理10年；

- `climQMBC`使用的是`nobs`的窗口，一次处理1年。

# References

1. Cannon, A. J., Sobie, S. R., & Murdock, T. Q. (2015). Bias Correction of GCM
   Precipitation by Quantile Mapping: How Well Do Methods Preserve Changes in
   Quantiles and Extremes? Journal of Climate, 28(17), 6938–6959.
   https://doi.org/10.1175/JCLI-D-14-00754.1

2. https://github.com/pacificclimate/ClimDown/blob/master/R/QDM.R#L126

3. https://github.com/rpkgs/climQMBC/blob/master/R/map_QDM.R#L43
"""
function QDM(y_obs::AbstractVector{T}, y_calib::AbstractVector{T}, y_pred::AbstractVector{T}; type_adj="add", kw...) where {T<:Real}
  tau_pred = cal_tau(y_pred)

  if type_adj == "mul"
    delta_m = y_pred ./ nanquantile2(y_calib, tau_pred)
    y_adj = nanquantile2(y_obs, tau_pred) .* delta_m
  elseif type_adj == "add"
    delta_m = y_pred - nanquantile2(y_calib, tau_pred)
    y_adj = nanquantile2(y_obs, tau_pred) + delta_m
  end
  #   delta_m = y_pred - quantile(y_calib, tau_pred)
  #   y_adj = quantile(y_obs, tau_pred) + delta_m
  y_adj
end


# only for daily data
function QDM_chunk!(y_adj::AbstractVector{T},
  y_obs::AbstractVector{T}, y_calib::AbstractVector{T}, y_pred::AbstractVector{T}, dates; 
  ny_win=10, type_adj="add") where {T<:Real}

  lst_index = split_date(dates; ny_win, merge_small=0.7)
  for inds in lst_index
    y_adj[inds] .= QDM(y_obs, y_calib, y_pred[inds]; type_adj)
  end
  y_adj
end


# 逐年滑动平均QDM
function QDM_mov!(y_adj::AbstractVector{T},
  y_obs::AbstractVector{T}, y_calib::AbstractVector{T}, y_pred::AbstractVector{T}, dates; 
  ny_win=30, type_adj="add") where {T<:Real}

  years = year.(dates)
  grps = unique_sort(years)
  year_min = minimum(grps)
  year_max = maximum(grps)

  half = fld(ny_win, 2)
  
  @inbounds @views for year in grps
    year_beg = max(year - half, year_min)
    year_end = min(year + half, year_max)

    inds_target = years == year
    inds_mov = years in year_beg:year_end

    _y_target = y_pred[inds_target]
    _y_mov = y_pred[inds_mov]
    
    tau_pred = cal_tau(_y_mov, _y_target)
    if type_adj == "add"
      delta_m = _y_target - nanquantile2(y_calib, tau_pred)
      y_target = nanquantile2(y_obs, tau_pred) + delta_m # 修正之后的
    elseif type_adj == "mul"
      delta_m = _y_target ./ nanquantile2(y_calib, tau_pred)
      y_target = nanquantile2(y_obs, tau_pred) .* delta_m # 修正之后的
    end
    y_adj[inds_target] .= y_target
  end
  y_adj
end


function QDM_main(arr_obs::AbstractArray{T,3},
  arr_calib::AbstractArray{T,3},
  arr_pred::AbstractArray{T,3}, dates;   
  inds, 
  (fun!)=QDM_chunk!, 
  ny_win=10, type_adj="add") where {T<:Real}

  arr_pred_adj = deepcopy(arr_pred) .* T(NaN)

  @inbounds @views @par for k in eachindex(inds)
    I = inds[k]
    i = I[1]
    j = I[2]

    mod(k, 100) == 0 && println("k = $k")

    y_obs = arr_obs[i, j, :]
    y_calib = arr_calib[i, j, :]
    y_pred = arr_pred[i, j, :]

    fun!(arr_pred_adj[i, j, :], y_obs, y_calib, y_pred, dates; ny_win, type_adj)
    # y_pred_adj = QDM(y_obs, y_calib, y_pred; na_rm)
    # arr_pred_adj[i, j, :] = y_pred_adj
  end
  arr_pred_adj
end


export QDM, QDM_chunk!, QDM_mov!, QDM_main
