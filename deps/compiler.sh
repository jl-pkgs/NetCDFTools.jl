time julia compiler.jl

# add to vscode setting

# "julia.additionalArgs": [
#         "--sysimage",
#         "/opt/julia/libNCTools.so"
#     ],
time julia --sysimage /opt/julia/libIpaper.so init.jl
time julia init.jl
