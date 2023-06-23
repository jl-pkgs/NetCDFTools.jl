function nc_get_value(fs, band=nothing)
  band === nothing && (band = nc_bands(fs[1])[1])

  res = map(f -> begin
      nc_open(f) do ds
        ds[band].var[:]
      end
    end, fs)

  dims = length(size(res[1]))
  cat(res..., dims=dims)
end


function nc_combine(fs, fout; compress=0)
  f = fs[1]
  nc = nc_open(f)
  band = nc_bands(f)[1]
  v = nc[band]

  printstyled("Reading data...\n")
  @time vals = nc_get_value(fs, band)
  time = nc_get_value(fs, "time")
  
  dims = ncvar_dim(nc)
  dim_time = NcDim("time", time, dims["time"].atts)
  dims[3] = dim_time

  printstyled("Writing data...\n")
  @time nc_write(fout, band, vals, dims, Dict(v.attrib);
    compress, goal_attrib=Dict(nc.attrib))
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
