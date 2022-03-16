module CMIP

using DataFrames
# import nctools: nc_calendar | not work
using nctools
import nctools.Ipaper: dates_miss, dates_nmiss

include("CMIPFiles_info.jl")

include("unit_convert.jl")
include("heat_index.jl")


export Tem_F2C, Tem_C2F, heat_index

end
