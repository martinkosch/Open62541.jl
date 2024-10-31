using Open62541
using Test

#JUA_String
j0 = JUA_String()
j1 = JUA_String("test")
u1 = UA_STRING("test")
j2 = JUA_String(u1)
@test j0 isa JUA_String
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
@test_throws Open62541.UnsupportedNumberTypeError JUA_Variant(Rational(true, false))
@test_throws Open62541.UnsupportedNumberTypeError JUA_Variant([Complex(Rational(1, 2), Rational(3, 4)), Complex(Rational(5, 6), Rational(7, 8))])
@test_throws Open62541.UnsupportedNumberTypeError JUA_Variant([Complex(Int16(1), Int16(3)), Complex(Int32(4), Int32(5))])
@test_throws Open62541.UnsupportedNumberTypeError JUA_Variant(Complex(Int16(1), Int16(3)))
@test_throws Open62541.UnsupportedNumberTypeError JUA_Variant(Complex(Rational(1, 2), Rational(3, 4)))

#JUA_NodeId
j1 = JUA_NodeId()
u1 = UA_NodeId_new()
j2 = JUA_NodeId(u1)
@test j1 isa JUA_NodeId
@test j2 isa JUA_NodeId
UA_NodeId_delete(u1)

#JUA_ExpandedNodeId
j1 = JUA_ExpandedNodeId()
@test j1 isa JUA_ExpandedNodeId
j1 = 0
GC.gc()

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

#JUA_LocalizedText
s1 = "test"
ua_s1 = UA_STRING(s1)
jua_s1 = JUA_String(s1)
s2 = "en-US"
ua_s2 = UA_STRING(s2)
jua_s2 = JUA_String(s2)
u1 = UA_LocalizedText_new()
j1 = JUA_LocalizedText()
j2 = JUA_LocalizedText(u1)
j3 = JUA_LocalizedText(s1, s2)
j4 = JUA_LocalizedText(s1, ua_s2)
j5 = JUA_LocalizedText(s1, jua_s2)
j6 = JUA_LocalizedText(ua_s1, s2)
j7 = JUA_LocalizedText(ua_s1, ua_s2)
j8 = JUA_LocalizedText(ua_s1, jua_s2)
j9 = JUA_LocalizedText(jua_s1, s2)
j10 = JUA_LocalizedText(jua_s1, s2)
j11 = JUA_LocalizedText(jua_s1, s2)

@test j1 isa JUA_LocalizedText
@test j2 isa JUA_LocalizedText
@test j3 isa JUA_LocalizedText
@test j4 isa JUA_LocalizedText
@test j5 isa JUA_LocalizedText
@test j6 isa JUA_LocalizedText
@test j7 isa JUA_LocalizedText
@test j8 isa JUA_LocalizedText
@test j9 isa JUA_LocalizedText
@test j10 isa JUA_LocalizedText
@test j11 isa JUA_LocalizedText

UA_LocalizedText_delete(u1)
UA_String_delete(ua_s1)
UA_String_delete(ua_s2)

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
