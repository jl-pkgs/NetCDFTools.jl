# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module Ipaper

# Reexport
# @reexport using Z: x, y

using Dates
using Pipe
using LambdaFn

# rename to @f
@eval const $(Symbol("@f")) = $(Symbol("@λ"))
export @λ, @lf, @f


include("plyr.jl")
include("cmd.jl")
include("dates.jl")
include("file_operation.jl")
include("macro.jl")
include("par.jl")
include("stringr.jl")
include("tools.jl")
include("factor.jl")
include("data.frame.jl")
include("DimensionalData.jl")

dim = size
# whos = varinfo

using Printf
export @sprintf

export dim
export path_mnt, is_wsl, is_windows, is_linux, @pipe

end
