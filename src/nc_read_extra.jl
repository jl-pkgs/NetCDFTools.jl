using Distributed
using Ipaper: abind

export nc_read_par
export nc_read_all
# addprocs(4)
# rmprocs.(2:5)
# procs()

function nc_read_par(fs, args...; kw...)
  lst = pmap(f -> nc_read(f, args...; kw...), fs)
  abind(lst, increase=false)
end

function nc_read_all(f; bands=nc_bands(f), kw...)
  vals = map(band -> nc_read(f, band; kw...), bands)
  # make sure `bands` is Symbol
  NamedTuple{Tuple(Symbol.(bands))}(vals)
end
