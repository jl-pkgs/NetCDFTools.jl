@testset "ncattr_put" begin
  f = "/data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc" |> proj_path
  
  ncattr_put(f, Dict("Author" => "Dongdong Kong"))
  @test ncattr_get(f, "Author") == "Dongdong Kong"
  
  ncattr_get(f)
  ncattr_get([f, f])

  @test_nowarn ncattr_del(f, ["Author"])
end

