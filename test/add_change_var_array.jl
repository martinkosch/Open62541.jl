# Purpose: This testset checks whether variable nodes containing an array of
# different types can be created on a server, read, changed and read again 
# (using the server and client APIs)
# We also check that setting a variable node with one type cannot be set to 
# another type (e.g., integer variable node cannot be set to float64.)

#Types tested: Bool, Int8/16/32/64, UInt8/16/32/64, Float32/64, String, ComplexF32/64


#TODO: Improve memory management, also test with high level interface.

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541, Test, Random

    # What types and sizes we are testing for: 
    types = [Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float32, Float64, String, ComplexF32, ComplexF64]
    array_sizes = (11, (2, 5), (3, 4, 5), (3, 4, 5, 6))

    # Generate random input values and generate nodeid names
    input_data = Tuple(Tuple( type != String ? rand(type, array_size) : reshape([randstring(Int64(rand(UInt8))) for i in 1:prod(array_size)], array_size...) for array_size in array_sizes) for type in types)
    varnode_ids = ["$(string(array_size)) $(Symbol(type)) array variable"
                   for type in types, array_size in array_sizes]
end

# Create nodes with random default values on new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    server = JUA_Server()
    retval = JUA_ServerConfig_setMinimalCustomBuffer(JUA_ServerConfig(server),
        4842, C_NULL, 0, 0)
    @test retval == UA_STATUSCODE_GOOD

    # Add variable node containing an array to the server
    for (type_ind, type) in enumerate(types)
        for (array_size_ind, array_size) in enumerate(array_sizes)
            # Generate a UA_Server with standard config
            input = input_data[type_ind][array_size_ind]
            accesslevel = UA_ACCESSLEVEL(read = true, write = true)
            attr = UA_VariableAttributes_generate(value = input,
                displayname = varnode_ids[type_ind, array_size_ind],
                description = "this is a $(string(array_size)) $(Symbol(type)) array variable",
                accesslevel = accesslevel)
            varnodeid = JUA_NodeId(1, varnode_ids[type_ind, array_size_ind])
            parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
            parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_ORGANIZES)
            typedefinition = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
            browsename = JUA_QualifiedName(1, varnode_ids[type_ind, array_size_ind])
            nodecontext = C_NULL
            outnewnodeid = C_NULL
            retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
                parentreferencenodeid,
                browsename, typedefinition, attr, nodecontext, outnewnodeid)
            # Test whether adding node to the server worked
            @test retval == UA_STATUSCODE_GOOD
            # Test whether the correct array is within the server (read from server)
            output_server = JUA_Server_readValue(server, varnodeid)
            if type <: AbstractFloat
                @test all(isapprox.(input, output_server))
            else
                @test all(input .== output_server)
            end
        end
    end

    # Start up the server
    Distributed.@spawnat Distributed.workers()[end] redirect_stderr() # Turn off all error messages
    println("Starting up the server...")
    JUA_Server_runUntilInterrupt(server)
end

# Specify client and connect to server after server startup
client = JUA_Client()
JUA_ClientConfig_setDefault(JUA_ClientConfig(client))
max_duration = 40.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
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

# Read with client from server
for (type_ind, type) in enumerate(types)
    for (array_size_ind, array_size) in enumerate(array_sizes)
        input = input_data[type_ind][array_size_ind]
        varnodeid = JUA_NodeId(1, varnode_ids[type_ind, array_size_ind])
        output_client = JUA_Client_readValueAttribute(client, varnodeid)
        if type <: Union{AbstractFloat, Complex}
            @test all(isapprox.(input, output_client))
        else
            @test all(input .== output_client)
        end
    end
end

# Write new data 
for (type_ind, type) in enumerate(types)
    for (array_size_ind, array_size) in enumerate(array_sizes)
        new_input = type != String ? rand(type, array_size) : reshape([randstring(Int64(rand(UInt8))) for i in 1:prod(array_size)], array_size...)
        varnodeid = JUA_NodeId(1, varnode_ids[type_ind, array_size_ind])
        new_v = UA_Variant_new(new_input) #TODO: need to come up with a good interface for the write functions as well.
        retval = UA_Client_writeValueAttribute(client, varnodeid, new_v)
        @test retval == UA_STATUSCODE_GOOD
        output_client_new = JUA_Client_readValueAttribute(client, varnodeid)
        if type <: AbstractFloat
            @test all(isapprox.(new_input, output_client_new))
        else
            @test all(new_input .== output_client_new)
        end
        UA_Variant_delete(new_v)
    end
end

# Test wrong data type write errors 
for type_ind in eachindex(types)
    for (array_size_ind, array_size) in enumerate(array_sizes)
        if types[type_ind] == ComplexF64 || types[type_ind]  == ComplexF32
            type = Float64
        elseif types[type_ind] == String #XXX: This is likely a bug in open62541 (can write complex numbers to string type variable, probably, because extension objects are not recognized properly)
            type = Float64
        else
            type = types[mod(type_ind, length(types)) + 1] # Select wrong data type
        end
        new_input = type != String ? rand(type, array_size) : reshape([randstring(Int64(rand(UInt8))) for i in 1:prod(array_size)], array_size...)
        varnodeid = JUA_NodeId(1, varnode_ids[type_ind, array_size_ind])
        new_v = UA_Variant_new(new_input)
        @test_throws open62541.AttributeReadWriteError UA_Client_writeValueAttribute(
            client, varnodeid, new_v)
        UA_Variant_delete(new_v)
    end
end

# Disconnect client
JUA_Client_disconnect(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
