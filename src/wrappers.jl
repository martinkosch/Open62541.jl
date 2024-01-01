abstract type AbstractJuliaOpen62541Type end

Jpointer(x::AbstractJuliaOpen62541Type) = getfield(x, :ptr)
function Base.getproperty(x::AbstractJuliaOpen62541Type, f::Symbol)
    unsafe_load(getproperty(Jpointer(x), f))
end

function Base.unsafe_convert(::Type{Ptr{T}}, obj::AbstractJuliaOpen62541Type) where {T}
    Base.unsafe_convert(Ptr{T}, Jpointer(obj))
end

#Server and server config
mutable struct JUA_Server <: AbstractJuliaOpen62541Type
    ptr::Ptr{UA_Server}
    function JUA_Server()
        obj = new(UA_Server_new())
        finalizer(release_handle, obj)
        return obj
    end
end

mutable struct JUA_ServerConfig <: AbstractJuliaOpen62541Type
    ptr::Ptr{UA_ServerConfig}
    function JUA_ServerConfig(server::JUA_Server)
        #no finalizer, because the config object lives and dies with the server itself
        obj = new(UA_Server_getConfig(server))
        return obj
    end
end

function JUA_Server_getConfig(server::JUA_Server)
    return JUA_ServerConfig(server)
end

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

#NodeIds
mutable struct JUA_NodeId <: AbstractJuliaOpen62541Type
    ptr::Ptr{UA_NodeId}

    function JUA_NodeId()
        obj = new(UA_NodeId_new())
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::Integer)
        obj = new(UA_NodeId_new(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::AbstractString)
        obj = new(UA_NodeId_new(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
end

# finalizers
function release_handle(obj::JUA_Server)
    UA_Server_delete(Jpointer(obj))
end

function release_handle(obj::JUA_NodeId)
    UA_NodeId_delete(Jpointer(obj))
end