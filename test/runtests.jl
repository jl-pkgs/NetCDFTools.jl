using Test
using nctools
using nctools.Ipaper

# println(dirname(@__FILE__))
# println(pwd())

# cd(dirname(@__FILE__)) do
    include("test-nc_write.jl")
    include("test-Ipaper.jl")
    # include("test-smooth_whit.jl")
    # include("test-smooth_SG.jl")
    # include("test_wTSM.jl")
    # include("test_whittaker.jl")
    # include("test-lambda_init.jl")
# end
