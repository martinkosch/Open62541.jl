# Based on https://www.open62541.org/doc/master/tutorial_datatypes.html
using open62541
using Test

# Int32
i = Int32(5)
j = UA_Int32_new()
UA_Int32_copy(i, j)
@test unsafe_load(j) == i
UA_Int32_delete(j)

# String
s1 = UA_STRING_ALLOC("test2") # Copies the content to the heap
s2 = UA_String_new()
UA_String_copy(s1, s2);
@test UA_String_equal(s1, s2)
UA_String_delete(s1) 
UA_String_delete(s2) 

# Structured Type
rr = UA_ReadRequest_new()
UA_init(rr) # Generic method
UA_ReadRequest_init(rr) # Shorthand for the previous line

rr.requestHeader.timestamp = UA_DateTime_now() # Members of a structure

rr.nodesToRead = UA_ReadValueId_new()
rr.nodesToRead = UA_Array_new(5, UA_ReadValueId)
rr.nodesToReadSize = 5 # Array size needs to be made known

rr2 = UA_ReadRequest_new()
UA_ReadRequest_copy(rr, rr2)
@test unsafe_load(rr2.nodesToReadSize) == unsafe_load(rr.nodesToReadSize)
UA_ReadRequest_clear(rr)
UA_ReadRequest_delete(rr2)