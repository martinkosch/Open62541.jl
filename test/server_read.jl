# Purpose: This testset checks whether the UA_Server_readXXXAttribute(...) 
# functions are usable. This is currently only implemented for nodes of 
# "variable" and "variabletype" type. For the attributes contained in such nodes 
# we check whether the respective read function returns the right type of variable. 
# For functions not defined for a variable node, we check that they throw the 
# appropriate exception. 

using open62541
using Test

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval0 == UA_STATUSCODE_GOOD

#add a variable node
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
input = rand(Float64)
attr = UA_VariableAttributes_generate(value = input, displayname = "scalar variable",
    description = "this is a scalar variable",
    accesslevel = accesslevel)
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
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "2D point type"
description = "This is a 2D point type."
attr2 = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
reqnewnodeid =  UA_NodeId_new()
parent2 = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
ref2 = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
browse2 = UA_QUALIFIEDNAME_ALLOC(1, "2DPoint Type")
t2 = UA_NodeId_new()
retval = UA_Server_addVariableTypeNode(server, reqnewnodeid, parent2, ref2,
    browse2, t2, attr2, C_NULL, variabletypenodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

#gather the previously defined nodes
#TODO: add more node types
nodes = (variablenodeid, variabletypenodeid)

for node in nodes
    out1 = UA_NodeClass_new()
    UA_Server_readNodeClass(server, node, out1)
    nodeclass = unsafe_load(out1)
    if nodeclass == UA_NODECLASS_VARIABLE
        attributeset = UA_VariableAttributes
    elseif nodeclass == UA_NODECLASS_VARIABLETYPE
        attributeset = UA_VariableTypeAttributes
    end 
    for att in open62541.attributes_UA_Server_read
        fun_name = Symbol(att[1])
        attr_type = Symbol(att[3])
        generator = Symbol(att[3]*"_new")
        cleaner = Symbol(att[3]*"_delete")
        out2 = eval(generator)()
        if in(Symbol(lowercasefirst(att[2])), fieldnames(attributeset)) ||
           in(Symbol(lowercasefirst(att[2])), fieldnames(UA_NodeHead))
            @test isa(eval(fun_name)(server, node, out2), UA_StatusCode)
        else
            @test_throws open62541.AttributeReadWriteError eval(fun_name)(server, node, out2)
        end
        eval(cleaner)(out2)
    end
    UA_NodeClass_delete(out1)
end

#clean up
UA_Server_delete(server)
UA_VariableAttributes_delete(attr)
UA_NodeId_delete(variablenodeid) 
UA_NodeId_delete(parentnodeid) 
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename) 
UA_NodeId_delete(variabletypenodeid) 
UA_VariableTypeAttributes_delete(attr2) 
UA_NodeId_delete(reqnewnodeid) 
UA_NodeId_delete(parent2) 
UA_NodeId_delete(ref2) 
UA_QualifiedName_delete(browse2) 
UA_NodeId_delete(t2)
