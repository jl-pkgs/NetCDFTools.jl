function cdo_grid(ra::AbstractRaster; fout="grid.txt", kw...)
  x, y = st_dims(ra)
  cdo_grid(x, y; fout, kw...)
end



export cdo_grid, cdo_bilinear
