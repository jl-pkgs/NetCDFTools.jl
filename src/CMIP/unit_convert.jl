"""
    Tem_F2C(T_degF::AbstractFloat)
    Tem_C2F(T_degC::AbstractFloat)
"""
function Tem_F2C(T_degF::Real)
    (T_degF .- 32) ./ (9 / 5)
end

function Tem_C2F(T_degC::Real)
    T_degC .* (9 / 5) .+ 32 # T_degF
end
