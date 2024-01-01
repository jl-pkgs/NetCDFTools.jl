# NetCDFTools in Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jl-pkgs.github.io/NetCDFTools.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jl-pkgs.github.io/NetCDFTools.jl/dev)
[![CI](https://github.com/jl-pkgs/NetCDFTools.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/jl-pkgs/NetCDFTools.jl/actions/workflows/CI.yml)
[![Codecov](https://codecov.io/gh/jl-pkgs/NetCDFTools.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jl-pkgs/NetCDFTools.jl)

> Dongdong Kong, CUG

# Installation

```
using Pkg
Pkg.add(url = "https://github.com/jl-pkgs/NetCDFTools.jl")
```

## Usage

- [x] 检索CMIP6数据，获取下载url

- [x] OpenDAP下载CMIP6数据

- [x] CMIP6 `QMD`偏差矫正

- [x] CMIP6 `bilinear`双线性插值

- [x] nc文件拼接、聚合（一些仿cdo的函数，nc_combine, nc_subset, nc_aggregate）

- [x] nc文件处理
