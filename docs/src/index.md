# Open62541.jl
Welcome to the documentation of Open62541.jl. 

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

!!! warning
    Note that Open62541.jl is still under active development and has not reached a maturity
    that would make it safe to use in a production environment.

    The developers aim to observe [semantic versioning](https://semver.org/), but
    accidental breakage and evolutions of the API have to be expected.


## Installation

Open62541.jl is registered in Julia's General registry.

Assuming you have Julia already installed (otherwise: [JuliaLang Website](https://julialang.org/)),
you can install Open62541.jl by executing:

```julia
using Pkg
Pkg.add("Open62541")
```

## Structure of the documentation
The documentation has the following structure:

- Tutorials: Provides a few brief instructions that showcase basic functionality. 
- Manual: Currently only slightly more than a reference, but intended to be more explanatory than the reference.
- Reference: Low level interface: Contains a list of functions and types that ship with open62541.
- Reference: High level interface: Contains a list of functions and types that constitute the higher level interface generated for Open62541.jl.

!!! note 
    The documentation is still a work in progress. To be concrete, many functions
    within src/Open62541.jl are still without docstrings. These are thin wrappers 
    to functions in open62541 generated through Clang.jl. Therefore, users who 
    are familiar with open62541 should be aware of the functions; users unfamilar
    with open62541 will have to resort to the source code for the time being.

    Docstrings will be added (pull requests welcome!).
    
    The docstring situation is better on the handwritten functions contained in 
    the other source files.

## How to contribute
There is many ways one can contribute to the development of Open62541.jl (in order of increasing complexity):
- Reporting bugs, issues and suggestions on the Github repository.
- Improving the clarity of the existing documentation.
- Adding new tutorials for more advanced functionality.
- Adding/Improving docstrings, especially in the main file of the library src/Open62541.jl. It would be best if these are added automatically in the right spot during the code generation using Clang.jl (see gen/generator.jl). But improvements are welcome also if they are directly done in the src/Open62541.jl (existing contributors can help keeping things aligned).
- Adding improvements to the high-level interface. It would be best to discuss ideas on this topic via the Github repository before embarking on larger changes.
