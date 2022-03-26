# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module nctools

# using NetCDF
export NcDim

using NCDatasets
export nc_open, close

using CFTime
using Dates

# include("Ipaper/Ipaper.jl")
using Ipaper
export Ipaper

include("nc_info.jl")
include("nc_dim.jl")
include("nc_date.jl")
include("nc_read.jl")
include("nc_write.jl")
include("ncvar_def.jl")
include("ncdim_def.jl")
include("ncatt_put.jl")

# CMIP
include("CMIP/CMIP.jl")
export CMIP


export nc_open, nc_close, nc_bands, nc_date, nc_info, ncinfo
export nc_dim, nc_dims, ncvar_dim, nc_size, nc_cellsize
export nc_read, nc_write, nc_write!
export nc_date, nc_calendar

export ncdim_def, ncvar_def
export ncatt_put, ncatt_get, ncatt_del

export names

end # module
