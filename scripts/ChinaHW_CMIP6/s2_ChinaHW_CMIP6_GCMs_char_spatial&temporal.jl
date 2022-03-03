# using DataFrames
include("main_spCluster.jl")

function get_modelInfo(files)
  scenario = @. basename(dirname(files_id))
  model = get_model.(files_id; prefix = "TRS_", postfix = ".nc")
  DataFrame(I = 1:length(model), model = model, scenario = scenario, file = files)
end


## local grid info -------------------------------------------------------------
f = "/mnt/i/Research/cmip6/CMIP6_ChinaHW_scripts/data-raw/China_05deg_FractionArea.csv"
d_coord = @pipe fread(f) |> rename(_, :I => :gridId) |>
                select(_, :gridId, :area) |>
                transform!(_, :area => @f(Float32.(_x / 1e3)) => "area",
                  :gridId => @f(Int16.(_x)) => "gridId") # convert area to 1e3 km^2
# ------------------------------------------------------------------------------

files_id = dir("/mnt/g/Researches/CMIP6/CMIP6_ChinaHW_cluster/HItasmax/ncell_4", "nc\$", recursive = true)
files_anorm = dir("/mnt/g/Researches/CMIP6/CMIP6_ChinaHW_anomaly/HItasmax", "nc\$", recursive = true)

info_id = get_modelInfo(files_id)
info_anorm = get_modelInfo(files_anorm)

info = dt_merge(info_id, info_anorm; by = ["model", "scenario"])

ODIR = "/mnt/g/Researches/CMIP6/CMIP6_ChinaHW_char_V2"
check_dir(ODIR)

@time for i in 1:nrow(info)
  prefix = "HItasmax_movTRS_$(info[i, :scenario])_$(info[i, :model])"
  println("[i = $i]: $prefix")

  f_id = info[i, "file"]
  f_anorm = info[i, "file_1"] # the second

  arr_id = Int32.(nc_read(f_id; raw = true))
  arr_anorm = nc_read(f_anorm; raw = true)

  include("main_spCluster.jl")
  df = cluster2df_GCM(arr_id, arr_anorm)

  # only select the grids in China
  df2 = dt_merge(df, d_coord, by = :gridId)

  @time info_temporal = statistic_temporal(df2)
  @time info_spatial = statistic_spatial(df2)

  @time fwrite(info_temporal, "$ODIR/char_temporal/char_temporal_$prefix.csv")
  @time fwrite(info_spatial, "$ODIR/char_spatial/char_spatial_$prefix.csv")
end

# variable = "HItasmax"
# files = dir("/mnt/k/Researches/CMIP6/CMIP6_ChinaHW_mergedFiles/$variable", ".nc\$", recursive = true)
# d = CMIPFiles_info(files)

f_id = "/mnt/g/Researches/CMIP6/CMIP6_ChinaHW_cluster/HItasmax/ncell_4/historical/clusterId_HItasmax_movTRS_ACCESS-CM2.nc"
f_anorm = "/mnt/g/Researches/CMIP6/CMIP6_ChinaHW_anomaly/HItasmax/historical/anomaly_HItasmax_movTRS_ACCESS-CM2.nc"
