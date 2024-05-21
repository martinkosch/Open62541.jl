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
"""
```
JUA_Client_addNode(client::JUA_Client, requestedNewNodeId::JUA_NodeId,
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName, 
        attributes::Union{JUA_VariableAttributes, JUA_VariableTypeAttributes, JUA_ObjectAttributes},
        outNewNodeId::JUA_NodeId, typeDefinition::JUA_NodeId)::UA_StatusCode
```

uses the client API to add a Variable, VariableType, or Object node to the server 
to which the client is connected to.

See [`JUA_VariableAttributes`](@ref), [`JUA_VariableTypeAttributes`](@ref), and [`JUA_ObjectAttributes`](@ref) 
on how to define valid attributes.

```
JUA_Client_addNode(client::JUA_Client, requestedNewNodeId::JUA_NodeId,
        parentNodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName,
        attributes::Union{JUA_ObjectTypeAttributes, JUA_ReferenceTypeAttributes, JUA_DataTypeAttributes, JUA_ViewAttributes},
        outNewNodeId::JUA_NodeId)::UA_StatusCode
```

uses the client API to add a Variable, VariableType, or Object node to the server 
to which the client is connected to.

See [`JUA_ObjectTypeAttributes`](@ref), See [`JUA_ReferenceTypeAttributes`](@ref), [`JUA_DataTypeAttributes`](@ref), and [`JUA_ViewAttributes`](@ref) on how to define valid attributes.
"""
function JUA_Client_addNode end 

for nodeclass in instances(UA_NodeClass)
    if nodeclass != __UA_NODECLASS_FORCE32BIT && nodeclass != UA_NODECLASS_UNSPECIFIED
        nodeclass_sym = Symbol(nodeclass)
        funname_sym = Symbol(replace(
            "UA_Client_add" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Node",
            "type" => "Type"))
        attributeptr_sym = Symbol(uppercase("UA_TYPES_" * string(nodeclass_sym)[14:end] *
                                            "ATTRIBUTES"))
        attributetype_sym_J = Symbol("J"*replace(
            "UA_" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Attributes",
            "type" => "Type"))
        if funname_sym == :UA_Client_addVariableNode || funname_sym == :UA_Client_addObjectNode
            @eval begin            
                function JUA_Client_addNode(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J),
                        outNewNodeId, typeDefinition)
                    return $(funname_sym)(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, typeDefinition,
                        attributes, outNewNodeId)
                end
            end
        else
            @eval begin
                function JUA_Client_addNode(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J), outNewNodeId)
                    return $(funname_sym)(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, attributes,
                        outNewNodeId)
                end
            end
        end
    end
end

#Client read and write functions
"""
```
value = JUA_Client_readValue(server::JUA_Client, nodeId::JUA_NodeId, type = Any)
```

uses the client API to read the value of `nodeId` from the server that the `client` 
is connected to. 

The output `value` is automatically converted to a Julia type (such as Float64, String, Vector{String}, 
etc.) if possible. Otherwise, open62541 composite types are returned.

Note: Since it is unknown what type of value is stored within `nodeId` before reading 
it, this function is inherently type unstable. 

Type stability is improved if the optional argument `type` is provided, for example, 
if you know that you have stored a Matrix{Float64} in `nodeId`, then you should 
specify this. If the wrong type is specified, the function will throw a TypeError.

"""
function JUA_Client_readValueAttribute(client, nodeId, type::T = Any) where {T}
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

uses the client API to write the value `newvalue` to `nodeId` to the server that 
the `client` is connected to. 

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


