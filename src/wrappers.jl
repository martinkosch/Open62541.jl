abstract type AbstractJuliaOpen62541Type end

mutable struct JUA_Server <: AbstractJuliaOpen62541Type
    ptr::Ptr{UA_Server}  

    function JUA_Server()
        obj = new(UA_Server_new())
        finalizer(release_handle, obj)
        return obj
    end

    function JUA_Server(config::UA_ServerConfig) 
        obj = new(UA_Server_newWithConfig(config))
        finalizer(release_handle, obj)
        return obj
    end
end

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

function release_handle(obj::JUA_Server)
    UA_Server_delete(Jpointer(obj))
end

function release_handle(obj::JUA_NodeId)
    UA_NodeId_delete(Jpointer(obj))
end

Jpointer(x::AbstractJuliaOpen62541Type) = getfield(x, :ptr)
function Base.getproperty(x::AbstractJuliaOpen62541Type, f::Symbol)
   unsafe_load(getproperty(Jpointer(x), f))
end

Base.unsafe_convert(::Type{Ptr{T}}, obj::AbstractJuliaOpen62541Type) where {T} = Base.unsafe_convert(Ptr{T}, Jpointer(obj))