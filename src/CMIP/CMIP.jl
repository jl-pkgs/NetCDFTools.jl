# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module CMIP

using nctools
# import nctools: nc_calendar | not work
using DataFrames: DataFrame, AbstractDataFrame
import Ipaper: str_extract, str_extract_all,
  dates_miss, dates_nmiss



# by reference
function cbind(x::AbstractDataFrame; kw...)
  # x = as_dataframe(x)
  n = length(kw)
  if n > 0
    vars = keys(kw)
    for i = 1:n
      key = vars[i]
      val = kw[i]
      if !isa(val, AbstractArray) || length(val) == 1
        x[:, key] .= val
      else
        x[:, key] = val
      end
    end
  end
  x
  # if length(args) == 0
  #   x
  # elseif length(args) == 1
  #   cbind(x, args[1])
  # else
  #   cbind(cbind(x, args[1]), args[2:end]...)
  # end
end

include("CMIPFiles_info.jl")
include("q2RH.jl")
include("heat_index.jl")
# include("unit_convert.jl")


export Tem_F2C, Tem_C2F, q2RH
export heat_index, heat_index_q

end
