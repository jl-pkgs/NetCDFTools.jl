using Dates
using Test

@testset "nc_date" begin
  f = "/data/HI_tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101.nc" |> proj_path
  dates = nc_date(f)
  @test eltype(dates) == DateTime
  @test length(dates) == 2
  @test nc_calendar(f) == "proleptic_gregorian"
end
