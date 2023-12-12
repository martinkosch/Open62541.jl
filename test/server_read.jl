# Purpose: This testset checks whether the UA_Server_readXXXAttribute(...) functions 
#are usable. This is currently only implemented for nodes of "variable" type. For the attributes
#contained in such nodes we check whether the respective read function returns the right type of 
#variable. For functions not defined for a variable node, we check that they throw the appropriate exception. 

#TODO: implement other node types, so that we can check the remaining functions.

using open62541
using Test

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval0 == UA_STATUSCODE_GOOD

#add a variable node
accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
input = rand(Float64)
attr = UA_generate_variable_attributes(input,
    "scalar variable",
    "this is a scalar variable",
    accesslevel)
variablenodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext = C_NULL
outnewnodeid = C_NULL
retval = UA_Server_addVariableNode(server, variablenodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

#add a variabletype node
input = zeros(2)
variabletypenodeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVELMASK_READ
displayname = "2D point type"
description = "This is a 2D point type."
attr = UA_generate_variable_attributes(input,
    displayname,
    description,
    accesslevel)
retval = UA_Server_addVariableTypeNode(server, UA_NODEID_NULL,
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), UA_NODEID_NULL,
    attr, C_NULL, variabletypenodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

#gather the previously defined nodes
nodes = (variablenodeid, variabletypenodeid)

for node in nodes
    nodeclass = UA_Server_readNodeClass(server, node)
    if nodeclass == UA_NODECLASS_VARIABLE
        attributeset = UA_VariableAttributes
    elseif nodeclass == UA_NODECLASS_VARIABLETYPE
        attributeset = UA_VariableTypeAttributes
    end #TODO: add more node types once implemented
    for att in open62541.attributes_UA_Server_read
        fun_name = Symbol(att[1])
        attr_name = Symbol(att[2])
        attr_type = Symbol(att[3])
        if in(Symbol(lowercasefirst(att[2])), fieldnames(attributeset)) ||
           in(Symbol(lowercasefirst(att[2])), fieldnames(UA_NodeHead))
            @test isa(eval(fun_name)(server, node), eval(attr_type))
            @test isa(eval(fun_name)(server, unsafe_load(node)), eval(attr_type))
        else
            @test_throws open62541.AttributeReadWriteError eval(fun_name)(server, node)
            @test_throws open62541.AttributeReadWriteError eval(fun_name)(server,
                unsafe_load(node))
        end
    end
end
