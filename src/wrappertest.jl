
using open62541

n1 = open62541.JUA_NodeId(1, 1234)
n2 = UA_NodeId_new(1, 1234)
n3 = open62541.JUA_NodeId(1, "my_new_id")
n4 = UA_NodeId_new(1, "my_new_id")

UA_NodeId_equal(n1, n2)
UA_NodeId_equal(n3, n4)

n3 = 10 #this causes reference to the pointer in n3 to be lost (which is connected to allocated memory). 
        #since finalizer is defined in the wrapper, the memory gets automatically freed.
GC.gc() #garbage collector frees the memory (normally runs automatically) 

for i in 1:50_000_000 #"forgetting" to free memory creates memory leak - should eat up about 3GB of memory.
    n5 = UA_NodeId_new(1, "my new id")
    n5 = 10
end

GC.gc() #memory not recovered by GC. :(

for i in 1:50_000_000 #no memory leak; usage constant, because the GC is at work.
    n6 = open62541.JUA_NodeId(1, "my new id")
    n6 = 10
end




