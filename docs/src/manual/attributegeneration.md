# Attribute generation

This page lists docstrings of functions used for the convenient generation of 
node attribute structures. Their main use is when adding nodes to a server through 
client API (see [`JUA_Client_addNode`](@ref)) or the server API (see [`JUA_Server_addNode`](@ref)).

Convenience functions that allow setting values for specific attributes:

```@docs
UA_VALUERANK
UA_ACCESSLEVEL
UA_USERACCESSLEVEL
UA_WRITEMASK
UA_USERWRITEMASK
UA_EVENTNOTIFIER
```

High level generators for attribute blocks:
```@docs
JUA_VariableAttributes
JUA_VariableTypeAttributes
JUA_ObjectAttributes
JUA_ObjectTypeAttributes
JUA_MethodAttributes
JUA_ViewAttributes
JUA_DataTypeAttributes
JUA_ReferenceTypeAttributes
```

Lower level generators for attribute blocks:
```@docs
UA_VariableAttributes_generate
UA_VariableTypeAttributes_generate
UA_ObjectAttributes_generate
UA_ObjectTypeAttributes_generate
UA_MethodAttributes_generate
UA_ViewAttributes_generate
UA_DataTypeAttributes_generate
UA_ReferenceTypeAttributes_generate
```
