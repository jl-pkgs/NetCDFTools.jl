# using nctools
# using Test

import Random: seed!

@testset "nc_write" begin
  cellsize = 2
  range = [70, 140, 15, 55]

  lon = range[1]+cellsize/2:cellsize:range[2]
  lat = range[3]+cellsize/2:cellsize:range[4]

  nlon = length(lon)
  nlat = length(lat)
  ntime = 10
  seed!(1)
  dat = rand(Float64, nlon, nlat, ntime)

  # time = 1:size(dat2, 3)
  dims = [
    NcDim("lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
    NcDim("lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
    NcDim("time", 1:ntime)
  ]
  # timatts = Dict("longname" => "Time",
  #           "units"    => "hours since 01-01-2000 00:00:00");
  # ntime = size(dat)[3]
  fn = "temp_HI.nc"
  isfile(fn) && rm(fn)

  ## test for nc_write `type`
  nc_write(dat, fn, dims, Dict("longname" => "Heatwave Index");
    varname="HI", overwrite=true,
    type=Float32)
  @test nc_read(fn) |> eltype == Float32
  @test nc_read(fn, type=Float64) |> eltype == Float64

  ## test for overwrite
  nc_write(dat, fn, dims, Dict("longname" => "Heatwave Index"); varname="HI", overwrite=true)
  nc_write!(dat, fn, dims; varname="HI2") # test for multiple variables

  nc_info(fn)
  @test nc_bands(fn) == ["HI", "HI2"]

  data = nc_read(fn, "HI")
  @test data == dat
  isfile(fn) && rm(fn)

  ## 测试第二种数据写入方法
  fn = "temp_HI2.nc"
  isfile(fn) && rm(fn)
  # 1. 写入一个空间文件
  type = Float32
  nc_write(fn, "HI", type, dims, Dict("longname" => "Heatwave Index"); overwrite=true)

  # 2. 后续填入数据
  nc_write!(fn, "HI", dat)
  # `nc_write!`会自动进行变量类型的转换
  # 此处dat被自动转为了`Float32`
  dat2 = nc_read(fn, "HI")
  @test eltype(dat2) == Float32
  @test maximum(abs.(dat2 - dat)) <= 1e-6
end
