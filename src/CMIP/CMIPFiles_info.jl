"""
    get_model(file; prefix = "day_", postfix = "_hist|_ssp|_piControl")
"""
function get_model(file, prefix="day_", postfix="_hist|_ssp|_piControl")
  str_extract(basename(file), "(?<=$prefix).*(?=$postfix)") #|> String
end

function get_variable(file, pattern::AbstractString="[a-zA-Z0-9]*")
  str_extract(basename(file), pattern) #|> String
end

function get_ensemble(file, pattern::AbstractString="(?<=_)r\\d.*(?=_\\d{4,8})")
  str_extract(basename(file), pattern)
end

function get_scenario(file, pattern::AbstractString="[a-z,A-Z,0-9,-]*(?=_r\\d)")
  str_extract(basename(file), pattern)
end

get_host(x::AbstractString) = str_extract(x, "(?<=://)[^\\/]*")

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

is_ssp(x::AbstractString) = x[1:3] == "ssp"

is_r1i1p1f1(x::AbstractString) = x[1:8] == "r1i1p1f1"

"""
  $(TYPEDSIGNATURES)

> Note: currently, only works for daily scale

# Return
- `model`:
- `ensemble`:
- `date_begin`, `date_end`:
- `file`:

$(METHODLIST)

# Example
```julia
fs = [
  "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_18500101-18991231.nc",
  "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_19000101-19491231.nc",
  "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_19500101-19991231.nc",
  "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/CMIP/CSIRO-ARCCSS/ACCESS-CM2/historical/r1i1p1f1/day/huss/gn/v20191108/huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_20000101-20141231.nc",
  "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/ScenarioMIP/CSIRO-ARCCSS/ACCESS-CM2/ssp126/r1i1p1f1/day/huss/gn/v20210317/huss_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_20150101-20641231.nc",
  "http://esgf-data04.diasjp.net/thredds/dodsC/esg_dataroot/CMIP6/ScenarioMIP/CSIRO-ARCCSS/ACCESS-CM2/ssp126/r1i1p1f1/day/huss/gn/v20210317/huss_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_20650101-21001231.nc"
]
info = CMIP.CMIPFiles_info(fs; detailed=false)
```
"""
function CMIPFiles_info(files; detailed=false, include_year=false, include_nmiss=false)
  date_begin, date_end = get_date(files)

  info = DataFrame(;
    variable=get_variable.(files),
    model=get_model.(files),
    ensemble=get_ensemble.(files),
    scenario=get_scenario.(files),
    date_begin, date_end)
  
  if include_year
    cbind(info; 
      year_begin=str_year.(date_begin), 
      year_end=str_year.(date_end))
  end
  
  if detailed
    calender = nc_calendar.(files)
    cell_x, cell_y, regular = nc_cellsize(files)
    nmiss = include_nmiss ? get_date_nmiss.(files) : NaN

    cbind(
      info;
      calender,
      nmiss, # v0.1.2, low efficient
      cell_x, cell_y, grid_regular=regular
    )
  end
  cbind(info; file=files)
end


function CMIPFiles_summary(info::AbstractDataFrame)
  by = intersect(["variable", "model", "ensemble", "scenario"], names(info))
  df = groupby(info, by)

  combine(d -> begin
    n = nrow(d)
    date_begin = d.date_begin[1]
    date_end = d.date_end[end]

    year_begin = str_year(date_begin)
    year_end = str_year(date_end)
    file = [d.file]
    DataFrame(;date_begin, date_end, year_begin, year_end, n, file)
  end, df)
end


export is_ssp, is_r1i1p1f1, 
  get_variable, get_host,
  str_year, 
  get_model, get_ensemble, get_scenario, get_date, get_date_nmiss, 
  CMIPFiles_info, CMIPFiles_summary
