using PackageCompiler

PackageCompiler.create_sysimage(["nctools"]; sysimage_path="/opt/julia/libnctools.so",
                                       precompile_execution_file="init.jl")
