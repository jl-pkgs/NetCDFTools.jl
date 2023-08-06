# major update, fix the error of bilinear nanmean4
using Test

@testset "nanmean" begin
  x = [1.0, 2, 3, 4]
  @test NCTools.nanmean4(x...) == 2.5
  @test NCTools.mean4(x...) == 2.5
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
