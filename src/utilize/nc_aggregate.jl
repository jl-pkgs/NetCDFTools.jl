"""
  $(TYPEDSIGNATURES)
  
# Arguments
- `f`: input file
- `fout`: output file
- `by`: "year" or "month", or a function to group dates

$(METHODLIST)
"""
function nc_aggregate(f::AbstractString, fout=nothing; by="year", fun=mean,
  outdir="./OUTPUT", overwrite=false, verbose=true)
  
  fout === nothing && (fout = "$outdir/$(basename(f))")
  if isfile(fout) && !overwrite
    println("[ok] file downloaded already!")
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
    _by = make_date.(year.(dates), month.(dates))
  elseif by == "year"
    _by = make_date.(year.(dates))
  else
    _by = by.(dates)
  end
  
  printstyled("Processing ...\n")
  @time vals = apply(data, 3; by=_by, fun)
  dims = ncvar_dim(nc) # time should be the third dimension
  dims[3] = NcDim_time(unique_sort(_by))
  
  printstyled("Writing data...\n")
  @time nc_write(fout, band, vals, dims, Dict(nc[band].attrib);
    compress=0, global_attrib=Dict(nc.attrib))
  
  nc_close(nc)
end


"""
  $(TYPEDSIGNATURES)

# Examples

```julia-repl
scenario = "historical"
indir = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax/historical"
outdir = "Z:/ChinaHW/CMIP6_cluster_HItasmax_adjchunk/HI_tasmax_year/historical"

nc_aggregate_dir(indir; by="year", replacement="day"=>"year", outdir)
```

$(METHODLIST)
"""
function nc_aggregate_dir(indir; 
  by="year", replacement="day"=>by, outdir="./OUTPUT", kw...)

  fs = dir(indir, "nc\$")
  check_dir(outdir)

  for f in fs
    file = str_replace(basename(f), replacement[1], replacement[2])
    fout = "$outdir/$file"
    nc_aggregate(f, fout; by, outdir, kw...)
  end
end


export nc_aggregate, nc_aggregate_dir
