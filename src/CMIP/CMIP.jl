# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module CMIP

using DataFrames
# import nctools: nc_calendar | not work
using nctools
import nctools.Ipaper: dates_miss, dates_nmiss

include("CMIPFiles_info.jl")

# include("unit_convert.jl")
include("heat_index.jl")


export Tem_F2C, Tem_C2F, heat_index

end
