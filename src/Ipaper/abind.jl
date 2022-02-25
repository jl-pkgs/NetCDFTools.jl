rbind(args...) = cat(args..., dims = 1)
cbind(args...) = cat(args..., dims = 2)

abind(args...; along = 3) = cat(args..., dims = along)

export rbind, cbind, abind
