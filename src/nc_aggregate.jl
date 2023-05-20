"""
  $(TYPEDSIGNATURES)
  
# Arguments
- `f`: input file
- `fout`: output file
- `by`: "year" or "month", or a function to group dates
"""
function nc_aggregate(f, fout=nothing; by="year", fun=nanmean,
  outdir=".", overwrite=false, verbose=true)
  
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
    compress=0, goal_attrib=Dict(nc.attrib))
  
  nc_close(nc)
end


export nc_aggregate
