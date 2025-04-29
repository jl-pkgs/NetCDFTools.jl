function nc_get_value(fs, band=nothing; verbose=false)
  band === nothing && (band = nc_bands(fs[1])[1])

  data = []
  dates = []
  
  for f = fs
    verbose && (println(basename(f)))
    nc_open(f) do ds
      _data = ds[band].var |> collect
      _dates = nc_date(ds)
      push!(data, _data)
      push!(dates, _dates)
    end
  end
  
  ndim = length(size(data[1]))
  
  data = cat(data..., dims=ndim)
  dates = cat(dates..., dims=1)

  inds = .!(duplicated(dates))
  selectdim(data, ndim, inds), dates[inds]
end

"""
    nc_combine(fs, fout; compress=0)

!会自动跳过重复的日期
"""
function nc_combine(fs, fout; compress=0)
  f = fs[1]
  nc = nc_open(f)
  band = nc_bands(f)[1]
  v = nc[band]

  printstyled("Reading data...\n")
  @time vals, dates = nc_get_value(fs, band)
  # times = nc_get_value(fs, "time")

  if eltype(dates) <: Real
    times = dates
  else
    att = nc["time"].attrib
    times = CFTime.timeencode(dates, att["units"], att["calendar"])
  end
  dims = ncvar_dim(nc)
  dims["time"] = NcDim("time", dates, dims["time"].atts)
  
  # 这里会引起错误
  printstyled("Writing data...\n")
  @time nc_write(fout, band, vals, dims;
    attr=Dict(v.attrib), global_attr=Dict(nc.attrib),
    compress)
end

"""
$(TYPEDSIGNATURES)
  
$(METHODLIST)
"""
function nc_combine(d::AbstractDataFrame; outdir = ".", overwrite=false, kw...)

  prefix = str_extract(basename(d.file[1]), ".*(?=_\\d{4})")
  date_begin = d.date_begin[1]
  date_end = d.date_end[end]
  fout = "$outdir/$(prefix)_$date_begin-$date_end.nc"

  if isfile(fout) && !overwrite
    println("[ok] file downloaded already!")
    return
  end

  @show fout
  fs = d.file
  nc_combine(fs, fout; kw...)  
end


# 若要使用并行版本，次函数需要重写
function nc_combine(lst::GroupedDataFrame; outdir = ".", overwrite=false, kw...)
  for d = lst
    nc_combine(d; outdir, overwrite, kw...)
  end
end


export nc_combine
