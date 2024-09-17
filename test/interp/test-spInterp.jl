# using RTableTools
# st = fread("data/st_met2481.csv")
# serialize("data/st_met2481", st[:, [:site, :lon, :lat, :alt]])
using Ipaper, Ipaper.sf #, ArchGDAL
using NetCDFTools, Test

indir = "$(@__DIR__)/../../data"

@testset "spInterp" begin
  st = deserialize("$indir/st_met2481")
  sites = [st.lon st.lat]
  alt = st[:, :alt]
  data = repeat(alt, 1, 24)' |> collect

  b = bbox(70, 15, 140, 55)
  lon, lat = bbox2dims(b; cellsize=0.5)
  nlon, nlat = length(lon), length(lat)
  ra = rast(rand(nlon, nlat), b)

  weights = weights_idw(ra, sites)
  @test length(rm_empty(weights[:])) == 7861

  weights = weights_idw(ra, sites)
  weights = weights_adw(ra, sites)
  @time zs = spInterp(weights, data)

  @test size(zs) == (nlon, nlat, 24)
  @test mean(zs[:, :, 1]) ≈ 814.0711051650405
end

# @profview zs = spInterp(weights, data);

# begin
#   using GLMakie, MakieLayers
#   lon, lat = st_dims(ra)
#   imagesc(lon, lat, zs[:, :, 1:4]; colorrange=(0, 5000))
# end
