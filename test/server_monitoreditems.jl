#stolen from: https://github.com/open62541/open62541/blob/master/examples/tutorial_server_monitoreditems.c

using Open62541
using Test

function dataChangeNotificationCallback(server, monitoredItemId,
        monitoredItemContext, nodeId, nodeContext, attributeId, value)
    println("Received notification")
    return nothing
end

#configure server
server = JUA_Server()
JUA_ServerConfig_setMinimalCustomBuffer(JUA_ServerConfig(server),
    4842, C_NULL, 0, 0)

currentTimeNodeId = JUA_NodeId(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)
monRequest = UA_MonitoredItemCreateRequest_default(currentTimeNodeId)
monRequest.requestedParameters.samplingInterval = 500.0 #time in ms
cb = @cfunction(dataChangeNotificationCallback, Cvoid,
    (Ptr{UA_Server}, UInt32, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
        UInt32, Ptr{UA_DataValue}))
result = UA_Server_createDataChangeMonitoredItem(server, UA_TIMESTAMPSTORETURN_SOURCE,
    unsafe_load(monRequest), C_NULL, cb)

@test result.statusCode == UA_STATUSCODE_GOOD

#JUA_Server_runUntilInterrupt(server) #this would just print a lot of "Received notification"
