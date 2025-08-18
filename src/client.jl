"""
```
UA_ClientConfig_setAuthenticationUsername(config::Ptr{UA_ClientConfig}, username::Ptr{UA_String}, 
    password::Ptr{UA_String})::UA_StatusCode
```

Configure Username/Password for the Session authentication. Also see 
`UA_ClientConfig_setAuthenticationCert` for x509-based authentication.

Note that `username` and `password` are copied; pointers must be cleared up separately.

"""
function UA_ClientConfig_setAuthenticationUsername(config::Ptr{UA_ClientConfig}, username::Ptr{UA_String}, 
        password::Ptr{UA_String})
    identityToken = UA_UserNameIdentityToken_new()
    if identityToken == C_NULL
        return UA_STATUSCODE_BADOUTOFMEMORY
    else
        UA_String_copy(username, identityToken.userName)
        UA_String_copy(password, identityToken.password)
        UA_ExtensionObject_clear(config.userIdentityToken)
        UA_ExtensionObject_setValueCopy(config.userIdentityToken, identityToken,
            UA_TYPES_PTRS[UA_TYPES_USERNAMEIDENTITYTOKEN])
        UA_UserNameIdentityToken_delete(identityToken)
        return UA_STATUSCODE_GOOD
    end
end

"""
```
UA_Client_connect(client::Ptr{UA_Client}, endpointurl::Ptr{UA_String})::UA_StatusCode
```

connect the `client` to the server with `endpointurl`. This is an anonymous connection, i.e.,
no username or password are used (some servers do not allow this).

Note that `endpointurl` is copied; pointer must be cleared up separately.

"""
function UA_Client_connect(client, endpointurl)
    cc = UA_Client_getConfig(client)
    cc.noSession = false
    UA_String_clear(cc.endpointUrl)
    UA_String_copy(endpointurl, cc.endpointUrl) 
    return __UA_Client_connect(client, false)
end

# /* Connect async (non-blocking) to the server. After initiating the connection,
#  * call UA_Client_run_iterate repeatedly until the connection is fully
#  * established. You can set a callback to client->config.stateCallback to be
#  * notified when the connection status changes. Or use UA_Client_getState to get
#  * the state manually. */
##TODO: ADD DOCSTRING
function UA_Client_connectAsync(client::Ptr{UA_Client}, endpointUrl::AbstractString)
    cc = UA_Client_getConfig(client)
    cc.noSession = false
    UA_String_clear(cc.endpointUrl)
    cc.endpointUrl = UA_STRING_ALLOC(endpointUrl)
    return __UA_Client_connect(client, true)
end

# /* Connect to the server without creating a session
#  *
#  * @param client to use
#  * @param endpointURL to connect (for example "opc.tcp://localhost:4840")
#  * @return Indicates whether the operation succeeded or returns an error code */
##TODO: ADD DOCSTRING
function UA_Client_connectSecureChannel(client::Ptr{UA_Client}, endpointUrl::AbstractString)
    cc = UA_Client_getConfig(client)
    cc.noSession = true
    UA_String_clear(cc.endpointUrl)
    cc.endpointUrl = UA_STRING_ALLOC(endpointUrl)
    return __UA_Client_connect(client, false)
end

# /* Connect async (non-blocking) only the SecureChannel */
function UA_Client_connectSecureChannelAsync(
        client::Ptr{UA_Client}, endpointUrl::AbstractString)
    cc = UA_Client_getConfig(client)
    cc.noSession = true
    UA_String_clear(cc.endpointUrl)
    cc.endpointUrl = UA_STRING_ALLOC(endpointUrl)
    return __UA_Client_connect(client, true)
end

"""
```
UA_Client_getContext(client::Ptr{UA_Client})::Ptr{Ptr{Cvoid}}
```

Get the client context.
"""
UA_Client_getContext(client::Ptr{UA_Client}) = UA_Client_getConfig(client).clientContext

"""
```
UA_Client_connectUsername(client::Ptr{UA_Client}, endpointurl::Ptr[UA_String}, 
    username::Ptr[UA_String}, password::Ptr[UA_String})::UA_StatusCode
```

connects the `client` to the server with endpoint URL `endpointurl` and supplies
`username` and `password` as login credentials.

Note that `endpointurl`, `username`, and `password` are copied, pointers must be freed up 
seperately.
"""
function UA_Client_connectUsername(client, endpointurl, username, password)
    cc = UA_Client_getConfig(client)
    res = UA_ClientConfig_setAuthenticationUsername(cc, username, password)
    if res != UA_STATUSCODE_GOOD
        return res
    else
        return UA_Client_connect(client, endpointurl)
    end
end

## UA_Client_Service functions
for att in attributes_UA_Client_Service
    fun_name = Symbol(att[1])
    req_type = Symbol("UA_", uppercasefirst(att[2]), "Request")
    resp_type = Symbol("UA_", uppercasefirst(att[2]), "Response")
    resp_gen = Symbol(resp_type, "_new")
    resp_del = Symbol(resp_type, "_delete")
    req_type_ptr = Symbol("UA_TYPES_", uppercase(String(att[2])), "REQUEST")
    resp_type_ptr = Symbol("UA_TYPES_", uppercase(String(att[2])), "RESPONSE")
    if isdefined(Open62541, req_type) # Skip functions that use undefined types
        @eval begin
            #TODO: add tests           
            """
            ```
            response::Ptr{$($resp_type))} = $($(fun_name))(client::Ptr{UA_Client}, request::Ptr{$($resp_type))})
            ```

            Uses the client $($(att[2])) service API to deliver a `response` to a 
            previously defined `request`. Note that memory for the response is 
            allocated by C and needs to be cleaned up using 
            `$($(resp_del))(response)` after its use.

            !!! This is a low-level function within open62541. It is normally 
            much better and more convenient to use a more specific, high level 
            function.              

            See also:

            [`$($resp_type)`](@ref)

            [`$($req_type)`](@ref)

            """
            function $(fun_name)(client, request)
                response = $(resp_gen)()
                statuscode = __UA_Client_Service(client, request,
                    UA_TYPES_PTRS[$(req_type_ptr)], response,
                    UA_TYPES_PTRS[$(resp_type_ptr)])
                if statuscode == UA_STATUSCODE_GOOD || isnothing(statuscode)
                    return response
                else
                    throw(ClientServiceRequestError("Service request of type ´($($(req_type))´ from UA_Client failed with statuscode \"$(UA_StatusCode_name_print(statuscode))\"."))
                end
            end
        end
    end
end

# #TODO: add tests
"""
```
response::Ptr{UA_SetMonitoringModeResponse} = UA_Client_MonitoredItems_setMonitoringMode(client::Ptr{UA_Client}, 
    request::Ptr{UA_SetMonitoringModeRequest})
```

uses the client API to set the monitoring mode on monitored items. Note that
memory for the response is allocated by C and needs to be cleaned up using
`UA_SetMonitoringModeResponse_delete(response)` after its use.

See also:

[Monitored item model at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1)

[Monitoring mode at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1.3)

[`UA_SetMonitoringModeRequest`](@ref)

[`UA_SetMonitoringModeResponse`](@ref)
"""
function UA_Client_MonitoredItems_setMonitoringMode(client, request)
    response = UA_SetMonitoringModeResponse_new()
    __UA_Client_Service(client,
        request, UA_TYPES_PTRS[UA_TYPES_SETMONITORINGMODEREQUEST],
        response, UA_TYPES_PTRS[UA_TYPES_SETMONITORINGMODERESPONSE])
    return response
end

# #TODO: add tests
"""
```
response::Ptr{UA_SetTriggeringResponse} = UA_Client_MonitoredItems_setTriggering(client::Ptr{UA_Client}, 
    request::Ptr{UA_SetTriggeringRequest}) 
```

uses the client API to set the monitoring mode on monitored items. Note that
memory for the response is allocated by C and needs to be cleaned up using
`UA_SetTriggeringResponse_delete(response)` after its use.

See also:

[Monitored item model at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1)

[SetTriggering at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.5)

[`UA_SetTriggeringRequest`](@ref)

[`UA_SetTriggeringResponse`](@ref)
"""
function UA_Client_MonitoredItems_setTriggering(client, request)
    response = UA_SetTriggeringResponse_new()
    __UA_Client_Service(client,
        request, UA_TYPES_PTRS[UA_TYPES_SETTRIGGERINGREQUEST],
        response, UA_TYPES_PTRS[UA_TYPES_SETTRIGGERINGRESPONSE])
    return response
end

#TODO: add tests
"""
```
response::Ptr{UA_SetPublishingModeResponse} = UA_Client_Subscriptions_setPublishingMode(client::Ptr{UA_Client}, 
    request::Ptr{UA_SetPublishingModeRequest}) 
```

uses the client API to set the publishing mode on subscriptions. Note that
memory for the response is allocated by C and needs to be cleaned up using
`UA_SetPublishingModeResponse_delete(response)` after its use.

See also:

[Subscription model at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.13.1)

[SetPublishingMode at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.13.4)

[`UA_SetPublishingModeRequest`](@ref)

[`UA_SetPublishingModeResponse`](@ref)
"""
function UA_Client_Subscriptions_setPublishingMode(client, request)
    response = UA_SetPublishingModeResponse_new()
    __UA_Client_Service(client,
        request, UA_TYPES_PTRS[UA_TYPES_SETPUBLISHINGMODEREQUEST],
        response, UA_TYPES_PTRS[UA_TYPES_SETPUBLISHINGMODERESPONSE])
    return response
end

## Client Add node functions (including async)
for nodeclass in instances(UA_NodeClass)
    if nodeclass != __UA_NODECLASS_FORCE32BIT && nodeclass != UA_NODECLASS_UNSPECIFIED
        nodeclass_sym = Symbol(nodeclass)
        funname_sym = Symbol(replace(
            "UA_Client_add" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Node",
            "type" => "Type"))
        funname_sym_async = Symbol(replace(
            "UA_Client_add" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Node",
            "type" => "Type") * "_async")
        attributeptr_sym = Symbol(uppercase("UA_TYPES_" * string(nodeclass_sym)[14:end] *
                                            "ATTRIBUTES"))
        attributetype_sym = Symbol(replace(
            "UA_" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Attributes",
            "type" => "Type"))
        if funname_sym == :UA_Client_addVariableNode ||
           funname_sym == :UA_Client_addObjectNode
            @eval begin
                """
                ```
                $($(funname_sym))(::Ptr{UA_Client}, requestednewnodeid::Ptr{UA_NodeId}, 
                        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
                        browseName::Ptr{UA_QualifiedName}, typedefinition::Ptr{UA_NodeId},
                        attr::Ptr{$($(attributetype_sym))}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
                ```

                uses the client API to add a $(lowercase(string($nodeclass_sym)[14:end])) 
                node to the `client`.

                See [`$($(attributetype_sym))_generate`](@ref) on how to define valid 
                attributes.
                """
                function $(funname_sym)(client, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, typeDefinition, attributes,
                        outNewNodeId)
                    return __UA_Client_addNode(client, $(nodeclass_sym),
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, typeDefinition, attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)], outNewNodeId)
                end

                """
                ```
                $($(funname_sym_async))(::Ptr{UA_Client}, requestednewnodeid::Ptr{UA_NodeId}, 
                        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
                        browseName::Ptr{UA_QualifiedName}, typedefinition::Ptr{UA_NodeId},
                        attr::Ptr{$($(attributetype_sym))}, outNewNodeId::Ptr{UA_NodeId},
                        callback::UA_ClientAsyncAddNodesCallback, userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
                ```

                uses the asynchronous client API to add a $(lowercase(string($nodeclass_sym)[14:end])) 
                node to the `client`.

                See [`$($(attributetype_sym))_generate`](@ref) on how to define valid 
                attributes.
                """
                function $(funname_sym_async)(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, typeDefinition,
                        attributes, outNewNodeId, callback, userdata, reqId)
                    return __UA_Client_addNode_async(client, $(nodeclass_sym),
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, typeDefinition, attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)], outNewNodeId,
                        reinterpret(UA_ClientAsyncServiceCallback, callback),
                        userdata, reqId)
                end
            end
        elseif funname_sym != :UA_Client_addMethodNode #can't add method node via client.
            @eval begin
                """
                ```
                $($(funname_sym))(::Ptr{UA_Client}, requestednewnodeid::Ptr{UA_NodeId}, 
                        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
                        browseName::Ptr{UA_QualifiedName}, attr::Ptr{$($(attributetype_sym))}, 
                        outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
                ```

                uses the client API to add a $(lowercase(string($nodeclass_sym)[14:end])) 
                node to the `client`.

                See [`$($(attributetype_sym))_generate`](@ref) on how to define valid 
                attributes.
                """
                function $(funname_sym)(client, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, attributes, outNewNodeId)
                    return __UA_Client_addNode(client, $(nodeclass_sym),
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, UA_NODEID_NULL, attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)], outNewNodeId)
                end

                """
                ```
                $($(funname_sym_async))(::Ptr{UA_Client}, requestednewnodeid::Ptr{UA_NodeId}, 
                        parentnodeid::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, 
                        browseName::Ptr{UA_QualifiedName}, attr::Ptr{$($(attributetype_sym))}, 
                        outNewNodeId::Ptr{UA_NodeId}, callback::UA_ClientAsyncAddNodesCallback, 
                        userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
                ```

                uses the asynchronous client API to add a $(lowercase(string($nodeclass_sym)[14:end])) 
                node to the `client`.

                See [`$($(attributetype_sym))_generate`](@ref) on how to define valid 
                attributes.
                """
                function $(funname_sym_async)(client, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, attributes, outNewNodeId,
                        callback, userdata, reqId)
                    return __UA_Client_addNode_async(client, $(nodeclass_sym),
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, UA_NODEID_NULL, attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)], outNewNodeId,
                        reinterpret(UA_ClientAsyncServiceCallback, callback), userdata,
                        reqId)
                end
            end
        end
    end
end

## Read attribute functions
for att in attributes_UA_Client_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    returnobject = Symbol(att[3] * "_new")
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(Symbol(att[3]))[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        """
        ```
        $($(fun_name))(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, out::Ptr{$($(att[3]))})
        ```

        Uses the UA Client API to read the value of attribute $($(String(attr_name))) from the NodeId `nodeId` accessed through the client `client`. 

        """
        function $(fun_name)(client, nodeId, out)
            data_type_ptr = UA_TYPES_PTRS[$(ret_type_ptr)]
            statuscode = __UA_Client_readAttribute(client,
                nodeId,
                $(ua_attr_name),
                out,
                data_type_ptr)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Reading"
                side = "Client"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
    end
end

## Write attribute functions
for att in attributes_UA_Client_write
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        """
        ```
        $($(fun_name))(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, new_val::Ptr{$($(String(attr_type)))})
        ```

        Uses the UA Client API to write the value `new_val` to the attribute $($(String(attr_name))) of the NodeId `nodeId` accessed through the client `client`. 

        """
        function $(fun_name)(client, nodeId, new_attr)
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Client_writeAttribute(client,
                nodeId,
                $(ua_attr_name),
                new_attr,
                data_type_ptr)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Client"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
    end
end

# ## Write attribute async functions
for att in attributes_UA_Client_write_async
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))
    cbtype = attr_name == :Value ? "UA_ClientAsyncWriteCallback" :
             "UA_ClientAsyncServiceCallback"

    @eval begin
        """
        ```
        $($(fun_name))(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, newValue::Ptr{$($(String(attr_type)))},
            callback::$($(cbtype)), userdata::Ptr{Cvoid},
            requestId::UInt32)::UA_StatusCode
        ```

        Uses the asynchronous client API to write the value `newValue` to the attribute $($(String(attr_name))) 
        of the NodeId `nodeId` accessed through the client `client`. 

        """
        function $(fun_name)(client, nodeId, newValue, callback, userdata, reqId)
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Client_writeAttribute_async(client, nodeId,
                $(ua_attr_name), newValue, data_type_ptr, callback, userdata, reqId)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Client"
                mode = "asynchronously"
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
    end
end

## TODO: functions below here have no tests yet.
# """
# ```
# UA_Client_MonitoredItems_modify_async(client::Ptr{UA_Client}, 
#     request::Ptr{UA_ModifyMonitoredItemsRequest},
#     callback::UA_ClientAsyncServiceCallback,
#     userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
# ```

# uses the asynchronous client API to modify monitored items. 

# See also:

# [Monitored item model at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1)

# [`UA_ModifyMonitoredItemsRequest`](@ref)

# [`UA_ClientAsyncServiceCallback_generate`](@ref)
# """
# function UA_Client_MonitoredItems_modify_async(client, request, callback, userdata,
#         requestId)
#     return __UA_Client_AsyncService(client, request,
#         UA_TYPES_PTRS[UA_TYPES_MODIFYMONITOREDITEMSREQUEST], callback,
#         UA_TYPES_PTRS[UA_TYPES_MODIFYMONITOREDITEMSRESPONSE],
#         userdata, requestId)
# end

"""
```
UA_Client_MonitoredItems_setMonitoringMode_async(client::Ptr{UA_Client}, 
    request::Ptr{UA_SetMonitoringModeRequest},
    callback::UA_ClientAsyncServiceCallback,
    userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
```

uses the asynchronous client API to set the monitoring mode on monitored items.

See also:

[Monitored item model at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1)

[Monitoring mode at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1.3)

[`UA_SetMonitoringModeRequest`](@ref)

[`UA_ClientAsyncServiceCallback_generate`](@ref)
"""
function UA_Client_MonitoredItems_setMonitoringMode_async(client, request,
        callback, userdata, requestId)
    return __UA_Client_AsyncService(client, request,
        UA_TYPES_PTRS[UA_TYPES_SETMONITORINGMODEREQUEST], callback,
        UA_TYPES_PTRS[UA_TYPES_SETMONITORINGMODERESPONSE],
        userdata, requestId)
end

"""
```
UA_Client_MonitoredItems_setTriggering_async(client::Ptr{UA_Client}, 
    request::Ptr{UA_SetTriggeringRequest},
    callback::UA_ClientAsyncServiceCallback,
    userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
```

uses the asynchronous client API to set the triggering on monitored items.

See also:

[Monitored item model at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1)

[Monitoring mode at OPC Foundation](https://reference.opcfoundation.org/Core/Part4/v105/docs/5.12.1.3)

[`UA_SetTriggeringRequest`](@ref)

[`UA_ClientAsyncServiceCallback_generate`](@ref)
"""
function UA_Client_MonitoredItems_setTriggering_async(client, request, callback,
        userdata, requestId)
    return __UA_Client_AsyncService(client, request,
        UA_TYPES_PTRS[UA_TYPES_SETTRIGGERINGREQUEST], callback,
        UA_TYPES_PTRS[UA_TYPES_SETTRIGGERINGRESPONSE],
        userdata, requestId)
end

"""
```
UA_Client_sendAsyncReadRequest(client::Ptr{UA_Client}, 
    request::Ptr{UA_ReadRequest},
    readCallback::UA_ClientAsyncReadCallback,
    userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
```

uses the asynchronous client API to send a read request.

See also:

[`UA_ReadRequest`](@ref)

[`UA_ClientAsyncReadCallback_generate`](@ref)
"""
function UA_Client_sendAsyncReadRequest(client, request, readCallback, userdata,
        reqId)
    return UA_Client_sendAsyncRequest(client, request,
        UA_TYPES_PTRS[UA_TYPES_READREQUEST],
        reinterpret(UA_ClientAsyncServiceCallback, readCallback),
        UA_TYPES_PTRS[UA_TYPES_READRESPONSE], userdata, reqId)
end

"""
```
UA_Client_sendAsyncWriteRequest(client::Ptr{UA_Client}, 
    request::Ptr{UA_WriteRequest},
    readCallback::UA_ClientAsyncWriteCallback,
    userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
```

uses the asynchronous client API to send a write request.

See also:

[`UA_WriteRequest`](@ref)

[`UA_ClientAsyncWriteCallback_generate`](@ref)
"""
function UA_Client_sendAsyncWriteRequest(client, request, writeCallback, userdata,
        reqId)
    return UA_Client_sendAsyncRequest(
        client, request, UA_TYPES_PTRS[UA_TYPES_WRITEREQUEST],
        reinterpret(UA_ClientAsyncServiceCallback, writeCallback),
        UA_TYPES_PTRS[UA_TYPES_WRITERESPONSE], userdata, reqId)
end

"""
```
UA_Client_sendAsyncBrowseRequest(client::Ptr{UA_Client}, 
    request::Ptr{UA_BrowseRequest},
    readCallback::UA_ClientAsyncBrowseCallback,
    userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
```

uses the asynchronous client API to send a browse request.

See also:

[`UA_BrowseRequest`](@ref)

[`UA_ClientAsyncBrowseCallback_generate`](@ref)
"""
function UA_Client_sendAsyncBrowseRequest(client, request, browseCallback,
        userdata, reqId)
    return UA_Client_sendAsyncRequest(client, request,
        UA_TYPES_PTRS[UA_TYPES_BROWSEREQUEST],
        reinterpret(UA_ClientAsyncServiceCallback, browseCallback),
        UA_TYPES_PTRS[UA_TYPES_BROWSERESPONSE], userdata,
        reqId)
end

# """
# ```
# UA_Client_writeMinimumSamplingIntervalAttribute_async(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, 
#     newValue::Float64, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid},
#     requestId::UInt32)::UA_StatusCode
# ```

# Uses the asynchronous client API to write the value `newValue` to the attribute MinimumSamplingInterval
# of the NodeId `nodeId` accessed through the client `client`. 

# """
# function UA_Client_writeMinimumSamplingIntervalAttribute_async(client, nodeId,
#         outMinimumSamplingInterval, callback, userdata, reqId)
#     return __UA_Client_writeAttribute_async(client, nodeId,
#         UA_ATTRIBUTEID_MINIMUMSAMPLINGINTERVAL,
#         wrap_ref(outMinimumSamplingInterval), UA_TYPES_PTRS[UA_TYPES_DOUBLE], callback, userdata,
#         reqId)
# end

"""
```
UA_Client_call_async(client::Ptr{UA_Client}, objectId::Ptr{UA_NodeId}, methodId::Ptr{UA_NodeId},
    inputSize::Csize_t, input::Ptr{UA_Variant}, callback::UA_ClientAsyncCallCallback, 
    userdata::Ptr{Cvoid}, requestId::UInt32)::UA_StatusCode
```

uses the asynchronous client API to call the method `methodId` on the server the
client is connected with.

See also:
[`UA_ClientAsyncCallCallback_generate`](@ref)
"""
function UA_Client_call_async(client, objectId, methodId, inputSize, input,
        callback, userdata, reqId)
    return __UA_Client_call_async(client, objectId, methodId, inputSize, input,
        reinterpret(UA_ClientAsyncServiceCallback, callback), userdata, reqId)
end

#TODO: IMPLEMENT
# function UA_Client_Service_translateBrowsePathsToNodeIds(client, request)
#     UA_TranslateBrowsePathsToNodeIdsResponse response;
#     __UA_Client_Service(
#         client, &request,
#         &UA_TYPES[UA_TYPES_TRANSLATEBROWSEPATHSTONODEIDSREQUEST],
#         &response,
#         &UA_TYPES[UA_TYPES_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE]);
#     return response
# end

#TODO: IMPLEMENT
# UA_Client_sendAsyncBrowseNextRequest(
#     UA_Client *client, UA_BrowseNextRequest *request,
#     UA_ClientAsyncBrowseNextCallback browseNextCallback,
#     void *userdata, UA_UInt32 *reqId) {
#     return __UA_Client_AsyncService(
#         client, request, &UA_TYPES[UA_TYPES_BROWSENEXTREQUEST],
#         (UA_ClientAsyncServiceCallback)browseNextCallback,
#         &UA_TYPES[UA_TYPES_BROWSENEXTRESPONSE], userdata, reqId);
# }
