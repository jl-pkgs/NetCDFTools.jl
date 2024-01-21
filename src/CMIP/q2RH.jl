
# - Pa: kPa
# -  q: g/g
function vapour_press(q, Pa=101.325)
  epsilon = 0.6220016
  q * Pa / (epsilon + (1 - epsilon) * q)
end

function cal_es(Tair)
  0.6108 * exp((17.27 * Tair) / (Tair + 237.3))
end

# RH in the unit of `%`
function q2RH(q, Tair; Pa=101.325)
  ea = vapour_press(q, Pa)
  es = cal_es(Tair)
  ea / es * 100
end
