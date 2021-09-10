using open62541

running = Ref{Bool}(true)
server = UA_Server_new()
UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server), 4840, C_NULL, 0, 0)
retval = UA_Server_run(server, running)