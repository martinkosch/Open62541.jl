using open62541

#start up server from simple_server.jl
include(joinpath(@__DIR__, "examples/simple_server.jl"))

#specify client and connect to server
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
retval = UA_Client_connect(client, "opc.tcp://localhost:4842")

#nodeid containins software version running on server
nodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION)

#read
raw_version = UA_Client_readValueAttribute(client, nodeid)
open62541_version_server = unsafe_string(unsafe_wrap(raw_version))

#software version according to julia constants
open62541_version_julia = "$UA_OPEN62541_VER_MAJOR.$UA_OPEN62541_VER_MINOR.$UA_OPEN62541_VER_PATCH"

#shut down server
running[] = false

#do they agree?
test = contains(open62541_version_server, open62541_version_julia)
