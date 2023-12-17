function nc_read_all(f; bands=nc_bands(f), kw...)
  vals = map(band -> nc_read(f, band; kw...), bands)
  # make sure `bands` is Symbol
  NamedTuple{Tuple(Symbol.(bands))}(vals)
end

export nc_read_all
