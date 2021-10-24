nc_date(ds::NCDataset) = ds["time"][:]

function nc_date(file::AbstractString)
    NCDataset(file) do ds;
        nc_date(ds)
    end
end

function nc_calendar(file::AbstractString)
    NCDataset(file) do ds;
        # typeof(ds["time"][1])
        ds["time"].attrib["calendar"]
    end
end

