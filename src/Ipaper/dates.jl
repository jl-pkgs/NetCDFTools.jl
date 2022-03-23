using CFTime
using Dates

# only for daily scale 
function dates_miss(dates)
    date_begin = first(dates)
    date_end = last(dates)
    dates_full = date_begin:Dates.Day(1):date_end
    setdiff(dates_full, dates)
end

# only for daily scale 
function dates_nmiss(dates)
    date_begin = first(dates)
    date_end = last(dates)

    n_full = (date_end - date_begin) / convert(Dates.Millisecond, Dates.Day(1)) + 1 |> Int
    n_full - length(dates) # n_miss
end


year = Dates.year
month = Dates.month
day = Dates.day

Year = Dates.Year
Month = Dates.Month
Day = Dates.Day

make_datetime = DateTime
make_date = DateTime

export dates_miss, dates_nmiss,
    year, month, day,
    Year, Month, Day,
    make_datetime, make_date
