#! time julia --sysimage /opt/julia/libIpaper.so init.jl
using Ipaper
# using nctools
# using Plots

dir(".")
d = fread("temp.csv")
