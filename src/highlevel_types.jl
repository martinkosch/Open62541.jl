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

#Guid
"""
```
JUA_Guid
```

a mutable struct that defines a globally unique identifier. It is the equivalent 
of a `UA_Guid`, but with memory managed by Julia rather than C.

The following constructor methods are defined:

```
JUA_Guid()
```

creates an empty `JUA_Guid`, equivalent to calling `UA_Guid_new()`.

```
JUA_Guid(guidstring::AbstractString)
```

creates a `JUA_Guid` by parsing the string `guidstring`. The string should be 
formatted according to the OPC standard defined in Part 6, 5.1.3. 

"""
mutable struct JUA_Guid <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Guid}
    function JUA_Guid()
        obj = new(UA_Guid_new())
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

```
JUA_NodeId(nptr::Ptr{UA_NodeId})
```

creates a `JUA_NodeId` based on the pointer `nptr`. This is a fallback 
method that can be used to pass `UA_NodeId`s generated via the low level interface 
to the higher level functions. Note that memory management remains on the C side 
when using this method, i.e., `nptr` needs to be manually cleaned up with 
`UA_NodeId_delete(nptr)` after the object is not needed anymore. It is up 
to the user to ensure this.

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

    function JUA_NodeId(nptr::Ptr{UA_NodeId})
        obj = new(nptr)
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
"""
```
JUA_QualifiedName
```

A mutable struct that defines a qualified name comprised of a namespace index 
and a text portion (a name). It is the equivalent of a `UA_QualifiedName`, but 
with memory managed by Julia rather than C.

The following constructor methods are defined:

```
JUA_QualifiedName()
```

creates an empty `JUA_QualifiedName`, equivalent to calling `UA_QualifiedName_new()`.

```
JUA_QualifiedName(nsIndex::Integer, identifier::AbstractString)
```

creates a `JUA_QualifiedName` with namespace index `nsIndex` and text identifier 
`identifier`.  

"""
mutable struct JUA_QualifiedName <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_QualifiedName}

    function JUA_QualifiedName()
        obj = new(UA_QualifiedName_new())
        finalizer(release_handle, obj)
        return obj
    end

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

A mutable struct that defines a `JUA_Variant` object - the equivalent of a 
`UA_Variant`, but with memory managed by Julia rather than C (exceptions below). 
`JUA_Variant`s can hold any datatype either as a scalar or in array form. 

The following constructor methods are defined:

```
JUA_Variant()
```

creates an empty `JUA_Variant`, equivalent to calling `UA_Variant_new()`.

```
JUA_Variant(value::Union{T, AbstractArray{T}}) where T <: Union{UA_NUMBER_TYPES, AbstractString, ComplexF32, ComplexF64})
```

creates a `JUA_Variant` containing `value`. All properties of the variant are set 
automatically. For example, if `value` is an array, then the arrayDimensions and 
arrayDimensionsSize properties are set based on the number of dimensions and 
number of elements across each dimension contained in `value`. 

```
JUA_Variant(variantptr::Ptr{UA_Variant})
```

creates a `JUA_Variant` based on the pointer `variantptr`. This is a fallback 
method that can be used to pass `UA_Variant`s generated via the low level interface 
to the higher level functions. Note that memory management remains on the C side 
when using this method, i.e., `variantptr` needs to be manually cleaned up with 
`UA_Variant_delete(variantptr)` after the object is not needed anymore. It is up 
to the user to ensure this.

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

    function JUA_Variant(variantptr::Ptr{UA_Variant})
        obj = new(variantptr)
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
"""
```
JUA_VariableAttributes
```

A mutable struct that defines a `JUA_VariableAttributes` object - the equivalent 
of a `UA_VariableAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_VariableAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_VariableAttributes_generate`](@ref).

```
JUA_VariableAttributes(ptr:Ptr{UA_VariableAttributes})
```

creates a `JUA_VariableAttributes` based on the pointer `ptr`. This is a 
fallback method that can be used to pass `UA_VariableAttributes`s generated via 
the low level interface to the higher level functions. See also [`UA_VariableAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with `UA_VariableAttributes_delete(ptr)` 
after the object is not needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_VariableAttributes(value = "Hello", displayname = "String variable", 
    description = "This is a variable with a string in it.")
ptr = UA_VariableAttributes_generate(value = "Hello", displayname = "String variable", 
    description = "This is a variable with a string in it.")
j = JUA_VariableAttributes(ptr)
(... do something with j ...)
UA_VariableAttributes_delete(ptr)
```
"""
mutable struct JUA_VariableAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_VariableAttributes}
    
    function JUA_VariableAttributes(; kwargs...)
        obj = new(UA_VariableAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_VariableAttributes(ptr::Ptr{UA_VariableAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_VariableAttributes)
    UA_VariableAttributes_delete(Jpointer(obj))
end

#VariableTypeAttributes
"""
```
JUA_VariableTypeAttributes
```

A mutable struct that defines a `JUA_VariableTypeAttributes` object - the equivalent 
of a `UA_VariableTypeAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_VariableTypeAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_VariableTypeAttributes_generate`](@ref).

```
JUA_VariableTypeAttributes(ptr::Ptr{UA_VariableTypeAttributes})
```

creates a `JUA_VariableTypeAttributes` based on the pointer `ptr`. 
This is a fallback method that can be used to pass `UA_VariableAttributes`s 
generated via the low level interface to the higher level functions. See also [`UA_VariableAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with `UA_VariableTypeAttributes_delete(ptr)`  
after the object is not needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_VariableTypeAttributes(value = [0.0, 0.0], displayname = "2D point type", 
    description = "This is a variable type representing a 2D point.")
ptr = UA_VariableTypeAttributes_generate(value = [0.0, 0.0], displayname = "2D point type", 
    description = "This is a variable type representing a 2D point.")
j = JUA_VariableTypeAttributes(ptr)
(... do something with j ...)
UA_VariableTypeAttributes_delete(ptr)
```
"""
mutable struct JUA_VariableTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_VariableTypeAttributes}

    function JUA_VariableTypeAttributes(; kwargs...)
        obj = new(UA_VariableTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_VariableTypeAttributes(ptr::Ptr{UA_VariableTypeAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_VariableTypeAttributes)
    UA_VariableTypeAttributes_delete(Jpointer(obj))
end

#ObjectAttributes
"""
```
JUA_ObjectAttributes
```

A mutable struct that defines a `JUA_ObjectAttributes` object - the equivalent 
of a `UA_ObjectAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_ObjectAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_ObjectAttributes_generate`](@ref).

```
JUA_ObjectAttributes(ptr::Ptr{UA_ObjectAttributes})
```

creates a `JUA_ObjectAttributes` based on the pointer `objattrptr`. 
This is a fallback method that can be used to pass `UA_ObjectAttributes`s 
generated via the low level interface to the higher level functions. See also [`UA_ObjectAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with `UA_ObjectAttributes_delete(ptr)` 
after the object is not needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_ObjectAttributes(displayname = "Pump 1", 
    description = "This is the first pump.")
ptr = UA_ObjectAttributes_generate(displayname = "Pump 1", 
description = "This is the first pump.")
j = JUA_ObjectAttributes(ptr)
(... do something with j ...)
UA_ObjectAttributes_delete(ptr)
```
"""
mutable struct JUA_ObjectAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ObjectAttributes}

    function JUA_ObjectAttributes(; kwargs...)
        obj = new(UA_ObjectAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ObjectAttributes(ptr::Ptr{UA_ObjectAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_ObjectAttributes)
    UA_ObjectAttributes_delete(Jpointer(obj))
end

#ObjectTypeAttributes
"""
```
JUA_ObjectTypeAttributes
```

A mutable struct that defines a `JUA_ObjectTypeAttributes` object - the equivalent 
of a `UA_ObjectTypeAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_ObjectTypeAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_ObjectTypeAttributes_generate`](@ref).

```
JUA_ObjectTypeAttributes(ptr::Ptr{UA_ObjectTypeAttributes})
```

creates a `JUA_ObjectTypeAttributes` based on the pointer `ptr`. This is a 
fallback method that can be used to pass `UA_ObjectTypeAttributes`s generated via 
the low level interface to the higher level functions. See also [`UA_ObjectTypeAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with `UA_ObjectTypeAttributes_delete(ptr)` 
after the object is not needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_ObjectTypeAttributes(displayname = "Pump Type", 
description = "This is an object type for a pump.")
varattrptr = UA_ObjectTypeAttributes_generate(displayname = "Pump Type", 
    description = "This is an object type for a pump.")
j = JUA_ObjectTypeAttributes(ptr)
(... do something with j ...)
UA_ObjectTypeAttributes_delete(ptr)
```
"""
mutable struct JUA_ObjectTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ObjectTypeAttributes}

    function JUA_ObjectTypeAttributes(; kwargs...)
        obj = new(UA_ObjectTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ObjectTypeAttributes(ptr::Ptr{UA_ObjectTypeAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_ObjectTypeAttributes)
    UA_ObjectTypeAttributes_delete(Jpointer(obj))
end

#ReferenceTypeAttributes
"""
```
JUA_ReferenceTypeAttributes
```

A mutable struct that defines a `JUA_ReferenceTypeAttributes` object - the equivalent 
of a `UA_ReferenceTypeAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_ReferenceTypeAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_ReferenceTypeAttributes_generate`](@ref).

```
JUA_ReferenceTypeAttributes(ptr::Ptr{UA_ReferenceTypeAttributes})
```

creates a `JUA_ReferenceTypeAttributes` based on the pointer `ptr`. 
This is a fallback method that can be used to pass `UA_ReferenceTypeAttributes`s 
generated via the low level interface to the higher level functions. See also [`UA_ReferenceTypeAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with 
`UA_ReferenceTypeAttributes_delete(ptr)`  after the object is not 
needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_ReferenceTypeAttributes(displayname = "My reference type", 
    description = "This is my reference type definining a relationship between nodes.")
varattrptr = UA_ReferenceTypeAttributes_generate(displayname = "My reference type", 
description = "This is my reference type definining a relationship between nodes.")
j = JUA_ReferenceTypeAttributes(ptr)
(... do something with j ...)
UA_ReferenceTypeAttributes_delete(ptr)
```
"""
mutable struct JUA_ReferenceTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ReferenceTypeAttributes}

    function JUA_ReferenceTypeAttributes(; kwargs...)
        obj = new(UA_ReferenceTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ReferenceTypeAttributes(ptr::Ptr{UA_ReferenceTypeAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_ReferenceTypeAttributes)
    UA_ReferenceTypeAttributes_delete(Jpointer(obj))
end

#DataTypeAttributes
"""
```
JUA_DataTypeAttributes
```

A mutable struct that defines a `JUA_DataTypeAttributes` object - the equivalent 
of a `UA_DataTypeAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_DataTypeAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_DataTypeAttributes_generate`](@ref).

```
JUA_DataTypeAttributes(ptr::Ptr{UA_DataTypeAttributes})
```

creates a `JUA_DataTypeAttributes` based on the pointer `ptr`. 
This is a fallback method that can be used to pass `UA_VariableAttributes`s 
generated via the low level interface to the higher level functions. See also [`UA_VariableAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with 
`UA_DataTypeAttributes_delete(ptr)`  after the object is not 
needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_DataTypeAttributes(displayname = "my special data type", 
    description = "This is my special data type with some properties.")
ptr = UA_DataTypeAttributes_generate(displayname = "my special data type", 
description = "This is my special data type with some properties.")
j = JUA_DataTypeAttributes(ptr)
(... do something with j ...)
UA_DataTypeAttributes_delete(ptr)
```
"""
mutable struct JUA_DataTypeAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_DataTypeAttributes}

    function JUA_DataTypeAttributes(; kwargs...)
        obj = new(UA_DataTypeAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_DataTypeAttributes(ptr::Ptr{UA_DataTypeAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_DataTypeAttributes)
    UA_DataTypeAttributes_delete(Jpointer(obj))
end

#ViewAttributes
"""
```
JUA_ViewAttributes
```

A mutable struct that defines a `JUA_ViewAttributes` object - the equivalent 
of a `UA_ViewAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_ViewAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_ViewAttributes_generate`](@ref).

```
JUA_ViewAttributes(ptr::Ptr{UA_ViewAttributes})
```

creates a `JUA_ViewAttributes` based on the pointer `ptr`. 
This is a fallback method that can be used to pass `UA_VariableAttributes`s 
generated via the low level interface to the higher level functions. See also [`UA_VariableAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with `UA_ViewAttributes_delete(ptr)` after 
the object is not needed anymore. It is up to the user to ensure this.

Examples:

```
j = JUA_ViewAttributes(displayname = "View 1", 
    description = "This is a view showing only certain nodes.")
varattrptr = UA_ViewAttributes_generate(displayname = "View 1", 
description = "This is a view showing only certain nodes.")
j = JUA_ViewAttributes(ptr)
(... do something with j ...)
UA_ViewAttributes_delete(ptr)
```
"""
mutable struct JUA_ViewAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ViewAttributes}

    function JUA_ViewAttributes(; kwargs...)
        obj = new(UA_ViewAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ViewAttributes(ptr::Ptr{UA_ViewAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_ViewAttributes)
    UA_ViewAttributes_delete(Jpointer(obj))
end
