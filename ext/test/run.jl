using Pkg
Pkg.activate(".")

@time using NetCDFTools
@time using RCall


f = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax/historical/G100_HI_tasmax_adj_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-20141231.nc"
shp = "Z:/Researches/CMIP6/ChinaHW_cluster.R/data-raw/shp/dat_representive_regions.shp"

@time data = nc_read(f);
dims = ncvar_dim(f)

lon = dims[r"lon"].vals
lat = dims[r"lat"].vals
date = nc_date(f);

@time r = exact_extract(data, lon, lat, shp, date; plot=true)
