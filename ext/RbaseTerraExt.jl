export RbaseTerraExt
module RbaseTerraExt

using DataFrames
using RCall
using NetCDFTools
import NetCDFTools: exact_extract, coverage_fraction


function init_pkgs()
  R"""
  suppressMessages({
    library(terra)
    library(exactextractr)
    library(data.table)
    library(Ipaper)
    library(sf2)
  })

  aperm_array <- function(x) {
    dims = dim(x)
    ndim = length(dims)
    perm = if (ndim >= 3) c(2, 1, 3:ndim) else c(2, 1)
    aperm(x, perm)
  }
  """
end

# function add_Id(d)
#   d.I = 1:nrow(d)
#   d[:, Cols(end, 2:end)]
# end

# 4d array如何处理呢？
# , shp::AbstractString=nothing
"""
  make_rast(data, lon, lat, shp, date=nothing)  

!!! Please install `exactextractr` and `terra` in R first.

# Arguments

- `data`: `heatmap(data[:, :, 1]', yflip=true);` should looks normal.

# Examples

```julia
# f = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax_year/historical/G100_HI_tasmax_adj_year_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-20141231.nc"

f = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax/historical/G100_HI_tasmax_adj_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-20141231.nc"
shp = "Z:/Researches/CMIP6/ChinaHW_cluster.R/data-raw/shp/dat_representive_regions.shp"

@time data = nc_read(f);
dims = ncvar_dim(f)

lon = dims[r"lon"].vals
lat = dims[r"lat"].vals
date = nc_date(f);

@time r = exact_extract(data, lon, lat, shp, date; plot=true)

# # check data
# using Plots
# heatmap(data[:, :, 1]', yflip=true);
```
"""
function exact_extract(data, lon, lat, shp, date=nothing; plot=false)
  cellx = diff(lon[1:2])[1]
  celly = diff(lat[1:2])[1]

  range = [minimum(lon), maximum(lon), minimum(lat), maximum(lat)] .+
          [-cellx, cellx, -celly, celly] ./ 2

  init_pkgs()

  R"""
  date = $date
  shp = sf::read_sf($shp)
  plot = $plot

  e = terra::ext($range)
  vals = $data
  vals = aperm_array(vals)
  ra = rast(vals, ext=e)

  if (plot) {
    Ipaper::write_fig({
      plot(ra[[1]])
    }, "Rplot_jl.pdf")
  }

  r <- exactextractr::exact_extract(ra, shp, "weighted_mean", 
    weights = "area")
  r = r |> as.matrix() |> t() |> as.data.frame()
  if (!is.null(date)) r = cbind(date, r)
  r
  """ |> rcopy
end


"""
    coverage_fraction(f, shp; union=false)

# Examples

```julia
f = "Z:/ERA5/ChinaHI_hourly/OUTPUT/ChinaDaily_ERA5_HI_ALL_2022.nc"
f_shp = "//kong-nas/CMIP6/GitHub/shapefiles/国家基础地理信息系统数据/bou1_4p.shp"

@time info, mask = coverage_fraction(f, f_shp; union=true)
@time data = nc_read_all(f);
data2 = map(x -> updateMask!(x, mask), data)

fout = "Z:/ERA5/ChinaHI_hourly/OUTPUT/ChinaDaily_ERA5_HI_ALL_2022_masked.nc"
nc_write!(fout, data2, ncvar_dim(f))
```
"""
function coverage_fraction(f, shp; union=false)
  init_pkgs()

  info = R"""
  ra = rast($f, lyrs=1)

  shp = sf::read_sf($shp)
  if ($union) shp = sf::st_union(shp)

  fraction = exactextractr::coverage_fraction(ra, shp)[[1]]
  area = cellSize(ra, unit = "km")

  r = c(area, fraction = fraction)
  rast_df(r) %>% 
    mutate(area2 = area * fraction) %>%
    .[fraction > 0] %>%
    .[, .(I = cell, cell, lon, lat, fraction, area, area2)]
  """ |> rcopy
  
  # return a mask, true is inside
  dims = length.(st_dims(f)[1:2])
  # data = nc_read(f, ind=(:, :, 1)) # time should be in the last
  mask = falses(dims...)
  mask[info.cell] .= true
  info, mask
end

# TODO: Test convert julia `Raster` to R `terra::rast`


end
