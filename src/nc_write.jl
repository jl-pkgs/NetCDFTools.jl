function nc_write(data::AbstractArray{T}, outfile, dims; 
    varname = "HI", type = nothing, compress = 1, overwrite = false) where T <: Real
    
    if type === nothing; type = T; end
    var = NcVar(varname, dims; t = type, compress = compress)

    if !isfile(outfile) || overwrite
        if isfile(outfile); rm(outfile); end
        NetCDF.create(outfile, var) do nc
            NetCDF.putvar(nc, varname, data)
        end
    end
end
