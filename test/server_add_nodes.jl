# Simple checks whether addition of different node types was successful or not
# Closely follows https://www.open62541.org/doc/1.3/tutorial_server_variabletype.html

using open62541
using Test

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval0 == UA_STATUSCODE_GOOD

## Variable nodes with scalar and array floats - other number types are tested 
## in add_change_var_scalar.jl and add_change_var_array.jl
#Variable node: scalar
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
input = rand(Float64)
attr = UA_generate_variable_attributes(value = input,
    displayname = "scalar variable",
    description = "this is a scalar variable",
    accesslevel = accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext = C_NULL
outnewnodeid = C_NULL
#JUA interface
# retval1 = JUA_Server_addNode(server, varnodeid, parentnodeid,
#     parentreferencenodeid,
#     browsename, typedefinition, attr, nodecontext, outnewnodeid)
#UA interface
retval1 = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
#test whether adding node to the server worked    
@test retval1 == UA_STATUSCODE_GOOD
# Test whether the correct array is within the server (read from server)
output_server = unsafe_wrap(UA_Server_readValue(server, varnodeid))
@test all(isapprox(input, output_server))

#Variable node: array
input = rand(Float64, 2, 3, 4)
varnodetext = "array variable"
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
attr = UA_generate_variable_attributes(value = input,
    displayname = varnodetext,
    description = "this is an array variable",
    accesslevel = accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, varnodetext)
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, varnodetext)
nodecontext = C_NULL
outnewnodeid = C_NULL
retval2 = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
# Test whether adding node to the server worked
@test retval2 == UA_STATUSCODE_GOOD

## VariableTypeNode - array
input = zeros(2)
pointtypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "2D point type"
description = "This is a 2D point type."
attr = UA_generate_variabletype_attributes(value = input,
    displayname = displayname,
    description = description)
retval3 = UA_Server_addVariableTypeNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), UA_NodeId_new(),
    attr, C_NULL, pointtypeid)

# Test whether adding the variable type node to the server worked
@test retval3 == UA_STATUSCODE_GOOD

#now add a variable node based on the variabletype node that we just defined.
input = rand(2)
pointvariableid1 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "a 2D point variable"
description = "This is a 2D point variable."
attr = UA_generate_variabletype_attributes(value = input,
    displayname = displayname,
    description = description)
retval4 = UA_Server_addVariableNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), pointtypeid,
    attr, C_NULL, pointvariableid1)
# Test whether adding the variable type node to the server worked
@test retval4 == UA_STATUSCODE_GOOD

#now attempt to add a node with the wrong dimensions 
input = rand(2, 3)
pointvariableid2 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "not a 2d point variable"
description = "This should fail"
attr = UA_generate_variabletype_attributes(value = input,
    displayname = displayname,
    description = description)
retval5 = UA_Server_addVariableNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), pointtypeid,
    attr, C_NULL, pointvariableid2)
# Test whether adding the variable type node to the server worked
@test retval5 == UA_STATUSCODE_BADTYPEMISMATCH

#and now we just want to change value rank (which again shouldn't be allowed)
@test_throws open62541.AttributeReadWriteError UA_Server_writeValueRank(server,
    pointvariableid1,
    UA_VALUERANK_ONE_OR_MORE_DIMENSIONS)

#variable type node - scalar
input = 42
scalartypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "scalar integer type"
description = "This is a scalar integer type."
attr = UA_generate_variabletype_attributes(value = input,
    displayname = displayname,
    description = description)
retval6 = UA_Server_addVariableTypeNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "scalar integer type"), UA_NodeId_new(),
    attr, C_NULL, scalartypeid)

# Test whether adding the variable type node to the server worked
@test retval6 == UA_STATUSCODE_GOOD

#add object node
#follows this tutorial page: https://www.open62541.org/doc/1.3/tutorial_server_object.html
pumpId = UA_NodeId_new()
# UA_NodeId pumpId; /* get the nodeid assigned by the server */
#     UA_ObjectAttributes oAttr = UA_ObjectAttributes_default()
#     oAttr.displayName = UA_LOCALIZEDTEXT("en-US", "Pump (Manual)");
#     UA_Server_addObjectNode(server, UA_NODEID_NULL,
#     UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
#     UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
#     UA_QUALIFIEDNAME(1, "Pump (Manual)"), UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
#     oAttr, NULL, pumpId)
