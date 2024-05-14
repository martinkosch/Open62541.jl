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

function __get_juliavalues_from_variant(v)
    wrapped = unsafe_wrap(v)
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
    elseif typeof(wrapped) == UA_String
        r = unsafe_string(wrapped)
    elseif typeof(wrapped) <: Array && eltype(wrapped) == UA_String
        r = unsafe_string.(wrapped)
    else
        r = deepcopy(wrapped) #TODO: do I need to copy here? test for memory safety!
    end
    return r
end