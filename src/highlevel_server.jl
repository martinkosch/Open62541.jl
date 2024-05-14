#Contains high level interface related to server

#Server and ServerConfig
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

#Add node functions
"""
```
JUA_Server_addNode(server::JUA_Server, requestedNewNodeId::JUA_NodeId,
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName, 
        attributes::Union{JUA_VariableAttributes, JUA_VariableTypeAttributes, JUA_ObjectAttributes},
        outNewNodeId::JUA_NodeId, nodeContext::JUA_NodeId, typeDefinition::JUA_NodeId)::UA_StatusCode
```

uses the server API to add a Variable, VariableType, or Object node to the `server`.

See [`JUA_VariableAttributes`](@ref), [`JUA_VariableTypeAttributes`](@ref), and [`JUA_ObjectAttributes`](@ref) 
on how to define valid attributes.

```
JUA_Server_addNode(server::JUA_Server, requestedNewNodeId::JUA_NodeId,
        parentNodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName,
        attributes::Union{JUA_ObjectTypeAttributes, JUA_ReferenceTypeAttributes, JUA_DataTypeAttributes, JUA_ViewAttributes},
        outNewNodeId::JUA_NodeId, nodeContext::JUA_NodeId)::UA_StatusCode
```

uses the server API to add a ObjectType, ReferenceType, DataType, or View node to the `server`.

See [`JUA_ObjectTypeAttributes`](@ref), See [`JUA_ReferenceTypeAttributes`](@ref), [`JUA_DataTypeAttributes`](@ref), and [`JUA_ViewAttributes`](@ref) on how to define valid attributes.
"""
function JUA_Server_addNode(server, requestedNewNodeId,
        parentNodeId, referenceTypeId, browseName,
        attributes::Ptr{UA_MethodAttributes}, outNewNodeId, nodeContext,
        method::Function, inputArgumentsSize, inputArguments, outputArgumentsSize,
        outputArguments) #TODO: consider whether we would like to go even higher level here (automatically generate inputArguments of the correct size etc.)
    return UA_Server_addMethodNode(server, requestedNewNodeId, parentNodeId,
        referenceTypeId, browseName, attributes, method,
        inputArgumentsSize, inputArguments, outputArgumentsSize,
        outputArguments, nodeContext, outNewNodeId)
end

for nodeclass in instances(UA_NodeClass)
    if nodeclass != __UA_NODECLASS_FORCE32BIT && nodeclass != UA_NODECLASS_UNSPECIFIED
        nodeclass_sym = Symbol(nodeclass)
        funname_sym = Symbol(replace(
            "UA_Server_add" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Node",
            "type" => "Type"))        
        attributetype_sym_J = Symbol("J"*replace(
            "UA_" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Attributes",
            "type" => "Type"))
        if funname_sym == :UA_Server_addVariableNode ||
           funname_sym == :UA_Server_addVariableTypeNode ||
           funname_sym == :UA_Server_addObjectNode
            @eval begin
                #high level function using multiple dispatch
                #docstring is with the cumulative docstring for this function above
                function JUA_Server_addNode(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J),
                        outNewNodeId, nodeContext, typeDefinition)
                    return $(funname_sym)(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        typeDefinition, attributes, nodeContext, outNewNodeId)
                end
            end
        elseif funname_sym != :UA_Server_addMethodNode
            @eval begin
                #higher level function using dispatch
                #docstring is with the cumulative docstring for this function above
                function JUA_Server_addNode(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J),
                        outNewNodeId, nodeContext)
                    return $(funname_sym)(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, attributes,
                        nodeContext, outNewNodeId)
                end
            end
        end
    end
end

#Server read and write functions
#TODO: add docstring
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