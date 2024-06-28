# Purpose: This testset checks whether the UA_Client_writeXXXAttribute(...) functions 
# are usable. This is currently only implemented for nodes of "variable" and 
# "variabletype" type. For the attributes contained in such nodes we check whether 
# the respective read function returns the right type of variable. For functions 
# not defined for a such nodes, we check that they throw the appropriate exception. 

#TODO: implement other node types, so that we can check the remaining functions.

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541
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
    writemask = UA_WRITEMASK(; accesslevel = true, arraydimensions = true,
          datatype = true,
          description = true, displayname = true, isabstract = true, minimumsamplinginterval = true,
          userwritemask = true, valuerank = true, historizing = true,
          writemask = true)
    userwritemask = writemask
    input = rand(Float64)
    attr1 = UA_VariableAttributes_generate(value = input, displayname = "scalar variable",
        description = "this is a scalar variable",
        accesslevel = accesslevel,
        writemask = writemask,
        userwritemask = userwritemask)
    parentnodeid1 = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid1 = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
    typedefinition1 = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    browsename1 = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
    nodecontext1 = C_NULL
    outnewnodeid1 = C_NULL
    retval = UA_Server_addVariableNode(server, variablenodeid, parentnodeid1,
        parentreferencenodeid1, browsename1, typedefinition1, attr1, nodecontext1, 
        outnewnodeid1)
    #test whether adding node to the server worked    
    @test retval == UA_STATUSCODE_GOOD

    #add a variabletype node
    input = zeros(2)    
    accesslevel = UA_ACCESSLEVEL(read = true)
    displayname = "2D point type"
    description = "This is a 2D point type."
    writemask = UA_WRITEMASK(; arraydimensions = true,
          datatype = true,
          description = true, displayname = true, isabstract = true, minimumsamplinginterval = false, nodeclass = false,
          userwritemask = true, valuerank = true,
          writemask = true, valueforvariabletype = true)
    userwritemask = writemask
    attr2 = UA_VariableTypeAttributes_generate(value = input,
        displayname = displayname,
        description = description,
        writemask = writemask,
        userwritemask = userwritemask)
    parentnodeid2 = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    parentreferencenodeid2 = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
    typedefinition2 = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    browsename2 = UA_QUALIFIEDNAME_ALLOC(1, "2DPoint Type")
    nodecontext2 = C_NULL
    outnewnodeid2 = C_NULL
    retval = UA_Server_addVariableTypeNode(server, variabletypenodeid, parentnodeid2,
        parentreferencenodeid2, browsename2, typedefinition2, attr2, nodecontext2, 
        outnewnodeid2)
        
    #test whether adding node to the server worked    
    @test retval == UA_STATUSCODE_GOOD

    #clean up variables (save to do, because content of the vars gets 
    #copied into the server)
    UA_VariableAttributes_delete(attr1)
    UA_NodeId_delete(parentnodeid1)
    UA_NodeId_delete(parentreferencenodeid1)
    UA_NodeId_delete(typedefinition1)
    UA_QualifiedName_delete(browsename1)
    UA_VariableTypeAttributes_delete(attr2)
    UA_NodeId_delete(parentnodeid2)
    UA_NodeId_delete(parentreferencenodeid2)
    UA_NodeId_delete(typedefinition2)
    UA_QualifiedName_delete(browsename2)
    UA_NodeId_delete(variablenodeid)
    UA_NodeId_delete(variabletypenodeid)

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
        #can't write certain attributes after node creation, see here: 
        #https://github.com/open62541/open62541/issues/3545
        nonvalidattr = (:NodeId, :NodeClass, :BrowseName, :UserWriteMask, :UserAccessLevel)
    elseif nodeclass == UA_NODECLASS_VARIABLETYPE
        attributeset = UA_VariableTypeAttributes
        nonvalidattr = (:NodeId, :NodeClass, :BrowseName, :UserWriteMask) #as above
    end 
    for att in Open62541.attributes_UA_Client_write
        fun_write = Symbol(att[1])
        fun_read = Symbol(replace(att[1], "write" => "read"))
        attr_name = Symbol(att[2])
        generator = Symbol(att[3]*"_new")
        cleaner = Symbol(att[3]*"_delete")
        if (in(Symbol(lowercasefirst(att[2])), fieldnames(attributeset)) ||
            in(Symbol(lowercasefirst(att[2])), fieldnames(UA_NodeHead))) && att[3] != "UA_DataType" && 
            att[1] != "UA_Client_writeValueAttributeEx"
            @show nodeclass, att
            out2 = eval(generator)()
            statuscode1 = eval(fun_read)(client, node, out2) #read
            @test statuscode1 == UA_STATUSCODE_GOOD
            if attr_name ∉ nonvalidattr
                statuscode2 = eval(fun_write)(client, node, out2) #write read value back...
                @test statuscode2 == UA_STATUSCODE_GOOD
            end
            eval(cleaner)(out2)
        end
    end
    UA_NodeClass_delete(out1)
end

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)
UA_NodeId_delete(variablenodeid)
UA_NodeId_delete(variabletypenodeid)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
