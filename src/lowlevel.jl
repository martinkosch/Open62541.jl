function UA_TYPES_OFFSET(offset)
    checkbounds(1:UA_TYPES_COUNT, offset+1)
    return UA_TYPES[] + sizeof(UA_DataType) * offset
end

macro ua_type_ptr(var)
    ua_str = "UA_"
    return quote
        local elt = $(esc(:(String(Symbol(eltype($var))))))
        local parts = $(esc(split))(elt, $(Regex(ua_str)))
        local id = $(esc(:(Meta.parse)))($(esc(:(string)))(parts[1:end-1]..., $(ua_str), "TYPES_", $(esc(:(uppercase)))(parts[end])))
        UA_TYPES_OFFSET(eval(id))
    end
end 

function UA_init(p::Ref{T}) where T
    @ccall memset(p::Ptr{Cvoid}, 0::Cint, (sizeof(T))::Csize_t)::Ptr{Cvoid}
    return nothing
end

UA_init(p) = UA_init(Ref(p))

function UA_copy(src::Ref{T}, dst::Ref{T}) where T
    type_ptr = @ua_type_ptr src
    return Libopen62541.UA_copy(Base.unsafe_convert(Ptr{Cvoid}, src), Base.unsafe_convert(Ptr{Cvoid}, dst), type_ptr)
end 

function UA_clear(p::Ref{T}) where T
    type_ptr = @ua_type_ptr p
    return Libopen62541.UA_clear(Base.unsafe_convert(Ptr{Cvoid}, p), type_ptr)
end

function UA_delete(p::Ref{T}) where T
    type_ptr = @ua_type_ptr p
    return Libopen62541.UA_delete(Base.unsafe_convert(Ptr{Cvoid}, p), type_ptr)
end

# function UA_NODEID_NUMERIC(nsIndex, i)
#     id = UA_NodeId()
#     id.namespaceIndex = nsIndex
#     id.identifierType = UA_NODEIDTYPE_NUMERIC
#     id.numeric = i
#     return id
# end

# function Libopen62541.__JL_Ctag_376(v)
#     T = fieldtype(open62541.UA_NodeId, :identifier))
#     raw = reinterpret(UInt8, [v])
#     padded = [raw; Vector{UInt8}(undef, sizeof(T) - length(raw))]
#     return T(Tuple(padded))
# end

# function Base.getproperty(x::UA_NodeId, f::Symbol)
#     f === :numeric && return getproperty(x.identifier, :numeric)
#     f === :string && return getproperty(x.identifier, :string)
#     f === :guid && return getproperty(x.identifier, :guid)
#     f === :byteString && return getproperty(x.identifier, :byteString)
#     return getfield(x, f) # Fallback to getfield
# end

# function Base.setproperty!(x::UA_NodeId, f::Symbol, v)
#     T = typeof(x.identifier)
#     f === :numeric && return setfield!(x, :identifier, T(UA_UInt32(v)))
#     f === :string && return setfield!(x, :identifier, T(UA_String(v)))
#     f === :guid && return setfield!(x, :identifier, T(UA_Guid(v)))
#     f === :byteString && return setfield!(x, :identifier, T(UA_ByteString(v)))
#     return setfield!(x, f, convert(fieldtype(typeof(x), f), v)) # Fallback to setfield!
# end