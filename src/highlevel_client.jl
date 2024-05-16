#Contains high level interface related to client

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

#Add node functions


#Client read and write functions
#TODO: add docstring
function JUA_Client_readValueAttribute(client, nodeId, type::T = Any) where {T}
    #TODO: Is there a way of making this typestable? 
    #(it's not really known what kind of data is stored inside a nodeid unless 
    #one checks the datatype beforehand)
    v = UA_Variant_new()
    UA_Client_readValueAttribute(client, nodeId, v)
    r = __get_juliavalues_from_variant(v, type)
    UA_Variant_delete(v)
    return r
end

"""
```
JUA_Client_writeValueAttribute(server::JUA_Client, nodeId::JUA_NodeId, newvalue)::UA_StatusCode
```

uses the client API to write the value `newvalue` to `nodeId` on `server`. 
`new_value` must either be a `JUA_Variant` or a Julia value/array compatible with 
any of its constructors. 

See also [`JUA_Variant`](@ref)

"""
function JUA_Client_writeValueAttribute(client, nodeId, newvalue)
    newvariant = JUA_Variant(newvalue)
    statuscode = UA_Client_writeValueAttribute(client, nodeId, newvariant)
    return statuscode
end

function JUA_Client_writeValueAttribute(client, nodeId, newvalue::JUA_Variant)
    statuscode = UA_Client_writeValueAttribute(client, nodeId, newvariant)
    return statuscode
end