using open62541
using Test

#JUA_String
j1 = JUA_String("test")
u1 = UA_STRING("test")
j2 = JUA_String(u1)
@test j1 isa JUA_String
@test j2 isa JUA_String
UA_String_delete(u1)

#JUA_Variant
j1 = JUA_Variant()
@test j1 isa JUA_Variant
v = UA_Variant_new()
j2 = JUA_Variant(v)
@test j2 isa JUA_Variant
UA_Variant_delete(v)

#JUA_QualifiedName
j1 = JUA_QualifiedName(1, "test")
ua_s = UA_STRING("test")
@test unsafe_string(j1.name) == unsafe_string(ua_s) #tests access of properties in high level struct.
UA_String_delete(ua_s)
u1 = UA_QUALIFIEDNAME(1, "test")
j2 = JUA_QualifiedName(u1)
@test j1 isa JUA_QualifiedName
@test j2 isa JUA_QualifiedName
UA_QualifiedName_delete(u1)

