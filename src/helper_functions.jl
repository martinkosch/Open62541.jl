function anonymous_struct_tuple(data, type)
    if isbitstype(typeof(data))
        raw = reinterpret(UInt8, [data])
    elseif isa(data, AbstractString)
        raw = Vector{UInt8}(data)
    else
        error("Type $(typeof(data)) not supported.")
    end
    padded = [raw; Vector{UInt8}(undef, sizeof(type) - length(raw))]
    return type(Tuple(padded))
end