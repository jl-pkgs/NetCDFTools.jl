export weighted_nanmean!, weighted_nanmean
import Ipaper: weighted_nanmean

# byrow
function weighted_nanmean(mat::AbstractMatrix{T1}, w::AbstractVector{T2}) where {T1,T2}
  n = size(mat, 1)
  R = zeros(promote_type(T1, T2), n)
  weighted_nanmean!(R, mat, w)
end

function weighted_nanmean!(R::AbstractVector, mat::AbstractMatrix{T1}, w::AbstractVector{T2}) where {T1,T2}
  T = promote_type(T1, T2)
  ∑ = ∅ = T(0)
  ∑w = ∅w = T2(0)

  # ntime = byrow ? size(mat, 1) : size(mat, 2)
  # nw = byrow ? size(mat, 2) : size(mat, 1)
  ntime, nw = size(mat)[1:2]
  nw == length(w) || throw(ArgumentError("length(w) must be equal to size of $nw in x"))

  # R = zeros(promote_type(T1, T2), n)
  @inbounds @simd for i in 1:ntime
    ∑ = T(0)
    ∑w = T2(0)
    
    for j in 1:nw
      xᵢⱼ = mat[i, j]
      notnan = xᵢⱼ == xᵢⱼ
      ∑ += ifelse(notnan, xᵢⱼ * w[j], ∅)
      ∑w += ifelse(notnan, w[j], ∅w)
    end
    R[i] = ∑ / ∑w
  end
  return R
end


# function rm_empty(list::Vector)
#   filter(x -> !isempty(x), list)
# end
