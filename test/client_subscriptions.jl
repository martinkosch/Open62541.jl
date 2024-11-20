#adapted from: https://github.com/open62541/open62541/blob/master/examples/client_subscription_loop.c
#the example (as of 2024-11-20) wants to create a subscription from within the 
#callback, which is not allowed, see here:
#https://github.com/open62541/open62541/issues/5816
#Unmerged PR addressing this: https://github.com/open62541/open62541/pull/5905

using Distributed
using Printf
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541
    using Test
end

Distributed.@spawnat Distributed.workers()[end] begin
    #configure the server
    server = UA_Server_new()
    retval = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
        4843, C_NULL,  0, 0)

    # Start up the server
    Distributed.@spawnat Distributed.workers()[end] redirect_stderr() # Turn off all error messages
    println("Starting up the server...")
    UA_Server_run(server, Ref(true))
end

# Specify client and connect to server after server startup
client = UA_Client_new()
config = UA_Client_getConfig(client)
UA_ClientConfig_setDefault(config)

#define callbacks
function handler_currentTimeChanged(client, subId, subContext, monId, monContext, 
        value)
    @show "cb triggered.", UA_print(value.value)
    if UA_Variant_hasScalarType(value.value, UA_TYPES_PTRS[UA_TYPES_DATETIME])
        @show "inner"
        raw_date = unsafe_wrap(value.value)
        dts = UA_DateTime_toStruct(raw_date)
        push!(container, Printf.@sprintf("current date and time (UTC) is: %u-%u-%u %u:%u:%u.%03u\n",
        dts.day, dts.month, dts.year, dts.hour, dts.min, dts.sec, dts.milliSec))
    end
    return nothing
end
handlercb = @cfunction(handler_currentTimeChanged, Cvoid, (Ptr{UA_Client}, UInt32, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, UA_DataValue))

#connect the client
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 3.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval = UA_Client_connect(client, "opc.tcp://localhost:4843")
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
sleep(2)

#create a subscription
request = UA_CreateSubscriptionRequest_default()
response = UA_Client_Subscriptions_create(client, unsafe_load(request), C_NULL, C_NULL, C_NULL)

#create a monitored item
currentTimeNode = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)
monRequest = UA_MonitoredItemCreateRequest_default(currentTimeNode)
monResponse = UA_Client_MonitoredItems_createDataChange(client, response.subscriptionId,
    UA_TIMESTAMPSTORETURN_BOTH, unsafe_load(monRequest),
    C_NULL, handlercb, C_NULL)
            
#now interrogate the thing
container = String[] #need to initialize variable here, otherwise error (use in handler_currentTimeChanged(...))
UA_Client_run_iterate(client, 1000)
container = String[] 
sleep(7) 
UA_Client_run_iterate(client, 1000)
#see UA_CreateSubscriptionRequest_default(); 
# requestedPublishingInterval = 500.0
# request.requestedMaxKeepAliveCount = 10
# --> would expect the maximum of 10 items in `container` after 7 seconds
@test length(container) == 10

UA_Client_disconnect(client)
UA_Client_delete(client) 

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
