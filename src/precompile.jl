using PrecompileTools


@setup_workload begin
  fs = [
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-18991231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_19000101-19491231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_19500101-19991231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_20000101-20141231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/ScenarioMIP/CSIRO-ARCCSS/ACCESS-CM2/ssp126/r1i1p1f1/day/huss/gn/v20210317/huss_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_20150101-20641231.nc",
    "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/ScenarioMIP/CSIRO-ARCCSS/ACCESS-CM2/ssp126/r1i1p1f1/day/huss/gn/v20210317/huss_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_20650101-21001231.nc"
  ]
  
  
  @compile_workload begin 
    info = CMIP.CMIPFiles_info(fs; detailed=false)

    # compile bilinear
    for T in (Float64, Float32)
      lon = 70:5:140
      lat = 15:5:55
      
      Lon = 70:2.5:140
      Lat = 15:2.5:55
      Z = rand(T, length(lon), length(lat), 2)
      r = bilinear(lon, lat, Z, Lon, Lat; na_rm=true)
    end
  end
end

# precompile(CMIPFiles_info, (Vector{String},))
