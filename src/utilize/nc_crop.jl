"""
    $(TYPEDSIGNATURES)
"""
function nc_crop(f::String, range::Vector, fout::String;
  bands=nothing, 
  compress=true, overwrite=false, kw...)

  lon, lat = st_dims(f)
  ilon = findall(range[1] .<= lon .<= range[2]) |> _zip
  ilat = findall(range[3] .<= lat .<= range[4]) |> _zip

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
