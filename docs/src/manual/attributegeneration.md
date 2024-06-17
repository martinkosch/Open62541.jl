# Attribute generation

This page lists docstrings of functions used for the convenient generation of 
node attribute structures. Their main use is when adding nodes to a server through 
client API (see [`JUA_Client_addNode`](@ref)) or the server API (see [`JUA_Server_addNode`](@ref)).

## Convenience functions that allow generating values for specific attributes:

```@docs; canonical = false
UA_VALUERANK
UA_ACCESSLEVEL
UA_USERACCESSLEVEL
UA_WRITEMASK
UA_USERWRITEMASK
UA_EVENTNOTIFIER
```

## High level generators for attribute blocks:
```@docs; canonical = false
JUA_DataTypeAttributes
JUA_MethodAttributes
JUA_ObjectAttributes
JUA_ObjectTypeAttributes
JUA_ReferenceTypeAttributes
JUA_VariableAttributes
JUA_VariableTypeAttributes
JUA_ViewAttributes
```

## Lower level generators for attribute blocks:

```@docs; canonical = false
UA_DataTypeAttributes_generate
UA_MethodAttributes_generate
UA_ObjectAttributes_generate
UA_ObjectTypeAttributes_generate
UA_ReferenceTypeAttributes_generate
UA_VariableAttributes_generate
UA_VariableTypeAttributes_generate
UA_ViewAttributes_generate
```
