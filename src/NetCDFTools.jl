# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.
module NetCDFTools

export NcDim

using NCDatasets
import NCDatasets: @select, NCDataset

using ProgressMeter
using CFTime
using Dates

using Reexport
using DocStringExtensions
# using DocStringExtensions: TYPEDFIELDS, TYPEDEF
import DataFrames: AbstractDataFrame, GroupedDataFrame

# include("Ipaper/Ipaper.jl")
using Ipaper
@reexport using Ipaper.sf

export exact_extract, coverage_fraction

function exact_extract end
function coverage_fraction end

include("NCDataset.jl")

include("tools.jl")
include("nc_info.jl")
include("nc_dim.jl")
include("nc_date.jl")
include("nc_read.jl")
include("nc_read_extra.jl")
include("nc_write.jl")
include("ncsave.jl")

include("ncvar_def.jl")
include("ncdim_def.jl")
include("ncatt_put.jl")

include("utilize/utilize.jl")

include("MFDataset/MFDataset.jl")
# CMIP
include("CMIP/CMIP.jl")
include("Interpolation/Interpolation.jl")
include("BiasCorrection/BiasCorrection.jl")

include("precompile.jl")


export CMIP
export @select
export nc_open, nc_close, close
export nc_bands, get_bandName, nc_info, ncinfo, ncvar_info
export nc_dim, nc_dims, ncvar_dim, nc_size, nc_cellsize
export nc_read, nc_write, nc_write!
export nc_date, nc_calendar
export nc_subset

export NcDim_time
export ncdim_def, ncvar_def
export ncatt_put, ncatt_get, ncatt_del

export names

end # module
