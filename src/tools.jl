# https://github.com/pacificclimate/ClimDown/blob/master/R/QDM.R
# mk.factor.set
function split_chunk(n::Int, nchunk=4; chunk = nothing, merge_small=0.5)
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
  len_max = maximum(lens)

  if lens[end] < merge_small * len_max
    i_beg = lst[end-1][1]
    i_end = lst[end][end]
    lst[end-1] = i_beg:i_end
    deleteat!(lst, nchunk)
  end
  lst
end

function split_chunk(x::Union{UnitRange, AbstractVector}, nchunk=4; kw...)
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
