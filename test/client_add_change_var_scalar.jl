# Purpose: This testset checks whether variable nodes containing a scalar of
# different types can be created on a server, read, changed and read again 
# (using the server and client APIs)
# We also check that setting a variable node with one type cannot be set to 
# another type (e.g., integer variable node cannot be set to float64.)

# Types tested: Bool, Int8/16/32/64, UInt8/16/32/64, Float32/64, String, ComplexF16/F32/64
# Rational{Int16/Int32}, Rational{UInt16, UInt32}

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541, Test, Random

    include("test_helpers.jl")

    # What types we are testing for: 
    types = [Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64,
        Float32, Float64, String, ComplexF32, ComplexF64, Rational{Int32},
        Rational{UInt32}]

    # Generate random input values and generate nodeid names
    input_data = Tuple(customrand(type) for type in types)
    varnode_ids = ["$(Symbol(type)) scalar variable" for type in types]
end

# Create nodes with random default values on new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    server = JUA_Server()
    retval = JUA_ServerConfig_setMinimalCustomBuffer(JUA_ServerConfig(server),
        4842, C_NULL, 0, 0)
    @test retval == UA_STATUSCODE_GOOD

    # Add variable node containing a scalar to the server
    for (type_ind, type) in enumerate(types)
        accesslevel = UA_ACCESSLEVEL(read = true, write = true)
        input = input_data[type_ind]
        attr = JUA_VariableAttributes(value = input,
            displayname = varnode_ids[type_ind],
            description = "this is a $(Symbol(type)) scalar variable",
            accesslevel = accesslevel)
        varnodeid = JUA_NodeId(1, varnode_ids[type_ind])
        parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
        parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_ORGANIZES)
        typedefinition = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
        browsename = JUA_QualifiedName(1, varnode_ids[type_ind])
        nodecontext = JUA_NodeId()
        outnewnodeid = JUA_NodeId()
        retval = JUA_Server_addNode(server, varnodeid, parentnodeid,
            parentreferencenodeid,
            browsename, attr, nodecontext, outnewnodeid, typedefinition)
        # Test whether adding node to the server worked    
        @test retval == UA_STATUSCODE_GOOD
        # Test whether the correct array is within the server (read from server)
        output_server = JUA_Server_readValue(server, varnodeid)
        if type <: Union{AbstractFloat, Complex}
            @test all(isapprox.(input, output_server))
        else
            @test all(input .== output_server)
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

# Read with client from server
for (type_ind, type) in enumerate(types)
    input = input_data[type_ind]
    varnodeid = JUA_NodeId(1, varnode_ids[type_ind])
    output_client = JUA_Client_readValueAttribute(client, varnodeid)
    if type <: Union{AbstractFloat, Complex}
        @test all(isapprox.(input, output_client))
    else
        @test all(input .== output_client)
    end
end

# Write new data 
for (type_ind, type) in enumerate(types)
    new_input = customrand(type)
    varnodeid = JUA_NodeId(1, varnode_ids[type_ind])
    retval = JUA_Client_writeValueAttribute(client, varnodeid, new_input)
    @test retval == UA_STATUSCODE_GOOD
    output_client_new = JUA_Client_readValueAttribute(client, varnodeid)
    if type <: Union{AbstractFloat, Complex}
        @test all(isapprox.(new_input, output_client_new))
    else
        @test all(new_input .== output_client_new)
    end
end

# Test wrong data type write errors 
for type_ind in eachindex(types)
    if types[type_ind] <: Integer
        type = Float64
    elseif types[type_ind] <: AbstractFloat
        type = Int64
    elseif types[type_ind] <: AbstractString
        type = Float64
    elseif types[type_ind] <: Rational{<:Unsigned}
        type = Rational{Int32}
    elseif types[type_ind] <: Rational{<:Signed}
        type = Rational{UInt32}
    elseif types[type_ind] <: Union{ComplexF16, ComplexF32}
        type = ComplexF64
    elseif types[type_ind] <: ComplexF64
        type = ComplexF32
    elseif types[type_ind] == Bool
        type = Int64
    end

    new_input = customrand(type)
    varnodeid = JUA_NodeId(1, varnode_ids[type_ind])
    @test_throws Open62541.AttributeReadWriteError JUA_Client_writeValueAttribute(client,
        varnodeid, new_input)
end

# Disconnect client
JUA_Client_disconnect(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
