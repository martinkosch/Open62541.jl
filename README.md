# open62541.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://martinkosch.github.io/open62541.jl/dev)
[![CI](https://github.com/martinkosch/open62541.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/martinkosch/open62541.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/martinkosch/open62541.jl/graph/badge.svg?token=lJe2xOTO7g)](https://codecov.io/gh/martinkosch/open62541.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

open62541.jl is a [Julia](https://julialang.org) package that interfaces with the [open62541](https://www.open62541.org/) 
library written in C ([source](https://github.com/open62541/open62541)). 

As such, it provides functionality following the [OPC Unified Architecture (OPC UA) standard](https://en.wikipedia.org/wiki/OPC_Unified_Architecture) 
for data exchange from sensors to cloud applications developed by the [OPC Foundation](). 

In short, it provides the ability to create OPC servers that make data from different 
sources available to clients and, naturally, also a client functionality that allows 
to read data from OPC UA servers. Features are summarized further on the [open62541 website](https://www.open62541.org/).

open62541.jl's *ultimate* aim is to provide the full functionality of open62541 to 
Julia users through a convenient high level interface without the need to engage 
in manual memory management etc. (as required in open62541).

At its current development stage the high level interface is implemented for a 
(commonly used) subset of functionality. An essentially feature-complete lower 
level interface that wraps all functionality of open62541 is, however, available.

## Warning: active development
Note that open62541.jl is still under active development and has not reached a maturity 
that would make it safe to use in a production environment. 

The developers aim to observe [semantic versioning](https://semver.org/), but 
accidental breakage and evolutions of the API have to be expected. 

Documentation is also a work in progress.

## Installation
open62541.jl is not yet registered in Julia's General registry, but it will 
hopefully be soon (status: May 2024). 

Assuming you have Julia already installed (otherwise: [JuliaLang Website](https://julialang.org/)), 
you can install by executing:
```julia
    using Pkg
    Pkg.add("https://github.com/martinkosch/open62541.jl")
```

## Server example
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

## Basic client example


