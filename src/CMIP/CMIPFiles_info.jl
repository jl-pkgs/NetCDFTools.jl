"""
    get_model(file; prefix = "day_", postfix = "_hist|_ssp|_piControl")
"""
function get_model(file, prefix = "day_", postfix = "_hist|_ssp|_piControl")
    str_extract(basename(file), "(?<=$prefix).*(?=$postfix)")
end

function get_ensemble(file, pattern::AbstractString = "(?<=_)r\\d.*(?=_\\d{4,8})")
    str_extract(basename(file), pattern)
end

function get_scenario(file, pattern::AbstractString = "[a-z,A-Z,0-9,-]*(?=_r\\d)")
    str_extract(basename(file), pattern)
end

# get date_begin and date_end from the file name
function get_date(file::AbstractString, pattern::AbstractString = "[0-9]{4,8}")
    str_extract_all(basename(file), pattern)
end

function get_date(files::Vector{<:AbstractString}, pattern::AbstractString = "[0-9]{4,8}")
    dates = map(x -> get_date(x, pattern), files)
    date_begin = map(x -> x[1], dates)
    date_end = map(x -> x[2], dates)
    date_begin, date_end
end

function get_date_nmiss(file)
    dates = nc_date(file)
    dates_nmiss(dates)
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
function CMIPFiles_info(files; include_nmiss=false)
    date_begin, date_end = get_date(files)
    calender = nc_calendar.(files)
    cell_x, cell_y, regular = nc_cellsize(files)

    nmiss = include_nmiss ? get_date_nmiss.(files) : NaN;
    DataFrame(;
        model = get_model.(files),
        ensemble = get_ensemble.(files),
        scenario = get_scenario.(files),
        date_begin = date_begin, date_end = date_end,
        calender,
        nmiss, # v0.1.2, low efficient
        cell_x, cell_y, grid_regular = regular, file = files)
end


precompile(CMIPFiles_info, (Vector{String}, ))

export get_model, get_ensemble, get_scenario, get_date, get_date_nmiss, CMIPFiles_info
