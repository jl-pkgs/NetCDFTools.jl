"""
  $(TYPEDSIGNATURES)
  
# Arguments
- `f`: input file
- `fout`: output file
- `by`: "year" or "month", or a function to group dates

$(METHODLIST)
# Examples
```
nc_agg(f, fout; by="year", fun=mean, outdir="./OUTPUT", overwrite=false, verbose=true)
```
"""
function nc_agg(f::AbstractString, fout=nothing; by="year", fun=mean,
  outdir="./OUTPUT", overwrite=false, verbose=true)
  
  fout === nothing && (fout = "$outdir/$(basename(f))")
  if isfile(fout) && !overwrite
    println("[ok] file already finished!")
    return
  end
  verbose && (println("[running] : $(basename(fout))"))

  check_dir(outdir)
  nc = nc_open(f)
  band = nc_bands(nc)[1]
  
  printstyled("Reading data...\n")
  data = nc_read(f)
  dates = nc_date(f)

  if by == "month"
    _by = date_ym.(dates)
  elseif by == "year"
    _by = date_year.(dates)
  else
    _by = by.(dates)
  end
  
  printstyled("Processing ...\n")
  @time vals = agg_time(data, _by; fun) # only support the 3th DIM

  dims = ncvar_dim(nc) # time should be the third dimension
  dims["time"] = NcDim_time(unique_sort(_by))
  
  printstyled("Writing data...\n")
  @time nc_write(fout, band, vals, dims, Dict(nc[band].attrib);
    compress=0, global_attr=Dict(nc.attrib), overwrite)
  nc_close(nc)
end


"""
  $(TYPEDSIGNATURES)

# Examples

```julia-repl
scenario = "historical"
indir = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax/historical"
outdir = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax_year/historical"

nc_agg_dir(indir; by="year", replacement="day"=>"year", outdir)
```

$(METHODLIST)
"""
function nc_agg_dir(indir; 
  by="year", replacement="day"=>by, outdir="./OUTPUT", kw...)

  fs = dir(indir, "nc\$")
  check_dir(outdir)

  for f in fs
    file = str_replace(basename(f), replacement[1], replacement[2])
    fout = "$outdir/$file"
    nc_agg(f, fout; by, outdir, kw...)
  end
end
