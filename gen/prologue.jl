using OffsetArrays
using Dates
using EnumX

const UA_INT64_MAX = typemax(Int64)
const UA_INT64_MIN = typemin(Int64)
const UA_UINT64_MAX = typemax(UInt64)
const UA_UINT64_MIN = typemin(UInt64)
const UA_FALSE = false
const UA_TRUE = true

const UA_EMPTY_ARRAY_SENTINEL = convert(Ptr{Nothing}, Int(0x01))
