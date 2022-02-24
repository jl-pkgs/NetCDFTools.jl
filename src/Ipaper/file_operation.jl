# whether the file exist? If not, create its directory
function check_file(file; verbose = false)
    if (!isfile(file))
        dirname(file) |> mkpath
        false
    else
        verbose && printstyled("[warn] file exists: $(basename(file))\n"; color = :light_black)
        true
    end
end

# whether directory exist? If not, create it.
function check_dir(indir; verbose = false)
    if (!isdir(indir))
        mkpath(indir)
        false
    else
        verbose && printstyled("[warn] dir exists: $indir\n"; color = :light_black)
        true
    end
end

export check_dir, check_file
