module Ipaper

# Reexport
# @reexport using Z: x, y

using Dates
using Pipe
using LambdaFn

# rename to @f
@eval const $(Symbol("@f")) = $(Symbol("@λ"))
export @λ, @lf, @f


include("cmd.jl")
include("dates.jl")
include("file_operation.jl")
include("macro.jl")
include("par.jl")
include("stringr.jl")
include("tools.jl")
include("factor.jl")
include("data.frame.jl")

dim = size
# whos = varinfo

export dim
export path_mnt, is_wsl, is_windows, is_linux, @pipe

end
