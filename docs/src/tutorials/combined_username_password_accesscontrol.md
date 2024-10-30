# Username/password authentication and basic access control

In this tutorial, we will showcase how authentication using a username and password
(rather than an anonymous user) can be accomplished using Open62541.jl. We will 
also showcase basic access control features, specifically, we will configure that 
a connected client can add nodes and references, as well as delete references. 
However, we will disallow the client to delete nodes from the server.

## Configuring the server
This will detail how to add the variables mentioned above to the server. The 
code block is commented line by line.

```julia
using Open62541

#configure the open62541 server; we choose a default config on port 4840.
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)
login = UA_UsernamePasswordLogin(UA_STRING("user"), UA_STRING("password"))
retval = UA_AccessControl_default(config, false,
    Ref(unsafe_load(unsafe_load(config.securityPolicies)).policyUri), 1, Ref(login))

JUA_Server_runUntilInterrupt(server)
```

## Using the client
Start a new Julia session and run the program shown below. Once you are finished, 
you may want to return to the first Julia session and stop the server (press 
CTRL + C repeatedly).

```julia
using Open62541

#initiate client, configure it and connect to server
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
JUA_Client_connect(client, "opc.tcp://localhost:4840")

#create the relevant nodeids (note that we are in a new Julia session, therefore,
#we have to redefine these variables)
name1 = "scalar float"
name2 = "array of floats"
name3 = "array of strings"
id1 = JUA_NodeId(1, name1)
id2 = JUA_NodeId(1, name2)
id3 = JUA_NodeId(1, name3)

#read values from the nodeids specified above
value_id1 = JUA_Client_readValueAttribute(client, id1)
value_id2 = JUA_Client_readValueAttribute(client, id2)
value_id3 = JUA_Client_readValueAttribute(client, id3)

#now write something new into the variables
new1 = 43.0
new2 = [1.0, 2.0, 3.0]
new3 = ["Maria", "Wuffi"]
retval1 = JUA_Client_writeValueAttribute(client, id1, new1)
retval2 = JUA_Client_writeValueAttribute(client, id2, new2)
retval3 = JUA_Client_writeValueAttribute(client, id3, new3)
```

Inspecting the return values (`retval1,2,3`) and the log and error messages in the 
terminal (both server and client), you will see that writing `new2` to `id2` 
failed with the statuscode "BadTypeMismatch" (`retval2a`). 

This is because in open62541 arrays are statically sized, both in terms of the 
number of dimensions, as well as the number of elements along each dimension. 
In order for this to work, one first has to specify the new array dimensions 
(and the write mask property of the variable has to allow altering this value; 
see the server code above!).

```julia
#Try again, but properly this time
retval4 = UA_Client_writeArrayDimensionsAttribute(client, id2, 1, [3])
retval5 = JUA_Client_writeValueAttribute(client, id2, new2)

#disconnect the client (good housekeeping practice)
JUA_Client_disconnect(client)
```

Note that changing the dimensionality of the array **additionally** requires 
setting the `valuerank` attribute either to `UA_VALUERANK_ONE_OR_MORE_DIMENSIONS` 
when defining the variable attributes in the server setup code above, or, one 
can use `UA_Client_writeValueRankAttribute` (and the writemask of the variable 
 attributes has to allow changing the valuerank property) to first change the 
 valuerank of the variable, before proceeding to change the array dimensions and 
 then finally setting the variable.
