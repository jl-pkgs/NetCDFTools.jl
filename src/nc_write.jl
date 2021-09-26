function nc_write(data, outfile, dims, varname = "HI"; overwrite = false, compress = 1)
    var = NcVar(varname, dims; t = Float32, compress = compress)

    if !isfile(outfile) || overwrite
        if isfile(outfile); rm(outfile); end
        NetCDF.create(outfile, var) do nc
            NetCDF.putvar(nc, varname, data)
        end
    end
end
