"""
    $(TYPEDSIGNATURES)

# Arguments

- `band`  : string (variable name) or int (band id). If `int` provided, 
            `bandName = nc_bands(file)[band]`

- `type`  : returned data type, e.g. `Float32`

- `period`: `[year_start, year_end]` or `year`, time should be in the 3rd dimension.

- `ind`   : If `ind` provided, `period` will be ignored.

- `raw`   : Boolean. It `true`, not replace na values.

- `verbose`: Boolean. It `true`, `data` and `ind` will be printed on the console.
"""
function nc_read(file, band=1;
  type=nothing, period=nothing, ind=nothing, raw=false, verbose=false)

  ds = Dataset(path_mnt(file))
  bandName = get_bandName(file, band)
  # @time data = ds[bandName].var[:] # not replace na values at here
  data = raw ? ds[bandName].var : ds[bandName]

  if ind === nothing && period !== nothing
    if length(period) == 1
      period = repeat([period], 2)
    end
    # change NC into Raster
    dates = ds["time"]
    years = Dates.year.(dates)
    itime = (years .>= period[1] .&& years .<= period[2]) |> findall
    # `ind` is continuous, but reading speed is faster when converting to `unitRange`
    # https://alexander-barth.github.io/NCDatasets.jl/stable/performance/
    ind = (:, :, itime[1]:itime[end])
    # data = length(dates) != length(ind) ?  data[:, :, ind] : data
  end
  if ind === nothing
    ind = (:,)
  end
  verbose && @show(data, ind)

  data = data[ind...]
  close(ds)

  if type !== nothing && eltype(data) != type
    data = @.(type(data))
  end
  data
  # data = SharedArray(data)
end
