using Parameters
import NCDatasets.DiskArrays: GridChunks
# using ProgressMeter

import Ipaper.sf: FileNetCDF, st_dims
import Ipaper: Progress

function st_dims(x::FileNetCDF)
  nc_open(x.file) do nc
    lon = nc[r"lon|x$"][:]
    lat = nc[r"lat|y$"][:]
    lon, lat
  end
end


include("struct_MFDataset.jl")


function nc_date(m::MFDataset)
  dates = map(f -> nc_date(f), m.fs)
  cat(dates..., dims=1)
end

# include("tools_NCDatasets.jl")
# include("tools_Zarr.jl")
# include("mapslices_3d_chunk.jl")
# include("mapslices_3d_zarr.jl")
# include("mapslices_3d.jl")
# include("main_YAXArrays.jl")

export MFDataset, MFVariable, get_chunk, GridChunks
export st_dims
