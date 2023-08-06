# NCTools.jl

Documentation for NCTools.jl, a Julia package for loading/writing NetCDF data on 
the top of `NCDatasets.jl`.

## Installation

Inside the Julia shell, you can download and install using the following commands:

```julia
using Pkg
Pkg.add("NCTools")
```

```@docs
nc_info
ncdim_def
ncvar_def
```

```docs
nc_read
nc_write
```

## Utilities

```@docs
nc_aggregate
nc_combine
nc_subset
```
