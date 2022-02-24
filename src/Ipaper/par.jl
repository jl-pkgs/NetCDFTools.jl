import Base.Threads
import Base.Threads: threading_run, threadid, _threadsfor, nthreads


macro par(parallel, ex)
    ex_par = :(Threads.@threads for _ in 1:1; end)
    ex_par.args[3] = ex
    
    expr = :(parallel ? $(ex_par) : $(ex))
    esc(expr)
end

macro par(ex)
    # default parallel
    ex_par = :(Threads.@threads for _ in 1:1; end)
    ex_par.args[3] = ex
    esc(ex_par)
end

get_clusters() = Threads.nthreads()


export get_clusters, @par
