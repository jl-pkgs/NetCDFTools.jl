# - Pa: kPa
# -  q: g/g
function vapour_press(q, Pa=101.325)
  epsilon = 0.6220016
  q * Pa / (epsilon + (1 - epsilon) * q)
end

function cal_es(Tair)
  0.6108 * exp((17.27 * Tair) / (Tair + 237.3))
end

# RH in the unit of `%`
function q2RH(q, Tair; Pa=101.325)
  ea = vapour_press(q, Pa)
  es = cal_es(Tair)
  ea / es * 100
end


"""
    Tem_F2C(T_degF::Real)
    Tem_C2F(T_degC::Real)
"""
function Tem_F2C(T_degF::Real)
  (T_degF .- 32) ./ (9 / 5)
end

function Tem_C2F(T_degC::Real)
  T_degC .* (9 / 5) .+ 32 # T_degF
end

function heat_index(t::Union{<:Real,Missing}, rh::Union{<:Real,Missing}; missval=-9999)
  if t == missval || rh == missval
    return missing
  end
  t = Tem_C2F(t)
  # if (ismissing(t) || ismissing(rh)); return(NaN64); end
  if (t <= 40)
    hi = t
  else
    alpha = 61 + ((t - 68) * 1.2) + (rh * 0.094)
    hi = 0.5 * (alpha + t)
    if (hi > 79)
      hi = -42.379 + 2.04901523 * t + 10.14333127 * rh -
           0.22475541 * t * rh - 6.83783 * 10^-3 * t^2 -
           5.481717 * 10^-2 * rh^2 + 1.22874 * 10^-3 * t^2 * rh +
           8.5282 * 10^-4 * t * rh^2 - 1.99 * 10^-6 * t^2 * rh^2
      if (rh <= 13 && t >= 80 && t <= 112)
        adjustment1 = (13 - rh) / 4
        adjustment2 = sqrt((17 - abs(t - 95)) / 17)
        total_adjustment = adjustment1 * adjustment2
        hi = hi - total_adjustment
      elseif (rh > 85 && t >= 80 && t <= 87)
        adjustment1 = (rh - 85) / 10
        adjustment2 = (87 - t) / 5
        total_adjustment = adjustment1 * adjustment2
        hi = hi + total_adjustment
      end
    end
  end
  Tem_F2C(hi)
end

function heat_index(t::AbstractArray{T}, rh::AbstractArray{T}; missval=-9999) where {T<:Union{Missing,Real}}
  heat_index.(t, rh; missval=missval)
end

"""
    heat_index(t::Union{<:Real,Missing}, rh::Union{<:Real,Missing})
    heat_index(t::AbstractArray{T}, rh::AbstractArray{T}) where {T<:Union{Missing,Real}}
    heat_index(f_tair::AbstractString, f_rh::AbstractString, outfile::AbstractString;
        raw=true, offset = -273.15,
        varname="HI", type = Float32, compress=1, 
        overwrite=false)

# Arguments
- `t`: degC
- `rh`: %

# Examples
```julia
heat_index(f_tair, f_rh, outfile; overwrite = false, raw = true, compress = 1)
```

# References
1. https://www.wpc.ncep.noaa.gov/html/heatindex_equationbody.html
2. Kong, D., Gu, X., Li, J., Ren, G., & Liu, J. (2020). Contributions of Global 
    Warming and Urbanization to the Intensification of Human‐Perceived Heatwaves 
    Over China. Journal of Geophysical Research: Atmospheres, 125(18), 1–16. 
    https://doi.org/10.1029/2019JD032175.
"""
function heat_index(f_tair::AbstractString, f_rh::AbstractString, outfile::AbstractString;
  raw=true, offset=-273.15,
  varname="HI", FT=Float32, compress=1,
  missval=-9999.0,
  overwrite=false)

  if !isfile(outfile) || overwrite
    isfile(outfile) && rm(outfile)

    println("reading Tair ...")
    arr_tair = nc_read(f_tair; type=FT, raw=raw) .+ FT(offset)

    println("reading RH ...")
    arr_rh = nc_read(f_rh; type=FT, raw=raw)

    println("calculating HI ...")
    @time arr_HI = heat_index.(arr_tair, arr_rh; missval=missval)

    println("saving ...")
    dims = ncvar_dim(f_tair)

    @time nc_write(outfile, varname, arr_HI, dims; type=FT, compress=compress)
    # @time nc_write(arr_HI, outfile, dims; varname=varname, type=type, compress=compress)
  end
end


function heat_index_q(f_tair::AbstractString, f_q::AbstractString, outfile::AbstractString;
  raw=true, offset=-273.15,
  varname="HI", FT=Float32, compress=0,
  missval=-9999.0,
  overwrite=false)

  if !isfile(outfile) || overwrite
    isfile(outfile) && rm(outfile)

    println("reading Tair ...")
    tair = nc_read(f_tair; type=FT, raw=raw) .+ FT(offset)

    println("reading q ...")
    q = nc_read(f_q; type=FT, raw=raw)
    RH = q2RH.(q, tair) # 进行转换

    println("calculating HI ...")
    @time HI = heat_index.(tair, RH; missval=missval)

    println("saving ...")
    dims = ncvar_dim(f_tair)

    @time nc_write(outfile, varname, HI, dims; type=FT, compress=compress)
    # @time nc_write(arr_HI, outfile, dims; varname=varname, type=type, compress=compress)
  end
end

precompile(heat_index, (String, String, String))
precompile(heat_index_q, (String, String, String))
