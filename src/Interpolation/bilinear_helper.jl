import Interpolations: linear_interpolation, Line


function approx(x, y, xout)
  interp_linear_extrap = linear_interpolation(x, y, extrapolation_bc=Line())
  interp_linear_extrap.(xout) # outside grid: linear extrapolation
end


array(val; dims) = reshape(val, dims...)
array(val, dims) = array(val; dims)

function meshgrid(x, y)
  X = repeat(x', length(y), 1)
  Y = repeat(y, 1, length(x))
  X, Y
end


function mean4(y1::T, y2::T, y3::T, y4::T) where {T<:AbstractFloat}
  (y1 + y2 + y3 + y4) / 4
end

function nanmean4(y1::T, y2::T, y3::T, y4::T) where {T<:AbstractFloat}
  Tₒ = Base.promote_op(/, T, Int)
  n = 0
  Σ = zero(Tₒ)

  if y1 == y1
    n += 1
    Σ += y1
  end

  if y2 == y2
    n += 1
    Σ += y2
  end

  if y3 == y3
    n += 1
    Σ += y3
  end

  if y4 == y4
    n += 1
    Σ += y4
  end

  return Σ / n
end

function nanmean4(y1::AbstractVector{T}, y2::AbstractVector{T},
  y3::AbstractVector{T}, y4::AbstractVector{T}) where {T<:AbstractFloat}
  nanmean4.(y1, y2, y3, y4)
end



function fix_na_each(x::AbstractArray{T}, y::AbstractArray{T}) where {T<:Real}
  @inbounds @simd for i in eachindex(x)
    if isnan(x[i])
      x[i] = y[i]
    end
    if isnan(y[i])
      y[i] = x[i]
    end
  end
end

function fix_na(x::AbstractArray{T}, y::AbstractArray{T}) where {T<:Real}
  @inbounds @simd for i in eachindex(x)
    if isnan(x[i])
      x[i] = y[i]
    end
  end
end


export approx, array, meshgrid
