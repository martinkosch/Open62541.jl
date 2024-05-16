#TODO: all of this needs docstrings of course.

#Preliminary definitions
abstract type AbstractOpen62541Wrapper end

Jpointer(x::AbstractOpen62541Wrapper) = getfield(x, :ptr)
function Base.getproperty(x::AbstractOpen62541Wrapper, f::Symbol)
    unsafe_load(getproperty(Jpointer(x), f))
end

function Base.unsafe_convert(::Type{Ptr{T}}, obj::AbstractOpen62541Wrapper) where {T}
    Base.unsafe_convert(Ptr{T}, Jpointer(obj))
end

Base.show(io::IO, ::MIME"text/plain", v::AbstractOpen62541Wrapper) = print(io, "$(typeof(v)):\n"*UA_print(Jpointer(v)))

## Useful basic types
#String
mutable struct JUA_String <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_String}
    function JUA_String(s::AbstractString)
        obj = new(UA_STRING(s))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_String)
    UA_String_delete(Jpointer(obj))
end

ua_data_type_ptr_default(::Type{JUA_String}) = ua_data_type_ptr_default(UA_String)
Base.convert(::Type{UA_String}, x::JUA_String) = unsafe_load(Jpointer(x))

#Guid
mutable struct JUA_Guid <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Guid}
    function JUA_Guid()
        obj = new(UA_Guid_random())
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_Guid(guidstring::AbstractString)
        obj = new(UA_GUID(guidstring))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_Guid)
    UA_Guid_delete(Jpointer(obj))
end

## NodeIds
"""
```
JUA_NodeId
```

creates a `JUA_NodeId` object - the equivalent of a `UA_NodeId`, but with memory
managed by Julia rather than C.

The following methods are defined:

```
JUA_NodeId()
```

creates a `JUA_NodeId` with namespaceIndex = 0, numeric identifierType and
identifier = 0

```
JUA_NodeId(s::AbstractString)
```

creates a `JUA_NodeId` based on String `s` that is parsed into the relevant
properties.

```
JUA_NodeId(nsIndex::Integer, identifier::Integer)
```

creates a `JUA_NodeId` with namespace index `nsIndex` and numerical identifier
`identifier`.

```
JUA_NodeId(nsIndex::Integer, identifier::AbstractString)
```

creates a `JUA_NodeId` with namespace index `nsIndex` and string identifier
`identifier`.

```
JUA_NodeId(nsIndex::Integer, identifier::JUA_Guid)
```

creates a `JUA_NodeId` with namespace index `nsIndex` and global unique id identifier
`identifier`.

Examples:

```
j = JUA_NodeId()
j = JUA_NodeId("ns=1;i=1234")
j = JUA_NodeId("ns=1;s=example")
j = JUA_NodeId(1, 1234)
j = JUA_NodeId(1, "example")
j = JUA_NodeId(1, JUA_Guid("C496578A-0DFE-4B8F-870A-745238C6AEAE"))
```
"""
mutable struct JUA_NodeId <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_NodeId}

    function JUA_NodeId()
        obj = new(UA_NodeId_new())
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(s::Union{AbstractString, JUA_String})
        obj = new(UA_NODEID(s))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::Integer)
        obj = new(UA_NODEID_NUMERIC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::Union{AbstractString, JUA_String})
        obj = new(UA_NODEID_STRING_ALLOC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::JUA_Guid)
        obj = new(UA_NODEID_GUID(nsIndex, Jpointer(identifier)))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_NodeId)
    UA_NodeId_delete(Jpointer(obj))
end

"""
```
JUA_NodeId_equal(j1::JUA_NodeId, n2::JUA_NodeId)::Bool
```

returns `true` if `j1` and `j2` are `JUA_NodeId`s with identical content.
"""
JUA_NodeId_equal(j1, j2) = UA_NodeId_equal(j1, j2)

#QualifiedName
mutable struct JUA_QualifiedName <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_QualifiedName}
    function JUA_QualifiedName(nsIndex::Integer, identifier::AbstractString)
        obj = new(UA_QUALIFIEDNAME_ALLOC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_QualifiedName)
    UA_QualifiedName_delete(Jpointer(obj))
end

Base.convert(::Type{UA_QualifiedName}, x::JUA_QualifiedName) = unsafe_load(Jpointer(x))

#Variant
"""
```
JUA_Variant
```

creates a `JUA_Variant` object - the equivalent of a `UA_Variant`, but with memory
managed by Julia rather than C (exceptions below).

The following methods are defined:

```
JUA_Variant()
```

creates an empty `JUA_Variant`, equivalent to calling `UA_Variant_new()`, but 
with memory managed by Julia. 

```
JUA_Variant(value::Union{T, AbstractArray{T}}) where T <: Union{UA_NUMBER_TYPES, AbstractString, ComplexF32, ComplexF64})
```

creates a `JUA_Variant` containing the  based on String `s` that is parsed into the relevant
properties.

```
JUA_NodeId(nsIndex::Integer, identifier::Integer)
```

creates a `JUA_NodeId` with namespace index `nsIndex` and numerical identifier
`identifier`.

```
JUA_NodeId(nsIndex::Integer, identifier::Union{AbstractString, JUA_String})
```

creates a `JUA_NodeId` with namespace index `nsIndex` and string identifier
`identifier`.

```
JUA_NodeId(nsIndex::Integer, identifier::JUA_Guid)
```

creates a `JUA_NodeId` with namespace index `nsIndex` and global unique id identifier
`identifier`.

Examples:

```
j = JUA_Variant()
j = JUA_Variant("I am a string value")
j = JUA_Variant(["String1", "String2"])
j = JUA_Variant(rand(Float32, 2, 3, 4))
j = JUA_Variant(rand(Int32, 2, 2))
j = JUA_Variant(rand(ComplexF64, 8))
```
"""
mutable struct JUA_Variant <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Variant}

    function JUA_Variant()
        obj = new(UA_Variant_new())
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_Variant(value::AbstractArray{T, N},
            type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {
            T <: Union{UA_NUMBER_TYPES, UA_String, UA_ComplexNumberType, UA_DoubleComplexNumberType}, N}
        var = UA_Variant_new()
        var.type = type_ptr
        var.storageType = UA_VARIANT_DATA
        var.arrayLength = length(value)
        ua_arr = UA_Array_new(vec(permutedims(value, reverse(1:N))), type_ptr) # Allocate new UA_Array from value with C style indexing
        UA_Variant_setArray(var, ua_arr, length(value), type_ptr)
        var.arrayDimensionsSize = length(size(value))
        var.arrayDimensions = UA_UInt32_Array_new(reverse(size(value)))
        obj = new(var)
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_Variant(value::T,
            type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{UA_NUMBER_TYPES, Ptr{UA_String}, UA_ComplexNumberType, UA_DoubleComplexNumberType}}
        var = UA_Variant_new()
        var.type = type_ptr
        var.storageType = UA_VARIANT_DATA
        UA_Variant_setScalarCopy(var, wrap_ref(value), type_ptr)
        obj = new(var)
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_Variant(value::AbstractString)
        ua_s = UA_STRING(value)
        obj = JUA_Variant(ua_s)
        UA_String_delete(ua_s)
        return obj
    end

    function JUA_Variant(value::Complex{T}) where {T <: Union{Float32, Float64}}
        f = T == Float32 ? UA_ComplexNumberType : UA_DoubleComplexNumberType
        ua_c = f(reim(value)...)
        return JUA_Variant(ua_c)
    end

    function JUA_Variant(value::AbstractArray{<:AbstractString})
        a = similar(value, UA_String)
        for i in eachindex(a)
            a[i] = UA_String_fromChars(value[i])
        end
        return JUA_Variant(a)
    end

    function JUA_Variant(value::AbstractArray{<:Complex{T}}) where {T <:
                                                                   Union{Float32, Float64}}
        f = T == Float32 ? UA_ComplexNumberType : UA_DoubleComplexNumberType
        a = similar(value, f)
        for i in eachindex(a)
            a[i] = f(reim(value[i])...)
        end
        return JUA_Variant(a)
    end
end

function release_handle(obj::JUA_Variant)
    UA_Variant_delete(Jpointer(obj))
end

#VariableAttributes
mutable struct JUA_VariableAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_VariableAttributes}
    function JUA_VariableAttributes(; kwargs...)
        obj = new(UA_VariableAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_VariableAttributes)
    UA_VariableAttributes_delete(Jpointer(obj))
end

#VariableTypeAttributes
mutable struct JUA_VariableTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_VariableTypeAttributes}
    function JUA_VariableTypeAttributes(; kwargs...)
        obj = new(UA_VariableTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_VariableTypeAttributes)
    UA_VariableTypeAttributes_delete(Jpointer(obj))
end

#ObjectAttributes
mutable struct JUA_ObjectAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ObjectAttributes}
    function JUA_ObjectAttributes(; kwargs...)
        obj = new(UA_ObjectAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_ObjectAttributes)
    UA_ObjectAttributes_delete(Jpointer(obj))
end

#ObjectTypeAttributes
mutable struct JUA_ObjectTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ObjectTypeAttributes}
    function JUA_ObjectTypeAttributes(; kwargs...)
        obj = new(UA_ObjectTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_ObjectTypeAttributes)
    UA_ObjectTypeAttributes_delete(Jpointer(obj))
end

#ReferenceTypeAttributes
mutable struct JUA_ReferenceTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ReferenceTypeAttributes}
    function JUA_ReferenceTypeAttributes(; kwargs...)
        obj = new(UA_ReferenceTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_ReferenceTypeAttributes)
    UA_ReferenceTypeAttributes_delete(Jpointer(obj))
end

#DataTypeAttributes
mutable struct JUA_DataTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_DataTypeAttributes}
    function JUA_DataTypeAttributes(; kwargs...)
        obj = new(UA_DataTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_DataTypeAttributes)
    UA_DataTypeAttributes_delete(Jpointer(obj))
end

#ViewAttributes
mutable struct JUA_ViewAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ViewAttributes}
    function JUA_ViewAttributes(; kwargs...)
        obj = new(UA_ViewAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_ViewAttributes)
    UA_ViewAttributes_delete(Jpointer(obj))
end
