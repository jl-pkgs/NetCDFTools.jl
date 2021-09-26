nc_date(ds::NCDataset) = ds["time"][:]

function nc_date(file::String)
    NCDataset(file) do ds;
        nc_date(ds)
    end
end
