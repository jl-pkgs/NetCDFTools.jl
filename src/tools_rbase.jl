export exact_extract, coverage_fraction, updateMask!


function exact_extract end
function coverage_fraction end

function updateMask!(A::AbstractArray{T,2}, mask::BitMatrix) where {T<:Real}
  missval = T(NaN)
  A[.!mask] .= missval
  A
end

# function updateMask!(A::AbstractArray{T,3}, mask::BitMatrix) where {T<:Real}
#   missval = T(NaN)
#   @views @inbounds for t in axes(A, 3)
#     x = A[:, :, t]
#     x[.!mask] .= missval
#   end
#   A
# end

function updateMask!(A::AbstractArray{T,N}, mask::BitMatrix) where {T<:Real,N}
  @views @inbounds for t in axes(A, N)
    ind = (repeat([:], N - 1)..., t)
    x = A[ind...]
    updateMask!(x, mask)
  end
  A
end
