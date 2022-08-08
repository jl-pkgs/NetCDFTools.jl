using Ipaper
using nctools
using nctools.CMIP

scenarios = ["hist-aer", "hist-GHG", "hist-nat", "ssp245"] #%>% set_names(., .) # , "historical"
indir = "/share/Data/CMIP6/cmip6_hurs_day"
# dir(indir)

idir = "$indir/$(scenarios[1])"
fs = dir(idir)

info = CMIP.CMIPFiles_info(fs)
