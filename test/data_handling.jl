# Based on https://www.open62541.org/doc/master/tutorial_datatypes.html
using open62541
using Test

### Int32
i = Int32(5)
j = UA_Int32_new()
UA_Int32_copy(i, j)
@test unsafe_load(j) == i

#clean up
UA_Int32_delete(j)

### Strings
s1 = UA_STRING_ALLOC("test2") # Copies the content to the heap
s2 = UA_String_new()
UA_String_copy(s1, s2)
@test UA_String_equal(s1, s2)

#clean up
UA_String_delete(s1)
UA_String_delete(s2)

### Structured Type
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

#clean up 
UA_ReadRequest_delete(rr)
UA_ReadRequest_delete(rr2)

### NodeIds
ns = 1
i = 1234
id1 = UA_NODEID_NUMERIC(ns, i)
@test unsafe_load(id1.namespaceIndex) == ns
@test unsafe_load(id1.identifier.numeric) == i
@test unsafe_load(id1.identifierType) == UA_NODEIDTYPE_NUMERIC

id2 = UA_NODEID_STRING_ALLOC(1, "testid")
@test !UA_NodeId_equal(id1, id2)

id3 = UA_NodeId_new()
UA_NodeId_copy(id2, id3)

#clean up
UA_NodeId_delete(id1)
UA_NodeId_delete(id2)
UA_NodeId_delete(id3)

# Variants
# Set a scalar value 
v = UA_Variant_new()
value = Ref(Int32(42))
type_ptr = UA_TYPES_PTRS[UA_TYPES_INT32]
retcode = UA_Variant_setScalarCopy(v, value, type_ptr)
@test retcode == UA_STATUSCODE_GOOD

# Make a copy 
v2 = UA_Variant_new()
UA_Variant_copy(v, v2)
@test unsafe_load(v2.storageType) == unsafe_load(v.storageType)
@test unsafe_load(v2.arrayLength) == unsafe_load(v.arrayLength)
@test open62541.unsafe_size(v2) == open62541.unsafe_size(v)
@test open62541.length(v2) == open62541.length(v)
@test unsafe_wrap(v2) == unsafe_wrap(v)
UA_Variant_delete(v2)
UA_Variant_delete(v)


# Set an array value
d = Float64[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
type_ptr = UA_TYPES_PTRS[UA_TYPES_DOUBLE]
v3 = UA_Variant_new()
v3.arrayLength = length(d)
ua_arr = UA_Array_new(vec(permutedims(d, reverse(1:length(size(d))))), type_ptr) # Allocate new UA_Array from value with C style indexing
UA_Variant_setArray(v3, ua_arr, length(d), type_ptr)
v3.arrayDimensionsSize = length(size(d))
v3.arrayDimensions = UA_UInt32_Array_new(reverse(size(d)))
@test all(isapprox.(d, unsafe_wrap(v3)))

# Set array dimensions
new_dims = UA_Array_new(2, UInt32)
new_dims[1] = 3
new_dims[2] = 3
v3.arrayDimensions = new_dims
v3.arrayDimensionsSize = 2
@test all(isapprox.(permutedims(reshape(d, (3, 3)), reverse(1:2)), unsafe_wrap(v3)))

#clean up
UA_Variant_delete(v)
UA_Variant_delete(v2)
UA_Variant_delete(v3)
