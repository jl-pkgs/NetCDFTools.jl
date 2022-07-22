using nctools

function create_nc()
  isfile(f) && rm(f)
  ds = nc_open(f, "c")

  ncdim_def(ds, "lon", lon, Dict("longname" => "Longitude", "units" => "degrees east"))
  ncdim_def(ds, "lat", lat, Dict("longname" => "Latitude", "units" => "degrees north"))
  ncdim_def(ds, "time", 1:ntime)
  ds
end

f = "f1.nc"
compress = 0
cellsize = 1
lon = 70+cellsize/2:cellsize:140
lat = 15+cellsize/2:cellsize:55
ntime = 10

dat = ones(length(lon), length(lat), ntime);

begin
  ds = create_nc()
  ncvar_def(ds, "HI", dat, ["lon", "lat", "time"], Dict("longname" => "hello"); compress=compress)
  close(ds)

  # append a variable
  ds = nc_open(f, "a")
  ncvar_def(ds, "HI2", dat, ["lon", "lat", "time"]; compress=compress)
  print(ds)
  # close(ds)

  # add a blank data
  ncvar_def(ds, "HI3", Float64, ["lon", "lat", "time"]; compress=compress)
  close(ds)

  nc_info(f)
end

## a modern way to define variable
begin
  attr = Dict(
    "units" => "degree_Celsius",
    "add_offset" => -273.15,
    "scale_factor" => 0.1,
    "long_name" => "Temperature"
  )

  f = "f1.nc"
  ds = create_nc()
  nc_close(ds)
  nc_write!(dat, f, ["lon", "lat", "time"]; varname="HI", compress=compress)

  # append a variable
  nc_write!(dat, f, ["lon", "lat", "time"], Dict("longname" => "hello"); varname="HI2", compress=compress)

  # add a blank data
  nc_write!(f, "HI3", Float64, ["lon", "lat", "time"], attr; compress=compress)

  nc_info(f)
end
