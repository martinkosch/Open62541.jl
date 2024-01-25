### attribute generation functions

##generic functions
function UA_VALUERANK(N::Integer)
    N == 1 && return UA_VALUERANK_ONE_DIMENSION
    N == 2 && return UA_VALUERANK_TWO_DIMENSIONS
    N == 3 && return UA_VALUERANK_THREE_DIMENSIONS
    return N
end

"""
```
UA_ACCESSLEVEL(; read = false, write = false, historyread = false, 
        historywrite = false, semanticchange = false, statuswrite = false, 
        timestampwrite = false)::UInt8
```
calculates a `UInt8` number expressing how the value of a variable can be accessed.
Default is to disallow all operations. The meaning of the keywords is explained 
here: https://reference.opcfoundation.org/Core/Part3/v105/docs/8.57
"""
function UA_ACCESSLEVEL(;
        read::Bool = false,
        write::Bool = false,
        historyread::Bool = false,
        historywrite::Bool = false,
        semanticchange::Bool = false,
        statuswrite::Bool = false,
        timestampwrite::Bool = false)
    al = UA_Byte(0)
    al = read ? al | UA_ACCESSLEVELMASK_READ : al
    al = write ? al | UA_ACCESSLEVELMASK_WRITE : al
    al = historyread ? al | UA_ACCESSLEVELMASK_HISTORYREAD : al
    al = historywrite ? al | UA_ACCESSLEVELMASK_HISTORYWRITE : al
    al = semanticchange ? al | UA_ACCESSLEVELMASK_SEMANTICCHANGE : al
    al = statuswrite ? al | UA_ACCESSLEVELMASK_STATUSWRITE : al
    al = timestampwrite ? al | UA_ACCESSLEVELMASK_TIMESTAMPWRITE : al
    return UA_Byte(al)
end

"""
```
UA_WRITEMASK(; accesslevel = false, arraydimensions = false,
        browsename = false, containsnoloops = false, datatype = false,
        description = false, displayname = false, eventnotifier = false,
        executable = false, historizing = false, inversename = false,
        isabstract = false, minimumsamplinginterval = false, nodeclass = false,
        nodeid = false, symmetric = false, useraccesslevel = false, 
        userexecutable = false, userwritemask = false, valuerank = false,
        writemask = false, valueforvariabletype = false)::UInt32
```
calculates a `UInt32` number expressing which attributes of a node are writeable.
The meaning of the keywords is explained here: https://reference.opcfoundation.org/Core/Part3/v105/docs/8.60

If the specific node type does not support an attribute, the corresponding keyword
must be set to false. *This is currently not enforced automatically.*
"""
function UA_WRITEMASK(; accesslevel = false, arraydimensions = false,
        browsename = false, containsnoloops = false, datatype = false,
        description = false, displayname = false, eventnotifier = false,
        executable = false, historizing = false, inversename = false,
        isabstract = false, minimumsamplinginterval = false, nodeclass = false,
        nodeid = false, symmetric = false, useraccesslevel = false,
        userexecutable = false, userwritemask = false, valuerank = false,
        writemask = false, valueforvariabletype = false)
    wm = UInt32(0)
    wm = accesslevel ? wm | UA_WRITEMASK_ACCESSLEVEL : wm
    wm = arraydimensions ? wm | UA_WRITEMASK_ARRRAYDIMENSIONS : wm #Note: RRR is a typo in open62541, not here.
    wm = browsename ? wm | UA_WRITEMASK_BROWSENAME : wm
    wm = containsnoloops ? wm | UA_WRITEMASK_CONTAINSNOLOOPS : wm
    wm = datatype ? wm | UA_WRITEMASK_DATATYPE : wm
    wm = description ? wm | UA_WRITEMASK_DESCRIPTION : wm
    wm = displayname ? wm | UA_WRITEMASK_DISPLAYNAME : wm
    wm = eventnotifier ? wm | UA_WRITEMASK_EVENTNOTIFIER : wm
    wm = executable ? wm | UA_WRITEMASK_EXECUTABLE : wm
    wm = historizing ? wm | UA_WRITEMASK_HISTORIZING : wm
    wm = inversename ? wm | UA_WRITEMASK_INVERSENAME : wm
    wm = isabstract ? wm | UA_WRITEMASK_ISABSTRACT : wm
    wm = minimumsamplinginterval ? wm | UA_WRITEMASK_MINIMUMSAMPLINGINTERVAL : wm
    wm = nodeclass ? wm | UA_WRITEMASK_NODECLASS : wm
    wm = nodeid ? wm | UA_WRITEMASK_NODEID : wm
    wm = symmetric ? wm | UA_WRITEMASK_SYMMETRIC : wm
    wm = useraccesslevel ? wm | UA_WRITEMASK_USERACCESSLEVEL : wm
    wm = userexecutable ? wm | UA_WRITEMASK_USEREXECUTABLE : wm
    wm = userwritemask ? wm | UA_WRITEMASK_USERWRITEMASK : wm
    wm = valuerank ? wm | UA_WRITEMASK_VALUERANK : wm
    wm = writemask ? wm | UA_WRITEMASK_WRITEMASK : wm
    wm = valueforvariabletype ? wm | UA_WRITEMASK_VALUEFORVARIABLETYPE : wm
    return wm
end

const UA_USERWRITEMASK = UA_WRITEMASK

"""
```
UA_EVENTNOTIFIER(; subscribetoevent = false, historyread = false, 
        historywrite = false)::UInt8
```
calculates a `UInt8` number expressing whether a node can be used to subscribe to
events and/or read/write historic events.

Meaning of keywords is explained here: https://reference.opcfoundation.org/Core/Part3/v105/docs/8.59
"""
function UA_EVENTNOTIFIER(;
        subscribetoevent = false,
        historyread = false,
        historywrite = false)
    en = UInt8(0)
    en = subscribetoevent ? en | UA_EVENTNOTIFIER_SUBSCRIBE_TO_EVENT : en
    en = historyread ? en | UA_EVENTNOTIFIER_HISTORY_READ : en
    en = historywrite ? en | UA_EVENTNOTIFIER_HISTORY_WRITE : en
    return UInt8(en)
end

#function that allows setting attributes that occur in all node types
function __set_generic_attributes!(attr,
        name,
        desc,
        localization,
        writemask,
        userwritemask)
    displayname = UA_LOCALIZEDTEXT(localization, name)
    description = UA_LOCALIZEDTEXT(localization, desc)
    UA_LocalizedText_copy(displayname, attr.displayName)
    UA_LocalizedText_copy(description, attr.description)
    UA_LocalizedText_delete(displayname)
    UA_LocalizedText_delete(description)
    if !isnothing(writemask)
        attr.writeMask = writemask
    end
    if !isnothing(userwritemask)
        attr.userWriteMask = userwritemask
    end
    return nothing
end

function __set_scalar_attributes!(attr,
        value::T,
        valuerank) where {T}
    type_ptr = ua_data_type_ptr_default(T)
    attr.valueRank = valuerank
    UA_Variant_setScalarCopy(attr.value, wrap_ref(value), type_ptr)
    return nothing
end

function __set_array_attributes!(attr,
        value::AbstractArray{T, N},
        valuerank) where {T, N}
    type_ptr = ua_data_type_ptr_default(T)
    attr.valueRank = valuerank
    #Note: need array dims twice, once to put into the variant, i.e., attr.value 
    #and once for the attr structure itself. If the same array is put into both 
    #places, using for example UA_VariableAttributes_delete(attr) leads to free-ing
    #the same memory twice --> julia crash (hard to track down!)
    arraydims_variant = UA_UInt32_Array_new(reverse(size(value))) 
    arraydims_attr = UA_UInt32_Array_new(reverse(size(value))) 
    attr.arrayDimensions = arraydims_attr
    attr.arrayDimensionsSize = length(arraydims_attr)
    ua_arr = UA_Array_new(vec(permutedims(value, reverse(1:N))), type_ptr) # Allocate new UA_Array from value with C style indexing
    UA_Variant_setArray(attr.value,
        ua_arr,
        length(value),
        type_ptr)
    attr.value.arrayDimensions = arraydims_variant
    attr.value.arrayDimensionsSize = length(arraydims_variant)
    return nothing
end

#VariableAttributes
"""
```
UA_generate_variable_attributes(; value::Union{AbstractArray{T}, T},
    displayname::AbstractString, description::AbstractString,
    localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    accesslevel::Union{Nothing, UInt8} = nothing,
    useraccesslevel::Union{Nothing, UInt8} = nothing,
    minimumsamplinginterval::Union{Nothing, Float64} = nothing,
    historizing::Union{Nothing, Bool} = nothing,
    valuerank::Union{Integer, Nothing} = nothing)::Ptr{UA_VariableAttributes} where {T <: Union{AbstractFloat, Integer}}
```
generates a `UA_VariableAttributes` object. Memory for the object is allocated 
by C and needs to be cleaned up by calling `UA_VariableAttributes_delete(x)` 
after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_VariableAttributes_default[]`.
If nothing is given for keyword `valuerank`, then it is either set to `UA_VALUERANK_SCALAR`
(if `value` is a scalar), or to the dimensionality of the supplied array
(i.e., `N` for an AbstractArray{T,N}).

See also [`UA_WRITEMASK`](@ref), [`UA_USERWRITEMASK`](@ref), [`UA_ACCESSLEVEL`](@ref),
and [`UA_USERACCESSLEVEL`](@ref) for information on how to generate the respective 
keyword inputs.
"""
function UA_generate_variable_attributes(; value::Union{AbstractArray{T}, T},
        displayname::AbstractString, description::AbstractString,
        localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        accesslevel::Union{Nothing, UInt8} = nothing,
        useraccesslevel::Union{Nothing, UInt8} = nothing,
        minimumsamplinginterval::Union{Nothing, Float64} = nothing,
        historizing::Union{Nothing, Bool} = nothing,
        valuerank::Union{Nothing, Integer} = nothing) where {T <: Union{AbstractFloat, Integer}}
    attr = __generate_variable_attributes(value, displayname, description,
        localization, writemask, userwritemask, accesslevel, useraccesslevel,
        minimumsamplinginterval, historizing, valuerank)
    return attr
end

function __generate_variable_attributes(value::AbstractArray{T, N}, displayname,
        description, localization, writemask, userwritemask, accesslevel,
        useraccesslevel, minimumsamplinginterval, historizing, valuerank) where {T, N}
    if isnothing(valuerank)
        valuerank = UA_VALUERANK(N)
    end
    attr = __generic_variable_attributes(displayname, description, localization,
        writemask, userwritemask, accesslevel, useraccesslevel, 
        minimumsamplinginterval, historizing, T)
    __set_array_attributes!(attr, value, valuerank)
    return attr
end

function __generate_variable_attributes(value::T, displayname, description,
        localization, writemask, userwritemask, accesslevel, useraccesslevel,
        minimumsamplinginterval, historizing, valuerank) where T 
    if isnothing(valuerank)
        valuerank = UA_VALUERANK_SCALAR
    end
    attr = __generic_variable_attributes(displayname, description, localization,
        writemask, userwritemask, accesslevel, useraccesslevel, 
        minimumsamplinginterval, historizing, T)
    __set_scalar_attributes!(attr, value, valuerank)
    return attr
end

function __generic_variable_attributes(displayname, description, localization,
        writemask, userwritemask, accesslevel, useraccesslevel,
        minimumsamplinginterval, historizing, type)
    attr = UA_VariableAttributes_new()
    retval = UA_VariableAttributes_copy(UA_VariableAttributes_default, attr)
    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr, displayname, description, localization,
            writemask, userwritemask)
        if !isnothing(accesslevel)
            attr.accessLevel = accesslevel
        end
        if !isnothing(useraccesslevel)
            attr.userAccessLevel = useraccesslevel
        end
        if !isnothing(minimumsamplinginterval)
            attr.minimumSamplingInterval = minimumsamplinginterval
        end
        if !isnothing(historizing)
            attr.historizing = historizing
        end
        attr.dataType = unsafe_load(ua_data_type_ptr_default(type).typeId)
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#VariableType Attributes
"""
```
UA_generate_variabletype_attributes(; value::Union{AbstractArray{T}, T},
    displayname::AbstractString, description::AbstractString,
    localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    valuerank::Union{Nothing, Integer} = nothing,
    isabstract::Union{Nothing, Bool})::Ptr{UA_VariableTypeAttributes} where {T <: Union{AbstractFloat, Integer}}
```
generates a `UA_VariableTypeAttributes` object. Memory for the object is allocated 
by C and needs to be cleaned up by calling `UA_VariableAttributes_delete(x)` 
after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_VariableAttributes_default[]`.
If nothing is given for keyword `valuerank`, then it is either set to `UA_VALUERANK_SCALAR`
(if `value` is a scalar), or to the dimensionality of the supplied array
(i.e., `N` for an AbstractArray{T,N}).

See also [`UA_WRITEMASK`](@ref), [`UA_USERWRITEMASK`](@ref) for information on 
how to generate the respective keyword inputs.
"""
function UA_generate_variabletype_attributes(; value::Union{AbstractArray{T}, T},
        displayname::AbstractString, description::AbstractString,
        localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        valuerank::Union{Nothing, Integer} = nothing,
        isabstract::Union{Nothing, Bool} = nothing) where {T <: Union{AbstractFloat, Integer}}
    attr = __generate_variabletype_attributes(value, displayname, description,
        localization, writemask, userwritemask, valuerank, isabstract)
    return attr
end

function __generate_variabletype_attributes(value::AbstractArray{T,N}, displayname, 
        description, localization, writemask, userwritemask, valuerank, isabstract) where {T,N}
    if isnothing(valuerank)
        valuerank = UA_VALUERANK(N)
    end
    attr = __generic_variabletype_attributes(displayname, description, localization,
            writemask, userwritemask, isabstract, T)
    __set_array_attributes!(attr, value, valuerank)
    return attr
end

function __generate_variabletype_attributes(value::T, displayname, 
        description, localization, writemask, userwritemask, valuerank, isabstract) where {T}
    if isnothing(valuerank)
        valuerank = UA_VALUERANK_SCALAR
    end
    attr = __generic_variabletype_attributes(displayname, description, localization,
            writemask, userwritemask, isabstract, T)
    __set_scalar_attributes!(attr, value, valuerank)
    return attr
end
    
function __generic_variabletype_attributes(displayname, description, localization, 
        writemask, userwritemask, isabstract, type) 
    attr = UA_VariableTypeAttributes_new()
    retval = UA_VariableTypeAttributes_copy(UA_VariableTypeAttributes_default, attr)
    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr, displayname, description, localization,
            writemask, userwritemask)
        if !isnothing(isabstract)
            attr.isAbstract = isabstract
        end
        attr.dataType = unsafe_load(ua_data_type_ptr_default(type).typeId)
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#ObjectAttributes
"""
```
UA_generate_object_attributes(; displayname::AbstractString,
    description::AbstractString, localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    eventnotifier::Union{Nothing, UInt8} = nothing)::Ptr{UA_ObjectAttributes}
```
generates a `UA_ObjectAttributes` object. Memory for the object is allocated by 
C and needs to be cleaned up by calling `UA_ObjectAttributes_delete(x)` after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_ObjectAttributes_default[]`

See also [`UA_WRITEMASK`](@ref), [`UA_USERWRITEMASK`](@ref), [`UA_EVENTNOTIFIER`](@ref)
for information on how to generate the respective keyword inputs.
"""
function UA_generate_object_attributes(; displayname::AbstractString,
        description::AbstractString, localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        eventnotifier::Union{Nothing, UInt8} = nothing)
    attr = UA_ObjectAttributes_new()
    retval = UA_ObjectAttributes_copy(UA_ObjectAttributes_default, attr)

    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            localization,
            writemask,
            userwritemask)
        if !isnothing(eventnotifier)
            attr.eventNotifier = eventnotifier
        end
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#ObjectTypeAttributes
"""
```
UA_generate_objecttype_attributes(; displayname::AbstractString,
    description::AbstractString, localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    isabstract::Union{Nothing, Bool} = nothing)::Ptr{UA_ObjectTypeAttributes}
```
generates a `UA_ObjectTypeAttributes` object. Memory for the object is allocated by 
C and needs to be cleaned up by calling `UA_ObjectTypeAttributes_delete(x)` after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_ObjectTypeAttributes_default[]`

See also [`UA_WRITEMASK`](@ref) and [`UA_USERWRITEMASK`](@ref) for information on 
how to generate the respective keyword inputs.
"""
function UA_generate_objecttype_attributes(; displayname::AbstractString,
        description::AbstractString, localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        isabstract::Union{Nothing, Bool} = nothing)
    attr = UA_ObjectTypeAttributes_new()
    retval = UA_ObjectTypeAttributes_copy(UA_ObjectTypeAttributes_default, attr)

    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            localization,
            writemask,
            userwritemask)
        if !isnothing(isabstract)
            attr.isAbstract = isabstract
        end
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#MethodAttributes
"""
```
UA_generate_method_attributes(; displayname::AbstractString,
    description::AbstractString, localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    isabstract::Union{Nothing, Bool} = nothing)::Ptr{UA_MethodAttributes}
```
generates a `UA_MethodAttributes` object. Memory for the object is allocated by 
C and needs to be cleaned up by calling `UA_MethodAttributes_delete(x)` after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_MethodAttributes_default[]`

See also [`UA_WRITEMASK`](@ref) and [`UA_USERWRITEMASK`](@ref) for information on 
how to generate the respective keyword inputs.
"""
function UA_generate_method_attributes(; displayname::AbstractString,
        description::AbstractString, localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        executable::Union{Nothing, Bool} = nothing,
        userexecutable::Union{Nothing, Bool} = nothing)
    attr = UA_MethodAttributes_new()
    retval = UA_MethodAttributes_copy(UA_MethodAttributes_default, attr)

    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            localization,
            writemask,
            userwritemask)
        if !isnothing(executable)
            attr.executable = executable
        end
        if !isnothing(userexecutable)
            attr.userExecutable = userexecutable
        end
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#ViewAttributes
"""
```
UA_generate_view_attributes(; displayname::AbstractString,
    description::AbstractString, localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    containsnoloops::Union{Nothing, Bool} = nothing,
    eventnotifier::Union{Nothing, UInt8} = nothing)::Ptr{UA_ViewAttributes}
```
generates a `UA_ViewAttributes` object. Memory for the object is allocated by 
C and needs to be cleaned up by calling `UA_ViewAttributes_delete(x)` after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_ViewAttributes_default[]`

See also [`UA_WRITEMASK`](@ref), [`UA_USERWRITEMASK`](@ref) and [`UA_EVENTNOTIFIER`](@ref) 
for information on how to generate the respective keyword inputs.
"""
function UA_generate_view_attributes(; displayname::AbstractString,
        description::AbstractString, localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        containsnoloops::Union{Nothing, Bool} = nothing,
        eventnotifier::Union{Nothing, UInt8} = nothing)
    attr = UA_ViewAttributes_new()
    retval = UA_ViewAttributes_copy(UA_ViewAttributes_default, attr)

    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            localization,
            writemask,
            userwritemask)
        if !isnothing(containsnoloops)
            attr.containsNoLoops = containsnoloops
        end
        if !isnothing(eventnotifier)
            attr.eventNotifier = eventnotifier
        end
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#DataTypeAttributes
"""
```
UA_generate_datatype_attributes(; displayname::AbstractString,
    description::AbstractString, localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    isabstract::Union{Nothing, Bool} = nothing)::Ptr{UA_DataTypeAttributes}
```
generates a `UA_DataTypeAttributes` object. Memory for the object is allocated by 
C and needs to be cleaned up by calling `UA_DataTypeAttributes_delete(x)` after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_DataTypeAttributes_default[]`

See also [`UA_WRITEMASK`](@ref) and [`UA_USERWRITEMASK`](@ref) for information on 
how to generate the respective keyword inputs.
"""
function UA_generate_datatype_attributes(; displayname::AbstractString,
        description::AbstractString, localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        isabstract::Union{Nothing, Bool} = nothing)
    attr = UA_DataTypeAttributes_new()
    retval = UA_DataTypeAttributes_copy(UA_DataTypeAttributes_default, attr)

    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            localization,
            writemask,
            userwritemask)
        if !isnothing(isabstract)
            attr.isAbstract = isabstract
        end
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

#ReferenceTypeAttributes
"""
```
UA_generate_referencetype_attributes(; displayname::AbstractString,
    description::AbstractString, localization::AbstractString = "en-US",
    writemask::Union{Nothing, UInt32} = nothing,
    userwritemask::Union{Nothing, UInt32} = nothing,
    isabstract::Union{Nothing, Bool} = nothing
    symmetric::Union{Nothing, Bool} = nothing,
    inversename::Union{Nothing, AbstractString} = nothing)::Ptr{UA_ReferenceTypeAttributes}
```
generates a `UA_ReferenceTypeAttributes` object. Memory for the object is allocated by 
C and needs to be cleaned up by calling `UA_ReferenceTypeAttributes_delete(x)` after usage.

For keywords given as `nothing`, the respective default value is used, see `UA_ReferenceTypeAttributes_default[]`

See also [`UA_WRITEMASK`](@ref) and [`UA_USERWRITEMASK`](@ref) for information on 
how to generate the respective keyword inputs.
"""
function UA_generate_referencetype_attributes(; displayname::AbstractString,
        description::AbstractString, localization::AbstractString = "en-US",
        writemask::Union{Nothing, UInt32} = nothing,
        userwritemask::Union{Nothing, UInt32} = nothing,
        isabstract::Union{Nothing, Bool} = nothing,
        symmetric::Union{Nothing, Bool} = nothing,
        inversename::Union{Nothing, AbstractString} = nothing)
    attr = UA_ReferenceTypeAttributes_new()
    retval = UA_ReferenceTypeAttributes_copy(UA_ReferenceTypeAttributes_default, attr)

    if retval == UA_STATUSCODE_GOOD
        __set_generic_attributes!(attr,
            displayname,
            description,
            localization,
            writemask,
            userwritemask)
        if !isnothing(isabstract)
            attr.isAbstract = isabstract
        end
        if !isnothing(symmetric)
            attr.symmetric = symmetric
        end
        if !isnothing(inversename)
            lt_inv = UA_LOCALIZEDTEXT(localization, inversename)
            UA_LocalizedText_copy(lt_inv, attr.inverseName)
            UA_LocalizedText_delete(lt_inv)
        end
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end