#adapted from: https://github.com/open62541/open62541/blob/master/examples/client_subscription_loop.c

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
        4842, C_NULL,  0, 0)

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

container = String[]

function handler_currentTimeChanged(client, subId, subContext, monId, monContext, 
        value)
    if UA_Variant_hasScalarType(value.value, UA_TYPES_PTRS[UA_TYPES_DATETIME])
        raw_date = unsafe_wrap(value.value)
        dts = UA_DateTime_toStruct(raw_date)
        push!(container, Printf.@sprintf("current date and time (UTC) is: %u-%u-%u %u:%u:%u.%03u\n",
        dts.day, dts.month, dts.year, dts.hour, dts.min, dts.sec, dts.milliSec))

    end
    return nothing
end

function deleteSubscriptionCallback(client, subscriptionId, subscriptionContext) 
    println("Subscription Id $subscriptionId was deleted")
    return nothing
end

function subscriptionInactivityCallback(client, subId, subContext)
    println("Inactivity for subscription $subId.")
    return nothing
end

function stateCallback(client, channelState, sessionState, recoveryStatus)
    if channelState == UA_SECURECHANNELSTATE_CLOSED
        println("The client is disconnected")
    elseif channelState == UA_SECURECHANNELSTATE_HEL_SENT
        println("Waiting for ack")
    elseif channelState == UA_SECURECHANNELSTATE_OPN_SENT
        println("Waiting for OPN Response")
    elseif channelState == UA_SECURECHANNELSTATE_OPEN
        println("A SecureChannel to the server is open")
    else 
        #donothing
    end

    if sessionState == UA_SESSIONSTATE_ACTIVATED
        println("A session with the server is activated")
        # A new session was created. We need to create the subscription.
        # Create a subscription
        request = UA_CreateSubscriptionRequest_default()
        delcb = @cfunction(deleteSubscriptionCallback, Cvoid, (Ptr{UA_Client}, UInt32, Ptr{Cvoid}))
        response = UA_Client_Subscriptions_create(client, unsafe_load(request), C_NULL, C_NULL, delcb)
        if response.responseHeader.serviceResult == UA_STATUSCODE_GOOD
            println("Create subscription succeeded, id $(response.subscriptionId)")
        else
            #something failed?
        end

        # Add a MonitoredItem 
        currentTimeNode = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)
        monRequest = UA_MonitoredItemCreateRequest_default(currentTimeNode)
        handlercb = @cfunction(handler_currentTimeChanged, Cvoid, (Ptr{UA_Client}, UInt32, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, UA_DataValue))
        monResponse = UA_Client_MonitoredItems_createDataChange(client, response.subscriptionId,
            UA_TIMESTAMPSTORETURN_BOTH, unsafe_load(monRequest),
            C_NULL, handlercb, C_NULL)
        if monResponse.statusCode == UA_STATUSCODE_GOOD 
            println("Monitoring UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME, id: $(monResponse.monitoredItemId)")
        end
    elseif sessionState == UA_SESSIONSTATE_CLOSED
        println("Session disconnected")
    else
        #donothing
    end
    return nothing
end


client = UA_Client_new()
cc = UA_Client_getConfig(client)
UA_ClientConfig_setDefault(cc)

# Set callbacks
cbstate = @cfunction(stateCallback, Cvoid, (Ptr{UA_Client}, UA_SecureChannelState, UA_SessionState, UA_StatusCode))
cc.stateCallback = cbstate
subcb = @cfunction(subscriptionInactivityCallback, Cvoid, (Ptr{UA_Client}, UInt32, Ptr{Cvoid}))
cc.subscriptionInactivityCallback = subcb

#connect client
ret = UA_Client_connect(client, "opc.tcp://localhost:4842")
@test ret == UA_STATUSCODE_GOOD

UA_Client_run_iterate(client, 1000) 
sleep(7) 
container = String[]
UA_Client_run_iterate(client, 1000)
#see UA_CreateSubscriptionRequest_default(); 
# requestedPublishingInterval = 500.0
# request.requestedMaxKeepAliveCount = 10
# --> would expect the maximum of 10 items in `container` after 7 seconds
@test length(container) == 10

UA_Client_disconnect(client)
UA_Client_delete(client) 
