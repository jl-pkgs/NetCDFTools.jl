@testset "CMIPFiles_info" begin
  fs = [
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-18991231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_19000101-19491231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_19500101-19991231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_20000101-20141231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/ScenarioMIP/CSIRO-ARCCSS/ACCESS-CM2/ssp126/r1i1p1f1/day/huss/gn/v20210317/huss_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_20150101-20641231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/ScenarioMIP/CSIRO-ARCCSS/ACCESS-CM2/ssp126/r1i1p1f1/day/huss/gn/v20210317/huss_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_20650101-21001231.nc"
  ]

  info = CMIP.CMIPFiles_info(fs; detailed=false)
  @test size(info, 1) == 6
  @test info.model[1] == "ACCESS-CM2"
  @test info.variable[1] == "huss"
  @test info.ensemble[1] == "r1i1p1f1_gn"
end
