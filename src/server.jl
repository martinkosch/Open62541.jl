# serverconfig functions
function UA_ServerConfig_setMinimal(config, portNumber, certificate)
    UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, 0, 0)
end

function UA_ServerConfig_setDefault(config)
    UA_ServerConfig_setMinimal(config, 4840, C_NULL)
end

## Add node functions TODO: work in progress - make note generation code more general (include all types of nodes)
# for nodeclass in instances(UA_NodeClass)
#     nodeclass_sym = Symbol(nodeclass)
#     funname_sym = Symbol("UA_Server_add" * titlecase(string(nodeclass_sym)[14:end]) *
#                          "Node")
#     #@show nodeclass_sym, funname_sym
#     # function UA_Server_addVariableNode(server, requestedNewNodeId, parentNodeId,
#     #     referenceTypeId,
#     #     browseName, typeDefinition, attributes, nodeContext, outNewNodeId)
#     # return __UA_Server_addNode(server, UA_NODECLASS_VARIABLE, wrap_ref(requestedNewNodeId),
#     #     wrap_ref(parentNodeId), wrap_ref(referenceTypeId), browseName,
#     #     wrap_ref(typeDefinition), attributes, UA_TYPES_PTRS[UA_TYPES_VARIABLEATTRIBUTES],
#     #     nodeContext, outNewNodeId)
#     # end
# end

function UA_Server_addVariableNode(server, requestedNewNodeId, parentNodeId,
        referenceTypeId,
        browseName, typeDefinition, attributes, nodeContext, outNewNodeId)
    return __UA_Server_addNode(server, UA_NODECLASS_VARIABLE, wrap_ref(requestedNewNodeId),
        wrap_ref(parentNodeId), wrap_ref(referenceTypeId), browseName,
        wrap_ref(typeDefinition), attributes, UA_TYPES_PTRS[UA_TYPES_VARIABLEATTRIBUTES],
        nodeContext, outNewNodeId)
end

function UA_Server_addVariableTypeNode(server,
        requestedNewNodeId,
        parentNodeId,
        referenceTypeId,
        browseName,
        typeDefinition,
        attributes,
        nodeContext, outNewNodeId)
    return __UA_Server_addNode(server, UA_NODECLASS_VARIABLETYPE,
        wrap_ref(requestedNewNodeId), wrap_ref(parentNodeId), wrap_ref(referenceTypeId),
        browseName, wrap_ref(typeDefinition),
        attributes,
        UA_TYPES_PTRS[UA_TYPES_VARIABLETYPEATTRIBUTES],
        nodeContext, outNewNodeId)
end

## Read functions
for att in attributes_UA_Server_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3])
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(server::Ref{UA_Server}, nodeId::Ref{UA_NodeId})
            out = Ref{$(ret_type)}()
            statuscode = __UA_Server_read(server, nodeId, $(ua_attr_name), out)
            if statuscode == UA_STATUSCODE_GOOD
                return out[]
            else
                action = "Reading"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end

        function $(fun_name)(server, nodeId)
            return $(fun_name)(wrap_ref(server), wrap_ref(nodeId))
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
        function $(fun_name)(server::Union{Ref{UA_Server}, Ptr{UA_Server}},
                nodeId::Union{Ref{UA_NodeId}, Ptr{UA_NodeId}},
                new_val::Union{Ref, Ptr})
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Server_write(server,
                nodeId,
                $(ua_attr_name),
                data_type_ptr,
                new_val)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(server, nodeId, new_val)
            return ($fun_name)(wrap_ref(server),
                wrap_ref(nodeId),
                wrap_ref(new_val))
        end
    end
end
