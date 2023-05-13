"""
    get_model(file; prefix = "day_", postfix = "_hist|_ssp|_piControl")
"""
function get_model(file, prefix="day_", postfix="_hist|_ssp|_piControl")
  str_extract(basename(file), "(?<=$prefix).*(?=$postfix)")
end

function get_ensemble(file, pattern::AbstractString="(?<=_)r\\d.*(?=_\\d{4,8})")
  str_extract(basename(file), pattern)
end

function get_scenario(file, pattern::AbstractString="[a-z,A-Z,0-9,-]*(?=_r\\d)")
  str_extract(basename(file), pattern)
end

# get date_begin and date_end from the file name
function get_date(file::AbstractString, pattern::AbstractString="[0-9]{4,8}")
  str_extract_all(basename(file), pattern)
end

function get_date(files::Vector{<:AbstractString}, pattern::AbstractString="[0-9]{4,8}")
  dates = map(x -> get_date(x, pattern), files)
  date_begin = map(x -> x[1], dates)
  date_end = map(x -> x[2], dates)
  date_begin, date_end
end

function get_date_nmiss(file)
  dates = nc_date(file)
  dates_nmiss(dates)
end

function str_year(x::AbstractString)
  parse(Int, x[1:4])
end

"""
    CMIPFiles_info(files)
    
> Note: currently, only works for daily scale

# Return
- `model`:
- `ensemble`:
- `date_begin`, `date_end`:
- `file`:
"""
function CMIPFiles_info(files; detailed=false, include_nmiss=false)
  date_begin, date_end = get_date(files)

  info = DataFrame(;
    model=get_model.(files),
    ensemble=get_ensemble.(files),
    scenario=get_scenario.(files),
    date_begin, date_end,
    year_begin=str_year.(date_begin),
    year_end=str_year.(date_end))

  if detailed
    calender = nc_calendar.(files)
    cell_x, cell_y, regular = nc_cellsize(files)
    nmiss = include_nmiss ? get_date_nmiss.(files) : NaN

    info = cbind(
      info;
      calender,
      nmiss, # v0.1.2, low efficient
      cell_x, cell_y, grid_regular=regular
    )
  end
  cbind(info; file=files)
end


export get_model, get_ensemble, get_scenario, get_date, get_date_nmiss, CMIPFiles_info
