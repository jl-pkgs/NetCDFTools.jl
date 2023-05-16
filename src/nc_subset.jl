"""
    $(TYPEDSIGNATURES)

# Arguments

- `check_vals`: If download failed, `length(unique(vals)) = 1`. Default check
  the length of data unique values


# Example

```julia
url = "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-18991231.nc"

fout = "out2.nc"
range = [70, 140, 15, 55]
delta = 5

@time nc_subset(url, range)
```
"""
function nc_subset(f, range::Vector, fout=nothing; 
    delta=5, 
    check_vals=true, verbose=true,
    outdir=".", overwrite=false)

  fout === nothing && (fout = "$outdir/$(basename(f))")
  if isfile(fout) && !overwrite
    verbose && println("[ok] file downloaded already!")
    return
  end
  
  nc = nc_open(f)
  printstyled("Reading dims...\n")
  # @time dims = ncvar_dim(nc)
  @time dims = nc_dims(nc)
  band = nc_bands(nc)[1] # 只选择其中一个变量

  lonr = range[1:2] + [-1, 1] * delta# longitude range
  latr = range[3:4] + [-1, 1] * delta# latitude range
  v = @select(nc[band], $lonr[1] <= lon <= $lonr[2] && $latr[1] <= lat <= $latr[2])

  (ilon, ilat, itime) = parentindices(v)
  dim_lon = dims["lon"][ilon]
  dim_lat = dims["lat"][ilat]
  dim_time = dims["time"][itime]
  dims2 = [dim_lon; dim_lat; dim_time]

  printstyled("Reading data...\n")
  @time vals = v.var[:, :, :] # 三维数据
  
  if check_vals && length(unique(vals)) == 1
    printstyled("[error] downloaded file failed: $f \n", color=:red)
    return
  end
  
  printstyled("Writing data...\n")
  @time nc_write(fout, band, vals, dims2, Dict(v.attrib); compres=1, goal_attrib=Dict(nc.attrib))
  # ncatt_put(fout, Dict(nc.attrib))
end


function nc_subset(d::AbstractDataFrame; 
    outdir=".", kw...)

  prefix = str_extract(basename(d.file[1]), ".*(?=_\\d{4})")
  date_begin = d.date_begin[1]
  date_end = d.date_end[end]

  fout = "$outdir/$(prefix)_$date_begin-$date_end.nc"
  urls = collect(d.file)
  nc_subset(urls, range, fout; kw...)
end
