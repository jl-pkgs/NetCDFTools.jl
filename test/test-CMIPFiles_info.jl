using nctools
# using Glob
# using NCDatasets
# using CFTime

# rh = rand(3, 3, 10) * 100
# tair = rand(3, 3, 10)
# heat_index(tair, rh)

# GFDL-CM4, r1i1p1f1_gr2, 2.5, 2.0 
# GFDL-CM4, r1i1p1f1_gr1, 1.25, 1.0 

# files = glob("k:/Researches/CMIP6/CMIP6_ChinaHW_mergedFiles/HItasmax/historical/*.nc")
# d = CMIPFiles_info(files)
# files = glob("k:/Researches/CMIP6/CMIP6_ChinaHW_mergedFiles/HItasmax/historical/")
# dir_prj  = "$pan/Researches/CMIP6/ChinaHW_cluster"

pan = path_mnt("K:")
dir_data = "$pan/Researches/CMIP6/CMIP6_ChinaHW_mergedFiles"

dirs = dir(dir_data)
files = dir(dirs[1], "nc", recursive = true)
d = CMIPFiles_info(files)

# file = files[1]
# fid = nc_open(file)
