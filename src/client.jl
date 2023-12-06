UA_Client_getContext(client::UA_Client) = UA_Client_getConfig(client).clientContext

function UA_Client_connectUsername(client::Ptr{UA_Client},
        endpointUrl::AbstractString,
        username::AbstractString,
        password::AbstractString)
    identityToken = UA_UserNameIdentityToken_new()
    identityToken == CNULL && return UA_STATUSCODE_BADOUTOFMEMORY
    identityToken.userName = UA_STRING_ALLOC(username)
    identityToken.password = UA_STRING_ALLOC(password)
    cc = UA_Client_getConfig(client)
    UA_ExtensionObject_clear(cc.userIdentityToken)
    cc.userIdentityToken.encoding = UA_EXTENSIONOBJECT_DECODED
    cc.userIdentityToken.content.decoded.type = UA_TYPES_PTRS[UA_TYPES_USERNAMEIDENTITYTOKEN]
    cc.userIdentityToken.content.decoded.data = identityToken
    return UA_Client_connect(client, endpointUrl)
end

## UA_Client_Service functions
for att in attributes_UA_Client_Service
    fun_name = Symbol(att[1])
    req_type = Symbol("UA_", uppercasefirst(att[2]), "Request")
    resp_type = Symbol("UA_", uppercasefirst(att[2]), "Response")
    req_type_ptr = Symbol("UA_TYPES_", uppercase(String(att[2])), "REQUEST")
    resp_type_ptr = Symbol("UA_TYPES_", uppercase(String(att[2])), "RESPONSE")

    @eval begin
        if @isdefined $(req_type) # Skip functions that use undefined types, e.g. deactivated historizing types
            function $(fun_name)(client::Ref{UA_Client}, request::Ptr{$(req_type)})
                response = Ref{$(resp_type)}()
                statuscode = __UA_Client_Service(client,
                    request,
                    UA_TYPES_PTRS[$(req_type_ptr)],
                    response,
                    UA_TYPES_PTRS[$(resp_type_ptr)])
                if isnothing(statuscode) || statuscode == UA_STATUSCODE_GOOD
                    return response[]
                else
                    throw(ClientServiceRequestError("Service request of type ´$(req_type)´ from UA_Client failed with statuscode \"$(UA_StatusCode_name_print(statuscode))\"."))
                end
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        $(fun_name)(client, request) = $(fun_name)(wrap_ref(client), wrap_ref(request))
    end
end

## Read attribute functions
for att in attributes_UA_Client_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3])
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(client::Ref{UA_Client}, nodeId::Ref{UA_NodeId})
            data_type_ptr = UA_TYPES_PTRS[$(ret_type_ptr)]
            out = Ref{$(ret_type)}()
            statuscode = __UA_Client_readAttribute(client,
                nodeId,
                $(ua_attr_name),
                out,
                data_type_ptr)
            if statuscode == UA_STATUSCODE_GOOD
                return out[]
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
        #function fallback that wraps any non-ref arguments into refs:
        $(fun_name)(client, nodeId) = $(fun_name)(wrap_ref(client), wrap_ref(nodeId))
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
        function $(fun_name)(client::Ref{UA_Client},
                nodeId::Ref{UA_NodeId},
                new_attr::Ref{$attr_type})
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
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(client, nodeId, new_attr)
            return ($fun_name)(wrap_ref(client),
                wrap_ref(nodeId),
                wrap_ref(new_attr))
        end
    end
end

## Read attribute async functions
for att in attributes_UA_Client_read_async
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3])
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(client::Ref{UA_Client},
                nodeId::Ref{UA_NodeId},
                callback::Ref{Nothing},
                userdata::Ref{Nothing},
                reqId::Integer)
            data_type_ptr = UA_TYPES_PTRS[$(ret_type_ptr)]
            statuscode = __UA_Client_readAttribute_async(client,
                nodeId,
                $(ua_attr_name),
                data_type_ptr,
                reinterpret(UA_ClientAsyncServiceCallback, callback),
                userdata,
                reqId)
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
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(client, nodeId, callback, userdata, reqId)
            return $(fun_name)(wrap_ref(client),
                wrap_ref(nodeId),
                wrap_ref(callback),
                wrap_ref(userdata),
                reqId::Integer)
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

    @eval begin
        function $(fun_name)(client::Ref{UA_Client},
                nodeId::Ref{UA_NodeId},
                out::Ref{$(attr_type)},
                callback::Ref{Nothing},
                userdata::Ref{Nothing},
                reqId::Integer)
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Client_writeAttribute_async(client,
                nodeId,
                $(ua_attr_name),
                out,
                data_type_ptr,
                callback,
                userdata,
                reqId)
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
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(client, nodeId, out, callback, userdata, reqId)
            return $(fun_name)(wrap_ref(client),
                wrap_ref(nodeId),
                wrap_ref(out),
                wrap_ref(callback),
                wrap_ref(userdata),
                reqId::Integer)
        end
    end
end
