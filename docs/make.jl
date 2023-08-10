# using Pkg
# Pkg.activate(@__DIR__)
CI = get(ENV, "CI", nothing) == "true"
using Documenter, NetCDFTools

makedocs(modules=[NetCDFTools], sitename="NetCDFTools.jl")

makedocs(modules=[NetCDFTools],
  sitename="NetCDFTools.jl",
  doctest=false,
  format=Documenter.HTML(
    prettyurls=CI,
  ),
  pages=[
    "Introduction" => "index.md",
    # "Datasets" => "dataset.md",
    # "Dimensions" => "dimensions.md",
    # "Variables" => "variables.md",
    # "Attributes" => "attributes.md",
    # "Performance tips" => "performance.md",
    # "Known issues" => "issues.md",
    # "Experimental features" => "experimental.md",

  ],
)

if CI
  deploydocs(repo="github.com/jl-spatial/NetCDFTools.jl.git",
    target="build")
end
