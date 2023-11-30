# Purpose: This testset checks whether variable nodes containing arrays (1, 2, 3, 4 dimensions) of
#different types can be created on a server, read, changed and read again (using the server commands and client commands)
#we also check that setting a variable node with one type cannot be set to another type (e.g., integer variable node cannot be
#set to float64.)

using open62541
using Test
using Base.Threads

# What types we are testing for: 
#types = [Int16, Int32, Int64, Float32, Float64, Bool]
types = [Float64]
#array_sizes = (11, (2, 5), (3, 4, 5), (3, 4, 5, 6))
array_sizes = (11, (2, 3), (2, 3, 4), (2, 3, 4, 5))

for type in types
    for array_size in array_sizes
        @show type, array_size
        #generate a UA_Server with standard config
        server = UA_Server_new()
        retval = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
            4842,
            C_NULL,
            0,
            0)
        @test retval == UA_STATUSCODE_GOOD 
        #add variable node containing an array to the server
        accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
        input = rand(type, array_size)
        attr = UA_generate_variable_attributes(input,
            "array variable",
            "this is an array variable",
            accesslevel)
        varnodeid = UA_NODEID_STRING_ALLOC(1, "array variable")
        parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
        parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
        typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
        browsename = UA_QUALIFIEDNAME_ALLOC(1, "array variable")
        nodecontext = C_NULL
        outnewnodeid = C_NULL
        retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
            parentreferencenodeid,
            browsename, typedefinition, attr, nodecontext, outnewnodeid)
        #test whether adding node to the server worked
        @test retval == UA_STATUSCODE_GOOD
        #test whether the correct array is within the server (read from server)
        output_server = unsafe_wrap(UA_Server_readValue(server, varnodeid))
        @test all(isapprox.(input, output_server))

        #start up the server
        running = Atomic{Bool}(true)
        t = @spawn UA_Server_run(server, running)
        #specify client and connect to server
        client = UA_Client_new()
        UA_ClientConfig_setDefault(UA_Client_getConfig(client))
        while !istaskstarted(t)
            sleep(1.0)
        end
        sleep(1.0)
        retval = UA_Client_connect(client, "opc.tcp://localhost:4842")
        @test retval == UA_STATUSCODE_GOOD       
        #read with client from server
        output_client = unsafe_wrap(UA_Client_readValueAttribute(client, varnodeid))
        @test all(isapprox.(input, output_client))
        # Write new data 
        new_input = rand(type, array_size)
        new_variant = UA_Variant_new_copy(new_input)
        #new_variant = UA_Client_readValueAttribute(client, varnodeid)
        @show "just before write"
        retval = UA_Client_writeValueAttribute(client, varnodeid, new_variant)
        @test retval == UA_STATUSCODE_GOOD   
        # # Read new data
        output_client_new = unsafe_wrap(UA_Client_readValueAttribute(client, varnodeid))
        # Check whether writing was successfull
        @test all(isapprox.(new_input, output_client_new))
        # #disconnect client
        UA_Client_disconnect(client)
        #shut down the server
        running[] = false
        #wait for task to finish
        wait(t)
        UA_Server_delete(server)
        UA_Client_delete(client)
    end
end

