# NetCDFTools.jl

Documentation for NetCDFTools.jl, a Julia package for loading/writing NetCDF data on 
the top of `NCDatasets.jl`.

## Installation

Inside the Julia shell, you can download and install using the following commands:

```julia
using Pkg
Pkg.add("NetCDFTools")
```

```@docs
nc_open
nc_cellsize

Base.getindex

NetCDFTools.NcDim
NetCDFTools.ncdim_def
NetCDFTools.make_dims

ncvar_def
ncatt_put
```

```@docs
nc_read
nc_write
nc_write!
```


## Utilities

```@docs
QDM
bilinear

nc_aggregate
nc_aggregate_dir

nc_combine
nc_subset
```


## CMIP functions

```@docs
CMIP.Tem_F2C
CMIP.heat_index

CMIP.get_model
CMIP.CMIPFiles_info
```
