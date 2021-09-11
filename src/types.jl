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

# UA_STRING(s::String)
#     return UA_String(length(s), )
#     # UA_String s; s.length = 0; s.data = NULL;
#     # if(!chars)
#     #     return s;
#     # s.length = strlen(chars); s.data = (UA_Byte*)chars; return s;
# end


function UA_NODEID_NUMERIC(nsIndex::Integer, identifier::Integer)
    identifier_tuple = anonymous_struct_tuple(UInt32(identifier), fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_NUMERIC, identifier_tuple)
end

# function UA_NODEID_STRING(nsIndex::Integer, char::AbstractString)
#     identifier_tuple = anonymous_struct_tuple(UA_STRING(char), fieldtype(UA_NodeId, :identifier))
#     return UA_NodeId(nsIndex, UA_NODEIDTYPE_STRING, identifier_tuple)
# end


# static UA_INLINE UA_NodeId
# UA_NODEID_STRING(UA_UInt16 nsIndex, char *chars) {
#     UA_NodeId id; id.namespaceIndex = nsIndex;
#     id.identifierType = UA_NODEIDTYPE_STRING;
#     id.identifier.string = UA_STRING(chars); return id;
# }

# static UA_INLINE UA_NodeId
# UA_NODEID_STRING_ALLOC(UA_UInt16 nsIndex, const char *chars) {
#     UA_NodeId id; id.namespaceIndex = nsIndex;
#     id.identifierType = UA_NODEIDTYPE_STRING;
#     id.identifier.string = UA_STRING_ALLOC(chars); return id;
# }

# static UA_INLINE UA_NodeId
# UA_NODEID_GUID(UA_UInt16 nsIndex, UA_Guid guid) {
#     UA_NodeId id; id.namespaceIndex = nsIndex;
#     id.identifierType = UA_NODEIDTYPE_GUID;
#     id.identifier.guid = guid; return id;
# }

# static UA_INLINE UA_NodeId
# UA_NODEID_BYTESTRING(UA_UInt16 nsIndex, char *chars) {
#     UA_NodeId id; id.namespaceIndex = nsIndex;
#     id.identifierType = UA_NODEIDTYPE_BYTESTRING;
#     id.identifier.byteString = UA_BYTESTRING(chars); return id;
# }

# static UA_INLINE UA_NodeId
# UA_NODEID_BYTESTRING_ALLOC(UA_UInt16 nsIndex, const char *chars) {
#     UA_NodeId id; id.namespaceIndex = nsIndex;
#     id.identifierType = UA_NODEIDTYPE_BYTESTRING;
#     id.identifier.byteString = UA_BYTESTRING_ALLOC(chars); return id;
# }

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