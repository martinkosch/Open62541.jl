# Reference: Low level interface

Lists types and functions that are part of the open62541 standard interface.

## open62541 types

```@autodocs
Modules = [Open62541]
Order = [:type]
Filter = t -> startswith(string(t), "UA_")
```

## Memory allocation and management for open62541 types

These are low level functions allowing to allocate and free (etc.) memory for
open62541 types ("UA_...") on the C-side, as well as comparison between objects of the same 
type.

```@autodocs
Modules = [Open62541]
Order = [:function]
Filter = t -> startswith(string(t), "UA_") && any(endswith.(string(t), ["_new", "_init", 
    "_delete", "_clear", "_copy", "_equal", "_deleteMembers"]))
```

## Convenience functions for generating strings/bytestrings & associated functions

```@docs
UA_BYTESTRING
UA_BYTESTRING_ALLOC
UA_STRING
UA_STRING_ALLOC
```

## Generation of (Expanded)NodeIds & associated functions

```@autodocs
Modules = [Open62541]
Order = [:function]
Filter = t -> startswith(string(t), "UA_NODEID") 
```

```@autodocs
Modules = [Open62541]
Order = [:function]
Filter = t -> startswith(string(t), "UA_EXPANDEDNODEID") 
```

## Attribute generation

Functions that allow generating attributes (used in node creation) in a convenient
fashion:

```@docs
UA_DataTypeAttributes_generate
UA_MethodAttributes_generate
UA_ObjectAttributes_generate
UA_ObjectTypeAttributes_generate
UA_ReferenceTypeAttributes_generate
UA_VariableAttributes_generate
UA_VariableTypeAttributes_generate
UA_ViewAttributes_generate
```

Helper functions for readmasks, valueranks, etc.:

```@docs
UA_ACCESSLEVEL
UA_EVENTNOTIFIER
UA_USERACCESSLEVEL
UA_USERWRITEMASK
UA_VALUERANK
UA_WRITEMASK
```

## Server API

```@autodocs
Modules = [Open62541]
Order = [:function]
Filter = t -> startswith(string(t), "UA_Server_") || startswith(string(t), "UA_ServerConfig")
```

## Client API

```@autodocs
Modules = [Open62541]
Order = [:function]
Filter = t -> startswith(string(t), "UA_Client_") && !contains(string(t), "Async") &&
    !contains(string(t), "async")
```

```@docs
UA_ClientConfig_setAuthenticationUsername
```

## Asynchronous Client API

```@autodocs
Modules = [Open62541]
Order = [:function]
Filter = t -> startswith(string(t), "UA_Client_") && (contains(string(t), "Async") || 
    contains(string(t), "async"))
```

## Callback generation

```@autodocs
Modules = [Open62541]
Pages = ["callbacks.jl"]
```

## Miscellaneous

```@docs
UA_CreateSubscriptionRequest_default
UA_MonitoredItemCreateRequest_default
```
