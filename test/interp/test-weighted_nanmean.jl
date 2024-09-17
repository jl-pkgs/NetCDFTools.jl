using Test

@testset "weighted_nanmean" begin
  x = [1, 2, 3, NaN]
  w = [1, 2, 3, 3]
  mat = [x x x x]
  sol = 2.3333333333333335
  @test weighted_nanmean(x, w) == sol
  # weighted_nanmean([x x x], w; byrow=false) == [sol, sol, sol]
  weighted_nanmean(mat, w) # x
  @test_throws ArgumentError weighted_nanmean([x x x], w)
end
