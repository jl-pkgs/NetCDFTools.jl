nc_open(file::String) = NCDataset(file)

nc_close(ds::NCDataset) = close(ds)

function nc_bands(ds::NCDataset) 
    # v_id = NCDatasets.nc_inq_varids(ds.ncid)
    # vars = NCDatasets.nc_inq_varname.(ds.ncid, v_id)
    vars = keys(ds)
    setdiff(vars, ["lon", "lat", "time", "time_bnds", "height"])
end

function nc_bands(file::String)
    NCDataset(file) do ds; nc_bands(ds); end 
end

function nc_info(ds::NCDataset) 
    vars = nc_bands(ds)[1]
    println(ds[vars])
end

function nc_info(file::String)
    println(basename(file))
    NCDataset(file) do ds; 
        nc_info(ds)
    end 
end

export nc_open, nc_close, 
    nc_bands, nc_date, nc_info
