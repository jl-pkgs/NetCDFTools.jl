using Test, NetCDFTools


# @testset "ncsave" 
begin
  f = "test.nc"
  dims = (; x=1:10, y=1:10)
  ncsave(f, true; dims, SM2=rand(10, 10), SPI=rand(Float32, 10, 10))

  # overwrite
  ncsave(f, true, (; overwrite=true);
    dims, SM=rand(10, 10), SPI=rand(Float64, 10, 10))

  dims = (; x=1:10, y=1:10, z=1:10)
  ncsave(f; dims, SM3=rand(10, 10, 10))

  SM2 = nc_read(f, "SM2")
  SM3 = nc_read(f, "SM3")
  SPI = nc_read(f, "SPI")
  @test size(SM2) == (10, 10)
  @test size(SM3) == (10, 10, 10)
  @test eltype(SPI) == Float32
  @test eltype(SM3) == Float64
  # isfile(f) && rm(f)
end

f = "test3.nc"
n = 1000
dims = (; x=1:n, y=1:n, z=1:10)
values = (; SM2=rand(n, n, 10), SPI=rand(Float32, n, n, 10))
values = Dict(:SM2 => rand(n, n, 10), :SPI => rand(Float32, n, n, 10))

@time ncsave(f, false; dims, values);

rm(f)
