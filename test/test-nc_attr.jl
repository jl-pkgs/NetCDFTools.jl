@testset "nc_attr!" begin
  f = "/data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc" |> proj_path
  
  nc_attr!(f, Dict("Author" => "Dongdong Kong"))
  @test nc_attr(f, "Author") == "Dongdong Kong"
  
  nc_attr(f)
  nc_attr([f, f])

  @test_nowarn nc_attr_rm!(f, ["Author"])
end
