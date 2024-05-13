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

## Server and server config
mutable struct JUA_Server <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Server}
    function JUA_Server()
        obj = new(UA_Server_new())
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_Server)
    UA_Server_delete(Jpointer(obj))
end

mutable struct JUA_ServerConfig <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ServerConfig}
    function JUA_ServerConfig(server::JUA_Server)
        #no finalizer, because the config object lives and dies with the server itself
        obj = new(UA_Server_getConfig(server))
        return obj
    end
end

#aliasing functions that interact with server and serverconfig
const JUA_ServerConfig_setMinimalCustomBuffer = UA_ServerConfig_setMinimalCustomBuffer
const JUA_ServerConfig_setMinimal = UA_ServerConfig_setMinimal
const JUA_ServerConfig_setDefault = UA_ServerConfig_setDefault
const JUA_ServerConfig_setBasics = UA_ServerConfig_setBasics
const JUA_ServerConfig_addNetworkLayerTCP = UA_ServerConfig_addNetworkLayerTCP
const JUA_ServerConfig_addSecurityPolicyNone = UA_ServerConfig_addSecurityPolicyNone
const JUA_ServerConfig_addEndpoint = UA_ServerConfig_addEndpoint
const JUA_ServerConfig_addAllEndpoints = UA_ServerConfig_addAllEndpoints
const JUA_ServerConfig_clean = UA_ServerConfig_clean
const JUA_AccessControl_default = UA_AccessControl_default
const JUA_AccessControl_defaultWithLoginCallback = UA_AccessControl_defaultWithLoginCallback

function JUA_Server_runUntilInterrupt(server::JUA_Server)
    running = Ref(true)
    try
        Base.exit_on_sigint(false)
        UA_Server_run(server, running)
    catch err
        UA_Server_run_shutdown(server)
        println("Shutting down server.")
        Base.exit_on_sigint(true)
    end
    return nothing
end

## Client and client config
mutable struct JUA_Client <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Client}
    function JUA_Client()
        obj = new(UA_Client_new())
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_Client)
    UA_Client_delete(Jpointer(obj))
end

mutable struct JUA_ClientConfig <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ClientConfig}
    function JUA_ClientConfig(client::JUA_Client)
        #no finalizer, because the config object lives and dies with the client itself
        obj = new(UA_Client_getConfig(client))
        return obj
    end
end

const JUA_ClientConfig_setDefault = UA_ClientConfig_setDefault
const JUA_Client_connect = UA_Client_connect
const JUA_Client_disconnect = UA_Client_disconnect

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
JUA_NodeId(s::Union{AbstractString, JUA_String})
```

creates a `JUA_NodeId` based on String `s` that is parsed into the relevant
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

mutable struct JUA_Variant <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Variant}
    function JUA_Variant()
        obj = new(UA_Variant_new())
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_Variant)
    UA_Variant_delete(Jpointer(obj))
end

function JUA_Client_readValueAttribute(client, nodeId)
    #TODO: Is there a way of making this typestable? 
    #(it's not really known what kind of data is stored inside a nodeid unless 
    #one checks the datatype beforehand)
    v = UA_Variant_new()
    UA_Client_readValueAttribute(client, nodeId, v)
    r = __get_juliavalues_from_variant(v)
    UA_Variant_delete(v)
    return r
end

function JUA_Client_writeValueAttribute(client, nodeId, newvalue)
    newvariant = UA_Variant_new(newvalue)
    statuscode = UA_Client_writeValueAttribute(client, nodeId, newvariant)
    UA_Variant_delete(newvariant)
    return statuscode
end

function JUA_Server_readValue(client, nodeId)
    #TODO: Is there a way of making this typestable? 
    #(it's not really known what kind of data is stored inside a nodeid unless 
    #one checks the datatype beforehand)
    v = UA_Variant_new()
    UA_Server_readValue(client, nodeId, v)
    r = __get_juliavalues_from_variant(v)
    UA_Variant_delete(v)
    return r
end

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
