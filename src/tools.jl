# https://github.com/pacificclimate/ClimDown/blob/master/R/QDM.R
# mk.factor.set
"""
    split_chunk(n::Int, nchunk=4; chunk=nothing, ratio_small::Real=0.5)

# Arguments
- `ratio_small`: The minimum ratio of the last chunk to the maximum length of chunks.
如果最后一个块的小于该比例，则将最后两个块合并。
"""
function split_chunk(n::Int, nchunk=4; chunk=nothing, ratio_small::Real=0.0)
  if chunk === nothing
    chunk = cld(n, nchunk)
  else
    nchunk = cld(n, chunk)
  end

  lst = map(i -> begin
      i_beg = (i - 1) * chunk + 1
      i_end = min(i * chunk, n)
      i_beg:i_end
    end, 1:nchunk)

  lens = map(length, lst)
  nmin = ratio_small * chunk

  if lens[end] < nmin
    i_beg = lst[end-1][1]
    i_end = lst[end][end]
    lst[end-1] = i_beg:i_end
    deleteat!(lst, nchunk)
  end
  lst
end

function split_chunk(x::Union{UnitRange,AbstractVector}, nchunk=4; kw...)
  lst = split_chunk(length(x), nchunk; kw...)
  map(i -> x[i], lst)
end

# dates = make_date(2015, 1, 1):Day(1):make_date(2100, 12, 31) |> collect
# - chunk: nyear
function split_date(dates; ny_win=10, kw...)
  years = year.(dates)
  grps = unique_sort(years)
  lst = split_chunk(grps; chunk=ny_win, kw...)

  lst_index = map(grp -> begin
      findall(indexin(years, grp) .!== nothing)
    end, lst)
  lst_index
end

export split_chunk, split_date
