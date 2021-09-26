
function ncdim_get(ds::NCDataset, name = "time") 
    x = ds[name]
    NcDim(name, x.var[:], Dict(x.attrib))
end

function ncdim_get(file::String, name = "time") 
    NCDataset(file) do ds; 
        ncdim_get(ds, name)
    end
end

function nc_dims(ds::NCDataset)
    lon = ncdim_get(ds, "lon")
    lat = ncdim_get(ds, "lat")
    time = ncdim_get(ds, "time")
    # Dict("lon" => lon, "lat" => lat, "time" => time)
    [lon, lat, time]
end

function nc_dims(file::String)
    NCDataset(file) do ds; 
        nc_dims(ds)
    end
end

export ncdim_get, nc_dims
