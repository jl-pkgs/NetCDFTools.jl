module nctools

# using NetCDF
export NcDim

using NCDatasets
export nc_open, close

using CFTime
using Dates

include("Ipaper/Ipaper.jl")
using nctools.Ipaper

include("nc_dim.jl")
include("nc_info.jl")
include("nc_date.jl")
include("nc_read.jl")
include("nc_write.jl")
include("ncvar_def.jl")
include("ncdim_def.jl")

# CMIP
include("CMIP/CMIP.jl")

export nc_open, nc_close, nc_bands, nc_date, nc_info, ncinfo
export nc_dim, nc_dims, nc_size, nc_cellsize
export nc_read, nc_write, nc_write!
export nc_date, nc_calendar

export names

end # module
