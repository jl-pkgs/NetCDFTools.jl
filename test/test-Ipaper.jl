using Test, NetCDFTools, Ipaper

@testset "updateMask" begin
  A = array(1.0:16, (4, 4)) |> collect
  mask = A .> 10
  updateMask!(A, mask)
  length(findall(A .> 10)) == 6

  A = rand(4, 4, 2)
  mask = A[:, :, 1] .> 0.5
  updateMask!(A, mask)
  @test isempty(findall(A[:, :, 1] .<= 0.5))
end


@testset "split_chunk" begin
  @test split_chunk(1:10, 4; ratio_small=0.5) == [1:3, 4:6, 7:10]
  @test split_chunk(1:10, 4; ratio_small=0.0) == [1:3, 4:6, 7:9, 10:10]

  dates = make_date(2015, 1, 1):Day(1):make_date(2100, 12, 31) #|> collect
  lst = split_date(dates; ny_win=10, ratio_small=0.0)
  @test length(lst) == 9
  lst = split_date(dates; ny_win=10, ratio_small=0.7)
  @test length(lst) == 8
end
