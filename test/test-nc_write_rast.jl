using NetCDFTools, Dates, Test

b = bbox(70, 15, 140, 55)
A = rand(70, 40, 4)
B = rand(70, 40, 4)
dates = Date(2010):Day(1):Date(2010, 1, 4) |> collect
ra = rast(A, b; time=dates, name="tasmax")


@testset "nc_write! for Tuple and SpatRast" begin
  nc_write!("a.nc", ra;
    attr=Dict("units" => "K", "long_name" => "temperature"),
    overwrite=true)

  _dims = NcDims(ra)
  data = (; a=A, b=A)
  data2 = (; a=B, b=B)

  nc_write!("b.nc", data, _dims)
  nc_write!("b.nc", data2, _dims, overwrite=true)
  @test nc_read("b.nc", "a") == B
  @test nc_read("b.nc", "a") !== A

  rm.(["a.nc", "b.nc"])
end

@testset "nc_write attrib" begin
  ## check attrib
  function check_unit(f)
    nc_open(f) do nc
      @test nc["tasmax"].attrib["units"] == "K"
    end
  end

  nc_write!("t1.nc", ra,
    attr=Dict("units" => "K", "long_name" => "temperature"), overwrite=true)
  check_unit("t1.nc")

  nc_write!("t1.nc", ra,
    attr=Dict("units" => "K", "long_name" => "temperature"),
    overwrite=true)
  check_unit("t1.nc")
  rm("t1.nc")
end
