# Purpose: This testset checks whether connection functions used to connect a client in 
# various ways to a server are functioning. Focus is on the high level interface.

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Pkg.BinaryPlatforms
    using Open62541
    using Test
end

# Create nodes with random default values on new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    server = JUA_Server()
    config = JUA_ServerConfig(server)
    JUA_ServerConfig_setDefault(config)
    login = JUA_UsernamePasswordLogin("PeterParker", "IamSpiderman")
    retval1 = UA_AccessControl_default(config, true,
        Ref(unsafe_load(unsafe_load(config.securityPolicies)).policyUri), 1, Ref(login.login))
    config.allowNonePolicyPassword = true #allow logging in with username/password on un-encrypted connections.
    @test retval1 == UA_STATUSCODE_GOOD
    @test isa(server, JUA_Server)

    # Start up the server
    Distributed.@spawnat Distributed.workers()[end] redirect_stderr() # Turn off all error messages
    println("Starting up the server...")
    JUA_Server_runUntilInterrupt(server)
end

# Set password and username outside of connect command
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
JUA_ClientConfig_setAuthenticationUsername(config, "PeterParker", "IamSpiderman")
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval = JUA_Client_connect(client, "opc.tcp://localhost:4840")
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
retval = JUA_Client_disconnect(client)
@test retval == UA_STATUSCODE_GOOD

# Set password and username with connect command
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = JUA_Client_connectUsername(client, "opc.tcp://localhost:4840", 
            "PeterParker", "IamSpiderman")        
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
retval = JUA_Client_disconnect(client)
@test retval == UA_STATUSCODE_GOOD

# Set password and username with connect command
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = JUA_Client_connectSecureChannel(client, "opc.tcp://localhost:4840")        
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
retval = JUA_Client_disconnect(client)
@test retval == UA_STATUSCODE_GOOD

#Async connect test 
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)

m = UInt32(typemax(UInt32))
global status = (m, m, m)

function stateCallback(client, channelstate, sessionstate, connectstatus)
    r = (channelstate, sessionstate, connectstatus)
    global status = r
    return nothing
end

@static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
    cb = UA_ClientConfig_stateCallback_generate(stateCallback)
else #we are on Apple Silicon and can't use a closure in @cfunction, so do it manually
    cb = @cfunction(stateCallback, nothing,
        (Ptr{UA_Client}, UInt32, UInt32, UInt32))
end
config.stateCallback = cb

max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = JUA_Client_connectAsync(client, "opc.tcp://localhost:4840")   
        i = 0
        while i < 10 && !all(status .== (UA_SECURECHANNELSTATE_OPEN, 
                UA_SESSIONSTATE_ACTIVATED, UA_CONNECTIONSTATE_CLOSED))
            UA_Client_run_iterate(client, 10)
        end     
        if retval1 == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
retval = JUA_Client_disconnect(client)
@test retval == UA_STATUSCODE_GOOD

#connectusernameasync
status = (m, m, m)
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = JUA_Client_connectUsernameAsync(client, "opc.tcp://localhost:4840", "PeterParker", "IamSpiderman")   
        i = 0
        while i < 10 && !all(status .== (UA_SECURECHANNELSTATE_OPEN, 
                UA_SESSIONSTATE_ACTIVATED, UA_CONNECTIONSTATE_CLOSED))
            UA_Client_run_iterate(client, 10)
            @show status
        end     
        if retval1 == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
retval = JUA_Client_disconnect(client)
@test retval == UA_STATUSCODE_GOOD

#connectsecurechannelasync
status = (m, m, m)
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = JUA_Client_connectSecureChannelAsync(client, "opc.tcp://localhost:4840")   
        i = 0
        while i < 10 && !all(status .== (UA_SECURECHANNELSTATE_OPEN, 
                UA_SESSIONSTATE_CLOSED, UA_CONNECTIONSTATE_CLOSED))
            UA_Client_run_iterate(client, 10)
            @show status
        end     
        if retval1 == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end
retval = JUA_Client_disconnect(client)
@test retval == UA_STATUSCODE_GOOD

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
