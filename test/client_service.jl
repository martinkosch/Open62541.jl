#purpose: check lower level client service functions; at the moment only the read 
#service is tested.

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541
    using Test
end

# Create nodes with random default values on new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    server = UA_Server_new()
    retval = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
        4842, C_NULL,  0, 0)
    @test retval == UA_STATUSCODE_GOOD

    # Start up the server
    Distributed.@spawnat Distributed.workers()[end] redirect_stderr() # Turn off all error messages
    println("Starting up the server...")
    UA_Server_run(server, Ref(true))
end

# Specify client and connect to server after server startup
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
max_duration = 40.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval = UA_Client_connect(client, "opc.tcp://localhost:4842")
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end

#now create a read request
request = UA_ReadRequest_new()
id = UA_ReadValueId_new()
id.attributeId = UA_ATTRIBUTEID_VALUE
id.nodeId = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_NAMESPACEARRAY)
request.nodesToRead = id
request.nodesToReadSize = 1

#now read
response = UA_Client_Service_read(client, request)

#test whether we have a valid response object
@test response isa Ptr{UA_ReadResponse}

#now could query the value of it
variant = unsafe_load(response).results.value
strings = unsafe_string.(unsafe_wrap(variant))
shouldbe = ["http://opcfoundation.org/UA/", "urn:open62541.server.application"]
@test all(strings .== shouldbe)

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)

#clean up
UA_ReadRequest_delete(request)
UA_ReadResponse_delete(response)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
