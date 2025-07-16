export rm_empty, weighted_nanmean!, weighted_nanmean, earth_dist
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

function rm_empty(list::Vector)
  filter(x -> !isempty(x), list)
end


"""
    earth_dist(x1::Matrix, x2::Matrix; R=6378.388)
    earth_dist(p1::Tuple{FT,FT}, x2::AbstractMatrix; R=6378.388) where {FT}

```julia
p1 = [110 30; 111 31]
p2 = [113 32; 115 35]
earth_dist(p1, p2)
```
"""
function earth_dist(x1::Matrix, x2::AbstractMatrix; R=6378.388)
  lon1 = deg2rad.(x1[:, 1])
  lat1 = deg2rad.(x1[:, 2])
  lon2 = deg2rad.(x2[:, 1])
  lat2 = deg2rad.(x2[:, 2])

  _x = @. [cos(lat1) * cos(lon1) cos(lat1) * sin(lon1) sin(lat1)]
  _y = @. [cos(lat2) * cos(lon2) cos(lat2) * sin(lon2) sin(lat2)]
  pp = _x * _y'
  return R .* acos.(clamp.(pp, -1, 1))
end

function earth_dist(p1::Tuple{FT,FT}, x2::AbstractMatrix; R=6378.388) where {FT}
  x1 = [p1[1] p1[2]]
  earth_dist(x1, x2; R)[:]
end
