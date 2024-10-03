using NetCDFTools, Ipaper, Test

@testset "nc_combine" begin
  fs = dir(proj_path("data/nc/"))
  fout = "combine.nc"
  @test_nowarn nc_combine(fs, fout)
  isfile(fout) && rm(fout)
end

@testset "nc_subset" begin
  f = dir(proj_path("data/nc/"))[1]
  fout = "subset.nc"
  @test_nowarn nc_subset(f, [100, 120, 20, 40], fout)
  isfile(fout) && rm(fout)
end


@testset "nc_agg" begin
  dates = Date(2010):Day(1):Date(2010, 12, 31) |> collect
  ntime = length(dates)
  b = bbox(70, 15, 140, 55)
  A = rand(70, 40, ntime)
  ra = rast(A, b; time=dates, name="tasmax")
  obj_size(A)
  nc_write!("test.nc", ra)

  # test `nc_agg`
  nc_agg("test.nc", "test_year.nc"; by="year", fun=mean,
    outdir=".", overwrite=true, verbose=true)
  nc_agg("test.nc", "test_mon.nc"; by="month", fun=mean,
    outdir=".", overwrite=true, verbose=true)
  @test nc_date("test_year.nc") == [DateTime(2010)]
  @test nc_date("test_mon.nc") == collect(DateTime.(2010, 1:12))

  # test `nc_crop`
  b2 = bbox(80, 15, 90, 30)
  nc_crop("test.nc", b2, "test_crop.nc")
  st_bbox("test_crop.nc") == b2

  rm.(["test.nc", "test_year.nc", "test_mon.nc", "test_crop.nc"])
end
