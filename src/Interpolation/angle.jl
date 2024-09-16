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
