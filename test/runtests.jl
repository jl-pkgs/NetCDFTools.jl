using Test
using NCTools
using Ipaper

# println(dirname(@__FILE__))
# println(pwd())

# cd(dirname(@__FILE__)) do
include("test-nc_write.jl")
include("test-nc_dims.jl")
include("test-bilinear.jl")
include("test-CMIPFiles_info.jl")
# end
