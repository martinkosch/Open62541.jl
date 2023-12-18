const UA_TYPES = Ref{Ptr{UA_DataType}}(0) # Initialize with C_NULL and initialize correct address during __init__
const UA_TYPES_PTRS = OffsetVector{Ptr{UA_DataType}}(undef, 0:(UA_TYPES_COUNT - 1)) # Initialize vector of UA_TYPES pointer undefined and write values during __init__
const UA_TYPES_MAP = Vector{DataType}(undef, UA_TYPES_COUNT) # Initialize vector of mapping between UA_TYPES and Julia types as undefined and write values during __init__

function juliadatatype(p::Ptr{UA_DataType})
    ind = Int(Int((p - UA_TYPES_PTRS[0])) / sizeof(UA_DataType))
    return UA_TYPES_MAP[ind + 1]
end

# Initialize default attribute definitions with C_NULL and initialize correct address during __init__ (extern variables are missed by Clang.jl)
const UA_VariableAttributes_default = Ref{UA_VariableAttributes}()
const UA_VariableTypeAttributes_default = Ref{UA_VariableTypeAttributes}()
const UA_MethodAttributes_default = Ref{UA_MethodAttributes}()
const UA_ObjectAttributes_default = Ref{UA_ObjectAttributes}()
const UA_ObjectTypeAttributes_default = Ref{UA_ObjectTypeAttributes}()
const UA_ReferenceTypeAttributes_default = Ref{UA_ReferenceTypeAttributes}()
const UA_DataTypeAttributes_default = Ref{UA_DataTypeAttributes}()
const UA_ViewAttributes_default = Ref{UA_ViewAttributes}()

function UA_init(p::Ref{T}) where {T}
    @ccall memset(p::Ptr{Cvoid}, 0::Cint, (sizeof(T))::Csize_t)::Ptr{Cvoid}
    return nothing
end

# ## UA_Array
# Julia wrapper for C array types
struct UA_Array{T <: Ptr} <: AbstractArray{T, 1}
    ptr::T
    length::Int64
end

function UA_Array(s::T, field::Symbol) where {T}
    size_fieldname = Symbol(field, :Size)
    ptr = getfield(s, field)
    datasize = getfield(s, size_fieldname)
    return UA_Array(ptr, Int64(datasize))
end

Base.size(a::UA_Array) = (a.length,)
Base.length(a::UA_Array) = a.length
Base.IndexStyle(::Type{<:UA_Array}) = IndexLinear()
function Base.getindex(a::UA_Array{Ptr{T}}, i::Int) where {T}
    1 <= i <= a.length || throw(BoundsError(a, i))
    return a.ptr + (i - 1) * sizeof(T)
end
Base.firstindex(a::UA_Array) = 1
Base.lastindex(a::UA_Array) = a.length
Base.setindex!(a::UA_Array, v, i::Int) = unsafe_store!(a.ptr, v, i)
Base.unsafe_wrap(a::UA_Array) = unsafe_wrap(Array, a[begin], size(a))
Base.pointer(a::UA_Array) = a[begin]
Base.convert(::Type{Ptr{T}}, a::UA_Array{Ptr{T}}) where {T} = a[begin]
Base.convert(::Type{Ptr{Nothing}}, a::UA_Array) = Base.unsafe_convert(Ptr{Nothing}, a)
Base.convert(::Type{Ptr{Nothing}}, a::UA_Array{Ptr{Nothing}}) = a[begin] # Avoid method ambigutiy
function Base.unsafe_convert(::Type{Ptr{Nothing}}, a::UA_Array)
    Base.unsafe_convert(Ptr{Nothing}, a[begin])
end

function UA_Array_init(p::UA_Array)
    for i in p
        UA_init(i)
    end
end

function UA_Array_new(v::AbstractArray{T},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T}
    v_typed = convert(Vector{juliadatatype(type_ptr)}, vec(v)) # Implicit check if T can be converted to type_ptr
    arr_ptr = convert(Ptr{T}, UA_Array_new(length(v), type_ptr))
    GC.@preserve v_typed unsafe_copyto!(arr_ptr, pointer(v_typed), length(v))
    return UA_Array(arr_ptr, length(v))
end

# Initialize empty array
function UA_Array_new(length::Integer, juliatype::DataType)
    type_ptr = ua_data_type_ptr_default(juliatype)
    ptr_arr = UA_Array_new(length, type_ptr)
    arr_ptr = convert(Ptr{juliatype}, ptr_arr)
    return UA_Array(arr_ptr, length)
end

function UA_print(p::Ref{T},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T}
    buf = UA_String_new()
    UA_print(p, type_ptr, buf)
    s = unsafe_string(buf)
    UA_String_clear(buf)
    UA_String_delete(buf)
    return s
end

function UA_print(v::T, type_ptr = ua_data_type_ptr_default(T)) where {T}
    UA_print(Ref(v), type_ptr)
end

for (i, type_name) in enumerate(type_names)
    type_ind_name = Symbol("UA_TYPES_", uppercase(String(type_name)[4:end]))
    julia_type = julia_types[i]
    val_type = Val{type_name}

    @eval begin
        # Datatype map functions
        ua_data_type_ptr(::$(val_type)) = UA_TYPES_PTRS[$(i - 1)]
        if !(type_names[$(i)] in types_ambiguous_ignorelist)
            ua_data_type_ptr_default(::Type{$(julia_type)}) = UA_TYPES_PTRS[$(i - 1)]
            Base.show(io::IO, ::MIME"text/plain", v::$(julia_type)) = print(io, UA_print(v))
        end

        # Datatype specific constructors, destructors, initalizers, as well as clear and copy functions
        function $(Symbol(type_name, "_new"))()
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return convert(Ptr{$(type_name)}, UA_new(data_type_ptr))
        end

        $(Symbol(type_name, "_init"))(p::Ptr{$(type_name)}) = UA_init(p)

        function $(Symbol(type_name, "_copy"))(src::Ref{$(type_name)},
                dst::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_copy(src, dst, data_type_ptr)
        end

        function $(Symbol(type_name, "_copy"))(src::$(type_name),
                dst::Ptr{$(type_name)})
            return $(Symbol(type_name, "_copy"))(Ref(src), dst)
        end

        function $(Symbol(type_name, "_clear"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_clear(p, data_type_ptr)
        end

        function $(Symbol(type_name, "_delete"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_delete(p, data_type_ptr)
        end

        function $(Symbol(type_name, "_Array_new"))(length::Integer)
            # TODO: Allow empty arrays with corresponsing UA_EMPTY_ARRAY_SENTINEL indicator
            length <= 0 &&
                throw(DomainError(length, "Length of new array must be larger than zero."))
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            arr_ptr = convert(Ptr{$(type_name)}, UA_Array_new(length, data_type_ptr))
            return UA_Array(arr_ptr, length)
        end

        function $(Symbol(type_name, "_Array_new"))(v::Tuple)
            return $(Symbol(type_name, "_Array_new"))(collect(v))
        end

        function $(Symbol(type_name, "_Array_new"))(v::AbstractVector)
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            v_typed = convert(Vector{$(type_name)}, v)
            arr_ptr = convert(Ptr{$(type_name)}, UA_Array_new(length(v), data_type_ptr))
            GC.@preserve v_typed unsafe_copyto!(arr_ptr, pointer(v_typed), length(v))
            return UA_Array(arr_ptr, length(v))
        end

        function $(Symbol(type_name, "_Array_init"))(p::UA_Array{Ptr{$(type_name)}})
            UA_Array_init(p)
        end

        function $(Symbol(type_name, "_Array_copy"))(src::Ref{$(type_name)},
                dst::Ptr{$(type_name)},
                length::Integer)
            length < 0 && error("Length of copied array cannot be negative.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_Array_copy(src, length, Ref(dst), data_type_ptr)
        end

        function $(Symbol(type_name, "_Array_delete"))(p::Ptr{$(type_name)},
                length::Integer)
            length < 0 && error("Length of deleted array cannot be negative.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_Array_delete(p, length, data_type_ptr)
        end

        function $(Symbol(type_name, "_Array_delete"))(p::UA_Array{Ptr{$(type_name)}})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_Array_delete(p, p.length, data_type_ptr)
        end
    end
end

## StatusCode
function UA_StatusCode_name_print(sc::Integer)
    return unsafe_string(UA_StatusCode_name(UA_StatusCode(sc)))
end

## String
# String `s` is copied to newly allocated memory that needs to be freed. Returns a pointer to a new `UA_String`.
function UA_String_set_alloc(data::AbstractString, ua_str::Ptr{UA_String})
    s = UA_String_fromChars(data)
    ua_str.data = s.data
    ua_str.length = s.length
    return ua_str
end

# String `s` must be kept valid using GC.@preserve as long as the return value is used. It is recommended to use UA_STRING_ALLOC with a subsequent call to UA_String_delete.
function UA_STRING_unsafe(s::AbstractString)
    GC.@preserve s begin
        isempty(s) && return UA_String(0, C_NULL)
        return UA_String(length(s), pointer(s))
    end
end

# String `s` is copied to newly allocated memory. The result's field `data` needs to be freed. Returns a `UA_String` struct.
UA_STRING_ALLOC(s::AbstractString) = UA_String_fromChars(s)

UA_String_delete(s::UA_String) = UA_Byte_delete(s.data)

Base.unsafe_string(s::UA_String) = unsafe_string(s.data, s.length)
Base.unsafe_string(s::Ref{UA_String}) = unsafe_string(s[])
Base.unsafe_string(s::Ptr{UA_String}) = unsafe_string(unsafe_load(s))

UA_String_equal(s1::UA_String, s2::Ref{UA_String}) = UA_String_equal(Ref(s1), s2)
UA_String_equal(s1::Ref{UA_String}, s2::UA_String) = UA_String_equal(s1, Ref(s2))
UA_String_equal(s1::UA_String, s2::UA_String) = UA_String_equal(Ref(s1), Ref(s2))

## DateTime
function UA_DateTime_toUnixTime(date::UA_DateTime)
    return (date - UA_DATETIME_UNIX_EPOCH) / UA_DATETIME_SEC
end

function UA_DateTime_fromUnixTime(unixDate::Integer)
    return UA_DateTime(unixDate * UA_DATETIME_SEC) + UA_DATETIME_UNIX_EPOCH
end

datetime2ua_datetime(dt::DateTime) = UA_DateTime_fromUnixTime(round(Int, datetime2unix(dt)))
ua_datetime2datetime(dt::UA_DateTime) = unix2datetime(UA_DateTime_toUnixTime(dt))

## Guid
# XXX - UA_GUID("test") --> BadInternalError
function UA_GUID(s::AbstractString)
    guid = Ref{UA_Guid}()
    ua_s = UA_STRING_unsafe(s)
    retval = GC.@preserve s UA_Guid_parse(guid, ua_s)
    retval != UA_STATUSCODE_GOOD &&
        error("Parsing of Guid \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return guid[]
end

## NodeId
#numeric
function UA_NodeId_new(nsIndex::Integer, identifier::Integer)
    nodeid = UA_NodeId_new()
    nodeid.namespaceIndex = UA_UInt16(nsIndex)
    nodeid.identifierType = UA_NODEIDTYPE_NUMERIC

    identifier_tuple = open62541.anonymous_struct_tuple(UInt32(identifier),
        typeof(unsafe_load(nodeid.identifier)))
    nodeid.identifier = identifier_tuple
    return nodeid
end

function UA_NODEID_NUMERIC(nsIndex::Integer, identifier::Integer)
    return UA_NodeId_new(nsIndex, identifier)
end

#string
function UA_NodeId_new(nsIndex::Integer, identifier::AbstractString)
    nodeid = UA_NodeId_new()
    nodeid.namespaceIndex = UA_UInt16(nsIndex)
    nodeid.identifierType = UA_NODEIDTYPE_STRING

    identifier_tuple = open62541.anonymous_struct_tuple(UA_String_fromChars(identifier),
        typeof(unsafe_load(nodeid.identifier)))
    nodeid.identifier = identifier_tuple
    return nodeid
end

function UA_NODEID_STRING_ALLOC(nsIndex::Integer, identifier::AbstractString)
    return UA_NodeId_new(nsIndex, identifier)
end

# String `s` must be kept valid using GC.@preserve as long as the return value is used. It is recommended to use UA_NODEID_STRING_ALLOC with a subsequent call to UA_NodeId_delete.
function UA_NODEID_STRING_unsafe(nsIndex::Integer, s::AbstractString)
    GC.@preserve s identifier_tuple=anonymous_struct_tuple(UA_STRING_unsafe(s),
        fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_STRING, identifier_tuple)
end

function UA_NODEID_GUID(nsIndex::Integer, guid::UA_Guid)
    identifier_tuple = anonymous_struct_tuple(guid, fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_GUID, identifier_tuple)
end

#TODO: since UA_NodeId_delete(Ptr{UA_NodeId}) is defined, do I still need this function?
function UA_NodeId_delete(n::UA_NodeId)
    if n.identifier == UA_NODEIDTYPE_STRING
        UA_String_delete(n.identifier.string)
    end
    return nothing
end

function UA_NodeId_equal(n1::Union{Ref{UA_NodeId}, Ptr{UA_NodeId}},
        n2::Union{Ref{UA_NodeId}, Ptr{UA_NodeId}})
    UA_NodeId_order(n1, n2) == UA_ORDER_EQ
end

function UA_NodeId_equal(n1, n2)
    UA_NodeId_equal(wrap_ref(n1), wrap_ref(n2))
end

## ExpandedNodeId
# String `ns_uri` is copied to newly allocated memory that needs to be freed.
function UA_EXPANDEDNODEID_NUMERIC_ALLOC(nsIndex::Integer,
        identifier::Integer,
        ns_uri::AbstractString,
        server_ind::Integer)
    nodeid = UA_NODEID_NUMERIC(nsIndex, identifier)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    return UA_ExpandedNodeId(nodeid, ua_ns_uri, server_ind)
end

# Strings `s` and `ns_uri` are copied to newly allocated memory that needs to be freed.
function UA_EXPANDEDNODEID_STRING_ALLOC(nsIndex::Integer,
        s::AbstractString,
        ns_uri::AbstractString,
        server_ind::Integer)
    nodeid = UA_NODEID_STRING_ALLOC(nsIndex, s)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    return UA_ExpandedNodeId(nodeid, ua_ns_uri, server_ind)
end

# String `ns_uri` is copied to newly allocated memory that needs to be freed.
function UA_EXPANDEDNODEID_GUID_ALLOC(nsIndex::Integer,
        guid::UA_Guid,
        ns_uri::AbstractString,
        server_ind::Integer)
    nodeid = UA_NODEID_GUID(nsIndex, guid)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    return UA_ExpandedNodeId(nodeid, ua_ns_uri, server_ind)
end

function UA_ExpandedNodeId_equal(n1::Ref{UA_ExpandedNodeId}, n2::Ref{UA_ExpandedNodeId})
    return UA_ExpandedNodeId_order(n1, n2) == UA_ORDER_EQ
end

function UA_ExpandedNodeId_delete(n::UA_ExpandedNodeId)
    UA_NodeId_delete(n.nodeId)
    UA_String_delete(n.namespaceUri)
    return nothing
end

## QualifiedName
UA_QualifiedName_isNull(q::UA_QualifiedName) = (q.namespaceIndex == 0 && q.name.length == 0)
UA_QualifiedName_isNull(q::Ref{UA_QualifiedName}) = UA_QualifiedName_isNull(q[])

# String `s` must be kept valid using GC.@preserve as long as the return value is used. It is recommended to use UA_QUALIFIEDNAME_ALLOC with a subsequent call to UA_QualifiedName_delete.
function UA_QUALIFIEDNAME(nsIndex::Integer, s::AbstractString)
    GC.@preserve s return UA_QualifiedName(nsIndex, UA_STRING_unsafe(s))
end

# String `s` is copied to newly allocated memory that needs to be freed.
function UA_QUALIFIEDNAME_ALLOC(nsIndex::Integer, s::AbstractString)
    return UA_QualifiedName(nsIndex, UA_String_fromChars(s))
end

UA_QualifiedName_delete(q::UA_QualifiedName) = UA_String_delete(q.name)

## LocalizedText
# Strings `locale` and `text` must be kept valid using GC.@preserve as long as the return value is used. It is recommended to use UA_QUALIFIEDNAME_ALLOC with a subsequent call to UA_LocalizedText_delete.
function UA_LOCALIZEDTEXT_unsafe(locale::AbstractString, text::AbstractString)
    GC.@preserve locale text begin
        return UA_LocalizedText(UA_STRING_unsafe(locale), UA_STRING_unsafe(text))
    end
end

# Strings `locale` and `text` are copied to newly allocated memory that needs to be freed
function UA_LOCALIZEDTEXT_ALLOC(locale::AbstractString, text::AbstractString)
    return UA_LocalizedText(UA_STRING_ALLOC(locale), UA_STRING_ALLOC(text))
end

UA_LocalizedText_delete(l::UA_LocalizedText) = UA_String_delete(l.text)

## NumericRange
function UA_NUMERICRANGE(s::AbstractArray)
    nr = Ref{UA_NumericRange}()
    retval = GC.@preserve s UA_NumericRange_parse(nr, UA_STRING_unsafe(s))
    retval != UA_STATUSCODE_GOOD &&
        error("Parsing of NumericRange \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return nr[]
end

## Variant
function unsafe_size(v::UA_Variant)
    UA_Variant_isScalar(v) && return ()
    v.arrayDimensionsSize == 0 && return (Int(v.arrayLength),)
    return Tuple([Int(unsafe_load(v.arrayDimensions, d + 1))
                  for d in 0:(v.arrayDimensionsSize - 1)])
end

unsafe_size(p::Ref{UA_Variant}) = unsafe_size(unsafe_load(p))
Base.length(v::UA_Variant) = Int(v.arrayLength)
Base.length(p::Ref{UA_Variant}) = length(unsafe_load(p))

function UA_Variant_new_copy(value::AbstractArray{T, N},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T, N}
    var = UA_Variant_new()
    var.type = type_ptr
    var.storageType = UA_VARIANT_DATA
    var.arrayLength = length(value)
    var.arrayDimensionsSize = length(size(value))
    var.data = UA_Array_new(vec(permutedims(value, reverse(1:N))), type_ptr)
    var.arrayDimensions = UA_UInt32_Array_new(reverse(size(value)))
    return var
end

function UA_Variant_new_copy(value::Ref{T},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{AbstractFloat, Integer}}
    var = UA_Variant_new()
    var.type = type_ptr
    var.storageType = UA_VARIANT_DATA
    var.arrayLength = 0
    var.arrayDimensionsSize = length(size(value))
    UA_Variant_setScalarCopy(var, value, type_ptr)
    var.arrayDimensions = C_NULL
    return var
end

function UA_Variant_new_copy(value::T,
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{AbstractFloat, Integer}}
    return UA_Variant_new_copy(Ref(value), type_ptr)
end

function UA_Variant_new_copy(value, type_sym::Symbol)
    UA_Variant_new_copy(value, ua_data_type_ptr(Val(type_sym)))
end

function Base.unsafe_wrap(v::UA_Variant)
    type = juliadatatype(v.type)
    data = reinterpret(Ptr{type}, v.data)
    UA_Variant_isScalar(v) && return GC.@preserve data unsafe_load(data)
    values = GC.@preserve data unsafe_wrap(Array, data, unsafe_size(v))
    values_row_major = reshape(values, unsafe_size(v))
    return permutedims(values_row_major, reverse(1:(Int64(v.arrayDimensionsSize)))) # To column major format; TODO: Which permutation is right? TODO: can make allocation free using PermutedDimsArray?
end

Base.unsafe_wrap(p::Ref{UA_Variant}) = unsafe_wrap(unsafe_load(p))
UA_Variant_isEmpty(v::UA_Variant) = v.type == C_NULL
UA_Variant_isEmpty(p::Ref{UA_Variant}) = UA_Variant_isEmpty(unsafe_load(p))
UA_Variant_isScalar(v::UA_Variant) = v.arrayLength == 0 && v.data > UA_EMPTY_ARRAY_SENTINEL
UA_Variant_isScalar(p::Ref{UA_Variant}) = UA_Variant_isScalar(unsafe_load(p))

function UA_Variant_hasScalarType(v::UA_Variant, type::Ref{UA_DataType})
    return UA_Variant_isScalar(v) && type == v.type
end

function UA_Variant_hasScalarType(p::Ref{UA_Variant}, type::Ref{UA_DataType})
    return UA_Variant_hasScalarType(unsafe_load(p), type)
end

function UA_Variant_hasArrayType(v::UA_Variant, type::Ref{UA_DataType})
    return !UA_Variant_isScalar(v) && type == v.type
end

function UA_Variant_hasArrayType(p::Ref{UA_Variant}, type::Ref{UA_DataType})
    return UA_Variant_hasArrayType(unsafe_load(p), type)
end
