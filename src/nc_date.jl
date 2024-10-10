nc_date(ds::NCdata) = ds["time"][:]

function nc_date(file::AbstractString; period=nothing)
  nc_open(file) do ds
    dates = nc_date(ds)
    period === nothing && return dates

    inds = period[1] .<= year.(dates) .<= period[2]
    return dates[inds]
  end
end

function nc_date(fs::Vector{<:AbstractString}; period=nothing)
  map(f -> nc_date(f; period), fs) |> x -> vcat(x...)
end

function nc_calendar(file::AbstractString)
  nc_open(file) do ds
    # typeof(ds["time"][1])
    ds["time"].attrib["calendar"]
  end
end
