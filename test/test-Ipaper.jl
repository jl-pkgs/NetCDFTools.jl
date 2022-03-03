# The deference of : and !
# using nctools
# using nctools.Ipaper
# using Test

@testset "Ipaper cbind" begin
  probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
  levs = factor(probs)

  d = DataFrame(x = 1:40)
  names(d)

  d2 = cbind(d, prob = probs[1])
  @test names(d2) == ["x", "prob"]

  ## for data.frame melt_list
  res = []
  for i = 1:4
    push!(res, d)
  end
  df1 = melt_list(res, id = 1:4)
  df2 = melt_list(res)
  @test names(df2) == ["x", "prob", "id", "I"]
end


@testset "Ipaper factor" begin
  probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
  levs = factor(probs)

  n = Int(1e3)
  x = repeat([levs[1]], n)
  y = repeat([probs[1]], n)

  sizeof(x) < sizeof(y)
end


# using StatsBase
# x = 1:4 |> collect
# w = [1 1 0.5 0.5]

# weighted_mean(x, w)
# weighted_sum(x, w)
