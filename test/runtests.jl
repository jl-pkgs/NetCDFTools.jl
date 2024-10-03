using Test
using NetCDFTools
using Ipaper, Dates

dir_root = dirname(dirname(@__FILE__))
proj_path(f) = dirname(dirname(@__FILE__)) * "/" *  f
# println(dirname(@__FILE__))
# println(pwd())
include("test-Ipaper.jl")
include("interp/test-weighted_nanmean.jl")
include("interp/test-angle.jl")
include("interp/test-spInterp.jl")
include("interp/test-bilinear.jl")

# cd(dirname(@__FILE__)) do
include("test-nc_date.jl")
include("test-utilize.jl")
include("test-ncatt.jl")
include("test-MFDataset.jl")
include("test-nc_write.jl")
include("test-nc_dims.jl")
include("test-CMIPFiles_info.jl")
# end
