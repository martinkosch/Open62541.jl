# Simple Method Nodes

In this tutorial, we will add method nodes to a server. A method node takes input(s), calls
a function (or method) on the server side and calculates output(s) based on the input(s). We
will then proceed to call the new method nodes using the client API.

In  Open62541.jl there is a convenient high level interface for this that simplifies these
operations, at the price of some flexibility when defining the methods. In the
final section of this tutorial, we will show how more flexible methods can be defined and
used by employing the low level interface.

## Configuring the server

Here we configure the server to accept a username/password combination. We will also disallow
anonymous logins. The code block is commented line by line.

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
    assembledstring = "Hello " * name * "."
    return assembledstring
end

#A two input, two output method. It will say hello and square a number.
function simple_two_in_two_out(name, number)
    out1 = "Hello " * name * "."
    out2 = number * number
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

#define browsenames for the two method nodes
browsename1 = JUA_QualifiedName(1, "Simple One in One Out")
browsename2 = JUA_QualifiedName(1, "Simple Two in Two Out")

#prepare method callbacks
#the following code is necessary, because Apple silicon does not currently support closures 
#within @cfunction, see ?@cfunction. If you are on Windows/*nix, you can just use the 
#UA_MethodCallback_wrap(...) part; on Apple Silicon, the longer and more cumbersome part is 
#used instead.
@static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
    m1 = UA_MethodCallback_generate(UA_MethodCallback_wrap(simple_one_in_one_out))
    m2 = UA_MethodCallback_generate(UA_MethodCallback_wrap(simple_two_in_two_out))
else #we are on Apple Silicon and can't use a closure in @cfunction, have to do more work.
    function c1(server, sessionId, sessionHandle, methodId, methodContext, objectId,
            objectContext, inputSize, input, outputSize, output)
        arr_input = UA_Array(input, Int64(inputSize))
        arr_output = UA_Array(output, Int64(outputSize))
        input_julia = Open62541.__get_juliavalues_from_variant.(arr_input, Any)
        output_julia = simple_one_in_one_out(input_julia...)
        if !isa(output_julia, Tuple)
            output_julia = (output_julia,)
        end
        for i in 1:outputSize
            j = JUA_Variant(output_julia[i])
            UA_Variant_copy(Open62541.Jpointer(j), arr_output[i])
        end
        return UA_STATUSCODE_GOOD
    end
    function c2(server, sessionId, sessionHandle, methodId, methodContext, objectId,
            objectContext, inputSize, input, outputSize, output)
        arr_input = UA_Array(input, Int64(inputSize))
        arr_output = UA_Array(output, Int64(outputSize))
        input_julia = Open62541.__get_juliavalues_from_variant.(arr_input, Any)
        output_julia = simple_two_in_two_out(input_julia...)
        if !isa(output_julia, Tuple)
            output_julia = (output_julia,)
        end
        for i in 1:outputSize
            j = JUA_Variant(output_julia[i])
            UA_Variant_copy(Open62541.Jpointer(j), arr_output[i])
        end
        return UA_STATUSCODE_GOOD
    end
    m1 = @cfunction(c1, UA_StatusCode,
        (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
    m2 = @cfunction(c2, UA_StatusCode,
        (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
end

#create example input and output arguments
oneinputarg = JUA_Argument("examplestring", name = "One input", description = "One input")
j1 = JUA_Argument("examplestring", name = "Name", description = "Number")
j2 = JUA_Argument(25, name = "Number", description = "Number")
twoinputarg = [j1, j2]

oneoutputarg = JUA_Argument(
    "examplestring", name = "One output", description = "One output")
j3 = JUA_Argument("examplestring", name = "Name", description = "Name")
j4 = JUA_Argument(25, name = "Number", description = "Number")
twooutputarg = [j3, j4]

#Add the method nodes to the server
retval1 = JUA_Server_addNode(server, methodid1, parentnodeid, parentreferencenodeid,
    browsename1, attr1, m1, oneinputarg, oneoutputarg,
    JUA_NodeId(), JUA_NodeId())
retval2 = JUA_Server_addNode(server, methodid2, parentnodeid, parentreferencenodeid,
    browsename2, attr2, m2, twoinputarg, twooutputarg,
    JUA_NodeId(), JUA_NodeId())

#For testing purposes, let's call the methods using the Server API. The more common use case, 
#that is calling the method node on a remote server via the Client API is shown below.
testinput1 = "Peter"
testinput2 = ("Claudia", 25)
res1 = JUA_Server_call(server, parentnodeid, methodid1, testinput1) # "Hello Peter."
res2 = JUA_Server_call(server, parentnodeid, methodid2, testinput2) # ("Hello Claudia.", 625)

#start the server, shut it down by pressing CTRL+C repeatedly once you are finished with it.
JUA_Server_runUntilInterrupt(server)
```

You can verify that the server has been correctly configured using, for example, a graphical
client, such as [UA Expert](https://www.unified-automation.com/products/development-tools/uaexpert.html).

In the following, we will access the server by calling the newly added method nodes through
the client API.

## Method calling using client API

In the following, we use the client API to call the newly established method nodes on the
server. In order to do so, start a new Julia session and run the program shown below.
Once you are finished, you may want to return to the first Julia session and stop the server
(press CTRL + C repeatedly).

```julia
using Open62541

#initiate client, configure it and connect to server
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
JUA_Client_connect(client, "opc.tcp://localhost:4840")

#re-define methodids and parentnodeid; remember, we are in a new Julia session.
methodid1 = JUA_NodeId(1, 62541)
methodid2 = JUA_NodeId(1, 62542)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)

#Define the input arguments
one_input = "Peter"
two_inputs = ("Claudia", 25)

#Call the method nodes
response1 = JUA_Client_call(client, parentnodeid, methodid1, one_input)
response2 = JUA_Client_call(client, parentnodeid, methodid2, two_inputs)

JUA_Client_disconnect(client) #disconnect
```

`response1` should be a string "Hello Peter.", whereas `response2` should be the tuple
`("Hello Claudia.", 625)`.

## More flexibility in method definitions

When configuring the server, expect for the case of Apple Silicon (see server section above),
we have employed the high level functions `UA_MethodCallback_wrap` and `UA_MethodCallback_generate`.
The former assumes that the output of the method your are calling solely depends on the user
inputs provided, but *not* on the state of the server, the session id, etc.

The Apple Silicon part of the server section above details how methods with more flexibility
can be defined (which is more cumbersome, because the lower level interface is used). It is
repeated below with more explanations.

```julia
using Open62541

#Define a more flexible method where one can also access server state, session id, etc.
#The function signature expected is:
#ret::UA_StatusCode = c2(server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId}, 
#    sessionHandle::Ptr{Cvoid}, methodId::Ptr{UA_NodeId}, methodContext::Ptr{Cvoid}, 
#    objectId::Ptr{UA_NodeId}, objectContext::Ptr{Cvoid}, inputSize::Csize_t, 
#    input::Ptr{UA_Variant}, outputSize::Csize_t, output::Ptr{UA_Variant}))

function c2(server, sessionId, sessionHandle, methodId, methodContext, objectId,
        objectContext, inputSize, input, outputSize, output)
    #define array wrappers for easier access of the corresponding memory
    arr_input = UA_Array(input, Int64(inputSize))
    arr_output = UA_Array(output, Int64(outputSize))

    #get input values in the form of a Julia tuple.
    input_julia = Open62541.__get_juliavalues_from_variant.(arr_input, Any)

    #prepare outputs
    output_julia = ... #whatever you want to do with all the input arguments

    #wraps singular output into tuple to process below.
    if !isa(output_julia, Tuple)
        output_julia = (output_julia,)
    end

    #copy Julia outputs into the memory where open62541 expects the results to be.
    for i in 1:outputSize
        j = JUA_Variant(output_julia[i])
        UA_Variant_copy(Open62541.Jpointer(j), arr_output[i])
    end

    #return a statuscode; obviously, might want to do some error catching if things don't work.
    return UA_STATUSCODE_GOOD
end

#create Ptr{Cvoid} expected when adding the method node to the server (if *not* on Apple 
#Silicon, this part can also be done with UA_MethodCallback_generate)
m2 = @cfunction(c2, UA_StatusCode,
    (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
        Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
        Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
```
