function anonymous_struct_tuple(data::Ptr{T}, type) where {T}
    vec = Vector{UInt8}(undef, sizeof(type))
    GC.@preserve vec unsafe_copyto!(pointer(vec), reinterpret(Ptr{UInt8}, data), sizeof(T))
    return type(Tuple(vec))
end

function anonymous_struct_tuple(data::Integer, type)
    raw = reinterpret(UInt8, [data])
    padded = [raw; Vector{UInt8}(undef, sizeof(type) - length(raw))]
    return type(Tuple(padded))
end

function anonymous_struct_tuple(data::UA_String, type)
    raw_length = reinterpret(UInt8, [data.length])
    raw_data = reinterpret(UInt8, [data.data])
    raw = [raw_length; raw_data]
    padded = [raw; Vector{UInt8}(undef, sizeof(type) - length(raw))]
    return type(Tuple(padded))
end

function anonymous_struct_tuple(data::UA_Guid, type)
    raw_data1 = reinterpret(UInt8, [data.data1])
    raw_data2 = reinterpret(UInt8, [data.data2])
    raw_data3 = reinterpret(UInt8, [data.data3])
    raw = [raw_data1; raw_data2; raw_data3; data.data4...]
    padded = [raw; Vector{UInt8}(undef, sizeof(type) - length(raw))]
    return type(Tuple(padded))
end
