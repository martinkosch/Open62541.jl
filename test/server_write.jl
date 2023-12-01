# Purpose: This testset checks whether the UA_Server_writeXXXAttribute(...) functions 
#are usable. This is currently only implemented for nodes of "variable" type. For the attributes
#contained in such nodes we check whether the respective write function is able to write a correct
#variable type to the node (TODO: also check that the correct value is actually readable from the 
#node after writing). For functions not defined for a variable node, we check that they throw the 
#appropriate exception. 

#TODO: implement other node types, so that we can check the remaining functions.

using open62541
using Test
using Base.Threads

#configure server
server = UA_Server_new()
retval1 = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
    4842,
    C_NULL,
    0,
    0)

accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
input = rand(Float64)
attr = UA_generate_variable_attributes(input,
    "scalar variable",
    "this is a scalar variable",
    accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext = C_NULL
outnewnodeid = C_NULL
retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

#TODO: not working as intended yet
for att in open62541.attributes_UA_Server_write
    fun_name = Symbol(att[1])
    @show fun_name
    attr_name = Symbol(att[2])
    new_val_name = Symbol(att[3],"_new")
    new_value_ptr = eval(new_val_name)()
    if attr_name != :BrowseName
        if isdefined(UA_VARIABLENODE_ATTRIBUTES, attr_name)
            statuscode = eval(fun_name)(server, varnodeid, new_value_ptr)
            @test statuscode == UA_STATUSCODE_GOOD
        else
            #@test_throws open62541.AttributeReadWriteError eval(fun_name)(server, varnodeid)
        end
    end
end
