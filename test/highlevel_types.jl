using open62541
using Test

#JUA_String
j1 = JUA_String("test")
u1 = UA_STRING("test")
j2 = JUA_String(u1)
@test j1 isa JUA_String
@test j2 isa JUA_String
UA_String_delete(u1)

#JUA_Guid
j1 = JUA_Guid()
u1 = UA_Guid_new()
j2 = JUA_Guid(u1)
@test j1 isa JUA_Guid
@test j2 isa JUA_Guid
UA_Guid_delete(u1)

#JUA_Variant
j1 = JUA_Variant()
@test j1 isa JUA_Variant
v = UA_Variant_new()
j2 = JUA_Variant(v)
@test j2 isa JUA_Variant
UA_Variant_delete(v)

#JUA_NodeId
j1 = JUA_NodeId()
u1 = UA_NodeId_new()
j2 = JUA_NodeId(u1)
@test j1 isa JUA_NodeId
@test j2 isa JUA_NodeId
UA_NodeId_delete(u1)

#JUA_QualifiedName
j1 = JUA_QualifiedName(1, "test")
ua_s = UA_STRING("test")
@test unsafe_string(j1.name) == unsafe_string(ua_s) #tests access of properties in high level struct.
UA_String_delete(ua_s)
u1 = UA_QUALIFIEDNAME(1, "test")
j2 = JUA_QualifiedName(u1)
j3 = JUA_QualifiedName()
@test j1 isa JUA_QualifiedName
@test j2 isa JUA_QualifiedName
@test j3 isa JUA_QualifiedName
UA_QualifiedName_delete(u1)

#Attributes
#just testing the fallback methods here; other methods are tested in more in depth
#testsets
u1 = UA_VariableAttributes_generate(value = "test1",
    displayname = "test2",
    description = "test3")
u2 = UA_VariableTypeAttributes_generate(value = "test1",
    displayname = "test2",
    description = "test3")
u3 = UA_ObjectAttributes_generate(displayname = "test2", description = "test3")
u4 = UA_ObjectTypeAttributes_generate(displayname = "test2", description = "test3")
u5 = UA_ReferenceTypeAttributes_generate(displayname = "test2",
    description = "test3")
u6 = UA_DataTypeAttributes_generate(displayname = "test2", description = "test3")
u7 = UA_ViewAttributes_generate(displayname = "test2", description = "test3")
u8 = UA_MethodAttributes_generate(displayname = "test2", description = "test3")
j1 = JUA_VariableAttributes(u1)
j2 = JUA_VariableTypeAttributes(u2)
j3 = JUA_ObjectAttributes(u3)
j4 = JUA_ObjectTypeAttributes(u4)
j5 = JUA_ReferenceTypeAttributes(u5)
j6 = JUA_DataTypeAttributes(u6)
j7 = JUA_ViewAttributes(u7)
j8 = JUA_MethodAttributes(u8)
@test j1 isa JUA_VariableAttributes
@test j2 isa JUA_VariableTypeAttributes
@test j3 isa JUA_ObjectAttributes
@test j4 isa JUA_ObjectTypeAttributes
@test j5 isa JUA_ReferenceTypeAttributes
@test j6 isa JUA_DataTypeAttributes
@test j7 isa JUA_ViewAttributes
@test j8 isa JUA_MethodAttributes
UA_VariableAttributes_delete(u1)
UA_VariableTypeAttributes_delete(u2)
UA_ObjectAttributes_delete(u3)
UA_ObjectTypeAttributes_delete(u4)
UA_ReferenceTypeAttributes_delete(u5)
UA_DataTypeAttributes_delete(u6)
UA_ViewAttributes_delete(u7)
UA_MethodAttributes_delete(u8)
