module nctools

using NCDatasets
using NetCDF
using CFTime
using Dates

include("nc_dim.jl")
include("nc_info.jl")
include("nc_date.jl")
include("nc_read.jl")
include("nc_write.jl")

# CMIP
include("Ipaper/Ipaper.jl")
include("CMIP/CMIP.jl")

export nc_open, nc_close, nc_bands, nc_date, nc_info
export nc_dim, nc_dims, nc_size, nc_cellsize
export nc_read, nc_write
export nc_date, nc_calendar

end # module
