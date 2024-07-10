# Supported number types
It is noteworthy that the open62541 library does not support all number types 
included within Julia natively. Open62541.jl supports the same number types as its
C counterpart. Julia types that are not supported will throw an exception, rather 
than silently performing an automated conversion for you.

If you want to store a Julia type that is not on the list below (for example: 
`Float32`, `Complex{Int64}` or `Rational{Bool}`) in an OPC UA server, you should 
consciously convert it to a supported number type beforehand. 

Furthermore `JUA_Client_readValueAttribute(client, nodeid)` will return numbers 
in one of the supported formats below. You can specify the conversion to be used 
via its typed equivalent if you know a `Float16` value should be returned, you 
can call `JUA_Client_readValueAttribute(client, nodeid, Float16)`. This conversion 
obviously only works if implemented in Julia. 

Adding other number types is possible, but relies on introducing a custom 
datatype. See the [open62541 documentation](https://github.com/open62541/open62541/tree/master/examples/custom_datatype) 
for details about this.

## Real numbers:
  - Boolean: Bool
  - Integers: Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64
  - Float: Float32, Float64
  - Rational: Rational{Int32}, Rational{UInt32}

## Complex numbers:
  - Complex{Float32}
  - Complex{Float64}
