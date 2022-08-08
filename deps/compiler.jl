using PackageCompiler

pkg = "Ipaper"
PackageCompiler.create_sysimage([pkg]; sysimage_path="/opt/julia/lib$pkg.so",
                                       precompile_execution_file="init.jl")
