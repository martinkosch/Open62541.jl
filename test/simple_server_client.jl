using open62541
using Test
using Base.Threads

running = Atomic{Bool}(true)
server = UA_Server_new()
retval1 = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
    4842,
    C_NULL,
    0,
    0)

t = @spawn UA_Server_run(server, running)

@test isa(server, Ptr{UA_Server})
@test retval1 == UA_STATUSCODE_GOOD
@test isa(t, Task)

#specify client and connect to server
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
maxattempts = 20
attempt = 1
retval = UA_STATUSCODE_BAD
while attempt <= maxattempts && retval != UA_STATUSCODE_GOOD
    retval = UA_Client_connect(client, "opc.tcp://localhost:4842")
    attempt = attempt + 1
    sleep(0.1)
end
if retval != UA_STATUSCODE_GOOD
    error("Connection failed $maxattempts time; exiting.")
end

#nodeid containing software version running on server
nodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION)

#read
if retval == UA_STATUSCODE_GOOD
    raw_version = UA_Client_readValueAttribute(client, nodeid)
    open62541_version_server = unsafe_string(unsafe_wrap(raw_version))
    UA_Client_disconnect(client)
else
    open62541_version_server = "fail"
end

# #software version according to julia constants
open62541_version_julia = "$UA_OPEN62541_VER_MAJOR.$UA_OPEN62541_VER_MINOR.$UA_OPEN62541_VER_PATCH"

# #shut down server
running[] = false
wait(t)
UA_Client_delete(client)
UA_Server_delete(server)

# #do they agree?
@test contains(open62541_version_server, open62541_version_julia)
