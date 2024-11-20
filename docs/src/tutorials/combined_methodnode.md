# Simple Method Nodes

In this tutorial, we will add a method node to a server. A method node takes input(s), calls a 
a function (or method) on the server side and calculates output(s) based on the inputs. We 
will then proceed to call the new method node using the server API, as well as the client 
API; just to showcase both. 

In  Open62541.jl there is a convenient high level interface for this that simplifies these 
operations, at the price of the loss of some flexibility when defining the methods. In the 
final section of this tutorial, we will show how more flexible methods can defined and used 
within by using the low level interface.

## Configuring the server
TODO

```julia
using Open62541
using Pkg.BinaryPlatforms

#configure the open62541 server; we choose a default config on port 4840.
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)

#define Julia functions that will be used within the method nodes
#A one input, one output method. Classical "Hello World!".
function simple_one_in_one_out(name)
    assembledstring = "Hello "*name*"."
    return assembledstring
end 

#A two input, two output method. It will say hello and square a number.
function simple_two_in_two_out(name, number)
    out1 = "Hello "*name*"."
    out2 = number*number
    return (out1, out2)
end 

#prepare method attributes
attr1 = JUA_MethodAttributes(description = "Simple One in One Out",
    displayname = "Simple One in One Out",
    executable = true, #makes the method node executable via server API
    userexecutable = true) #makes the method executable via client API
attr2 = JUA_MethodAttributes(description = "Simple Two in Two Out - Mixed Types",
    displayname = "Simple Two in Two Out - Mixed Types",
    executable = true,
    userexecutable = true)

#define nodeids for the two methods:
methodid1 = JUA_NodeId(1, 62541)
methodid2 = JUA_NodeId(1, 62542)

#parent and reference nodeid:
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER) #method nodes will appear in "Objects"
parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)

#prepare method callbacks
#the following code is necessary, because Apple silicon does not currently support closures 
#within @cfunction, see ?@cfunction. If you are on Windows/*nix, you can just use the 
#UA_MethodCallback_generate(...) part.
function wrap_method_by_architecture(method)
    @static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
        res = UA_MethodCallback_generate(method)
    else #we are on Apple Silicon and can't use a closure in @cfunction, have to do more work.
        res = @cfunction(method, UA_StatusCode,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
    end
    return res
end

w1 = UA_MethodCallback_wrap(simple_one_in_one_out) #see ?UA_MethodCallback_wrap
w2 = UA_MethodCallback_wrap(simple_two_in_two_out)
m1 = wrap_method_by_architecture(w1)
m2 = wrap_method_by_architecture(w2)



JUA_Server_runUntilInterrupt(server) #start the server, shut it down by pressing CTRL+C repeatedly once you are finished with it.
```

## Method calling using server API
TODO

## Method calling using client API
TODO
Start a new Julia session and run the program shown below. Once you are finished, 
you may want to return to the first Julia session and stop the server (press 
CTRL + C repeatedly).

```julia
using Open62541

#initiate client, configure it and connect to server
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)

retval = JUA_Client_connectUsername(client,
            "opc.tcp://localhost:4840",
            "BruceWayne",
            "IamBatman") #connect using the username and password

JUA_Client_disconnect(client) #disconnect

retval2 = JUA_Client_connectUsername(client,
            "opc.tcp://localhost:4840",
            "PeterParker",
            "IamSpiderman") #try connecting using a wrong username/password

JUA_Client_disconnect(client) #disconnect
 
```
`retval` should be `UA_STATUSCODE_GOOD` (= 0) indicating that authentication was sucessful,
whereas `retval2` should be `UA_STATUSCODE_BADUSERACCESSDENIED` (= 2149515264) indicating 
that the second login attempt was rejected.

Note that in this basic configuration the login credentials are transmitted unencrypted,
which is obviously not recommended when network traffic is potentially exposed to 
unwanted listeners.
