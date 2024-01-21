@testset "nc_dims" begin
    f = "data/temp_HI.nc"
    dims = nc_dims(f)
    @test names(dims) == ["lon", "lat", "time"]
end

@testset "ncatt_put" begin
    f = "data/temp_HI.nc"

    atts = Dict("a" => 1, "b" => 2)
    ncatt_put(f, atts)
    # nc_atts(f) == atts
    nc_info(f)

    ks = keys(atts) |> collect
    ncatt_del(f, ks)
    nc_info(f)
    # @test names(dims) == ["lon", "lat", "time"]
end


## test for dim
@testset "ncvar_dim" begin
  f = "/data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc" |> proj_path
  dims = ncvar_dim(f)
  @test names(dims) == ["x", "y", "time"]
  @test dims[["x", "y"]] == dims[1:2]
  
  ds = nc_open(f)

  @test_nowarn nc_dim(ds, r"lon|x")
  @test_nowarn nc_dim(ds, "x")
  nc_close(ds)

  @test nc_cellsize(f) == (1.875, 1.875, true)
  @test nc_cellsize([f, f]) == ([1.875, 1.875], [1.875, 1.875], Bool[1, 1])
end
