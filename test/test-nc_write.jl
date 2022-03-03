# using nctools
# using Test

@testset "nc_write" begin
  cellsize = 2
  range = [70, 140, 15, 55]

  lon = range[1]+cellsize/2:cellsize:range[2]
  lat = range[3]+cellsize/2:cellsize:range[4]

  nlon = length(lon)
  nlat = length(lat)
  ntime = 10
  dat = rand(Int32, nlon, nlat, ntime)

  # time = 1:size(dat2, 3)
  dims = [
    NcDim("lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
    NcDim("lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
    NcDim("time", 1:ntime)
  ]
  # timatts = Dict("longname" => "Time",
  #           "units"    => "hours since 01-01-2000 00:00:00");
  # ntime = size(dat)[3]
  fn = "data/temp_HI.nc"
  # isfile(fn) && rm(fn)

  nc_write(dat, fn, dims, Dict("longname" => "Heatwave Index"); varname = "HI", overwrite = true)
  nc_write!(dat, fn, dims; varname = "HI2")

  nc_info(fn)
  @test nc_bands(fn) == ["HI", "HI2"]

  data = nc_read(fn, "HI")
  @test data == dat
  # rm()
end
