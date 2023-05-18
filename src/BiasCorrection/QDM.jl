using StatsBase: ecdf, quantile


cal_tau(x::AbstractVector) = ecdf(x)(x)

# skip nan values
function nanquantile2(x::AbstractVector{T}, probs::AbstractVector) where {T<:Real}
  inds_good = .!isnan.(x)
  z = quantile(@view(x[inds_good]), probs) # skip nan
  z
end


"""
  $(TYPEDSIGNATURES)
  
# References

1. Cannon, A. J., Sobie, S. R., & Murdock, T. Q. (2015). Bias Correction of GCM
   Precipitation by Quantile Mapping: How Well Do Methods Preserve Changes in
   Quantiles and Extremes? Journal of Climate, 28(17), 6938–6959.
   https://doi.org/10.1175/JCLI-D-14-00754.1
"""
function QDM(y_obs::AbstractVector{T}, y_calib::AbstractVector{T}, y_pred::AbstractVector{T}; na_rm=false) where {T<:Real}
  tau_pred = cal_tau(y_pred)

  if na_rm
    delta_m = y_pred - nanquantile2(y_calib, tau_pred)
    y_pred_adj = nanquantile2(y_obs, tau_pred) + delta_m
  else
    delta_m = y_pred - quantile(y_calib, tau_pred)
    y_pred_adj = quantile(y_obs, tau_pred) + delta_m
  end
  y_pred_adj
end


function QDM(arr_obs::AbstractArray{T,3},
  arr_calib::AbstractArray{T,3},
  arr_pred::AbstractArray{T,3}; inds, na_rm=false) where {T<:Real}

  arr_pred_adj = deepcopy(arr_pred) .* T(NaN)

  @inbounds @views @par for k in eachindex(inds)
    I = inds[k]
    i = I[1]
    j = I[2]

    mod(k, 100) == 0 && println("k = $k")

    y_obs = arr_obs[i, j, :]
    y_calib = arr_calib[i, j, :]
    y_pred = arr_pred[i, j, :]

    y_pred_adj = QDM(y_obs, y_calib, y_pred; na_rm)
    arr_pred_adj[i, j, :] = y_pred_adj
  end
  arr_pred_adj
end

export QDM
