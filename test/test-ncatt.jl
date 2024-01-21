@testset "ncatt_put" begin
  f = "/data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc" |> proj_path
  
  ncatt_put(f, Dict("Author" => "Dongdong Kong"))
  @test ncatt_get(f, "Author") == "Dongdong Kong"
  
  ncatt_get(f)
  ncatt_get([f, f])

  @test_nowarn ncatt_del(f, ["Author"])
end

