using DataFrames

"""
    weight_idw(point::Tuple, sites::AbstractMatrix; r_deg=5, nmax::Int=20, m=2)
    weight_adw(point::Tuple, sites::AbstractMatrix; r_deg=5, nmax::Int=20, m=4, cdd=450)

# Arguments
- `point`: Tuple of (lon, lat) coordinates
- `sites`: Matrix of (lon, lat) coordinates
- `r_deg`: radius in degrees
- `nmax`: maximum number of sites
- `m`: power of distance
"""
function weight_idw(point::Tuple, sites::AbstractMatrix;
  r_deg=5, nmax::Int=20, m=2)

  lgl = (abs.(sites[:, 1] .- point[1]) .<= r_deg) .&
        (abs.(sites[:, 2] .- point[2]) .<= r_deg)
  I = findall(lgl)
  sites = @view sites[I, :]
  dist = earth_dist(point, sites)

  @views if length(dist) > nmax
    inds = sortperm(dist, rev=true)[1:nmax] # sort by distance
    sites = sites[inds, :]
    dist = dist[inds]
    I = I[inds]
  end

  isempty(dist) && return DataFrame(; I=[], w=[], dist)
  w = 1 ./ dist .^ m
  DataFrame(; I, w, dist)
end

function weight_adw(point::Tuple, sites::AbstractMatrix;
  r_deg=5, nmax::Int=20, m=4, cdd=450)

  lgl = (abs.(sites[:, 1] .- point[1]) .<= r_deg) .&
        (abs.(sites[:, 2] .- point[2]) .<= r_deg)
  I = findall(lgl)
  sites = @view sites[I, :]
  dist = earth_dist(point, sites)
  # 根据距离只挑选前20的点
  @views if length(dist) > nmax
    inds = sortperm(dist, rev=true)[1:nmax] # sort by distance
    sites = sites[inds, :]
    dist = dist[inds]
    I = I[inds]
  end

  if length(dist) == 1
    return DataFrame(; I, w=1.0, dist, θ=0.0)
  end

  θ = deg2rad.(angle_azimuth_sphere(point, sites))
  θ[dist.<=1e-2] .= 0 # site just on the grid
  wk = @. exp(-dist / cdd)^m # Xavier 2016, Eq. 7

  n = length(dist)
  α = zeros(n)
  @inbounds for k = 1:n
    ∑ = ∑w = 0.0
    for l = 1:n
      k == l && continue
      ∑ += wk[l] * (1 - cos(θ[k] - θ[l]))
      ∑w += wk[l]
    end
    α[k] = ∑ / ∑w
  end
  w = wk .* (1 .+ α)
  return DataFrame(; I, w, dist, θ=rad2deg.(θ))
end


function weights_idw(ra::SpatRaster, sites::AbstractMatrix;
  nmax::Int=10, r_deg=5,
  m=2, ignored...)
  weights_func(ra, sites; wfun=weight_idw, nmax, r_deg, m, ignored...)
end

function weights_adw(ra::SpatRaster, sites::AbstractMatrix;
  nmax=10, r_deg=5, m=4, cdd=450, ignored...)
  weights_func(ra, sites; wfun=weight_adw, m, cdd, nmax, r_deg, ignored...)
end


function weights_func(ra::SpatRaster, sites::AbstractMatrix; wfun::Function, nmax=10, r_deg=5, kw...)
  lon, lat = st_dims(ra)
  nlon, nlat = size(ra)[1:2]
  weights = Matrix{Any}(undef, nlon, nlat)
  p = Progress(nlon)

  for i = 1:nlon
    next!(p)
    for j = 1:nlat
      _lon, _lat = lon[i], lat[j]
      # k = (ilon - 1) * nlat + ilat

      point = (_lon, _lat)
      info = wfun(point, sites; r_deg, nmax, kw...)
      if nrow(info) > 0
        info = info[sortperm(info.w, rev=true), :]
        nrow(info) > nmax && (info = info[1:nmax, :])
      end
      weights[i, j] = info
    end
  end
  return weights
end


"""
    spInterp(weights::AbstractMatrix, data::AbstractMatrix; progress=true)

```julia
sites = [st.lon st.lat]
alt = st[:, :alt]
data = repeat(alt, 1, 24)' |> collect

b = bbox(70, 15, 140, 55)
lon, lat = bbox2dims(b; cellsize=0.5)
nlon, nlat = length(lon), length(lat)
ra = rast(rand(nlon, nlat), b)

weights = weights_adw(ra, sites)
@time zs = spInterp(weights, data)
```
"""
function spInterp(weights::AbstractMatrix, data::AbstractMatrix; progress=true)
  ntime = size(data, 1)
  nlon, nlat = size(weights)[1:2]
  out = zeros(nlon, nlat, ntime)

  p = Progress(nlon)
  z = zeros(Float64, ntime)

  @views @inbounds for i = 1:nlon
    progress && next!(p)
    for j = 1:nlat
      # k = (i - 1) * nlat + j
      info = weights[i, j]
      isempty(info) && continue

      I = info.I
      ws = info.w
      weighted_nanmean!(z, data[:, I], ws) # byrow=true
      out[i, j, :] .= z
    end
  end
  return out
end


export weight_adw, weight_idw,
  weights_adw, weights_idw,
  weights_func, spInterp
