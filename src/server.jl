# serverconfig functions
"""
```
UA_ServerConfig_setMinimal(config, portNumber, certificate)
```

creates a new server config with one endpoint. The config will set the tcp
network layer to the given port and adds a single endpoint with the security
policy ``SecurityPolicy#None`` to the server. A server certificate may be
supplied but is optional.
"""
function UA_ServerConfig_setMinimal(config, portNumber, certificate)
    UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, 0, 0)
end

"""
```
UA_ServerConfig_setDefault(config)
```

Creates a server config on the default port 4840 with no server certificate.
"""
function UA_ServerConfig_setDefault(config)
    UA_ServerConfig_setMinimal(config, 4840, C_NULL)
end

## Add node Functions
"""
```
UA_Server_addMethodNode(server::Ptr{UA_Server}, requestednewnodeid::Ptr{UA_NodeId}, 
        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
        browseName::Ptr{UA_QualifiedName}, attr::Ptr{UA_MethodAttributes}, 
        method::Function, inputArgumentsSize::Csize_t, inputArguments::Union{UA_Argument, AbstractArray{UA_Argument}}, 
        outputArgumentsSize::Csize_t, outputArguments::Union{UA_Argument, AbstractArray{UA_Argument}}, 
        nodeContext::Ptr{UA_NodeId}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
```

uses the server API to add a method node with the callback `method` to the `server`.
`UA_MethodCallback_generate` is internally called on the `method` supplied and thus
its function signature must match its requirements.

See [`UA_MethodAttributes_generate`](@ref) on how to define valid attributes.
"""
function UA_Server_addMethodNode(server, requestedNewNodeId, parentNodeId,
        referenceTypeId, browseName, attr, method::Function,
        inputArgumentsSize, inputArguments, outputArgumentsSize,
        outputArguments, nodeContext, outNewNodeId)

    #Generate the appropriate Cfunction pointer for the callback method
    callback = UA_MethodCallback_generate(method)

    return UA_Server_addMethodNodeEx(server, requestedNewNodeId,
        parentNodeId, referenceTypeId, browseName, unsafe_load(attr),
        callback, inputArgumentsSize, inputArguments,
        UA_NODEID_NULL, C_NULL, outputArgumentsSize, outputArguments,
        UA_NODEID_NULL, C_NULL, nodeContext, outNewNodeId)
end

for nodeclass in instances(UA_NodeClass)
    if nodeclass != __UA_NODECLASS_FORCE32BIT && nodeclass != UA_NODECLASS_UNSPECIFIED
        nodeclass_sym = Symbol(nodeclass)
        funname_sym = Symbol(replace(
            "UA_Server_add" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Node",
            "type" => "Type"))
        attributeptr_sym = Symbol(uppercase("UA_TYPES_" * string(nodeclass_sym)[14:end] *
                                            "ATTRIBUTES"))
        attributetype_sym = Symbol(replace(
            "UA_" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Attributes",
            "type" => "Type"))

        if funname_sym == :UA_Server_addVariableNode ||
           funname_sym == :UA_Server_addVariableTypeNode ||
           funname_sym == :UA_Server_addObjectNode
            @eval begin
                # emit specific add node functions            
                """
                ```
                $($(funname_sym))(server::Ptr{UA_Server}, requestednewnodeid::Ptr{UA_NodeId}, 
                        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
                        browseName::Ptr{UA_QualifiedName}, typedefinition::Ptr{UA_NodeId},
                        attr::Ptr{$($(attributetype_sym))}, nodeContext::Ptr{UA_NodeId}, 
                        outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
                ```

                uses the server API to add a $(lowercase(string($nodeclass_sym)[14:end])) node to the `server`.

                See [`$($(attributetype_sym))_generate`](@ref) on how to define valid attributes.
                """
                function $(funname_sym)(server, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, typeDefinition, attributes,
                        nodeContext, outNewNodeId)
                    return __UA_Server_addNode(server, $(nodeclass_sym),
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, typeDefinition, attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)], nodeContext, outNewNodeId)
                end                
            end
        elseif funname_sym != :UA_Server_addMethodNode
            @eval begin
                # emit specific add node functions
                """
                ```
                $($(funname_sym))(server::Ptr{UA_Server}, requestednewnodeid::Ptr{UA_NodeId}, 
                        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
                        browseName::Ptr{UA_QualifiedName}, typedefinition::Ptr{UA_NodeId},
                        attr::Ptr{$($(attributetype_sym))}, nodeContext::Ptr{UA_NodeId}, 
                        outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
                ```

                uses the server API to add a $(lowercase(string($nodeclass_sym)[14:end])) node to the `server`.

                See [`$($(attributetype_sym))_generate`](@ref) on how to define valid attributes.
                """
                function $(funname_sym)(server, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, attributes, nodeContext,
                        outNewNodeId)
                    return __UA_Server_addNode(server, $(nodeclass_sym),
                        requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        wrap_ref(UA_NODEID_NULL), attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)],
                        nodeContext, outNewNodeId)
                end
            end
        end
    end
end

## Read functions
for att in attributes_UA_Server_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3] * "_new")
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        """
        ```
        $($(fun_name))(server::Ptr{UA_Server}, nodeId::Ptr{UA_NodeId}, out::Ptr{$($(String(att[3])))})
        ```
        Uses the Server API to read the value of the attribute $($(String(attr_name))) 
        from the NodeId `nodeId` located on server `server`. The result is saved 
        into `out`.
        
        Note that memory for `out` must be allocated by C before using this function. 
        This can be accomplished with `out = $($(String(ret_type)))()`. The 
        resulting object must be cleaned up via `$($(String(att[3])))_delete(out::Ptr{$($(String(att[3])))})`    
        after its use.
        """
        function $(fun_name)(server, nodeId, out)
            statuscode = __UA_Server_read(server, nodeId, $(ua_attr_name), out)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Reading"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action, mode, side,
                    $(String(attr_name)), statuscode)
                throw(err)
            end
        end
    end
end

## Write functions
for att in attributes_UA_Server_write
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        """
        ```
        $($(fun_name))(server::Ptr{UA_Server}, nodeId::Ptr{UA_NodeId}, new_val::Ptr{$($(String(attr_type)))})
        ```
        Uses the Server API to write the value `new_val` to the attribute $($(String(attr_name))) 
        of the NodeId `nodeId` located on the `server`. 
        """
        function $(fun_name)(server, nodeId, new_val)
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Server_write(server, nodeId, $(ua_attr_name),
                data_type_ptr, wrap_ref(new_val))
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action, mode, side,
                    $(String(attr_name)), statuscode)
                throw(err)
            end
        end
    end
end

"""
```
UA_Server_call(server::Ptr{UA_Server}, request::Ptr{UA_CallMethodRequest}, result::Ptr{UA_CallMethodResult})::Nothing
```

uses the server API to process the method call request `request` on the `server`.
Note that `result` is mutated.
"""
function UA_Server_call(server, request, result)
    r = UA_Server_call(server, request) #TODO: introduce memory leak test to check whether r is correctly GC-ed or not.
    UA_CallMethodResult_copy(r, result)
    return nothing
end
