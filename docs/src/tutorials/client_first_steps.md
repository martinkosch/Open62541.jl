# First steps with an open62541 client

In this tutorial we will connect an OPC client to the server started up in [First steps with an open62541 server](@ref)
and read some basic information from it, namely the software version number and
the current time. Note that this information should be contained in all OPC UA
servers, so you could also connect to a different server that you know is running.

```julia
using open62541
using Printf

#initiate client, configure it and connect to server
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
JUA_Client_connect(client, "opc.tcp://localhost:4840")

#define nodeids that we are interested in 
nodeid_currenttime = JUA_NodeId(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)
nodeid_version = JUA_NodeId(0, UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION)

#read data from nodeids
currenttime = JUA_Client_readValueAttribute(client, nodeid_currenttime) #Int64 which represents the number of 100 nanosecond intervals since January 1, 1601 (UTC)
version = JUA_Client_readValueAttribute(client, nodeid_version) #String containing open62541 version number

#Convert current time into human understandable format
dts = UA_DateTime_toStruct(currenttime)

#Print results to terminal
Printf.@printf("current date and time (UTC) is: %u-%u-%u %u:%u:%u.%03u\n",
    dts.day, dts.month, dts.year, dts.hour, dts.min, dts.sec, dts.milliSec)
Printf.@printf("The server is running open62541 version %s.", version)

#disconnect the client (good housekeeping practice)
JUA_Client_disconnect(client)
```
