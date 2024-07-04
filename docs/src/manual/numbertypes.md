# Supported number types

It is noteworthy that the open62541 library supports the following Julia
number types natively. Open62541.jl provides support for the same number types.
Adding other types is possible, but must rely on a custom datatype. See the [open62541 documentation](https://github.com/open62541/open62541/tree/master/examples/custom_datatype).

**Real:**
  - Boolean: Bool
  - Integers: Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64.
  - Float: Float32 and Float64.

**Complex:**

  - Complex{Float32}, Complex{Float64}

**Complex:**

  - Rational{Int32}
  - Rational{UInt32}
