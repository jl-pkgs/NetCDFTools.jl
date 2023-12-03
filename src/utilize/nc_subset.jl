"""
    $(TYPEDSIGNATURES)

# Arguments

- `check_vals`: If download failed, `length(unique(vals)) = 1`. Default check
  the length of data unique values


# Note
! 目前只保存其中一个变量

# Example

```julia
# 4-d array
url = "http://esgf3.dkrz.de/thredds/dodsC/cmip6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/zg/gn/v20191108/zg_day_ACCESS-CM2_historical_r1i1p1f1_gn_19500101-19541231.nc"

nc_open(url)

# 3-d array
url = "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-18991231.nc"

range = [70, 140, 15, 55]
delta = 5

@time nc_subset(url, range)
```

$(METHODLIST)
"""
function nc_subset(f, range::Vector, fout=nothing;
  delta=5,
  check_vals=true, verbose=true,
  big=false,
  plevs=nothing,
  band=nothing,
  outdir=".", overwrite=false)

  fout === nothing && (fout = "$outdir/$(basename(f))")
  if isfile(fout) && !overwrite
    verbose && println("[ok] file downloaded already!")
    return
  end

  nc = nc_open(f)
  band === nothing && (band = nc_bands(nc)[1])

  printstyled("Reading dims...\n")
  @time dims = ncvar_dim(nc, band)

  lonr = range[1:2] + [-1, 1] * delta# longitude range
  latr = range[3:4] + [-1, 1] * delta# latitude range
  
  ## 截取数据
  in_plev(plev, plevs) = indexin(round.(Int, plev), plevs*100) .!== nothing

  v = @select(nc[band], $lonr[1] <= lon <= $lonr[2] && $latr[1] <= lat <= $latr[2])

  (ilon, ilat, _) = parentindices(v)
  dims["lon"] = dims["lon"][ilon]
  dims["lat"] = dims["lat"][ilat]
  
  if plevs !== nothing && ndims(v) == 4
    v = @select(v, in_plev(plev, $plevs))
    (ilon, ilat, ilev, _) = parentindices(v)
    dims["plev"] = dims["plev"][ilev]
  end
  
  printstyled("Reading data...\n")

  ntime = dims[end].dimlen
  ndim = ndims(v)
  inds = ntuple(i -> :, ndim)

  @time if big
    lst = split_chunk(ntime, 6)
    tmp = map(itime -> begin
        println("\t[chunk]: $itime")
        _inds = tuple(inds[1:ndim-1]..., itime)
        v[_inds...]
      end, lst)
    vals = cat(tmp...; dims=ndim)
  else
    vals = v[inds...]
  end

  if check_vals && length(unique(vals)) == 1
    printstyled("[error] downloaded file failed: $f \n", color=:red)
    return
  end

  printstyled("Writing data...\n")
  @time nc_write(fout, band, vals, dims, Dict(v.attrib);
    compress=1, global_attrib=Dict(nc.attrib))
  # ncatt_put(fout, Dict(nc.attrib))
end


function nc_subset(d::AbstractDataFrame, range;
  outdir=".", kw...)

  prefix = str_extract(basename(d.file[1]), ".*(?=_\\d{4})")
  date_begin = d.date_begin[1]
  date_end = d.date_end[end]

  fout = "$outdir/$(prefix)_$date_begin-$date_end.nc"
  urls = collect(d.file)
  nc_subset(urls, range, fout; kw...)
end


export nc_subset
