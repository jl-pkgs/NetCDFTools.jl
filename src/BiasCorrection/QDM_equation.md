# QDM

## 降水

- $F_{m, p}^{(t)-1}\left[\tau_{m, p}(t)\right]$：相对于历史增加了多少倍

$$
\Delta_m(t)=\frac{F_{m, p}^{(t)-1}\left[\tau_{m, p}(t)\right]}{F_{m, h}^{-1}\left[\tau_{m, p}(t)\right]}
=\frac{x_{m, p}(t)}{F_{m, h}^{-1}\left[\tau_{m, p}(t)\right]}
$$

如果套用历史的分布，
$$
\hat{x}_{o: m, l: p}(t) = F_{o, h}^{-1}\left[\tau_{m, p}(t)\right],
$$
最终矫正的结果
$$
\hat{x}_{m, p}(t)=\hat{x}_{o m, h: p}(t) \Delta_m(t) \\
=\frac{F_{m, p}^{(t)-1}\left[\tau_{m, p}(t)\right]}{F_{m, h}^{-1}\left[\tau_{m, p}(t)\right]} F_{o, h}^{-1}\left[\tau_{m, p}(t)\right],
$$

## 温度

$F_{m, p}^{(t)-1}\left[\tau_{m, p}(t)\right]$：相对于历史增加了多少倍
$$
\Delta_m(t)={F_{m, p}^{(t)-1}\left[\tau_{m, p}(t)\right]} - {F_{m, h}^{-1}\left[\tau_{m, p}(t)\right]}
$$
如果套用历史的分布，
$$
\hat{x}_{o: m, l: p}(t)=F_{o, h}^{-1}\left[\tau_{m, p}(t)\right],
$$
最终矫正的结果
$$
\hat{x}_{m, p}(t)=\hat{x}_{o m, h: p}(t) + \Delta_m(t)
$$


## 趋势对矫正的影响