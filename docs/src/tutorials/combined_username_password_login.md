# Username/password authentication using basic access control

In this tutorial, we will showcase how authentication using a username and password
(rather than an anonymous user) can be accomplished using Open62541.jl.

!!! warning
    
    Note that in this basic configuration the login credentials are transmitted unencrypted
    over the network, which is obviously *not recommended* when network traffic is
    potentially exposed to unwanted listeners.

## Configuring the server

Here we configure the server to accept a username/password combination. We will also disallow
anonymous logins. The code block is commented line by line.

```julia
using Open62541

#configure the open62541 server; we choose a default config on port 4840.
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)
login = JUA_UsernamePasswordLogin("BruceWayne", "IamBatman") #specifies the user BruceWayne and his secret password.
allowAnonymous = false #disallow anonymous login
JUA_AccessControl_default(config, allowAnonymous, login) #set the access control inside the server config.

JUA_Server_runUntilInterrupt(server) #start the server, shut it down by pressing CTRL+C repeatedly once you are finished with it.
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
config.allowNonePolicyPassword = true #allow logging in with username/password on un-encrypted connections.
JUA_ClientConfig_setDefault(config)

retval1 = JUA_Client_connectUsername(client,
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

`retval1` should be `UA_STATUSCODE_GOOD` (= 0) indicating that authentication was sucessful,
whereas `retval2` should be `UA_STATUSCODE_BADUSERACCESSDENIED` (= 2149515264) indicating
that the second login attempt was rejected.
