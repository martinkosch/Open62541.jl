#Preliminary definitions
abstract type AbstractOpen62541Wrapper end

Jpointer(x::AbstractOpen62541Wrapper) = getfield(x, :ptr)
Jpointer(x) = x

function Base.getproperty(x::AbstractOpen62541Wrapper, f::Symbol)
    getproperty(Jpointer(x), f)
end

function Base.unsafe_convert(::Type{Ptr{T}}, obj::AbstractOpen62541Wrapper) where {T}
    Base.unsafe_convert(Ptr{T}, Jpointer(obj))
end

function Base.setproperty!(x::AbstractOpen62541Wrapper, f::Symbol, v)
    setproperty!(Jpointer(x), f, v)
end

#Sets a field of JUA_XXX object to a JUA_YYY object, calls the next method, i.e., 
#will create a copy of the JUA_YYY object. 
function Base.setproperty!(
        x::AbstractOpen62541Wrapper, f::Symbol, v::AbstractOpen62541Wrapper)
    @warn "Assigning a $(typeof(v)) as content of field $(String(f)) in a $(typeof(x)) leads to a copy of 
        the $(typeof(v)) being generated. Avoid repeated assignments without finalizing the $(typeof(x))." maxlog=1
    setproperty!(Jpointer(x), f, v, true)
end

#Sets a field of Ptr{UA_XXX} to a JUA_YYY item. 
#This creates a copy of the object to be assigned, so that the JUA_YYY object 
#can be safely used multiple times in assignments without getting freed multiple 
#times.
for i in UNIQUE_JULIA_TYPES_IND
    @eval begin
        function Base.setproperty!(x::Ptr{$(JULIA_TYPES[i])}, f::Symbol, v::T,
                nowarn::Bool = false) where {T <: AbstractOpen62541Wrapper}
            type_ptr = ua_data_type_ptr_default(typeof(Jpointer(v)))
            UA_clear(getproperty(x, f), type_ptr)
            UA_copy(Jpointer(v), getproperty(x, f), type_ptr)
            if nowarn == false
                @warn "Assigning a $(typeof(v)) as content of field $(String(f)) in a $(typeof(x)) leads to a copy of 
                    the $(typeof(v)) being generated. Avoid repeated assignments without finalizing the $(typeof(x))." maxlog=1
            end
        end
    end
end

function Base.show(io::IO, a::MIME"text/plain", v::AbstractOpen62541Wrapper)
    print(io, "$(typeof(v)):\npointer: " * string(Jpointer(v)) * "\ncontent: ")
    Base.show(io, a, unsafe_load(Jpointer(v)))
end

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

    function JUA_String()
        obj = new(UA_String_new())
        finalizer(release_handle, obj)
        return obj
    end

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

#Base.convert(::Type{UA_String}, x::JUA_String) = unsafe_load(Jpointer(x))

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

    function JUA_NodeId(
            nsIndex::Integer, identifier::Union{AbstractString, JUA_String, Ptr{UA_String}})
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

"""
```
JUA_UsernamePasswordLogin 
```

creates a `JUA_UsernamePasswordLogin` object - the equivalent of a `UA_UsernamePasswordLogin` object, but with memory
managed by Julia rather than C.

The following methods are defined:

```
JUA_UsernamePasswordLogin(username::AbstractString, password::AbstractString)
```

Example:

```
j = JUA_UsernamePasswordLogin("PeterParker", "IamSpiderman")

```
"""
mutable struct JUA_UsernamePasswordLogin #This is rather ugly, but prevents memory-leaking.
    login::UA_UsernamePasswordLogin
    username::Ptr{UA_String}
    password::Ptr{UA_String}

    function JUA_UsernamePasswordLogin(username::AbstractString, password::AbstractString)
        un = UA_STRING(username)
        pw = UA_STRING(password)
        obj = new(UA_UsernamePasswordLogin(un, pw), un, pw)
        finalizer(release_handle, obj)
        return obj
    end
end

function Base.show(io::IO, a::MIME"text/plain", v::JUA_UsernamePasswordLogin)
    print("JUA_UsernamePasswordLogin:\n")
    print(io, "Username: ")
    Base.show(io, a, unsafe_load(v.username))
    print("\n")
    print(io, "Password: ")
    Base.show(io, a, unsafe_load(v.password))
end

function release_handle(obj::JUA_UsernamePasswordLogin)
    UA_String_delete(obj.username)
    UA_String_delete(obj.password)
end

function Base.unsafe_convert(::Type{UA_UsernamePasswordLogin}, x::JUA_UsernamePasswordLogin)
    x.login
end

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

    function JUA_ExpandedNodeId(
            nsIndex::Integer, identifier::Union{AbstractString, JUA_String, Ptr{UA_String}})
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

    function JUA_ExpandedNodeId(
            identifier::Integer, ns_uri::AbstractString, server_ind::Integer)
        obj = new(UA_EXPANDEDNODEID_NUMERIC(identifier, ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(
            identifier::Union{Ptr{UA_String}, AbstractString, JUA_String},
            ns_uri::AbstractString, server_ind::Integer)
        obj = new(UA_EXPANDEDNODEID_STRING_ALLOC(Jpointer(identifier), ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(guid::Union{Ptr{UA_Guid}, JUA_Guid},
            ns_uri::AbstractString, server_ind::Integer)
        obj = new(UA_EXPANDEDNODEID_STRING_GUID(Jpointer(guid), ns_uri, server_ind))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_ExpandedNodeId(nodeid::Union{Ptr{UA_NodeId}, JUA_NodeId},
            ns_uri::AbstractString, server_ind::Integer)
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

#LocalizedText
"""
```
JUA_LocalizedText
```

A mutable struct that defines a localized text comprised of a locale specifier
and a text portion. It is the equivalent of a `UA_QualifiedName`, but
with memory managed by Julia rather than C.

The following constructor methods are defined:

```
JUA_LocalizedText()
```

creates an empty `JUA_LocalizedText`, equivalent to calling `UA_LocalizedText_new()`.

```
JUA_LocalizedText(locale::Union{AbstractString, JUA_String, Ptr{UA_String}}, text::Union{AbstractString, JUA_String, Ptr{UA_String}})
```

creates a `JUA_LocalizedText` with localization `locale` and text `text`.

```
JUA_LocalizedText(ptr::Ptr{UA_LocalizedText})
```

creates a `JUA_LocalizedText` based on the pointer `ptr`. This is a fallback
method that can be used to pass `UA_LocalizedText`s generated via the low level
interface to the higher level functions. Note that memory management remains on
the C side when using this method, i.e., `ptr` needs to be manually cleaned up with
`UA_LocalizedText_delete(ptr)` after the object is not needed anymore. It is up
to the user to ensure this.
"""
mutable struct JUA_LocalizedText <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_LocalizedText}

    function JUA_LocalizedText()
        obj = new(UA_LocalizedText_new())
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_LocalizedText(locale::Union{AbstractString, JUA_String, Ptr{UA_String}},
            text::Union{AbstractString, JUA_String, Ptr{UA_String}})
        obj = new(UA_LOCALIZEDTEXT_ALLOC(Jpointer(locale), Jpointer(text)))
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_LocalizedText(ptr::Ptr{UA_LocalizedText})
        obj = new(ptr)
        return obj
    end
end

function release_handle(obj::JUA_LocalizedText)
    UA_LocalizedText_delete(Jpointer(obj))
end

#Base.convert(::Type{UA_LocalizedText}, x::JUA_LocalizedText) = unsafe_load(Jpointer(x))

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
JUA_Variant(value::Union{T, AbstractArray{T}}) where T <: Union{UA_NUMBER_TYPES, AbstractString, ComplexF32, ComplexF64, Rational{<:Integer}})
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

    function JUA_Variant(value::Union{AbstractArray{T}, T}) where {T <: Number}
        #if not specifically handled by one of the methods below, the number type
        #is not natively supported; hence throw an informative exception.
        err = UnsupportedNumberTypeError(T)
        throw(err)
    end

    function JUA_Variant(value::AbstractArray{T, N},
            type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {
            T <: Union{UA_NUMBER_TYPES, UA_String, UA_ComplexNumberType,
                UA_DoubleComplexNumberType, UA_RationalNumber, UA_UnsignedRationalNumber}, N}
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
            type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{
            UA_NUMBER_TYPES, Ptr{UA_String}, UA_ComplexNumberType,
            UA_DoubleComplexNumberType, UA_RationalNumber, UA_UnsignedRationalNumber}}
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
        if sizeof(T) <= 4
            f = UA_ComplexNumberType
        else
            f = UA_DoubleComplexNumberType
        end
        ua_c = f(reim(value)...)
        return JUA_Variant(ua_c)
    end

    function JUA_Variant(value::Rational{<:Unsigned})
        v = UA_UnsignedRationalNumber(value.num, value.den)
        return JUA_Variant(v)
    end

    function JUA_Variant(value::Rational{<:Signed})
        v = UA_RationalNumber(value.num, value.den)
        return JUA_Variant(v)
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

    function JUA_Variant(value::AbstractArray{<:Rational{T}}) where {T <:
                                                                     Union{Int32, UInt32}}
        f = T == Int32 ? UA_RationalNumber : UA_UnsignedRationalNumber
        a = similar(value, f)
        for i in eachindex(a)
            a[i] = f(value[i].num, value[i].den)
        end
        return JUA_Variant(a)
    end
end

function release_handle(obj::JUA_Variant)
    UA_Variant_delete(Jpointer(obj))
end

#Argument
const ARG_TYPEUNION = Union{
    JULIA_TYPES..., Complex{Float32}, Complex{Float64}, Rational{Int32},
    Rational{UInt32}, AbstractString}

"""
```
JUA_Argument
```

A mutable struct that defines a `JUA_Argument` object - the equivalent of a
`UA_Argument`, but with memory managed by Julia rather than C (exceptions below).

The following constructor methods are defined:

```
JUA_Argument()
```

creates an empty `JUA_Argument`, equivalent to calling `UA_Argument_new()`.

```
JUA_Argument(examplearg::Union{Nothing, AbstractArray{<: ARG_TYPEUNION}, ARG_TYPEUNION} = nothing; 
        name::Union{Nothing, AbstractString} = nothing, 
        description::Union{AbstractString, Nothing} = nothing, 
        localization::AbstractString = "en-US",
        datatype::Union{Nothing, ARG_TYPEUNION} = nothing,
        valuerank::Union{Integer, Nothing} = nothing, 
        arraydimensions::Union{Integer, AbstractArray{<: Integer}, Nothing} = nothing)
```

creates a `JUA_Argument` based on the properties of `examplearg`. Specifically, the `datatype`,
`valuerank`, and `arraydimensions` are automatically determined from `examplearg`. The `name`,
`description` and `localization` keyword arguments can be used to describe the `JUA_Argument`
further.

The `valuerank` and `arraydimensions` properties are explained here: [OPC Foundation Website](https://reference.opcfoundation.org/Core/Part3/v105/docs/8.6)

```
JUA_Argument(argumentptr::Ptr{UA_Argument})
```

creates a `JUA_Argument` based on the pointer `argumentptr`. This is a fallback
method that can be used to pass `UA_Argument`s generated via the low level interface
to the higher level functions. Note that memory management remains on the C side
when using this method, i.e., `argumentptr` needs to be manually cleaned up with
`UA_Argument_delete(argumentptr)` after the object is not needed anymore. It is up
to the user to ensure this.

Examples:

```
j = JUA_Argument()
j = JUA_Argument(1.0) #will accept a Float64 scalar
j = JUA_Argument(zeros(Float32, 2, 2)) #will exclusively accept Float32 arrays of size 2x2
j = JUA_Argument(zeros(Float32, 2, 2), arraydimensions = [0, 0]) #will accept any 2D Float32 array.
j = JUA_Argument(datatype = Int8, valuerank = 1, arraydimensions = [2, 2]) #will accept a Int8 array of size 2 x 2.
j = JUA_Argument(datatype = Float64, valuerank = 1, arraydimensions = 4) #will accept a Float64 vector with 4 elements.
j = JUA_Argument(datatype = Float64, valuerank = 1, arraydimensions = 0) #will accept a Float64 vector of any length.
```
"""
mutable struct JUA_Argument <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Argument}
    #Actually placing the type restrictions on examplearg and datatype like in the docstring 
    #places a large burden on the VS code interpreter and the compiler (large union); to avoid
    #this, we keep the arguments untyped.
    function JUA_Argument(examplearg = nothing;
            name::Union{Nothing, AbstractString} = nothing,
            description::Union{AbstractString, Nothing} = nothing,
            localization::AbstractString = "en-US",
            datatype = nothing,
            valuerank::Union{Integer, Nothing} = nothing,
            arraydimensions::Union{Integer, AbstractArray{<:Integer}, Nothing} = nothing)
        arg = UA_Argument_new()
        if isa(arraydimensions, Integer)
            arraydimensions = [arraydimensions]
        end
        if !isnothing(name)
            ua_s = UA_STRING(name)
            UA_String_copy(ua_s, arg.name)
            UA_String_delete(ua_s)
        end
        if !isnothing(description)
            lt = UA_LOCALIZEDTEXT(localization, description)
            UA_LocalizedText_copy(lt, arg.description)
            UA_LocalizedText_delete(lt)
        end

        #determine type and array parameters based on example arg if given
        if !isnothing(examplearg)
            if isa(examplearg, AbstractArray)
                s = size(examplearg)
                if isnothing(valuerank) || valuerank == length(s)
                    arg.arrayDimensionsSize = length(s)
                    arg.arrayDimensions = UA_UInt32_Array_new(s)
                    arg.valueRank = length(s)
                end
                arg.dataType = __determinetype(eltype(examplearg))
            else
                arg.valueRank = -1
                arg.dataType = __determinetype(typeof(examplearg))
            end
        end

        #allow type to be overwritten
        if !isnothing(datatype)
            arg.dataType = datatype
        end

        #allow array fields to be overwritten (to allow flexibility in terms of dimensions etc.)
        if !isnothing(valuerank)
            arg.valueRank = valuerank
        end
        if !isnothing(arraydimensions)
            arg.arrayDimensionsSize = length(arraydimensions)
            arg.arrayDimensions = UA_UInt32_Array_new(arraydimensions)
        end

        #consistency check
        ads = unsafe_load(arg.arrayDimensionsSize)
        ad = unsafe_wrap(Array, unsafe_load(arg.arrayDimensions), ads)
        vr = unsafe_load(arg.valueRank)
        consistent = __check_valuerank_arraydimensions_consistency(vr, ad)
        if consistent == true
            obj = new(arg)
            finalizer(release_handle, obj)
            return obj
        else
            #clean up and throw exception
            UA_Argument_delete(arg)
            err = ValueRankArraySizeConsistencyError(arg.valueRank, arg.arrayDimensions)
            throw(err)
        end
    end

    function JUA_Argument(argumentptr::Ptr{UA_Argument})
        obj = new(argumentptr)
        return obj
    end
end

function release_handle(obj::JUA_Argument)
    UA_Argument_delete(Jpointer(obj))
end

function __argsize(a::JUA_Argument)
    return 1
end

function __argsize(a)
    return length(a)
end

#CallMethodRequest
"""
```
JUA_CallMethodRequest
```

A mutable struct that defines a `JUA_CallMethodRequest` object - the equivalent of a
`UA_CallMethodRequest`, but with memory managed by Julia rather than C (exceptions below).

The following constructor methods are defined:

```
JUA_CallMethodRequest()
```

creates an empty `JUA_CallMethodRequest`, equivalent to calling `UA_CallMethodRequest_new()`.

```
JUA_CallMethodRequest(objectid::JUA_NodeId, methodid::JUA_NodeId, inputarg::Union{Any, Tuple{Any, ...}})
```

creates a `JUA_CallMethodRequest` taking the context nodeid (`objectid`), the nodeid of the
method to be called (`methodid`)`, as well as the `inputarg` that the method is called with.

`inputarg` can be any type that is compatible within Open62541.jl, particularly builtin number
types, strings, as well as UA_XXX types. Input arguments can also be arrays (for example a
Vector{Float64}). Multiple arguments should be provided as a tuple.

```
JUA_CallMethodRequest(methodrequestptr::Ptr{UA_CallMethodRequest})
```

creates a `JUA_CallMethodRequest` based on the pointer `methodrequestptr`. This is a fallback
method that can be used to pass `UA_CallMethodRequest`s generated via the low level interface
to the higher level functions. Note that memory management remains on the C side
when using this method, i.e., `methodrequestptr` needs to be manually cleaned up with
`UA_CallMethodRequest_delete(methodrequestptr)` after the object is not needed anymore. It is up
to the user to ensure this.

Examples:

```
j = JUA_CallMethodRequest()
j = JUA_CallMethodRequest(JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER), JUA_NodeId(1, 1234), ["Peter", "Julia"]) #one vector of strings inputarg
j = JUA_CallMethodRequest(JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER), JUA_NodeId(1, 1234), ("Claudia", 1234)]) #two input args
```

See also:

  - [`UA_MethodCallback_generate`](@ref)

  - [`UA_MethodCallback_wrap`](@ref)
  - [`JUA_Server_addNode`](@ref)
"""
mutable struct JUA_CallMethodRequest <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_CallMethodRequest}

    function JUA_CallMethodRequest()
        req = UA_CallMethodRequest_new()
        obj = new(req)
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_CallMethodRequest(objectid::JUA_NodeId, methodid::JUA_NodeId, inputarg)
        req = UA_CallMethodRequest_new()
        req.objectId = objectid
        req.methodId = methodid
        if inputarg isa Tuple
            variants = UA_Variant_Array_new(length(inputarg))
            for i in eachindex(variants)
                j = JUA_Variant(inputarg[i])
                UA_Variant_copy(Jpointer(j), variants[i])
            end
            req.inputArguments = variants
            req.inputArgumentsSize = length(inputarg)
        else
            j = JUA_Variant(inputarg)
            v = UA_Variant_new()
            UA_Variant_copy(Jpointer(j), v)
            req.inputArguments = v
            req.inputArgumentsSize = 1
        end
        obj = new(req)
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_CallMethodRequest(ptr::Ptr{UA_CallMethodRequest})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_CallMethodRequest)
    UA_CallMethodRequest_delete(Jpointer(obj))
end

#CallMethodResult
mutable struct JUA_CallMethodResult <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_CallMethodResult}

    function JUA_CallMethodResult()
        res = UA_CallMethodResult_new()
        obj = new(res)
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_CallMethodResult(ptr::Ptr{UA_CallMethodResult})
        return new(ptr) #no finalizer, see docstring
    end
end

function release_handle(obj::JUA_CallMethodResult)
    UA_CallMethodResult_delete(Jpointer(obj))
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

creates a `JUA_ObjectAttributes` based on the pointer `ptr`.
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
below for exceptions).

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
