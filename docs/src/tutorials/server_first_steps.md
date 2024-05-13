# First steps with an open62541 server

Starting up a server with a default configuration in open62541.jl is very simple.
Just execute the following code in the REPL or as a script:

```julia
using open62541
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)
JUA_Server_runUntilInterrupt(server)
```

This will configure a server with the default configuration (address: opc.tcp://localhost:4840/)
and start it. The server can be shut down by pressing CTRL+C multiple times.

While the server is running, it can be accessed via the Client API of open62541.jl
or it can be browsed and accessed with a graphical client, such as [UA Expert](https://www.unified-automation.com/products/development-tools/uaexpert.html).

Subsequent tutorials will explain how to add your own variables, objects, and
methods to the server.
