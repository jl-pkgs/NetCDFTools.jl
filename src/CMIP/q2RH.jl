
# - Pa: kPa
# -  q: g/g
function vapour_press(q, Pa = 101.325) 
  epsilon = 0.6220016
  q * Pa/(epsilon + (1 - epsilon) * q)
end

function cal_es(Tair)
   0.6108 * exp((17.27 * Tair)/(Tair + 237.3))
end

# RH in the unit of `%`
function q2RH(q, Tair; Pa=101.325)
  ea = vapour_press(q, Pa)
  es = cal_es(Tair)
  ea / es * 100
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

precompile(heat_index_q, (String, String, String))
