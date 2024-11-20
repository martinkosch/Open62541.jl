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
    function simple_one_in_one_out(name)
        assembledstring = "Hello "*name*"."
        return assembledstring
    end 

    function simple_two_in_one_out(name, adjective)
        assembledstring = "Hello "*name*", you are "*adjective*"."
        return assembledstring
    end 

    function simple_one_in_two_out(name)
        out1 = "Hello "*name*"."
        out2 = reverse(name)*" is "*name*" reversed."
        return (out1, out2)
    end 

    function simple_two_in_two_out(name, adjective)
        out1 = "Hello "*name*", you are "*adjective*"."
        out2 = adjective*" is the adjective."
        return (out1, out2)
    end 

    function simple_two_in_two_out_mixed_type(name, number)
        out1 = "Hello "*name*"."
        out2 = number*number
        return (out1, out2)
    end 

    #lower level without abstraction
    function two_in_one_out(server, sessionId, sessionHandle, methodId, methodContext, objectId, 
            objectContext, inputSize, input, outputSize, output)
        arr = UA_Array(input, Int64(inputSize))
        strings = Open62541.__get_juliavalues_from_variant.(arr, Any)
        assembledstring = "Hello "*strings[1]*", you are "*strings[2]
        j = JUA_Variant(assembledstring)
        UA_Variant_copy(Open62541.Jpointer(j), output)
        return UA_STATUSCODE_GOOD
    end
    
    #prepare method attributes
    attr1 = JUA_MethodAttributes(description = "Simple One in One Out",
        displayname = "Simple One in One Out",
        executable = true,
        userexecutable = true)
    attr2 = JUA_MethodAttributes(description = "Simple Two in One Out",
        displayname = "Simple Two in One Out",
        executable = true,
        userexecutable = true)
    attr3 = JUA_MethodAttributes(description = "Simple One in Two Out",
        displayname = "Simple One in Two Out",
        executable = true,
        userexecutable = true)
    attr4 = JUA_MethodAttributes(description = "Simple Two in Two Out",
        displayname = "Simple Two in Two Out",
        executable = true,
        userexecutable = true)
    attr5 = JUA_MethodAttributes(description = "Simple Two in Two Out - Mixed Types",
        displayname = "Simple Two in Two Out - Mixed Types",
        executable = true,
        userexecutable = true)

    #prepare method nodeids
    methodid1 = JUA_NodeId(1, 62541)
    methodid2 = JUA_NodeId(1, 62542)
    methodid3 = JUA_NodeId(1, 62543)
    methodid4 = JUA_NodeId(1, 62544)
    methodid5 = JUA_NodeId(1, 62545)

    parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)

    #prepare method callbacks
    function wrap_method_by_architecture(method)
        @static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
            res = UA_MethodCallback_generate(method)
        else #we are on Apple Silicon and can't use a closure in @cfunction, have to do more work.
            res = @cfunction(method, UA_StatusCode,
                (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
                    Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
                    Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
        end
        return res
    end

    m1 = wrap_method_by_architecture(UA_MethodCallback_wrap(simple_one_in_one_out))
    m2 = wrap_method_by_architecture(UA_MethodCallback_wrap(simple_two_in_one_out))
    m3 = wrap_method_by_architecture(UA_MethodCallback_wrap(simple_one_in_two_out))
    m4 = wrap_method_by_architecture(UA_MethodCallback_wrap(simple_two_in_two_out))
    m5 = wrap_method_by_architecture(UA_MethodCallback_wrap(simple_two_in_two_out_mixed_type))

    #prepare browsenames
    browsename1 = JUA_QualifiedName(1, "Simple One in One Out")
    browsename2 = JUA_QualifiedName(1, "Simple Two in One Out")
    browsename3 = JUA_QualifiedName(1, "Simple One in Two Out")
    browsename4 = JUA_QualifiedName(1, "Simple Two in Two Out")
    browsename5 = JUA_QualifiedName(1, "Simple Two in Two Out Mixed Type")

    #prepare input and output arguments
    oneinputarg = JUA_Argument("examplestring", name = "One input", 
        description = "One input")
    twoinputarg = UA_Argument_Array_new(2)
    twoinputarg_mixed = UA_Argument_Array_new(2)
    #TODO: this could be much nicer if UA_Argument_Array works nicely, see https://github.com/martinkosch/Open62541.jl/issues/37
    j1 = JUA_Argument("examplestring", name = "First input", description = "First input")
    j2 = JUA_Argument("examplestring", name = "Second input", description = "Second input")
    UA_Argument_copy(Open62541.Jpointer(j1), twoinputarg[1]) 
    UA_Argument_copy(Open62541.Jpointer(j2), twoinputarg[2])

    j3 = JUA_Argument("examplestring", name = "Name", description = "Number")
    j4 = JUA_Argument(25, name = "Number", description = "Number")
    UA_Argument_copy(Open62541.Jpointer(j3), twoinputarg_mixed[1])
    UA_Argument_copy(Open62541.Jpointer(j4), twoinputarg_mixed[2])

    oneoutputarg = JUA_Argument("examplestring", name = "One output", description = "One output")
    twooutputarg = UA_Argument_Array_new(2)
    twooutputarg_mixed = UA_Argument_Array_new(2)
    j1 = JUA_Argument("examplestring", name = "First output", description = "First output")
    j2 = JUA_Argument("examplestring", name = "Second output", description = "Second output")
    UA_Argument_copy(Open62541.Jpointer(j1), twooutputarg[1])
    UA_Argument_copy(Open62541.Jpointer(j2), twooutputarg[2])
    j3 = JUA_Argument("examplestring", name = "Name", description = "Name")
    j4 = JUA_Argument(25, name = "Number", description = "Number")
    UA_Argument_copy(Open62541.Jpointer(j3), twooutputarg_mixed[1])
    UA_Argument_copy(Open62541.Jpointer(j4), twooutputarg_mixed[2])

    #add the nodes
    retval1 = JUA_Server_addNode(server, methodid1, parentnodeid, parentreferencenodeid, 
        browsename1, attr1, m1, oneinputarg, oneoutputarg, 
        JUA_NodeId(), JUA_NodeId())
    retval2 = JUA_Server_addNode(server, methodid2, parentnodeid, parentreferencenodeid, 
        browsename2, attr2, m2, twoinputarg, oneoutputarg, 
        JUA_NodeId(), JUA_NodeId())
    retval3 = JUA_Server_addNode(server, methodid3, parentnodeid, parentreferencenodeid, 
        browsename3, attr3, m3, oneinputarg, twooutputarg, 
        JUA_NodeId(), JUA_NodeId())
    retval4 = JUA_Server_addNode(server, methodid4, parentnodeid, parentreferencenodeid, 
        browsename4, attr4, m4, twoinputarg, twooutputarg, 
        JUA_NodeId(), JUA_NodeId())   
    retval5 = JUA_Server_addNode(server, methodid5, parentnodeid, parentreferencenodeid, 
        browsename5, attr5, m5, twoinputarg_mixed, twooutputarg_mixed, 
        JUA_NodeId(), JUA_NodeId())  

    @test retval1 == UA_STATUSCODE_GOOD
    @test retval2 == UA_STATUSCODE_GOOD
    @test retval3 == UA_STATUSCODE_GOOD
    @test retval4 == UA_STATUSCODE_GOOD
    @test retval5 == UA_STATUSCODE_GOOD

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
        retval3 = JUA_Client_connect(client, "opc.tcp://localhost:4842")
        if retval3 == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end

#calling the method node with high level interface
methodid1 = JUA_NodeId(1, 62541)
methodid2 = JUA_NodeId(1, 62542)
methodid3 = JUA_NodeId(1, 62543)
methodid4 = JUA_NodeId(1, 62544)
methodid5 = JUA_NodeId(1, 62545)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)

one_input = "Peter"
two_inputs = ("Bruce", "amazing")
two_inputs_mixed = ("Claudia", 25)
response1 = JUA_Client_call(client, parentnodeid, methodid1, one_input)
response2 = JUA_Client_call(client, parentnodeid, methodid2, two_inputs)
response3 = JUA_Client_call(client, parentnodeid, methodid3, one_input)
response4 = JUA_Client_call(client, parentnodeid, methodid4, two_inputs)
response5 = JUA_Client_call(client, parentnodeid, methodid5, two_inputs_mixed)

@test response1 == "Hello Peter."
@test response2 == "Hello Bruce, you are amazing."
@test all(response3 .== ("Hello Peter.", "reteP is Peter reversed."))
@test all(response4 .== ("Hello Bruce, you are amazing.", "amazing is the adjective."))
@test all(response5 .== ("Hello Claudia.", 625))
#test whether supplying wrong number of arguments throws:
@test_throws Open62541.ClientServiceRequestError JUA_Client_call(client, parentnodeid, methodid1, two_inputs) 

# Disconnect client
JUA_Client_disconnect(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
