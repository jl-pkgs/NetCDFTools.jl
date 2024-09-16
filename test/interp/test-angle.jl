using Test

@testset "azimuth" begin
  @test angle_azimuth_sphere((0, 0), (0, 1)) == 0    # 正北，0
  @test angle_azimuth_sphere((0, 0), (1, 0)) == 90   # 正东，90
  @test angle_azimuth_sphere((0, 0), (0, -1)) == 180 # 正南，180
  @test angle_azimuth_sphere((0, 0), (-1, 0)) == 270 # 正西，270

  @test angle_azimuth((0, 0), (0, 1)) == 0    # 正北，0
  @test angle_azimuth((0, 0), (1, 0)) == 90   # 正东，90
  @test angle_azimuth((0, 0), (0, -1)) == 180 # 正南，180
  @test angle_azimuth((0, 0), (-1, 0)) == 270 # 正西，270
end
