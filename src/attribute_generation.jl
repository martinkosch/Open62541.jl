### attribute generation functions
##generic functions
function UA_VALUERANK(N::Integer)
    N == 1 && return UA_VALUERANK_ONE_DIMENSION
    N == 2 && return UA_VALUERANK_TWO_DIMENSIONS
    N == 3 && return UA_VALUERANK_THREE_DIMENSIONS
    return N
end

function __set_generic_attributes!(attr,
        name,
        desc,
        type,
        localization)
    displayname = UA_LOCALIZEDTEXT(localization, name)
    description = UA_LOCALIZEDTEXT(localization, desc)
    UA_LocalizedText_copy(displayname, attr.displayName)
    UA_LocalizedText_copy(description, attr.description)
    attr.dataType = unsafe_load(ua_data_type_ptr_default(type).typeId)
    UA_LocalizedText_delete(displayname)
    UA_LocalizedText_delete(description)
    return nothing
end

function __set_scalar_attributes!(attr,
        input::T,
        valuerank) where {T}
    type_ptr = ua_data_type_ptr_default(T)
    attr.valueRank = valuerank
    UA_Variant_setScalarCopy(attr.value, wrap_ref(input), type_ptr)
    return nothing
end

function __set_array_attributes!(attr,
        input::AbstractArray{T, N},
        valuerank) where {T, N}
    type_ptr = ua_data_type_ptr_default(T)
    attr.valueRank = valuerank
    arraydims = UA_UInt32_Array_new(reverse(size(input))) #implicit conversion to uint32
    attr.arrayDimensions = arraydims
    attr.arrayDimensionsSize = length(arraydims)
    ua_arr = UA_Array_new(vec(permutedims(input, reverse(1:N))), type_ptr) # Allocate new UA_Array from input with C style indexing
    UA_Variant_setArray(attr.value,
        ua_arr,
        length(input),
        type_ptr)
    attr.value.arrayDimensions = arraydims
    attr.value.arrayDimensionsSize = length(arraydims)
    return nothing
end

#variable functions
function __generic_variable_attributes(displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        type::DataType,
        localization::AbstractString = "en-US")
    attr = UA_VariableAttributes_new()
    retval = UA_VariableAttributes_copy(UA_VariableAttributes_default, attr)
    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            type,
            localization)
        attr.accessLevel = accesslevel
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

function UA_generate_variable_attributes(input::AbstractArray{T, N},
        displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        valuerank::Integer = UA_VALUERANK(N)) where {T, N}
    attr = __generic_variable_attributes(displayname, description, accesslevel, T)
    __set_array_attributes!(attr, input, valuerank)
    return attr
end

function UA_generate_variable_attributes(input::Union{Ref{T}, Ptr{T}, T},
        displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        valuerank::Integer = UA_VALUERANK_SCALAR) where {T <: Union{AbstractFloat, Integer}}
    type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)
    attr = __generic_variable_attributes(displayname, description, accesslevel, T)
    __set_scalar_attributes!(attr, input, valuerank)
    return attr
end

#variable type functions
function __generic_variabletype_attributes(displayname::AbstractString,
        description::AbstractString,
        type::DataType,
        localization::AbstractString = "en-US")
    attr = UA_VariableTypeAttributes_new()
    retval = UA_VariableTypeAttributes_copy(UA_VariableTypeAttributes_default, attr)
    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            type,
            localization)
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

function UA_generate_variabletype_attributes(input::AbstractArray{T, N},
        displayname::AbstractString,
        description::AbstractString,
        valuerank::Integer = UA_VALUERANK(N)) where {T, N}
    attr = __generic_variabletype_attributes(displayname, description, T)
    __set_array_attributes!(attr, input, valuerank)
    return attr
end

function UA_generate_variabletype_attributes(input::Union{Ref{T}, Ptr{T}, T},
        displayname::AbstractString,
        description::AbstractString,
        valuerank::Integer = UA_VALUERANK_SCALAR) where {T <: Union{AbstractFloat, Integer}}
    attr = __generic_variabletype_attributes(displayname, description, T)
    __set_scalar_attributes!(attr, input, valuerank)
    return attr
end
