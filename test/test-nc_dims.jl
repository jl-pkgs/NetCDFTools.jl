@testset "nc_dims" begin
    f = "data/temp_HI.nc"
    # f = "temp_HI.nc"
    dims = nc_dims(f)
    @test names(dims) == ["lon", "lat", "time"]
end
# ds = nc_open(f)
