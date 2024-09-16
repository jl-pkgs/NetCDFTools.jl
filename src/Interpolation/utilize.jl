"""
rdist_earth(x1::Matrix, x2::Matrix; R=6378.388)

```julia
p1 = [110 30; 111 31]
p2 = [113 32; 115 35]
rdist_earth(p1, p2)
```
"""
function rdist_earth(x1::Matrix, x2::Matrix; R=6378.388)
  lon1 = deg2rad.(x1[:, 1])
  lat1 = deg2rad.(x1[:, 2])
  lon2 = deg2rad.(x2[:, 1])
  lat2 = deg2rad.(x2[:, 2])

  _x = @. [cos(lat1) * cos(lon1) cos(lat1) * sin(lon1) sin(lat1)]
  _y = @. [cos(lat2) * cos(lon2) cos(lat2) * sin(lon2) sin(lat2)]
  pp = _x * _y'
  return R .* acos.(clamp.(pp, -1, 1))
end
