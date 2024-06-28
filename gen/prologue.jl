using Dates
using OffsetArrays
using DocStringExtensions

const UA_INT64_MAX = typemax(Int64)
const UA_INT64_MIN = typemin(Int64)
const UA_UINT64_MAX = typemax(UInt64)
const UA_UINT64_MIN = typemin(UInt64)
const UA_FALSE = false
const UA_TRUE = true
const UA_INT32_MIN = typemin(Int32)
const UA_INT32_MAX = typemax(Int32)
const UA_UINT32_MIN = 0
const UA_UINT32_MAX = typemax(UInt32)
const UA_FLOAT_MIN = typemin(Float32)
const UA_FLOAT_MAX = typemax(Float32)
const UA_DOUBLE_MIN = typemin(Float64)
const UA_DOUBLE_MAX = typemax(Float64)
const UA_EMPTY_ARRAY_SENTINEL = convert(Ptr{Nothing}, Int(0x01))
