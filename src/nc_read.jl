# - return: data with the dimension of `[lon, lat, ntime]`
function nc_read(file; band = nothing, period = nothing, raw = false)
    ds = Dataset(file)
    dates = ds["time"]
    if band === nothing; band = nc_bands(file)[1]; end

    # @time data = ds[band].var[:] # not replace na values at here
    data = raw ? ds[band].var : ds[band]
    @time if period === nothing
        data = data[:]
    else
        # https://alexander-barth.github.io/NCDatasets.jl/stable/performance/
        # convert index to unitRange
        ind = (Dates.year.(dates) .<= year_end) |> findall
        ind = ind[1]:ind[end]
        data = data[:, :, ind]
        # data = length(dates) != length(ind) ?  data[:, :, ind] : data
    end
    close(ds)
    data
    # data = SharedArray(data)
end

