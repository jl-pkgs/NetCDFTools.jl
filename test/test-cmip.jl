# using SpatioTemporalCluster
# using SpatioTemporalCluster.Ipaper

# using DataFrames
using nctools
using nctools.CMIP
using nctools.Ipaper

# using Dates
# using CFTime

variable = "HItasmax"
files = dir("/mnt/k/Researches/CMIP6/CMIP6_ChinaHW_mergedFiles/$variable", ".nc\$", recursive = true)
d = CMIPFiles_info(files)

# suggest using match2 to find the matched model
m1 = d[d.scenario.=="historical", :model]
m2 = d[d.scenario.=="ssp126", :model]

match2(m2, m1)
