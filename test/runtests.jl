using Test
using NetCDFTools
using Ipaper, Dates, Test

dir_root = dirname(dirname(@__FILE__))
proj_path(f) = dirname(dirname(@__FILE__)) * "/" *  f
# println(dirname(@__FILE__))
# println(pwd())
include("utilize/test-utilize.jl")
include("test-Ipaper.jl")
include("interp/test-weighted_nanmean.jl")
include("interp/test-angle.jl")
include("interp/test-spInterp.jl")
include("interp/test-bilinear.jl")

# cd(dirname(@__FILE__)) do
include("test-nc_date.jl")
include("test-ncatt.jl")
include("test-MFDataset.jl")
include("test-nc_write.jl")
include("test-nc_write_rast.jl")
include("test-ncsave.jl")

include("test-nc_dims.jl")
include("test-CMIPFiles_info.jl")
# end
