# nctools in Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jl-spatial.github.io/nctools.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jl-spatial.github.io/nctools.jl/dev)
[![CI](https://github.com/jl-spatial/nctools.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/jl-spatial/nctools.jl/actions/workflows/CI.yml)
[![Codecov](https://codecov.io/gh/jl-spatial/nctools.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jl-spatial/nctools.jl)

> Dongdong Kong

# Installation

```
using Pkg
Pkg.add(url = "https://github.com/jl-spatial/nctools.jl")
```

# TODO

- add support for [Rasters.jl](https://github.com/rafaqz/Rasters.jl)
- update [Stars.jl](https://github.com/jl-spatial/Stars.jl)
- 学习julia写注释的方法
- 添加multi-files读取的支持，添加CMIP6数据截取和拼接函数

## Usage

> opendap下载选定区域: 只下载中国区域数据会小23倍，因此下载中国区域也会快23倍，最终1分钟即可下载好中国区域数据

```julia
range_global = [-180, 180, -90, 90] # 360*180
range_china  = [70, 140, 15, 55]    # 70*40
(180*360) / (70*40) ≈ 23
```

```julia
url = "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-18991231.nc"

fout = "out2.nc"
range = [70, 140, 15, 55]
delta = 5

@time nc_subset(url, range)
```
