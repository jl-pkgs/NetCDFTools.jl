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

