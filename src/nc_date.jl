nc_date(ds::NCdata) = ds["time"][:]

function nc_date(file::NCfiles)
    nc_open(file) do ds
        nc_date(ds)
    end
end

function nc_calendar(file::AbstractString)
    nc_open(file) do ds
        # typeof(ds["time"][1])
        ds["time"].attrib["calendar"]
    end
end
