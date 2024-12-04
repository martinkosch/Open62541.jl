using Open62541
using Test

function meminfo_julia()
    Float64(Sys.maxrss() / 2^20) #gives memory use of the whole julia process in MBs
end

#Client Call 

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541
    using Test
    using Pkg
    using Pkg.BinaryPlatforms

    #create methods that will be used later
    function simple_two_in_two_out_mixed_type(name, number)
        out1 = "Hello " * name * "."
        out2 = number * number
        return (out1, out2)
    end

    function c5(server, sessionId, sessionHandle, methodId, methodContext, objectId,
            objectContext, inputSize, input, outputSize, output)
        arr_input = UA_Array(input, Int64(inputSize))
        arr_output = UA_Array(output, Int64(outputSize))
        input_julia = Open62541.__get_juliavalues_from_variant.(arr_input, Any)
        output_julia = simple_two_in_two_out_mixed_type(input_julia...)
        if !isa(output_julia, Tuple)
            output_julia = (output_julia,)
        end
        for i in 1:outputSize
            j = JUA_Variant(output_julia[i])
            UA_Variant_copy(Open62541.Jpointer(j), arr_output[i])
        end
        return UA_STATUSCODE_GOOD
    end
end

Distributed.@spawnat Distributed.workers()[end] begin
    #prepare method callbacks
    @static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
        w5 = UA_MethodCallback_wrap(simple_two_in_two_out_mixed_type)
        m5 = UA_MethodCallback_generate(w5)
    else #we are on Apple Silicon and can't use a closure in @cfunction, have to do MUCH more work.
        m5 = @cfunction(c5, UA_StatusCode,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
    end

    #configure server
    server = JUA_Server()
    retval0 = JUA_ServerConfig_setMinimalCustomBuffer(JUA_ServerConfig(server),
        4842, C_NULL, 0, 0)

    #prepare method attributes
    attr5 = JUA_MethodAttributes(description = "Simple Two in Two Out - Mixed Types",
        displayname = "Simple Two in Two Out - Mixed Types",
        executable = true,
        userexecutable = true)

    #prepare method nodeids
    methodid5 = JUA_NodeId(1, 62545)

    parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)

    #prepare browsenames
    browsename5 = JUA_QualifiedName(1, "Simple Two in Two Out Mixed Type")

    #prepare input arguments
    j3 = JUA_Argument("examplestring", name = "Name", description = "Number")
    j4 = JUA_Argument(25, name = "Number", description = "Number")
    twoinputarg_mixed = [j3, j4]

    #prepare output arguments
    j3 = JUA_Argument("examplestring", name = "Name", description = "Name")
    j4 = JUA_Argument(25, name = "Number", description = "Number")
    twooutputarg_mixed = [j3, j4]

    #add the nodes
    retval5 = JUA_Server_addNode(server, methodid5, parentnodeid, parentreferencenodeid,
        browsename5, attr5, m5, twoinputarg_mixed, twooutputarg_mixed,
        JUA_NodeId(), JUA_NodeId())

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
methodid5 = JUA_NodeId(1, 62545)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
two_inputs_mixed = ("Claudia", 25)

#the actual memory leak tests
mem_start = meminfo_julia()
for i in 1:1_000_000
    response5 = JUA_Client_call(client, parentnodeid, methodid5, two_inputs_mixed)
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0


# Disconnect client & kill the server
JUA_Client_disconnect(client)
println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
