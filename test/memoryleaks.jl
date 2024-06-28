using Open62541
using Test

function meminfo_julia()
    Float64(Sys.maxrss() / 2^20) #gives memory use of the whole julia process in MBs
end

#Basic functions
#UA_STRING_ALLOC
mem_start = meminfo_julia()
for i in 1:10_000_000
    s = UA_STRING_ALLOC("test")
    UA_String_delete(s)
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#UA_QualifiedName
ua_s = UA_STRING("scalar variable")
mem_start = meminfo_julia()
for i in 1:10_000_000
    qn1 = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
    qn2 = UA_QUALIFIEDNAME_ALLOC(1, ua_s)
    UA_QualifiedName_delete(qn1)
    UA_QualifiedName_delete(qn2)
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#UA_LocalizedText
ua_s1 = UA_STRING("test1")
ua_s2 = UA_STRING("test2")
mem_start = meminfo_julia()
for i in 1:100_000_000
    lt1 = UA_LOCALIZEDTEXT_ALLOC("test1", "test2")
    lt2 = UA_LOCALIZEDTEXT_ALLOC(ua_s1, ua_s2)
    UA_LocalizedText_delete(lt1)
    UA_LocalizedText_delete(lt2)
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#NodeIds
ua_s = UA_STRING("test")
guid = UA_Guid_random()
ua_s2 = UA_String_new()
UA_Guid_print(guid, ua_s2)
guid_string = unsafe_string(ua_s2)
UA_String_delete(ua_s2)

mem_start = meminfo_julia()
for i in 1:10_000_000
    n1 = UA_NODEID("ns=1;s=test")
    n2 = UA_NODEID_STRING(1, ua_s)
    n3 = UA_NODEID_STRING(1, "test")
    n4 = UA_NODEID_STRING_ALLOC(1, ua_s)
    n5 = UA_NODEID_STRING_ALLOC(1, "test")
    n6 = UA_NODEID_NUMERIC(1, 1234)
    n7 = UA_NODEID("ns=1;g=" * guid_string)
    n8 = UA_NODEID_GUID(1, guid)
    n9 = UA_NODEID_GUID(1, guid_string)
    n10 = UA_NODEID("ns=1;b=dGVzdA==")
    n11 = UA_NODEID_BYTESTRING(1, "test")
    n12 = UA_NODEID_BYTESTRING_ALLOC(1, "test")
    UA_NodeId_delete(n1)
    UA_NodeId_delete(n2)
    UA_NodeId_delete(n3)
    UA_NodeId_delete(n4)
    UA_NodeId_delete(n5)
    UA_NodeId_delete(n6)
    UA_NodeId_delete(n7)
    UA_NodeId_delete(n8)
    UA_NodeId_delete(n9)
    UA_NodeId_delete(n10)
    UA_NodeId_delete(n11)
    UA_NodeId_delete(n12)
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#expanded nodeids
ns_uri = "http://example.com"
server_ind = 1
nodeid = UA_NODEID_NUMERIC(0, 1234)
guid = UA_Guid_random()
ua_s2 = UA_String_new()
UA_Guid_print(guid, ua_s2)
guid_string = unsafe_string(ua_s2)
UA_String_delete(ua_s2)
ua_s = UA_STRING("test")
mem_start = meminfo_julia()
for i in 1:10_000_000
    e1 = UA_EXPANDEDNODEID("ns=1;s=test")
    e2 = UA_EXPANDEDNODEID_STRING(1, "test")
    e3 = UA_EXPANDEDNODEID_STRING_ALLOC(1, ua_s)
    e4 = UA_EXPANDEDNODEID("ns=1;i=1234")
    e5 = UA_EXPANDEDNODEID_NUMERIC(1, 1234)
    e6 = UA_EXPANDEDNODEID_NUMERIC(1, 1234)
    e7 = UA_EXPANDEDNODEID("ns=1;g=" * guid_string)
    e8 = UA_EXPANDEDNODEID_STRING_GUID(1, guid)
    e9 = UA_EXPANDEDNODEID_STRING_GUID(1, guid_string)
    e10 = UA_EXPANDEDNODEID("ns=1;b=dGVzdA==")
    e11 = UA_EXPANDEDNODEID_BYTESTRING(1, "test")
    e12 = UA_EXPANDEDNODEID_BYTESTRING_ALLOC(1, "test")
    e13 = UA_EXPANDEDNODEID("svr=1;nsu=http://example.com;s=test")
    e14 = UA_EXPANDEDNODEID_NUMERIC(1234, ns_uri, server_ind)
    e15 = UA_EXPANDEDNODEID_STRING_ALLOC("test", ns_uri, server_ind)
    e16 = UA_EXPANDEDNODEID_STRING_ALLOC(ua_s, ns_uri, server_ind)
    e17 = UA_EXPANDEDNODEID_STRING_GUID(guid, ns_uri, server_ind)
    e18 = UA_EXPANDEDNODEID_STRING_GUID(guid_string, ns_uri, server_ind)
    e19 = UA_EXPANDEDNODEID_NODEID(nodeid, ns_uri, server_ind)
    e20 = UA_EXPANDEDNODEID_BYTESTRING_ALLOC(ua_s, ns_uri, server_ind)
    e21 = UA_EXPANDEDNODEID_BYTESTRING_ALLOC("test", ns_uri, server_ind)
    UA_ExpandedNodeId_delete(e1)
    UA_ExpandedNodeId_delete(e2)
    UA_ExpandedNodeId_delete(e3)
    UA_ExpandedNodeId_delete(e4)
    UA_ExpandedNodeId_delete(e5)
    UA_ExpandedNodeId_delete(e6)
    UA_ExpandedNodeId_delete(e7)
    UA_ExpandedNodeId_delete(e8)
    UA_ExpandedNodeId_delete(e9)
    UA_ExpandedNodeId_delete(e10)
    UA_ExpandedNodeId_delete(e11)
    UA_ExpandedNodeId_delete(e12)
    UA_ExpandedNodeId_delete(e13)
    UA_ExpandedNodeId_delete(e14)
    UA_ExpandedNodeId_delete(e15)
    UA_ExpandedNodeId_delete(e16)
    UA_ExpandedNodeId_delete(e17)
    UA_ExpandedNodeId_delete(e18)
    UA_ExpandedNodeId_delete(e19)
    UA_ExpandedNodeId_delete(e20)
    UA_ExpandedNodeId_delete(e21)
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#VariableAttributes and VariableTypeAttributes - both scalar and array, hitting all dispatch paths
mem_start = meminfo_julia()
input1 = rand(Float64)
input2 = rand(Float64, 2)
input3 = rand(ComplexF64)
input4 = rand(ComplexF64, 2, 2)
input5 = "test1"
input6 = ["test1", "test2"]
inputs = (input1, input2, input3, input4, input5, input6)
for j in eachindex(inputs)
    for i in 1:10_000_000
        accesslevel = UA_ACCESSLEVEL(read = true, write = true)
        attr1 = UA_VariableAttributes_generate(value = inputs[j], displayname = "variable",
            description = "this is a variable", accesslevel = accesslevel)
        attr2 = UA_VariableTypeAttributes_generate(value = inputs[j], displayname = "variabletype",
            description = "this is variabletype variable")
        UA_VariableAttributes_delete(attr1)
        UA_VariableTypeAttributes_delete(attr2)
    end
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#adding a node to a server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))

#add a variable node
nodecontext = C_NULL
outnewnodeid = C_NULL
mem_start = meminfo_julia()
for i in 1:1_000_000
    accesslevel = UA_ACCESSLEVEL(read = true, write = true)
    input = rand(Float64)
    variablenodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
    parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
    typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
    attr = UA_VariableAttributes_generate(value = input, displayname = "scalar variable",
        description = "this is a scalar variable", accesslevel = accesslevel)
    retval = UA_Server_addVariableNode(server, variablenodeid, parentnodeid,
        parentreferencenodeid,
        browsename, typedefinition, attr, nodecontext, outnewnodeid)

    #cleaning up
    UA_NodeId_delete(parentnodeid)
    UA_NodeId_delete(parentreferencenodeid)
    UA_NodeId_delete(typedefinition)
    UA_QualifiedName_delete(browsename)
    UA_VariableAttributes_delete(attr)
    UA_Server_deleteNode(server, variablenodeid, true)
    UA_NodeId_delete(variablenodeid) #can't delete variablenodeid before deleting the node...
end
GC.gc()
mem_end = meminfo_julia()
@test (mem_end - mem_start) < 100.0

#clean up server
UA_Server_delete(server)
