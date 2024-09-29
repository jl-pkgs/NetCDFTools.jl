export exact_extract, coverage_fraction, updateMask!


function exact_extract end
function coverage_fraction end

function updateMask!(A::AbstractArray{T,2}, mask::BitMatrix) where {T<:Real}
  missval = T(NaN)
  A[.!mask] .= missval
  A
end

function updateMask!(A::AbstractArray{T,3}, mask::BitMatrix) where {T<:Real}
  missval = T(NaN)
  nlon, nlat, ntime = size(A)
  # lgl = .!mask
  @inbounds @par for k in 1:ntime
    for j = 1:nlat, i = 1:nlon
      !mask[i, j] && (A[i, j, k] = missval)
    end
  end
  A
end

function updateMask!(A::AbstractArray{T,N}, mask::BitMatrix) where {T<:Real,N}
  @inbounds for t in axes(A, N)
    ind = (repeat([:], N - 1)..., t)
    x = @view A[ind...]
    updateMask!(x, mask)
  end
  A
end
