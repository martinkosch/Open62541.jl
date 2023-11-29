#tests custom exceptions

using open62541
using Test
using Base.Threads

#configure server
server = UA_Server_new()
retval1 = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
    4842,
    C_NULL,
    0,
    0)

accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
input = rand(type)
attr = UA_generate_variable_attributes(input,
        "scalar variable",
        "this is a scalar variable",
        accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext = C_NULL
outnewnodeid = C_NULL
retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD
#test whether the correct array is within the server (read from server)
output_server = unsafe_wrap(UA_Server_readValue(server, varnodeid))

#test whether correct exception type is thrown for each function
@test_throws open62541.AttributeReadWriteError UA_Server_readValue(server, bogusid)

