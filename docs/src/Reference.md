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

ncvar_def
nc_attr!
```

```@docs
nc_read
nc_write
nc_write!

ncsave
```


## Utilities

```@docs
QDM

nc_agg 
nc_agg_dir

nc_combine
nc_subset
nc_crop
```

```@docs
split_chunk
```

## Interpolation

```@docs
spInterp
bilinear
weight_idw
```

```@docs
earth_dist
angle_azimuth_sphere
```

## CMIP functions

```@docs
CMIP.Tem_F2C
CMIP.heat_index

CMIP.get_model
CMIP.CMIPFiles_info
```

## MFDataset

```@docs
MFDataset
```
