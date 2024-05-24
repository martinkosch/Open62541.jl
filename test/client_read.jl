# Purpose: This testset checks whether the UA_Client_readXXXAttribute(...) functions 
# are usable. This is currently only implemented for nodes of "variable" and 
# "variabletype" type. For the attributes contained in such nodes we check whether 
# the respective read function returns the right type of variable. For functions 
# not defined for a such nodes, we check that they throw the appropriate exception. 

#TODO: implement other node types, so that we can check the remaining functions.

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541
    using Test
end

# Create nodes with random default values on new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    variablenodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
    variabletypenodeid = UA_NODEID_STRING_ALLOC(1, "variabletype 2Dpoint")

    server = UA_Server_new()
    retval = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
        4842, C_NULL,  0, 0)
    @test retval == UA_STATUSCODE_GOOD

    # Add variable node containing a scalar to the server
    #add a variable node
    accesslevel = UA_ACCESSLEVEL(read = true, write = true)
    input = rand(Float64)
    attr = UA_VariableAttributes_generate(value = input, displayname = "scalar variable",
        description = "this is a scalar variable",
        accesslevel = accesslevel)
    parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
    typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
    nodecontext = C_NULL
    outnewnodeid = C_NULL
    retval = UA_Server_addVariableNode(server, variablenodeid, parentnodeid,
        parentreferencenodeid, browsename, typedefinition, attr, nodecontext, 
        outnewnodeid)
    #test whether adding node to the server worked    
    @test retval == UA_STATUSCODE_GOOD

    #add a variabletype node
    input = zeros(2)    
    accesslevel = UA_ACCESSLEVEL(read = true)
    displayname = "2D point type"
    description = "This is a 2D point type."
    attr = UA_VariableTypeAttributes_generate(value = input,
        displayname = displayname,
        description = description)
    parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
    typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    browsename = UA_QUALIFIEDNAME_ALLOC(1, "2DPoint Type")
    nodecontext = C_NULL
    outnewnodeid = C_NULL
    retval = UA_Server_addVariableTypeNode(server, variabletypenodeid, parentnodeid,
        parentreferencenodeid, browsename, typedefinition, attr, nodecontext, 
        outnewnodeid)
        
    #test whether adding node to the server worked    
    @test retval == UA_STATUSCODE_GOOD

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


#gather the previously defined nodes
variablenodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
variabletypenodeid = UA_NODEID_STRING_ALLOC(1, "variabletype 2Dpoint")
nodes = (variablenodeid, variabletypenodeid)

#now run through the tests
for node in nodes
    out1 = UA_NodeClass_new()
    UA_Client_readNodeClassAttribute(client, node, out1)
    nodeclass = unsafe_load(out1)
    if nodeclass == UA_NODECLASS_VARIABLE
        attributeset = UA_VariableAttributes
    elseif nodeclass == UA_NODECLASS_VARIABLETYPE
        attributeset = UA_VariableTypeAttributes
    end 
    for att in open62541.attributes_UA_Client_read
        fun_name = Symbol(att[1])
        attr_type = Symbol(att[3])
        generator = Symbol(att[3]*"_new")
        cleaner = Symbol(att[3]*"_delete")
        out2 = eval(generator)()
        if in(Symbol(lowercasefirst(att[2])), fieldnames(attributeset)) ||
           in(Symbol(lowercasefirst(att[2])), fieldnames(UA_NodeHead))
            @test isa(eval(fun_name)(client, node, out2), Ptr{eval(attr_type)})
        else
            @test_throws open62541.AttributeReadWriteError eval(fun_name)(client, node)
        end
        eval(cleaner)(out2)
    end
    UA_NodeClass_delete(out1)
end

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)


