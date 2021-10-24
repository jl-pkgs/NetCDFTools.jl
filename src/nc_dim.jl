import StatsBase: mode


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
    NCDataset(file) do ds; nc_dims(ds); end
end

function nc_dimsize(file::String)
    NCDataset(file) do ds 
        var = nc_bands(ds)[1]    
        size(ds[var])
    end
end

"""
    nc_cellsize(ds::NCDataset)
"""
function nc_cellsize(ds::NCDataset)
    lon = ncdim_get(ds, "lon").vals |> diff 
    lat = ncdim_get(ds, "lat").vals |> diff
    
    cell_x = mode(lon)
    cell_y = mode(lat)
    regular = length(unique(lon)) == 1 && length(unique(lat)) == 1
    cell_x, cell_y, regular
end

function nc_cellsize(file::String)
    NCDataset(file) do ds; nc_cellsize(ds); end
end

function nc_cellsize(files::Vector{<:AbstractString})
    n = length(files)
    cell_x = zeros(n) 
    cell_y = zeros(n)
    regular = zeros(Bool, n)
    for i = 1:n
        cell_x[i], cell_y[i], regular[i] = nc_cellsize(files[i])
    end
    cell_x, cell_y, regular
end

export ncdim_get, nc_dims, nc_size, nc_cellsize
