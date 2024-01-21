using NetCDFTools

f = "Z:/ChinaHW/CMIP6_mergedFiles/ChinaHW_CMIP6_raw/HI_tasmax_Palt/historical/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-20141231.nc"

# nc_info(f)
# nc_bands(f)
A = nc_read(f; ind=(:, :, 1:2))
dates = nc_date(f)[1:2]

_dims = nc_dims(f)[[1, 3]]
dim_time = NcDim_time(dates)
_dims = [_dims..., dim_time]

nc_write("data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc", "HImax", A, _dims)
