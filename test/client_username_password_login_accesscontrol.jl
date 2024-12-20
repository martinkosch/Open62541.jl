using Distributed
#follows Server side example here: https://github.com/open62541/open62541/blob/2c87f1ed06bf594103d6bf0b1d31267fa3e9d8cf/examples/access_control/server_access_control.c

Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541
    using Test
    using Pkg

    function allowAddNode(server, ac, sessionId, sessionContext, item)
        return true
    end

    function allowAddReference(server, ac, sessionId, sessionContext, item)
        return true
    end

    function allowDeleteNode(server, ac, sessionId, sessionContext, item)
        return false #Do not allow node deletion from client
    end

    function allowDeleteReference(server, ac, sessionId, sessionContext, item)
        return true
    end
end

Distributed.@spawnat Distributed.workers()[end] begin
    #configure server and add login details of one user.
    server = JUA_Server()
    config = JUA_ServerConfig(server)
    JUA_ServerConfig_setDefault(config)
    login = JUA_UsernamePasswordLogin("user", "password")
    retval0 = UA_AccessControl_default(config, false,
        Ref(unsafe_load(unsafe_load(config.securityPolicies)).policyUri), 1, Ref(login.login))
    @test retval0 == UA_STATUSCODE_GOOD

    #generate callbacks and add them to the config; TODO: define callback generators for these, so that the user doesn't have to deal with @cfunction etc.
    cb_allowAddNode = @cfunction(allowAddNode,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_AddNodesItem}))
    cb_allowAddReference = @cfunction(allowAddReference,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_AddReferencesItem}))
    cb_allowDeleteNode = @cfunction(allowDeleteNode,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_DeleteNodesItem}))
    cb_allowDeleteReference = @cfunction(allowDeleteReference,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_DeleteReferencesItem}))

    config.accessControl.allowAddNode = cb_allowAddNode
    config.accessControl.allowAddReference = cb_allowAddReference
    config.accessControl.allowDeleteNode = cb_allowDeleteNode
    config.accessControl.allowDeleteReference = cb_allowDeleteReference
    config.allowNonePolicyPassword = true #allow logging in with username/password on un-encrypted connections.
    UA_Server_run(server, Ref(true))
end

#Client side: https://github.com/open62541/open62541/blob/2c87f1ed06bf594103d6bf0b1d31267fa3e9d8cf/examples/access_control/client_access_control.c
# Specify client and connect to server after server startup
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 3.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = JUA_Client_connectUsername(client,
            "opc.tcp://localhost:4840",
            "user",
            "password")
        if retval1 == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end

newVariableIdRequest = JUA_NodeId()
newVariableId = JUA_NodeId()
value = UA_UInt32(50)
accesslevel = UA_ACCESSLEVEL(read = true)
description = "NewVariable description"
displayname = "NewVariable"
newVariableAttributes = JUA_VariableAttributes(value = value,
    accesslevel = accesslevel,
    description = description,
    displayname = displayname)
retval2 = JUA_Client_addNode(client, newVariableIdRequest,
    JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER),
    JUA_NodeId(0, UA_NS0ID_ORGANIZES), JUA_QualifiedName(1, "newVariable"),
    newVariableAttributes, newVariableId, JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE))
@test retval2 == UA_STATUSCODE_GOOD

extNodeId = JUA_ExpandedNodeId(0, 0)
extNodeId.nodeId = newVariableId
retval3 = UA_Client_addReference(client, JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER),
    JUA_NodeId(0, UA_NS0ID_HASCOMPONENT), UA_TRUE, UA_STRING_NULL, extNodeId,
    UA_NODECLASS_VARIABLE)
@test retval3 == UA_STATUSCODE_GOOD

retval4 = UA_Client_deleteReference(client, JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER),
    JUA_NodeId(0, UA_NS0ID_ORGANIZES), UA_TRUE, extNodeId, UA_TRUE)
@test retval4 == UA_STATUSCODE_GOOD

retval5 = UA_Client_deleteNode(client, newVariableId, UA_TRUE)
@test retval5 == UA_STATUSCODE_BADUSERACCESSDENIED #disallowed deleting nodes via client above, so should return access denied retcode

# Disconnect and clean up
UA_Client_disconnect(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
