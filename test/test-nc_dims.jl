@testset "nc_dims" begin
    f = "data/temp_HI.nc"
    # f = "temp_HI.nc"
    dims = nc_dims(f)
    @test names(dims) == ["lon", "lat", "time"]
end
# ds = nc_open(f)

@testset "ncatt_put" begin
    f = "data/temp_HI.nc"
    # f = "temp_HI.nc"
    # ds = nc_open(f)
    # close(ds)

    atts = Dict("a" => 1, "b" => 2)
    ncatt_put(f, atts)
    # nc_atts(f) == atts
    nc_info(f)

    ks = keys(atts) |> collect
    ncatt_del(f, ks)
    nc_info(f)
    # @test names(dims) == ["lon", "lat", "time"]
end
