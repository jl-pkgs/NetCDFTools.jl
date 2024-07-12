"""
  nc_crop(f::String, range, fout::String; 
    compress=false, overwrite=false, kw...)

只有一个变量的情况。
"""
function nc_crop(f::String, range::Vector, fout::String; 
  compress=false, overwrite=false, kw...)

  lon, lat = st_dims(f)
  ilon = findall(range[1] .<= lon .<= range[2]) |> zip
  ilat = findall(range[3] .<= lat .<= range[4]) |> zip

  A = nc_read(f, ind=(ilon, ilat, :));
  var = nc_bands(f)[1]
  _dims = ncvar_dim(f)
  _dims["lon"] = _dims["lon"][ilon]
  _dims["lat"] = _dims["lat"][ilat]
  
  nc_write(fout, var, A, _dims; compress, overwrite, kw...)
end
