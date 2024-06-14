# Open62541.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://martinkosch.github.io/Open62541.jl/dev)
[![CI](https://github.com/martinkosch/Open62541.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/martinkosch/Open62541.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/martinkosch/Open62541.jl/graph/badge.svg?token=lJe2xOTO7g)](https://codecov.io/gh/martinkosch/Open62541.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

Open62541.jl is a [Julia](https://julialang.org) package that interfaces with the [open62541](https://www.open62541.org/)
library written in C ([source](https://github.com/open62541/open62541)).

As such, it provides functionality following the [OPC Unified Architecture (OPC UA) standard](https://en.wikipedia.org/wiki/OPC_Unified_Architecture)
for data exchange from sensors to cloud applications developed by the [OPC Foundation](https://opcfoundation.org/).

In short, it provides the ability to create OPC servers that make data from different
sources available to clients and, naturally, also a client functionality that allows
to read data from OPC UA servers. Features are summarized further on the [open62541 website](https://www.open62541.org/).

Open62541.jl's *ultimate* aim is to provide the full functionality of open62541 to
Julia users through a convenient high level interface without the need to engage
in manual memory management etc. (as required in open62541).

At its current development stage the high level interface is implemented for a
(commonly used) subset of functionality. An essentially feature-complete lower
level interface that wraps all functionality of open62541 is, however, available.

## Warning: active development

Note that Open62541.jl is still under active development and has not reached a maturity
that would make it safe to use in a production environment.

The developers aim to observe [semantic versioning](https://semver.org/), but
accidental breakage and evolutions of the API have to be expected.

Documentation is also a work in progress.

## Installation

Open62541.jl is registered in Julia's General registry.

Assuming you have Julia already installed (otherwise: [JuliaLang Website](https://julialang.org/)),
you can install Open62541.jl by executing:

```julia
using Pkg
Pkg.add("Open62541")
```

## Server example

Starting up a server with a default configuration in Open62541.jl is very simple.
Just execute the following code in the REPL or as a script:

```julia
using Open62541
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)
JUA_Server_runUntilInterrupt(server)
```

This will configure a server with the default configuration (address: opc.tcp://localhost:4840/)
and start it. The server can be shut down by pressing CTRL+C multiple times.

While the server is running, it can be accessed via the Client API of Open62541.jl
or it can be browsed and accessed with a graphical client, such as [UA Expert](https://www.unified-automation.com/products/development-tools/uaexpert.html).

## Basic client example

In order to showcase the Client API functionality, we will use the above server
and read some basic information from it, namely the software version number and
the current time. Note that this information should be contained in all OPC UA
servers, so you could also connect to a different server that you know is running.

```julia
using Open62541
using Printf

#initiate client, configure it and connect to server
client = JUA_Client()
config = JUA_ClientConfig(client)
JUA_ClientConfig_setDefault(config)
JUA_Client_connect(client, "opc.tcp://localhost:4840")

#define nodeids that we are interested in 
nodeid_currenttime = JUA_NodeId(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)
nodeid_version = JUA_NodeId(0, UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION)

#read data from nodeids
currenttime = JUA_Client_readValueAttribute(client, nodeid_currenttime) #Int64 which represents the number of 100 nanosecond intervals since January 1, 1601 (UTC)
version = JUA_Client_readValueAttribute(client, nodeid_version) #String containing open62541 version number

#Convert current time into human understandable format
dts = UA_DateTime_toStruct(currenttime)

#Print results to terminal
Printf.@printf("current date and time (UTC) is: %u-%u-%u %u:%u:%u.%03u\n",
    dts.day, dts.month, dts.year, dts.hour, dts.min, dts.sec, dts.milliSec)
Printf.@printf("The server is running open62541 version %s.", version)

#disconnect the client (good housekeeping practice)
JUA_Client_disconnect(client)
```
