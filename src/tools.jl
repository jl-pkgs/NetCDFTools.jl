using Interpolations

function approx(x, y, xout)
  interp_linear_extrap = linear_interpolation(x, y, extrapolation_bc=Line())
  interp_linear_extrap.(xout) # outside grid: linear extrapolation
end


array(val; dims) = reshape(val, dims...)
array(val, dims) = array(val; dims)

function meshgrid(x, y)
  X = repeat(x', length(y), 1)
  Y = repeat(y, 1, length(x))
  X, Y
end


export array, meshgrid
