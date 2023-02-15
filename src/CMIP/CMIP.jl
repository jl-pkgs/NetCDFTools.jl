# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module CMIP

using nctools
# import nctools: nc_calendar | not work
using DataFrames: DataFrame
import Ipaper: str_extract, str_extract_all,
  dates_miss, dates_nmiss,
  dt_merge

include("CMIPFiles_info.jl")
include("heat_index.jl")
include("q2RH.jl")
# include("unit_convert.jl")


export Tem_F2C, Tem_C2F, heat_index
export q2RH, heat_index_q

end
