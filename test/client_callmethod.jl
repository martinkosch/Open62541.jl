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

    function helloWorld(server, sessionId, sessionHandle, methodId,
            methodContext, objectId, objectContext, inputSize, input, outputSize, output)
        inputstr = unsafe_string(unsafe_wrap(input))
        tmp = UA_STRING("Hello " * inputstr)
        UA_Variant_setScalarCopy(output, tmp, UA_TYPES_PTRS[UA_TYPES_STRING])
        UA_String_delete(tmp)
        return UA_STATUSCODE_GOOD
    end

    inputArgument = JUA_Argument("examplestring", name = "MyInput", description = "A String")
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




inputarg = "Peter"
req = JUA_CallMethodRequest(parentnodeid, methodid, inputarg)
answer = JUA_CallMethodResult()
UA_Server_call(server, req, answer)
@test unsafe_load(answer.statusCode) == UA_STATUSCODE_GOOD
#TODO: Still really ugly to get the actual string back; need another layer of simplification 
#here.
@test unsafe_string(unsafe_wrap(unsafe_load(answer.outputArguments))) == "Hello Peter" 
