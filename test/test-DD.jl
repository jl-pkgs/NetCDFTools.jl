using nctools.Ipaper
using Statistics

arr = rand(200, 200, 365);
d = DimArray(arr, ["lon", "lat", "time"]);
probs = [0.5, 0.9];
Quantile(d, probs; dims = :time)
# mapslices(x -> quantile(x, probs), d, dims = 3)
