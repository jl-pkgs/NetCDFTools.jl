using RCall


R"""
library(magrittr)
library(data.table)

statistic_temporal <- function(d) {
  df = as.data.table(d)
  df[, .(.N, wm = mean(anomaly), ws = sum(anomaly)), 
       .(prob, year, doy, id)] %>%
    .[, .(
      doy_begin = first(doy), 
      doy_end = last(doy),
      HWD = .N,
      HWI = max(wm),
      HWS_mean = sum(wm), # 这个未乘以面积
      HWS_sum = sum(ws),  # 这是考虑anomaly加权的HWS
      HWA_avg = mean(N),
      HWA_max = max(N), 
      HWA_sum = sum(N)
    ), .(prob, year, id)]  
}
# r = statistic_temporal($df)
# summary(r[, HWS_sum/HWS_mean])
"""
