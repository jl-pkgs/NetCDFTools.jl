using Test
using NetCDFTools
# using Terra

## 数据保存没有问题，可能是读取的时候出现了bug
# ra = Raster(f) |> edge2center
dir_root = dirname(dirname(@__FILE__))
indir = "$dir_root/data/nc"

fs = [
  "$indir/test1-01.nc",
  "$indir/test1-02.nc",
  "$indir/test1-03.nc",
  "$indir/test1-04.nc"
]
f = fs[1]# coord存在明显的错误

@testset "MFDataset" begin
  _chunkszie = (5, 5, typemax(Int))
  m = MFDataset(fs, _chunkszie)

  @test m.bbox == st_bbox(f)
  @test m.ntime == 20
  @test size(m.chunks) == (2, 2, 1)

  @test_nowarn print(m)
  @test size(m[:LAI][:, :]) == (10, 10, 20)
end
