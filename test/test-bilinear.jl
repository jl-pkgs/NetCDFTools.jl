# major update, fix the error of bilinear nanmean4
using Test

@testset "nanmean" begin
  x = [1.0, 2, 3, 4]
  @test NetCDFTools.nanmean4(x...) == 2.5
  @test NetCDFTools.mean4(x...) == 2.5
end


@testset "bilinear" begin
  cell = 10
  lon = 70:cell:140
  lat = 15:cell:55
  ntime = 2

  cell2 = 5
  Lon = 70+cell2/2:cell2:140
  Lat = 15+cell2/2:cell2:55
  Z = rand(Float32, length(lon), length(lat), ntime)
  r1 = bilinear(lon, lat, Z, Lon, Lat; na_rm=true)
  r2 = bilinear(lon, lat, Z; range=[70, 140, 15, 55], cellsize=cell2)
  
  @test size(r1) == (length(Lon), length(Lat), ntime)
  @test r1 == r2
  # 如何检测结果是否正确？
end

@testset "bilinear vs. cdo" begin
  f_cdo = "../data/HI_tasmax_resampled_cdo.nc"
  # cdo_bilinear(f, fout, fgrid; verbose=true)
  Z_cdo = nc_read(f_cdo)

  ## 2. bilinear版本
  # note: the sort style of `lat` and `yy` should be same
  f = "../data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc"
  lon, lat = st_dims(f)
  A = nc_read(f)
  b = bbox(70, 15, 140, 55)
  xx, yy = bbox2dims(b; cellsize=1, reverse_lat=false)

  Z_kong = bilinear(lon, lat, A, xx, yy)
  @test maximum(abs.(Z_kong - Z_cdo)) <= 1e-5
end
