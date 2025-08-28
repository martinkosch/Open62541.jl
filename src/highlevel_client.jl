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

"""
```
JUA_ClientConfig_setAuthenticationUsername(config::JUA_ClientConfig, username::AbstractString, 
    password::AbstractString)::UA_StatusCode
```

Configure Username/Password for the Session authentication. Also see 
`JUA_ClientConfig_setAuthenticationCert` for x509-based authentication.


"""
function JUA_ClientConfig_setAuthenticationUsername(config::JUA_ClientConfig, username::AbstractString, 
        password::AbstractString)
    username_ptr = UA_STRING_ALLOC(username)
    password_ptr = UA_STRING_ALLOC(password) 
    sc = UA_ClientConfig_setAuthenticationUsername(config, username_ptr, password_ptr)
    return sc
end

"""
```
JUA_Client_connect(client::JUA_Client, endpointurl::AbstractString)::UA_StatusCode
```

connect the `client` to the server with `endpointurl`. This is an anonymous connection, i.e.,
no username or password are used (some servers do not allow this).

"""
function JUA_Client_connect(client::JUA_Client, endpointurl::AbstractString)
    #simple wrapper to directly allow endpointurl with a Julia AbstractString
    endpointurl_ptr = UA_STRING_ALLOC(endpointurl)
    sc = UA_Client_connect(client, endpointurl_ptr)
    UA_String_delete(endpointurl_ptr)
    return sc
end

"""
```
JUA_Client_connectUsername(client::JUA_Client, endpointurl::AbstractString, 
    username::AbstractString, password::AbstractString)::UA_StatusCode
```

connects the `client` to the server with endpoint URL `endpointurl` and supplies
`username` and `password` as login credentials.

"""
function JUA_Client_connectUsername(client::JUA_Client, endpointurl::AbstractString, 
        username::AbstractString, password::AbstractString)
    username_ptr = UA_STRING_ALLOC(username)
    password_ptr = UA_STRING_ALLOC(password)
    endpointurl_ptr = UA_STRING_ALLOC(endpointurl)
    sc = UA_Client_connectUsername(client, endpointurl_ptr, username_ptr, password_ptr)
    UA_String_delete(username_ptr)
    UA_String_delete(password_ptr)
    UA_String_delete(endpointurl_ptr)
    return sc
end

"""
```
JUA_Client_connectAsync(client::JUA_Client, endpointurl::AbstractString)::UA_StatusCode
```

connect the `client` to the server with `endpointurl` *asynchronously* (non-blocking). This 
is an anonymous connection, i.e., no username or password are used (some servers do not 
allow this).

After initiating the connection, call `UA_Client_run_iterate` repeatedly until the connection 
is fully established. You can set a callback to client->config.stateCallback to be notified 
when the connection status changes. Or use `JUA_Client_getState` to get the state manually.

See also:

[`JUA_Client_getState`](@ref)

[`UA_ClientConfig_stateCallback_generate`](@ref)

[`UA_Client_run_iterate`](@ref)

"""
function JUA_Client_connectAsync(client, endpointurl)
    endpointurl_ptr = UA_STRING_ALLOC(endpointurl) 
    sc = UA_Client_connectAsync(client, endpointurl_ptr)
    UA_String_delete(endpointurl_ptr)
    return sc
end

"""
```
JUA_Client_connectSecureChannel(client::JUA_Client, endpointurl::AbstractString)::UA_StatusCode
```

connect the `client` to the server with `endpointurl` without creating a session.

"""
function JUA_Client_connectSecureChannel(client::JUA_Client, endpointurl::AbstractString)
    endpointurl_ptr = UA_STRING_ALLOC(endpointurl)
    sc = UA_Client_connect(client, endpointurl_ptr)
    UA_String_delete(endpointurl_ptr)
    return sc
end

"""
```
JUA_Client_connectSecureChannelAsync(client::JUA_Client, endpointurl::AbstractString)::UA_StatusCode
```

connect the `client` to the server with `endpointurl` *asynchronously* (non-blocking) 
without creating a session.

After initiating the connection, call `UA_Client_run_iterate` repeatedly until the connection 
is fully established. You can set a callback to client->config.stateCallback to be notified 
when the connection status changes. Or use `JUA_Client_getState` to get the state manually.

See also:

[`JUA_Client_getState`](@ref)

[`UA_ClientConfig_stateCallback_generate`](@ref)

[`UA_Client_run_iterate`](@ref)

"""
function JUA_Client_connectSecureChannelAsync(client, endpointurl)
    endpointurl_ptr = UA_STRING_ALLOC(endpointurl)
    sc = UA_Client_connectSecureChannelAsync(client, endpointurl_ptr)
    UA_String_delete(endpointurl_ptr)
    return sc
end

"""
```
JUA_Client_connectUsernameAsync(client::JUA_Client, endpointurl::AbstractString, 
    username::AbstractString, password::AbstractString)::UA_StatusCode
```

connect the `client` to the server with `endpointurl` *asynchronously* (non-blocking) 
and supplies `username` and `password` as login credentials.

After initiating the connection, call `UA_Client_run_iterate` repeatedly until the connection 
is fully established. You can set a callback to client->config.stateCallback to be notified 
when the connection status changes. Or use `JUA_Client_getState` to get the state manually.

See also:

[`JUA_Client_getState`](@ref)

[`UA_ClientConfig_stateCallback_generate`](@ref)

[`UA_Client_run_iterate`](@ref)

"""
function JUA_Client_connectUsernameAsync(client::JUA_Client, endpointurl::AbstractString, 
        username::AbstractString, password::AbstractString)
    username_ptr = UA_STRING_ALLOC(username)
    password_ptr = UA_STRING_ALLOC(password)
    endpointurl_ptr = UA_STRING_ALLOC(endpointurl)
    sc = UA_Client_connectUsernameAsync(client, endpointurl_ptr, username_ptr, password_ptr)
    UA_String_delete(username_ptr)
    UA_String_delete(password_ptr)
    UA_String_delete(endpointurl_ptr)
    return sc
end

const JUA_Client_disconnect = UA_Client_disconnect

"""
```
channelState::UInt32, sessionState::UInt32, connectStatus::UA_StatusCode = JUA_Client_getState(client::JUA_Client)::UA_StatusCode
```

returns the state of the `client`, particularly:
- `channelState`: the status of the secure channel between client and server.
- `sessionState`: the status of the session between client and server.
- `connectStatus`: the status of the connection between client and server. 

The returned values are `UInt32`, whose meaning is documented in `UA_SecureChannelState`, 
`UA_SessionState` and `UA_ConnectionState`.

"""
function JUA_Client_getState(client::JUA_Client)
    channelState_ptr = UA_UInt32_new()
    sessionState_ptr = UA_UInt32_new()
    connectStatus_ptr = UA_UInt32_new()
    UA_Client_getState(client, channelState_ptr, sessionState_ptr, connectStatus_ptr)
    channelState = unsafe_load(channelState_ptr)
    sessionState = unsafe_load(sessionState_ptr)
    connectStatus = unsafe_load(connectStatus_ptr)
    UA_UInt32_delete(channelState_ptr)
    UA_UInt32_delete(sessionState_ptr)
    UA_UInt32_delete(connectStatus_ptr)
    return channelState, sessionState, connectStatus
end

#Add node functions
"""
```
JUA_Client_addNode(client::JUA_Client, requestedNewNodeId::JUA_NodeId,
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName, 
        attributes::Union{JUA_VariableAttributes, JUA_ObjectAttributes},
        outNewNodeId::JUA_NodeId, typeDefinition::JUA_NodeId)::UA_StatusCode
```

uses the client API to add a Variable or Object node to the server
to which the client is connected to.

See [`JUA_VariableAttributes`](@ref), [`JUA_VariableTypeAttributes`](@ref), and [`JUA_ObjectAttributes`](@ref)
on how to define valid attributes.

```
JUA_Client_addNode(client::JUA_Client, requestedNewNodeId::JUA_NodeId,
        parentNodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName,
        attributes::Union{JUA_VariableTypeAttributes, JUA_ObjectTypeAttributes, 
        JUA_ReferenceTypeAttributes, JUA_DataTypeAttributes, JUA_ViewAttributes},
        outNewNodeId::JUA_NodeId)::UA_StatusCode
```

uses the client API to add a ObjectType, ReferenceType, DataType or View node
to the server to which the client is connected to.

See [`JUA_VariableTypeAttributes](@ref), [`JUA_ObjectTypeAttributes`](@ref), [`JUA_ReferenceTypeAttributes`](@ref), [`JUA_DataTypeAttributes`](@ref), and [`JUA_ViewAttributes`](@ref) on how to define valid attributes.
"""
function JUA_Client_addNode end

"""
```
JUA_Client_addNode_async(client::JUA_Client, requestedNewNodeId::JUA_NodeId,
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName, 
        attributes::Union{JUA_VariableAttributes, JUA_ObjectAttributes},
        outNewNodeId::JUA_NodeId, callback::UA_ClientAsyncAddNodesCallback, 
        userdata::Ptr{Cvoid}, requestId::UInt32, typeDefinition::JUA_NodeId)::UA_StatusCode
```

uses the **asynchronous** client API to add a Variable or Object node to the server
to which the client is connected to.

See [`JUA_VariableAttributes`](@ref) or [`JUA_ObjectAttributes`](@ref)
on how to define valid attributes.

```
JUA_Client_addNode_async(client::JUA_Client, requestedNewNodeId::JUA_NodeId,
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName, 
        attributes::Union{JUA_VariableTypeAttributes, JUA_ObjectTypeAttributes, 
        JUA_ViewAttributes, JUA_ReferenceTypeAttributes, JUA_DataTypeAttributes},
        outNewNodeId::JUA_NodeId, callback::UA_ClientAsyncAddNodesCallback, 
        userdata::Ptr{Cvoid}, requestId::UInt32, typeDefinition::JUA_NodeId)::UA_StatusCode
```

uses the **asynchronous** client API to add a VariableType, ObjectType, ReferenceType, DataType
or View node to the server to which the client is connected to.

See [`JUA_VariableTypeAttributes`](@ref), [`JUA_ObjectTypeAttributes`](@ref),
[`JUA_ReferenceTypeAttributes`](@ref), [`JUA_DataTypeAttributes`](@ref),
and [`JUA_ViewAttributes`](@ref) on how to define valid attributes.
"""
function JUA_Client_addNode_async end

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
        attributetype_sym_J = Symbol("J" * replace(
            "UA_" *
            titlecase(string(nodeclass_sym)[14:end]) *
            "Attributes",
            "type" => "Type"))
        if funname_sym == :UA_Client_addVariableNode ||
           funname_sym == :UA_Client_addObjectNode
            @eval begin
                function JUA_Client_addNode(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J),
                        outNewNodeId, typeDefinition)
                    return $(funname_sym)(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, typeDefinition,
                        attributes, outNewNodeId)
                end
                function JUA_Client_addNode_async(client,
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, attributes::$(attributetype_sym_J),
                        outNewNodeId, callback, userdata, reqId, typeDefinition)
                    return $(funname_sym_async)(client, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, typeDefinition, attributes,
                        outNewNodeId, callback, userdata, reqId)
                end
            end
        elseif funname_sym != :UA_Client_addMethodNode #can't add method node via client.
            @eval begin
                function JUA_Client_addNode(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J), outNewNodeId)
                    return $(funname_sym)(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, attributes,
                        outNewNodeId)
                end
                function JUA_Client_addNode_async(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::$(attributetype_sym_J), outNewNodeId,
                        callback, userdata, reqId)
                    return $(funname_sym_async)(client, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, attributes,
                        outNewNodeId, callback, userdata, reqId)
                end
            end
        end
    end
end

#Client read and write functions
"""
```
value = JUA_Client_readValueAttribute(client::JUA_Client, nodeId::JUA_NodeId, type = Any)
```

uses the client API to read the value of `nodeId` from the server that the `client`
is connected to. In case the client has no live connection to a server, automatic 
reconnection is attempted.

The output `value` is automatically converted to a Julia type (such as Float64, String, Vector{String},
etc.) if possible. Otherwise, open62541 composite types are returned.

Note: Since it is unknown what type of value is stored within `nodeId` before reading
it, this function is inherently type unstable.

Type stability is improved if the optional argument `type` is provided, for example,
if you know that you have stored a Matrix{Float64} in `nodeId`, then you should
specify this. If the wrong type is specified, the function will throw a TypeError.
"""
function JUA_Client_readValueAttribute(client, nodeId, type::T = Any) where {T}
    #automated reconnect.
    channelState, sessionState, connectStatus = JUA_Client_getState(client)
    if channelState != UA_SECURECHANNELSTATE_OPEN || sessionState != UA_SESSIONSTATE_ACTIVATED
        cc = UA_Client_getConfig(client)
        UA_Client_connect(client, cc.endpointUrl)
    end
    v = UA_Variant_new()
    UA_Client_readValueAttribute(client, nodeId, v)
    r = __get_juliavalues_from_variant(v, type)
    UA_Variant_delete(v)
    return r
end

"""
```
JUA_Client_writeValueAttribute(client::JUA_Client, nodeId::JUA_NodeId, newvalue)::UA_StatusCode
```

uses the client API to write the value `newvalue` to `nodeId` to the server that
the `client` is connected to. In case the client has no live connection to a server, 
automatic reconnection is attempted.

`new_value` must either be a `JUA_Variant` or a Julia value/array compatible with
any of its constructors.

See also [`JUA_Variant`](@ref)
"""
function JUA_Client_writeValueAttribute(client, nodeId, newvalue)
    newvariant = JUA_Variant(newvalue)
    return JUA_Client_writeValueAttribute(client, nodeId, newvariant)
end

function JUA_Client_writeValueAttribute(client, nodeId, newvalue::JUA_Variant)
    #automated reconnect.
    channelState, sessionState, connectStatus = JUA_Client_getState(client)
    if channelState != UA_SECURECHANNELSTATE_OPEN || sessionState != UA_SESSIONSTATE_ACTIVATED
        cc = UA_Client_getConfig(client)
        UA_Client_connect(client, cc.endpointUrl)
    end
    statuscode = UA_Client_writeValueAttribute(client, nodeId, newvalue)
    return statuscode
end

#Client call wrapper
"""
```
output::Union{Any, Tuple{Any, ...}} = JUA_Client_call(client::JUA_Client, 
    parentnodeid::JUA_NodeId, methodid::JUA_NodeId, inputs::Union{Any, Tuple{Any, ...}})
```

uses the client API to call a method node (`methodid`) on the server the `client` is
connected with.  `inputs` can either be a single argument or a tuple of arguments. Depending
on the method called an apporpriate output or tuple of output arguments is returned.
"""
function JUA_Client_call(
        client::JUA_Client, parentnodeid::JUA_NodeId, methodid::JUA_NodeId,
        inputs)
    JUA_Client_call(client, parentnodeid, methodid, (inputs,))
end

function JUA_Client_call(
        client::JUA_Client, parentnodeid::JUA_NodeId, methodid::JUA_NodeId,
        inputs::Tuple)
    #browse children nodes of methodid to infer properties of input and output arguments
    e = nothing
    breq = UA_BrowseRequest_new()
    UA_BrowseRequest_init(breq)
    breq.requestedMaxReferencesPerNode = 0
    bd = UA_BrowseDescription_new()
    bd.nodeId = methodid
    bd.resultMask = UA_BROWSERESULTMASK_ALL
    breq.nodesToBrowse = bd
    breq.nodesToBrowseSize = 1

    bresp = UA_Client_Service_browse(client, breq)
    nresults = unsafe_load(bresp.resultsSize)
    if nresults == 1
        results = unsafe_load(bresp.results)
        nrefs = unsafe_load(results.referencesSize) #should be 2 (in and output arguments)
        if nrefs == 2
            refs = UA_Array(unsafe_load(results.references), 2)
            if unsafe_string(refs[1].browseName.name) == "InputArguments"
                j = 1
            else
                j = 2
            end
            k = j == 1 ? 2 : 1
            nodeid_inputargs = refs[j].nodeId.nodeId
            nodeid_outputargs = refs[k].nodeId.nodeId
        else
            e = "something went wrong while browsing the nodes."
        end
    else
        e = "something went wrong while browsing the nodes."
    end

    inputarguments = JUA_Client_readValueAttribute(client, nodeid_inputargs)
    outputarguments = JUA_Client_readValueAttribute(client, nodeid_outputargs)

    if length(inputarguments) != length(inputs)
        e = MethodNodeInputError(length(inputs), length(inputarguments))
        throw(e)
    end

    input_variants = UA_Variant_Array_new(length(inputs))
    for i in 1:length(inputs)
        UA_Variant_copy(Jpointer(JUA_Variant(inputs[i])), input_variants[i])
    end

    arr_output = UA_Variant_Array_new(length(outputarguments))
    ref = Ref(arr_output[1])
    sc = UA_Client_call(client, parentnodeid, methodid, length(inputs),
        input_variants.ptr, Ref(UInt64(length(outputarguments))), ref)

    UA_BrowseRequest_delete(breq)
    UA_BrowseResponse_delete(bresp)
    UA_Variant_Array_delete(input_variants)

    if !isnothing(e)
        error(e)
    end

    if sc != UA_STATUSCODE_GOOD
        throw(ClientServiceRequestError("Calling method via Client API failed with statuscode \"$(UA_StatusCode_name_print(sc))\"."))
    else
        arr_output2 = UA_Array(ref[], length(outputarguments))
        r = __get_juliavalues_from_variant.(arr_output2, Any)

        UA_Variant_Array_delete(arr_output)
        if length(outputarguments) == 1
            return r[1]
        else
            return tuple(r...)
        end
    end
end
