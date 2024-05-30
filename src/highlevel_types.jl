#Preliminary definitions
abstract type AbstractOpen62541Wrapper end

Jpointer(x::AbstractOpen62541Wrapper) = getfield(x, :ptr)
Jpointer(x) = x

function Base.getproperty(x::AbstractOpen62541Wrapper, f::Symbol)
    unsafe_load(getproperty(Jpointer(x), f))
end

function Base.unsafe_convert(::Type{Ptr{T}}, obj::AbstractOpen62541Wrapper) where {T}
    Base.unsafe_convert(Ptr{T}, Jpointer(obj))
end

Base.show(io::IO, ::MIME"text/plain", v::AbstractOpen62541Wrapper) = print(io, "$(typeof(v)):\n"*UA_print(Jpointer(v)))

## Useful basic types
#String
"""
```
JUA_String
```

a mutable struct that defines a string type usable with open62541. It is the equivalent 
of a `UA_String`, but with memory managed by Julia rather than C.

The following constructor methods are defined:

```
JUA_String()
```

creates an empty `JUA_String`, equivalent to calling `UA_String_new()`.

```
JUA_String(s::AbstractString)
```

creates a `JUA_String` containing the string `s`. 

```
JUA_String(ptr::Ptr{UA_String})
```

creates a `JUA_String` based on the pointer `ptr`. This is a fallback 
method that can be used to pass `UA_Guid`s generated via the low level interface 
to the higher level functions. Note that memory management remains on the C side 
when using this method, i.e., `ptr` needs to be manually cleaned up with 
`UA_String_delete(ptr)` after the object is not needed anymore. It is up 
to the user to ensure this.

"""
mutable struct JUA_String <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_String}

    function JUA_String(s::AbstractString)
        obj = new(UA_STRING(s))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_String(ptr::Ptr{UA_String})
        return new(ptr)
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

```
JUA_Guid(ptr::Ptr{UA_Guid})
```

creates a `JUA_Guid` based on the pointer `ptr`. This is a fallback 
method that can be used to pass `UA_Guid`s generated via the low level interface 
to the higher level functions. Note that memory management remains on the C side 
when using this method, i.e., `ptr` needs to be manually cleaned up with 
`UA_Guid_delete(ptr)` after the object is not needed anymore. It is up 
to the user to ensure this.

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
    
    function JUA_Guid(ptr::Ptr{UA_Guid})
        return new(ptr)
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

    function JUA_NodeId(s::Union{AbstractString, JUA_String, Ptr{UA_String}})
        obj = new(UA_NODEID(Jpointer(s)))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_NodeId(nsIndex::Integer, identifier::Integer)
        obj = new(UA_NODEID_NUMERIC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_NodeId(nsIndex::Integer, identifier::Union{AbstractString, JUA_String, Ptr{UA_String}})
        obj = new(UA_NODEID_STRING_ALLOC(nsIndex, Jpointer(identifier)))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_NodeId(nsIndex::Integer, identifier::Union{JUA_Guid, Ptr{UA_Guid}})
        obj = new(UA_NODEID_GUID(nsIndex, Jpointer(identifier)))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_NodeId)
    UA_NodeId_delete(Jpointer(obj))
end

Base.convert(::Type{UA_NodeId}, x::JUA_NodeId) = unsafe_load(Jpointer(x))

"""
```
JUA_NodeId_equal(j1::JUA_NodeId, n2::JUA_NodeId)::Bool
```

returns `true` if `j1` and `j2` are `JUA_NodeId`s with identical content.
"""
JUA_NodeId_equal(j1, j2) = UA_NodeId_equal(j1, j2)

#ExpandedNodeId
"""
```
JUA_NodeId
```

creates a `JUA_ExpandedNodeId` object - the equivalent of a `UA_ExpandedNodeId`, 
but with memory managed by Julia rather than C.

See also: [OPC Foundation Website](https://reference.opcfoundation.org/Core/Part6/v105/docs/5.2.2.10)

The following methods are defined:

```
JUA_ExpandedNodeId()
```

creates a `JUA_ExpandedNodeId` with all fields equal to null.

```
JUA_ExpandedNodeId(s::Union{AbstractString, JUA_String, Ptr{UA_String}})
```

creates a `JUA_ExpandedNodeId` based on String `s` that is parsed into the relevant
properties. 

```
JUA_ExpandedNodeId(nsIndex::Integer, identifier::Integer)
```

creates a `JUA_ExpandedNodeId` with namespace index `nsIndex`, numeric NodeId identifier 
`identifier`, serverIndex = 0 and empty nameSpaceUri.

```
JUA_ExpandedNodeId(nsIndex::Integer, identifier::Union{AbstractString, JUA_String, Ptr{UA_String}})
```

creates a `JUA_ExpandedNodeId` with namespace index `nsIndex`, string NodeId identifier 
`identifier`, serverIndex = 0 and empty nameSpaceUri.

```
JUA_ExpandedNodeId(nodeId::Union{Ptr{UA_NodeId}, JUA_NodeId})
```

creates a `JUA_ExpandedNodeId` with empty namespaceUri, serverIndex = 0 and the 
content of `nodeId` in the nodeId field. 

```
JUA_ExpandedNodeId(identifier::Integer, ns_uri::AbstractString, server_ind::Integer) 
```

creates a `JUA_ExpandedNodeId` with namespace index `nsIndex` and global unique id identifier
`identifier` for the Nodeid, as well as serverIndex = 0 and empty namespaceUri.

```
JUA_ExpandedNodeId(identifier::Union{Ptr{UA_String}, AbstractString, JUA_String}, ns_uri::AbstractString, server_ind::Integer) 
```
creates a `JUA_ExpandedNodeId` with a string `identifier` for the nodeid, namespacUri 
`ns_uri` and server index `server_ind`.

```
JUA_ExpandedNodeId(guid::Union{Ptr{UA_Guid}, JUA_Guid}, ns_uri::AbstractString, server_ind::Integer) 
```
creates a `JUA_ExpandedNodeId` with its nodeid having the global unique identifier `guid`,
namespaceUri `ns_uri` and server index `server_ind`.

```
JUA_ExpandedNodeId(nodeid::Union{Ptr{UA_NodeId}, JUA_NodeId}, ns_uri::AbstractString, server_ind::Integer)
```

creates a `JUA_ExpandedNodeId` from the JUA_NodeId `nodeid`, namespaceUri `ns_uri` and server index `server_ind`.

```
JUA_ExpandedNodeId(nptr::Ptr{UA_ExpandedNodeId})
```

creates a `JUA_ExpandedNodeId` based on the pointer `nptr`. This is a fallback 
method that can be used to pass `UA_NodeId`s generated via the low level interface 
to the higher level functions. Note that memory management remains on the C side 
when using this method, i.e., `nptr` needs to be manually cleaned up with 
`UA_ExpandedNodeId_delete(nptr)` after the object is not needed anymore. It is up 
to the user to ensure this.

Examples:

```
j = JUA_ExpandedNodeId()
j = JUA_ExpandedNodeId("ns=1;i=1234")
j = JUA_ExpandedNodeId("ns=1;s=example")
j = JUA_ExpandedNodeId(1, 1234)
j = JUA_ExpandedNodeId(1, "example")
j = JUA_ExpandedNodeId(1, JUA_Guid("C496578A-0DFE-4B8F-870A-745238C6AEAE"))
```
"""
mutable struct JUA_ExpandedNodeId <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ExpandedNodeId}

    function JUA_ExpandedNodeId()
        obj = new(UA_ExpandedNodeId_new())
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(nptr::Ptr{UA_ExpandedNodeId})
        obj = new(nptr)
        return obj
    end

    function JUA_ExpandedNodeId(nsIndex::Integer, identifier::Integer)
        obj = new(UA_EXPANDEDNODEID_NUMERIC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(s::Union{AbstractString, Ptr{UA_String}, JUA_String})
        obj = new(UA_EXPANDEDNODEID(Jpointer(s)))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(nsIndex::Integer, identifier::Union{AbstractString, JUA_String, Ptr{UA_String}})
        obj = new(UA_EXPANDEDNODEID_STRING_ALLOC(nsIndex, Jpointer(identifier)))
        finalizer(release_handle, obj)
        return obj
    end
    
    function JUA_ExpandedNodeId(nodeId::Union{Ptr{UA_NodeId}, JUA_NodeId})
        obj = new(UA_EXPANDEDNODEID_NODEID(Jpointer(nodeId)))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(nsIndex::Integer, guid::Union{Ptr{UA_Guid}, JUA_Guid})
        obj = new(UA_EXPANDEDNODEID_STRING_GUID(nsIndex, Jpointer(guid)))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(identifier::Integer, ns_uri::AbstractString, server_ind::Integer) 
        obj = new(UA_EXPANDEDNODEID_NUMERIC(identifier, ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(identifier::Union{Ptr{UA_String}, AbstractString, JUA_String}, ns_uri::AbstractString, server_ind::Integer) 
        obj = new(UA_EXPANDEDNODEID_STRING_ALLOC(Jpointer(identifier), ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(guid::Union{Ptr{UA_Guid}, JUA_Guid}, ns_uri::AbstractString, server_ind::Integer) 
        obj = new(UA_EXPANDEDNODEID_STRING_GUID(Jpointer(guid), ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(nodeid::Union{Ptr{UA_NodeId}, JUA_NodeId}, ns_uri::AbstractString, server_ind::Integer)
        obj = new(UA_EXPANDEDNODEID_NODEID(Jpointer(nodeid), ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_ExpandedNodeId)
    UA_ExpandedNodeId_delete(Jpointer(obj))
end

Base.convert(::Type{UA_ExpandedNodeId}, x::JUA_ExpandedNodeId) = unsafe_load(Jpointer(x))

"""
```
JUA_NodeId_equal(j1::JUA_ExpandedNodeId, n2::JUA_ExpandedNodeId)::Bool
```

returns `true` if `j1` and `j2` are `JUA_ExpandedNodeId`s with identical content.
"""
JUA_ExpandedNodeId_equal(j1, j2) = UA_ExpandedNodeId_equal(j1, j2)

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

```
JUA_QualifiedName(ptr::Ptr{UA_QualifiedName})
```

creates a `JUA_QualifiedName` based on the pointer `ptr`. This is a fallback 
method that can be used to pass `UA_QualifiedName`s generated via the low level 
interface to the higher level functions. Note that memory management remains on 
the C side when using this method, i.e., `ptr` needs to be manually cleaned up with 
`UA_QualifiedName_delete(ptr)` after the object is not needed anymore. It is up 
to the user to ensure this.

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

    function JUA_QualifiedName(ptr::Ptr{UA_QualifiedName})
        obj = new(ptr)
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

#MethodAttributes
"""
```
JUA_MethodAttributes
```

A mutable struct that defines a `JUA_MethodAttributes` object - the equivalent 
of a `UA_MethodAttributes`, but with memory managed by Julia rather than C (see 
below for exceptions) 

The following constructor methods are defined:

```
JUA_MethodAttributes(; kwargs...)
```

For valid keyword arguments `kwargs` see [`UA_MethodAttributes_generate`](@ref).

```
JUA_MethodAttributes(ptr::Ptr{UA_MethodAttributes})
```

creates a `JUA_MethodAttributes` based on the pointer `ptr`. 
This is a fallback method that can be used to pass `UA_MethodAttributes`s 
generated via the low level interface to the higher level functions. See also [`UA_MethodAttributes_generate`](@ref).

Note that memory management remains on the C side when using this method, i.e., 
`ptr` needs to be manually cleaned up with `UA_MethodAttributes_delete(ptr)` 
after the object is not needed anymore. It is up to the user to ensure this.
"""
mutable struct JUA_MethodAttributes <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_MethodAttributes}

    function JUA_MethodAttributes(; kwargs...)
        obj = new(UA_MethodAttributes_generate(; kwargs...))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_MethodAttributes(ptr::Ptr{UA_MethodAttributes})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_MethodAttributes)
    UA_MethodAttributes_delete(Jpointer(obj))
end
