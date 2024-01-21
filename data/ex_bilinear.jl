using Ipaper
using Ipaper.sf
using NetCDFTools

f = "./data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc"
lon, lat = st_dims(f)
st_cellsize(lon, lat)

## 1. cdo 版本
cdo_grid([70, 140, 15, 55], 1, true; fout="data/grid.txt")

fgrid = "data/grid.txt"
fout = "data/HI_tasmax_resampled_cdo.nc"
cdo_bilinear(f, fout, fgrid; verbose=true)

## 2. bilinear版本
Z_cdo = nc_read(fout)
# note: the sort style of `lat` and `yy` should be same
A = nc_read(f)
b = bbox(70, 15, 140, 55)
xx, yy = bbox2dims(b; cellsize=1, reverse_lat=false)
Z_kong = bilinear(lon, lat, A, xx, yy)
maximum(abs.(Z_kong - Z_cdo)) <= 1e-5
