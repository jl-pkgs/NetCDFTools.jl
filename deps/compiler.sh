time julia compiler.jl

# add to vscode setting

# "julia.additionalArgs": [
#         "--sysimage",
#         "/opt/julia/libnctools.so"
#     ],
time julia --sysimage /opt/julia/libnctools.so init.jl
time julia init.jl
