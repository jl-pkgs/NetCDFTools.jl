using Glob
export glob


"""
    str_extract(x::AbstractString, pattern::AbstractString)
"""
function str_extract(x::AbstractString, pattern::AbstractString)
    r = match(Regex(pattern), basename(x))
    r === nothing ? "" : r.match
    # if ; r.match; else ""; end
end

function str_extract_all(x::AbstractString, pattern::AbstractString)
    [x === nothing ? "" : x.match for x in eachmatch(Regex(pattern), basename(x))]
end

function str_replace(x::AbstractString, pattern::AbstractString, replacement::AbstractString = "")
    replace(x, pattern => replacement)
end

function grep(x::AbstractString, pattern::AbstractString)
    r = match(Regex(pattern), x)
    r === nothing ? false : true
end

function grep(x::Vector{<:AbstractString}, pattern::AbstractString)::AbstractArray{Bool,1}
    map(x) do x
        grep(x, pattern)
    end
end

function grepl(x::Vector{<:AbstractString}, pattern::AbstractString)::AbstractArray{Int,1}
    grep(x, pattern) |> findall
end


"""
    dir(path = ".", pattern = ""; full_names = true, include_dirs = false, recursive = false)

# Arguments:
- `path`
- `pattern`
- `full_names`
- `include_dirs`
- `recursive`

# Example
dir(".", "\\.md\$")
"""
function dir(path = ".", pattern = ""; full_names = true, include_dirs = true, recursive = false)
    res = readdir(path, join = true) # also include directory

    dirs = filter(isdir, res)
    files = filter(isfile, res)

    if recursive
        files_deep = map(dirs) do x
            dir(x, pattern; full_names = full_names, include_dirs = include_dirs, recursive = recursive)
        end
        files = cat([files, files_deep...]..., dims = 1)
    end

    if include_dirs
        files = [dirs; files]
    end
    if pattern != ""
        files = files[grepl(files, pattern)]
    end
    files
end


export str_extract, str_extract_all, str_replace,
    grep, grepl,
    dir
