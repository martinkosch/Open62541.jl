# Purpose: This testset checks whether the UA_Server_writeXXXAttribute(...) functions 
#are usable. This is currently only implemented for nodes of "variable" type. For the attributes
#contained in such nodes we check whether the respective write function is able to write a correct
#variable type to the node. For functions not defined for a variable node, we check that they throw the 
#appropriate exception. 

using Open62541
using Test
using Base.Threads

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval0 == UA_STATUSCODE_GOOD

#add variable node
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
input = rand(Float64)
attr1 = UA_VariableAttributes_generate(value = input,
    displayname = "scalar variable",
    description = "this is a scalar variable",
    accesslevel = accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid1 = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid1 = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition1 = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename1 = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext1 = C_NULL
outnewnodeid1 = C_NULL
retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid1,
    parentreferencenodeid1,
    browsename1, typedefinition1, attr1, nodecontext1, outnewnodeid1)
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
requestednewnodeid = UA_NodeId_new()
parentnodeid2 = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename2 = UA_QUALIFIEDNAME(1, "2DPoint Type")
parentreferencenodeid2 = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
typedefinition2 = UA_NodeId_new()
retval = UA_Server_addVariableTypeNode(server, requestednewnodeid,
    parentnodeid2, parentreferencenodeid2,
    browsename2, typedefinition2,
    attr2, C_NULL, variabletypenodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

#TODO: add more node types 
nodes = (varnodeid, variabletypenodeid)
for node in nodes
    out1 = UA_NodeClass_new()
    UA_Server_readNodeClass(server, node, out1)
    nodeclass = unsafe_load(out1)
    if nodeclass == UA_NODECLASS_VARIABLE
        attributeset = UA_VariableAttributes
    elseif nodeclass == UA_NODECLASS_VARIABLETYPE
        attributeset = UA_VariableTypeAttributes
    end
    for att in Open62541.attributes_UA_Server_write
        fun_write = Symbol(att[1])
        fun_read = Symbol(replace(att[1], "write" => "read"))
        attr_name = Symbol(att[2])
        generator = Symbol(att[3] * "_new")
        cleaner = Symbol(att[3] * "_delete")
        out2 = eval(generator)()
        if in(Symbol(lowercasefirst(att[2])), fieldnames(attributeset)) ||
           in(Symbol(lowercasefirst(att[2])), fieldnames(UA_NodeHead))
            statuscode1 = eval(fun_read)(server, node, out2) #read
            @test statuscode1 == UA_STATUSCODE_GOOD
            if attr_name != :BrowseName #can't write browsename, see here: https://github.com/open62541/open62541/issues/3545
                statuscode2 = eval(fun_write)(server, node, out2) #write read value back...
                @test statuscode2 == UA_STATUSCODE_GOOD
            end
        end
        eval(cleaner)(out2)
    end
    UA_NodeClass_delete(out1)
end

#clean up
UA_Server_delete(server)
UA_NodeId_delete(varnodeid)
UA_NodeId_delete(parentnodeid1)
UA_NodeId_delete(parentreferencenodeid1)
UA_NodeId_delete(typedefinition1)
UA_QualifiedName_delete(browsename1)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid2)
UA_NodeId_delete(parentreferencenodeid2)
UA_NodeId_delete(typedefinition2)
UA_QualifiedName_delete(browsename2)
UA_NodeId_delete(variabletypenodeid)
