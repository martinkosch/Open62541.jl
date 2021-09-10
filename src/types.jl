const UA_TYPES = Ref{Ptr{UA_DataType}}(0) # Initilize with C_NULL and initialize correct address at __init__
const UA_TYPES_PTRS = OffsetVector{Ptr{UA_DataType}}(undef, 0:UA_TYPES_COUNT-1) # Initilize vector of UA_TYPES pointer undefined and write values at __init__

function UA_init(p::Ref{T}) where T
    @ccall memset(p::Ptr{Cvoid}, 0::Cint, (sizeof(T))::Csize_t)::Ptr{Cvoid}
    return nothing
end

for type_name in type_names
    type_ind_name = Symbol("UA_TYPES_", uppercase(type_name))
    type_name = Symbol("UA_", type_name)

    @eval begin
        function $(Symbol(type_name, "_new"))()
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return convert(Ptr{$(type_name)}, UA_new(data_type_ptr))
        end

        $(Symbol(type_name, "_init"))(p::Ptr{$(type_name)}) = UA_init(p)

        function $(Symbol(type_name, "_copy"))(src::Ptr{$(type_name)}, dst::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_copy(src, dst, data_type_ptr)
        end

        function $(Symbol(type_name, "_clear"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_clear(p, data_type_ptr)
        end

        function $(Symbol(type_name, "_delete"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_delete(p, data_type_ptr)
        end
    end
end

UA_Variant_isEmpty(v::Ref{UA_Variant}) = unsafe_load(v).type == C_NULL

function UA_Variant_isScalar(p::Ref{UA_Variant}) 
    v = unsafe_load(p)
    return v.arrayLength == 0 && v.data > UA_EMPTY_ARRAY_SENTINEL
end

function UA_Variant_hasScalarType(p::Ref{UA_Variant}, type::Ref{UA_DataType}) 
    return UA_Variant_isScalar(p) && type == unsafe_load(p).type
end

function UA_Variant_hasArrayType(p::Ref{UA_Variant}, type::Ref{UA_DataType}) 
    return !UA_Variant_isScalar(p) && type == unsafe_load(p).type
end