using Test
using NetCDFTools
using Ipaper

dir_root = dirname(dirname(@__FILE__))
proj_path(f) = dirname(dirname(@__FILE__)) * "/" *  f
# println(dirname(@__FILE__))
# println(pwd())

# cd(dirname(@__FILE__)) do
include("test-ncatt.jl")
include("test-bilinear.jl")
include("test-MFDataset.jl")
include("test-nc_write.jl")
include("test-nc_dims.jl")
include("test-CMIPFiles_info.jl")
# end
