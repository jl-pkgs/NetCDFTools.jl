# using RTableTools
# st = fread("data/st_met2481.csv")
# serialize("data/st_met2481", st[:, [:site, :lon, :lat, :alt]])
using Ipaper, SpatRasters #, ArchGDAL
using NetCDFTools, Test, Dates

begin
  st = deserialize("data/st_met2481")
  sites = [st.lon st.lat]
  alt = st[:, :alt]
  data = repeat(alt, 1, 24)' |> collect # [time, site]

  b = bbox(70, 15, 140, 55) # xmin, ymin, xmax, ymax
  lon, lat = bbox2dims(b; cellsize=0.5)
  ra = rast(rand(length(lon), length(lat)), b)

  # weights = weights_idw(ra, sites)
  weights = weights_adw(ra, sites)
  @time Z = spInterp(weights, data)
end

dates = DateTime(2020, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 23) |> collect
_dims = [
  NcDim("lon", lon),
  NcDim("lat", lat),
  NcDim_time(dates)
]
nc_write("out.nc", "PRCP", Z, _dims; attrib=Dict("unit" => "mm/h"), overwrite=true)

# @profview zs = spInterp(weights, data);
begin
  using GLMakie, MakieLayers
  lon, lat = st_dims(ra)
  imagesc(lon, lat, Z[:, :, 1:4]; colorrange=(0, 5000))
end
