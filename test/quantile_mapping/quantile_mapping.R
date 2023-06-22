QDM <- function(o.c, m.c, m.p, ratio = FALSE, trace = 0.05, trace.calc = 0.5 *
                  trace, jitter.factor = 0, n.tau = NULL, ratio.max = 2, ratio.max.trace = 10 *
                  trace, ECBC = FALSE, ties = "first", subsample = NULL, pp.type = 7) {
  n <- length(m.p)
  if (is.null(n.tau)) n.tau <- n
  tau <- seq(0, 1, length = n.tau)

  quant.o.c <- quantile(o.c, tau, type = pp.type)
  quant.m.c <- quantile(m.c, tau, type = pp.type)
  quant.m.p <- quantile(m.p, tau, type = pp.type)

  tau.m.p <- approx(quant.m.p, tau, m.p, rule = 2, ties = "ordered")$y
  # if (ratio) {
  #   approx.t.qmc.tmp <- approx(tau, quant.m.c, tau.m.p, rule = 2, ties = "ordered")$y
  #   delta.m <- m.p / approx.t.qmc.tmp
  #   delta.m[(delta.m > ratio.max) & (approx.t.qmc.tmp < ratio.max.trace)] <- ratio.max
  #   mhat.p <- approx(tau, quant.o.c, tau.m.p, rule = 2, ties = "ordered")$y *
  #     delta.m
  # } else {
  delta.m <- m.p - approx(tau, quant.m.c, tau.m.p, rule = 2, ties = "ordered")$y
  mhat.p <- approx(tau, quant.o.c, tau.m.p, rule = 2, ties = "ordered")$y + delta.m
  # }
  mhat.c <- approx(quant.m.c, quant.o.c, m.c, rule = 2, ties = "ordered")$y
  mhat.p
}
