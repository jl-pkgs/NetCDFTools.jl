
is_wsl() = Sys.islinux() && isfile("/mnt/c/Windows/System32/cmd.exe")
is_windows() = Sys.iswindows()
is_linux() = Sys.islinux()

"""
    path_mnt(path = ".")

Relative path will kept the original format.
"""
function path_mnt(path = ".")
    # path = realpath(path)
    n = length(path)
    if is_wsl() && n >= 2 && path[2] == ':'
        pan = "/mnt/$(lowercase(path[1]))"
        path = n >= 3 ? "$pan$(path[3:end])" : pan
    elseif is_windows() && n >= 6 && path[1:5] == "/mnt/"
        pan = "$(uppercase(path[6])):"
        path = n >= 7 ? "$pan$(path[7:end])" : pan
    end
    path
end
