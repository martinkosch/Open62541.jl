#functions used multiple times within Open62541.jl testset

#For Strings - produces strings with length between 1 and 10 characters
function customrand(type::Type{String}, array_size)
    return reshape([randstring(rand(1:10)) for i in 1:prod(array_size)],
        array_size...)
end

function customrand(type::Type{String})
    return randstring(rand(1:10))
end

#rational numbers
function customrand(::Type{Rational{T}}, array_size) where {T}
    num = rand(T, array_size)
    den = rand(T, array_size)
    r = Rational.(num, den)
    return r
end

function customrand(::Type{Rational{T}}) where {T}
    num = rand(T)
    den = rand(T)
    r = Rational(num, den)
    return r
end

#For all other number types
function customrand(type::Type{<:Number}, array_size)
    return rand(type, array_size)
end

function customrand(type::Type{<:Number})
    return rand(type)
end
