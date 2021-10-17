UA_Client_getContext(client::UA_Client) = UA_Client_getConfig(client).clientContext

function UA_Client_connectUsername(client::Ptr{UA_Client}, endpointUrl::AbstractString, username::AbstractString, password::AbstractString)
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
        try
            function $(fun_name)(client::Ptr{UA_Client}, request::Ptr{$(req_type)})
                response = Ref{$(resp_type)}()
                __UA_Client_Service(
                    client, 
                    request, 
                    UA_TYPES_PTRS[$(req_type_ptr)],
                    response, 
                    UA_TYPES_PTRS[$(resp_type_ptr)]
                )
                if retval == UA_STATUSCODE_GOOD
                    return response[]
                else
                    error("Service request of type ´$(req_type)´ from UA_Client failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
                end
            end
        catch # Skip functions that may be not defined, e.g. historizing functions
        end
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
        function $(fun_name)(client::Ptr{UA_Client}, nodeId::Ref{UA_NodeId})
            data_type_ptr = UA_TYPES_PTRS[$(ret_type_ptr)]
            out = Ref{$(ret_type)}()
            retval = __UA_Client_readAttribute(client, nodeId, $(ua_attr_name), out, data_type_ptr)
            if retval == UA_STATUSCODE_GOOD
                return out[]
            else
                error("Reading attribute ´$(attr_name)´ from UA_Client failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
            end
        end

        function $(fun_name)(client::Ptr{UA_Client}, nodeId::UA_NodeId) 
            return $(fun_name)(client, Ref(nodeId))
        end
    end
end