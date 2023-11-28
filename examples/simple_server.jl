using open62541, Base.Threads

running = Atomic{Bool}(true)
server = UA_Server_new()
UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
    4842,
    C_NULL,
    0,
    0)

t = @spawn UA_Server_run(server, running)
