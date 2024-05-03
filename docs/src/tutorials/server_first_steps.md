```@meta
CurrentModule = open62541
```

# First steps with an open62541 server
Starting up a server with a default configuration in open62541.jl is very simple.
Just execute the following code in the REPL or as a script:
```julia
    server = JUA_Server()
    config = JUA_ServerConfig(server)
    JUA_ServerConfig_setDefault(config)
    JUA_Server_runUntilInterrupt(server)
```
This will configure a server with the default configuration (address: opc.tcp://localhost:4840/)
 and start it. The server can be shut down by pressing CTRL+C multiple times.

While running the server it can be accessed, for example, either via the Client 
API of open62541.jl or it can be browsed and accessed with a graphical client, 
such as [UA Expert website](https://www.unified-automation.com/products/development-tools/uaexpert.html).

How to add your own variables, objects, methods, and objects is explained in 
subsequent tutorials.

