export rm_empty, weighted_nanmean!, weighted_nanmean, earth_dist
using LoopVectorization

function weighted_nanmean(x::AbstractVector{T1}, w::AbstractVector{T2}) where {T1,T2}
  T = promote_type(T1, T2)
  ∑ = ∅ = T(0)
  ∑w = ∅w = T2(0)

  # @inbounds 
  @turbo for i = eachindex(x)
    # if !isnan(x[i]); end
    xᵢ = x[i]
    notnan = xᵢ == xᵢ
    ∑ += ifelse(notnan, x[i] * w[i], ∅)
    ∑w += ifelse(notnan, w[i], ∅w)
  end
  return ∑ / ∑w
end

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
球面方位角 (0~360°)

```julia
angle_azimuth_sphere((0, 0), (0, 1)) # 正北，0
angle_azimuth((0, 0), (0, 1))        # 正北，0
```
"""
function angle_azimuth_sphere(p1::Tuple{FT,FT}, p2::Tuple{FT,FT}) where {FT}
  lon1, lat1 = p1
  lon2, lat2 = p2

  φ1 = deg2rad(lat1)
  φ2 = deg2rad(lat2)
  Δλ = deg2rad(lon2 - lon1)

  y = sin(Δλ) * cos(φ2)
  x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
  θ = atan(y, x)

  azimuth = rad2deg(θ)
  azimuth < 0 && (azimuth += 360) # 标准化方位角为0-360度
  return azimuth
end

function angle_azimuth_sphere(p1::Tuple{FT,FT}, p2::AbstractMatrix{FT}) where {FT}
  map(x -> angle_azimuth_sphere(p1, (x[1], x[2])), eachrow(p2))
end


function angle_azimuth(p1::Tuple{FT,FT}, p2::Tuple{FT,FT}) where {FT}
  lon1, lat1 = p1
  lon2, lat2 = p2
  dx = lon2 - lon1
  dy = lat2 - lat1

  # 需要atan2(Δx, Δy)来计算从北向东的方位角
  # azimuth = -rad2deg(atan(dy, dx)) + 90
  azimuth = rad2deg(atan(dx, dy))
  azimuth < 0 && (azimuth += 360) # 标准化方位角为0-360度
  return azimuth
end

function angle_azimuth(p1::Tuple{FT,FT}, p2::AbstractMatrix{FT}) where {FT}
  map(x -> angle_azimuth(p1, (x[1], x[2])), eachrow(p2))
end


"""
rdist_earth(x1::Matrix, x2::Matrix; R=6378.388)

```julia
p1 = [110 30; 111 31]
p2 = [113 32; 115 35]
rdist_earth(p1, p2)
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
