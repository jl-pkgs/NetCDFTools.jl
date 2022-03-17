using nctools
using NCDatasets

# f = "/mnt/g/Researches/CMIP6/CMIP6_ChinaHW_mergedFiles/HItasmax/hist-GHG/HItasmax_day_ACCESS-CM2_hist-GHG_r1i1p1f1_gn_19610101-20141231.nc"
# f = "/mnt/z/ChinaHW/CMIP6_ChinaHW_cluster/HItasmax/ncell_4/ssp126/clusterId_HItasmax_movTRS_EC-Earth3_m95.nc"
f = "z:/ChinaHW/CMIP6_ChinaHW_mergedFiles/HItasmax/historical/HItasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-20141231.nc"

nc = nc_open(f)
fid = NCDatasets.NCDataset(f)
# nc_dims(f)
@time data = nc["HI"][:];
