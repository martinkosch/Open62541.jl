# Server

This page lists docstrings relevant to the server API.

## Adding different types of nodes:

```@docs; canonical = false
JUA_Server_addNode
UA_Server_addVariableNode
UA_Server_addObjectNode 
UA_Server_addVariableTypeNode
UA_Server_addObjectTypeNode
UA_Server_addViewNode
UA_Server_addReferenceTypeNode
UA_Server_addDataTypeNode
UA_Server_addMethodNode
```

## Reading from nodes:

```@docs; canonical = false
UA_Server_readAccessLevel
UA_Server_readArrayDimensions
UA_Server_readBrowseName
UA_Server_readContainsNoLoops
UA_Server_readDataType
UA_Server_readDescription
UA_Server_readDisplayName
UA_Server_readEventNotifier
UA_Server_readExecutable
UA_Server_readHistorizing
UA_Server_readInverseName
UA_Server_readIsAbstract
UA_Server_readMinimumSamplingInterval
UA_Server_readNodeClass
UA_Server_readNodeId
UA_Server_readSymmetric
UA_Server_readValue
UA_Server_readValueRank
UA_Server_readWriteMask
```

## Writing to nodes:

```@docs; canonical = false
UA_Server_writeAccessLevel
UA_Server_writeArrayDimensions
UA_Server_writeBrowseName
UA_Server_writeDataType
UA_Server_writeDataValue
UA_Server_writeDescription
UA_Server_writeDisplayName
UA_Server_writeEventNotifier
UA_Server_writeExecutable
UA_Server_writeHistorizing
UA_Server_writeInverseName
UA_Server_writeIsAbstract
UA_Server_writeMinimumSamplingInterval
UA_Server_writeValue
UA_Server_writeValueRank
UA_Server_writeWriteMask
```
