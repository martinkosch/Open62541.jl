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

Base.show(io::IO, ::MIME"text/plain", v::JUA_Server) = print(io, "$(typeof(v))\n")

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
const JUA_ServerConfig_setDefaultWithSecurityPolicies = UA_ServerConfig_setDefaultWithSecurityPolicies
const JUA_ServerConfig_setDefaultWithSecureSecurityPolicies = UA_ServerConfig_setDefaultWithSecureSecurityPolicies
const JUA_ServerConfig_setBasics = UA_ServerConfig_setBasics
const JUA_ServerConfig_setBasics_withPort = UA_ServerConfig_setBasics_withPort
const JUA_ServerConfig_addSecurityPolicyNone = UA_ServerConfig_addSecurityPolicyNone
const JUA_ServerConfig_addSecurityPolicyBasic128Rsa15 = UA_ServerConfig_addSecurityPolicyBasic128Rsa15
const JUA_ServerConfig_addSecurityPolicyBasic256 = UA_ServerConfig_addSecurityPolicyBasic256
const JUA_ServerConfig_addSecurityPolicyBasic256Sha256 = UA_ServerConfig_addSecurityPolicyBasic256Sha256
const JUA_ServerConfig_addSecurityPolicyAes128Sha256RsaOaep = UA_ServerConfig_addSecurityPolicyAes128Sha256RsaOaep
const JUA_ServerConfig_addSecurityPolicyAes256Sha256RsaPss = UA_ServerConfig_addSecurityPolicyAes256Sha256RsaPss
const JUA_ServerConfig_addAllSecurityPolicies = UA_ServerConfig_addAllSecurityPolicies
const JUA_ServerConfig_addAllSecureSecurityPolicies = UA_ServerConfig_addAllSecureSecurityPolicies
const JUA_ServerConfig_addEndpoint = UA_ServerConfig_addEndpoint
const JUA_ServerConfig_addAllEndpoints = UA_ServerConfig_addAllEndpoints
const JUA_ServerConfig_addAllSecureEndpoints = UA_ServerConfig_addAllSecureEndpoints

"""
```
JUA_ServerConfig_setMinimal(config, portNumber[, certificate])
```

creates a new server config with one endpoint. The config will set the tcp
network layer to the given port and adds a single endpoint with the security
policy ``SecurityPolicy#None`` to the server. A server certificate may be
supplied but is optional.
"""
JUA_ServerConfig_setMinimal(config, portNumber, certificate = C_NULL) = UA_ServerConfig_setMinimal(config, portNumber, certificate)

const JUA_ServerConfig_setDefault = UA_ServerConfig_setDefault
const JUA_ServerConfig_clean = UA_ServerConfig_clean

"""
```
JUA_AccessControl_default(config::JUA_ServerConfig, allowAnonymous::Bool, 
    usernamePasswordLogin::Union{JUA_UsernamePasswordLogin, AbstractArray{JUA_UsernamePasswordLogin}}, 
    [userTokenPolicyUri::AbstractString])::UA_StatusCode
```

sets default access control options in a server configuration.

"""

function JUA_AccessControl_default(config::JUA_ServerConfig, allowAnonymous::Bool, 
            usernamePasswordLogin::Union{JUA_UsernamePasswordLogin,AbstractArray{JUA_UsernamePasswordLogin}})
    JUA_AccessControl_default(config, allowAnonymous, usernamePasswordLogin, 
        Ref(unsafe_load(unsafe_load(config.securityPolicies)).policyUri)) 
end

function JUA_AccessControl_default(config::JUA_ServerConfig, allowAnonymous::Bool, 
            usernamePasswordLogin::Union{JUA_UsernamePasswordLogin,AbstractArray{JUA_UsernamePasswordLogin}}, userTokenPolicyUri::AbstractString)
    ua_s = UA_STRING(userTokenPolicyUri)
    JUA_AccessControl_default(config, allowAnonymous, usernamePasswordLogin, ua_s)
end

function JUA_AccessControl_default(config::JUA_ServerConfig, allowAnonymous::Bool, 
        usernamePasswordLogin::JUA_UsernamePasswordLogin, 
        userTokenPolicyUri::Union{Ref{UA_String}, Ptr{UA_String}})
    UA_AccessControl_default(config, allowAnonymous, userTokenPolicyUri, 1, Ref(usernamePasswordLogin.login))
end

function JUA_AccessControl_default(config::JUA_ServerConfig, allowAnonymous::Bool, 
        usernamePasswordLogin::AbstractArray{JUA_UsernamePasswordLogin}, 
        userTokenPolicyUri::Union{Ref{UA_String}, Ptr{UA_String}})
    logins = [usernamePasswordLogin[i].login for i in eachindex(usernamePasswordLogin)]
    UA_AccessControl_default(config, allowAnonymous, userTokenPolicyUri, length(logins), logins)
end

    
#const JUA_AccessControl_defaultWithLoginCallback = UA_AccessControl_defaultWithLoginCallback #TODO: complete this

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
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName,
        attributes::Union{JUA_ObjectTypeAttributes, JUA_ReferenceTypeAttributes, JUA_DataTypeAttributes, JUA_ViewAttributes},
        outNewNodeId::JUA_NodeId, nodeContext::JUA_NodeId)::UA_StatusCode
```

uses the server API to add a ObjectType, ReferenceType, DataType, or View node to the `server`.

See [`JUA_ObjectTypeAttributes`](@ref), [`JUA_ReferenceTypeAttributes`](@ref), [`JUA_DataTypeAttributes`](@ref), and [`JUA_ViewAttributes`](@ref) on how to define valid attributes.

```
JUA_Server_addNode(server::JUA_Server, requestedNewNodeId::JUA_NodeId,
        parentNodeId::JUA_NodeId, referenceTypeId::JUA_NodeId, browseName::JUA_QualifiedName,
        attributes::JUA_MethodAttributes, method::Union{Function, Ptr{Cvoid}, Base.CFunction},
        outNewNodeId::JUA_NodeId, nodeContext::JUA_NodeId)::UA_StatusCode
```

uses the server API to add a Method node to the `server`.

The method supplied

See [`JUA_MethodAttributes`](@ref) on how to define valid attributes.


"""
function JUA_Server_addNode(server, requestedNewNodeId,
        parentNodeId, referenceTypeId, browseName,
        attributes::JUA_MethodAttributes, method, 
        inputArguments::Union{UA_Array, JUA_Argument},
        outputArguments::Union{UA_Array, JUA_Argument}, nodeContext, 
        outNewNodeId)
    if inputArguments isa UA_Array
        inputargs = inputArguments.ptr
    else
        inputargs = inputArguments
    end
    if outputArguments isa UA_Array
        outputargs = outputArguments.ptr
    else
        outputargs = outputArguments
    end
    return UA_Server_addMethodNode(server, requestedNewNodeId, parentNodeId,
        referenceTypeId, browseName, Jpointer(attributes), __callback_wrap(method),
        __argsize(inputArguments), inputargs, __argsize(outputArguments),
        outputargs, nodeContext, outNewNodeId)
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
                        nodeContext, outNewNodeId, typeDefinition)
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
                        nodeContext, outNewNodeId)
                    return $(funname_sym)(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, attributes,
                        nodeContext, outNewNodeId)
                end
            end
        end
    end
end

#Server read and write functions
"""
```
value = JUA_Server_readValue(server::JUA_Server, nodeId::JUA_NodeId, type = Any)
```

uses the server API to read the value of `nodeId` from `server`. Output is 
automatically converted to a Julia type (such as Float64, String, Vector{String}, 
etc.) if possible. Otherwise, open62541 composite types are returned.

Note: Since it is unknown what type of value is stored within `nodeId` before reading 
it, this function is inherently type unstable. 

Type stability is improved if the optional argument `type` is provided, for example, 
if you know that you have stored a Matrix{Float64} in `nodeId`, then you should 
specify this. If the wrong type is specified, the function will throw a TypeError.

"""
function JUA_Server_readValue(server, nodeId, type::T = Any) where {T}
    v = UA_Variant_new()
    UA_Server_readValue(server, nodeId, v)
    r = __get_juliavalues_from_variant(v, type)
    UA_Variant_delete(v)
    return r
end

"""
```
JUA_Server_writeValue(server::JUA_Server, nodeId::JUA_NodeId, newvalue)::UA_StatusCode
```

uses the server API to write the value `newvalue` to `nodeId` on `server`. 
`new_value` must either be a `JUA_Variant` or a Julia value/array compatible with 
any of its constructors. 

See also [`JUA_Variant`](@ref)

"""
function JUA_Server_writeValue(server, nodeId, newvalue)
    newvariant = JUA_Variant(newvalue)
    return JUA_Server_writeValue(server, nodeId, newvariant)
end

function JUA_Server_writeValue(server, nodeId, newvalue::JUA_Variant)
    statuscode = UA_Server_writeValue(server, nodeId, unsafe_load(Jpointer(newvalue))) #Yes, this is black magic; necessary due to how the function is defined in open62541
    return statuscode
end
