#function that wraps a non-ref/non-ptr argument into a ref of appropriate type.
wrap_ref(x::Union{Ref, Ptr}) = x #no-op fall back
wrap_ref(x) = Ref(x)

function __extract_ExtensionObject(eo::UA_ExtensionObject)
    if eo.encoding != UA_EXTENSIONOBJECT_DECODED
        error("can't make sense of this extension object yet.")
    else
        v = eo.content.decoded
        type = juliadatatype(v.type)
        data = reinterpret(Ptr{type}, v.data)
        return GC.@preserve v type data unsafe_load(data)
    end
end

function __get_juliavalues_from_variant(v, type)
    wrapped = unsafe_wrap(v)::type
    if typeof(wrapped) == UA_ExtensionObject
        wrapped = __extract_ExtensionObject.(wrapped)
    elseif typeof(wrapped) <: Array && eltype(wrapped) == UA_ExtensionObject
        wrapped = __extract_ExtensionObject.(wrapped)
    end

    #now deal with special types
    if typeof(wrapped) <: Union{UA_ComplexNumberType, UA_DoubleComplexNumberType}
        r = complex(wrapped)
    elseif typeof(wrapped) <: Array &&
           eltype(wrapped) <: Union{UA_ComplexNumberType, UA_DoubleComplexNumberType}
        r = complex.(wrapped)
    elseif typeof(wrapped) <: Union{UA_RationalNumber, UA_UnsignedRationalNumber}
        r = Rational(wrapped)
    elseif typeof(wrapped) <: Array &&
           eltype(wrapped) <: Union{UA_RationalNumber, UA_UnsignedRationalNumber}
        r = Rational.(wrapped)
    elseif typeof(wrapped) == UA_String
        r = unsafe_string(wrapped)
    elseif typeof(wrapped) <: Array && eltype(wrapped) == UA_String
        r = unsafe_string.(wrapped)
    else
        r = wrapped
    end
    # r2 = deepcopy(r) #don't need to copy due to Base.unsafe_wrap(p::Ptr{UA_Variant})
    # using unsafe_load, which already copies (see types.jl)
    return r
end

function __determinetype(type)
    if type <: AbstractString
        t = unsafe_load(UA_TYPES_PTRS[UA_TYPES_STRING].typeId)
    elseif type == Complex{Float32}
        t = unsafe_load(UA_TYPES_PTRS[UA_TYPES_COMPLEXNUMBERTYPE].typeId)
    elseif type == Complex{Float64}
        t = unsafe_load(UA_TYPES_PTRS[UA_TYPES_DOUBLECOMPLEXNUMBERTYPE].typeId)
    elseif type == Rational{Int32}
        t = unsafe_load(UA_TYPES_PTRS[UA_TYPES_RATIONALNUMBER].typeId)
    elseif type == Rational{UInt32}
        t = unsafe_load(UA_TYPES_PTRS[UA_TYPES_UNSIGNEDRATIONALNUMBER].typeId)
    else
        t = unsafe_load(ua_data_type_ptr_default(type).typeId)
    end
    return t
end

function __callback_wrap(method::Function)
    return UA_MethodCallback_generate(method)
end

function __callback_wrap(method)
    return method
end

#checks the consistency of arraydimensionssize, arraydimensions and valuerank
function __check_valuerank_arraydimensions_consistency(valuerank, arraydimensions)
    #see here for specification: https://reference.opcfoundation.org/Core/Part3/v105/docs/8.6
    if valuerank >= -3 && valuerank <= 0 && length(arraydimensions) == 0 #scalar or array of one dimension
        consistent = true
    elseif valuerank > 0 && length(arraydimensions) == valuerank #array of valuerank dimension
        consistent = true
    else
        consistent = false
    end
    return consistent
end
