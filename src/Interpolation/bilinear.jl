"""
  $(TYPEDSIGNATURES)

Suppose that the location, (locx, locy) lies in between the first two grid points in both x an y. That is locx is between x1 and x2 and locy is between y1 and y2. Let `ex= (l1-x1)/(x2-x1)` `ey= (l2-y1)/(y2-y1)`. The interpolant is

( 1-ex)(1-ey)*z11 + (1- ex)(ey)*z12 + ( ex)(1-ey)*z21 + ( ex)(ey)*z22

Where the z's are the corresponding elements of the Z matrix.

  $(METHODLIST)

# References

1. https://github.com/cran/fields/blob/master/R/interp.surface.R

2. https://en.wikipedia.org/wiki/Bilinear_interpolation

# Examples

```jldoc
lon = 70:5:140
lat = 15:5:55

Lon = 70:2.5:140
Lat = 15:2.5:55
Z = rand(T, length(lon), length(lat), 2)
r = bilinear(lon, lat, Z, Lon, Lat; na_rm=true)
```
"""
function bilinear(x, y, z::AbstractArray{T,3}, xx, yy; na_rm=true) where {T<:Real}
  nx = length(x)
  ny = length(y)

  nxx = length(xx)
  nyy = length(yy)
  
  ## approx: 将(x, y) -> 网格的(i, j)；可将(x2-x1, y2-y1) -> (1, 1)
  lx = approx(x, 1.0:nx, xx)
  ly = approx(y, 1.0:ny, yy)

  lx1 = floor.(Int, lx)
  ly1 = floor.(Int, ly)

  ex = lx - lx1
  ey = ly - ly1
  
  ## 边界处理
  lx1[lx1.==nx] .= nx - 1
  ly1[ly1.==ny] .= ny - 1
  ex[lx1.==nx] .= 1
  ey[ly1.==ny] .= 1

  ntime = size(z, 3)
  res = zeros(T, nxx, nyy, ntime)

  @inbounds for i = 1:nxx, j = 1:nyy
    I, J = lx1[i], ly1[j]

    _ex = ex[i] #/ (x2 - x1)
    _ey = ey[j] #/ (y2 - x1)

    z11 = z[I, J, :]
    z12 = z[I, J+1, :]
    z21 = z[I+1, J, :]
    z22 = z[I+1, J+1, :]

    if na_rm
      zmean = nanmean4.(z11, z12, z21, z22) # mean
      fix_na_each(z11, z12)
      fix_na_each(z21, z22)
      fix_na(z11, zmean)
      fix_na(z12, zmean)
      fix_na(z21, zmean)
      fix_na(z22, zmean)
    end

    @fastmath res[i, j, :] = @.(
      z11 * (1 - _ex) * (1 - _ey) +
      z12 * (1 - _ex) * _ey +
      z21 * _ex * (1 - _ey) +
      z22 * _ex * _ey)
    
  end
  res
end

function bilinear(x, y, z::AbstractArray{T,3};
  range=[70, 140, 15, 55], cellsize=1, na_rm=true) where {T<:Real}
  
  delta = cellsize / 2
  rlon = range[1:2]
  rlat = range[3:4]
  xx = rlon[1]+delta:cellsize:rlon[2] #|> collect
  yy = rlat[1]+delta:cellsize:rlat[2] #|> collect
  bilinear(x, y, z, xx, yy; na_rm)
end


export bilinear
