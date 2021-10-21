
function Tem_F2C(T_degF::AbstractFloat)
    (T_degF .- 32) ./ (9 / 5) 
end

function Tem_C2F(T_degC::AbstractFloat)
    T_degC .* (9 / 5) .+ 32 # T_degF
end

# t: degF
# rh: %
function heat_index(t :: T1, rh :: T2)::Real where 
    {T1<:Union{Real, Missing}, T2<:Union{Real, Missing}}
    
    t = Tem_C2F(t)
    # print(t, ismissing(t) || ismissing(rh))
    # if (ismissing(t) || ismissing(rh)); return(NaN64); end
    if (t <= 40) 
        hi = t
    else
        alpha = 61 + ((t - 68) * 1.2) + (rh * 0.094)
        hi = 0.5*(alpha + t)
        if (hi > 79)
            hi = -42.379 + 2.04901523 * t + 10.14333127 * rh -
                    0.22475541 * t * rh - 6.83783 * 10^-3 * t^2 -
                    5.481717 * 10^-2 * rh^2 + 1.22874 * 10^-3 * t^2 *
                    rh + 8.5282 * 10^-4 * t * rh^2 - 1.99 * 10^-6 *
                    t^2 * rh^2
            if (rh <= 13 && t >= 80 && t <= 112) 
                adjustment1 = (13 - rh)/4
                adjustment2 = sqrt((17 - abs(t - 95))/17)
                total_adjustment = adjustment1 * adjustment2
                hi = hi - total_adjustment
            elseif (rh > 85 && t >= 80 && t <= 87)
                adjustment1 = (rh - 85)/10
                adjustment2 = (87 - t)/5
                total_adjustment = adjustment1 * adjustment2
                hi = hi + total_adjustment
            end
        end
    end
    Tem_F2C(hi)
end

function heat_index(t :: AbstractArray{T}, rh :: AbstractArray{T}) where 
    T<:Union{Real, Union{Missing, Real}}
    heat_index.(t, rh)
end


function CMIP6_heat_index(file_tair, file_rh, outfile; 
    overwrite = false, raw = false, compress = 1)

    if !isfile(outfile) || overwrite
        if isfile(outfile); rm(outfile); end
        
        println("reading Tair ...")
        arr_tair = nc_read(file_tair; raw = raw) .- 273.15

        println("reading RH ...")
        arr_rh   = nc_read(file_rh; raw = raw)
        
        println("calculating HI ...")
        @time arr_HI = heat_index.(arr_tair, arr_rh)

        println("saving ...")
        dims = nc_dims(file_tair)
        @time nc_write(arr_HI, outfile, dims; varname = "HI", compress = compress)
    end
end


export heat_index, CMIP6_heat_index;
