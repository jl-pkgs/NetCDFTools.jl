using Parameters
using DiskArrays: GridChunks
# using ProgressMeter

import Ipaper.sf: FileNetCDF, st_dims

function st_dims(x::FileNetCDF)
  nc_open(x.file) do nc
    lon = nc[r"lon|x$"][:]
    lat = nc[r"lat|y$"][:]
    lon, lat
  end
end


include("tools_Ipaper.jl")
include("struct_MFDataset.jl")

# include("tools_NCDatasets.jl")
# include("tools_Zarr.jl")
# include("mapslices_3d_chunk.jl")
# include("mapslices_3d_zarr.jl")
# include("mapslices_3d.jl")
# include("main_YAXArrays.jl")

export MFDataset, MFVariable, get_chunk
export findnear
export st_dims
