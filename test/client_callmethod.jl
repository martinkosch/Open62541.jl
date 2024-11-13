# Check whether calling method nodes via the client works. 

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541
    using Test
    using Pkg
    using Pkg.BinaryPlatforms
end

Distributed.@spawnat Distributed.workers()[end] begin
    #configure server
    server = JUA_Server()
    retval0 = JUA_ServerConfig_setMinimalCustomBuffer(JUA_ServerConfig(server),
        4842, C_NULL, 0, 0)
    @test retval0 == UA_STATUSCODE_GOOD

    #add method node
    #follows this: https://www.open62541.org/doc/1.3/tutorial_server_method.html
    #TODO: it would be great to have another level of abstraction here, so that one only has 
    #write a Julia function like this:
    # function helloWorld(name, adjective)
    #     assembledstring = "Hello "*name*", you are "*adjective
    #     return assembledstring
    # end
    #and then doing the Open62541 specific handling automatically, instead as shown below.

    function helloWorld(server, sessionId, sessionHandle, methodId,
            methodContext, objectId, objectContext, inputSize, input, outputSize, output)
        arr = UA_Array(input, Int64(inputSize))
        strings = Open62541.__get_juliavalues_from_variant.(arr, Any)
        assembledstring = "Hello "*strings[1]*", you are "*strings[2]
        j = JUA_Variant(assembledstring)
        UA_Variant_copy(Open62541.Jpointer(j), output)
        return UA_STATUSCODE_GOOD
    end
    
    inputArgument = UA_Argument_Array_new(2)
    j1 = JUA_Argument("examplestring", name = "MyInput", description = "A String")
    j2 = JUA_Argument("examplestring", name = "MyInput", description = "A second String")
    UA_Argument_copy(Open62541.Jpointer(j1), inputArgument[1])
    UA_Argument_copy(Open62541.Jpointer(j2), inputArgument[2])
    outputArgument = JUA_Argument("examplestring", name = "MyOutput", description = "A String")
    helloAttr = JUA_MethodAttributes(description = "Say Hello World",
        displayname = "Hello World",
        executable = true,
        userexecutable = true)

    methodid = JUA_NodeId(1, 62541)
    parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)
    @static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
        helloWorldMethodCallback = UA_MethodCallback_generate(helloWorld)
    else #we are on Apple Silicon and can't use a closure in @cfunction, have to do more work.
        helloWorldMethodCallback = @cfunction(helloWorld, UA_StatusCode,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
    end
    browsename = JUA_QualifiedName(1, "hello world")
    retval = JUA_Server_addNode(server, methodid, parentnodeid, parentreferencenodeid, 
        browsename, helloAttr, helloWorldMethodCallback, inputArgument, outputArgument, 
        JUA_NodeId(), JUA_NodeId())

    @test retval == UA_STATUSCODE_GOOD

    # Start up the server
    Distributed.@spawnat Distributed.workers()[end] redirect_stderr() # Turn off all error messages
    println("Starting up the server...")
    JUA_Server_runUntilInterrupt(server)

end

client = JUA_Client()
JUA_ClientConfig_setDefault(JUA_ClientConfig(client))
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 3.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval = JUA_Client_connect(client, "opc.tcp://localhost:4842")
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end



#calling the method node with high level interface
methodid = JUA_NodeId(1, 62541)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
inputs = ("Peter", "amazing")
response = JUA_Client_call(client, parentnodeid, methodid, inputs)

@test response == "Hello Peter, you are amazing"

# Disconnect client
JUA_Client_disconnect(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
