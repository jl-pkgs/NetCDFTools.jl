include("main_spCluster.jl")
using SpatioTemporalCluster


ODIR = "/mnt/j/Researches/ChinaHW_cluster/Observed/ncell_16"
check_dir(ODIR)

## local grid info -------------------------------------------------------------
f_grid = "/mnt/i/Research/cmip6/CMIP6_ChinaHW_scripts/data-raw/China_025deg_FractionArea.csv"
d_coord = @pipe fread(f_grid) |> rename(_, :I => :gridId) |>
                select(_, :gridId, :area) |>
                transform!(_, :area => @f(Float32.(_x / 1e3)) => "area",
                    :gridId => @f(UInt16.(_x)) => "gridId") # convert area to 1e3 km^2
# ------------------------------------------------------------------------------
f_id = "$ODIR/clusterId_HItasmax_(1961-2016).nc"

nc = nc_open(f_id, "r")
# f_HI = "/mnt/i/Research/cmip6/heatwave/OUTPUT/Observed_HI_V2_Tmax-1961_2016.nc"
f_HI = nc.attrib["file_HI"]

dates = nc_date(f_id)


TRS = nc_read(f_id, "TRS")
arr_id = nc_read(f_id, "clusterId")
arr_HI = nc_read(f_HI; raw = true)

df = cluster2df_Observed(arr_id, arr_HI, TRS, dates)
df2 = dt_merge(df, d_coord, by = :gridId) # grids in China

@time info_temporal = statistic_temporal(df2)
@time info_spatial = statistic_spatial(df2)

# only select the grids in China
prefix = "clusterId_HItasmax_(1961-2016)"
@time fwrite(info_temporal, "$ODIR/char_temporal_$prefix.csv")
@time fwrite(info_spatial, "$ODIR/char_spatial_$prefix.csv")




## POST procedure --------------------------------------------------------------
# @pipe df2 |> 
#     subset(_, :year => ByRow(@f(x == 1961)) )
d = df2[(df2.year.==1961).&(df2.prob.==probs[1]), :]
fwrite(d, "clusterId_1961.csv")

d[d.anomaly.==0, :]
# pipe works
# Macronc_del_att
@pipe d |> _[_.anomaly.==0, :]

## Error results
id = 450
trs = TRS[:, :, 1, 1][id]
