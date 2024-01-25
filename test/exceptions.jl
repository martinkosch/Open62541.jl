#tests custom exceptions

using open62541
using Test

#configure server
server = UA_Server_new()
retval = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval == UA_STATUSCODE_GOOD

#configure client
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))

#specify a bad nodeid (doesn't exist in server)
bogusid = UA_NODEID_STRING_ALLOC(1, "bogusid")

#AttributeReadWriteError - UA_Server_readX function 
@test_throws open62541.AttributeReadWriteError UA_Server_readValue(server, bogusid)

#AttributeReadWriteError - UA_Server_writeX function 
var1 = UA_Variant_new()
@test_throws open62541.AttributeReadWriteError UA_Server_writeValue(server, bogusid, var1)

#AttributeReadWriteError - UA_Server_readX function 
@test_throws open62541.AttributeReadWriteError UA_Client_readValueAttribute(client, bogusid)

#AttributeReadWriteError - UA_Server_readX function 
var2 = UA_Variant_new()
@test_throws open62541.AttributeReadWriteError UA_Client_writeValueAttribute(client,
    bogusid,
    var2)

#tidy up
UA_Server_delete(server)
UA_Client_delete(client)
UA_Variant_delete(var1)
UA_Variant_delete(var2)
UA_NodeId_delete(bogusid)
