# major update, fix the error of bilinear nanmean4
using Test, NetCDFTools

@testset "nanmean" begin
  x = [1.0, 2, 3, 4]
  @test NetCDFTools.nanmean4(x...) == 2.5
  @test NetCDFTools.mean4(x...) == 2.5
end


@testset "bilinear" begin
  set_seed(1)
  b = bbox(70, 15, 140, 55)
  lon, lat = bbox2dims(b; cellsize=10)
  
  cell2 = 5
  ntime = 2
  Z = rand(Float32, length(lon), length(lat), ntime)

  dates = Date(2010):Day(1):Date(2010, 1, 1) |> collect
  ra = rast(deepcopy(Z), b; time=dates, name="tasmax")
  ra_5 = bilinear(ra; cellsize=5)
  
  Lon, Lat = bbox2dims(b; cellsize=5)
  r1 = bilinear(lon, lat, Z, Lon, Lat; na_rm=true)
  r2 = bilinear(lon, lat, Z; b, cellsize=cell2)

  @test size(r1) == (length(Lon), length(Lat), ntime)
  @test r1 == r2
  @test ra_5.A == r1
end


@testset "bilinear vs. cdo" begin
  f_cdo = proj_path("data/HI_tasmax_resampled_cdo.nc")
  # cdo_bilinear(f, fout, fgrid; verbose=true)
  Z_cdo = nc_read(f_cdo)

  ## 2. bilinear版本
  # note: the sort style of `lat` and `yy` should be same
  f = proj_path("data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc")
  lon, lat = st_dims(f)
  A = nc_read(f)
  b = bbox(70, 15, 140, 55)
  xx, yy = bbox2dims(b; cellsize=1, reverse_lat=false)

  Z_kong = bilinear(lon, lat, A, xx, yy)
  @test maximum(abs.(Z_kong - Z_cdo)) <= 1e-5
end
