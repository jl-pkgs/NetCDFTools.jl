using Pkg
Pkg.activate(@__DIR__)
CI = get(ENV, "CI", nothing) == "true"
using Documenter, NCTools

makedocs(modules=[NCTools], sitename="NCTools.jl")

makedocs(modules=[NCTools],
  sitename="NCTools.jl",
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
  deploydocs(repo="github.com/CUG-hydro/NCTools.jl.git",
    target="build")
end
