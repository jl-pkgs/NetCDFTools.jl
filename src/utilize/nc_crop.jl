"""
    $(TYPEDSIGNATURES)
"""
function nc_crop(f::String, b::bbox, fout::String;
  bands=nothing, 
  compress=true, overwrite=false, kw...)

  lon, lat = st_dims(f)
  ilon = findall(b.xmin .<= lon .<= b.xmax) |> _zip
  ilat = findall(b.ymin .<= lat .<= b.ymax) |> _zip

  _dims = ncvar_dim(f)
  _dims["lon"] = _dims["lon"][ilon]
  _dims["lat"] = _dims["lat"][ilat]

  isnothing(bands) && (bands = nc_bands(f))
  for band in bands
    A = nc_read(f, band, ind=(ilon, ilat, :))
    nc_write!(fout, band, A, _dims; compress, overwrite, kw...)
  end
end


_zip(inds) = inds[1]:inds[end]

export nc_crop, _zip
