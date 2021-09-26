using nctools
using NCDatasets

rh = rand(3, 3, 10) * 100
tair = rand(3, 3, 10)

heat_index(tair, rh)
