module open62541

using open62541_jll
export open62541_jll

using CEnum

using OffsetArrays

const int64_t = Int64
const uint64_t = UInt64
const UA_INT64_MAX = typemax(Int64)
const UA_INT64_MIN = typemin(Int64)
const UA_UINT64_MAX = typemax(UInt64)
const UA_UINT64_MIN = typemin(UInt64)
const UA_FALSE = false
const UA_TRUE = true

const UA_EMPTY_ARRAY_SENTINEL = convert(Ptr{Nothing}, Int(0x01))

const UINT_PTR = Culonglong

const SOCKET = UINT_PTR

"""
Byte ^^^^ An integer value between 0 and 255. 
"""
const UA_Byte = UInt8

"""
    UA_String

String ^^^^^^ A sequence of Unicode characters. Strings are just an array of [`UA_Byte`](@ref). 
"""
struct UA_String
    length::Csize_t
    data::Ptr{UA_Byte}
end

function UA_String_fromChars(src)
    @ccall libopen62541.UA_String_fromChars(src::Cstring)::UA_String
end

"""
UInt16 ^^^^^^ An integer value between 0 and 65 535. 
"""
const UA_UInt16 = UInt16

"""
    UA_NodeIdType

.. \\_nodeid:

NodeId ^^^^^^ An identifier for a node in the address space of an OPC UA Server. 
"""
@cenum UA_NodeIdType::UInt32 begin
    UA_NODEIDTYPE_NUMERIC = 0
    UA_NODEIDTYPE_STRING = 3
    UA_NODEIDTYPE_GUID = 4
    UA_NODEIDTYPE_BYTESTRING = 5
end

struct __JL_Ctag_376
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_376}, f::Symbol)
    f === :numeric && return Ptr{UA_UInt32}(x + 0)
    f === :string && return Ptr{UA_String}(x + 0)
    f === :guid && return Ptr{UA_Guid}(x + 0)
    f === :byteString && return Ptr{UA_ByteString}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_376, f::Symbol)
    r = Ref{__JL_Ctag_376}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_376}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_376}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_NodeId
    namespaceIndex::UA_UInt16
    identifierType::UA_NodeIdType
    identifier::__JL_Ctag_376
end
function Base.getproperty(x::Ptr{UA_NodeId}, f::Symbol)
    f === :namespaceIndex && return Ptr{UA_UInt16}(x + 0)
    f === :identifierType && return Ptr{UA_NodeIdType}(x + 4)
    f === :identifier && return Ptr{__JL_Ctag_376}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_NodeId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


"""
UInt32 ^^^^^^ An integer value between 0 and 4 294 967 295. 
"""
const UA_UInt32 = UInt32

"""
.. \\_types:

Data Types ==========

The OPC UA protocol defines 25 builtin data types and three ways of combining them into higher-order types: arrays, structures and unions. In open62541, only the builtin data types are defined manually. All other data types are generated from standard XML definitions. Their exact definitions can be looked up at https://opcfoundation.org/UA/schemas/Opc.Ua.Types.bsd.

For users that are new to open62541, take a look at the :ref:`tutorial for working with data types<types-tutorial>` before diving into the implementation details.

Builtin Types -------------

Boolean ^^^^^^^ A two-state logical value (true or false). 
"""
const UA_Boolean = Bool

"""
    UA_DataTypeMember

.. \\_generic-types:

Generic Type Handling ---------------------

All information about a (builtin/structured) data type is stored in a `[`UA_DataType`](@ref)`. The array ``UA_TYPES`` contains the description of all standard-defined types. This type description is used for the following generic operations that work on all types:

- ``void T\\_init(T *ptr)``: Initialize the data type. This is synonymous with zeroing out the memory, i.e. ``memset(ptr, 0, sizeof(T))``. - ``T* T\\_new()``: Allocate and return the memory for the data type. The value is already initialized. - ``[`UA_StatusCode`](@ref) T\\_copy(const T *src, T *dst)``: Copy the content of the data type. Returns `[`UA_STATUSCODE_GOOD`](@ref)` or `[`UA_STATUSCODE_BADOUTOFMEMORY`](@ref)`. - ``void T\\_clear(T *ptr)``: Delete the dynamically allocated content of the data type and perform a ``T_init`` to reset the type. - ``void T\\_delete(T *ptr)``: Delete the content of the data type and the memory for the data type itself.

Specializations, such as ``[`UA_Int32_new`](@ref)()`` are derived from the generic type operations as static inline functions. 
"""
struct UA_DataTypeMember
    memberTypeIndex::UA_UInt16
    padding::UA_Byte
    namespaceZero::UA_Boolean
    isArray::UA_Boolean
    isOptional::UA_Boolean
    memberName::Cstring
end

"""
    UA_DataType

.. \\_variant:

Variant ^^^^^^^

Variants may contain values of any type together with a description of the content. See the section on :ref:`generic-types` on how types are described. The standard mandates that variants contain built-in data types only. If the value is not of a builtin type, it is wrapped into an :ref:`extensionobject`. open62541 hides this wrapping transparently in the encoding layer. If the data type is unknown to the receiver, the variant contains the original ExtensionObject in binary or XML encoding.

Variants may contain a scalar value or an array. For details on the handling of arrays, see the section on :ref:`array-handling`. Array variants can have an additional dimensionality (matrix, 3-tensor, ...) defined in an array of dimension lengths. The actual values are kept in an array of dimensions one. For users who work with higher-dimensions arrays directly, keep in mind that dimensions of higher rank are serialized first (the highest rank dimension has stride 1 and elements follow each other directly). Usually it is simplest to interact with higher-dimensional arrays via `[`UA_NumericRange`](@ref)` descriptions (see :ref:`array-handling`).

To differentiate between scalar / array variants, the following definition is used. `[`UA_Variant_isScalar`](@ref)` provides simplified access to these checks.

- ``arrayLength == 0 && data == NULL``: undefined array of length -1 - ``arrayLength == 0 && data == [`UA_EMPTY_ARRAY_SENTINEL`](@ref)``: array of length 0 - ``arrayLength == 0 && data > [`UA_EMPTY_ARRAY_SENTINEL`](@ref)``: scalar value - ``arrayLength > 0``: array of the given length

Variants can also be *empty*. Then, the pointer to the type description is ``NULL``. 
"""
struct UA_DataType
    data::NTuple{72, UInt8}
end

function Base.getproperty(x::Ptr{UA_DataType}, f::Symbol)
    f === :typeId && return Ptr{UA_NodeId}(x + 0)
    f === :binaryEncodingId && return Ptr{UA_NodeId}(x + 24)
    f === :memSize && return Ptr{UA_UInt16}(x + 48)
    f === :typeIndex && return Ptr{UA_UInt16}(x + 50)
    f === :typeKind && return (Ptr{UA_UInt32}(x + 52), 0, 6)
    f === :pointerFree && return (Ptr{UA_UInt32}(x + 52), 6, 1)
    f === :overlayable && return (Ptr{UA_UInt32}(x + 52), 7, 1)
    f === :membersSize && return (Ptr{UA_UInt32}(x + 52), 8, 8)
    f === :members && return Ptr{Ptr{UA_DataTypeMember}}(x + 56)
    f === :typeName && return Ptr{Cstring}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataType, f::Symbol)
    r = Ref{UA_DataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataType}, r)
    fptr = getproperty(ptr, f)
    begin
        if fptr isa Ptr
            return GC.@preserve(r, unsafe_load(fptr))
        else
            (baseptr, offset, width) = fptr
            ty = eltype(baseptr)
            baseptr32 = convert(Ptr{UInt32}, baseptr)
            u64 = GC.@preserve(r, unsafe_load(baseptr32))
            if offset + width > 32
                u64 |= GC.@preserve(r, unsafe_load(baseptr32 + 4)) << 32
            end
            u64 = u64 >> offset & (1 << width - 1)
            return u64 % ty
        end
    end
end

function Base.setproperty!(x::Ptr{UA_DataType}, f::Symbol, v)
    fptr = getproperty(x, f)
    if fptr isa Ptr
        unsafe_store!(getproperty(x, f), v)
    else
        (baseptr, offset, width) = fptr
        baseptr32 = convert(Ptr{UInt32}, baseptr)
        u64 = unsafe_load(baseptr32)
        straddle = offset + width > 32
        if straddle
            u64 |= unsafe_load(baseptr32 + 4) << 32
        end
        mask = 1 << width - 1
        u64 &= ~(mask << offset)
        u64 |= (unsigned(v) & mask) << offset
        unsafe_store!(baseptr32, u64 & typemax(UInt32))
        if straddle
            unsafe_store!(baseptr32 + 4, u64 >> 32)
        end
    end
end

function UA_clear(p, type)
    @ccall libopen62541.UA_clear(p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

"""
Int32 ^^^^^ An integer value between -2 147 483 648 and 2 147 483 647. 
"""
const UA_Int32 = Int32

@cenum UA_ValueBackendType::UInt32 begin
    UA_VALUEBACKENDTYPE_NONE = 0
    UA_VALUEBACKENDTYPE_INTERNAL = 1
    UA_VALUEBACKENDTYPE_DATA_SOURCE_CALLBACK = 2
    UA_VALUEBACKENDTYPE_EXTERNAL = 3
end

struct __JL_Ctag_371
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_371}, f::Symbol)
    f === :internal && return Ptr{__JL_Ctag_372}(x + 0)
    f === :dataSource && return Ptr{UA_DataSource}(x + 0)
    f === :external && return Ptr{__JL_Ctag_373}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_371, f::Symbol)
    r = Ref{__JL_Ctag_371}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_371}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_371}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_ValueBackend
    backendType::UA_ValueBackendType
    backend::__JL_Ctag_371
end

"""
    UA_ValueSource

VariableNode ------------

Variables store values in a :ref:`datavalue` together with metadata for introspection. Most notably, the attributes data type, value rank and array dimensions constrain the possible values the variable can take on.

Variables come in two flavours: properties and datavariables. Properties are related to a parent with a ``hasProperty`` reference and may not have child nodes themselves. Datavariables may contain properties (``hasProperty``) and also datavariables (``hasComponents``).

All variables are instances of some :ref:`variabletypenode` in return constraining the possible data type, value rank and array dimensions attributes.

Data Type ~~~~~~~~~

The (scalar) data type of the variable is constrained to be of a specific type or one of its children in the type hierarchy. The data type is given as a NodeId pointing to a :ref:`datatypenode` in the type hierarchy. See the Section :ref:`datatypenode` for more details.

If the data type attribute points to ``UInt32``, then the value attribute must be of that exact type since ``UInt32`` does not have children in the type hierarchy. If the data type attribute points ``Number``, then the type of the value attribute may still be ``UInt32``, but also ``Float`` or ``Byte``.

Consistency between the data type attribute in the variable and its :ref:`VariableTypeNode` is ensured.

Value Rank ~~~~~~~~~~

This attribute indicates whether the value attribute of the variable is an array and how many dimensions the array has. It may have the following values:

- ``n >= 1``: the value is an array with the specified number of dimensions - ``n = 0``: the value is an array with one or more dimensions - ``n = -1``: the value is a scalar - ``n = -2``: the value can be a scalar or an array with any number of dimensions - ``n = -3``: the value can be a scalar or a one dimensional array

Consistency between the value rank attribute in the variable and its :ref:`variabletypenode` is ensured.

Array Dimensions ~~~~~~~~~~~~~~~~

If the value rank permits the value to be a (multi-dimensional) array, the exact length in each dimensions can be further constrained with this attribute.

- For positive lengths, the variable value is guaranteed to be of the same length in this dimension. - The dimension length zero is a wildcard and the actual value may have any length in this dimension.

Consistency between the array dimensions attribute in the variable and its :ref:`variabletypenode` is ensured. 
"""
@cenum UA_ValueSource::UInt32 begin
    UA_VALUESOURCE_DATA = 0
    UA_VALUESOURCE_DATASOURCE = 1
end

@cenum UA_VariantStorageType::UInt32 begin
    UA_VARIANT_DATA = 0
    UA_VARIANT_DATA_NODELETE = 1
end

struct UA_Variant
    type::Ptr{UA_DataType}
    storageType::UA_VariantStorageType
    arrayLength::Csize_t
    data::Ptr{Cvoid}
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
end

"""
.. \\_datetime:

DateTime ^^^^^^^^ An instance in time. A DateTime value is encoded as a 64-bit signed integer which represents the number of 100 nanosecond intervals since January 1, 1601 (UTC).

The methods providing an interface to the system clock are architecture- specific. Usually, they provide a UTC clock that includes leap seconds. The OPC UA standard allows the use of International Atomic Time (TAI) for the DateTime instead. But this is still unusual and not implemented for most SDKs. Currently (2019), UTC and TAI are 37 seconds apart due to leap seconds. 
"""
const UA_DateTime = Int64

"""
.. \\_statuscode:

StatusCode ^^^^^^^^^^ A numeric identifier for a error or condition that is associated with a value or an operation. See the section :ref:`statuscodes` for the meaning of a specific code. 
"""
const UA_StatusCode = UInt32

"""
    UA_DataValue

.. \\_datavalue:

DataValue ^^^^^^^^^ A data value with an associated status code and timestamps. 
"""
struct UA_DataValue
    value::UA_Variant
    sourceTimestamp::UA_DateTime
    serverTimestamp::UA_DateTime
    sourcePicoseconds::UA_UInt16
    serverPicoseconds::UA_UInt16
    status::UA_StatusCode
    hasValue::UA_Boolean
    hasStatus::UA_Boolean
    hasSourceTimestamp::UA_Boolean
    hasServerTimestamp::UA_Boolean
    hasSourcePicoseconds::UA_Boolean
    hasServerPicoseconds::UA_Boolean
end

struct UA_ValueCallback
    onRead::Ptr{Cvoid}
    onWrite::Ptr{Cvoid}
end

struct UA_DataSource
    read::Ptr{Cvoid}
    write::Ptr{Cvoid}
end

"""
Forward Declarations -------------------- Opaque oointers used by the plugins. 
"""
mutable struct UA_Server end

"""
UInt64 ^^^^^^ An integer value between 0 and 18 446 744 073 709 551 615. 
"""
const UA_UInt64 = UInt64

function UA_Server_removeCallback(server, callbackId)
    @ccall libopen62541.UA_Server_removeCallback(server::Ptr{UA_Server}, callbackId::UA_UInt64)::Cvoid
end

struct static_assertion_failed_0
    static_assertion_failed_cannot_overlay_integers_with_large_bool::Cint
end

"""
    UA_AttributeId

Common Definitions ==================

Common definitions for Client, Server and PubSub.

.. \\_attribute-id:

Attribute Id ------------ Every node in an OPC UA information model contains attributes depending on the node type. Possible attributes are as follows: 
"""
@cenum UA_AttributeId::UInt32 begin
    UA_ATTRIBUTEID_NODEID = 1
    UA_ATTRIBUTEID_NODECLASS = 2
    UA_ATTRIBUTEID_BROWSENAME = 3
    UA_ATTRIBUTEID_DISPLAYNAME = 4
    UA_ATTRIBUTEID_DESCRIPTION = 5
    UA_ATTRIBUTEID_WRITEMASK = 6
    UA_ATTRIBUTEID_USERWRITEMASK = 7
    UA_ATTRIBUTEID_ISABSTRACT = 8
    UA_ATTRIBUTEID_SYMMETRIC = 9
    UA_ATTRIBUTEID_INVERSENAME = 10
    UA_ATTRIBUTEID_CONTAINSNOLOOPS = 11
    UA_ATTRIBUTEID_EVENTNOTIFIER = 12
    UA_ATTRIBUTEID_VALUE = 13
    UA_ATTRIBUTEID_DATATYPE = 14
    UA_ATTRIBUTEID_VALUERANK = 15
    UA_ATTRIBUTEID_ARRAYDIMENSIONS = 16
    UA_ATTRIBUTEID_ACCESSLEVEL = 17
    UA_ATTRIBUTEID_USERACCESSLEVEL = 18
    UA_ATTRIBUTEID_MINIMUMSAMPLINGINTERVAL = 19
    UA_ATTRIBUTEID_HISTORIZING = 20
    UA_ATTRIBUTEID_EXECUTABLE = 21
    UA_ATTRIBUTEID_USEREXECUTABLE = 22
    UA_ATTRIBUTEID_DATATYPEDEFINITION = 23
    UA_ATTRIBUTEID_ROLEPERMISSIONS = 24
    UA_ATTRIBUTEID_USERROLEPERMISSIONS = 25
    UA_ATTRIBUTEID_ACCESSRESTRICTIONS = 26
    UA_ATTRIBUTEID_ACCESSLEVELEX = 27
end

"""
    UA_RuleHandling

Rule Handling -------------

The RuleHanding settings define how error cases that result from rules in the OPC UA specification shall be handled. The rule handling can be softened, e.g. to workaround misbehaving implementations or to mitigate the impact of additional rules that are introduced in later versions of the OPC UA specification. 
"""
@cenum UA_RuleHandling::UInt32 begin
    UA_RULEHANDLING_DEFAULT = 0
    UA_RULEHANDLING_ABORT = 1
    UA_RULEHANDLING_WARN = 2
    UA_RULEHANDLING_ACCEPT = 3
end

"""
    UA_Order

Order -----

The Order enum is used to establish an absolute ordering between elements.
"""
@cenum UA_Order::Int32 begin
    UA_ORDER_LESS = -1
    UA_ORDER_EQ = 0
    UA_ORDER_MORE = 1
end

"""
    UA_SecureChannelState

Connection State ---------------- 
"""
@cenum UA_SecureChannelState::UInt32 begin
    UA_SECURECHANNELSTATE_FRESH = 0
    UA_SECURECHANNELSTATE_HEL_SENT = 1
    UA_SECURECHANNELSTATE_HEL_RECEIVED = 2
    UA_SECURECHANNELSTATE_ACK_SENT = 3
    UA_SECURECHANNELSTATE_ACK_RECEIVED = 4
    UA_SECURECHANNELSTATE_OPN_SENT = 5
    UA_SECURECHANNELSTATE_OPEN = 6
    UA_SECURECHANNELSTATE_CLOSING = 7
    UA_SECURECHANNELSTATE_CLOSED = 8
end

@cenum UA_SessionState::UInt32 begin
    UA_SESSIONSTATE_CLOSED = 0
    UA_SESSIONSTATE_CREATE_REQUESTED = 1
    UA_SESSIONSTATE_CREATED = 2
    UA_SESSIONSTATE_ACTIVATE_REQUESTED = 3
    UA_SESSIONSTATE_ACTIVATED = 4
    UA_SESSIONSTATE_CLOSING = 5
end

"""
    UA_NetworkStatistics

Statistic counters ------------------

The stack manage statistic counter for the following layers:

- Network - Secure channel - Session

The session layer counters are matching the counters of the ServerDiagnosticsSummaryDataType that are defined in the OPC UA Part 5 specification. Counter of the other layers are not specified by OPC UA but are harmonized with the session layer counters if possible. 
"""
struct UA_NetworkStatistics
    currentConnectionCount::Csize_t
    cumulatedConnectionCount::Csize_t
    rejectedConnectionCount::Csize_t
    connectionTimeoutCount::Csize_t
    connectionAbortCount::Csize_t
end

struct UA_SecureChannelStatistics
    currentChannelCount::Csize_t
    cumulatedChannelCount::Csize_t
    rejectedChannelCount::Csize_t
    channelTimeoutCount::Csize_t
    channelAbortCount::Csize_t
    channelPurgeCount::Csize_t
end

struct UA_SessionStatistics
    currentSessionCount::Csize_t
    cumulatedSessionCount::Csize_t
    securityRejectedSessionCount::Csize_t
    rejectedSessionCount::Csize_t
    sessionTimeoutCount::Csize_t
    sessionAbortCount::Csize_t
end

"""
SByte ^^^^^ An integer value between -128 and 127. 
"""
const UA_SByte = Int8

"""
Int16 ^^^^^ An integer value between -32 768 and 32 767. 
"""
const UA_Int16 = Int16

"""
Int64 ^^^^^ An integer value between -9 223 372 036 854 775 808 and 9 223 372 036 854 775 807. 
"""
const UA_Int64 = Int64

"""
Float ^^^^^ An IEEE single precision (32 bit) floating point value. 
"""
const UA_Float = Cfloat

"""
Double ^^^^^^ An IEEE double precision (64 bit) floating point value. 
"""
const UA_Double = Cdouble

function UA_StatusCode_name(code)
    @ccall libopen62541.UA_StatusCode_name(code::UA_StatusCode)::Cstring
end

function UA_String_equal(s1, s2)
    @ccall libopen62541.UA_String_equal(s1::Ptr{UA_String}, s2::Ptr{UA_String})::UA_Boolean
end

function UA_DateTime_now()
    @ccall libopen62541.UA_DateTime_now()::UA_DateTime
end

function UA_DateTime_localTimeUtcOffset()
    @ccall libopen62541.UA_DateTime_localTimeUtcOffset()::UA_Int64
end

function UA_DateTime_nowMonotonic()
    @ccall libopen62541.UA_DateTime_nowMonotonic()::UA_DateTime
end

struct UA_DateTimeStruct
    nanoSec::UA_UInt16
    microSec::UA_UInt16
    milliSec::UA_UInt16
    sec::UA_UInt16
    min::UA_UInt16
    hour::UA_UInt16
    day::UA_UInt16
    month::UA_UInt16
    year::UA_UInt16
end

function UA_DateTime_toStruct(t)
    @ccall libopen62541.UA_DateTime_toStruct(t::UA_DateTime)::UA_DateTimeStruct
end

function UA_DateTime_fromStruct(ts)
    @ccall libopen62541.UA_DateTime_fromStruct(ts::UA_DateTimeStruct)::UA_DateTime
end

"""
    UA_Guid

Guid ^^^^ A 16 byte value that can be used as a globally unique identifier. 
"""
struct UA_Guid
    data1::UA_UInt32
    data2::UA_UInt16
    data3::UA_UInt16
    data4::NTuple{8, UA_Byte}
end

function UA_Guid_equal(g1, g2)
    @ccall libopen62541.UA_Guid_equal(g1::Ptr{UA_Guid}, g2::Ptr{UA_Guid})::UA_Boolean
end

function UA_Guid_parse(guid, str)
    @ccall libopen62541.UA_Guid_parse(guid::Ptr{UA_Guid}, str::UA_String)::UA_StatusCode
end

"""
ByteString ^^^^^^^^^^ A sequence of octets. 
"""
const UA_ByteString = UA_String

function UA_ByteString_allocBuffer(bs, length)
    @ccall libopen62541.UA_ByteString_allocBuffer(bs::Ptr{UA_ByteString}, length::Csize_t)::UA_StatusCode
end

function UA_ByteString_toBase64(bs, output)
    @ccall libopen62541.UA_ByteString_toBase64(bs::Ptr{UA_ByteString}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_ByteString_fromBase64(bs, input)
    @ccall libopen62541.UA_ByteString_fromBase64(bs::Ptr{UA_ByteString}, input::Ptr{UA_String})::UA_StatusCode
end

function UA_ByteString_hash(initialHashValue, data, size)
    @ccall libopen62541.UA_ByteString_hash(initialHashValue::UA_UInt32, data::Ptr{UA_Byte}, size::Csize_t)::UA_UInt32
end

"""
XmlElement ^^^^^^^^^^ An XML element. 
"""
const UA_XmlElement = UA_String

function UA_NodeId_isNull(p)
    @ccall libopen62541.UA_NodeId_isNull(p::Ptr{UA_NodeId})::UA_Boolean
end

function UA_NodeId_print(id, output)
    @ccall libopen62541.UA_NodeId_print(id::Ptr{UA_NodeId}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_NodeId_parse(id, str)
    @ccall libopen62541.UA_NodeId_parse(id::Ptr{UA_NodeId}, str::UA_String)::UA_StatusCode
end

function UA_NodeId_order(n1, n2)
    @ccall libopen62541.UA_NodeId_order(n1::Ptr{UA_NodeId}, n2::Ptr{UA_NodeId})::UA_Order
end

function UA_NodeId_hash(n)
    @ccall libopen62541.UA_NodeId_hash(n::Ptr{UA_NodeId})::UA_UInt32
end

"""
    UA_ExpandedNodeId

ExpandedNodeId ^^^^^^^^^^^^^^ A NodeId that allows the namespace URI to be specified instead of an index. 
"""
struct UA_ExpandedNodeId
    nodeId::UA_NodeId
    namespaceUri::UA_String
    serverIndex::UA_UInt32
end

function UA_ExpandedNodeId_print(id, output)
    @ccall libopen62541.UA_ExpandedNodeId_print(id::Ptr{UA_ExpandedNodeId}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_ExpandedNodeId_parse(id, str)
    @ccall libopen62541.UA_ExpandedNodeId_parse(id::Ptr{UA_ExpandedNodeId}, str::UA_String)::UA_StatusCode
end

function UA_ExpandedNodeId_isLocal(n)
    @ccall libopen62541.UA_ExpandedNodeId_isLocal(n::Ptr{UA_ExpandedNodeId})::UA_Boolean
end

function UA_ExpandedNodeId_order(n1, n2)
    @ccall libopen62541.UA_ExpandedNodeId_order(n1::Ptr{UA_ExpandedNodeId}, n2::Ptr{UA_ExpandedNodeId})::UA_Order
end

function UA_ExpandedNodeId_hash(n)
    @ccall libopen62541.UA_ExpandedNodeId_hash(n::Ptr{UA_ExpandedNodeId})::UA_UInt32
end

"""
    UA_QualifiedName

.. \\_qualifiedname:

QualifiedName ^^^^^^^^^^^^^ A name qualified by a namespace. 
"""
struct UA_QualifiedName
    namespaceIndex::UA_UInt16
    name::UA_String
end

function UA_QualifiedName_hash(q)
    @ccall libopen62541.UA_QualifiedName_hash(q::Ptr{UA_QualifiedName})::UA_UInt32
end

function UA_QualifiedName_equal(qn1, qn2)
    @ccall libopen62541.UA_QualifiedName_equal(qn1::Ptr{UA_QualifiedName}, qn2::Ptr{UA_QualifiedName})::UA_Boolean
end

"""
    UA_LocalizedText

LocalizedText ^^^^^^^^^^^^^ Human readable text with an optional locale identifier. 
"""
struct UA_LocalizedText
    locale::UA_String
    text::UA_String
end

function UA_StatusCode_isBad(code)
    @ccall libopen62541.UA_StatusCode_isBad(code::UA_StatusCode)::UA_Boolean
end

"""
    UA_NumericRangeDimension

.. \\_numericrange:

NumericRange ^^^^^^^^^^^^

NumericRanges are used to indicate subsets of a (multidimensional) array. They no official data type in the OPC UA standard and are transmitted only with a string encoding, such as "1:2,0:3,5". The colon separates min/max index and the comma separates dimensions. A single value indicates a range with a single element (min==max). 
"""
struct UA_NumericRangeDimension
    min::UA_UInt32
    max::UA_UInt32
end

struct UA_NumericRange
    dimensionsSize::Csize_t
    dimensions::Ptr{UA_NumericRangeDimension}
end

function UA_NumericRange_parse(range, str)
    @ccall libopen62541.UA_NumericRange_parse(range::Ptr{UA_NumericRange}, str::UA_String)::UA_StatusCode
end

function UA_Variant_setScalar(v, p, type)
    @ccall libopen62541.UA_Variant_setScalar(v::Ptr{UA_Variant}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_Variant_setScalarCopy(v, p, type)
    @ccall libopen62541.UA_Variant_setScalarCopy(v::Ptr{UA_Variant}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Variant_setArray(v, array, arraySize, type)
    @ccall libopen62541.UA_Variant_setArray(v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t, type::Ptr{UA_DataType})::Cvoid
end

function UA_Variant_setArrayCopy(v, array, arraySize, type)
    @ccall libopen62541.UA_Variant_setArrayCopy(v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Variant_copyRange(src, dst, range)
    @ccall libopen62541.UA_Variant_copyRange(src::Ptr{UA_Variant}, dst::Ptr{UA_Variant}, range::UA_NumericRange)::UA_StatusCode
end

function UA_Variant_setRange(v, array, arraySize, range)
    @ccall libopen62541.UA_Variant_setRange(v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t, range::UA_NumericRange)::UA_StatusCode
end

function UA_Variant_setRangeCopy(v, array, arraySize, range)
    @ccall libopen62541.UA_Variant_setRangeCopy(v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t, range::UA_NumericRange)::UA_StatusCode
end

"""
    UA_ExtensionObjectEncoding

.. \\_extensionobject:

ExtensionObject ^^^^^^^^^^^^^^^

ExtensionObjects may contain scalars of any data type. Even those that are unknown to the receiver. See the section on :ref:`generic-types` on how types are described. If the received data type is unknown, the encoded string and target NodeId is stored instead of the decoded value. 
"""
@cenum UA_ExtensionObjectEncoding::UInt32 begin
    UA_EXTENSIONOBJECT_ENCODED_NOBODY = 0
    UA_EXTENSIONOBJECT_ENCODED_BYTESTRING = 1
    UA_EXTENSIONOBJECT_ENCODED_XML = 2
    UA_EXTENSIONOBJECT_DECODED = 3
    UA_EXTENSIONOBJECT_DECODED_NODELETE = 4
end

struct __JL_Ctag_368
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_368}, f::Symbol)
    f === :encoded && return Ptr{__JL_Ctag_369}(x + 0)
    f === :decoded && return Ptr{__JL_Ctag_370}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_368, f::Symbol)
    r = Ref{__JL_Ctag_368}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_368}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_368}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_ExtensionObject
    encoding::UA_ExtensionObjectEncoding
    content::__JL_Ctag_368
end

function UA_ExtensionObject_setValue(eo, p, type)
    @ccall libopen62541.UA_ExtensionObject_setValue(eo::Ptr{UA_ExtensionObject}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_ExtensionObject_setValueNoDelete(eo, p, type)
    @ccall libopen62541.UA_ExtensionObject_setValueNoDelete(eo::Ptr{UA_ExtensionObject}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_ExtensionObject_setValueCopy(eo, p, type)
    @ccall libopen62541.UA_ExtensionObject_setValueCopy(eo::Ptr{UA_ExtensionObject}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

"""
    UA_DiagnosticInfo

DiagnosticInfo ^^^^^^^^^^^^^^ A structure that contains detailed error and diagnostic information associated with a StatusCode. 
"""
struct UA_DiagnosticInfo
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{UA_DiagnosticInfo}, f::Symbol)
    f === :hasSymbolicId && return (Ptr{UA_Boolean}(x + 0), 0, 1)
    f === :hasNamespaceUri && return (Ptr{UA_Boolean}(x + 0), 1, 1)
    f === :hasLocalizedText && return (Ptr{UA_Boolean}(x + 0), 2, 1)
    f === :hasLocale && return (Ptr{UA_Boolean}(x + 0), 3, 1)
    f === :hasAdditionalInfo && return (Ptr{UA_Boolean}(x + 0), 4, 1)
    f === :hasInnerStatusCode && return (Ptr{UA_Boolean}(x + 0), 5, 1)
    f === :hasInnerDiagnosticInfo && return (Ptr{UA_Boolean}(x + 0), 6, 1)
    f === :symbolicId && return Ptr{UA_Int32}(x + 4)
    f === :namespaceUri && return Ptr{UA_Int32}(x + 8)
    f === :localizedText && return Ptr{UA_Int32}(x + 12)
    f === :locale && return Ptr{UA_Int32}(x + 16)
    f === :additionalInfo && return Ptr{UA_String}(x + 24)
    f === :innerStatusCode && return Ptr{UA_StatusCode}(x + 40)
    f === :innerDiagnosticInfo && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DiagnosticInfo, f::Symbol)
    r = Ref{UA_DiagnosticInfo}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DiagnosticInfo}, r)
    fptr = getproperty(ptr, f)
    begin
        if fptr isa Ptr
            return GC.@preserve(r, unsafe_load(fptr))
        else
            (baseptr, offset, width) = fptr
            ty = eltype(baseptr)
            baseptr32 = convert(Ptr{UInt32}, baseptr)
            u64 = GC.@preserve(r, unsafe_load(baseptr32))
            if offset + width > 32
                u64 |= GC.@preserve(r, unsafe_load(baseptr32 + 4)) << 32
            end
            u64 = u64 >> offset & (1 << width - 1)
            return u64 % ty
        end
    end
end

function Base.setproperty!(x::Ptr{UA_DiagnosticInfo}, f::Symbol, v)
    fptr = getproperty(x, f)
    if fptr isa Ptr
        unsafe_store!(getproperty(x, f), v)
    else
        (baseptr, offset, width) = fptr
        baseptr32 = convert(Ptr{UInt32}, baseptr)
        u64 = unsafe_load(baseptr32)
        straddle = offset + width > 32
        if straddle
            u64 |= unsafe_load(baseptr32 + 4) << 32
        end
        mask = 1 << width - 1
        u64 &= ~(mask << offset)
        u64 |= (unsigned(v) & mask) << offset
        unsafe_store!(baseptr32, u64 & typemax(UInt32))
        if straddle
            unsafe_store!(baseptr32 + 4, u64 >> 32)
        end
    end
end

@cenum UA_DataTypeKind::UInt32 begin
    UA_DATATYPEKIND_BOOLEAN = 0
    UA_DATATYPEKIND_SBYTE = 1
    UA_DATATYPEKIND_BYTE = 2
    UA_DATATYPEKIND_INT16 = 3
    UA_DATATYPEKIND_UINT16 = 4
    UA_DATATYPEKIND_INT32 = 5
    UA_DATATYPEKIND_UINT32 = 6
    UA_DATATYPEKIND_INT64 = 7
    UA_DATATYPEKIND_UINT64 = 8
    UA_DATATYPEKIND_FLOAT = 9
    UA_DATATYPEKIND_DOUBLE = 10
    UA_DATATYPEKIND_STRING = 11
    UA_DATATYPEKIND_DATETIME = 12
    UA_DATATYPEKIND_GUID = 13
    UA_DATATYPEKIND_BYTESTRING = 14
    UA_DATATYPEKIND_XMLELEMENT = 15
    UA_DATATYPEKIND_NODEID = 16
    UA_DATATYPEKIND_EXPANDEDNODEID = 17
    UA_DATATYPEKIND_STATUSCODE = 18
    UA_DATATYPEKIND_QUALIFIEDNAME = 19
    UA_DATATYPEKIND_LOCALIZEDTEXT = 20
    UA_DATATYPEKIND_EXTENSIONOBJECT = 21
    UA_DATATYPEKIND_DATAVALUE = 22
    UA_DATATYPEKIND_VARIANT = 23
    UA_DATATYPEKIND_DIAGNOSTICINFO = 24
    UA_DATATYPEKIND_DECIMAL = 25
    UA_DATATYPEKIND_ENUM = 26
    UA_DATATYPEKIND_STRUCTURE = 27
    UA_DATATYPEKIND_OPTSTRUCT = 28
    UA_DATATYPEKIND_UNION = 29
    UA_DATATYPEKIND_BITFIELDCLUSTER = 30
end

function UA_DataType_isNumeric(type)
    @ccall libopen62541.UA_DataType_isNumeric(type::Ptr{UA_DataType})::UA_Boolean
end

"""
    UA_findDataType(typeId)

Builtin data types can be accessed as UA\\_TYPES[UA\\_TYPES\\_XXX], where XXX is the name of the data type. If only the NodeId of a type is known, use the following method to retrieve the data type description. 
"""
function UA_findDataType(typeId)
    @ccall libopen62541.UA_findDataType(typeId::Ptr{UA_NodeId})::Ptr{UA_DataType}
end

function UA_new(type)
    @ccall libopen62541.UA_new(type::Ptr{UA_DataType})::Ptr{Cvoid}
end

function UA_copy(src, dst, type)
    @ccall libopen62541.UA_copy(src::Ptr{Cvoid}, dst::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_delete(p, type)
    @ccall libopen62541.UA_delete(p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_print(p, type, output)
    @ccall libopen62541.UA_print(p::Ptr{Cvoid}, type::Ptr{UA_DataType}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_Array_new(size, type)
    @ccall libopen62541.UA_Array_new(size::Csize_t, type::Ptr{UA_DataType})::Ptr{Cvoid}
end

function UA_Array_copy(src, size, dst, type)
    @ccall libopen62541.UA_Array_copy(src::Ptr{Cvoid}, size::Csize_t, dst::Ptr{Ptr{Cvoid}}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Array_delete(p, size, type)
    @ccall libopen62541.UA_Array_delete(p::Ptr{Cvoid}, size::Csize_t, type::Ptr{UA_DataType})::Cvoid
end

"""
    UA_random_seed(seed)

Random Number Generator ----------------------- If [`UA_MULTITHREADING`](@ref) is defined, then the seed is stored in thread local storage. The seed is initialized for every thread in the server/client. 
"""
function UA_random_seed(seed)
    @ccall libopen62541.UA_random_seed(seed::UA_UInt64)::Cvoid
end

function UA_UInt32_random()
    @ccall libopen62541.UA_UInt32_random()::UA_UInt32
end

function UA_Guid_random()
    @ccall libopen62541.UA_Guid_random()::UA_Guid
end

struct UA_DataTypeArray
    next::Ptr{UA_DataTypeArray}
    typesSize::Csize_t
    types::Ptr{UA_DataType}
end

"""
    UA_ViewAttributes

ViewAttributes ^^^^^^^^^^^^^^ The attributes for a view node. 
"""
struct UA_ViewAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    containsNoLoops::UA_Boolean
    eventNotifier::UA_Byte
end

"""
    UA_XVType

XVType ^^^^^^
"""
struct UA_XVType
    x::UA_Double
    value::UA_Float
end

"""
    UA_ElementOperand

ElementOperand ^^^^^^^^^^^^^^
"""
struct UA_ElementOperand
    index::UA_UInt32
end

"""
    UA_VariableAttributes

VariableAttributes ^^^^^^^^^^^^^^^^^^ The attributes for a variable node. 
"""
struct UA_VariableAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    value::UA_Variant
    dataType::UA_NodeId
    valueRank::UA_Int32
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
    accessLevel::UA_Byte
    userAccessLevel::UA_Byte
    minimumSamplingInterval::UA_Double
    historizing::UA_Boolean
end

"""
    UA_EnumValueType

EnumValueType ^^^^^^^^^^^^^ A mapping between a value of an enumerated type and a name and description. 
"""
struct UA_EnumValueType
    value::UA_Int64
    displayName::UA_LocalizedText
    description::UA_LocalizedText
end

"""
    UA_EventFieldList

EventFieldList ^^^^^^^^^^^^^^
"""
struct UA_EventFieldList
    clientHandle::UA_UInt32
    eventFieldsSize::Csize_t
    eventFields::Ptr{UA_Variant}
end

"""
    UA_MonitoredItemCreateResult

MonitoredItemCreateResult ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_MonitoredItemCreateResult
    statusCode::UA_StatusCode
    monitoredItemId::UA_UInt32
    revisedSamplingInterval::UA_Double
    revisedQueueSize::UA_UInt32
    filterResult::UA_ExtensionObject
end

"""
    UA_EUInformation

EUInformation ^^^^^^^^^^^^^
"""
struct UA_EUInformation
    namespaceUri::UA_String
    unitId::UA_Int32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
end

"""
    UA_ServerDiagnosticsSummaryDataType

ServerDiagnosticsSummaryDataType ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ServerDiagnosticsSummaryDataType
    serverViewCount::UA_UInt32
    currentSessionCount::UA_UInt32
    cumulatedSessionCount::UA_UInt32
    securityRejectedSessionCount::UA_UInt32
    rejectedSessionCount::UA_UInt32
    sessionTimeoutCount::UA_UInt32
    sessionAbortCount::UA_UInt32
    currentSubscriptionCount::UA_UInt32
    cumulatedSubscriptionCount::UA_UInt32
    publishingIntervalCount::UA_UInt32
    securityRejectedRequestsCount::UA_UInt32
    rejectedRequestsCount::UA_UInt32
end

"""
    UA_ContentFilterElementResult

ContentFilterElementResult ^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ContentFilterElementResult
    statusCode::UA_StatusCode
    operandStatusCodesSize::Csize_t
    operandStatusCodes::Ptr{UA_StatusCode}
    operandDiagnosticInfosSize::Csize_t
    operandDiagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_LiteralOperand

LiteralOperand ^^^^^^^^^^^^^^
"""
struct UA_LiteralOperand
    value::UA_Variant
end

"""
    UA_MessageSecurityMode

MessageSecurityMode ^^^^^^^^^^^^^^^^^^^ The type of security to use on a message. 
"""
@cenum UA_MessageSecurityMode::UInt32 begin
    UA_MESSAGESECURITYMODE_INVALID = 0
    UA_MESSAGESECURITYMODE_NONE = 1
    UA_MESSAGESECURITYMODE_SIGN = 2
    UA_MESSAGESECURITYMODE_SIGNANDENCRYPT = 3
    __UA_MESSAGESECURITYMODE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_1
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
UtcTime ^^^^^^^ A date/time value specified in Universal Coordinated Time (UTC). 
"""
const UA_UtcTime = UA_DateTime

"""
    UA_UserIdentityToken

UserIdentityToken ^^^^^^^^^^^^^^^^^ A base type for a user identity token. 
"""
struct UA_UserIdentityToken
    policyId::UA_String
end

"""
    UA_X509IdentityToken

X509IdentityToken ^^^^^^^^^^^^^^^^^ A token representing a user identified by an X509 certificate. 
"""
struct UA_X509IdentityToken
    policyId::UA_String
    certificateData::UA_ByteString
end

"""
    UA_MonitoredItemNotification

MonitoredItemNotification ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_MonitoredItemNotification
    clientHandle::UA_UInt32
    value::UA_DataValue
end

"""
    UA_StructureType

StructureType ^^^^^^^^^^^^^
"""
@cenum UA_StructureType::UInt32 begin
    UA_STRUCTURETYPE_STRUCTURE = 0
    UA_STRUCTURETYPE_STRUCTUREWITHOPTIONALFIELDS = 1
    UA_STRUCTURETYPE_UNION = 2
    __UA_STRUCTURETYPE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_2
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_ResponseHeader

ResponseHeader ^^^^^^^^^^^^^^ The header passed with every server response. 
"""
struct UA_ResponseHeader
    timestamp::UA_DateTime
    requestHandle::UA_UInt32
    serviceResult::UA_StatusCode
    serviceDiagnostics::UA_DiagnosticInfo
    stringTableSize::Csize_t
    stringTable::Ptr{UA_String}
    additionalHeader::UA_ExtensionObject
end

"""
    UA_SignatureData

SignatureData ^^^^^^^^^^^^^ A digital signature. 
"""
struct UA_SignatureData
    algorithm::UA_String
    signature::UA_ByteString
end

"""
    UA_ModifySubscriptionResponse

ModifySubscriptionResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ModifySubscriptionResponse
    responseHeader::UA_ResponseHeader
    revisedPublishingInterval::UA_Double
    revisedLifetimeCount::UA_UInt32
    revisedMaxKeepAliveCount::UA_UInt32
end

"""
    UA_NodeAttributes

NodeAttributes ^^^^^^^^^^^^^^ The base attributes for all nodes. 
"""
struct UA_NodeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
end

"""
    UA_ActivateSessionResponse

ActivateSessionResponse ^^^^^^^^^^^^^^^^^^^^^^^ Activates a session with the server. 
"""
struct UA_ActivateSessionResponse
    responseHeader::UA_ResponseHeader
    serverNonce::UA_ByteString
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_EnumField

EnumField ^^^^^^^^^
"""
struct UA_EnumField
    value::UA_Int64
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    name::UA_String
end

"""
    UA_VariableTypeAttributes

VariableTypeAttributes ^^^^^^^^^^^^^^^^^^^^^^ The attributes for a variable type node. 
"""
struct UA_VariableTypeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    value::UA_Variant
    dataType::UA_NodeId
    valueRank::UA_Int32
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
    isAbstract::UA_Boolean
end

"""
    UA_CallMethodResult

CallMethodResult ^^^^^^^^^^^^^^^^
"""
struct UA_CallMethodResult
    statusCode::UA_StatusCode
    inputArgumentResultsSize::Csize_t
    inputArgumentResults::Ptr{UA_StatusCode}
    inputArgumentDiagnosticInfosSize::Csize_t
    inputArgumentDiagnosticInfos::Ptr{UA_DiagnosticInfo}
    outputArgumentsSize::Csize_t
    outputArguments::Ptr{UA_Variant}
end

"""
    UA_MonitoringMode

MonitoringMode ^^^^^^^^^^^^^^
"""
@cenum UA_MonitoringMode::UInt32 begin
    UA_MONITORINGMODE_DISABLED = 0
    UA_MONITORINGMODE_SAMPLING = 1
    UA_MONITORINGMODE_REPORTING = 2
    __UA_MONITORINGMODE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_3
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_SetMonitoringModeResponse

SetMonitoringModeResponse ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SetMonitoringModeResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_BrowseResultMask

BrowseResultMask ^^^^^^^^^^^^^^^^ A bit mask which specifies what should be returned in a browse response. 
"""
@cenum UA_BrowseResultMask::UInt32 begin
    UA_BROWSERESULTMASK_NONE = 0
    UA_BROWSERESULTMASK_REFERENCETYPEID = 1
    UA_BROWSERESULTMASK_ISFORWARD = 2
    UA_BROWSERESULTMASK_NODECLASS = 4
    UA_BROWSERESULTMASK_BROWSENAME = 8
    UA_BROWSERESULTMASK_DISPLAYNAME = 16
    UA_BROWSERESULTMASK_TYPEDEFINITION = 32
    UA_BROWSERESULTMASK_ALL = 63
    UA_BROWSERESULTMASK_REFERENCETYPEINFO = 3
    UA_BROWSERESULTMASK_TARGETINFO = 60
    __UA_BROWSERESULTMASK_FORCE32BIT = 2147483647
end

struct static_assertion_failed_4
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_RequestHeader

RequestHeader ^^^^^^^^^^^^^ The header passed with every server request. 
"""
struct UA_RequestHeader
    authenticationToken::UA_NodeId
    timestamp::UA_DateTime
    requestHandle::UA_UInt32
    returnDiagnostics::UA_UInt32
    auditEntryId::UA_String
    timeoutHint::UA_UInt32
    additionalHeader::UA_ExtensionObject
end

"""
    UA_MonitoredItemModifyResult

MonitoredItemModifyResult ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_MonitoredItemModifyResult
    statusCode::UA_StatusCode
    revisedSamplingInterval::UA_Double
    revisedQueueSize::UA_UInt32
    filterResult::UA_ExtensionObject
end

"""
    UA_CloseSecureChannelRequest

CloseSecureChannelRequest ^^^^^^^^^^^^^^^^^^^^^^^^^ Closes a secure channel. 
"""
struct UA_CloseSecureChannelRequest
    requestHeader::UA_RequestHeader
end

"""
    UA_NotificationMessage

NotificationMessage ^^^^^^^^^^^^^^^^^^^
"""
struct UA_NotificationMessage
    sequenceNumber::UA_UInt32
    publishTime::UA_DateTime
    notificationDataSize::Csize_t
    notificationData::Ptr{UA_ExtensionObject}
end

"""
    UA_CreateSubscriptionResponse

CreateSubscriptionResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_CreateSubscriptionResponse
    responseHeader::UA_ResponseHeader
    subscriptionId::UA_UInt32
    revisedPublishingInterval::UA_Double
    revisedLifetimeCount::UA_UInt32
    revisedMaxKeepAliveCount::UA_UInt32
end

"""
    UA_EnumDefinition

EnumDefinition ^^^^^^^^^^^^^^
"""
struct UA_EnumDefinition
    fieldsSize::Csize_t
    fields::Ptr{UA_EnumField}
end

"""
    UA_AxisScaleEnumeration

AxisScaleEnumeration ^^^^^^^^^^^^^^^^^^^^
"""
@cenum UA_AxisScaleEnumeration::UInt32 begin
    UA_AXISSCALEENUMERATION_LINEAR = 0
    UA_AXISSCALEENUMERATION_LOG = 1
    UA_AXISSCALEENUMERATION_LN = 2
    __UA_AXISSCALEENUMERATION_FORCE32BIT = 2147483647
end

struct static_assertion_failed_5
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_BrowseDirection

BrowseDirection ^^^^^^^^^^^^^^^ The directions of the references to return. 
"""
@cenum UA_BrowseDirection::UInt32 begin
    UA_BROWSEDIRECTION_FORWARD = 0
    UA_BROWSEDIRECTION_INVERSE = 1
    UA_BROWSEDIRECTION_BOTH = 2
    UA_BROWSEDIRECTION_INVALID = 3
    __UA_BROWSEDIRECTION_FORCE32BIT = 2147483647
end

struct static_assertion_failed_6
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_CallMethodRequest

CallMethodRequest ^^^^^^^^^^^^^^^^^
"""
struct UA_CallMethodRequest
    objectId::UA_NodeId
    methodId::UA_NodeId
    inputArgumentsSize::Csize_t
    inputArguments::Ptr{UA_Variant}
end

"""
    UA_ReadResponse

ReadResponse ^^^^^^^^^^^^
"""
struct UA_ReadResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_DataValue}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_TimestampsToReturn

TimestampsToReturn ^^^^^^^^^^^^^^^^^^
"""
@cenum UA_TimestampsToReturn::UInt32 begin
    UA_TIMESTAMPSTORETURN_SOURCE = 0
    UA_TIMESTAMPSTORETURN_SERVER = 1
    UA_TIMESTAMPSTORETURN_BOTH = 2
    UA_TIMESTAMPSTORETURN_NEITHER = 3
    UA_TIMESTAMPSTORETURN_INVALID = 4
    __UA_TIMESTAMPSTORETURN_FORCE32BIT = 2147483647
end

struct static_assertion_failed_7
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_NodeClass

NodeClass ^^^^^^^^^ A mask specifying the class of the node. 
"""
@cenum UA_NodeClass::UInt32 begin
    UA_NODECLASS_UNSPECIFIED = 0
    UA_NODECLASS_OBJECT = 1
    UA_NODECLASS_VARIABLE = 2
    UA_NODECLASS_METHOD = 4
    UA_NODECLASS_OBJECTTYPE = 8
    UA_NODECLASS_VARIABLETYPE = 16
    UA_NODECLASS_REFERENCETYPE = 32
    UA_NODECLASS_DATATYPE = 64
    UA_NODECLASS_VIEW = 128
    __UA_NODECLASS_FORCE32BIT = 2147483647
end

struct static_assertion_failed_8
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_ObjectTypeAttributes

ObjectTypeAttributes ^^^^^^^^^^^^^^^^^^^^ The attributes for an object type node. 
"""
struct UA_ObjectTypeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    isAbstract::UA_Boolean
end

"""
    UA_SecurityTokenRequestType

SecurityTokenRequestType ^^^^^^^^^^^^^^^^^^^^^^^^ Indicates whether a token if being created or renewed. 
"""
@cenum UA_SecurityTokenRequestType::UInt32 begin
    UA_SECURITYTOKENREQUESTTYPE_ISSUE = 0
    UA_SECURITYTOKENREQUESTTYPE_RENEW = 1
    __UA_SECURITYTOKENREQUESTTYPE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_9
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_CloseSessionResponse

CloseSessionResponse ^^^^^^^^^^^^^^^^^^^^ Closes a session with the server. 
"""
struct UA_CloseSessionResponse
    responseHeader::UA_ResponseHeader
end

"""
    UA_SetPublishingModeRequest

SetPublishingModeRequest ^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SetPublishingModeRequest
    requestHeader::UA_RequestHeader
    publishingEnabled::UA_Boolean
    subscriptionIdsSize::Csize_t
    subscriptionIds::Ptr{UA_UInt32}
end

"""
    UA_IssuedIdentityToken

IssuedIdentityToken ^^^^^^^^^^^^^^^^^^^ A token representing a user identified by a WS-Security XML token. 
"""
struct UA_IssuedIdentityToken
    policyId::UA_String
    tokenData::UA_ByteString
    encryptionAlgorithm::UA_String
end

"""
    UA_DeleteMonitoredItemsResponse

DeleteMonitoredItemsResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_DeleteMonitoredItemsResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_ApplicationType

ApplicationType ^^^^^^^^^^^^^^^ The types of applications. 
"""
@cenum UA_ApplicationType::UInt32 begin
    UA_APPLICATIONTYPE_SERVER = 0
    UA_APPLICATIONTYPE_CLIENT = 1
    UA_APPLICATIONTYPE_CLIENTANDSERVER = 2
    UA_APPLICATIONTYPE_DISCOVERYSERVER = 3
    __UA_APPLICATIONTYPE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_10
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_BrowseNextRequest

BrowseNextRequest ^^^^^^^^^^^^^^^^^ Continues one or more browse operations. 
"""
struct UA_BrowseNextRequest
    requestHeader::UA_RequestHeader
    releaseContinuationPoints::UA_Boolean
    continuationPointsSize::Csize_t
    continuationPoints::Ptr{UA_ByteString}
end

"""
    UA_ModifySubscriptionRequest

ModifySubscriptionRequest ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ModifySubscriptionRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    requestedPublishingInterval::UA_Double
    requestedLifetimeCount::UA_UInt32
    requestedMaxKeepAliveCount::UA_UInt32
    maxNotificationsPerPublish::UA_UInt32
    priority::UA_Byte
end

"""
    UA_BrowseDescription

BrowseDescription ^^^^^^^^^^^^^^^^^ A request to browse the the references from a node. 
"""
struct UA_BrowseDescription
    nodeId::UA_NodeId
    browseDirection::UA_BrowseDirection
    referenceTypeId::UA_NodeId
    includeSubtypes::UA_Boolean
    nodeClassMask::UA_UInt32
    resultMask::UA_UInt32
end

"""
    UA_SignedSoftwareCertificate

SignedSoftwareCertificate ^^^^^^^^^^^^^^^^^^^^^^^^^ A software certificate with a digital signature. 
"""
struct UA_SignedSoftwareCertificate
    certificateData::UA_ByteString
    signature::UA_ByteString
end

"""
    UA_BrowsePathTarget

BrowsePathTarget ^^^^^^^^^^^^^^^^ The target of the translated path. 
"""
struct UA_BrowsePathTarget
    targetId::UA_ExpandedNodeId
    remainingPathIndex::UA_UInt32
end

"""
    UA_WriteResponse

WriteResponse ^^^^^^^^^^^^^
"""
struct UA_WriteResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_AddNodesResult

AddNodesResult ^^^^^^^^^^^^^^ A result of an add node operation. 
"""
struct UA_AddNodesResult
    statusCode::UA_StatusCode
    addedNodeId::UA_NodeId
end

"""
    UA_AddReferencesItem

AddReferencesItem ^^^^^^^^^^^^^^^^^ A request to add a reference to the server address space. 
"""
struct UA_AddReferencesItem
    sourceNodeId::UA_NodeId
    referenceTypeId::UA_NodeId
    isForward::UA_Boolean
    targetServerUri::UA_String
    targetNodeId::UA_ExpandedNodeId
    targetNodeClass::UA_NodeClass
end

"""
    UA_DeleteReferencesResponse

DeleteReferencesResponse ^^^^^^^^^^^^^^^^^^^^^^^^ Delete one or more references from the server address space. 
"""
struct UA_DeleteReferencesResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_RelativePathElement

RelativePathElement ^^^^^^^^^^^^^^^^^^^ An element in a relative path. 
"""
struct UA_RelativePathElement
    referenceTypeId::UA_NodeId
    isInverse::UA_Boolean
    includeSubtypes::UA_Boolean
    targetName::UA_QualifiedName
end

"""
    UA_SubscriptionAcknowledgement

SubscriptionAcknowledgement ^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SubscriptionAcknowledgement
    subscriptionId::UA_UInt32
    sequenceNumber::UA_UInt32
end

"""
    UA_TransferResult

TransferResult ^^^^^^^^^^^^^^
"""
struct UA_TransferResult
    statusCode::UA_StatusCode
    availableSequenceNumbersSize::Csize_t
    availableSequenceNumbers::Ptr{UA_UInt32}
end

"""
    UA_CreateMonitoredItemsResponse

CreateMonitoredItemsResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_CreateMonitoredItemsResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_MonitoredItemCreateResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_DeleteReferencesItem

DeleteReferencesItem ^^^^^^^^^^^^^^^^^^^^ A request to delete a node from the server address space. 
"""
struct UA_DeleteReferencesItem
    sourceNodeId::UA_NodeId
    referenceTypeId::UA_NodeId
    isForward::UA_Boolean
    targetNodeId::UA_ExpandedNodeId
    deleteBidirectional::UA_Boolean
end

"""
    UA_WriteValue

WriteValue ^^^^^^^^^^
"""
struct UA_WriteValue
    nodeId::UA_NodeId
    attributeId::UA_UInt32
    indexRange::UA_String
    value::UA_DataValue
end

"""
    UA_DataTypeAttributes

DataTypeAttributes ^^^^^^^^^^^^^^^^^^ The attributes for a data type node. 
"""
struct UA_DataTypeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    isAbstract::UA_Boolean
end

"""
    UA_TransferSubscriptionsResponse

TransferSubscriptionsResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_TransferSubscriptionsResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_TransferResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_AddReferencesResponse

AddReferencesResponse ^^^^^^^^^^^^^^^^^^^^^ Adds one or more references to the server address space. 
"""
struct UA_AddReferencesResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_DeadbandType

DeadbandType ^^^^^^^^^^^^
"""
@cenum UA_DeadbandType::UInt32 begin
    UA_DEADBANDTYPE_NONE = 0
    UA_DEADBANDTYPE_ABSOLUTE = 1
    UA_DEADBANDTYPE_PERCENT = 2
    __UA_DEADBANDTYPE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_11
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_DataChangeTrigger

DataChangeTrigger ^^^^^^^^^^^^^^^^^
"""
@cenum UA_DataChangeTrigger::UInt32 begin
    UA_DATACHANGETRIGGER_STATUS = 0
    UA_DATACHANGETRIGGER_STATUSVALUE = 1
    UA_DATACHANGETRIGGER_STATUSVALUETIMESTAMP = 2
    __UA_DATACHANGETRIGGER_FORCE32BIT = 2147483647
end

struct static_assertion_failed_12
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_BuildInfo

BuildInfo ^^^^^^^^^
"""
struct UA_BuildInfo
    productUri::UA_String
    manufacturerName::UA_String
    productName::UA_String
    softwareVersion::UA_String
    buildNumber::UA_String
    buildDate::UA_DateTime
end

"""
FilterOperand ^^^^^^^^^^^^^
"""
const UA_FilterOperand = Ptr{Cvoid}

"""
    UA_MonitoringParameters

MonitoringParameters ^^^^^^^^^^^^^^^^^^^^
"""
struct UA_MonitoringParameters
    clientHandle::UA_UInt32
    samplingInterval::UA_Double
    filter::UA_ExtensionObject
    queueSize::UA_UInt32
    discardOldest::UA_Boolean
end

"""
    UA_DoubleComplexNumberType

DoubleComplexNumberType ^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_DoubleComplexNumberType
    real::UA_Double
    imaginary::UA_Double
end

"""
    UA_DeleteNodesItem

DeleteNodesItem ^^^^^^^^^^^^^^^ A request to delete a node to the server address space. 
"""
struct UA_DeleteNodesItem
    nodeId::UA_NodeId
    deleteTargetReferences::UA_Boolean
end

"""
    UA_ReadValueId

ReadValueId ^^^^^^^^^^^
"""
struct UA_ReadValueId
    nodeId::UA_NodeId
    attributeId::UA_UInt32
    indexRange::UA_String
    dataEncoding::UA_QualifiedName
end

"""
    UA_CallRequest

CallRequest ^^^^^^^^^^^
"""
struct UA_CallRequest
    requestHeader::UA_RequestHeader
    methodsToCallSize::Csize_t
    methodsToCall::Ptr{UA_CallMethodRequest}
end

"""
    UA_RelativePath

RelativePath ^^^^^^^^^^^^ A relative path constructed from reference types and browse names. 
"""
struct UA_RelativePath
    elementsSize::Csize_t
    elements::Ptr{UA_RelativePathElement}
end

"""
    UA_DeleteNodesRequest

DeleteNodesRequest ^^^^^^^^^^^^^^^^^^ Delete one or more nodes from the server address space. 
"""
struct UA_DeleteNodesRequest
    requestHeader::UA_RequestHeader
    nodesToDeleteSize::Csize_t
    nodesToDelete::Ptr{UA_DeleteNodesItem}
end

"""
    UA_MonitoredItemModifyRequest

MonitoredItemModifyRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_MonitoredItemModifyRequest
    monitoredItemId::UA_UInt32
    requestedParameters::UA_MonitoringParameters
end

"""
    UA_UserTokenType

UserTokenType ^^^^^^^^^^^^^ The possible user token types. 
"""
@cenum UA_UserTokenType::UInt32 begin
    UA_USERTOKENTYPE_ANONYMOUS = 0
    UA_USERTOKENTYPE_USERNAME = 1
    UA_USERTOKENTYPE_CERTIFICATE = 2
    UA_USERTOKENTYPE_ISSUEDTOKEN = 3
    __UA_USERTOKENTYPE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_13
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_AggregateConfiguration

AggregateConfiguration ^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_AggregateConfiguration
    useServerCapabilitiesDefaults::UA_Boolean
    treatUncertainAsBad::UA_Boolean
    percentDataBad::UA_Byte
    percentDataGood::UA_Byte
    useSlopedExtrapolation::UA_Boolean
end

"""
LocaleId ^^^^^^^^ An identifier for a user locale. 
"""
const UA_LocaleId = UA_String

"""
    UA_UnregisterNodesResponse

UnregisterNodesResponse ^^^^^^^^^^^^^^^^^^^^^^^ Unregisters one or more previously registered nodes. 
"""
struct UA_UnregisterNodesResponse
    responseHeader::UA_ResponseHeader
end

"""
    UA_ContentFilterResult

ContentFilterResult ^^^^^^^^^^^^^^^^^^^
"""
struct UA_ContentFilterResult
    elementResultsSize::Csize_t
    elementResults::Ptr{UA_ContentFilterElementResult}
    elementDiagnosticInfosSize::Csize_t
    elementDiagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_UserTokenPolicy

UserTokenPolicy ^^^^^^^^^^^^^^^ Describes a user token that can be used with a server. 
"""
struct UA_UserTokenPolicy
    policyId::UA_String
    tokenType::UA_UserTokenType
    issuedTokenType::UA_String
    issuerEndpointUrl::UA_String
    securityPolicyUri::UA_String
end

"""
    UA_DeleteMonitoredItemsRequest

DeleteMonitoredItemsRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_DeleteMonitoredItemsRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    monitoredItemIdsSize::Csize_t
    monitoredItemIds::Ptr{UA_UInt32}
end

"""
    UA_SetMonitoringModeRequest

SetMonitoringModeRequest ^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SetMonitoringModeRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    monitoringMode::UA_MonitoringMode
    monitoredItemIdsSize::Csize_t
    monitoredItemIds::Ptr{UA_UInt32}
end

"""
Duration ^^^^^^^^ A period of time measured in milliseconds. 
"""
const UA_Duration = UA_Double

"""
    UA_ReferenceTypeAttributes

ReferenceTypeAttributes ^^^^^^^^^^^^^^^^^^^^^^^ The attributes for a reference type node. 
"""
struct UA_ReferenceTypeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    isAbstract::UA_Boolean
    symmetric::UA_Boolean
    inverseName::UA_LocalizedText
end

"""
    UA_GetEndpointsRequest

GetEndpointsRequest ^^^^^^^^^^^^^^^^^^^ Gets the endpoints used by the server. 
"""
struct UA_GetEndpointsRequest
    requestHeader::UA_RequestHeader
    endpointUrl::UA_String
    localeIdsSize::Csize_t
    localeIds::Ptr{UA_String}
    profileUrisSize::Csize_t
    profileUris::Ptr{UA_String}
end

"""
    UA_CloseSecureChannelResponse

CloseSecureChannelResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^ Closes a secure channel. 
"""
struct UA_CloseSecureChannelResponse
    responseHeader::UA_ResponseHeader
end

"""
    UA_ViewDescription

ViewDescription ^^^^^^^^^^^^^^^ The view to browse. 
"""
struct UA_ViewDescription
    viewId::UA_NodeId
    timestamp::UA_DateTime
    viewVersion::UA_UInt32
end

"""
    UA_SetPublishingModeResponse

SetPublishingModeResponse ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SetPublishingModeResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_StatusChangeNotification

StatusChangeNotification ^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_StatusChangeNotification
    status::UA_StatusCode
    diagnosticInfo::UA_DiagnosticInfo
end

"""
    UA_StructureField

StructureField ^^^^^^^^^^^^^^
"""
struct UA_StructureField
    name::UA_String
    description::UA_LocalizedText
    dataType::UA_NodeId
    valueRank::UA_Int32
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
    maxStringLength::UA_UInt32
    isOptional::UA_Boolean
end

"""
    UA_NodeAttributesMask

NodeAttributesMask ^^^^^^^^^^^^^^^^^^ The bits used to specify default attributes for a new node. 
"""
@cenum UA_NodeAttributesMask::UInt32 begin
    UA_NODEATTRIBUTESMASK_NONE = 0
    UA_NODEATTRIBUTESMASK_ACCESSLEVEL = 1
    UA_NODEATTRIBUTESMASK_ARRAYDIMENSIONS = 2
    UA_NODEATTRIBUTESMASK_BROWSENAME = 4
    UA_NODEATTRIBUTESMASK_CONTAINSNOLOOPS = 8
    UA_NODEATTRIBUTESMASK_DATATYPE = 16
    UA_NODEATTRIBUTESMASK_DESCRIPTION = 32
    UA_NODEATTRIBUTESMASK_DISPLAYNAME = 64
    UA_NODEATTRIBUTESMASK_EVENTNOTIFIER = 128
    UA_NODEATTRIBUTESMASK_EXECUTABLE = 256
    UA_NODEATTRIBUTESMASK_HISTORIZING = 512
    UA_NODEATTRIBUTESMASK_INVERSENAME = 1024
    UA_NODEATTRIBUTESMASK_ISABSTRACT = 2048
    UA_NODEATTRIBUTESMASK_MINIMUMSAMPLINGINTERVAL = 4096
    UA_NODEATTRIBUTESMASK_NODECLASS = 8192
    UA_NODEATTRIBUTESMASK_NODEID = 16384
    UA_NODEATTRIBUTESMASK_SYMMETRIC = 32768
    UA_NODEATTRIBUTESMASK_USERACCESSLEVEL = 65536
    UA_NODEATTRIBUTESMASK_USEREXECUTABLE = 131072
    UA_NODEATTRIBUTESMASK_USERWRITEMASK = 262144
    UA_NODEATTRIBUTESMASK_VALUERANK = 524288
    UA_NODEATTRIBUTESMASK_WRITEMASK = 1048576
    UA_NODEATTRIBUTESMASK_VALUE = 2097152
    UA_NODEATTRIBUTESMASK_DATATYPEDEFINITION = 4194304
    UA_NODEATTRIBUTESMASK_ROLEPERMISSIONS = 8388608
    UA_NODEATTRIBUTESMASK_ACCESSRESTRICTIONS = 16777216
    UA_NODEATTRIBUTESMASK_ALL = 33554431
    UA_NODEATTRIBUTESMASK_BASENODE = 26501220
    UA_NODEATTRIBUTESMASK_OBJECT = 26501348
    UA_NODEATTRIBUTESMASK_OBJECTTYPE = 26503268
    UA_NODEATTRIBUTESMASK_VARIABLE = 26571383
    UA_NODEATTRIBUTESMASK_VARIABLETYPE = 28600438
    UA_NODEATTRIBUTESMASK_METHOD = 26632548
    UA_NODEATTRIBUTESMASK_REFERENCETYPE = 26537060
    UA_NODEATTRIBUTESMASK_VIEW = 26501356
    __UA_NODEATTRIBUTESMASK_FORCE32BIT = 2147483647
end

struct static_assertion_failed_14
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_EventFilterResult

EventFilterResult ^^^^^^^^^^^^^^^^^
"""
struct UA_EventFilterResult
    selectClauseResultsSize::Csize_t
    selectClauseResults::Ptr{UA_StatusCode}
    selectClauseDiagnosticInfosSize::Csize_t
    selectClauseDiagnosticInfos::Ptr{UA_DiagnosticInfo}
    whereClauseResult::UA_ContentFilterResult
end

"""
    UA_MonitoredItemCreateRequest

MonitoredItemCreateRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_MonitoredItemCreateRequest
    itemToMonitor::UA_ReadValueId
    monitoringMode::UA_MonitoringMode
    requestedParameters::UA_MonitoringParameters
end

"""
    UA_ComplexNumberType

ComplexNumberType ^^^^^^^^^^^^^^^^^
"""
struct UA_ComplexNumberType
    real::UA_Float
    imaginary::UA_Float
end

"""
    UA_Range

Range ^^^^^
"""
struct UA_Range
    low::UA_Double
    high::UA_Double
end

"""
    UA_DataChangeNotification

DataChangeNotification ^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_DataChangeNotification
    monitoredItemsSize::Csize_t
    monitoredItems::Ptr{UA_MonitoredItemNotification}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_Argument

Argument ^^^^^^^^ An argument for a method. 
"""
struct UA_Argument
    name::UA_String
    dataType::UA_NodeId
    valueRank::UA_Int32
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
    description::UA_LocalizedText
end

"""
    UA_TransferSubscriptionsRequest

TransferSubscriptionsRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_TransferSubscriptionsRequest
    requestHeader::UA_RequestHeader
    subscriptionIdsSize::Csize_t
    subscriptionIds::Ptr{UA_UInt32}
    sendInitialValues::UA_Boolean
end

"""
    UA_ChannelSecurityToken

ChannelSecurityToken ^^^^^^^^^^^^^^^^^^^^ The token that identifies a set of keys for an active secure channel. 
"""
struct UA_ChannelSecurityToken
    channelId::UA_UInt32
    tokenId::UA_UInt32
    createdAt::UA_DateTime
    revisedLifetime::UA_UInt32
end

"""
    UA_ServerState

ServerState ^^^^^^^^^^^
"""
@cenum UA_ServerState::UInt32 begin
    UA_SERVERSTATE_RUNNING = 0
    UA_SERVERSTATE_FAILED = 1
    UA_SERVERSTATE_NOCONFIGURATION = 2
    UA_SERVERSTATE_SUSPENDED = 3
    UA_SERVERSTATE_SHUTDOWN = 4
    UA_SERVERSTATE_TEST = 5
    UA_SERVERSTATE_COMMUNICATIONFAULT = 6
    UA_SERVERSTATE_UNKNOWN = 7
    __UA_SERVERSTATE_FORCE32BIT = 2147483647
end

struct static_assertion_failed_15
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_EventNotificationList

EventNotificationList ^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_EventNotificationList
    eventsSize::Csize_t
    events::Ptr{UA_EventFieldList}
end

"""
    UA_AnonymousIdentityToken

AnonymousIdentityToken ^^^^^^^^^^^^^^^^^^^^^^ A token representing an anonymous user. 
"""
struct UA_AnonymousIdentityToken
    policyId::UA_String
end

"""
    UA_FilterOperator

FilterOperator ^^^^^^^^^^^^^^
"""
@cenum UA_FilterOperator::UInt32 begin
    UA_FILTEROPERATOR_EQUALS = 0
    UA_FILTEROPERATOR_ISNULL = 1
    UA_FILTEROPERATOR_GREATERTHAN = 2
    UA_FILTEROPERATOR_LESSTHAN = 3
    UA_FILTEROPERATOR_GREATERTHANOREQUAL = 4
    UA_FILTEROPERATOR_LESSTHANOREQUAL = 5
    UA_FILTEROPERATOR_LIKE = 6
    UA_FILTEROPERATOR_NOT = 7
    UA_FILTEROPERATOR_BETWEEN = 8
    UA_FILTEROPERATOR_INLIST = 9
    UA_FILTEROPERATOR_AND = 10
    UA_FILTEROPERATOR_OR = 11
    UA_FILTEROPERATOR_CAST = 12
    UA_FILTEROPERATOR_INVIEW = 13
    UA_FILTEROPERATOR_OFTYPE = 14
    UA_FILTEROPERATOR_RELATEDTO = 15
    UA_FILTEROPERATOR_BITWISEAND = 16
    UA_FILTEROPERATOR_BITWISEOR = 17
    __UA_FILTEROPERATOR_FORCE32BIT = 2147483647
end

struct static_assertion_failed_16
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_AggregateFilter

AggregateFilter ^^^^^^^^^^^^^^^
"""
struct UA_AggregateFilter
    startTime::UA_DateTime
    aggregateType::UA_NodeId
    processingInterval::UA_Double
    aggregateConfiguration::UA_AggregateConfiguration
end

"""
    UA_RepublishResponse

RepublishResponse ^^^^^^^^^^^^^^^^^
"""
struct UA_RepublishResponse
    responseHeader::UA_ResponseHeader
    notificationMessage::UA_NotificationMessage
end

"""
    UA_DeleteSubscriptionsResponse

DeleteSubscriptionsResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_DeleteSubscriptionsResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_RegisterNodesRequest

RegisterNodesRequest ^^^^^^^^^^^^^^^^^^^^ Registers one or more nodes for repeated use within a session. 
"""
struct UA_RegisterNodesRequest
    requestHeader::UA_RequestHeader
    nodesToRegisterSize::Csize_t
    nodesToRegister::Ptr{UA_NodeId}
end

"""
    UA_StructureDefinition

StructureDefinition ^^^^^^^^^^^^^^^^^^^
"""
struct UA_StructureDefinition
    defaultEncodingId::UA_NodeId
    baseDataType::UA_NodeId
    structureType::UA_StructureType
    fieldsSize::Csize_t
    fields::Ptr{UA_StructureField}
end

"""
    UA_MethodAttributes

MethodAttributes ^^^^^^^^^^^^^^^^ The attributes for a method node. 
"""
struct UA_MethodAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    executable::UA_Boolean
    userExecutable::UA_Boolean
end

"""
    UA_UserNameIdentityToken

UserNameIdentityToken ^^^^^^^^^^^^^^^^^^^^^ A token representing a user identified by a user name and password. 
"""
struct UA_UserNameIdentityToken
    policyId::UA_String
    userName::UA_String
    password::UA_ByteString
    encryptionAlgorithm::UA_String
end

"""
    UA_UnregisterNodesRequest

UnregisterNodesRequest ^^^^^^^^^^^^^^^^^^^^^^ Unregisters one or more previously registered nodes. 
"""
struct UA_UnregisterNodesRequest
    requestHeader::UA_RequestHeader
    nodesToUnregisterSize::Csize_t
    nodesToUnregister::Ptr{UA_NodeId}
end

"""
    UA_OpenSecureChannelResponse

OpenSecureChannelResponse ^^^^^^^^^^^^^^^^^^^^^^^^^ Creates a secure channel with a server. 
"""
struct UA_OpenSecureChannelResponse
    responseHeader::UA_ResponseHeader
    serverProtocolVersion::UA_UInt32
    securityToken::UA_ChannelSecurityToken
    serverNonce::UA_ByteString
end

"""
    UA_SetTriggeringResponse

SetTriggeringResponse ^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SetTriggeringResponse
    responseHeader::UA_ResponseHeader
    addResultsSize::Csize_t
    addResults::Ptr{UA_StatusCode}
    addDiagnosticInfosSize::Csize_t
    addDiagnosticInfos::Ptr{UA_DiagnosticInfo}
    removeResultsSize::Csize_t
    removeResults::Ptr{UA_StatusCode}
    removeDiagnosticInfosSize::Csize_t
    removeDiagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_SimpleAttributeOperand

SimpleAttributeOperand ^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SimpleAttributeOperand
    typeDefinitionId::UA_NodeId
    browsePathSize::Csize_t
    browsePath::Ptr{UA_QualifiedName}
    attributeId::UA_UInt32
    indexRange::UA_String
end

"""
    UA_RepublishRequest

RepublishRequest ^^^^^^^^^^^^^^^^
"""
struct UA_RepublishRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    retransmitSequenceNumber::UA_UInt32
end

"""
    UA_RegisterNodesResponse

RegisterNodesResponse ^^^^^^^^^^^^^^^^^^^^^ Registers one or more nodes for repeated use within a session. 
"""
struct UA_RegisterNodesResponse
    responseHeader::UA_ResponseHeader
    registeredNodeIdsSize::Csize_t
    registeredNodeIds::Ptr{UA_NodeId}
end

"""
    UA_ModifyMonitoredItemsResponse

ModifyMonitoredItemsResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ModifyMonitoredItemsResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_MonitoredItemModifyResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_DeleteSubscriptionsRequest

DeleteSubscriptionsRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_DeleteSubscriptionsRequest
    requestHeader::UA_RequestHeader
    subscriptionIdsSize::Csize_t
    subscriptionIds::Ptr{UA_UInt32}
end

"""
    UA_RedundancySupport

RedundancySupport ^^^^^^^^^^^^^^^^^
"""
@cenum UA_RedundancySupport::UInt32 begin
    UA_REDUNDANCYSUPPORT_NONE = 0
    UA_REDUNDANCYSUPPORT_COLD = 1
    UA_REDUNDANCYSUPPORT_WARM = 2
    UA_REDUNDANCYSUPPORT_HOT = 3
    UA_REDUNDANCYSUPPORT_TRANSPARENT = 4
    UA_REDUNDANCYSUPPORT_HOTANDMIRRORED = 5
    __UA_REDUNDANCYSUPPORT_FORCE32BIT = 2147483647
end

struct static_assertion_failed_17
    static_assertion_failed_enum_must_be_32bit::Cint
end

"""
    UA_BrowsePath

BrowsePath ^^^^^^^^^^ A request to translate a path into a node id. 
"""
struct UA_BrowsePath
    startingNode::UA_NodeId
    relativePath::UA_RelativePath
end

"""
    UA_ObjectAttributes

ObjectAttributes ^^^^^^^^^^^^^^^^ The attributes for an object node. 
"""
struct UA_ObjectAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    eventNotifier::UA_Byte
end

"""
    UA_PublishRequest

PublishRequest ^^^^^^^^^^^^^^
"""
struct UA_PublishRequest
    requestHeader::UA_RequestHeader
    subscriptionAcknowledgementsSize::Csize_t
    subscriptionAcknowledgements::Ptr{UA_SubscriptionAcknowledgement}
end

"""
    UA_FindServersRequest

FindServersRequest ^^^^^^^^^^^^^^^^^^ Finds the servers known to the discovery server. 
"""
struct UA_FindServersRequest
    requestHeader::UA_RequestHeader
    endpointUrl::UA_String
    localeIdsSize::Csize_t
    localeIds::Ptr{UA_String}
    serverUrisSize::Csize_t
    serverUris::Ptr{UA_String}
end

"""
    UA_ReferenceDescription

ReferenceDescription ^^^^^^^^^^^^^^^^^^^^ The description of a reference. 
"""
struct UA_ReferenceDescription
    referenceTypeId::UA_NodeId
    isForward::UA_Boolean
    nodeId::UA_ExpandedNodeId
    browseName::UA_QualifiedName
    displayName::UA_LocalizedText
    nodeClass::UA_NodeClass
    typeDefinition::UA_ExpandedNodeId
end

"""
    UA_CreateSubscriptionRequest

CreateSubscriptionRequest ^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_CreateSubscriptionRequest
    requestHeader::UA_RequestHeader
    requestedPublishingInterval::UA_Double
    requestedLifetimeCount::UA_UInt32
    requestedMaxKeepAliveCount::UA_UInt32
    maxNotificationsPerPublish::UA_UInt32
    publishingEnabled::UA_Boolean
    priority::UA_Byte
end

"""
    UA_CallResponse

CallResponse ^^^^^^^^^^^^
"""
struct UA_CallResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_CallMethodResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_DeleteNodesResponse

DeleteNodesResponse ^^^^^^^^^^^^^^^^^^^ Delete one or more nodes from the server address space. 
"""
struct UA_DeleteNodesResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_ModifyMonitoredItemsRequest

ModifyMonitoredItemsRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ModifyMonitoredItemsRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    timestampsToReturn::UA_TimestampsToReturn
    itemsToModifySize::Csize_t
    itemsToModify::Ptr{UA_MonitoredItemModifyRequest}
end

"""
    UA_ServiceFault

ServiceFault ^^^^^^^^^^^^ The response returned by all services when there is a service level error. 
"""
struct UA_ServiceFault
    responseHeader::UA_ResponseHeader
end

"""
    UA_PublishResponse

PublishResponse ^^^^^^^^^^^^^^^
"""
struct UA_PublishResponse
    responseHeader::UA_ResponseHeader
    subscriptionId::UA_UInt32
    availableSequenceNumbersSize::Csize_t
    availableSequenceNumbers::Ptr{UA_UInt32}
    moreNotifications::UA_Boolean
    notificationMessage::UA_NotificationMessage
    resultsSize::Csize_t
    results::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_CreateMonitoredItemsRequest

CreateMonitoredItemsRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""
struct UA_CreateMonitoredItemsRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    timestampsToReturn::UA_TimestampsToReturn
    itemsToCreateSize::Csize_t
    itemsToCreate::Ptr{UA_MonitoredItemCreateRequest}
end

"""
    UA_OpenSecureChannelRequest

OpenSecureChannelRequest ^^^^^^^^^^^^^^^^^^^^^^^^ Creates a secure channel with a server. 
"""
struct UA_OpenSecureChannelRequest
    requestHeader::UA_RequestHeader
    clientProtocolVersion::UA_UInt32
    requestType::UA_SecurityTokenRequestType
    securityMode::UA_MessageSecurityMode
    clientNonce::UA_ByteString
    requestedLifetime::UA_UInt32
end

"""
    UA_CloseSessionRequest

CloseSessionRequest ^^^^^^^^^^^^^^^^^^^ Closes a session with the server. 
"""
struct UA_CloseSessionRequest
    requestHeader::UA_RequestHeader
    deleteSubscriptions::UA_Boolean
end

"""
    UA_SetTriggeringRequest

SetTriggeringRequest ^^^^^^^^^^^^^^^^^^^^
"""
struct UA_SetTriggeringRequest
    requestHeader::UA_RequestHeader
    subscriptionId::UA_UInt32
    triggeringItemId::UA_UInt32
    linksToAddSize::Csize_t
    linksToAdd::Ptr{UA_UInt32}
    linksToRemoveSize::Csize_t
    linksToRemove::Ptr{UA_UInt32}
end

"""
    UA_BrowseResult

BrowseResult ^^^^^^^^^^^^ The result of a browse operation. 
"""
struct UA_BrowseResult
    statusCode::UA_StatusCode
    continuationPoint::UA_ByteString
    referencesSize::Csize_t
    references::Ptr{UA_ReferenceDescription}
end

"""
    UA_AddReferencesRequest

AddReferencesRequest ^^^^^^^^^^^^^^^^^^^^ Adds one or more references to the server address space. 
"""
struct UA_AddReferencesRequest
    requestHeader::UA_RequestHeader
    referencesToAddSize::Csize_t
    referencesToAdd::Ptr{UA_AddReferencesItem}
end

"""
    UA_AddNodesItem

AddNodesItem ^^^^^^^^^^^^ A request to add a node to the server address space. 
"""
struct UA_AddNodesItem
    parentNodeId::UA_ExpandedNodeId
    referenceTypeId::UA_NodeId
    requestedNewNodeId::UA_ExpandedNodeId
    browseName::UA_QualifiedName
    nodeClass::UA_NodeClass
    nodeAttributes::UA_ExtensionObject
    typeDefinition::UA_ExpandedNodeId
end

"""
    UA_ServerStatusDataType

ServerStatusDataType ^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ServerStatusDataType
    startTime::UA_DateTime
    currentTime::UA_DateTime
    state::UA_ServerState
    buildInfo::UA_BuildInfo
    secondsTillShutdown::UA_UInt32
    shutdownReason::UA_LocalizedText
end

"""
    UA_BrowseNextResponse

BrowseNextResponse ^^^^^^^^^^^^^^^^^^ Continues one or more browse operations. 
"""
struct UA_BrowseNextResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_BrowseResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_AxisInformation

AxisInformation ^^^^^^^^^^^^^^^
"""
struct UA_AxisInformation
    engineeringUnits::UA_EUInformation
    eURange::UA_Range
    title::UA_LocalizedText
    axisScaleType::UA_AxisScaleEnumeration
    axisStepsSize::Csize_t
    axisSteps::Ptr{UA_Double}
end

"""
    UA_ApplicationDescription

ApplicationDescription ^^^^^^^^^^^^^^^^^^^^^^ Describes an application and how to find it. 
"""
struct UA_ApplicationDescription
    applicationUri::UA_String
    productUri::UA_String
    applicationName::UA_LocalizedText
    applicationType::UA_ApplicationType
    gatewayServerUri::UA_String
    discoveryProfileUri::UA_String
    discoveryUrlsSize::Csize_t
    discoveryUrls::Ptr{UA_String}
end

"""
    UA_ReadRequest

ReadRequest ^^^^^^^^^^^
"""
struct UA_ReadRequest
    requestHeader::UA_RequestHeader
    maxAge::UA_Double
    timestampsToReturn::UA_TimestampsToReturn
    nodesToReadSize::Csize_t
    nodesToRead::Ptr{UA_ReadValueId}
end

"""
    UA_ActivateSessionRequest

ActivateSessionRequest ^^^^^^^^^^^^^^^^^^^^^^ Activates a session with the server. 
"""
struct UA_ActivateSessionRequest
    requestHeader::UA_RequestHeader
    clientSignature::UA_SignatureData
    clientSoftwareCertificatesSize::Csize_t
    clientSoftwareCertificates::Ptr{UA_SignedSoftwareCertificate}
    localeIdsSize::Csize_t
    localeIds::Ptr{UA_String}
    userIdentityToken::UA_ExtensionObject
    userTokenSignature::UA_SignatureData
end

"""
    UA_BrowsePathResult

BrowsePathResult ^^^^^^^^^^^^^^^^ The result of a translate opearation. 
"""
struct UA_BrowsePathResult
    statusCode::UA_StatusCode
    targetsSize::Csize_t
    targets::Ptr{UA_BrowsePathTarget}
end

"""
    UA_AddNodesRequest

AddNodesRequest ^^^^^^^^^^^^^^^ Adds one or more nodes to the server address space. 
"""
struct UA_AddNodesRequest
    requestHeader::UA_RequestHeader
    nodesToAddSize::Csize_t
    nodesToAdd::Ptr{UA_AddNodesItem}
end

"""
    UA_BrowseRequest

BrowseRequest ^^^^^^^^^^^^^ Browse the references for one or more nodes from the server address space. 
"""
struct UA_BrowseRequest
    requestHeader::UA_RequestHeader
    view::UA_ViewDescription
    requestedMaxReferencesPerNode::UA_UInt32
    nodesToBrowseSize::Csize_t
    nodesToBrowse::Ptr{UA_BrowseDescription}
end

"""
    UA_WriteRequest

WriteRequest ^^^^^^^^^^^^
"""
struct UA_WriteRequest
    requestHeader::UA_RequestHeader
    nodesToWriteSize::Csize_t
    nodesToWrite::Ptr{UA_WriteValue}
end

"""
    UA_AddNodesResponse

AddNodesResponse ^^^^^^^^^^^^^^^^ Adds one or more nodes to the server address space. 
"""
struct UA_AddNodesResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_AddNodesResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_AttributeOperand

AttributeOperand ^^^^^^^^^^^^^^^^
"""
struct UA_AttributeOperand
    nodeId::UA_NodeId
    alias::UA_String
    browsePath::UA_RelativePath
    attributeId::UA_UInt32
    indexRange::UA_String
end

"""
    UA_DataChangeFilter

DataChangeFilter ^^^^^^^^^^^^^^^^
"""
struct UA_DataChangeFilter
    trigger::UA_DataChangeTrigger
    deadbandType::UA_UInt32
    deadbandValue::UA_Double
end

"""
    UA_EndpointDescription

EndpointDescription ^^^^^^^^^^^^^^^^^^^ The description of a endpoint that can be used to access a server. 
"""
struct UA_EndpointDescription
    endpointUrl::UA_String
    server::UA_ApplicationDescription
    serverCertificate::UA_ByteString
    securityMode::UA_MessageSecurityMode
    securityPolicyUri::UA_String
    userIdentityTokensSize::Csize_t
    userIdentityTokens::Ptr{UA_UserTokenPolicy}
    transportProfileUri::UA_String
    securityLevel::UA_Byte
end

"""
    UA_DeleteReferencesRequest

DeleteReferencesRequest ^^^^^^^^^^^^^^^^^^^^^^^ Delete one or more references from the server address space. 
"""
struct UA_DeleteReferencesRequest
    requestHeader::UA_RequestHeader
    referencesToDeleteSize::Csize_t
    referencesToDelete::Ptr{UA_DeleteReferencesItem}
end

"""
    UA_TranslateBrowsePathsToNodeIdsRequest

TranslateBrowsePathsToNodeIdsRequest ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Translates one or more paths in the server address space. 
"""
struct UA_TranslateBrowsePathsToNodeIdsRequest
    requestHeader::UA_RequestHeader
    browsePathsSize::Csize_t
    browsePaths::Ptr{UA_BrowsePath}
end

"""
    UA_FindServersResponse

FindServersResponse ^^^^^^^^^^^^^^^^^^^ Finds the servers known to the discovery server. 
"""
struct UA_FindServersResponse
    responseHeader::UA_ResponseHeader
    serversSize::Csize_t
    servers::Ptr{UA_ApplicationDescription}
end

"""
    UA_CreateSessionRequest

CreateSessionRequest ^^^^^^^^^^^^^^^^^^^^ Creates a new session with the server. 
"""
struct UA_CreateSessionRequest
    requestHeader::UA_RequestHeader
    clientDescription::UA_ApplicationDescription
    serverUri::UA_String
    endpointUrl::UA_String
    sessionName::UA_String
    clientNonce::UA_ByteString
    clientCertificate::UA_ByteString
    requestedSessionTimeout::UA_Double
    maxResponseMessageSize::UA_UInt32
end

"""
    UA_ContentFilterElement

ContentFilterElement ^^^^^^^^^^^^^^^^^^^^
"""
struct UA_ContentFilterElement
    filterOperator::UA_FilterOperator
    filterOperandsSize::Csize_t
    filterOperands::Ptr{UA_ExtensionObject}
end

"""
    UA_TranslateBrowsePathsToNodeIdsResponse

TranslateBrowsePathsToNodeIdsResponse ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Translates one or more paths in the server address space. 
"""
struct UA_TranslateBrowsePathsToNodeIdsResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_BrowsePathResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_BrowseResponse

BrowseResponse ^^^^^^^^^^^^^^ Browse the references for one or more nodes from the server address space. 
"""
struct UA_BrowseResponse
    responseHeader::UA_ResponseHeader
    resultsSize::Csize_t
    results::Ptr{UA_BrowseResult}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
    UA_CreateSessionResponse

CreateSessionResponse ^^^^^^^^^^^^^^^^^^^^^ Creates a new session with the server. 
"""
struct UA_CreateSessionResponse
    responseHeader::UA_ResponseHeader
    sessionId::UA_NodeId
    authenticationToken::UA_NodeId
    revisedSessionTimeout::UA_Double
    serverNonce::UA_ByteString
    serverCertificate::UA_ByteString
    serverEndpointsSize::Csize_t
    serverEndpoints::Ptr{UA_EndpointDescription}
    serverSoftwareCertificatesSize::Csize_t
    serverSoftwareCertificates::Ptr{UA_SignedSoftwareCertificate}
    serverSignature::UA_SignatureData
    maxRequestMessageSize::UA_UInt32
end

"""
    UA_ContentFilter

ContentFilter ^^^^^^^^^^^^^
"""
struct UA_ContentFilter
    elementsSize::Csize_t
    elements::Ptr{UA_ContentFilterElement}
end

"""
    UA_GetEndpointsResponse

GetEndpointsResponse ^^^^^^^^^^^^^^^^^^^^ Gets the endpoints used by the server. 
"""
struct UA_GetEndpointsResponse
    responseHeader::UA_ResponseHeader
    endpointsSize::Csize_t
    endpoints::Ptr{UA_EndpointDescription}
end

"""
    UA_EventFilter

EventFilter ^^^^^^^^^^^
"""
struct UA_EventFilter
    selectClausesSize::Csize_t
    selectClauses::Ptr{UA_SimpleAttributeOperand}
    whereClause::UA_ContentFilter
end

struct UA_Logger
    log::Ptr{Cvoid}
    context::Ptr{Cvoid}
    clear::Ptr{Cvoid}
end

"""
    UA_ConnectionConfig

.. \\_networking:

Networking Plugin API =====================

Connection ---------- Client-server connections are represented by a [`UA_Connection`](@ref). The connection is stateful and stores partially received messages, and so on. In addition, the connection contains function pointers to the underlying networking implementation. An example for this is the `send` function. So the connection encapsulates all the required networking functionality. This lets users on embedded (or otherwise exotic) systems implement their own networking plugins with a clear interface to the main open62541 library. 
"""
struct UA_ConnectionConfig
    protocolVersion::UA_UInt32
    recvBufferSize::UA_UInt32
    sendBufferSize::UA_UInt32
    localMaxMessageSize::UA_UInt32
    remoteMaxMessageSize::UA_UInt32
    localMaxChunkCount::UA_UInt32
    remoteMaxChunkCount::UA_UInt32
end

struct UA_ServerNetworkLayer
    handle::Ptr{Cvoid}
    statistics::Ptr{UA_NetworkStatistics}
    discoveryUrl::UA_String
    localConnectionConfig::UA_ConnectionConfig
    start::Ptr{Cvoid}
    listen::Ptr{Cvoid}
    stop::Ptr{Cvoid}
    clear::Ptr{Cvoid}
end

"""
    UA_SecurityPolicySignatureAlgorithm

SecurityPolicy Interface Definition ----------------------------------- 
"""
struct UA_SecurityPolicySignatureAlgorithm
    uri::UA_String
    verify::Ptr{Cvoid}
    sign::Ptr{Cvoid}
    getLocalSignatureSize::Ptr{Cvoid}
    getRemoteSignatureSize::Ptr{Cvoid}
    getLocalKeyLength::Ptr{Cvoid}
    getRemoteKeyLength::Ptr{Cvoid}
end

struct UA_SecurityPolicyEncryptionAlgorithm
    uri::UA_String
    encrypt::Ptr{Cvoid}
    decrypt::Ptr{Cvoid}
    getLocalKeyLength::Ptr{Cvoid}
    getRemoteKeyLength::Ptr{Cvoid}
    getLocalBlockSize::Ptr{Cvoid}
    getRemoteBlockSize::Ptr{Cvoid}
    getLocalPlainTextBlockSize::Ptr{Cvoid}
    getRemotePlainTextBlockSize::Ptr{Cvoid}
end

struct UA_SecurityPolicyCryptoModule
    signatureAlgorithm::UA_SecurityPolicySignatureAlgorithm
    encryptionAlgorithm::UA_SecurityPolicyEncryptionAlgorithm
end

struct UA_SecurityPolicyAsymmetricModule
    makeCertificateThumbprint::Ptr{Cvoid}
    compareCertificateThumbprint::Ptr{Cvoid}
    cryptoModule::UA_SecurityPolicyCryptoModule
end

struct UA_SecurityPolicySymmetricModule
    generateKey::Ptr{Cvoid}
    generateNonce::Ptr{Cvoid}
    secureChannelNonceLength::Csize_t
    cryptoModule::UA_SecurityPolicyCryptoModule
end

struct UA_SecurityPolicyChannelModule
    newContext::Ptr{Cvoid}
    deleteContext::Ptr{Cvoid}
    setLocalSymEncryptingKey::Ptr{Cvoid}
    setLocalSymSigningKey::Ptr{Cvoid}
    setLocalSymIv::Ptr{Cvoid}
    setRemoteSymEncryptingKey::Ptr{Cvoid}
    setRemoteSymSigningKey::Ptr{Cvoid}
    setRemoteSymIv::Ptr{Cvoid}
    compareCertificate::Ptr{Cvoid}
end

struct UA_SecurityPolicy
    policyContext::Ptr{Cvoid}
    policyUri::UA_ByteString
    localCertificate::UA_ByteString
    asymmetricModule::UA_SecurityPolicyAsymmetricModule
    symmetricModule::UA_SecurityPolicySymmetricModule
    certificateSigningAlgorithm::UA_SecurityPolicySignatureAlgorithm
    channelModule::UA_SecurityPolicyChannelModule
    logger::Ptr{UA_Logger}
    updateCertificateAndPrivateKey::Ptr{Cvoid}
    clear::Ptr{Cvoid}
end

"""
    UA_GlobalNodeLifecycle

.. \\_information-modelling:

Information Modelling =====================

Information modelling in OPC UA combines concepts from object-orientation and semantic modelling. At the core, an OPC UA information model is a graph made up of

- Nodes: There are eight possible Node types (variable, object, method, ...) - References: Typed and directed relations between two nodes

Every node is identified by a unique (within the server) :ref:`nodeid`. Reference are triples of the form ``(source-nodeid, referencetype-nodeid, target-nodeid)``. An example reference between nodes is a ``hasTypeDefinition`` reference between a Variable and its VariableType. Some ReferenceTypes are *hierarchic* and must not form *directed loops*. See the section on :ref:`ReferenceTypes <referencetypenode>` for more details on possible references and their semantics.

**Warning!!** The structures defined in this section are only relevant for the developers of custom Nodestores. The interaction with the information model is possible only via the OPC UA :ref:`services`. So the following sections are purely informational so that users may have a clear mental model of the underlying representation.

.. \\_node-lifecycle:

Node Lifecycle: Constructors, Destructors and Node Contexts -----------------------------------------------------------

To finalize the instantiation of a node, a (user-defined) constructor callback is executed. There can be both a global constructor for all nodes and node-type constructor specific to the TypeDefinition of the new node (attached to an ObjectTypeNode or VariableTypeNode).

In the hierarchy of ObjectTypes and VariableTypes, only the constructor of the (lowest) type defined for the new node is executed. Note that every Object and Variable can have only one ``isTypeOf`` reference. But type-nodes can technically have several ``hasSubType`` references to implement multiple inheritance. Issues of (multiple) inheritance in the constructor need to be solved by the user.

When a node is destroyed, the node-type destructor is called before the global destructor. So the overall node lifecycle is as follows:

1. Global Constructor (set in the server config) 2. Node-Type Constructor (for VariableType or ObjectTypes) 3. (Usage-period of the Node) 4. Node-Type Destructor 5. Global Destructor

The constructor and destructor callbacks can be set to ``NULL`` and are not used in that case. If the node-type constructor fails, the global destructor will be called before removing the node. The destructors are assumed to never fail.

Every node carries a user-context and a constructor-context pointer. The user-context is used to attach custom data to a node. But the (user-defined) constructors and destructors may replace the user-context pointer if they wish to do so. The initial value for the constructor-context is ``NULL``. When the ``AddNodes`` service is used over the network, the user-context pointer of the new node is also initially set to ``NULL``.

Global Node Lifecycle ~~~~~~~~~~~~~~~~~~~~~~ Global constructor and destructor callbacks used for every node type. To be set in the server config.
"""
struct UA_GlobalNodeLifecycle
    constructor::Ptr{Cvoid}
    destructor::Ptr{Cvoid}
    createOptionalChild::Ptr{Cvoid}
    generateChildNodeId::Ptr{Cvoid}
end

"""
    UA_AccessControl

.. \\_access-control:

Access Control Plugin API ========================= The access control callback is used to authenticate sessions and grant access rights accordingly.

The ``sessionId`` and ``sessionContext`` can be both NULL. This is the case when, for example, a MonitoredItem (the underlying Subscription) is detached from its Session but continues to run. 
"""
struct UA_AccessControl
    context::Ptr{Cvoid}
    clear::Ptr{Cvoid}
    userTokenPoliciesSize::Csize_t
    userTokenPolicies::Ptr{UA_UserTokenPolicy}
    activateSession::Ptr{Cvoid}
    closeSession::Ptr{Cvoid}
    getUserRightsMask::Ptr{Cvoid}
    getUserAccessLevel::Ptr{Cvoid}
    getUserExecutable::Ptr{Cvoid}
    getUserExecutableOnObject::Ptr{Cvoid}
    allowAddNode::Ptr{Cvoid}
    allowAddReference::Ptr{Cvoid}
    allowDeleteNode::Ptr{Cvoid}
    allowDeleteReference::Ptr{Cvoid}
    allowBrowseNode::Ptr{Cvoid}
    allowTransferSubscription::Ptr{Cvoid}
end

# typedef void ( * UA_Server_AsyncOperationNotifyCallback ) ( UA_Server * server )
const UA_Server_AsyncOperationNotifyCallback = Ptr{Cvoid}

struct UA_Nodestore
    context::Ptr{Cvoid}
    clear::Ptr{Cvoid}
    newNode::Ptr{Cvoid}
    deleteNode::Ptr{Cvoid}
    getNode::Ptr{Cvoid}
    releaseNode::Ptr{Cvoid}
    getNodeCopy::Ptr{Cvoid}
    insertNode::Ptr{Cvoid}
    replaceNode::Ptr{Cvoid}
    removeNode::Ptr{Cvoid}
    getReferenceTypeId::Ptr{Cvoid}
    iterate::Ptr{Cvoid}
end

"""
    UA_CertificateVerification

Public Key Infrastructure Integration ===================================== This file contains interface definitions for integration in a Public Key Infrastructure (PKI). Currently only one plugin interface is defined.

Certificate Verification ------------------------ This plugin verifies that the origin of the certificate is trusted. It does not assign any access rights/roles to the holder of the certificate.

Usually, implementations of the certificate verification plugin provide an initialization method that takes a trust-list and a revocation-list as input. The lifecycle of the plugin is attached to a server or client config. The ``clear`` method is called automatically when the config is destroyed. 
"""
struct UA_CertificateVerification
    context::Ptr{Cvoid}
    verifyCertificate::Ptr{Cvoid}
    verifyApplicationURI::Ptr{Cvoid}
    clear::Ptr{Cvoid}
end

struct UA_DurationRange
    min::UA_Duration
    max::UA_Duration
end

struct UA_UInt32Range
    min::UA_UInt32
    max::UA_UInt32
end

"""
    UA_ServerConfig

| Field             | Note                                                                                                                                               |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| networkLayersSize | .. note:: See the section on :ref:`generic-types`. Examples for working with custom data types are provided in ``/examples/custom\\_datatype/``.   |
| accessControl     | .. note:: See the section for :ref:`node lifecycle handling<node-lifecycle>`.                                                                      |
| nodestore         | .. note:: See the section for :ref:`async operations<async-operations>`.                                                                           |
"""
struct UA_ServerConfig
    logger::UA_Logger
    buildInfo::UA_BuildInfo
    applicationDescription::UA_ApplicationDescription
    serverCertificate::UA_ByteString
    shutdownDelay::UA_Double
    verifyRequestTimestamp::UA_RuleHandling
    allowEmptyVariables::UA_RuleHandling
    customDataTypes::Ptr{UA_DataTypeArray}
    networkLayersSize::Csize_t
    networkLayers::Ptr{UA_ServerNetworkLayer}
    customHostname::UA_String
    securityPoliciesSize::Csize_t
    securityPolicies::Ptr{UA_SecurityPolicy}
    endpointsSize::Csize_t
    endpoints::Ptr{UA_EndpointDescription}
    securityPolicyNoneDiscoveryOnly::UA_Boolean
    nodeLifecycle::UA_GlobalNodeLifecycle
    accessControl::UA_AccessControl
    asyncOperationTimeout::UA_Double
    maxAsyncOperationQueueSize::Csize_t
    asyncOperationNotifyCallback::UA_Server_AsyncOperationNotifyCallback
    nodestore::UA_Nodestore
    certificateVerification::UA_CertificateVerification
    maxSecureChannels::UA_UInt16
    maxSecurityTokenLifetime::UA_UInt32
    maxSessions::UA_UInt16
    maxSessionTimeout::UA_Double
    maxNodesPerRead::UA_UInt32
    maxNodesPerWrite::UA_UInt32
    maxNodesPerMethodCall::UA_UInt32
    maxNodesPerBrowse::UA_UInt32
    maxNodesPerRegisterNodes::UA_UInt32
    maxNodesPerTranslateBrowsePathsToNodeIds::UA_UInt32
    maxNodesPerNodeManagement::UA_UInt32
    maxMonitoredItemsPerCall::UA_UInt32
    maxReferencesPerNode::UA_UInt32
    maxSubscriptions::UA_UInt32
    maxSubscriptionsPerSession::UA_UInt32
    publishingIntervalLimits::UA_DurationRange
    lifeTimeCountLimits::UA_UInt32Range
    keepAliveCountLimits::UA_UInt32Range
    maxNotificationsPerPublish::UA_UInt32
    enableRetransmissionQueue::UA_Boolean
    maxRetransmissionQueueSize::UA_UInt32
    maxMonitoredItems::UA_UInt32
    maxMonitoredItemsPerSubscription::UA_UInt32
    samplingIntervalLimits::UA_DurationRange
    queueSizeLimits::UA_UInt32Range
    maxPublishReqPerSession::UA_UInt32
    monitoredItemRegisterCallback::Ptr{Cvoid}
end

mutable struct UA_Client end

function UA_parseEndpointUrl(endpointUrl, outHostname, outPort, outPath)
    @ccall libopen62541.UA_parseEndpointUrl(endpointUrl::Ptr{UA_String}, outHostname::Ptr{UA_String}, outPort::Ptr{UA_UInt16}, outPath::Ptr{UA_String})::UA_StatusCode
end

function UA_parseEndpointUrlEthernet(endpointUrl, target, vid, pcp)
    @ccall libopen62541.UA_parseEndpointUrlEthernet(endpointUrl::Ptr{UA_String}, target::Ptr{UA_String}, vid::Ptr{UA_UInt16}, pcp::Ptr{UA_Byte})::UA_StatusCode
end

function UA_readNumber(buf, buflen, number)
    @ccall libopen62541.UA_readNumber(buf::Ptr{UA_Byte}, buflen::Csize_t, number::Ptr{UA_UInt32})::Csize_t
end

function UA_readNumberWithBase(buf, buflen, number, base)
    @ccall libopen62541.UA_readNumberWithBase(buf::Ptr{UA_Byte}, buflen::Csize_t, number::Ptr{UA_UInt32}, base::UA_Byte)::Csize_t
end

function UA_RelativePath_parse(rp, str)
    @ccall libopen62541.UA_RelativePath_parse(rp::Ptr{UA_RelativePath}, str::UA_String)::UA_StatusCode
end

"""
    UA_LogLevel

Logging Plugin API ==================

Servers and clients define a logger in their configuration. The logger is a plugin. A default plugin that logs to ``stdout`` is provided as an example. The logger plugin is stateful and can point to custom data. So it is possible to keep open file handlers in the logger context.

Every log-message consists of a log-level, a log-category and a string message content. The timestamp of the log-message is created within the logger. 
"""
@cenum UA_LogLevel::UInt32 begin
    UA_LOGLEVEL_TRACE = 0
    UA_LOGLEVEL_DEBUG = 1
    UA_LOGLEVEL_INFO = 2
    UA_LOGLEVEL_WARNING = 3
    UA_LOGLEVEL_ERROR = 4
    UA_LOGLEVEL_FATAL = 5
end

@cenum UA_LogCategory::UInt32 begin
    UA_LOGCATEGORY_NETWORK = 0
    UA_LOGCATEGORY_SECURECHANNEL = 1
    UA_LOGCATEGORY_SESSION = 2
    UA_LOGCATEGORY_SERVER = 3
    UA_LOGCATEGORY_CLIENT = 4
    UA_LOGCATEGORY_USERLAND = 5
    UA_LOGCATEGORY_SECURITYPOLICY = 6
end

@cenum UA_ConnectionState::UInt32 begin
    UA_CONNECTIONSTATE_CLOSED = 0
    UA_CONNECTIONSTATE_OPENING = 1
    UA_CONNECTIONSTATE_ESTABLISHED = 2
end

mutable struct UA_SecureChannel end

"""
    UA_Connection

********************************* amalgamated original file "/workspace/srcdir/open62541/include/open62541/plugin/network.h" **********************************
"""
struct UA_Connection
    state::UA_ConnectionState
    channel::Ptr{UA_SecureChannel}
    sockfd::SOCKET
    openingDate::UA_DateTime
    handle::Ptr{Cvoid}
    getSendBuffer::Ptr{Cvoid}
    releaseSendBuffer::Ptr{Cvoid}
    send::Ptr{Cvoid}
    recv::Ptr{Cvoid}
    releaseRecvBuffer::Ptr{Cvoid}
    close::Ptr{Cvoid}
    free::Ptr{Cvoid}
end

"""
    UA_Server_processBinaryMessage(server, connection, message)

Server Network Layer -------------------- The server exposes two functions to interact with remote clients: `processBinaryMessage` and `removeConnection`. These functions are called by the server network layer.

It is the job of the server network layer to listen on a TCP socket, to accept new connections, to call the server with received messages and to signal closed connections to the server.

The network layer is part of the server config. So users can provide a custom implementation if the provided example does not fit their architecture. The network layer is invoked only from the server's main loop. So the network layer does not need to be thread-safe. If the networklayer receives a positive duration for blocking listening, the server's main loop will block until a message is received or the duration times out. 
"""
function UA_Server_processBinaryMessage(server, connection, message)
    @ccall libopen62541.UA_Server_processBinaryMessage(server::Ptr{UA_Server}, connection::Ptr{UA_Connection}, message::Ptr{UA_ByteString})::Cvoid
end

function UA_Server_removeConnection(server, connection)
    @ccall libopen62541.UA_Server_removeConnection(server::Ptr{UA_Server}, connection::Ptr{UA_Connection})::Cvoid
end

# typedef UA_Connection ( * UA_ConnectClientConnection ) ( UA_ConnectionConfig config , UA_String endpointUrl , UA_UInt32 timeout , const UA_Logger * logger )
const UA_ConnectClientConnection = Ptr{Cvoid}

function UA_SecurityPolicy_getRemoteAsymEncryptionBufferLengthOverhead(securityPolicy, channelContext, maxEncryptionLength)
    @ccall libopen62541.UA_SecurityPolicy_getRemoteAsymEncryptionBufferLengthOverhead(securityPolicy::Ptr{UA_SecurityPolicy}, channelContext::Ptr{Cvoid}, maxEncryptionLength::Csize_t)::Csize_t
end

function UA_SecurityPolicy_getSecurityPolicyByUri(server, securityPolicyUri)
    @ccall libopen62541.UA_SecurityPolicy_getSecurityPolicyByUri(server::Ptr{UA_Server}, securityPolicyUri::Ptr{UA_ByteString})::Ptr{UA_SecurityPolicy}
end

@cenum ZIP_CMP::Int32 begin
    ZIP_CMP_LESS = -1
    ZIP_CMP_EQ = 0
    ZIP_CMP_MORE = 1
end

function ZIP_FFS32(v)
    @ccall libopen62541.ZIP_FFS32(v::Cuint)::Cuchar
end

@cenum aa_cmp::Int32 begin
    AA_CMP_LESS = -1
    AA_CMP_EQ = 0
    AA_CMP_MORE = 1
end

struct aa_entry
    left::Ptr{aa_entry}
    right::Ptr{aa_entry}
    level::Cuint
end

struct aa_head
    root::Ptr{aa_entry}
    cmp::Ptr{Cvoid}
    entry_offset::Cuint
    key_offset::Cuint
end

function aa_init(head, cmp, entry_offset, key_offset)
    @ccall libopen62541.aa_init(head::Ptr{aa_head}, cmp::Ptr{Cvoid}, entry_offset::Cuint, key_offset::Cuint)::Cvoid
end

function aa_insert(head, elem)
    @ccall libopen62541.aa_insert(head::Ptr{aa_head}, elem::Ptr{Cvoid})::Cvoid
end

function aa_remove(head, elem)
    @ccall libopen62541.aa_remove(head::Ptr{aa_head}, elem::Ptr{Cvoid})::Cvoid
end

function aa_find(head, key)
    @ccall libopen62541.aa_find(head::Ptr{aa_head}, key::Ptr{Cvoid})::Ptr{Cvoid}
end

function aa_min(head)
    @ccall libopen62541.aa_min(head::Ptr{aa_head})::Ptr{Cvoid}
end

function aa_max(head)
    @ccall libopen62541.aa_max(head::Ptr{aa_head})::Ptr{Cvoid}
end

function aa_next(head, elem)
    @ccall libopen62541.aa_next(head::Ptr{aa_head}, elem::Ptr{Cvoid})::Ptr{Cvoid}
end

function aa_prev(head, elem)
    @ccall libopen62541.aa_prev(head::Ptr{aa_head}, elem::Ptr{Cvoid})::Ptr{Cvoid}
end

"""
    UA_NodeTypeLifecycle

Node Type Lifecycle ~~~~~~~~~~~~~~~~~~~ Constructor and destructors for specific object and variable types. 
"""
struct UA_NodeTypeLifecycle
    constructor::Ptr{Cvoid}
    destructor::Ptr{Cvoid}
end

struct UA_ReferenceTypeSet
    bits::NTuple{4, UA_UInt32}
end

"""
    UA_ReferenceTarget

Base Node Attributes --------------------

Nodes contain attributes according to their node type. The base node attributes are common to all node types. In the OPC UA :ref:`services`, attributes are referred to via the :ref:`nodeid` of the containing node and an integer :ref:`attribute-id`.

Internally, open62541 uses `[`UA_Node`](@ref)` in places where the exact node type is not known or not important. The ``nodeClass`` attribute is used to ensure the correctness of casting from `[`UA_Node`](@ref)` to a specific node type. 
"""
struct UA_ReferenceTarget
    idTreeEntry::aa_entry
    nameTreeEntry::aa_entry
    targetIdHash::UA_UInt32
    targetNameHash::UA_UInt32
    targetId::UA_ExpandedNodeId
end

struct UA_NodeReferenceKind
    idTreeRoot::Ptr{aa_entry}
    nameTreeRoot::Ptr{aa_entry}
    referenceTypeIndex::UA_Byte
    isInverse::UA_Boolean
end

struct UA_NodeHead
    nodeId::UA_NodeId
    nodeClass::UA_NodeClass
    browseName::UA_QualifiedName
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    referencesSize::Csize_t
    references::Ptr{UA_NodeReferenceKind}
    context::Ptr{Cvoid}
    constructed::UA_Boolean
end

"""
    UA_ExternalValueCallback

.. \\_value-callback:

Value Callback ~~~~~~~~~~~~~~ Value Callbacks can be attached to variable and variable type nodes. If not ``NULL``, they are called before reading and after writing respectively. 
"""
struct UA_ExternalValueCallback
    notificationRead::Ptr{Cvoid}
    userWrite::Ptr{Cvoid}
end

struct __JL_Ctag_374
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_374}, f::Symbol)
    f === :data && return Ptr{__JL_Ctag_375}(x + 0)
    f === :dataSource && return Ptr{UA_DataSource}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_374, f::Symbol)
    r = Ref{__JL_Ctag_374}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_374}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_374}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_VariableNode
    head::UA_NodeHead
    dataType::UA_NodeId
    valueRank::UA_Int32
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
    valueBackend::UA_ValueBackend
    valueSource::UA_ValueSource
    value::__JL_Ctag_374
    accessLevel::UA_Byte
    minimumSamplingInterval::UA_Double
    historizing::UA_Boolean
    isDynamic::UA_Boolean
end

struct __JL_Ctag_366
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_366}, f::Symbol)
    f === :data && return Ptr{__JL_Ctag_367}(x + 0)
    f === :dataSource && return Ptr{UA_DataSource}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_366, f::Symbol)
    r = Ref{__JL_Ctag_366}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_366}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_366}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
    UA_VariableTypeNode

.. \\_variabletypenode:

VariableTypeNode ----------------

VariableTypes are used to provide type definitions for variables. VariableTypes constrain the data type, value rank and array dimensions attributes of variable instances. Furthermore, instantiating from a specific variable type may provide semantic information. For example, an instance from ``MotorTemperatureVariableType`` is more meaningful than a float variable instantiated from ``BaseDataVariable``. 
"""
struct UA_VariableTypeNode
    head::UA_NodeHead
    dataType::UA_NodeId
    valueRank::UA_Int32
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
    valueBackend::UA_ValueBackend
    valueSource::UA_ValueSource
    value::__JL_Ctag_366
    isAbstract::UA_Boolean
    lifecycle::UA_NodeTypeLifecycle
end

# typedef UA_StatusCode ( * UA_MethodCallback ) ( UA_Server * server , const UA_NodeId * sessionId , void * sessionContext , const UA_NodeId * methodId , void * methodContext , const UA_NodeId * objectId , void * objectContext , size_t inputSize , const UA_Variant * input , size_t outputSize , UA_Variant * output )
"""
.. \\_methodnode:

MethodNode ----------

Methods define callable functions and are invoked using the :ref:`Call <method-services>` service. MethodNodes may have special properties (variable children with a ``hasProperty`` reference) with the :ref:`qualifiedname` ``(0, "InputArguments")`` and ``(0, "OutputArguments")``. The input and output arguments are both described via an array of `[`UA_Argument`](@ref)`. While the Call service uses a generic array of :ref:`variant` for input and output, the actual argument values are checked to match the signature of the MethodNode.

Note that the same MethodNode may be referenced from several objects (and object types). For this, the NodeId of the method *and of the object providing context* is part of a Call request message. 
"""
const UA_MethodCallback = Ptr{Cvoid}

struct UA_MethodNode
    head::UA_NodeHead
    executable::UA_Boolean
    method::UA_MethodCallback
    async::UA_Boolean
end

"""
    UA_ObjectNode

ObjectNode ----------

Objects are used to represent systems, system components, real-world objects and software objects. Objects are instances of an :ref:`object type<objecttypenode>` and may contain variables, methods and further objects. 
"""
struct UA_ObjectNode
    head::UA_NodeHead
    eventNotifier::UA_Byte
end

"""
    UA_ObjectTypeNode

.. \\_objecttypenode:

ObjectTypeNode --------------

ObjectTypes provide definitions for Objects. Abstract objects cannot be instantiated. See :ref:`node-lifecycle` for the use of constructor and destructor callbacks. 
"""
struct UA_ObjectTypeNode
    head::UA_NodeHead
    isAbstract::UA_Boolean
    lifecycle::UA_NodeTypeLifecycle
end

"""
    UA_ReferenceTypeNode

.. \\_referencetypenode:

ReferenceTypeNode -----------------

Each reference between two nodes is typed with a ReferenceType that gives meaning to the relation. The OPC UA standard defines a set of ReferenceTypes as a mandatory part of OPC UA information models.

- Abstract ReferenceTypes cannot be used in actual references and are only used to structure the ReferenceTypes hierarchy - Symmetric references have the same meaning from the perspective of the source and target node

The figure below shows the hierarchy of the standard ReferenceTypes (arrows indicate a ``hasSubType`` relation). Refer to Part 3 of the OPC UA specification for the full semantics of each ReferenceType.

.. graphviz::

digraph tree {

node [height=0, shape=box, fillcolor="#E5E5E5", concentrate=true]

references [label="References(Abstract, Symmetric)"] hierarchical\\_references [label="HierarchicalReferences(Abstract)"] references -> hierarchical\\_references

nonhierarchical\\_references [label="NonHierarchicalReferences(Abstract, Symmetric)"] references -> nonhierarchical\\_references

haschild [label="HasChild(Abstract)"] hierarchical\\_references -> haschild

aggregates [label="Aggregates(Abstract)"] haschild -> aggregates

organizes [label="Organizes"] hierarchical\\_references -> organizes

hascomponent [label="HasComponent"] aggregates -> hascomponent

hasorderedcomponent [label="HasOrderedComponent"] hascomponent -> hasorderedcomponent

hasproperty [label="HasProperty"] aggregates -> hasproperty

hassubtype [label="HasSubtype"] haschild -> hassubtype

hasmodellingrule [label="HasModellingRule"] nonhierarchical\\_references -> hasmodellingrule

hastypedefinition [label="HasTypeDefinition"] nonhierarchical\\_references -> hastypedefinition

hasencoding [label="HasEncoding"] nonhierarchical\\_references -> hasencoding

hasdescription [label="HasDescription"] nonhierarchical\\_references -> hasdescription

haseventsource [label="HasEventSource"] hierarchical\\_references -> haseventsource

hasnotifier [label="HasNotifier"] hierarchical\\_references -> hasnotifier

generatesevent [label="GeneratesEvent"] nonhierarchical\\_references -> generatesevent

alwaysgeneratesevent [label="AlwaysGeneratesEvent"] generatesevent -> alwaysgeneratesevent

{rank=same hierarchical\\_references nonhierarchical\\_references} {rank=same generatesevent haseventsource hasmodellingrule hasencoding hassubtype} {rank=same alwaysgeneratesevent hasproperty}

}

The ReferenceType hierarchy can be extended with user-defined ReferenceTypes. Many Companion Specifications for OPC UA define new ReferenceTypes to be used in their domain of interest.

For the following example of custom ReferenceTypes, we attempt to model the structure of a technical system. For this, we introduce two custom ReferenceTypes. First, the hierarchical ``contains`` ReferenceType indicates that a system (represented by an OPC UA object) contains a component (or subsystem). This gives rise to a tree-structure of containment relations. For example, the motor (object) is contained in the car and the crankshaft is contained in the motor. Second, the symmetric ``connectedTo`` ReferenceType indicates that two components are connected. For example, the motor's crankshaft is connected to the gear box. Connections are independent of the containment hierarchy and can induce a general graph-structure. Further subtypes of ``connectedTo`` could be used to differentiate between physical, electrical and information related connections. A client can then learn the layout of a (physical) system represented in an OPC UA information model based on a common understanding of just two custom reference types. 
"""
struct UA_ReferenceTypeNode
    head::UA_NodeHead
    isAbstract::UA_Boolean
    symmetric::UA_Boolean
    inverseName::UA_LocalizedText
    referenceTypeIndex::UA_Byte
    subTypes::UA_ReferenceTypeSet
end

"""
    UA_DataTypeNode

.. \\_datatypenode:

DataTypeNode ------------

DataTypes represent simple and structured data types. DataTypes may contain arrays. But they always describe the structure of a single instance. In open62541, DataTypeNodes in the information model hierarchy are matched to `[`UA_DataType`](@ref)` type descriptions for :ref:`generic-types` via their NodeId.

Abstract DataTypes (e.g. ``Number``) cannot be the type of actual values. They are used to constrain values to possible child DataTypes (e.g. ``UInt32``). 
"""
struct UA_DataTypeNode
    head::UA_NodeHead
    isAbstract::UA_Boolean
end

"""
    UA_ViewNode

ViewNode --------

Each View defines a subset of the Nodes in the AddressSpace. Views can be used when browsing an information model to focus on a subset of nodes and references only. ViewNodes can be created and be interacted with. But their use in the :ref:`Browse<view-services>` service is currently unsupported in open62541. 
"""
struct UA_ViewNode
    head::UA_NodeHead
    eventNotifier::UA_Byte
    containsNoLoops::UA_Boolean
end

"""
    UA_Node

Node Union ----------

A union that represents any kind of node. The node head can always be used. Check the NodeClass before accessing specific content.
"""
struct UA_Node
    data::NTuple{440, UInt8}
end

function Base.getproperty(x::Ptr{UA_Node}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :variableNode && return Ptr{UA_VariableNode}(x + 0)
    f === :variableTypeNode && return Ptr{UA_VariableTypeNode}(x + 0)
    f === :methodNode && return Ptr{UA_MethodNode}(x + 0)
    f === :objectNode && return Ptr{UA_ObjectNode}(x + 0)
    f === :objectTypeNode && return Ptr{UA_ObjectTypeNode}(x + 0)
    f === :referenceTypeNode && return Ptr{UA_ReferenceTypeNode}(x + 0)
    f === :dataTypeNode && return Ptr{UA_DataTypeNode}(x + 0)
    f === :viewNode && return Ptr{UA_ViewNode}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_Node, f::Symbol)
    r = Ref{UA_Node}(x)
    ptr = Base.unsafe_convert(Ptr{UA_Node}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_Node}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

# typedef void ( * UA_NodestoreVisitor ) ( void * visitorCtx , const UA_Node * node )
"""
Nodestore Plugin API --------------------

The following definitions are used for implementing custom node storage backends. **Most users will want to use the default nodestore and don't need to work with the nodestore API**.

Outside of custom nodestore implementations, users should not manually edit nodes. Please use the OPC UA services for that. Otherwise, all consistency checks are omitted. This can crash the application eventually. 
"""
const UA_NodestoreVisitor = Ptr{Cvoid}

function UA_Node_setAttributes(node, attributes, attributeType)
    @ccall libopen62541.UA_Node_setAttributes(node::Ptr{UA_Node}, attributes::Ptr{Cvoid}, attributeType::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Node_copy(src, dst)
    @ccall libopen62541.UA_Node_copy(src::Ptr{UA_Node}, dst::Ptr{UA_Node})::UA_StatusCode
end

function UA_Node_copy_alloc(src)
    @ccall libopen62541.UA_Node_copy_alloc(src::Ptr{UA_Node})::Ptr{UA_Node}
end

function UA_Node_addReference(node, refTypeIndex, isForward, targetNodeId, targetBrowseNameHash)
    @ccall libopen62541.UA_Node_addReference(node::Ptr{UA_Node}, refTypeIndex::UA_Byte, isForward::UA_Boolean, targetNodeId::Ptr{UA_ExpandedNodeId}, targetBrowseNameHash::UA_UInt32)::UA_StatusCode
end

function UA_Node_deleteReference(node, refTypeIndex, isForward, targetNodeId)
    @ccall libopen62541.UA_Node_deleteReference(node::Ptr{UA_Node}, refTypeIndex::UA_Byte, isForward::UA_Boolean, targetNodeId::Ptr{UA_ExpandedNodeId})::UA_StatusCode
end

function UA_Node_deleteReferencesSubset(node, keepSet)
    @ccall libopen62541.UA_Node_deleteReferencesSubset(node::Ptr{UA_Node}, keepSet::Ptr{UA_ReferenceTypeSet})::Cvoid
end

function UA_Node_deleteReferences(node)
    @ccall libopen62541.UA_Node_deleteReferences(node::Ptr{UA_Node})::Cvoid
end

function UA_Node_clear(node)
    @ccall libopen62541.UA_Node_clear(node::Ptr{UA_Node})::Cvoid
end

"""
.. \\_server:

Server ======

.. \\_server-configuration:

Server Configuration --------------------

The configuration structure is passed to the server during initialization. The server expects that the configuration is not modified during runtime. Currently, only one server can use a configuration at a time. During shutdown, the server will clean up the parts of the configuration that are modified at runtime through the provided API.

Examples for configurations are provided in the ``/plugins`` folder. The usual usage is as follows:

1. Create a server configuration with default settings as a starting point 2. Modifiy the configuration, e.g. by adding a server certificate 3. Instantiate a server with it 4. After shutdown of the server, clean up the configuration (free memory)

The :ref:`tutorials` provide a good starting point for this. 
"""
mutable struct UA_PubSubConfiguration end

function UA_ServerConfig_clean(config)
    @ccall libopen62541.UA_ServerConfig_clean(config::Ptr{UA_ServerConfig})::Cvoid
end

function UA_Server_newWithConfig(config)
    @ccall libopen62541.UA_Server_newWithConfig(config::Ptr{UA_ServerConfig})::Ptr{UA_Server}
end

function UA_Server_delete(server)
    @ccall libopen62541.UA_Server_delete(server::Ptr{UA_Server})::Cvoid
end

function UA_Server_getConfig(server)
    @ccall libopen62541.UA_Server_getConfig(server::Ptr{UA_Server})::Ptr{UA_ServerConfig}
end

function UA_Server_run(server, running)
    @ccall libopen62541.UA_Server_run(server::Ptr{UA_Server}, running::Ptr{UA_Boolean})::UA_StatusCode
end

function UA_Server_run_startup(server)
    @ccall libopen62541.UA_Server_run_startup(server::Ptr{UA_Server})::UA_StatusCode
end

function UA_Server_run_iterate(server, waitInternal)
    @ccall libopen62541.UA_Server_run_iterate(server::Ptr{UA_Server}, waitInternal::UA_Boolean)::UA_UInt16
end

function UA_Server_run_shutdown(server)
    @ccall libopen62541.UA_Server_run_shutdown(server::Ptr{UA_Server})::UA_StatusCode
end

# typedef void ( * UA_ServerCallback ) ( UA_Server * server , void * data )
"""
Timed Callbacks --------------- 
"""
const UA_ServerCallback = Ptr{Cvoid}

function UA_Server_addTimedCallback(server, callback, data, date, callbackId)
    @ccall libopen62541.UA_Server_addTimedCallback(server::Ptr{UA_Server}, callback::UA_ServerCallback, data::Ptr{Cvoid}, date::UA_DateTime, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Server_addRepeatedCallback(server, callback, data, interval_ms, callbackId)
    @ccall libopen62541.UA_Server_addRepeatedCallback(server::Ptr{UA_Server}, callback::UA_ServerCallback, data::Ptr{Cvoid}, interval_ms::UA_Double, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Server_changeRepeatedCallbackInterval(server, callbackId, interval_ms)
    @ccall libopen62541.UA_Server_changeRepeatedCallbackInterval(server::Ptr{UA_Server}, callbackId::UA_UInt64, interval_ms::UA_Double)::UA_StatusCode
end

function UA_Server_read(server, item, timestamps)
    @ccall libopen62541.UA_Server_read(server::Ptr{UA_Server}, item::Ptr{UA_ReadValueId}, timestamps::UA_TimestampsToReturn)::UA_DataValue
end

function __UA_Server_read(server, nodeId, attributeId, v)
    @ccall libopen62541.__UA_Server_read(server::Ptr{UA_Server}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId, v::Ptr{Cvoid})::UA_StatusCode
end

function UA_Server_write(server, value)
    @ccall libopen62541.UA_Server_write(server::Ptr{UA_Server}, value::Ptr{UA_WriteValue})::UA_StatusCode
end

function __UA_Server_write(server, nodeId, attributeId, attr_type, attr)
    @ccall libopen62541.__UA_Server_write(server::Ptr{UA_Server}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId, attr_type::Ptr{UA_DataType}, attr::Ptr{Cvoid})::UA_StatusCode
end

"""
    UA_Server_browse(server, maxReferences, bd)

Browsing -------- 
"""
function UA_Server_browse(server, maxReferences, bd)
    @ccall libopen62541.UA_Server_browse(server::Ptr{UA_Server}, maxReferences::UA_UInt32, bd::Ptr{UA_BrowseDescription})::UA_BrowseResult
end

function UA_Server_browseNext(server, releaseContinuationPoint, continuationPoint)
    @ccall libopen62541.UA_Server_browseNext(server::Ptr{UA_Server}, releaseContinuationPoint::UA_Boolean, continuationPoint::Ptr{UA_ByteString})::UA_BrowseResult
end

function UA_Server_browseRecursive(server, bd, resultsSize, results)
    @ccall libopen62541.UA_Server_browseRecursive(server::Ptr{UA_Server}, bd::Ptr{UA_BrowseDescription}, resultsSize::Ptr{Csize_t}, results::Ptr{Ptr{UA_ExpandedNodeId}})::UA_StatusCode
end

function UA_Server_translateBrowsePathToNodeIds(server, browsePath)
    @ccall libopen62541.UA_Server_translateBrowsePathToNodeIds(server::Ptr{UA_Server}, browsePath::Ptr{UA_BrowsePath})::UA_BrowsePathResult
end

function UA_Server_browseSimplifiedBrowsePath(server, origin, browsePathSize, browsePath)
    @ccall libopen62541.UA_Server_browseSimplifiedBrowsePath(server::Ptr{UA_Server}, origin::UA_NodeId, browsePathSize::Csize_t, browsePath::Ptr{UA_QualifiedName})::UA_BrowsePathResult
end

# typedef UA_StatusCode ( * UA_NodeIteratorCallback ) ( UA_NodeId childId , UA_Boolean isInverse , UA_NodeId referenceTypeId , void * handle )
const UA_NodeIteratorCallback = Ptr{Cvoid}

function UA_Server_forEachChildNodeCall(server, parentNodeId, callback, handle)
    @ccall libopen62541.UA_Server_forEachChildNodeCall(server::Ptr{UA_Server}, parentNodeId::UA_NodeId, callback::UA_NodeIteratorCallback, handle::Ptr{Cvoid})::UA_StatusCode
end

"""
    UA_Server_setAdminSessionContext(server, context)

Information Model Callbacks ---------------------------

There are three places where a callback from an information model to user-defined code can happen.

- Custom node constructors and destructors - Linking VariableNodes with an external data source - MethodNode callbacks
"""
function UA_Server_setAdminSessionContext(server, context)
    @ccall libopen62541.UA_Server_setAdminSessionContext(server::Ptr{UA_Server}, context::Ptr{Cvoid})::Cvoid
end

function UA_Server_setNodeTypeLifecycle(server, nodeId, lifecycle)
    @ccall libopen62541.UA_Server_setNodeTypeLifecycle(server::Ptr{UA_Server}, nodeId::UA_NodeId, lifecycle::UA_NodeTypeLifecycle)::UA_StatusCode
end

function UA_Server_getNodeContext(server, nodeId, nodeContext)
    @ccall libopen62541.UA_Server_getNodeContext(server::Ptr{UA_Server}, nodeId::UA_NodeId, nodeContext::Ptr{Ptr{Cvoid}})::UA_StatusCode
end

function UA_Server_setNodeContext(server, nodeId, nodeContext)
    @ccall libopen62541.UA_Server_setNodeContext(server::Ptr{UA_Server}, nodeId::UA_NodeId, nodeContext::Ptr{Cvoid})::UA_StatusCode
end

"""
    UA_Server_setVariableNode_dataSource(server, nodeId, dataSource)

.. \\_datasource:

Data Source Callback ^^^^^^^^^^^^^^^^^^^^

The server has a unique way of dealing with the content of variables. Instead of storing a variant attached to the variable node, the node can point to a function with a local data provider. Whenever the value attribute is read, the function will be called and asked to provide a [`UA_DataValue`](@ref) return value that contains the value content and additional timestamps.

It is expected that the read callback is implemented. The write callback can be set to a null-pointer. 
"""
function UA_Server_setVariableNode_dataSource(server, nodeId, dataSource)
    @ccall libopen62541.UA_Server_setVariableNode_dataSource(server::Ptr{UA_Server}, nodeId::UA_NodeId, dataSource::UA_DataSource)::UA_StatusCode
end

function UA_Server_setVariableNode_valueCallback(server, nodeId, callback)
    @ccall libopen62541.UA_Server_setVariableNode_valueCallback(server::Ptr{UA_Server}, nodeId::UA_NodeId, callback::UA_ValueCallback)::UA_StatusCode
end

function UA_Server_setVariableNode_valueBackend(server, nodeId, valueBackend)
    @ccall libopen62541.UA_Server_setVariableNode_valueBackend(server::Ptr{UA_Server}, nodeId::UA_NodeId, valueBackend::UA_ValueBackend)::UA_StatusCode
end

# typedef void ( * UA_Server_DataChangeNotificationCallback ) ( UA_Server * server , UA_UInt32 monitoredItemId , void * monitoredItemContext , const UA_NodeId * nodeId , void * nodeContext , UA_UInt32 attributeId , const UA_DataValue * value )
const UA_Server_DataChangeNotificationCallback = Ptr{Cvoid}

# typedef void ( * UA_Server_EventNotificationCallback ) ( UA_Server * server , UA_UInt32 monId , void * monContext , size_t nEventFields , const UA_Variant * eventFields )
const UA_Server_EventNotificationCallback = Ptr{Cvoid}

function UA_Server_createDataChangeMonitoredItem(server, timestampsToReturn, item, monitoredItemContext, callback)
    @ccall libopen62541.UA_Server_createDataChangeMonitoredItem(server::Ptr{UA_Server}, timestampsToReturn::UA_TimestampsToReturn, item::UA_MonitoredItemCreateRequest, monitoredItemContext::Ptr{Cvoid}, callback::UA_Server_DataChangeNotificationCallback)::UA_MonitoredItemCreateResult
end

function UA_Server_deleteMonitoredItem(server, monitoredItemId)
    @ccall libopen62541.UA_Server_deleteMonitoredItem(server::Ptr{UA_Server}, monitoredItemId::UA_UInt32)::UA_StatusCode
end

function UA_Server_setMethodNode_callback(server, methodNodeId, methodCallback)
    @ccall libopen62541.UA_Server_setMethodNode_callback(server::Ptr{UA_Server}, methodNodeId::UA_NodeId, methodCallback::UA_MethodCallback)::UA_StatusCode
end

function UA_Server_writeObjectProperty(server, objectId, propertyName, value)
    @ccall libopen62541.UA_Server_writeObjectProperty(server::Ptr{UA_Server}, objectId::UA_NodeId, propertyName::UA_QualifiedName, value::UA_Variant)::UA_StatusCode
end

function UA_Server_writeObjectProperty_scalar(server, objectId, propertyName, value, type)
    @ccall libopen62541.UA_Server_writeObjectProperty_scalar(server::Ptr{UA_Server}, objectId::UA_NodeId, propertyName::UA_QualifiedName, value::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Server_readObjectProperty(server, objectId, propertyName, value)
    @ccall libopen62541.UA_Server_readObjectProperty(server::Ptr{UA_Server}, objectId::UA_NodeId, propertyName::UA_QualifiedName, value::Ptr{UA_Variant})::UA_StatusCode
end

function UA_Server_call(server, request)
    @ccall libopen62541.UA_Server_call(server::Ptr{UA_Server}, request::Ptr{UA_CallMethodRequest})::UA_CallMethodResult
end

function __UA_Server_addNode(server, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, attributeType, nodeContext, outNewNodeId)
    @ccall libopen62541.__UA_Server_addNode(server::Ptr{UA_Server}, nodeClass::UA_NodeClass, requestedNewNodeId::Ptr{UA_NodeId}, parentNodeId::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId}, browseName::UA_QualifiedName, typeDefinition::Ptr{UA_NodeId}, attr::Ptr{UA_NodeAttributes}, attributeType::Ptr{UA_DataType}, nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_addDataSourceVariableNode(server, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, dataSource, nodeContext, outNewNodeId)
    @ccall libopen62541.UA_Server_addDataSourceVariableNode(server::Ptr{UA_Server}, requestedNewNodeId::UA_NodeId, parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName, typeDefinition::UA_NodeId, attr::UA_VariableAttributes, dataSource::UA_DataSource, nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_addMethodNodeEx(server, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, method, inputArgumentsSize, inputArguments, inputArgumentsRequestedNewNodeId, inputArgumentsOutNewNodeId, outputArgumentsSize, outputArguments, outputArgumentsRequestedNewNodeId, outputArgumentsOutNewNodeId, nodeContext, outNewNodeId)
    @ccall libopen62541.UA_Server_addMethodNodeEx(server::Ptr{UA_Server}, requestedNewNodeId::UA_NodeId, parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName, attr::UA_MethodAttributes, method::UA_MethodCallback, inputArgumentsSize::Csize_t, inputArguments::Ptr{UA_Argument}, inputArgumentsRequestedNewNodeId::UA_NodeId, inputArgumentsOutNewNodeId::Ptr{UA_NodeId}, outputArgumentsSize::Csize_t, outputArguments::Ptr{UA_Argument}, outputArgumentsRequestedNewNodeId::UA_NodeId, outputArgumentsOutNewNodeId::Ptr{UA_NodeId}, nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

"""
    UA_Server_addNode_begin(server, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, attributeType, nodeContext, outNewNodeId)

The method pair [`UA_Server_addNode_begin`](@ref) and \\_finish splits the AddNodes service in two parts. This is useful if the node shall be modified before finish the instantiation. For example to add children with specific NodeIds. Otherwise, mandatory children (e.g. of an ObjectType) are added with pseudo-random unique NodeIds. Existing children are detected during the \\_finish part via their matching BrowseName.

The \\_begin method: - prepares the node and adds it to the nodestore - copies some unassigned attributes from the TypeDefinition node internally - adds the references to the parent (and the TypeDefinition if applicable) - performs type-checking of variables.

You can add an object node without a parent if you set the parentNodeId and referenceTypeId to UA\\_NODE\\_ID\\_NULL. Then you need to add the parent reference and hasTypeDef reference yourself before calling the \\_finish method. Not that this is only allowed for object nodes.

The \\_finish method: - copies mandatory children - calls the node constructor(s) at the end - may remove the node if it encounters an error.

The special [`UA_Server_addMethodNode_finish`](@ref) method needs to be used for method nodes, since there you need to explicitly specifiy the input and output arguments which are added in the finish step (if not yet already there) 
"""
function UA_Server_addNode_begin(server, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, attributeType, nodeContext, outNewNodeId)
    @ccall libopen62541.UA_Server_addNode_begin(server::Ptr{UA_Server}, nodeClass::UA_NodeClass, requestedNewNodeId::UA_NodeId, parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName, typeDefinition::UA_NodeId, attr::Ptr{Cvoid}, attributeType::Ptr{UA_DataType}, nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_addNode_finish(server, nodeId)
    @ccall libopen62541.UA_Server_addNode_finish(server::Ptr{UA_Server}, nodeId::UA_NodeId)::UA_StatusCode
end

function UA_Server_addMethodNode_finish(server, nodeId, method, inputArgumentsSize, inputArguments, outputArgumentsSize, outputArguments)
    @ccall libopen62541.UA_Server_addMethodNode_finish(server::Ptr{UA_Server}, nodeId::UA_NodeId, method::UA_MethodCallback, inputArgumentsSize::Csize_t, inputArguments::Ptr{UA_Argument}, outputArgumentsSize::Csize_t, outputArguments::Ptr{UA_Argument})::UA_StatusCode
end

function UA_Server_deleteNode(server, nodeId, deleteReferences)
    @ccall libopen62541.UA_Server_deleteNode(server::Ptr{UA_Server}, nodeId::UA_NodeId, deleteReferences::UA_Boolean)::UA_StatusCode
end

"""
    UA_Server_addReference(server, sourceId, refTypeId, targetId, isForward)

Reference Management -------------------- 
"""
function UA_Server_addReference(server, sourceId, refTypeId, targetId, isForward)
    @ccall libopen62541.UA_Server_addReference(server::Ptr{UA_Server}, sourceId::UA_NodeId, refTypeId::UA_NodeId, targetId::UA_ExpandedNodeId, isForward::UA_Boolean)::UA_StatusCode
end

function UA_Server_deleteReference(server, sourceNodeId, referenceTypeId, isForward, targetNodeId, deleteBidirectional)
    @ccall libopen62541.UA_Server_deleteReference(server::Ptr{UA_Server}, sourceNodeId::UA_NodeId, referenceTypeId::UA_NodeId, isForward::UA_Boolean, targetNodeId::UA_ExpandedNodeId, deleteBidirectional::UA_Boolean)::UA_StatusCode
end

function UA_Server_updateCertificate(server, oldCertificate, newCertificate, newPrivateKey, closeSessions, closeSecureChannels)
    @ccall libopen62541.UA_Server_updateCertificate(server::Ptr{UA_Server}, oldCertificate::Ptr{UA_ByteString}, newCertificate::Ptr{UA_ByteString}, newPrivateKey::Ptr{UA_ByteString}, closeSessions::UA_Boolean, closeSecureChannels::UA_Boolean)::UA_StatusCode
end

"""
    UA_Server_findDataType(server, typeId)

Utility Functions ----------------- 
"""
function UA_Server_findDataType(server, typeId)
    @ccall libopen62541.UA_Server_findDataType(server::Ptr{UA_Server}, typeId::Ptr{UA_NodeId})::Ptr{UA_DataType}
end

function UA_Server_addNamespace(server, name)
    @ccall libopen62541.UA_Server_addNamespace(server::Ptr{UA_Server}, name::Cstring)::UA_UInt16
end

function UA_Server_getNamespaceByName(server, namespaceUri, foundIndex)
    @ccall libopen62541.UA_Server_getNamespaceByName(server::Ptr{UA_Server}, namespaceUri::UA_String, foundIndex::Ptr{Csize_t})::UA_StatusCode
end

function UA_Server_setMethodNodeAsync(server, id, isAsync)
    @ccall libopen62541.UA_Server_setMethodNodeAsync(server::Ptr{UA_Server}, id::UA_NodeId, isAsync::UA_Boolean)::UA_StatusCode
end

@cenum UA_AsyncOperationType::UInt32 begin
    UA_ASYNCOPERATIONTYPE_INVALID = 0
    UA_ASYNCOPERATIONTYPE_CALL = 1
end

struct UA_AsyncOperationRequest
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{UA_AsyncOperationRequest}, f::Symbol)
    f === :callMethodRequest && return Ptr{UA_CallMethodRequest}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AsyncOperationRequest, f::Symbol)
    r = Ref{UA_AsyncOperationRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AsyncOperationRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AsyncOperationRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_AsyncOperationResponse
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{UA_AsyncOperationResponse}, f::Symbol)
    f === :callMethodResult && return Ptr{UA_CallMethodResult}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AsyncOperationResponse, f::Symbol)
    r = Ref{UA_AsyncOperationResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AsyncOperationResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AsyncOperationResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_getAsyncOperationNonBlocking(server, type, request, context, timeout)
    @ccall libopen62541.UA_Server_getAsyncOperationNonBlocking(server::Ptr{UA_Server}, type::Ptr{UA_AsyncOperationType}, request::Ptr{Ptr{UA_AsyncOperationRequest}}, context::Ptr{Ptr{Cvoid}}, timeout::Ptr{UA_DateTime})::UA_Boolean
end

function UA_Server_setAsyncOperationResult(server, response, context)
    @ccall libopen62541.UA_Server_setAsyncOperationResult(server::Ptr{UA_Server}, response::Ptr{UA_AsyncOperationResponse}, context::Ptr{Cvoid})::Cvoid
end

function UA_Server_getAsyncOperation(server, type, request, context)
    @ccall libopen62541.UA_Server_getAsyncOperation(server::Ptr{UA_Server}, type::Ptr{UA_AsyncOperationType}, request::Ptr{Ptr{UA_AsyncOperationRequest}}, context::Ptr{Ptr{Cvoid}})::UA_Boolean
end

"""
    UA_ServerStatistics

Statistics ----------

Statistic counters keeping track of the current state of the stack. Counters are structured per OPC UA communication layer. 
"""
struct UA_ServerStatistics
    ns::UA_NetworkStatistics
    scs::UA_SecureChannelStatistics
    ss::UA_SessionStatistics
end

function UA_Server_getStatistics(server)
    @ccall libopen62541.UA_Server_getStatistics(server::Ptr{UA_Server})::UA_ServerStatistics
end

"""
    UA_ClientConfig

.. \\_client:

Client ======

The client implementation allows remote access to all OPC UA services. For convenience, some functionality has been wrapped in :ref:`high-level abstractions <client-highlevel>`.

**However**: At this time, the client does not yet contain its own thread or event-driven main-loop, meaning that the client will not perform any actions automatically in the background. This is especially relevant for connection/session management and subscriptions. The user will have to periodically call [`UA_Client_run_iterate`](@ref) to ensure that asynchronous events are handled, including keeping a secure connection established. See more about :ref:`asynchronicity<client-async-services>` and :ref:`subscriptions<client-subscriptions>`.

.. \\_client-config:

Client Configuration --------------------

The client configuration is used for setting connection parameters and additional settings used by the client. The configuration should not be modified after it is passed to a client. Currently, only one client can use a configuration at a time.

Examples for configurations are provided in the ``/plugins`` folder. The usual usage is as follows:

1. Create a client configuration with default settings as a starting point 2. Modifiy the configuration, e.g. modifying the timeout 3. Instantiate a client with it 4. After shutdown of the client, clean up the configuration (free memory)

The :ref:`tutorials` provide a good starting point for this. 
"""
struct UA_ClientConfig
    clientContext::Ptr{Cvoid}
    logger::UA_Logger
    timeout::UA_UInt32
    clientDescription::UA_ApplicationDescription
    userIdentityToken::UA_ExtensionObject
    securityMode::UA_MessageSecurityMode
    securityPolicyUri::UA_String
    endpoint::UA_EndpointDescription
    userTokenPolicy::UA_UserTokenPolicy
    secureChannelLifeTime::UA_UInt32
    requestedSessionTimeout::UA_UInt32
    localConnectionConfig::UA_ConnectionConfig
    connectivityCheckInterval::UA_UInt32
    customDataTypes::Ptr{UA_DataTypeArray}
    securityPoliciesSize::Csize_t
    securityPolicies::Ptr{UA_SecurityPolicy}
    certificateVerification::UA_CertificateVerification
    initConnectionFunc::UA_ConnectClientConnection
    pollConnectionFunc::Ptr{Cvoid}
    stateCallback::Ptr{Cvoid}
    inactivityCallback::Ptr{Cvoid}
    outStandingPublishRequests::UA_UInt16
    subscriptionInactivityCallback::Ptr{Cvoid}
end

function UA_Client_newWithConfig(config)
    @ccall libopen62541.UA_Client_newWithConfig(config::Ptr{UA_ClientConfig})::Ptr{UA_Client}
end

function UA_Client_getState(client, channelState, sessionState, connectStatus)
    @ccall libopen62541.UA_Client_getState(client::Ptr{UA_Client}, channelState::Ptr{UA_SecureChannelState}, sessionState::Ptr{UA_SessionState}, connectStatus::Ptr{UA_StatusCode})::Cvoid
end

function UA_Client_getConfig(client)
    @ccall libopen62541.UA_Client_getConfig(client::Ptr{UA_Client})::Ptr{UA_ClientConfig}
end

function UA_Client_delete(client)
    @ccall libopen62541.UA_Client_delete(client::Ptr{UA_Client})::Cvoid
end

function UA_Client_connect(client, endpointUrl)
    @ccall libopen62541.UA_Client_connect(client::Ptr{UA_Client}, endpointUrl::Cstring)::UA_StatusCode
end

function UA_Client_connectAsync(client, endpointUrl)
    @ccall libopen62541.UA_Client_connectAsync(client::Ptr{UA_Client}, endpointUrl::Cstring)::UA_StatusCode
end

function UA_Client_connectSecureChannel(client, endpointUrl)
    @ccall libopen62541.UA_Client_connectSecureChannel(client::Ptr{UA_Client}, endpointUrl::Cstring)::UA_StatusCode
end

function UA_Client_connectSecureChannelAsync(client, endpointUrl)
    @ccall libopen62541.UA_Client_connectSecureChannelAsync(client::Ptr{UA_Client}, endpointUrl::Cstring)::UA_StatusCode
end

function UA_Client_disconnect(client)
    @ccall libopen62541.UA_Client_disconnect(client::Ptr{UA_Client})::UA_StatusCode
end

function UA_Client_disconnectAsync(client)
    @ccall libopen62541.UA_Client_disconnectAsync(client::Ptr{UA_Client})::UA_StatusCode
end

function UA_Client_disconnectSecureChannel(client)
    @ccall libopen62541.UA_Client_disconnectSecureChannel(client::Ptr{UA_Client})::UA_StatusCode
end

function UA_Client_getEndpoints(client, serverUrl, endpointDescriptionsSize, endpointDescriptions)
    @ccall libopen62541.UA_Client_getEndpoints(client::Ptr{UA_Client}, serverUrl::Cstring, endpointDescriptionsSize::Ptr{Csize_t}, endpointDescriptions::Ptr{Ptr{UA_EndpointDescription}})::UA_StatusCode
end

function UA_Client_findServers(client, serverUrl, serverUrisSize, serverUris, localeIdsSize, localeIds, registeredServersSize, registeredServers)
    @ccall libopen62541.UA_Client_findServers(client::Ptr{UA_Client}, serverUrl::Cstring, serverUrisSize::Csize_t, serverUris::Ptr{UA_String}, localeIdsSize::Csize_t, localeIds::Ptr{UA_String}, registeredServersSize::Ptr{Csize_t}, registeredServers::Ptr{Ptr{UA_ApplicationDescription}})::UA_StatusCode
end

"""
    __UA_Client_Service(client, request, requestType, response, responseType)

.. \\_client-services:

Services --------

The raw OPC UA services are exposed to the client. But most of them time, it is better to use the convenience functions from ``ua\\_client\\_highlevel.h`` that wrap the raw services. 
"""
function __UA_Client_Service(client, request, requestType, response, responseType)
    @ccall libopen62541.__UA_Client_Service(client::Ptr{UA_Client}, request::Ptr{Cvoid}, requestType::Ptr{UA_DataType}, response::Ptr{Cvoid}, responseType::Ptr{UA_DataType})::Cvoid
end

# typedef void ( * UA_ClientAsyncServiceCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , void * response )
"""
.. \\_client-async-services:

Asynchronous Services --------------------- All OPC UA services are asynchronous in nature. So several service calls can be made without waiting for the individual responses. Depending on the server's priorities responses may come in a different ordering than sent.

As noted in :ref:`the client overview<client>` currently no means of handling asynchronous events automatically is provided. However, some synchronous function calls will trigger handling, but to ensure this happens a client should periodically call [`UA_Client_run_iterate`](@ref) explicitly.

Connection and session management are also performed in [`UA_Client_run_iterate`](@ref), so to keep a connection healthy any client need to consider how and when it is appropriate to do the call. This is especially true for the periodic renewal of a SecureChannel's SecurityToken which is designed to have a limited lifetime and will invalidate the connection if not renewed.
"""
const UA_ClientAsyncServiceCallback = Ptr{Cvoid}

function __UA_Client_AsyncService(client, request, requestType, callback, responseType, userdata, requestId)
    @ccall libopen62541.__UA_Client_AsyncService(client::Ptr{UA_Client}, request::Ptr{Cvoid}, requestType::Ptr{UA_DataType}, callback::UA_ClientAsyncServiceCallback, responseType::Ptr{UA_DataType}, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_sendAsyncRequest(client, request, requestType, callback, responseType, userdata, requestId)
    @ccall libopen62541.UA_Client_sendAsyncRequest(client::Ptr{UA_Client}, request::Ptr{Cvoid}, requestType::Ptr{UA_DataType}, callback::UA_ClientAsyncServiceCallback, responseType::Ptr{UA_DataType}, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_run_iterate(client, timeout)
    @ccall libopen62541.UA_Client_run_iterate(client::Ptr{UA_Client}, timeout::UA_UInt32)::UA_StatusCode
end

function UA_Client_renewSecureChannel(client)
    @ccall libopen62541.UA_Client_renewSecureChannel(client::Ptr{UA_Client})::UA_StatusCode
end

function __UA_Client_AsyncServiceEx(client, request, requestType, callback, responseType, userdata, requestId, timeout)
    @ccall libopen62541.__UA_Client_AsyncServiceEx(client::Ptr{UA_Client}, request::Ptr{Cvoid}, requestType::Ptr{UA_DataType}, callback::UA_ClientAsyncServiceCallback, responseType::Ptr{UA_DataType}, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32}, timeout::UA_UInt32)::UA_StatusCode
end

# typedef void ( * UA_ClientCallback ) ( UA_Client * client , void * data )
"""
Timed Callbacks --------------- Repeated callbacks can be attached to a client and will be executed in the defined interval. 
"""
const UA_ClientCallback = Ptr{Cvoid}

function UA_Client_addTimedCallback(client, callback, data, date, callbackId)
    @ccall libopen62541.UA_Client_addTimedCallback(client::Ptr{UA_Client}, callback::UA_ClientCallback, data::Ptr{Cvoid}, date::UA_DateTime, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Client_addRepeatedCallback(client, callback, data, interval_ms, callbackId)
    @ccall libopen62541.UA_Client_addRepeatedCallback(client::Ptr{UA_Client}, callback::UA_ClientCallback, data::Ptr{Cvoid}, interval_ms::UA_Double, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Client_changeRepeatedCallbackInterval(client, callbackId, interval_ms)
    @ccall libopen62541.UA_Client_changeRepeatedCallbackInterval(client::Ptr{UA_Client}, callbackId::UA_UInt64, interval_ms::UA_Double)::UA_StatusCode
end

function UA_Client_removeCallback(client, callbackId)
    @ccall libopen62541.UA_Client_removeCallback(client::Ptr{UA_Client}, callbackId::UA_UInt64)::Cvoid
end

"""
    UA_Client_findDataType(client, typeId)

Client Utility Functions ------------------------ 
"""
function UA_Client_findDataType(client, typeId)
    @ccall libopen62541.UA_Client_findDataType(client::Ptr{UA_Client}, typeId::Ptr{UA_NodeId})::Ptr{UA_DataType}
end

"""
    __UA_Client_readAttribute(client, nodeId, attributeId, out, outDataType)

.. \\_client-highlevel:

Highlevel Client Functionality ------------------------------

The following definitions are convenience functions making use of the standard OPC UA services in the background. This is a less flexible way of handling the stack, because at many places sensible defaults are presumed; at the same time using these functions is the easiest way of implementing an OPC UA application, as you will not have to consider all the details that go into the OPC UA services. If more flexibility is needed, you can always achieve the same functionality using the raw :ref:`OPC UA services <client-services>`.

Read Attributes ^^^^^^^^^^^^^^^ The following functions can be used to retrieve a single node attribute. Use the regular service to read several attributes at once. 
"""
function __UA_Client_readAttribute(client, nodeId, attributeId, out, outDataType)
    @ccall libopen62541.__UA_Client_readAttribute(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId, out::Ptr{Cvoid}, outDataType::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Client_readArrayDimensionsAttribute(client, nodeId, outArrayDimensionsSize, outArrayDimensions)
    @ccall libopen62541.UA_Client_readArrayDimensionsAttribute(client::Ptr{UA_Client}, nodeId::UA_NodeId, outArrayDimensionsSize::Ptr{Csize_t}, outArrayDimensions::Ptr{Ptr{UA_UInt32}})::UA_StatusCode
end

"""
    __UA_Client_writeAttribute(client, nodeId, attributeId, in, inDataType)

Write Attributes ^^^^^^^^^^^^^^^^

The following functions can be use to write a single node attribute at a time. Use the regular write service to write several attributes at once. 
"""
function __UA_Client_writeAttribute(client, nodeId, attributeId, in, inDataType)
    @ccall libopen62541.__UA_Client_writeAttribute(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId, in::Ptr{Cvoid}, inDataType::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Client_writeArrayDimensionsAttribute(client, nodeId, newArrayDimensionsSize, newArrayDimensions)
    @ccall libopen62541.UA_Client_writeArrayDimensionsAttribute(client::Ptr{UA_Client}, nodeId::UA_NodeId, newArrayDimensionsSize::Csize_t, newArrayDimensions::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_call(client, objectId, methodId, inputSize, input, outputSize, output)
    @ccall libopen62541.UA_Client_call(client::Ptr{UA_Client}, objectId::UA_NodeId, methodId::UA_NodeId, inputSize::Csize_t, input::Ptr{UA_Variant}, outputSize::Ptr{Csize_t}, output::Ptr{Ptr{UA_Variant}})::UA_StatusCode
end

"""
    UA_Client_addReference(client, sourceNodeId, referenceTypeId, isForward, targetServerUri, targetNodeId, targetNodeClass)

Node Management ^^^^^^^^^^^^^^^ See the section on :ref:`server-side node management <addnodes>`. 
"""
function UA_Client_addReference(client, sourceNodeId, referenceTypeId, isForward, targetServerUri, targetNodeId, targetNodeClass)
    @ccall libopen62541.UA_Client_addReference(client::Ptr{UA_Client}, sourceNodeId::UA_NodeId, referenceTypeId::UA_NodeId, isForward::UA_Boolean, targetServerUri::UA_String, targetNodeId::UA_ExpandedNodeId, targetNodeClass::UA_NodeClass)::UA_StatusCode
end

function UA_Client_deleteReference(client, sourceNodeId, referenceTypeId, isForward, targetNodeId, deleteBidirectional)
    @ccall libopen62541.UA_Client_deleteReference(client::Ptr{UA_Client}, sourceNodeId::UA_NodeId, referenceTypeId::UA_NodeId, isForward::UA_Boolean, targetNodeId::UA_ExpandedNodeId, deleteBidirectional::UA_Boolean)::UA_StatusCode
end

function UA_Client_deleteNode(client, nodeId, deleteTargetReferences)
    @ccall libopen62541.UA_Client_deleteNode(client::Ptr{UA_Client}, nodeId::UA_NodeId, deleteTargetReferences::UA_Boolean)::UA_StatusCode
end

function __UA_Client_addNode(client, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, attributeType, outNewNodeId)
    @ccall libopen62541.__UA_Client_addNode(client::Ptr{UA_Client}, nodeClass::UA_NodeClass, requestedNewNodeId::UA_NodeId, parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName, typeDefinition::UA_NodeId, attr::Ptr{UA_NodeAttributes}, attributeType::Ptr{UA_DataType}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Client_NamespaceGetIndex(client, namespaceUri, namespaceIndex)
    @ccall libopen62541.UA_Client_NamespaceGetIndex(client::Ptr{UA_Client}, namespaceUri::Ptr{UA_String}, namespaceIndex::Ptr{UA_UInt16})::UA_StatusCode
end

function UA_Client_forEachChildNodeCall(client, parentNodeId, callback, handle)
    @ccall libopen62541.UA_Client_forEachChildNodeCall(client::Ptr{UA_Client}, parentNodeId::UA_NodeId, callback::UA_NodeIteratorCallback, handle::Ptr{Cvoid})::UA_StatusCode
end

# typedef void ( * UA_Client_DeleteSubscriptionCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext )
"""
.. \\_client-subscriptions:

Subscriptions -------------

Subscriptions in OPC UA are asynchronous. That is, the client sends several PublishRequests to the server. The server returns PublishResponses with notifications. But only when a notification has been generated. The client does not wait for the responses and continues normal operations.

Note the difference between Subscriptions and MonitoredItems. Subscriptions are used to report back notifications. MonitoredItems are used to generate notifications. Every MonitoredItem is attached to exactly one Subscription. And a Subscription can contain many MonitoredItems.

The client automatically processes PublishResponses (with a callback) in the background and keeps enough PublishRequests in transit. The PublishResponses may be recieved during a synchronous service call or in `[`UA_Client_run_iterate`](@ref)`. See more about :ref:`asynchronicity<client-async-services>`.
"""
const UA_Client_DeleteSubscriptionCallback = Ptr{Cvoid}

# typedef void ( * UA_Client_StatusChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_StatusChangeNotification * notification )
const UA_Client_StatusChangeNotificationCallback = Ptr{Cvoid}

function UA_Client_Subscriptions_create(client, request, subscriptionContext, statusChangeCallback, deleteCallback)
    @ccall libopen62541.UA_Client_Subscriptions_create(client::Ptr{UA_Client}, request::UA_CreateSubscriptionRequest, subscriptionContext::Ptr{Cvoid}, statusChangeCallback::UA_Client_StatusChangeNotificationCallback, deleteCallback::UA_Client_DeleteSubscriptionCallback)::UA_CreateSubscriptionResponse
end

function UA_Client_Subscriptions_create_async(client, request, subscriptionContext, statusChangeCallback, deleteCallback, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_Subscriptions_create_async(client::Ptr{UA_Client}, request::UA_CreateSubscriptionRequest, subscriptionContext::Ptr{Cvoid}, statusChangeCallback::UA_Client_StatusChangeNotificationCallback, deleteCallback::UA_Client_DeleteSubscriptionCallback, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_Subscriptions_modify(client, request)
    @ccall libopen62541.UA_Client_Subscriptions_modify(client::Ptr{UA_Client}, request::UA_ModifySubscriptionRequest)::UA_ModifySubscriptionResponse
end

function UA_Client_Subscriptions_modify_async(client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_Subscriptions_modify_async(client::Ptr{UA_Client}, request::UA_ModifySubscriptionRequest, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_Subscriptions_delete(client, request)
    @ccall libopen62541.UA_Client_Subscriptions_delete(client::Ptr{UA_Client}, request::UA_DeleteSubscriptionsRequest)::UA_DeleteSubscriptionsResponse
end

function UA_Client_Subscriptions_delete_async(client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_Subscriptions_delete_async(client::Ptr{UA_Client}, request::UA_DeleteSubscriptionsRequest, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_Subscriptions_deleteSingle(client, subscriptionId)
    @ccall libopen62541.UA_Client_Subscriptions_deleteSingle(client::Ptr{UA_Client}, subscriptionId::UA_UInt32)::UA_StatusCode
end

# typedef void ( * UA_Client_DeleteMonitoredItemCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext )
"""
The clientHandle parameter can't be set by the user, any value will be replaced by the client before sending the request to the server. 
"""
const UA_Client_DeleteMonitoredItemCallback = Ptr{Cvoid}

# typedef void ( * UA_Client_DataChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , UA_DataValue * value )
const UA_Client_DataChangeNotificationCallback = Ptr{Cvoid}

# typedef void ( * UA_Client_EventNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , size_t nEventFields , UA_Variant * eventFields )
const UA_Client_EventNotificationCallback = Ptr{Cvoid}

function UA_Client_MonitoredItems_createDataChanges(client, request, contexts, callbacks, deleteCallbacks)
    @ccall libopen62541.UA_Client_MonitoredItems_createDataChanges(client::Ptr{UA_Client}, request::UA_CreateMonitoredItemsRequest, contexts::Ptr{Ptr{Cvoid}}, callbacks::Ptr{UA_Client_DataChangeNotificationCallback}, deleteCallbacks::Ptr{UA_Client_DeleteMonitoredItemCallback})::UA_CreateMonitoredItemsResponse
end

function UA_Client_MonitoredItems_createDataChanges_async(client, request, contexts, callbacks, deleteCallbacks, createCallback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_createDataChanges_async(client::Ptr{UA_Client}, request::UA_CreateMonitoredItemsRequest, contexts::Ptr{Ptr{Cvoid}}, callbacks::Ptr{UA_Client_DataChangeNotificationCallback}, deleteCallbacks::Ptr{UA_Client_DeleteMonitoredItemCallback}, createCallback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_MonitoredItems_createDataChange(client, subscriptionId, timestampsToReturn, item, context, callback, deleteCallback)
    @ccall libopen62541.UA_Client_MonitoredItems_createDataChange(client::Ptr{UA_Client}, subscriptionId::UA_UInt32, timestampsToReturn::UA_TimestampsToReturn, item::UA_MonitoredItemCreateRequest, context::Ptr{Cvoid}, callback::UA_Client_DataChangeNotificationCallback, deleteCallback::UA_Client_DeleteMonitoredItemCallback)::UA_MonitoredItemCreateResult
end

function UA_Client_MonitoredItems_createEvents(client, request, contexts, callback, deleteCallback)
    @ccall libopen62541.UA_Client_MonitoredItems_createEvents(client::Ptr{UA_Client}, request::UA_CreateMonitoredItemsRequest, contexts::Ptr{Ptr{Cvoid}}, callback::Ptr{UA_Client_EventNotificationCallback}, deleteCallback::Ptr{UA_Client_DeleteMonitoredItemCallback})::UA_CreateMonitoredItemsResponse
end

function UA_Client_MonitoredItems_createEvents_async(client, request, contexts, callbacks, deleteCallbacks, createCallback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_createEvents_async(client::Ptr{UA_Client}, request::UA_CreateMonitoredItemsRequest, contexts::Ptr{Ptr{Cvoid}}, callbacks::Ptr{UA_Client_EventNotificationCallback}, deleteCallbacks::Ptr{UA_Client_DeleteMonitoredItemCallback}, createCallback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_MonitoredItems_createEvent(client, subscriptionId, timestampsToReturn, item, context, callback, deleteCallback)
    @ccall libopen62541.UA_Client_MonitoredItems_createEvent(client::Ptr{UA_Client}, subscriptionId::UA_UInt32, timestampsToReturn::UA_TimestampsToReturn, item::UA_MonitoredItemCreateRequest, context::Ptr{Cvoid}, callback::UA_Client_EventNotificationCallback, deleteCallback::UA_Client_DeleteMonitoredItemCallback)::UA_MonitoredItemCreateResult
end

function UA_Client_MonitoredItems_delete(client, arg2)
    @ccall libopen62541.UA_Client_MonitoredItems_delete(client::Ptr{UA_Client}, arg2::UA_DeleteMonitoredItemsRequest)::UA_DeleteMonitoredItemsResponse
end

function UA_Client_MonitoredItems_delete_async(client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_delete_async(client::Ptr{UA_Client}, request::UA_DeleteMonitoredItemsRequest, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_MonitoredItems_deleteSingle(client, subscriptionId, monitoredItemId)
    @ccall libopen62541.UA_Client_MonitoredItems_deleteSingle(client::Ptr{UA_Client}, subscriptionId::UA_UInt32, monitoredItemId::UA_UInt32)::UA_StatusCode
end

function UA_Client_MonitoredItems_modify(client, request)
    @ccall libopen62541.UA_Client_MonitoredItems_modify(client::Ptr{UA_Client}, request::UA_ModifyMonitoredItemsRequest)::UA_ModifyMonitoredItemsResponse
end

# typedef void ( * UA_ClientAsyncReadCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_ReadResponse * rr )
"""
Raw Services ^^^^^^^^^^^^ 
"""
const UA_ClientAsyncReadCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncWriteCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_WriteResponse * wr )
const UA_ClientAsyncWriteCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncBrowseCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_BrowseResponse * wr )
const UA_ClientAsyncBrowseCallback = Ptr{Cvoid}

"""
    __UA_Client_readAttribute_async(client, nodeId, attributeId, outDataType, callback, userdata, reqId)

Read Attribute ^^^^^^^^^^^^^^ 
"""
function __UA_Client_readAttribute_async(client, nodeId, attributeId, outDataType, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_readAttribute_async(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId, outDataType::Ptr{UA_DataType}, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadDataTypeAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_NodeId * var )
const UA_ClientAsyncReadDataTypeAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadValueAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Variant * var )
const UA_ClientAsyncReadValueAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadNodeIdAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_NodeId * out )
const UA_ClientAsyncReadNodeIdAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadNodeClassAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_NodeClass * out )
const UA_ClientAsyncReadNodeClassAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadBrowseNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_QualifiedName * out )
const UA_ClientAsyncReadBrowseNameAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadDisplayNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_LocalizedText * out )
const UA_ClientAsyncReadDisplayNameAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadDescriptionAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_LocalizedText * out )
const UA_ClientAsyncReadDescriptionAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadWriteMaskAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_UInt32 * out )
const UA_ClientAsyncReadWriteMaskAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadUserWriteMaskAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_UInt32 * out )
const UA_ClientAsyncReadUserWriteMaskAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadIsAbstractAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Boolean * out )
const UA_ClientAsyncReadIsAbstractAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadSymmetricAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Boolean * out )
const UA_ClientAsyncReadSymmetricAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadInverseNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_LocalizedText * out )
const UA_ClientAsyncReadInverseNameAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadContainsNoLoopsAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Boolean * out )
const UA_ClientAsyncReadContainsNoLoopsAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadEventNotifierAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Byte * out )
const UA_ClientAsyncReadEventNotifierAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadValueRankAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Int32 * out )
const UA_ClientAsyncReadValueRankAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadAccessLevelAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Byte * out )
const UA_ClientAsyncReadAccessLevelAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadUserAccessLevelAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Byte * out )
const UA_ClientAsyncReadUserAccessLevelAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Double * out )
const UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadHistorizingAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Boolean * out )
const UA_ClientAsyncReadHistorizingAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadExecutableAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Boolean * out )
const UA_ClientAsyncReadExecutableAttributeCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadUserExecutableAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_Boolean * out )
const UA_ClientAsyncReadUserExecutableAttributeCallback = Ptr{Cvoid}

"""
    __UA_Client_writeAttribute_async(client, nodeId, attributeId, in, inDataType, callback, userdata, reqId)

Write Attribute ^^^^^^^^^^^^^^ 
"""
function __UA_Client_writeAttribute_async(client, nodeId, attributeId, in, inDataType, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_writeAttribute_async(client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId, in::Ptr{Cvoid}, inDataType::Ptr{UA_DataType}, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

function __UA_Client_call_async(client, objectId, methodId, inputSize, input, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_call_async(client::Ptr{UA_Client}, objectId::UA_NodeId, methodId::UA_NodeId, inputSize::Csize_t, input::Ptr{UA_Variant}, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncCallCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_CallResponse * cr )
const UA_ClientAsyncCallCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncAddNodesCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_AddNodesResponse * ar )
"""
Node Management ^^^^^^^^^^^^^^^ 
"""
const UA_ClientAsyncAddNodesCallback = Ptr{Cvoid}

function __UA_Client_addNode_async(client, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, attributeType, outNewNodeId, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_addNode_async(client::Ptr{UA_Client}, nodeClass::UA_NodeClass, requestedNewNodeId::UA_NodeId, parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName, typeDefinition::UA_NodeId, attr::Ptr{UA_NodeAttributes}, attributeType::Ptr{UA_DataType}, outNewNodeId::Ptr{UA_NodeId}, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

"""
    __UA_Client_translateBrowsePathsToNodeIds_async(client, paths, ids, pathSize, callback, userdata, reqId)

Misc Functionalities ^^^^^^^^^^^^^^^^^^^^ 
"""
function __UA_Client_translateBrowsePathsToNodeIds_async(client, paths, ids, pathSize, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_translateBrowsePathsToNodeIds_async(client::Ptr{UA_Client}, paths::Ptr{Cstring}, ids::Ptr{UA_UInt32}, pathSize::Csize_t, callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncTranslateCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_TranslateBrowsePathsToNodeIdsResponse * tr )
const UA_ClientAsyncTranslateCallback = Ptr{Cvoid}

function UA_Cient_translateBrowsePathsToNodeIds_async(client, paths, ids, pathSize, callback, userdata, reqId)
    @ccall libopen62541.UA_Cient_translateBrowsePathsToNodeIds_async(client::Ptr{UA_Client}, paths::Ptr{Cstring}, ids::Ptr{UA_UInt32}, pathSize::Csize_t, callback::UA_ClientAsyncTranslateCallback, userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

"""
    UA_UsernamePasswordLogin

********************************* amalgamated original file "/workspace/srcdir/open62541/plugins/include/open62541/plugin/accesscontrol\\_default.h" **********************************
"""
struct UA_UsernamePasswordLogin
    username::UA_String
    password::UA_String
end

function UA_AccessControl_default(config, allowAnonymous, userTokenPolicyUri, usernamePasswordLoginSize, usernamePasswordLogin)
    @ccall libopen62541.UA_AccessControl_default(config::Ptr{UA_ServerConfig}, allowAnonymous::UA_Boolean, userTokenPolicyUri::Ptr{UA_ByteString}, usernamePasswordLoginSize::Csize_t, usernamePasswordLogin::Ptr{UA_UsernamePasswordLogin})::UA_StatusCode
end

"""
    UA_CertificateVerification_AcceptAll(cv)

********************************* amalgamated original file "/workspace/srcdir/open62541/plugins/include/open62541/plugin/pki\\_default.h" **********************************
"""
function UA_CertificateVerification_AcceptAll(cv)
    @ccall libopen62541.UA_CertificateVerification_AcceptAll(cv::Ptr{UA_CertificateVerification})::Cvoid
end

function UA_Log_Stdout_clear(logContext)
    @ccall libopen62541.UA_Log_Stdout_clear(logContext::Ptr{Cvoid})::Cvoid
end

function UA_Log_Stdout_withLevel(minlevel)
    @ccall libopen62541.UA_Log_Stdout_withLevel(minlevel::UA_LogLevel)::UA_Logger
end

"""
    UA_Nodestore_HashMap(ns)

********************************* amalgamated original file "/workspace/srcdir/open62541/plugins/include/open62541/plugin/nodestore\\_default.h" **********************************
"""
function UA_Nodestore_HashMap(ns)
    @ccall libopen62541.UA_Nodestore_HashMap(ns::Ptr{UA_Nodestore})::UA_StatusCode
end

function UA_Nodestore_ZipTree(ns)
    @ccall libopen62541.UA_Nodestore_ZipTree(ns::Ptr{UA_Nodestore})::UA_StatusCode
end

"""
    UA_Server_new()

********************************* amalgamated original file "/workspace/srcdir/open62541/plugins/include/open62541/server\\_config\\_default.h" **********************************
"""
function UA_Server_new()
    @ccall libopen62541.UA_Server_new()::Ptr{UA_Server}
end

function UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, sendBufferSize, recvBufferSize)
    @ccall libopen62541.UA_ServerConfig_setMinimalCustomBuffer(config::Ptr{UA_ServerConfig}, portNumber::UA_UInt16, certificate::Ptr{UA_ByteString}, sendBufferSize::UA_UInt32, recvBufferSize::UA_UInt32)::UA_StatusCode
end

function UA_ServerConfig_setBasics(conf)
    @ccall libopen62541.UA_ServerConfig_setBasics(conf::Ptr{UA_ServerConfig})::UA_StatusCode
end

function UA_ServerConfig_addNetworkLayerTCP(conf, portNumber, sendBufferSize, recvBufferSize)
    @ccall libopen62541.UA_ServerConfig_addNetworkLayerTCP(conf::Ptr{UA_ServerConfig}, portNumber::UA_UInt16, sendBufferSize::UA_UInt32, recvBufferSize::UA_UInt32)::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyNone(config, certificate)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyNone(config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addEndpoint(config, securityPolicyUri, securityMode)
    @ccall libopen62541.UA_ServerConfig_addEndpoint(config::Ptr{UA_ServerConfig}, securityPolicyUri::UA_String, securityMode::UA_MessageSecurityMode)::UA_StatusCode
end

function UA_ServerConfig_addAllEndpoints(config)
    @ccall libopen62541.UA_ServerConfig_addAllEndpoints(config::Ptr{UA_ServerConfig})::UA_StatusCode
end

"""
    UA_Client_new()

********************************* amalgamated original file "/workspace/srcdir/open62541/plugins/include/open62541/client\\_config\\_default.h" **********************************
"""
function UA_Client_new()
    @ccall libopen62541.UA_Client_new()::Ptr{UA_Client}
end

function UA_ClientConfig_setDefault(config)
    @ccall libopen62541.UA_ClientConfig_setDefault(config::Ptr{UA_ClientConfig})::UA_StatusCode
end

"""
    UA_SecurityPolicy_None(policy, localCertificate, logger)

********************************* amalgamated original file "/workspace/srcdir/open62541/plugins/include/open62541/plugin/securitypolicy\\_default.h" **********************************
"""
function UA_SecurityPolicy_None(policy, localCertificate, logger)
    @ccall libopen62541.UA_SecurityPolicy_None(policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString, logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_ServerNetworkLayerTCP(config, port, maxConnections)
    @ccall libopen62541.UA_ServerNetworkLayerTCP(config::UA_ConnectionConfig, port::UA_UInt16, maxConnections::UA_UInt16)::UA_ServerNetworkLayer
end

function UA_ClientConnectionTCP_init(config, endpointUrl, timeout, logger)
    @ccall libopen62541.UA_ClientConnectionTCP_init(config::UA_ConnectionConfig, endpointUrl::UA_String, timeout::UA_UInt32, logger::Ptr{UA_Logger})::UA_Connection
end

function UA_ClientConnectionTCP_poll(connection, timeout, logger)
    @ccall libopen62541.UA_ClientConnectionTCP_poll(connection::Ptr{UA_Connection}, timeout::UA_UInt32, logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_socket_set_blocking(sockfd)
    @ccall libopen62541.UA_socket_set_blocking(sockfd::SOCKET)::Cuint
end

function UA_socket_set_nonblocking(sockfd)
    @ccall libopen62541.UA_socket_set_nonblocking(sockfd::SOCKET)::Cuint
end

function UA_initialize_architecture_network()
    @ccall libopen62541.UA_initialize_architecture_network()::Cvoid
end

function UA_deinitialize_architecture_network()
    @ccall libopen62541.UA_deinitialize_architecture_network()::Cvoid
end

struct __JL_Ctag_367
    value::UA_DataValue
    callback::UA_ValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_367}, f::Symbol)
    f === :value && return Ptr{UA_DataValue}(x + 0)
    f === :callback && return Ptr{UA_ValueCallback}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_367, f::Symbol)
    r = Ref{__JL_Ctag_367}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_367}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_367}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct __JL_Ctag_369
    typeId::UA_NodeId
    body::UA_ByteString
end
function Base.getproperty(x::Ptr{__JL_Ctag_369}, f::Symbol)
    f === :typeId && return Ptr{UA_NodeId}(x + 0)
    f === :body && return Ptr{UA_ByteString}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_369, f::Symbol)
    r = Ref{__JL_Ctag_369}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_369}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_369}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct __JL_Ctag_370
    type::Ptr{UA_DataType}
    data::Ptr{Cvoid}
end
function Base.getproperty(x::Ptr{__JL_Ctag_370}, f::Symbol)
    f === :type && return Ptr{Ptr{UA_DataType}}(x + 0)
    f === :data && return Ptr{Ptr{Cvoid}}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_370, f::Symbol)
    r = Ref{__JL_Ctag_370}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_370}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_370}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct __JL_Ctag_372
    value::UA_DataValue
    callback::UA_ValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_372}, f::Symbol)
    f === :value && return Ptr{UA_DataValue}(x + 0)
    f === :callback && return Ptr{UA_ValueCallback}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_372, f::Symbol)
    r = Ref{__JL_Ctag_372}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_372}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_372}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct __JL_Ctag_373
    value::Ptr{Ptr{UA_DataValue}}
    callback::UA_ExternalValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_373}, f::Symbol)
    f === :value && return Ptr{Ptr{Ptr{UA_DataValue}}}(x + 0)
    f === :callback && return Ptr{UA_ExternalValueCallback}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_373, f::Symbol)
    r = Ref{__JL_Ctag_373}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_373}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_373}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct __JL_Ctag_375
    value::UA_DataValue
    callback::UA_ValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_375}, f::Symbol)
    f === :value && return Ptr{UA_DataValue}(x + 0)
    f === :callback && return Ptr{UA_ValueCallback}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_375, f::Symbol)
    r = Ref{__JL_Ctag_375}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_375}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_375}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


const UA_OPEN62541_VER_MAJOR = 1

const UA_OPEN62541_VER_MINOR = 2

const UA_OPEN62541_VER_PATCH = 2

const UA_OPEN62541_VER_LABEL = "-dirty"

const UA_OPEN62541_VER_COMMIT = "v1.2.2-dirty"

const UA_LOGLEVEL = 300

const UA_MULTITHREADING = 100

const UA_VALGRIND_INTERACTIVE_INTERVAL = 1000

const WINVER = 0x0600

const _WIN32_WINDOWS = 0x0600

const _WIN32_WINNT = 0x0600

const OPTVAL_TYPE = Cint

const UA_IPV6 = 1

# Skipping MacroDefinition: UA_EXPORT __attribute__ ( ( dllimport ) )

# Skipping MacroDefinition: UA_INLINE inline

# Skipping MacroDefinition: UA_FUNC_ATTR_MALLOC __attribute__ ( ( malloc ) )

# Skipping MacroDefinition: UA_FUNC_ATTR_PURE __attribute__ ( ( pure ) )

# Skipping MacroDefinition: UA_FUNC_ATTR_CONST __attribute__ ( ( const ) )

# Skipping MacroDefinition: UA_FUNC_ATTR_WARN_UNUSED_RESULT __attribute__ ( ( warn_unused_result ) )

# Skipping MacroDefinition: UA_DEPRECATED __attribute__ ( ( deprecated ) )

const UA_LITTLE_ENDIAN = 1

const UA_BINARY_OVERLAYABLE_INTEGER = 1

const UA_FLOAT_IEEE754 = 1

const UA_FLOAT_LITTLE_ENDIAN = 1

const UA_BINARY_OVERLAYABLE_FLOAT = 1

const UA_STATUSCODE_GOOD = 0x00

const UA_STATUSCODE_INFOTYPE_DATAVALUE = 0x00000400

const UA_STATUSCODE_INFOBITS_OVERFLOW = 0x00000080

const UA_STATUSCODE_BADUNEXPECTEDERROR = 0x80010000

const UA_STATUSCODE_BADINTERNALERROR = 0x80020000

const UA_STATUSCODE_BADOUTOFMEMORY = 0x80030000

const UA_STATUSCODE_BADRESOURCEUNAVAILABLE = 0x80040000

const UA_STATUSCODE_BADCOMMUNICATIONERROR = 0x80050000

const UA_STATUSCODE_BADENCODINGERROR = 0x80060000

const UA_STATUSCODE_BADDECODINGERROR = 0x80070000

const UA_STATUSCODE_BADENCODINGLIMITSEXCEEDED = 0x80080000

const UA_STATUSCODE_BADREQUESTTOOLARGE = 0x80b80000

const UA_STATUSCODE_BADRESPONSETOOLARGE = 0x80b90000

const UA_STATUSCODE_BADUNKNOWNRESPONSE = 0x80090000

const UA_STATUSCODE_BADTIMEOUT = 0x800a0000

const UA_STATUSCODE_BADSERVICEUNSUPPORTED = 0x800b0000

const UA_STATUSCODE_BADSHUTDOWN = 0x800c0000

const UA_STATUSCODE_BADSERVERNOTCONNECTED = 0x800d0000

const UA_STATUSCODE_BADSERVERHALTED = 0x800e0000

const UA_STATUSCODE_BADNOTHINGTODO = 0x800f0000

const UA_STATUSCODE_BADTOOMANYOPERATIONS = 0x80100000

const UA_STATUSCODE_BADTOOMANYMONITOREDITEMS = 0x80db0000

const UA_STATUSCODE_BADDATATYPEIDUNKNOWN = 0x80110000

const UA_STATUSCODE_BADCERTIFICATEINVALID = 0x80120000

const UA_STATUSCODE_BADSECURITYCHECKSFAILED = 0x80130000

const UA_STATUSCODE_BADCERTIFICATEPOLICYCHECKFAILED = 0x81140000

const UA_STATUSCODE_BADCERTIFICATETIMEINVALID = 0x80140000

const UA_STATUSCODE_BADCERTIFICATEISSUERTIMEINVALID = 0x80150000

const UA_STATUSCODE_BADCERTIFICATEHOSTNAMEINVALID = 0x80160000

const UA_STATUSCODE_BADCERTIFICATEURIINVALID = 0x80170000

const UA_STATUSCODE_BADCERTIFICATEUSENOTALLOWED = 0x80180000

const UA_STATUSCODE_BADCERTIFICATEISSUERUSENOTALLOWED = 0x80190000

const UA_STATUSCODE_BADCERTIFICATEUNTRUSTED = 0x801a0000

const UA_STATUSCODE_BADCERTIFICATEREVOCATIONUNKNOWN = 0x801b0000

const UA_STATUSCODE_BADCERTIFICATEISSUERREVOCATIONUNKNOWN = 0x801c0000

const UA_STATUSCODE_BADCERTIFICATEREVOKED = 0x801d0000

const UA_STATUSCODE_BADCERTIFICATEISSUERREVOKED = 0x801e0000

const UA_STATUSCODE_BADCERTIFICATECHAININCOMPLETE = 0x810d0000

const UA_STATUSCODE_BADUSERACCESSDENIED = 0x801f0000

const UA_STATUSCODE_BADIDENTITYTOKENINVALID = 0x80200000

const UA_STATUSCODE_BADIDENTITYTOKENREJECTED = 0x80210000

const UA_STATUSCODE_BADSECURECHANNELIDINVALID = 0x80220000

const UA_STATUSCODE_BADINVALIDTIMESTAMP = 0x80230000

const UA_STATUSCODE_BADNONCEINVALID = 0x80240000

const UA_STATUSCODE_BADSESSIONIDINVALID = 0x80250000

const UA_STATUSCODE_BADSESSIONCLOSED = 0x80260000

const UA_STATUSCODE_BADSESSIONNOTACTIVATED = 0x80270000

const UA_STATUSCODE_BADSUBSCRIPTIONIDINVALID = 0x80280000

const UA_STATUSCODE_BADREQUESTHEADERINVALID = 0x802a0000

const UA_STATUSCODE_BADTIMESTAMPSTORETURNINVALID = 0x802b0000

const UA_STATUSCODE_BADREQUESTCANCELLEDBYCLIENT = 0x802c0000

const UA_STATUSCODE_BADTOOMANYARGUMENTS = 0x80e50000

const UA_STATUSCODE_BADLICENSEEXPIRED = 0x810e0000

const UA_STATUSCODE_BADLICENSELIMITSEXCEEDED = 0x810f0000

const UA_STATUSCODE_BADLICENSENOTAVAILABLE = 0x81100000

const UA_STATUSCODE_GOODSUBSCRIPTIONTRANSFERRED = 0x002d0000

const UA_STATUSCODE_GOODCOMPLETESASYNCHRONOUSLY = 0x002e0000

const UA_STATUSCODE_GOODOVERLOAD = 0x002f0000

const UA_STATUSCODE_GOODCLAMPED = 0x00300000

const UA_STATUSCODE_BADNOCOMMUNICATION = 0x80310000

const UA_STATUSCODE_BADWAITINGFORINITIALDATA = 0x80320000

const UA_STATUSCODE_BADNODEIDINVALID = 0x80330000

const UA_STATUSCODE_BADNODEIDUNKNOWN = 0x80340000

const UA_STATUSCODE_BADATTRIBUTEIDINVALID = 0x80350000

const UA_STATUSCODE_BADINDEXRANGEINVALID = 0x80360000

const UA_STATUSCODE_BADINDEXRANGENODATA = 0x80370000

const UA_STATUSCODE_BADDATAENCODINGINVALID = 0x80380000

const UA_STATUSCODE_BADDATAENCODINGUNSUPPORTED = 0x80390000

const UA_STATUSCODE_BADNOTREADABLE = 0x803a0000

const UA_STATUSCODE_BADNOTWRITABLE = 0x803b0000

const UA_STATUSCODE_BADOUTOFRANGE = 0x803c0000

const UA_STATUSCODE_BADNOTSUPPORTED = 0x803d0000

const UA_STATUSCODE_BADNOTFOUND = 0x803e0000

const UA_STATUSCODE_BADOBJECTDELETED = 0x803f0000

const UA_STATUSCODE_BADNOTIMPLEMENTED = 0x80400000

const UA_STATUSCODE_BADMONITORINGMODEINVALID = 0x80410000

const UA_STATUSCODE_BADMONITOREDITEMIDINVALID = 0x80420000

const UA_STATUSCODE_BADMONITOREDITEMFILTERINVALID = 0x80430000

const UA_STATUSCODE_BADMONITOREDITEMFILTERUNSUPPORTED = 0x80440000

const UA_STATUSCODE_BADFILTERNOTALLOWED = 0x80450000

const UA_STATUSCODE_BADSTRUCTUREMISSING = 0x80460000

const UA_STATUSCODE_BADEVENTFILTERINVALID = 0x80470000

const UA_STATUSCODE_BADCONTENTFILTERINVALID = 0x80480000

const UA_STATUSCODE_BADFILTEROPERATORINVALID = 0x80c10000

const UA_STATUSCODE_BADFILTEROPERATORUNSUPPORTED = 0x80c20000

const UA_STATUSCODE_BADFILTEROPERANDCOUNTMISMATCH = 0x80c30000

const UA_STATUSCODE_BADFILTEROPERANDINVALID = 0x80490000

const UA_STATUSCODE_BADFILTERELEMENTINVALID = 0x80c40000

const UA_STATUSCODE_BADFILTERLITERALINVALID = 0x80c50000

const UA_STATUSCODE_BADCONTINUATIONPOINTINVALID = 0x804a0000

const UA_STATUSCODE_BADNOCONTINUATIONPOINTS = 0x804b0000

const UA_STATUSCODE_BADREFERENCETYPEIDINVALID = 0x804c0000

const UA_STATUSCODE_BADBROWSEDIRECTIONINVALID = 0x804d0000

const UA_STATUSCODE_BADNODENOTINVIEW = 0x804e0000

const UA_STATUSCODE_BADNUMERICOVERFLOW = 0x81120000

const UA_STATUSCODE_BADSERVERURIINVALID = 0x804f0000

const UA_STATUSCODE_BADSERVERNAMEMISSING = 0x80500000

const UA_STATUSCODE_BADDISCOVERYURLMISSING = 0x80510000

const UA_STATUSCODE_BADSEMPAHOREFILEMISSING = 0x80520000

const UA_STATUSCODE_BADREQUESTTYPEINVALID = 0x80530000

const UA_STATUSCODE_BADSECURITYMODEREJECTED = 0x80540000

const UA_STATUSCODE_BADSECURITYPOLICYREJECTED = 0x80550000

const UA_STATUSCODE_BADTOOMANYSESSIONS = 0x80560000

const UA_STATUSCODE_BADUSERSIGNATUREINVALID = 0x80570000

const UA_STATUSCODE_BADAPPLICATIONSIGNATUREINVALID = 0x80580000

const UA_STATUSCODE_BADNOVALIDCERTIFICATES = 0x80590000

const UA_STATUSCODE_BADIDENTITYCHANGENOTSUPPORTED = 0x80c60000

const UA_STATUSCODE_BADREQUESTCANCELLEDBYREQUEST = 0x805a0000

const UA_STATUSCODE_BADPARENTNODEIDINVALID = 0x805b0000

const UA_STATUSCODE_BADREFERENCENOTALLOWED = 0x805c0000

const UA_STATUSCODE_BADNODEIDREJECTED = 0x805d0000

const UA_STATUSCODE_BADNODEIDEXISTS = 0x805e0000

const UA_STATUSCODE_BADNODECLASSINVALID = 0x805f0000

const UA_STATUSCODE_BADBROWSENAMEINVALID = 0x80600000

const UA_STATUSCODE_BADBROWSENAMEDUPLICATED = 0x80610000

const UA_STATUSCODE_BADNODEATTRIBUTESINVALID = 0x80620000

const UA_STATUSCODE_BADTYPEDEFINITIONINVALID = 0x80630000

const UA_STATUSCODE_BADSOURCENODEIDINVALID = 0x80640000

const UA_STATUSCODE_BADTARGETNODEIDINVALID = 0x80650000

const UA_STATUSCODE_BADDUPLICATEREFERENCENOTALLOWED = 0x80660000

const UA_STATUSCODE_BADINVALIDSELFREFERENCE = 0x80670000

const UA_STATUSCODE_BADREFERENCELOCALONLY = 0x80680000

const UA_STATUSCODE_BADNODELETERIGHTS = 0x80690000

const UA_STATUSCODE_UNCERTAINREFERENCENOTDELETED = 0x40bc0000

const UA_STATUSCODE_BADSERVERINDEXINVALID = 0x806a0000

const UA_STATUSCODE_BADVIEWIDUNKNOWN = 0x806b0000

const UA_STATUSCODE_BADVIEWTIMESTAMPINVALID = 0x80c90000

const UA_STATUSCODE_BADVIEWPARAMETERMISMATCH = 0x80ca0000

const UA_STATUSCODE_BADVIEWVERSIONINVALID = 0x80cb0000

const UA_STATUSCODE_UNCERTAINNOTALLNODESAVAILABLE = 0x40c00000

const UA_STATUSCODE_GOODRESULTSMAYBEINCOMPLETE = 0x00ba0000

const UA_STATUSCODE_BADNOTTYPEDEFINITION = 0x80c80000

const UA_STATUSCODE_UNCERTAINREFERENCEOUTOFSERVER = 0x406c0000

const UA_STATUSCODE_BADTOOMANYMATCHES = 0x806d0000

const UA_STATUSCODE_BADQUERYTOOCOMPLEX = 0x806e0000

const UA_STATUSCODE_BADNOMATCH = 0x806f0000

const UA_STATUSCODE_BADMAXAGEINVALID = 0x80700000

const UA_STATUSCODE_BADSECURITYMODEINSUFFICIENT = 0x80e60000

const UA_STATUSCODE_BADHISTORYOPERATIONINVALID = 0x80710000

const UA_STATUSCODE_BADHISTORYOPERATIONUNSUPPORTED = 0x80720000

const UA_STATUSCODE_BADINVALIDTIMESTAMPARGUMENT = 0x80bd0000

const UA_STATUSCODE_BADWRITENOTSUPPORTED = 0x80730000

const UA_STATUSCODE_BADTYPEMISMATCH = 0x80740000

const UA_STATUSCODE_BADMETHODINVALID = 0x80750000

const UA_STATUSCODE_BADARGUMENTSMISSING = 0x80760000

const UA_STATUSCODE_BADNOTEXECUTABLE = 0x81110000

const UA_STATUSCODE_BADTOOMANYSUBSCRIPTIONS = 0x80770000

const UA_STATUSCODE_BADTOOMANYPUBLISHREQUESTS = 0x80780000

const UA_STATUSCODE_BADNOSUBSCRIPTION = 0x80790000

const UA_STATUSCODE_BADSEQUENCENUMBERUNKNOWN = 0x807a0000

const UA_STATUSCODE_BADMESSAGENOTAVAILABLE = 0x807b0000

const UA_STATUSCODE_BADINSUFFICIENTCLIENTPROFILE = 0x807c0000

const UA_STATUSCODE_BADSTATENOTACTIVE = 0x80bf0000

const UA_STATUSCODE_BADALREADYEXISTS = 0x81150000

const UA_STATUSCODE_BADTCPSERVERTOOBUSY = 0x807d0000

const UA_STATUSCODE_BADTCPMESSAGETYPEINVALID = 0x807e0000

const UA_STATUSCODE_BADTCPSECURECHANNELUNKNOWN = 0x807f0000

const UA_STATUSCODE_BADTCPMESSAGETOOLARGE = 0x80800000

const UA_STATUSCODE_BADTCPNOTENOUGHRESOURCES = 0x80810000

const UA_STATUSCODE_BADTCPINTERNALERROR = 0x80820000

const UA_STATUSCODE_BADTCPENDPOINTURLINVALID = 0x80830000

const UA_STATUSCODE_BADREQUESTINTERRUPTED = 0x80840000

const UA_STATUSCODE_BADREQUESTTIMEOUT = 0x80850000

const UA_STATUSCODE_BADSECURECHANNELCLOSED = 0x80860000

const UA_STATUSCODE_BADSECURECHANNELTOKENUNKNOWN = 0x80870000

const UA_STATUSCODE_BADSEQUENCENUMBERINVALID = 0x80880000

const UA_STATUSCODE_BADPROTOCOLVERSIONUNSUPPORTED = 0x80be0000

const UA_STATUSCODE_BADCONFIGURATIONERROR = 0x80890000

const UA_STATUSCODE_BADNOTCONNECTED = 0x808a0000

const UA_STATUSCODE_BADDEVICEFAILURE = 0x808b0000

const UA_STATUSCODE_BADSENSORFAILURE = 0x808c0000

const UA_STATUSCODE_BADOUTOFSERVICE = 0x808d0000

const UA_STATUSCODE_BADDEADBANDFILTERINVALID = 0x808e0000

const UA_STATUSCODE_UNCERTAINNOCOMMUNICATIONLASTUSABLEVALUE = 0x408f0000

const UA_STATUSCODE_UNCERTAINLASTUSABLEVALUE = 0x40900000

const UA_STATUSCODE_UNCERTAINSUBSTITUTEVALUE = 0x40910000

const UA_STATUSCODE_UNCERTAININITIALVALUE = 0x40920000

const UA_STATUSCODE_UNCERTAINSENSORNOTACCURATE = 0x40930000

const UA_STATUSCODE_UNCERTAINENGINEERINGUNITSEXCEEDED = 0x40940000

const UA_STATUSCODE_UNCERTAINSUBNORMAL = 0x40950000

const UA_STATUSCODE_GOODLOCALOVERRIDE = 0x00960000

const UA_STATUSCODE_BADREFRESHINPROGRESS = 0x80970000

const UA_STATUSCODE_BADCONDITIONALREADYDISABLED = 0x80980000

const UA_STATUSCODE_BADCONDITIONALREADYENABLED = 0x80cc0000

const UA_STATUSCODE_BADCONDITIONDISABLED = 0x80990000

const UA_STATUSCODE_BADEVENTIDUNKNOWN = 0x809a0000

const UA_STATUSCODE_BADEVENTNOTACKNOWLEDGEABLE = 0x80bb0000

const UA_STATUSCODE_BADDIALOGNOTACTIVE = 0x80cd0000

const UA_STATUSCODE_BADDIALOGRESPONSEINVALID = 0x80ce0000

const UA_STATUSCODE_BADCONDITIONBRANCHALREADYACKED = 0x80cf0000

const UA_STATUSCODE_BADCONDITIONBRANCHALREADYCONFIRMED = 0x80d00000

const UA_STATUSCODE_BADCONDITIONALREADYSHELVED = 0x80d10000

const UA_STATUSCODE_BADCONDITIONNOTSHELVED = 0x80d20000

const UA_STATUSCODE_BADSHELVINGTIMEOUTOFRANGE = 0x80d30000

const UA_STATUSCODE_BADNODATA = 0x809b0000

const UA_STATUSCODE_BADBOUNDNOTFOUND = 0x80d70000

const UA_STATUSCODE_BADBOUNDNOTSUPPORTED = 0x80d80000

const UA_STATUSCODE_BADDATALOST = 0x809d0000

const UA_STATUSCODE_BADDATAUNAVAILABLE = 0x809e0000

const UA_STATUSCODE_BADENTRYEXISTS = 0x809f0000

const UA_STATUSCODE_BADNOENTRYEXISTS = 0x80a00000

const UA_STATUSCODE_BADTIMESTAMPNOTSUPPORTED = 0x80a10000

const UA_STATUSCODE_GOODENTRYINSERTED = 0x00a20000

const UA_STATUSCODE_GOODENTRYREPLACED = 0x00a30000

const UA_STATUSCODE_UNCERTAINDATASUBNORMAL = 0x40a40000

const UA_STATUSCODE_GOODNODATA = 0x00a50000

const UA_STATUSCODE_GOODMOREDATA = 0x00a60000

const UA_STATUSCODE_BADAGGREGATELISTMISMATCH = 0x80d40000

const UA_STATUSCODE_BADAGGREGATENOTSUPPORTED = 0x80d50000

const UA_STATUSCODE_BADAGGREGATEINVALIDINPUTS = 0x80d60000

const UA_STATUSCODE_BADAGGREGATECONFIGURATIONREJECTED = 0x80da0000

const UA_STATUSCODE_GOODDATAIGNORED = 0x00d90000

const UA_STATUSCODE_BADREQUESTNOTALLOWED = 0x80e40000

const UA_STATUSCODE_BADREQUESTNOTCOMPLETE = 0x81130000

const UA_STATUSCODE_GOODEDITED = 0x00dc0000

const UA_STATUSCODE_GOODPOSTACTIONFAILED = 0x00dd0000

const UA_STATUSCODE_UNCERTAINDOMINANTVALUECHANGED = 0x40de0000

const UA_STATUSCODE_GOODDEPENDENTVALUECHANGED = 0x00e00000

const UA_STATUSCODE_BADDOMINANTVALUECHANGED = 0x80e10000

const UA_STATUSCODE_UNCERTAINDEPENDENTVALUECHANGED = 0x40e20000

const UA_STATUSCODE_BADDEPENDENTVALUECHANGED = 0x80e30000

const UA_STATUSCODE_GOODCOMMUNICATIONEVENT = 0x00a70000

const UA_STATUSCODE_GOODSHUTDOWNEVENT = 0x00a80000

const UA_STATUSCODE_GOODCALLAGAIN = 0x00a90000

const UA_STATUSCODE_GOODNONCRITICALTIMEOUT = 0x00aa0000

const UA_STATUSCODE_BADINVALIDARGUMENT = 0x80ab0000

const UA_STATUSCODE_BADCONNECTIONREJECTED = 0x80ac0000

const UA_STATUSCODE_BADDISCONNECT = 0x80ad0000

const UA_STATUSCODE_BADCONNECTIONCLOSED = 0x80ae0000

const UA_STATUSCODE_BADINVALIDSTATE = 0x80af0000

const UA_STATUSCODE_BADENDOFSTREAM = 0x80b00000

const UA_STATUSCODE_BADNODATAAVAILABLE = 0x80b10000

const UA_STATUSCODE_BADWAITINGFORRESPONSE = 0x80b20000

const UA_STATUSCODE_BADOPERATIONABANDONED = 0x80b30000

const UA_STATUSCODE_BADEXPECTEDSTREAMTOBLOCK = 0x80b40000

const UA_STATUSCODE_BADWOULDBLOCK = 0x80b50000

const UA_STATUSCODE_BADSYNTAXERROR = 0x80b60000

const UA_STATUSCODE_BADMAXCONNECTIONSREACHED = 0x80b70000

const UA_NS0ID_BOOLEAN = 1

const UA_NS0ID_SBYTE = 2

const UA_NS0ID_BYTE = 3

const UA_NS0ID_INT16 = 4

const UA_NS0ID_UINT16 = 5

const UA_NS0ID_INT32 = 6

const UA_NS0ID_UINT32 = 7

const UA_NS0ID_INT64 = 8

const UA_NS0ID_UINT64 = 9

const UA_NS0ID_FLOAT = 10

const UA_NS0ID_DOUBLE = 11

const UA_NS0ID_STRING = 12

const UA_NS0ID_DATETIME = 13

const UA_NS0ID_GUID = 14

const UA_NS0ID_BYTESTRING = 15

const UA_NS0ID_XMLELEMENT = 16

const UA_NS0ID_NODEID = 17

const UA_NS0ID_EXPANDEDNODEID = 18

const UA_NS0ID_STATUSCODE = 19

const UA_NS0ID_QUALIFIEDNAME = 20

const UA_NS0ID_LOCALIZEDTEXT = 21

const UA_NS0ID_STRUCTURE = 22

const UA_NS0ID_DATAVALUE = 23

const UA_NS0ID_BASEDATATYPE = 24

const UA_NS0ID_DIAGNOSTICINFO = 25

const UA_NS0ID_NUMBER = 26

const UA_NS0ID_INTEGER = 27

const UA_NS0ID_UINTEGER = 28

const UA_NS0ID_ENUMERATION = 29

const UA_NS0ID_IMAGE = 30

const UA_NS0ID_REFERENCES = 31

const UA_NS0ID_NONHIERARCHICALREFERENCES = 32

const UA_NS0ID_HIERARCHICALREFERENCES = 33

const UA_NS0ID_HASCHILD = 34

const UA_NS0ID_ORGANIZES = 35

const UA_NS0ID_HASEVENTSOURCE = 36

const UA_NS0ID_HASMODELLINGRULE = 37

const UA_NS0ID_HASENCODING = 38

const UA_NS0ID_HASDESCRIPTION = 39

const UA_NS0ID_HASTYPEDEFINITION = 40

const UA_NS0ID_GENERATESEVENT = 41

const UA_NS0ID_AGGREGATES = 44

const UA_NS0ID_HASSUBTYPE = 45

const UA_NS0ID_HASPROPERTY = 46

const UA_NS0ID_HASCOMPONENT = 47

const UA_NS0ID_HASNOTIFIER = 48

const UA_NS0ID_HASORDEREDCOMPONENT = 49

const UA_NS0ID_DECIMAL = 50

const UA_NS0ID_FROMSTATE = 51

const UA_NS0ID_TOSTATE = 52

const UA_NS0ID_HASCAUSE = 53

const UA_NS0ID_HASEFFECT = 54

const UA_NS0ID_HASHISTORICALCONFIGURATION = 56

const UA_NS0ID_BASEOBJECTTYPE = 58

const UA_NS0ID_FOLDERTYPE = 61

const UA_NS0ID_BASEVARIABLETYPE = 62

const UA_NS0ID_BASEDATAVARIABLETYPE = 63

const UA_NS0ID_PROPERTYTYPE = 68

const UA_NS0ID_DATATYPEDESCRIPTIONTYPE = 69

const UA_NS0ID_DATATYPEDICTIONARYTYPE = 72

const UA_NS0ID_DATATYPESYSTEMTYPE = 75

const UA_NS0ID_DATATYPEENCODINGTYPE = 76

const UA_NS0ID_MODELLINGRULETYPE = 77

const UA_NS0ID_MODELLINGRULE_MANDATORY = 78

const UA_NS0ID_MODELLINGRULE_MANDATORYSHARED = 79

const UA_NS0ID_MODELLINGRULE_OPTIONAL = 80

const UA_NS0ID_MODELLINGRULE_EXPOSESITSARRAY = 83

const UA_NS0ID_ROOTFOLDER = 84

const UA_NS0ID_OBJECTSFOLDER = 85

const UA_NS0ID_TYPESFOLDER = 86

const UA_NS0ID_VIEWSFOLDER = 87

const UA_NS0ID_OBJECTTYPESFOLDER = 88

const UA_NS0ID_VARIABLETYPESFOLDER = 89

const UA_NS0ID_DATATYPESFOLDER = 90

const UA_NS0ID_REFERENCETYPESFOLDER = 91

const UA_NS0ID_XMLSCHEMA_TYPESYSTEM = 92

const UA_NS0ID_OPCBINARYSCHEMA_TYPESYSTEM = 93

const UA_NS0ID_PERMISSIONTYPE = 94

const UA_NS0ID_ACCESSRESTRICTIONTYPE = 95

const UA_NS0ID_ROLEPERMISSIONTYPE = 96

const UA_NS0ID_DATATYPEDEFINITION = 97

const UA_NS0ID_STRUCTURETYPE = 98

const UA_NS0ID_STRUCTUREDEFINITION = 99

const UA_NS0ID_ENUMDEFINITION = 100

const UA_NS0ID_STRUCTUREFIELD = 101

const UA_NS0ID_ENUMFIELD = 102

const UA_NS0ID_DATATYPEDESCRIPTIONTYPE_DATATYPEVERSION = 104

const UA_NS0ID_DATATYPEDESCRIPTIONTYPE_DICTIONARYFRAGMENT = 105

const UA_NS0ID_DATATYPEDICTIONARYTYPE_DATATYPEVERSION = 106

const UA_NS0ID_DATATYPEDICTIONARYTYPE_NAMESPACEURI = 107

const UA_NS0ID_MODELLINGRULETYPE_NAMINGRULE = 111

const UA_NS0ID_MODELLINGRULE_MANDATORY_NAMINGRULE = 112

const UA_NS0ID_MODELLINGRULE_OPTIONAL_NAMINGRULE = 113

const UA_NS0ID_MODELLINGRULE_EXPOSESITSARRAY_NAMINGRULE = 114

const UA_NS0ID_MODELLINGRULE_MANDATORYSHARED_NAMINGRULE = 116

const UA_NS0ID_HASSUBSTATEMACHINE = 117

const UA_NS0ID_NAMINGRULETYPE = 120

const UA_NS0ID_DATATYPEDEFINITION_ENCODING_DEFAULTBINARY = 121

const UA_NS0ID_STRUCTUREDEFINITION_ENCODING_DEFAULTBINARY = 122

const UA_NS0ID_ENUMDEFINITION_ENCODING_DEFAULTBINARY = 123

const UA_NS0ID_DATASETMETADATATYPE_ENCODING_DEFAULTBINARY = 124

const UA_NS0ID_DATATYPEDESCRIPTION_ENCODING_DEFAULTBINARY = 125

const UA_NS0ID_STRUCTUREDESCRIPTION_ENCODING_DEFAULTBINARY = 126

const UA_NS0ID_ENUMDESCRIPTION_ENCODING_DEFAULTBINARY = 127

const UA_NS0ID_ROLEPERMISSIONTYPE_ENCODING_DEFAULTBINARY = 128

const UA_NS0ID_HASARGUMENTDESCRIPTION = 129

const UA_NS0ID_HASOPTIONALINPUTARGUMENTDESCRIPTION = 131

const UA_NS0ID_IDTYPE = 256

const UA_NS0ID_NODECLASS = 257

const UA_NS0ID_NODE = 258

const UA_NS0ID_NODE_ENCODING_DEFAULTXML = 259

const UA_NS0ID_NODE_ENCODING_DEFAULTBINARY = 260

const UA_NS0ID_OBJECTNODE = 261

const UA_NS0ID_OBJECTNODE_ENCODING_DEFAULTXML = 262

const UA_NS0ID_OBJECTNODE_ENCODING_DEFAULTBINARY = 263

const UA_NS0ID_OBJECTTYPENODE = 264

const UA_NS0ID_OBJECTTYPENODE_ENCODING_DEFAULTXML = 265

const UA_NS0ID_OBJECTTYPENODE_ENCODING_DEFAULTBINARY = 266

const UA_NS0ID_VARIABLENODE = 267

const UA_NS0ID_VARIABLENODE_ENCODING_DEFAULTXML = 268

const UA_NS0ID_VARIABLENODE_ENCODING_DEFAULTBINARY = 269

const UA_NS0ID_VARIABLETYPENODE = 270

const UA_NS0ID_VARIABLETYPENODE_ENCODING_DEFAULTXML = 271

const UA_NS0ID_VARIABLETYPENODE_ENCODING_DEFAULTBINARY = 272

const UA_NS0ID_REFERENCETYPENODE = 273

const UA_NS0ID_REFERENCETYPENODE_ENCODING_DEFAULTXML = 274

const UA_NS0ID_REFERENCETYPENODE_ENCODING_DEFAULTBINARY = 275

const UA_NS0ID_METHODNODE = 276

const UA_NS0ID_METHODNODE_ENCODING_DEFAULTXML = 277

const UA_NS0ID_METHODNODE_ENCODING_DEFAULTBINARY = 278

const UA_NS0ID_VIEWNODE = 279

const UA_NS0ID_VIEWNODE_ENCODING_DEFAULTXML = 280

const UA_NS0ID_VIEWNODE_ENCODING_DEFAULTBINARY = 281

const UA_NS0ID_DATATYPENODE = 282

const UA_NS0ID_DATATYPENODE_ENCODING_DEFAULTXML = 283

const UA_NS0ID_DATATYPENODE_ENCODING_DEFAULTBINARY = 284

const UA_NS0ID_REFERENCENODE = 285

const UA_NS0ID_REFERENCENODE_ENCODING_DEFAULTXML = 286

const UA_NS0ID_REFERENCENODE_ENCODING_DEFAULTBINARY = 287

const UA_NS0ID_INTEGERID = 288

const UA_NS0ID_COUNTER = 289

const UA_NS0ID_DURATION = 290

const UA_NS0ID_NUMERICRANGE = 291

const UA_NS0ID_TIME = 292

const UA_NS0ID_DATE = 293

const UA_NS0ID_UTCTIME = 294

const UA_NS0ID_LOCALEID = 295

const UA_NS0ID_ARGUMENT = 296

const UA_NS0ID_ARGUMENT_ENCODING_DEFAULTXML = 297

const UA_NS0ID_ARGUMENT_ENCODING_DEFAULTBINARY = 298

const UA_NS0ID_STATUSRESULT = 299

const UA_NS0ID_STATUSRESULT_ENCODING_DEFAULTXML = 300

const UA_NS0ID_STATUSRESULT_ENCODING_DEFAULTBINARY = 301

const UA_NS0ID_MESSAGESECURITYMODE = 302

const UA_NS0ID_USERTOKENTYPE = 303

const UA_NS0ID_USERTOKENPOLICY = 304

const UA_NS0ID_USERTOKENPOLICY_ENCODING_DEFAULTXML = 305

const UA_NS0ID_USERTOKENPOLICY_ENCODING_DEFAULTBINARY = 306

const UA_NS0ID_APPLICATIONTYPE = 307

const UA_NS0ID_APPLICATIONDESCRIPTION = 308

const UA_NS0ID_APPLICATIONDESCRIPTION_ENCODING_DEFAULTXML = 309

const UA_NS0ID_APPLICATIONDESCRIPTION_ENCODING_DEFAULTBINARY = 310

const UA_NS0ID_APPLICATIONINSTANCECERTIFICATE = 311

const UA_NS0ID_ENDPOINTDESCRIPTION = 312

const UA_NS0ID_ENDPOINTDESCRIPTION_ENCODING_DEFAULTXML = 313

const UA_NS0ID_ENDPOINTDESCRIPTION_ENCODING_DEFAULTBINARY = 314

const UA_NS0ID_SECURITYTOKENREQUESTTYPE = 315

const UA_NS0ID_USERIDENTITYTOKEN = 316

const UA_NS0ID_USERIDENTITYTOKEN_ENCODING_DEFAULTXML = 317

const UA_NS0ID_USERIDENTITYTOKEN_ENCODING_DEFAULTBINARY = 318

const UA_NS0ID_ANONYMOUSIDENTITYTOKEN = 319

const UA_NS0ID_ANONYMOUSIDENTITYTOKEN_ENCODING_DEFAULTXML = 320

const UA_NS0ID_ANONYMOUSIDENTITYTOKEN_ENCODING_DEFAULTBINARY = 321

const UA_NS0ID_USERNAMEIDENTITYTOKEN = 322

const UA_NS0ID_USERNAMEIDENTITYTOKEN_ENCODING_DEFAULTXML = 323

const UA_NS0ID_USERNAMEIDENTITYTOKEN_ENCODING_DEFAULTBINARY = 324

const UA_NS0ID_X509IDENTITYTOKEN = 325

const UA_NS0ID_X509IDENTITYTOKEN_ENCODING_DEFAULTXML = 326

const UA_NS0ID_X509IDENTITYTOKEN_ENCODING_DEFAULTBINARY = 327

const UA_NS0ID_ENDPOINTCONFIGURATION = 331

const UA_NS0ID_ENDPOINTCONFIGURATION_ENCODING_DEFAULTXML = 332

const UA_NS0ID_ENDPOINTCONFIGURATION_ENCODING_DEFAULTBINARY = 333

const UA_NS0ID_BUILDINFO = 338

const UA_NS0ID_BUILDINFO_ENCODING_DEFAULTXML = 339

const UA_NS0ID_BUILDINFO_ENCODING_DEFAULTBINARY = 340

const UA_NS0ID_SIGNEDSOFTWARECERTIFICATE = 344

const UA_NS0ID_SIGNEDSOFTWARECERTIFICATE_ENCODING_DEFAULTXML = 345

const UA_NS0ID_SIGNEDSOFTWARECERTIFICATE_ENCODING_DEFAULTBINARY = 346

const UA_NS0ID_ATTRIBUTEWRITEMASK = 347

const UA_NS0ID_NODEATTRIBUTESMASK = 348

const UA_NS0ID_NODEATTRIBUTES = 349

const UA_NS0ID_NODEATTRIBUTES_ENCODING_DEFAULTXML = 350

const UA_NS0ID_NODEATTRIBUTES_ENCODING_DEFAULTBINARY = 351

const UA_NS0ID_OBJECTATTRIBUTES = 352

const UA_NS0ID_OBJECTATTRIBUTES_ENCODING_DEFAULTXML = 353

const UA_NS0ID_OBJECTATTRIBUTES_ENCODING_DEFAULTBINARY = 354

const UA_NS0ID_VARIABLEATTRIBUTES = 355

const UA_NS0ID_VARIABLEATTRIBUTES_ENCODING_DEFAULTXML = 356

const UA_NS0ID_VARIABLEATTRIBUTES_ENCODING_DEFAULTBINARY = 357

const UA_NS0ID_METHODATTRIBUTES = 358

const UA_NS0ID_METHODATTRIBUTES_ENCODING_DEFAULTXML = 359

const UA_NS0ID_METHODATTRIBUTES_ENCODING_DEFAULTBINARY = 360

const UA_NS0ID_OBJECTTYPEATTRIBUTES = 361

const UA_NS0ID_OBJECTTYPEATTRIBUTES_ENCODING_DEFAULTXML = 362

const UA_NS0ID_OBJECTTYPEATTRIBUTES_ENCODING_DEFAULTBINARY = 363

const UA_NS0ID_VARIABLETYPEATTRIBUTES = 364

const UA_NS0ID_VARIABLETYPEATTRIBUTES_ENCODING_DEFAULTXML = 365

const UA_NS0ID_VARIABLETYPEATTRIBUTES_ENCODING_DEFAULTBINARY = 366

const UA_NS0ID_REFERENCETYPEATTRIBUTES = 367

const UA_NS0ID_REFERENCETYPEATTRIBUTES_ENCODING_DEFAULTXML = 368

const UA_NS0ID_REFERENCETYPEATTRIBUTES_ENCODING_DEFAULTBINARY = 369

const UA_NS0ID_DATATYPEATTRIBUTES = 370

const UA_NS0ID_DATATYPEATTRIBUTES_ENCODING_DEFAULTXML = 371

const UA_NS0ID_DATATYPEATTRIBUTES_ENCODING_DEFAULTBINARY = 372

const UA_NS0ID_VIEWATTRIBUTES = 373

const UA_NS0ID_VIEWATTRIBUTES_ENCODING_DEFAULTXML = 374

const UA_NS0ID_VIEWATTRIBUTES_ENCODING_DEFAULTBINARY = 375

const UA_NS0ID_ADDNODESITEM = 376

const UA_NS0ID_ADDNODESITEM_ENCODING_DEFAULTXML = 377

const UA_NS0ID_ADDNODESITEM_ENCODING_DEFAULTBINARY = 378

const UA_NS0ID_ADDREFERENCESITEM = 379

const UA_NS0ID_ADDREFERENCESITEM_ENCODING_DEFAULTXML = 380

const UA_NS0ID_ADDREFERENCESITEM_ENCODING_DEFAULTBINARY = 381

const UA_NS0ID_DELETENODESITEM = 382

const UA_NS0ID_DELETENODESITEM_ENCODING_DEFAULTXML = 383

const UA_NS0ID_DELETENODESITEM_ENCODING_DEFAULTBINARY = 384

const UA_NS0ID_DELETEREFERENCESITEM = 385

const UA_NS0ID_DELETEREFERENCESITEM_ENCODING_DEFAULTXML = 386

const UA_NS0ID_DELETEREFERENCESITEM_ENCODING_DEFAULTBINARY = 387

const UA_NS0ID_SESSIONAUTHENTICATIONTOKEN = 388

const UA_NS0ID_REQUESTHEADER = 389

const UA_NS0ID_REQUESTHEADER_ENCODING_DEFAULTXML = 390

const UA_NS0ID_REQUESTHEADER_ENCODING_DEFAULTBINARY = 391

const UA_NS0ID_RESPONSEHEADER = 392

const UA_NS0ID_RESPONSEHEADER_ENCODING_DEFAULTXML = 393

const UA_NS0ID_RESPONSEHEADER_ENCODING_DEFAULTBINARY = 394

const UA_NS0ID_SERVICEFAULT = 395

const UA_NS0ID_SERVICEFAULT_ENCODING_DEFAULTXML = 396

const UA_NS0ID_SERVICEFAULT_ENCODING_DEFAULTBINARY = 397

const UA_NS0ID_FINDSERVERSREQUEST = 420

const UA_NS0ID_FINDSERVERSREQUEST_ENCODING_DEFAULTXML = 421

const UA_NS0ID_FINDSERVERSREQUEST_ENCODING_DEFAULTBINARY = 422

const UA_NS0ID_FINDSERVERSRESPONSE = 423

const UA_NS0ID_FINDSERVERSRESPONSE_ENCODING_DEFAULTXML = 424

const UA_NS0ID_FINDSERVERSRESPONSE_ENCODING_DEFAULTBINARY = 425

const UA_NS0ID_GETENDPOINTSREQUEST = 426

const UA_NS0ID_GETENDPOINTSREQUEST_ENCODING_DEFAULTXML = 427

const UA_NS0ID_GETENDPOINTSREQUEST_ENCODING_DEFAULTBINARY = 428

const UA_NS0ID_GETENDPOINTSRESPONSE = 429

const UA_NS0ID_GETENDPOINTSRESPONSE_ENCODING_DEFAULTXML = 430

const UA_NS0ID_GETENDPOINTSRESPONSE_ENCODING_DEFAULTBINARY = 431

const UA_NS0ID_REGISTEREDSERVER = 432

const UA_NS0ID_REGISTEREDSERVER_ENCODING_DEFAULTXML = 433

const UA_NS0ID_REGISTEREDSERVER_ENCODING_DEFAULTBINARY = 434

const UA_NS0ID_REGISTERSERVERREQUEST = 435

const UA_NS0ID_REGISTERSERVERREQUEST_ENCODING_DEFAULTXML = 436

const UA_NS0ID_REGISTERSERVERREQUEST_ENCODING_DEFAULTBINARY = 437

const UA_NS0ID_REGISTERSERVERRESPONSE = 438

const UA_NS0ID_REGISTERSERVERRESPONSE_ENCODING_DEFAULTXML = 439

const UA_NS0ID_REGISTERSERVERRESPONSE_ENCODING_DEFAULTBINARY = 440

const UA_NS0ID_CHANNELSECURITYTOKEN = 441

const UA_NS0ID_CHANNELSECURITYTOKEN_ENCODING_DEFAULTXML = 442

const UA_NS0ID_CHANNELSECURITYTOKEN_ENCODING_DEFAULTBINARY = 443

const UA_NS0ID_OPENSECURECHANNELREQUEST = 444

const UA_NS0ID_OPENSECURECHANNELREQUEST_ENCODING_DEFAULTXML = 445

const UA_NS0ID_OPENSECURECHANNELREQUEST_ENCODING_DEFAULTBINARY = 446

const UA_NS0ID_OPENSECURECHANNELRESPONSE = 447

const UA_NS0ID_OPENSECURECHANNELRESPONSE_ENCODING_DEFAULTXML = 448

const UA_NS0ID_OPENSECURECHANNELRESPONSE_ENCODING_DEFAULTBINARY = 449

const UA_NS0ID_CLOSESECURECHANNELREQUEST = 450

const UA_NS0ID_CLOSESECURECHANNELREQUEST_ENCODING_DEFAULTXML = 451

const UA_NS0ID_CLOSESECURECHANNELREQUEST_ENCODING_DEFAULTBINARY = 452

const UA_NS0ID_CLOSESECURECHANNELRESPONSE = 453

const UA_NS0ID_CLOSESECURECHANNELRESPONSE_ENCODING_DEFAULTXML = 454

const UA_NS0ID_CLOSESECURECHANNELRESPONSE_ENCODING_DEFAULTBINARY = 455

const UA_NS0ID_SIGNATUREDATA = 456

const UA_NS0ID_SIGNATUREDATA_ENCODING_DEFAULTXML = 457

const UA_NS0ID_SIGNATUREDATA_ENCODING_DEFAULTBINARY = 458

const UA_NS0ID_CREATESESSIONREQUEST = 459

const UA_NS0ID_CREATESESSIONREQUEST_ENCODING_DEFAULTXML = 460

const UA_NS0ID_CREATESESSIONREQUEST_ENCODING_DEFAULTBINARY = 461

const UA_NS0ID_CREATESESSIONRESPONSE = 462

const UA_NS0ID_CREATESESSIONRESPONSE_ENCODING_DEFAULTXML = 463

const UA_NS0ID_CREATESESSIONRESPONSE_ENCODING_DEFAULTBINARY = 464

const UA_NS0ID_ACTIVATESESSIONREQUEST = 465

const UA_NS0ID_ACTIVATESESSIONREQUEST_ENCODING_DEFAULTXML = 466

const UA_NS0ID_ACTIVATESESSIONREQUEST_ENCODING_DEFAULTBINARY = 467

const UA_NS0ID_ACTIVATESESSIONRESPONSE = 468

const UA_NS0ID_ACTIVATESESSIONRESPONSE_ENCODING_DEFAULTXML = 469

const UA_NS0ID_ACTIVATESESSIONRESPONSE_ENCODING_DEFAULTBINARY = 470

const UA_NS0ID_CLOSESESSIONREQUEST = 471

const UA_NS0ID_CLOSESESSIONREQUEST_ENCODING_DEFAULTXML = 472

const UA_NS0ID_CLOSESESSIONREQUEST_ENCODING_DEFAULTBINARY = 473

const UA_NS0ID_CLOSESESSIONRESPONSE = 474

const UA_NS0ID_CLOSESESSIONRESPONSE_ENCODING_DEFAULTXML = 475

const UA_NS0ID_CLOSESESSIONRESPONSE_ENCODING_DEFAULTBINARY = 476

const UA_NS0ID_CANCELREQUEST = 477

const UA_NS0ID_CANCELREQUEST_ENCODING_DEFAULTXML = 478

const UA_NS0ID_CANCELREQUEST_ENCODING_DEFAULTBINARY = 479

const UA_NS0ID_CANCELRESPONSE = 480

const UA_NS0ID_CANCELRESPONSE_ENCODING_DEFAULTXML = 481

const UA_NS0ID_CANCELRESPONSE_ENCODING_DEFAULTBINARY = 482

const UA_NS0ID_ADDNODESRESULT = 483

const UA_NS0ID_ADDNODESRESULT_ENCODING_DEFAULTXML = 484

const UA_NS0ID_ADDNODESRESULT_ENCODING_DEFAULTBINARY = 485

const UA_NS0ID_ADDNODESREQUEST = 486

const UA_NS0ID_ADDNODESREQUEST_ENCODING_DEFAULTXML = 487

const UA_NS0ID_ADDNODESREQUEST_ENCODING_DEFAULTBINARY = 488

const UA_NS0ID_ADDNODESRESPONSE = 489

const UA_NS0ID_ADDNODESRESPONSE_ENCODING_DEFAULTXML = 490

const UA_NS0ID_ADDNODESRESPONSE_ENCODING_DEFAULTBINARY = 491

const UA_NS0ID_ADDREFERENCESREQUEST = 492

const UA_NS0ID_ADDREFERENCESREQUEST_ENCODING_DEFAULTXML = 493

const UA_NS0ID_ADDREFERENCESREQUEST_ENCODING_DEFAULTBINARY = 494

const UA_NS0ID_ADDREFERENCESRESPONSE = 495

const UA_NS0ID_ADDREFERENCESRESPONSE_ENCODING_DEFAULTXML = 496

const UA_NS0ID_ADDREFERENCESRESPONSE_ENCODING_DEFAULTBINARY = 497

const UA_NS0ID_DELETENODESREQUEST = 498

const UA_NS0ID_DELETENODESREQUEST_ENCODING_DEFAULTXML = 499

const UA_NS0ID_DELETENODESREQUEST_ENCODING_DEFAULTBINARY = 500

const UA_NS0ID_DELETENODESRESPONSE = 501

const UA_NS0ID_DELETENODESRESPONSE_ENCODING_DEFAULTXML = 502

const UA_NS0ID_DELETENODESRESPONSE_ENCODING_DEFAULTBINARY = 503

const UA_NS0ID_DELETEREFERENCESREQUEST = 504

const UA_NS0ID_DELETEREFERENCESREQUEST_ENCODING_DEFAULTXML = 505

const UA_NS0ID_DELETEREFERENCESREQUEST_ENCODING_DEFAULTBINARY = 506

const UA_NS0ID_DELETEREFERENCESRESPONSE = 507

const UA_NS0ID_DELETEREFERENCESRESPONSE_ENCODING_DEFAULTXML = 508

const UA_NS0ID_DELETEREFERENCESRESPONSE_ENCODING_DEFAULTBINARY = 509

const UA_NS0ID_BROWSEDIRECTION = 510

const UA_NS0ID_VIEWDESCRIPTION = 511

const UA_NS0ID_VIEWDESCRIPTION_ENCODING_DEFAULTXML = 512

const UA_NS0ID_VIEWDESCRIPTION_ENCODING_DEFAULTBINARY = 513

const UA_NS0ID_BROWSEDESCRIPTION = 514

const UA_NS0ID_BROWSEDESCRIPTION_ENCODING_DEFAULTXML = 515

const UA_NS0ID_BROWSEDESCRIPTION_ENCODING_DEFAULTBINARY = 516

const UA_NS0ID_BROWSERESULTMASK = 517

const UA_NS0ID_REFERENCEDESCRIPTION = 518

const UA_NS0ID_REFERENCEDESCRIPTION_ENCODING_DEFAULTXML = 519

const UA_NS0ID_REFERENCEDESCRIPTION_ENCODING_DEFAULTBINARY = 520

const UA_NS0ID_CONTINUATIONPOINT = 521

const UA_NS0ID_BROWSERESULT = 522

const UA_NS0ID_BROWSERESULT_ENCODING_DEFAULTXML = 523

const UA_NS0ID_BROWSERESULT_ENCODING_DEFAULTBINARY = 524

const UA_NS0ID_BROWSEREQUEST = 525

const UA_NS0ID_BROWSEREQUEST_ENCODING_DEFAULTXML = 526

const UA_NS0ID_BROWSEREQUEST_ENCODING_DEFAULTBINARY = 527

const UA_NS0ID_BROWSERESPONSE = 528

const UA_NS0ID_BROWSERESPONSE_ENCODING_DEFAULTXML = 529

const UA_NS0ID_BROWSERESPONSE_ENCODING_DEFAULTBINARY = 530

const UA_NS0ID_BROWSENEXTREQUEST = 531

const UA_NS0ID_BROWSENEXTREQUEST_ENCODING_DEFAULTXML = 532

const UA_NS0ID_BROWSENEXTREQUEST_ENCODING_DEFAULTBINARY = 533

const UA_NS0ID_BROWSENEXTRESPONSE = 534

const UA_NS0ID_BROWSENEXTRESPONSE_ENCODING_DEFAULTXML = 535

const UA_NS0ID_BROWSENEXTRESPONSE_ENCODING_DEFAULTBINARY = 536

const UA_NS0ID_RELATIVEPATHELEMENT = 537

const UA_NS0ID_RELATIVEPATHELEMENT_ENCODING_DEFAULTXML = 538

const UA_NS0ID_RELATIVEPATHELEMENT_ENCODING_DEFAULTBINARY = 539

const UA_NS0ID_RELATIVEPATH = 540

const UA_NS0ID_RELATIVEPATH_ENCODING_DEFAULTXML = 541

const UA_NS0ID_RELATIVEPATH_ENCODING_DEFAULTBINARY = 542

const UA_NS0ID_BROWSEPATH = 543

const UA_NS0ID_BROWSEPATH_ENCODING_DEFAULTXML = 544

const UA_NS0ID_BROWSEPATH_ENCODING_DEFAULTBINARY = 545

const UA_NS0ID_BROWSEPATHTARGET = 546

const UA_NS0ID_BROWSEPATHTARGET_ENCODING_DEFAULTXML = 547

const UA_NS0ID_BROWSEPATHTARGET_ENCODING_DEFAULTBINARY = 548

const UA_NS0ID_BROWSEPATHRESULT = 549

const UA_NS0ID_BROWSEPATHRESULT_ENCODING_DEFAULTXML = 550

const UA_NS0ID_BROWSEPATHRESULT_ENCODING_DEFAULTBINARY = 551

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSREQUEST = 552

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSREQUEST_ENCODING_DEFAULTXML = 553

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSREQUEST_ENCODING_DEFAULTBINARY = 554

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE = 555

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE_ENCODING_DEFAULTXML = 556

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE_ENCODING_DEFAULTBINARY = 557

const UA_NS0ID_REGISTERNODESREQUEST = 558

const UA_NS0ID_REGISTERNODESREQUEST_ENCODING_DEFAULTXML = 559

const UA_NS0ID_REGISTERNODESREQUEST_ENCODING_DEFAULTBINARY = 560

const UA_NS0ID_REGISTERNODESRESPONSE = 561

const UA_NS0ID_REGISTERNODESRESPONSE_ENCODING_DEFAULTXML = 562

const UA_NS0ID_REGISTERNODESRESPONSE_ENCODING_DEFAULTBINARY = 563

const UA_NS0ID_UNREGISTERNODESREQUEST = 564

const UA_NS0ID_UNREGISTERNODESREQUEST_ENCODING_DEFAULTXML = 565

const UA_NS0ID_UNREGISTERNODESREQUEST_ENCODING_DEFAULTBINARY = 566

const UA_NS0ID_UNREGISTERNODESRESPONSE = 567

const UA_NS0ID_UNREGISTERNODESRESPONSE_ENCODING_DEFAULTXML = 568

const UA_NS0ID_UNREGISTERNODESRESPONSE_ENCODING_DEFAULTBINARY = 569

const UA_NS0ID_QUERYDATADESCRIPTION = 570

const UA_NS0ID_QUERYDATADESCRIPTION_ENCODING_DEFAULTXML = 571

const UA_NS0ID_QUERYDATADESCRIPTION_ENCODING_DEFAULTBINARY = 572

const UA_NS0ID_NODETYPEDESCRIPTION = 573

const UA_NS0ID_NODETYPEDESCRIPTION_ENCODING_DEFAULTXML = 574

const UA_NS0ID_NODETYPEDESCRIPTION_ENCODING_DEFAULTBINARY = 575

const UA_NS0ID_FILTEROPERATOR = 576

const UA_NS0ID_QUERYDATASET = 577

const UA_NS0ID_QUERYDATASET_ENCODING_DEFAULTXML = 578

const UA_NS0ID_QUERYDATASET_ENCODING_DEFAULTBINARY = 579

const UA_NS0ID_NODEREFERENCE = 580

const UA_NS0ID_NODEREFERENCE_ENCODING_DEFAULTXML = 581

const UA_NS0ID_NODEREFERENCE_ENCODING_DEFAULTBINARY = 582

const UA_NS0ID_CONTENTFILTERELEMENT = 583

const UA_NS0ID_CONTENTFILTERELEMENT_ENCODING_DEFAULTXML = 584

const UA_NS0ID_CONTENTFILTERELEMENT_ENCODING_DEFAULTBINARY = 585

const UA_NS0ID_CONTENTFILTER = 586

const UA_NS0ID_CONTENTFILTER_ENCODING_DEFAULTXML = 587

const UA_NS0ID_CONTENTFILTER_ENCODING_DEFAULTBINARY = 588

const UA_NS0ID_FILTEROPERAND = 589

const UA_NS0ID_FILTEROPERAND_ENCODING_DEFAULTXML = 590

const UA_NS0ID_FILTEROPERAND_ENCODING_DEFAULTBINARY = 591

const UA_NS0ID_ELEMENTOPERAND = 592

const UA_NS0ID_ELEMENTOPERAND_ENCODING_DEFAULTXML = 593

const UA_NS0ID_ELEMENTOPERAND_ENCODING_DEFAULTBINARY = 594

const UA_NS0ID_LITERALOPERAND = 595

const UA_NS0ID_LITERALOPERAND_ENCODING_DEFAULTXML = 596

const UA_NS0ID_LITERALOPERAND_ENCODING_DEFAULTBINARY = 597

const UA_NS0ID_ATTRIBUTEOPERAND = 598

const UA_NS0ID_ATTRIBUTEOPERAND_ENCODING_DEFAULTXML = 599

const UA_NS0ID_ATTRIBUTEOPERAND_ENCODING_DEFAULTBINARY = 600

const UA_NS0ID_SIMPLEATTRIBUTEOPERAND = 601

const UA_NS0ID_SIMPLEATTRIBUTEOPERAND_ENCODING_DEFAULTXML = 602

const UA_NS0ID_SIMPLEATTRIBUTEOPERAND_ENCODING_DEFAULTBINARY = 603

const UA_NS0ID_CONTENTFILTERELEMENTRESULT = 604

const UA_NS0ID_CONTENTFILTERELEMENTRESULT_ENCODING_DEFAULTXML = 605

const UA_NS0ID_CONTENTFILTERELEMENTRESULT_ENCODING_DEFAULTBINARY = 606

const UA_NS0ID_CONTENTFILTERRESULT = 607

const UA_NS0ID_CONTENTFILTERRESULT_ENCODING_DEFAULTXML = 608

const UA_NS0ID_CONTENTFILTERRESULT_ENCODING_DEFAULTBINARY = 609

const UA_NS0ID_PARSINGRESULT = 610

const UA_NS0ID_PARSINGRESULT_ENCODING_DEFAULTXML = 611

const UA_NS0ID_PARSINGRESULT_ENCODING_DEFAULTBINARY = 612

const UA_NS0ID_QUERYFIRSTREQUEST = 613

const UA_NS0ID_QUERYFIRSTREQUEST_ENCODING_DEFAULTXML = 614

const UA_NS0ID_QUERYFIRSTREQUEST_ENCODING_DEFAULTBINARY = 615

const UA_NS0ID_QUERYFIRSTRESPONSE = 616

const UA_NS0ID_QUERYFIRSTRESPONSE_ENCODING_DEFAULTXML = 617

const UA_NS0ID_QUERYFIRSTRESPONSE_ENCODING_DEFAULTBINARY = 618

const UA_NS0ID_QUERYNEXTREQUEST = 619

const UA_NS0ID_QUERYNEXTREQUEST_ENCODING_DEFAULTXML = 620

const UA_NS0ID_QUERYNEXTREQUEST_ENCODING_DEFAULTBINARY = 621

const UA_NS0ID_QUERYNEXTRESPONSE = 622

const UA_NS0ID_QUERYNEXTRESPONSE_ENCODING_DEFAULTXML = 623

const UA_NS0ID_QUERYNEXTRESPONSE_ENCODING_DEFAULTBINARY = 624

const UA_NS0ID_TIMESTAMPSTORETURN = 625

const UA_NS0ID_READVALUEID = 626

const UA_NS0ID_READVALUEID_ENCODING_DEFAULTXML = 627

const UA_NS0ID_READVALUEID_ENCODING_DEFAULTBINARY = 628

const UA_NS0ID_READREQUEST = 629

const UA_NS0ID_READREQUEST_ENCODING_DEFAULTXML = 630

const UA_NS0ID_READREQUEST_ENCODING_DEFAULTBINARY = 631

const UA_NS0ID_READRESPONSE = 632

const UA_NS0ID_READRESPONSE_ENCODING_DEFAULTXML = 633

const UA_NS0ID_READRESPONSE_ENCODING_DEFAULTBINARY = 634

const UA_NS0ID_HISTORYREADVALUEID = 635

const UA_NS0ID_HISTORYREADVALUEID_ENCODING_DEFAULTXML = 636

const UA_NS0ID_HISTORYREADVALUEID_ENCODING_DEFAULTBINARY = 637

const UA_NS0ID_HISTORYREADRESULT = 638

const UA_NS0ID_HISTORYREADRESULT_ENCODING_DEFAULTXML = 639

const UA_NS0ID_HISTORYREADRESULT_ENCODING_DEFAULTBINARY = 640

const UA_NS0ID_HISTORYREADDETAILS = 641

const UA_NS0ID_HISTORYREADDETAILS_ENCODING_DEFAULTXML = 642

const UA_NS0ID_HISTORYREADDETAILS_ENCODING_DEFAULTBINARY = 643

const UA_NS0ID_READEVENTDETAILS = 644

const UA_NS0ID_READEVENTDETAILS_ENCODING_DEFAULTXML = 645

const UA_NS0ID_READEVENTDETAILS_ENCODING_DEFAULTBINARY = 646

const UA_NS0ID_READRAWMODIFIEDDETAILS = 647

const UA_NS0ID_READRAWMODIFIEDDETAILS_ENCODING_DEFAULTXML = 648

const UA_NS0ID_READRAWMODIFIEDDETAILS_ENCODING_DEFAULTBINARY = 649

const UA_NS0ID_READPROCESSEDDETAILS = 650

const UA_NS0ID_READPROCESSEDDETAILS_ENCODING_DEFAULTXML = 651

const UA_NS0ID_READPROCESSEDDETAILS_ENCODING_DEFAULTBINARY = 652

const UA_NS0ID_READATTIMEDETAILS = 653

const UA_NS0ID_READATTIMEDETAILS_ENCODING_DEFAULTXML = 654

const UA_NS0ID_READATTIMEDETAILS_ENCODING_DEFAULTBINARY = 655

const UA_NS0ID_HISTORYDATA = 656

const UA_NS0ID_HISTORYDATA_ENCODING_DEFAULTXML = 657

const UA_NS0ID_HISTORYDATA_ENCODING_DEFAULTBINARY = 658

const UA_NS0ID_HISTORYEVENT = 659

const UA_NS0ID_HISTORYEVENT_ENCODING_DEFAULTXML = 660

const UA_NS0ID_HISTORYEVENT_ENCODING_DEFAULTBINARY = 661

const UA_NS0ID_HISTORYREADREQUEST = 662

const UA_NS0ID_HISTORYREADREQUEST_ENCODING_DEFAULTXML = 663

const UA_NS0ID_HISTORYREADREQUEST_ENCODING_DEFAULTBINARY = 664

const UA_NS0ID_HISTORYREADRESPONSE = 665

const UA_NS0ID_HISTORYREADRESPONSE_ENCODING_DEFAULTXML = 666

const UA_NS0ID_HISTORYREADRESPONSE_ENCODING_DEFAULTBINARY = 667

const UA_NS0ID_WRITEVALUE = 668

const UA_NS0ID_WRITEVALUE_ENCODING_DEFAULTXML = 669

const UA_NS0ID_WRITEVALUE_ENCODING_DEFAULTBINARY = 670

const UA_NS0ID_WRITEREQUEST = 671

const UA_NS0ID_WRITEREQUEST_ENCODING_DEFAULTXML = 672

const UA_NS0ID_WRITEREQUEST_ENCODING_DEFAULTBINARY = 673

const UA_NS0ID_WRITERESPONSE = 674

const UA_NS0ID_WRITERESPONSE_ENCODING_DEFAULTXML = 675

const UA_NS0ID_WRITERESPONSE_ENCODING_DEFAULTBINARY = 676

const UA_NS0ID_HISTORYUPDATEDETAILS = 677

const UA_NS0ID_HISTORYUPDATEDETAILS_ENCODING_DEFAULTXML = 678

const UA_NS0ID_HISTORYUPDATEDETAILS_ENCODING_DEFAULTBINARY = 679

const UA_NS0ID_UPDATEDATADETAILS = 680

const UA_NS0ID_UPDATEDATADETAILS_ENCODING_DEFAULTXML = 681

const UA_NS0ID_UPDATEDATADETAILS_ENCODING_DEFAULTBINARY = 682

const UA_NS0ID_UPDATEEVENTDETAILS = 683

const UA_NS0ID_UPDATEEVENTDETAILS_ENCODING_DEFAULTXML = 684

const UA_NS0ID_UPDATEEVENTDETAILS_ENCODING_DEFAULTBINARY = 685

const UA_NS0ID_DELETERAWMODIFIEDDETAILS = 686

const UA_NS0ID_DELETERAWMODIFIEDDETAILS_ENCODING_DEFAULTXML = 687

const UA_NS0ID_DELETERAWMODIFIEDDETAILS_ENCODING_DEFAULTBINARY = 688

const UA_NS0ID_DELETEATTIMEDETAILS = 689

const UA_NS0ID_DELETEATTIMEDETAILS_ENCODING_DEFAULTXML = 690

const UA_NS0ID_DELETEATTIMEDETAILS_ENCODING_DEFAULTBINARY = 691

const UA_NS0ID_DELETEEVENTDETAILS = 692

const UA_NS0ID_DELETEEVENTDETAILS_ENCODING_DEFAULTXML = 693

const UA_NS0ID_DELETEEVENTDETAILS_ENCODING_DEFAULTBINARY = 694

const UA_NS0ID_HISTORYUPDATERESULT = 695

const UA_NS0ID_HISTORYUPDATERESULT_ENCODING_DEFAULTXML = 696

const UA_NS0ID_HISTORYUPDATERESULT_ENCODING_DEFAULTBINARY = 697

const UA_NS0ID_HISTORYUPDATEREQUEST = 698

const UA_NS0ID_HISTORYUPDATEREQUEST_ENCODING_DEFAULTXML = 699

const UA_NS0ID_HISTORYUPDATEREQUEST_ENCODING_DEFAULTBINARY = 700

const UA_NS0ID_HISTORYUPDATERESPONSE = 701

const UA_NS0ID_HISTORYUPDATERESPONSE_ENCODING_DEFAULTXML = 702

const UA_NS0ID_HISTORYUPDATERESPONSE_ENCODING_DEFAULTBINARY = 703

const UA_NS0ID_CALLMETHODREQUEST = 704

const UA_NS0ID_CALLMETHODREQUEST_ENCODING_DEFAULTXML = 705

const UA_NS0ID_CALLMETHODREQUEST_ENCODING_DEFAULTBINARY = 706

const UA_NS0ID_CALLMETHODRESULT = 707

const UA_NS0ID_CALLMETHODRESULT_ENCODING_DEFAULTXML = 708

const UA_NS0ID_CALLMETHODRESULT_ENCODING_DEFAULTBINARY = 709

const UA_NS0ID_CALLREQUEST = 710

const UA_NS0ID_CALLREQUEST_ENCODING_DEFAULTXML = 711

const UA_NS0ID_CALLREQUEST_ENCODING_DEFAULTBINARY = 712

const UA_NS0ID_CALLRESPONSE = 713

const UA_NS0ID_CALLRESPONSE_ENCODING_DEFAULTXML = 714

const UA_NS0ID_CALLRESPONSE_ENCODING_DEFAULTBINARY = 715

const UA_NS0ID_MONITORINGMODE = 716

const UA_NS0ID_DATACHANGETRIGGER = 717

const UA_NS0ID_DEADBANDTYPE = 718

const UA_NS0ID_MONITORINGFILTER = 719

const UA_NS0ID_MONITORINGFILTER_ENCODING_DEFAULTXML = 720

const UA_NS0ID_MONITORINGFILTER_ENCODING_DEFAULTBINARY = 721

const UA_NS0ID_DATACHANGEFILTER = 722

const UA_NS0ID_DATACHANGEFILTER_ENCODING_DEFAULTXML = 723

const UA_NS0ID_DATACHANGEFILTER_ENCODING_DEFAULTBINARY = 724

const UA_NS0ID_EVENTFILTER = 725

const UA_NS0ID_EVENTFILTER_ENCODING_DEFAULTXML = 726

const UA_NS0ID_EVENTFILTER_ENCODING_DEFAULTBINARY = 727

const UA_NS0ID_AGGREGATEFILTER = 728

const UA_NS0ID_AGGREGATEFILTER_ENCODING_DEFAULTXML = 729

const UA_NS0ID_AGGREGATEFILTER_ENCODING_DEFAULTBINARY = 730

const UA_NS0ID_MONITORINGFILTERRESULT = 731

const UA_NS0ID_MONITORINGFILTERRESULT_ENCODING_DEFAULTXML = 732

const UA_NS0ID_MONITORINGFILTERRESULT_ENCODING_DEFAULTBINARY = 733

const UA_NS0ID_EVENTFILTERRESULT = 734

const UA_NS0ID_EVENTFILTERRESULT_ENCODING_DEFAULTXML = 735

const UA_NS0ID_EVENTFILTERRESULT_ENCODING_DEFAULTBINARY = 736

const UA_NS0ID_AGGREGATEFILTERRESULT = 737

const UA_NS0ID_AGGREGATEFILTERRESULT_ENCODING_DEFAULTXML = 738

const UA_NS0ID_AGGREGATEFILTERRESULT_ENCODING_DEFAULTBINARY = 739

const UA_NS0ID_MONITORINGPARAMETERS = 740

const UA_NS0ID_MONITORINGPARAMETERS_ENCODING_DEFAULTXML = 741

const UA_NS0ID_MONITORINGPARAMETERS_ENCODING_DEFAULTBINARY = 742

const UA_NS0ID_MONITOREDITEMCREATEREQUEST = 743

const UA_NS0ID_MONITOREDITEMCREATEREQUEST_ENCODING_DEFAULTXML = 744

const UA_NS0ID_MONITOREDITEMCREATEREQUEST_ENCODING_DEFAULTBINARY = 745

const UA_NS0ID_MONITOREDITEMCREATERESULT = 746

const UA_NS0ID_MONITOREDITEMCREATERESULT_ENCODING_DEFAULTXML = 747

const UA_NS0ID_MONITOREDITEMCREATERESULT_ENCODING_DEFAULTBINARY = 748

const UA_NS0ID_CREATEMONITOREDITEMSREQUEST = 749

const UA_NS0ID_CREATEMONITOREDITEMSREQUEST_ENCODING_DEFAULTXML = 750

const UA_NS0ID_CREATEMONITOREDITEMSREQUEST_ENCODING_DEFAULTBINARY = 751

const UA_NS0ID_CREATEMONITOREDITEMSRESPONSE = 752

const UA_NS0ID_CREATEMONITOREDITEMSRESPONSE_ENCODING_DEFAULTXML = 753

const UA_NS0ID_CREATEMONITOREDITEMSRESPONSE_ENCODING_DEFAULTBINARY = 754

const UA_NS0ID_MONITOREDITEMMODIFYREQUEST = 755

const UA_NS0ID_MONITOREDITEMMODIFYREQUEST_ENCODING_DEFAULTXML = 756

const UA_NS0ID_MONITOREDITEMMODIFYREQUEST_ENCODING_DEFAULTBINARY = 757

const UA_NS0ID_MONITOREDITEMMODIFYRESULT = 758

const UA_NS0ID_MONITOREDITEMMODIFYRESULT_ENCODING_DEFAULTXML = 759

const UA_NS0ID_MONITOREDITEMMODIFYRESULT_ENCODING_DEFAULTBINARY = 760

const UA_NS0ID_MODIFYMONITOREDITEMSREQUEST = 761

const UA_NS0ID_MODIFYMONITOREDITEMSREQUEST_ENCODING_DEFAULTXML = 762

const UA_NS0ID_MODIFYMONITOREDITEMSREQUEST_ENCODING_DEFAULTBINARY = 763

const UA_NS0ID_MODIFYMONITOREDITEMSRESPONSE = 764

const UA_NS0ID_MODIFYMONITOREDITEMSRESPONSE_ENCODING_DEFAULTXML = 765

const UA_NS0ID_MODIFYMONITOREDITEMSRESPONSE_ENCODING_DEFAULTBINARY = 766

const UA_NS0ID_SETMONITORINGMODEREQUEST = 767

const UA_NS0ID_SETMONITORINGMODEREQUEST_ENCODING_DEFAULTXML = 768

const UA_NS0ID_SETMONITORINGMODEREQUEST_ENCODING_DEFAULTBINARY = 769

const UA_NS0ID_SETMONITORINGMODERESPONSE = 770

const UA_NS0ID_SETMONITORINGMODERESPONSE_ENCODING_DEFAULTXML = 771

const UA_NS0ID_SETMONITORINGMODERESPONSE_ENCODING_DEFAULTBINARY = 772

const UA_NS0ID_SETTRIGGERINGREQUEST = 773

const UA_NS0ID_SETTRIGGERINGREQUEST_ENCODING_DEFAULTXML = 774

const UA_NS0ID_SETTRIGGERINGREQUEST_ENCODING_DEFAULTBINARY = 775

const UA_NS0ID_SETTRIGGERINGRESPONSE = 776

const UA_NS0ID_SETTRIGGERINGRESPONSE_ENCODING_DEFAULTXML = 777

const UA_NS0ID_SETTRIGGERINGRESPONSE_ENCODING_DEFAULTBINARY = 778

const UA_NS0ID_DELETEMONITOREDITEMSREQUEST = 779

const UA_NS0ID_DELETEMONITOREDITEMSREQUEST_ENCODING_DEFAULTXML = 780

const UA_NS0ID_DELETEMONITOREDITEMSREQUEST_ENCODING_DEFAULTBINARY = 781

const UA_NS0ID_DELETEMONITOREDITEMSRESPONSE = 782

const UA_NS0ID_DELETEMONITOREDITEMSRESPONSE_ENCODING_DEFAULTXML = 783

const UA_NS0ID_DELETEMONITOREDITEMSRESPONSE_ENCODING_DEFAULTBINARY = 784

const UA_NS0ID_CREATESUBSCRIPTIONREQUEST = 785

const UA_NS0ID_CREATESUBSCRIPTIONREQUEST_ENCODING_DEFAULTXML = 786

const UA_NS0ID_CREATESUBSCRIPTIONREQUEST_ENCODING_DEFAULTBINARY = 787

const UA_NS0ID_CREATESUBSCRIPTIONRESPONSE = 788

const UA_NS0ID_CREATESUBSCRIPTIONRESPONSE_ENCODING_DEFAULTXML = 789

const UA_NS0ID_CREATESUBSCRIPTIONRESPONSE_ENCODING_DEFAULTBINARY = 790

const UA_NS0ID_MODIFYSUBSCRIPTIONREQUEST = 791

const UA_NS0ID_MODIFYSUBSCRIPTIONREQUEST_ENCODING_DEFAULTXML = 792

const UA_NS0ID_MODIFYSUBSCRIPTIONREQUEST_ENCODING_DEFAULTBINARY = 793

const UA_NS0ID_MODIFYSUBSCRIPTIONRESPONSE = 794

const UA_NS0ID_MODIFYSUBSCRIPTIONRESPONSE_ENCODING_DEFAULTXML = 795

const UA_NS0ID_MODIFYSUBSCRIPTIONRESPONSE_ENCODING_DEFAULTBINARY = 796

const UA_NS0ID_SETPUBLISHINGMODEREQUEST = 797

const UA_NS0ID_SETPUBLISHINGMODEREQUEST_ENCODING_DEFAULTXML = 798

const UA_NS0ID_SETPUBLISHINGMODEREQUEST_ENCODING_DEFAULTBINARY = 799

const UA_NS0ID_SETPUBLISHINGMODERESPONSE = 800

const UA_NS0ID_SETPUBLISHINGMODERESPONSE_ENCODING_DEFAULTXML = 801

const UA_NS0ID_SETPUBLISHINGMODERESPONSE_ENCODING_DEFAULTBINARY = 802

const UA_NS0ID_NOTIFICATIONMESSAGE = 803

const UA_NS0ID_NOTIFICATIONMESSAGE_ENCODING_DEFAULTXML = 804

const UA_NS0ID_NOTIFICATIONMESSAGE_ENCODING_DEFAULTBINARY = 805

const UA_NS0ID_MONITOREDITEMNOTIFICATION = 806

const UA_NS0ID_MONITOREDITEMNOTIFICATION_ENCODING_DEFAULTXML = 807

const UA_NS0ID_MONITOREDITEMNOTIFICATION_ENCODING_DEFAULTBINARY = 808

const UA_NS0ID_DATACHANGENOTIFICATION = 809

const UA_NS0ID_DATACHANGENOTIFICATION_ENCODING_DEFAULTXML = 810

const UA_NS0ID_DATACHANGENOTIFICATION_ENCODING_DEFAULTBINARY = 811

const UA_NS0ID_STATUSCHANGENOTIFICATION = 818

const UA_NS0ID_STATUSCHANGENOTIFICATION_ENCODING_DEFAULTXML = 819

const UA_NS0ID_STATUSCHANGENOTIFICATION_ENCODING_DEFAULTBINARY = 820

const UA_NS0ID_SUBSCRIPTIONACKNOWLEDGEMENT = 821

const UA_NS0ID_SUBSCRIPTIONACKNOWLEDGEMENT_ENCODING_DEFAULTXML = 822

const UA_NS0ID_SUBSCRIPTIONACKNOWLEDGEMENT_ENCODING_DEFAULTBINARY = 823

const UA_NS0ID_PUBLISHREQUEST = 824

const UA_NS0ID_PUBLISHREQUEST_ENCODING_DEFAULTXML = 825

const UA_NS0ID_PUBLISHREQUEST_ENCODING_DEFAULTBINARY = 826

const UA_NS0ID_PUBLISHRESPONSE = 827

const UA_NS0ID_PUBLISHRESPONSE_ENCODING_DEFAULTXML = 828

const UA_NS0ID_PUBLISHRESPONSE_ENCODING_DEFAULTBINARY = 829

const UA_NS0ID_REPUBLISHREQUEST = 830

const UA_NS0ID_REPUBLISHREQUEST_ENCODING_DEFAULTXML = 831

const UA_NS0ID_REPUBLISHREQUEST_ENCODING_DEFAULTBINARY = 832

const UA_NS0ID_REPUBLISHRESPONSE = 833

const UA_NS0ID_REPUBLISHRESPONSE_ENCODING_DEFAULTXML = 834

const UA_NS0ID_REPUBLISHRESPONSE_ENCODING_DEFAULTBINARY = 835

const UA_NS0ID_TRANSFERRESULT = 836

const UA_NS0ID_TRANSFERRESULT_ENCODING_DEFAULTXML = 837

const UA_NS0ID_TRANSFERRESULT_ENCODING_DEFAULTBINARY = 838

const UA_NS0ID_TRANSFERSUBSCRIPTIONSREQUEST = 839

const UA_NS0ID_TRANSFERSUBSCRIPTIONSREQUEST_ENCODING_DEFAULTXML = 840

const UA_NS0ID_TRANSFERSUBSCRIPTIONSREQUEST_ENCODING_DEFAULTBINARY = 841

const UA_NS0ID_TRANSFERSUBSCRIPTIONSRESPONSE = 842

const UA_NS0ID_TRANSFERSUBSCRIPTIONSRESPONSE_ENCODING_DEFAULTXML = 843

const UA_NS0ID_TRANSFERSUBSCRIPTIONSRESPONSE_ENCODING_DEFAULTBINARY = 844

const UA_NS0ID_DELETESUBSCRIPTIONSREQUEST = 845

const UA_NS0ID_DELETESUBSCRIPTIONSREQUEST_ENCODING_DEFAULTXML = 846

const UA_NS0ID_DELETESUBSCRIPTIONSREQUEST_ENCODING_DEFAULTBINARY = 847

const UA_NS0ID_DELETESUBSCRIPTIONSRESPONSE = 848

const UA_NS0ID_DELETESUBSCRIPTIONSRESPONSE_ENCODING_DEFAULTXML = 849

const UA_NS0ID_DELETESUBSCRIPTIONSRESPONSE_ENCODING_DEFAULTBINARY = 850

const UA_NS0ID_REDUNDANCYSUPPORT = 851

const UA_NS0ID_SERVERSTATE = 852

const UA_NS0ID_REDUNDANTSERVERDATATYPE = 853

const UA_NS0ID_REDUNDANTSERVERDATATYPE_ENCODING_DEFAULTXML = 854

const UA_NS0ID_REDUNDANTSERVERDATATYPE_ENCODING_DEFAULTBINARY = 855

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSDATATYPE = 856

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_ENCODING_DEFAULTXML = 857

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_ENCODING_DEFAULTBINARY = 858

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYDATATYPE = 859

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYDATATYPE_ENCODING_DEFAULTXML = 860

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYDATATYPE_ENCODING_DEFAULTBINARY = 861

const UA_NS0ID_SERVERSTATUSDATATYPE = 862

const UA_NS0ID_SERVERSTATUSDATATYPE_ENCODING_DEFAULTXML = 863

const UA_NS0ID_SERVERSTATUSDATATYPE_ENCODING_DEFAULTBINARY = 864

const UA_NS0ID_SESSIONDIAGNOSTICSDATATYPE = 865

const UA_NS0ID_SESSIONDIAGNOSTICSDATATYPE_ENCODING_DEFAULTXML = 866

const UA_NS0ID_SESSIONDIAGNOSTICSDATATYPE_ENCODING_DEFAULTBINARY = 867

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSDATATYPE = 868

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSDATATYPE_ENCODING_DEFAULTXML = 869

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSDATATYPE_ENCODING_DEFAULTBINARY = 870

const UA_NS0ID_SERVICECOUNTERDATATYPE = 871

const UA_NS0ID_SERVICECOUNTERDATATYPE_ENCODING_DEFAULTXML = 872

const UA_NS0ID_SERVICECOUNTERDATATYPE_ENCODING_DEFAULTBINARY = 873

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSDATATYPE = 874

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSDATATYPE_ENCODING_DEFAULTXML = 875

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSDATATYPE_ENCODING_DEFAULTBINARY = 876

const UA_NS0ID_MODELCHANGESTRUCTUREDATATYPE = 877

const UA_NS0ID_MODELCHANGESTRUCTUREDATATYPE_ENCODING_DEFAULTXML = 878

const UA_NS0ID_MODELCHANGESTRUCTUREDATATYPE_ENCODING_DEFAULTBINARY = 879

const UA_NS0ID_RANGE = 884

const UA_NS0ID_RANGE_ENCODING_DEFAULTXML = 885

const UA_NS0ID_RANGE_ENCODING_DEFAULTBINARY = 886

const UA_NS0ID_EUINFORMATION = 887

const UA_NS0ID_EUINFORMATION_ENCODING_DEFAULTXML = 888

const UA_NS0ID_EUINFORMATION_ENCODING_DEFAULTBINARY = 889

const UA_NS0ID_EXCEPTIONDEVIATIONFORMAT = 890

const UA_NS0ID_ANNOTATION = 891

const UA_NS0ID_ANNOTATION_ENCODING_DEFAULTXML = 892

const UA_NS0ID_ANNOTATION_ENCODING_DEFAULTBINARY = 893

const UA_NS0ID_PROGRAMDIAGNOSTICDATATYPE = 894

const UA_NS0ID_PROGRAMDIAGNOSTICDATATYPE_ENCODING_DEFAULTXML = 895

const UA_NS0ID_PROGRAMDIAGNOSTICDATATYPE_ENCODING_DEFAULTBINARY = 896

const UA_NS0ID_SEMANTICCHANGESTRUCTUREDATATYPE = 897

const UA_NS0ID_SEMANTICCHANGESTRUCTUREDATATYPE_ENCODING_DEFAULTXML = 898

const UA_NS0ID_SEMANTICCHANGESTRUCTUREDATATYPE_ENCODING_DEFAULTBINARY = 899

const UA_NS0ID_EVENTNOTIFICATIONLIST = 914

const UA_NS0ID_EVENTNOTIFICATIONLIST_ENCODING_DEFAULTXML = 915

const UA_NS0ID_EVENTNOTIFICATIONLIST_ENCODING_DEFAULTBINARY = 916

const UA_NS0ID_EVENTFIELDLIST = 917

const UA_NS0ID_EVENTFIELDLIST_ENCODING_DEFAULTXML = 918

const UA_NS0ID_EVENTFIELDLIST_ENCODING_DEFAULTBINARY = 919

const UA_NS0ID_HISTORYEVENTFIELDLIST = 920

const UA_NS0ID_HISTORYEVENTFIELDLIST_ENCODING_DEFAULTXML = 921

const UA_NS0ID_HISTORYEVENTFIELDLIST_ENCODING_DEFAULTBINARY = 922

const UA_NS0ID_ISSUEDIDENTITYTOKEN = 938

const UA_NS0ID_ISSUEDIDENTITYTOKEN_ENCODING_DEFAULTXML = 939

const UA_NS0ID_ISSUEDIDENTITYTOKEN_ENCODING_DEFAULTBINARY = 940

const UA_NS0ID_NOTIFICATIONDATA = 945

const UA_NS0ID_NOTIFICATIONDATA_ENCODING_DEFAULTXML = 946

const UA_NS0ID_NOTIFICATIONDATA_ENCODING_DEFAULTBINARY = 947

const UA_NS0ID_AGGREGATECONFIGURATION = 948

const UA_NS0ID_AGGREGATECONFIGURATION_ENCODING_DEFAULTXML = 949

const UA_NS0ID_AGGREGATECONFIGURATION_ENCODING_DEFAULTBINARY = 950

const UA_NS0ID_IMAGEBMP = 2000

const UA_NS0ID_IMAGEGIF = 2001

const UA_NS0ID_IMAGEJPG = 2002

const UA_NS0ID_IMAGEPNG = 2003

const UA_NS0ID_SERVERTYPE = 2004

const UA_NS0ID_SERVERTYPE_SERVERARRAY = 2005

const UA_NS0ID_SERVERTYPE_NAMESPACEARRAY = 2006

const UA_NS0ID_SERVERTYPE_SERVERSTATUS = 2007

const UA_NS0ID_SERVERTYPE_SERVICELEVEL = 2008

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES = 2009

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS = 2010

const UA_NS0ID_SERVERTYPE_VENDORSERVERINFO = 2011

const UA_NS0ID_SERVERTYPE_SERVERREDUNDANCY = 2012

const UA_NS0ID_SERVERCAPABILITIESTYPE = 2013

const UA_NS0ID_SERVERCAPABILITIESTYPE_SERVERPROFILEARRAY = 2014

const UA_NS0ID_SERVERCAPABILITIESTYPE_LOCALEIDARRAY = 2016

const UA_NS0ID_SERVERCAPABILITIESTYPE_MINSUPPORTEDSAMPLERATE = 2017

const UA_NS0ID_SERVERCAPABILITIESTYPE_MODELLINGRULES = 2019

const UA_NS0ID_SERVERDIAGNOSTICSTYPE = 2020

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY = 2021

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SAMPLINGINTERVALDIAGNOSTICSARRAY = 2022

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SUBSCRIPTIONDIAGNOSTICSARRAY = 2023

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_ENABLEDFLAG = 2025

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE = 2026

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_SESSIONDIAGNOSTICSARRAY = 2027

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_SESSIONSECURITYDIAGNOSTICSARRAY = 2028

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE = 2029

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS = 2030

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS = 2031

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SUBSCRIPTIONDIAGNOSTICSARRAY = 2032

const UA_NS0ID_VENDORSERVERINFOTYPE = 2033

const UA_NS0ID_SERVERREDUNDANCYTYPE = 2034

const UA_NS0ID_SERVERREDUNDANCYTYPE_REDUNDANCYSUPPORT = 2035

const UA_NS0ID_TRANSPARENTREDUNDANCYTYPE = 2036

const UA_NS0ID_TRANSPARENTREDUNDANCYTYPE_CURRENTSERVERID = 2037

const UA_NS0ID_TRANSPARENTREDUNDANCYTYPE_REDUNDANTSERVERARRAY = 2038

const UA_NS0ID_NONTRANSPARENTREDUNDANCYTYPE = 2039

const UA_NS0ID_NONTRANSPARENTREDUNDANCYTYPE_SERVERURIARRAY = 2040

const UA_NS0ID_BASEEVENTTYPE = 2041

const UA_NS0ID_BASEEVENTTYPE_EVENTID = 2042

const UA_NS0ID_BASEEVENTTYPE_EVENTTYPE = 2043

const UA_NS0ID_BASEEVENTTYPE_SOURCENODE = 2044

const UA_NS0ID_BASEEVENTTYPE_SOURCENAME = 2045

const UA_NS0ID_BASEEVENTTYPE_TIME = 2046

const UA_NS0ID_BASEEVENTTYPE_RECEIVETIME = 2047

const UA_NS0ID_BASEEVENTTYPE_MESSAGE = 2050

const UA_NS0ID_BASEEVENTTYPE_SEVERITY = 2051

const UA_NS0ID_AUDITEVENTTYPE = 2052

const UA_NS0ID_AUDITEVENTTYPE_ACTIONTIMESTAMP = 2053

const UA_NS0ID_AUDITEVENTTYPE_STATUS = 2054

const UA_NS0ID_AUDITEVENTTYPE_SERVERID = 2055

const UA_NS0ID_AUDITEVENTTYPE_CLIENTAUDITENTRYID = 2056

const UA_NS0ID_AUDITEVENTTYPE_CLIENTUSERID = 2057

const UA_NS0ID_AUDITSECURITYEVENTTYPE = 2058

const UA_NS0ID_AUDITCHANNELEVENTTYPE = 2059

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE = 2060

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_CLIENTCERTIFICATE = 2061

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_REQUESTTYPE = 2062

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SECURITYPOLICYURI = 2063

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SECURITYMODE = 2065

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_REQUESTEDLIFETIME = 2066

const UA_NS0ID_AUDITSESSIONEVENTTYPE = 2069

const UA_NS0ID_AUDITSESSIONEVENTTYPE_SESSIONID = 2070

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE = 2071

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_SECURECHANNELID = 2072

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_CLIENTCERTIFICATE = 2073

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_REVISEDSESSIONTIMEOUT = 2074

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE = 2075

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_CLIENTSOFTWARECERTIFICATES = 2076

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_USERIDENTITYTOKEN = 2077

const UA_NS0ID_AUDITCANCELEVENTTYPE = 2078

const UA_NS0ID_AUDITCANCELEVENTTYPE_REQUESTHANDLE = 2079

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE = 2080

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_CERTIFICATE = 2081

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE = 2082

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_INVALIDHOSTNAME = 2083

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_INVALIDURI = 2084

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE = 2085

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE = 2086

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE = 2087

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE = 2088

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE = 2089

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE = 2090

const UA_NS0ID_AUDITADDNODESEVENTTYPE = 2091

const UA_NS0ID_AUDITADDNODESEVENTTYPE_NODESTOADD = 2092

const UA_NS0ID_AUDITDELETENODESEVENTTYPE = 2093

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_NODESTODELETE = 2094

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE = 2095

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_REFERENCESTOADD = 2096

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE = 2097

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_REFERENCESTODELETE = 2098

const UA_NS0ID_AUDITUPDATEEVENTTYPE = 2099

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE = 2100

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_INDEXRANGE = 2101

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_OLDVALUE = 2102

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_NEWVALUE = 2103

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE = 2104

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE = 2127

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_METHODID = 2128

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_INPUTARGUMENTS = 2129

const UA_NS0ID_SYSTEMEVENTTYPE = 2130

const UA_NS0ID_DEVICEFAILUREEVENTTYPE = 2131

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE = 2132

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE = 2133

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_CHANGES = 2134

const UA_NS0ID_SERVERVENDORCAPABILITYTYPE = 2137

const UA_NS0ID_SERVERSTATUSTYPE = 2138

const UA_NS0ID_SERVERSTATUSTYPE_STARTTIME = 2139

const UA_NS0ID_SERVERSTATUSTYPE_CURRENTTIME = 2140

const UA_NS0ID_SERVERSTATUSTYPE_STATE = 2141

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO = 2142

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE = 2150

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_SERVERVIEWCOUNT = 2151

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_CURRENTSESSIONCOUNT = 2152

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_CUMULATEDSESSIONCOUNT = 2153

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_SECURITYREJECTEDSESSIONCOUNT = 2154

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_REJECTEDSESSIONCOUNT = 2155

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_SESSIONTIMEOUTCOUNT = 2156

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_SESSIONABORTCOUNT = 2157

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_PUBLISHINGINTERVALCOUNT = 2159

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_CURRENTSUBSCRIPTIONCOUNT = 2160

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_CUMULATEDSUBSCRIPTIONCOUNT = 2161

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_SECURITYREJECTEDREQUESTSCOUNT = 2162

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYTYPE_REJECTEDREQUESTSCOUNT = 2163

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSARRAYTYPE = 2164

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSTYPE = 2165

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSTYPE_SAMPLINGINTERVAL = 2166

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE = 2171

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE = 2172

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_SESSIONID = 2173

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_SUBSCRIPTIONID = 2174

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_PRIORITY = 2175

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_PUBLISHINGINTERVAL = 2176

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_MAXKEEPALIVECOUNT = 2177

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_MAXNOTIFICATIONSPERPUBLISH = 2179

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_PUBLISHINGENABLED = 2180

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_MODIFYCOUNT = 2181

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_ENABLECOUNT = 2182

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_DISABLECOUNT = 2183

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_REPUBLISHREQUESTCOUNT = 2184

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_REPUBLISHMESSAGEREQUESTCOUNT = 2185

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_REPUBLISHMESSAGECOUNT = 2186

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_TRANSFERREQUESTCOUNT = 2187

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_TRANSFERREDTOALTCLIENTCOUNT = 2188

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_TRANSFERREDTOSAMECLIENTCOUNT = 2189

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_PUBLISHREQUESTCOUNT = 2190

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_DATACHANGENOTIFICATIONSCOUNT = 2191

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_NOTIFICATIONSCOUNT = 2193

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE = 2196

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE = 2197

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_SESSIONID = 2198

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_SESSIONNAME = 2199

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CLIENTDESCRIPTION = 2200

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_SERVERURI = 2201

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_ENDPOINTURL = 2202

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_LOCALEIDS = 2203

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_ACTUALSESSIONTIMEOUT = 2204

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CLIENTCONNECTIONTIME = 2205

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CLIENTLASTCONTACTTIME = 2206

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CURRENTSUBSCRIPTIONSCOUNT = 2207

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CURRENTMONITOREDITEMSCOUNT = 2208

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CURRENTPUBLISHREQUESTSINQUEUE = 2209

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_READCOUNT = 2217

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_HISTORYREADCOUNT = 2218

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_WRITECOUNT = 2219

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_HISTORYUPDATECOUNT = 2220

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CALLCOUNT = 2221

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CREATEMONITOREDITEMSCOUNT = 2222

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_MODIFYMONITOREDITEMSCOUNT = 2223

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_SETMONITORINGMODECOUNT = 2224

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_SETTRIGGERINGCOUNT = 2225

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_DELETEMONITOREDITEMSCOUNT = 2226

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_CREATESUBSCRIPTIONCOUNT = 2227

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_MODIFYSUBSCRIPTIONCOUNT = 2228

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_SETPUBLISHINGMODECOUNT = 2229

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_PUBLISHCOUNT = 2230

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_REPUBLISHCOUNT = 2231

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_TRANSFERSUBSCRIPTIONSCOUNT = 2232

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_DELETESUBSCRIPTIONSCOUNT = 2233

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_ADDNODESCOUNT = 2234

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_ADDREFERENCESCOUNT = 2235

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_DELETENODESCOUNT = 2236

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_DELETEREFERENCESCOUNT = 2237

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_BROWSECOUNT = 2238

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_BROWSENEXTCOUNT = 2239

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_TRANSLATEBROWSEPATHSTONODEIDSCOUNT = 2240

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_QUERYFIRSTCOUNT = 2241

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_QUERYNEXTCOUNT = 2242

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE = 2243

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE = 2244

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_SESSIONID = 2245

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_CLIENTUSERIDOFSESSION = 2246

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_CLIENTUSERIDHISTORY = 2247

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_AUTHENTICATIONMECHANISM = 2248

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_ENCODING = 2249

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_TRANSPORTPROTOCOL = 2250

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_SECURITYMODE = 2251

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_SECURITYPOLICYURI = 2252

const UA_NS0ID_SERVER = 2253

const UA_NS0ID_SERVER_SERVERARRAY = 2254

const UA_NS0ID_SERVER_NAMESPACEARRAY = 2255

const UA_NS0ID_SERVER_SERVERSTATUS = 2256

const UA_NS0ID_SERVER_SERVERSTATUS_STARTTIME = 2257

const UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME = 2258

const UA_NS0ID_SERVER_SERVERSTATUS_STATE = 2259

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO = 2260

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_PRODUCTNAME = 2261

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_PRODUCTURI = 2262

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_MANUFACTURERNAME = 2263

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION = 2264

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_BUILDNUMBER = 2265

const UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_BUILDDATE = 2266

const UA_NS0ID_SERVER_SERVICELEVEL = 2267

const UA_NS0ID_SERVER_SERVERCAPABILITIES = 2268

const UA_NS0ID_SERVER_SERVERCAPABILITIES_SERVERPROFILEARRAY = 2269

const UA_NS0ID_SERVER_SERVERCAPABILITIES_LOCALEIDARRAY = 2271

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MINSUPPORTEDSAMPLERATE = 2272

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS = 2274

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY = 2275

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SERVERVIEWCOUNT = 2276

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CURRENTSESSIONCOUNT = 2277

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CUMULATEDSESSIONCOUNT = 2278

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SECURITYREJECTEDSESSIONCOUNT = 2279

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SESSIONTIMEOUTCOUNT = 2281

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SESSIONABORTCOUNT = 2282

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_PUBLISHINGINTERVALCOUNT = 2284

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CURRENTSUBSCRIPTIONCOUNT = 2285

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CUMULATEDSUBSCRIPTIONCOUNT = 2286

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SECURITYREJECTEDREQUESTSCOUNT = 2287

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_REJECTEDREQUESTSCOUNT = 2288

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SAMPLINGINTERVALDIAGNOSTICSARRAY = 2289

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SUBSCRIPTIONDIAGNOSTICSARRAY = 2290

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_ENABLEDFLAG = 2294

const UA_NS0ID_SERVER_VENDORSERVERINFO = 2295

const UA_NS0ID_SERVER_SERVERREDUNDANCY = 2296

const UA_NS0ID_STATEMACHINETYPE = 2299

const UA_NS0ID_STATETYPE = 2307

const UA_NS0ID_STATETYPE_STATENUMBER = 2308

const UA_NS0ID_INITIALSTATETYPE = 2309

const UA_NS0ID_TRANSITIONTYPE = 2310

const UA_NS0ID_TRANSITIONEVENTTYPE = 2311

const UA_NS0ID_TRANSITIONTYPE_TRANSITIONNUMBER = 2312

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE = 2315

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE = 2318

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_STEPPED = 2323

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_DEFINITION = 2324

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_MAXTIMEINTERVAL = 2325

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_MINTIMEINTERVAL = 2326

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_EXCEPTIONDEVIATION = 2327

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_EXCEPTIONDEVIATIONFORMAT = 2328

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE = 2330

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_ACCESSHISTORYDATACAPABILITY = 2331

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_ACCESSHISTORYEVENTSCAPABILITY = 2332

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_INSERTDATACAPABILITY = 2334

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_REPLACEDATACAPABILITY = 2335

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_UPDATEDATACAPABILITY = 2336

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_DELETERAWCAPABILITY = 2337

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_DELETEATTIMECAPABILITY = 2338

const UA_NS0ID_AGGREGATEFUNCTIONTYPE = 2340

const UA_NS0ID_AGGREGATEFUNCTION_INTERPOLATIVE = 2341

const UA_NS0ID_AGGREGATEFUNCTION_AVERAGE = 2342

const UA_NS0ID_AGGREGATEFUNCTION_TIMEAVERAGE = 2343

const UA_NS0ID_AGGREGATEFUNCTION_TOTAL = 2344

const UA_NS0ID_AGGREGATEFUNCTION_MINIMUM = 2346

const UA_NS0ID_AGGREGATEFUNCTION_MAXIMUM = 2347

const UA_NS0ID_AGGREGATEFUNCTION_MINIMUMACTUALTIME = 2348

const UA_NS0ID_AGGREGATEFUNCTION_MAXIMUMACTUALTIME = 2349

const UA_NS0ID_AGGREGATEFUNCTION_RANGE = 2350

const UA_NS0ID_AGGREGATEFUNCTION_ANNOTATIONCOUNT = 2351

const UA_NS0ID_AGGREGATEFUNCTION_COUNT = 2352

const UA_NS0ID_AGGREGATEFUNCTION_NUMBEROFTRANSITIONS = 2355

const UA_NS0ID_AGGREGATEFUNCTION_START = 2357

const UA_NS0ID_AGGREGATEFUNCTION_END = 2358

const UA_NS0ID_AGGREGATEFUNCTION_DELTA = 2359

const UA_NS0ID_AGGREGATEFUNCTION_DURATIONGOOD = 2360

const UA_NS0ID_AGGREGATEFUNCTION_DURATIONBAD = 2361

const UA_NS0ID_AGGREGATEFUNCTION_PERCENTGOOD = 2362

const UA_NS0ID_AGGREGATEFUNCTION_PERCENTBAD = 2363

const UA_NS0ID_AGGREGATEFUNCTION_WORSTQUALITY = 2364

const UA_NS0ID_DATAITEMTYPE = 2365

const UA_NS0ID_DATAITEMTYPE_DEFINITION = 2366

const UA_NS0ID_DATAITEMTYPE_VALUEPRECISION = 2367

const UA_NS0ID_ANALOGITEMTYPE = 2368

const UA_NS0ID_ANALOGITEMTYPE_EURANGE = 2369

const UA_NS0ID_ANALOGITEMTYPE_INSTRUMENTRANGE = 2370

const UA_NS0ID_ANALOGITEMTYPE_ENGINEERINGUNITS = 2371

const UA_NS0ID_DISCRETEITEMTYPE = 2372

const UA_NS0ID_TWOSTATEDISCRETETYPE = 2373

const UA_NS0ID_TWOSTATEDISCRETETYPE_FALSESTATE = 2374

const UA_NS0ID_TWOSTATEDISCRETETYPE_TRUESTATE = 2375

const UA_NS0ID_MULTISTATEDISCRETETYPE = 2376

const UA_NS0ID_MULTISTATEDISCRETETYPE_ENUMSTRINGS = 2377

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE = 2378

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_INTERMEDIATERESULT = 2379

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE = 2380

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_CREATESESSIONID = 2381

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_CREATECLIENTNAME = 2382

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_INVOCATIONCREATIONTIME = 2383

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTTRANSITIONTIME = 2384

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTMETHODCALL = 2385

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTMETHODSESSIONID = 2386

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTMETHODINPUTARGUMENTS = 2387

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTMETHODOUTPUTARGUMENTS = 2388

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTMETHODCALLTIME = 2389

const UA_NS0ID_PROGRAMDIAGNOSTICTYPE_LASTMETHODRETURNSTATUS = 2390

const UA_NS0ID_PROGRAMSTATEMACHINETYPE = 2391

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_CREATABLE = 2392

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_DELETABLE = 2393

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_AUTODELETE = 2394

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RECYCLECOUNT = 2395

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_INSTANCECOUNT = 2396

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_MAXINSTANCECOUNT = 2397

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_MAXRECYCLECOUNT = 2398

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC = 2399

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_READY = 2400

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_READY_STATENUMBER = 2401

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNING = 2402

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNING_STATENUMBER = 2403

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDED = 2404

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDED_STATENUMBER = 2405

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_HALTED = 2406

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_HALTED_STATENUMBER = 2407

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_HALTEDTOREADY = 2408

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_HALTEDTOREADY_TRANSITIONNUMBER = 2409

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_READYTORUNNING = 2410

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_READYTORUNNING_TRANSITIONNUMBER = 2411

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNINGTOHALTED = 2412

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNINGTOHALTED_TRANSITIONNUMBER = 2413

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNINGTOREADY = 2414

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNINGTOREADY_TRANSITIONNUMBER = 2415

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNINGTOSUSPENDED = 2416

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RUNNINGTOSUSPENDED_TRANSITIONNUMBER = 2417

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDEDTORUNNING = 2418

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDEDTORUNNING_TRANSITIONNUMBER = 2419

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDEDTOHALTED = 2420

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDEDTOHALTED_TRANSITIONNUMBER = 2421

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDEDTOREADY = 2422

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPENDEDTOREADY_TRANSITIONNUMBER = 2423

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_READYTOHALTED = 2424

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_READYTOHALTED_TRANSITIONNUMBER = 2425

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_START = 2426

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_SUSPEND = 2427

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RESUME = 2428

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_HALT = 2429

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_RESET = 2430

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_REGISTERNODESCOUNT = 2730

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_UNREGISTERNODESCOUNT = 2731

const UA_NS0ID_SERVERCAPABILITIESTYPE_MAXBROWSECONTINUATIONPOINTS = 2732

const UA_NS0ID_SERVERCAPABILITIESTYPE_MAXQUERYCONTINUATIONPOINTS = 2733

const UA_NS0ID_SERVERCAPABILITIESTYPE_MAXHISTORYCONTINUATIONPOINTS = 2734

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MAXBROWSECONTINUATIONPOINTS = 2735

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MAXQUERYCONTINUATIONPOINTS = 2736

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MAXHISTORYCONTINUATIONPOINTS = 2737

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE = 2738

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_CHANGES = 2739

const UA_NS0ID_SERVERTYPE_AUDITING = 2742

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SESSIONSDIAGNOSTICSSUMMARY = 2744

const UA_NS0ID_AUDITCHANNELEVENTTYPE_SECURECHANNELID = 2745

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_CLIENTCERTIFICATETHUMBPRINT = 2746

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_CLIENTCERTIFICATETHUMBPRINT = 2747

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE = 2748

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_ENDPOINTURL = 2749

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_ATTRIBUTEID = 2750

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_PARAMETERDATATYPEID = 2751

const UA_NS0ID_SERVERSTATUSTYPE_SECONDSTILLSHUTDOWN = 2752

const UA_NS0ID_SERVERSTATUSTYPE_SHUTDOWNREASON = 2753

const UA_NS0ID_SERVERCAPABILITIESTYPE_AGGREGATEFUNCTIONS = 2754

const UA_NS0ID_STATEVARIABLETYPE = 2755

const UA_NS0ID_STATEVARIABLETYPE_ID = 2756

const UA_NS0ID_STATEVARIABLETYPE_NAME = 2757

const UA_NS0ID_STATEVARIABLETYPE_NUMBER = 2758

const UA_NS0ID_STATEVARIABLETYPE_EFFECTIVEDISPLAYNAME = 2759

const UA_NS0ID_FINITESTATEVARIABLETYPE = 2760

const UA_NS0ID_FINITESTATEVARIABLETYPE_ID = 2761

const UA_NS0ID_TRANSITIONVARIABLETYPE = 2762

const UA_NS0ID_TRANSITIONVARIABLETYPE_ID = 2763

const UA_NS0ID_TRANSITIONVARIABLETYPE_NAME = 2764

const UA_NS0ID_TRANSITIONVARIABLETYPE_NUMBER = 2765

const UA_NS0ID_TRANSITIONVARIABLETYPE_TRANSITIONTIME = 2766

const UA_NS0ID_FINITETRANSITIONVARIABLETYPE = 2767

const UA_NS0ID_FINITETRANSITIONVARIABLETYPE_ID = 2768

const UA_NS0ID_STATEMACHINETYPE_CURRENTSTATE = 2769

const UA_NS0ID_STATEMACHINETYPE_LASTTRANSITION = 2770

const UA_NS0ID_FINITESTATEMACHINETYPE = 2771

const UA_NS0ID_FINITESTATEMACHINETYPE_CURRENTSTATE = 2772

const UA_NS0ID_FINITESTATEMACHINETYPE_LASTTRANSITION = 2773

const UA_NS0ID_TRANSITIONEVENTTYPE_TRANSITION = 2774

const UA_NS0ID_TRANSITIONEVENTTYPE_FROMSTATE = 2775

const UA_NS0ID_TRANSITIONEVENTTYPE_TOSTATE = 2776

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_OLDSTATEID = 2777

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_NEWSTATEID = 2778

const UA_NS0ID_CONDITIONTYPE = 2782

const UA_NS0ID_REFRESHSTARTEVENTTYPE = 2787

const UA_NS0ID_REFRESHENDEVENTTYPE = 2788

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE = 2789

const UA_NS0ID_AUDITCONDITIONEVENTTYPE = 2790

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE = 2803

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE = 2829

const UA_NS0ID_DIALOGCONDITIONTYPE = 2830

const UA_NS0ID_DIALOGCONDITIONTYPE_PROMPT = 2831

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE = 2881

const UA_NS0ID_ALARMCONDITIONTYPE = 2915

const UA_NS0ID_SHELVEDSTATEMACHINETYPE = 2929

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVED = 2930

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVED = 2932

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVED = 2933

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVEDTOTIMEDSHELVED = 2935

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVEDTOONESHOTSHELVED = 2936

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVEDTOUNSHELVED = 2940

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVEDTOONESHOTSHELVED = 2942

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVEDTOUNSHELVED = 2943

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVEDTOTIMEDSHELVED = 2945

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVE = 2947

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVE = 2948

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVE = 2949

const UA_NS0ID_LIMITALARMTYPE = 2955

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVE_INPUTARGUMENTS = 2991

const UA_NS0ID_SERVER_SERVERSTATUS_SECONDSTILLSHUTDOWN = 2992

const UA_NS0ID_SERVER_SERVERSTATUS_SHUTDOWNREASON = 2993

const UA_NS0ID_SERVER_AUDITING = 2994

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MODELLINGRULES = 2996

const UA_NS0ID_SERVER_SERVERCAPABILITIES_AGGREGATEFUNCTIONS = 2997

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_EVENTNOTIFICATIONSCOUNT = 2998

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE = 2999

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_FILTER = 3003

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE = 3006

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE = 3012

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE = 3014

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_ISDELETEMODIFIED = 3015

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_STARTTIME = 3016

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_ENDTIME = 3017

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE = 3019

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_REQTIMES = 3020

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_OLDVALUES = 3021

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE = 3022

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_EVENTIDS = 3023

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_OLDVALUES = 3024

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_UPDATEDNODE = 3025

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_UPDATEDNODE = 3026

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_UPDATEDNODE = 3027

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_PERFORMINSERTREPLACE = 3028

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_NEWVALUES = 3029

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_OLDVALUES = 3030

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_PERFORMINSERTREPLACE = 3031

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_NEWVALUES = 3032

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_OLDVALUES = 3033

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_OLDVALUES = 3034

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE = 3035

const UA_NS0ID_EVENTTYPESFOLDER = 3048

const UA_NS0ID_SERVERCAPABILITIESTYPE_SOFTWARECERTIFICATES = 3049

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_MAXRESPONSEMESSAGESIZE = 3050

const UA_NS0ID_BUILDINFOTYPE = 3051

const UA_NS0ID_BUILDINFOTYPE_PRODUCTURI = 3052

const UA_NS0ID_BUILDINFOTYPE_MANUFACTURERNAME = 3053

const UA_NS0ID_BUILDINFOTYPE_PRODUCTNAME = 3054

const UA_NS0ID_BUILDINFOTYPE_SOFTWAREVERSION = 3055

const UA_NS0ID_BUILDINFOTYPE_BUILDNUMBER = 3056

const UA_NS0ID_BUILDINFOTYPE_BUILDDATE = 3057

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSTYPE_CLIENTCERTIFICATE = 3058

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_AGGREGATECONFIGURATION = 3059

const UA_NS0ID_DEFAULTBINARY = 3062

const UA_NS0ID_DEFAULTXML = 3063

const UA_NS0ID_ALWAYSGENERATESEVENT = 3065

const UA_NS0ID_ICON = 3067

const UA_NS0ID_NODEVERSION = 3068

const UA_NS0ID_LOCALTIME = 3069

const UA_NS0ID_ALLOWNULLS = 3070

const UA_NS0ID_ENUMVALUES = 3071

const UA_NS0ID_INPUTARGUMENTS = 3072

const UA_NS0ID_OUTPUTARGUMENTS = 3073

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_STARTTIME = 3074

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_CURRENTTIME = 3075

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_STATE = 3076

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO = 3077

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO_PRODUCTURI = 3078

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO_MANUFACTURERNAME = 3079

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO_PRODUCTNAME = 3080

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION = 3081

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO_BUILDNUMBER = 3082

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_BUILDINFO_BUILDDATE = 3083

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_SECONDSTILLSHUTDOWN = 3084

const UA_NS0ID_SERVERTYPE_SERVERSTATUS_SHUTDOWNREASON = 3085

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_SERVERPROFILEARRAY = 3086

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_LOCALEIDARRAY = 3087

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MINSUPPORTEDSAMPLERATE = 3088

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MAXBROWSECONTINUATIONPOINTS = 3089

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MAXQUERYCONTINUATIONPOINTS = 3090

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MAXHISTORYCONTINUATIONPOINTS = 3091

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_SOFTWARECERTIFICATES = 3092

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MODELLINGRULES = 3093

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_AGGREGATEFUNCTIONS = 3094

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY = 3095

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SERVERVIEWCOUNT = 3096

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CURRENTSESSIONCOUNT = 3097

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CUMULATEDSESSIONCOUNT = 3098

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SECURITYREJECTEDSESSIONCOUNT = 3099

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_REJECTEDSESSIONCOUNT = 3100

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SESSIONTIMEOUTCOUNT = 3101

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SESSIONABORTCOUNT = 3102

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_PUBLISHINGINTERVALCOUNT = 3104

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CURRENTSUBSCRIPTIONCOUNT = 3105

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_CUMULATEDSUBSCRIPTIONCOUNT = 3106

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_SECURITYREJECTEDREQUESTSCOUNT = 3107

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_REJECTEDREQUESTSCOUNT = 3108

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SAMPLINGINTERVALDIAGNOSTICSARRAY = 3109

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SUBSCRIPTIONDIAGNOSTICSARRAY = 3110

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SESSIONSDIAGNOSTICSSUMMARY = 3111

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SESSIONSDIAGNOSTICSSUMMARY_SESSIONDIAGNOSTICSARRAY = 3112

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_SESSIONSDIAGNOSTICSSUMMARY_SESSIONSECURITYDIAGNOSTICSARRAY = 3113

const UA_NS0ID_SERVERTYPE_SERVERDIAGNOSTICS_ENABLEDFLAG = 3114

const UA_NS0ID_SERVERTYPE_SERVERREDUNDANCY_REDUNDANCYSUPPORT = 3115

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_SERVERVIEWCOUNT = 3116

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_CURRENTSESSIONCOUNT = 3117

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_CUMULATEDSESSIONCOUNT = 3118

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_SECURITYREJECTEDSESSIONCOUNT = 3119

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_REJECTEDSESSIONCOUNT = 3120

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_SESSIONTIMEOUTCOUNT = 3121

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_SESSIONABORTCOUNT = 3122

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_PUBLISHINGINTERVALCOUNT = 3124

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_CURRENTSUBSCRIPTIONCOUNT = 3125

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_CUMULATEDSUBSCRIPTIONCOUNT = 3126

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_SECURITYREJECTEDREQUESTSCOUNT = 3127

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SERVERDIAGNOSTICSSUMMARY_REJECTEDREQUESTSCOUNT = 3128

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SESSIONSDIAGNOSTICSSUMMARY_SESSIONDIAGNOSTICSARRAY = 3129

const UA_NS0ID_SERVERDIAGNOSTICSTYPE_SESSIONSDIAGNOSTICSSUMMARY_SESSIONSECURITYDIAGNOSTICSARRAY = 3130

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_SESSIONID = 3131

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_SESSIONNAME = 3132

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CLIENTDESCRIPTION = 3133

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_SERVERURI = 3134

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_ENDPOINTURL = 3135

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_LOCALEIDS = 3136

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_ACTUALSESSIONTIMEOUT = 3137

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_MAXRESPONSEMESSAGESIZE = 3138

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CLIENTCONNECTIONTIME = 3139

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CLIENTLASTCONTACTTIME = 3140

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CURRENTSUBSCRIPTIONSCOUNT = 3141

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CURRENTMONITOREDITEMSCOUNT = 3142

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CURRENTPUBLISHREQUESTSINQUEUE = 3143

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_READCOUNT = 3151

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_HISTORYREADCOUNT = 3152

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_WRITECOUNT = 3153

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_HISTORYUPDATECOUNT = 3154

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CALLCOUNT = 3155

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CREATEMONITOREDITEMSCOUNT = 3156

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_MODIFYMONITOREDITEMSCOUNT = 3157

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_SETMONITORINGMODECOUNT = 3158

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_SETTRIGGERINGCOUNT = 3159

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_DELETEMONITOREDITEMSCOUNT = 3160

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_CREATESUBSCRIPTIONCOUNT = 3161

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_MODIFYSUBSCRIPTIONCOUNT = 3162

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_SETPUBLISHINGMODECOUNT = 3163

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_PUBLISHCOUNT = 3164

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_REPUBLISHCOUNT = 3165

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_TRANSFERSUBSCRIPTIONSCOUNT = 3166

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_DELETESUBSCRIPTIONSCOUNT = 3167

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_ADDNODESCOUNT = 3168

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_ADDREFERENCESCOUNT = 3169

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_DELETENODESCOUNT = 3170

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_DELETEREFERENCESCOUNT = 3171

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_BROWSECOUNT = 3172

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_BROWSENEXTCOUNT = 3173

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_TRANSLATEBROWSEPATHSTONODEIDSCOUNT = 3174

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_QUERYFIRSTCOUNT = 3175

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_QUERYNEXTCOUNT = 3176

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_REGISTERNODESCOUNT = 3177

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_UNREGISTERNODESCOUNT = 3178

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_SESSIONID = 3179

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_CLIENTUSERIDOFSESSION = 3180

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_CLIENTUSERIDHISTORY = 3181

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_AUTHENTICATIONMECHANISM = 3182

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_ENCODING = 3183

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_TRANSPORTPROTOCOL = 3184

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_SECURITYMODE = 3185

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_SECURITYPOLICYURI = 3186

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONSECURITYDIAGNOSTICS_CLIENTCERTIFICATE = 3187

const UA_NS0ID_TRANSPARENTREDUNDANCYTYPE_REDUNDANCYSUPPORT = 3188

const UA_NS0ID_NONTRANSPARENTREDUNDANCYTYPE_REDUNDANCYSUPPORT = 3189

const UA_NS0ID_BASEEVENTTYPE_LOCALTIME = 3190

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_EVENTID = 3191

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_EVENTTYPE = 3192

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_SOURCENODE = 3193

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_SOURCENAME = 3194

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_TIME = 3195

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_RECEIVETIME = 3196

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_LOCALTIME = 3197

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_MESSAGE = 3198

const UA_NS0ID_EVENTQUEUEOVERFLOWEVENTTYPE_SEVERITY = 3199

const UA_NS0ID_AUDITEVENTTYPE_EVENTID = 3200

const UA_NS0ID_AUDITEVENTTYPE_EVENTTYPE = 3201

const UA_NS0ID_AUDITEVENTTYPE_SOURCENODE = 3202

const UA_NS0ID_AUDITEVENTTYPE_SOURCENAME = 3203

const UA_NS0ID_AUDITEVENTTYPE_TIME = 3204

const UA_NS0ID_AUDITEVENTTYPE_RECEIVETIME = 3205

const UA_NS0ID_AUDITEVENTTYPE_LOCALTIME = 3206

const UA_NS0ID_AUDITEVENTTYPE_MESSAGE = 3207

const UA_NS0ID_AUDITEVENTTYPE_SEVERITY = 3208

const UA_NS0ID_AUDITSECURITYEVENTTYPE_EVENTID = 3209

const UA_NS0ID_AUDITSECURITYEVENTTYPE_EVENTTYPE = 3210

const UA_NS0ID_AUDITSECURITYEVENTTYPE_SOURCENODE = 3211

const UA_NS0ID_AUDITSECURITYEVENTTYPE_SOURCENAME = 3212

const UA_NS0ID_AUDITSECURITYEVENTTYPE_TIME = 3213

const UA_NS0ID_AUDITSECURITYEVENTTYPE_RECEIVETIME = 3214

const UA_NS0ID_AUDITSECURITYEVENTTYPE_LOCALTIME = 3215

const UA_NS0ID_AUDITSECURITYEVENTTYPE_MESSAGE = 3216

const UA_NS0ID_AUDITSECURITYEVENTTYPE_SEVERITY = 3217

const UA_NS0ID_AUDITSECURITYEVENTTYPE_ACTIONTIMESTAMP = 3218

const UA_NS0ID_AUDITSECURITYEVENTTYPE_STATUS = 3219

const UA_NS0ID_AUDITSECURITYEVENTTYPE_SERVERID = 3220

const UA_NS0ID_AUDITSECURITYEVENTTYPE_CLIENTAUDITENTRYID = 3221

const UA_NS0ID_AUDITSECURITYEVENTTYPE_CLIENTUSERID = 3222

const UA_NS0ID_AUDITCHANNELEVENTTYPE_EVENTID = 3223

const UA_NS0ID_AUDITCHANNELEVENTTYPE_EVENTTYPE = 3224

const UA_NS0ID_AUDITCHANNELEVENTTYPE_SOURCENODE = 3225

const UA_NS0ID_AUDITCHANNELEVENTTYPE_SOURCENAME = 3226

const UA_NS0ID_AUDITCHANNELEVENTTYPE_TIME = 3227

const UA_NS0ID_AUDITCHANNELEVENTTYPE_RECEIVETIME = 3228

const UA_NS0ID_AUDITCHANNELEVENTTYPE_LOCALTIME = 3229

const UA_NS0ID_AUDITCHANNELEVENTTYPE_MESSAGE = 3230

const UA_NS0ID_AUDITCHANNELEVENTTYPE_SEVERITY = 3231

const UA_NS0ID_AUDITCHANNELEVENTTYPE_ACTIONTIMESTAMP = 3232

const UA_NS0ID_AUDITCHANNELEVENTTYPE_STATUS = 3233

const UA_NS0ID_AUDITCHANNELEVENTTYPE_SERVERID = 3234

const UA_NS0ID_AUDITCHANNELEVENTTYPE_CLIENTAUDITENTRYID = 3235

const UA_NS0ID_AUDITCHANNELEVENTTYPE_CLIENTUSERID = 3236

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_EVENTID = 3237

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_EVENTTYPE = 3238

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SOURCENODE = 3239

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SOURCENAME = 3240

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_TIME = 3241

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_RECEIVETIME = 3242

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_LOCALTIME = 3243

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_MESSAGE = 3244

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SEVERITY = 3245

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_ACTIONTIMESTAMP = 3246

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_STATUS = 3247

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SERVERID = 3248

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_CLIENTAUDITENTRYID = 3249

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_CLIENTUSERID = 3250

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_SECURECHANNELID = 3251

const UA_NS0ID_AUDITSESSIONEVENTTYPE_EVENTID = 3252

const UA_NS0ID_AUDITSESSIONEVENTTYPE_EVENTTYPE = 3253

const UA_NS0ID_AUDITSESSIONEVENTTYPE_SOURCENODE = 3254

const UA_NS0ID_AUDITSESSIONEVENTTYPE_SOURCENAME = 3255

const UA_NS0ID_AUDITSESSIONEVENTTYPE_TIME = 3256

const UA_NS0ID_AUDITSESSIONEVENTTYPE_RECEIVETIME = 3257

const UA_NS0ID_AUDITSESSIONEVENTTYPE_LOCALTIME = 3258

const UA_NS0ID_AUDITSESSIONEVENTTYPE_MESSAGE = 3259

const UA_NS0ID_AUDITSESSIONEVENTTYPE_SEVERITY = 3260

const UA_NS0ID_AUDITSESSIONEVENTTYPE_ACTIONTIMESTAMP = 3261

const UA_NS0ID_AUDITSESSIONEVENTTYPE_STATUS = 3262

const UA_NS0ID_AUDITSESSIONEVENTTYPE_SERVERID = 3263

const UA_NS0ID_AUDITSESSIONEVENTTYPE_CLIENTAUDITENTRYID = 3264

const UA_NS0ID_AUDITSESSIONEVENTTYPE_CLIENTUSERID = 3265

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_EVENTID = 3266

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_EVENTTYPE = 3267

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_SOURCENODE = 3268

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_SOURCENAME = 3269

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_TIME = 3270

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_RECEIVETIME = 3271

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_LOCALTIME = 3272

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_MESSAGE = 3273

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_SEVERITY = 3274

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_ACTIONTIMESTAMP = 3275

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_STATUS = 3276

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_SERVERID = 3277

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_CLIENTAUDITENTRYID = 3278

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_CLIENTUSERID = 3279

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_EVENTID = 3281

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_EVENTTYPE = 3282

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_SOURCENODE = 3283

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_SOURCENAME = 3284

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_TIME = 3285

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_RECEIVETIME = 3286

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_LOCALTIME = 3287

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_MESSAGE = 3288

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_SEVERITY = 3289

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_ACTIONTIMESTAMP = 3290

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_STATUS = 3291

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_SERVERID = 3292

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_CLIENTAUDITENTRYID = 3293

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_CLIENTUSERID = 3294

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_SECURECHANNELID = 3296

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_CLIENTCERTIFICATE = 3297

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_CLIENTCERTIFICATETHUMBPRINT = 3298

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_REVISEDSESSIONTIMEOUT = 3299

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_EVENTID = 3300

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_EVENTTYPE = 3301

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_SOURCENODE = 3302

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_SOURCENAME = 3303

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_TIME = 3304

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_RECEIVETIME = 3305

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_LOCALTIME = 3306

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_MESSAGE = 3307

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_SEVERITY = 3308

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_ACTIONTIMESTAMP = 3309

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_STATUS = 3310

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_SERVERID = 3311

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_CLIENTAUDITENTRYID = 3312

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_CLIENTUSERID = 3313

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_SESSIONID = 3314

const UA_NS0ID_AUDITCANCELEVENTTYPE_EVENTID = 3315

const UA_NS0ID_AUDITCANCELEVENTTYPE_EVENTTYPE = 3316

const UA_NS0ID_AUDITCANCELEVENTTYPE_SOURCENODE = 3317

const UA_NS0ID_AUDITCANCELEVENTTYPE_SOURCENAME = 3318

const UA_NS0ID_AUDITCANCELEVENTTYPE_TIME = 3319

const UA_NS0ID_AUDITCANCELEVENTTYPE_RECEIVETIME = 3320

const UA_NS0ID_AUDITCANCELEVENTTYPE_LOCALTIME = 3321

const UA_NS0ID_AUDITCANCELEVENTTYPE_MESSAGE = 3322

const UA_NS0ID_AUDITCANCELEVENTTYPE_SEVERITY = 3323

const UA_NS0ID_AUDITCANCELEVENTTYPE_ACTIONTIMESTAMP = 3324

const UA_NS0ID_AUDITCANCELEVENTTYPE_STATUS = 3325

const UA_NS0ID_AUDITCANCELEVENTTYPE_SERVERID = 3326

const UA_NS0ID_AUDITCANCELEVENTTYPE_CLIENTAUDITENTRYID = 3327

const UA_NS0ID_AUDITCANCELEVENTTYPE_CLIENTUSERID = 3328

const UA_NS0ID_AUDITCANCELEVENTTYPE_SESSIONID = 3329

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_EVENTID = 3330

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_EVENTTYPE = 3331

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_SOURCENODE = 3332

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_SOURCENAME = 3333

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_TIME = 3334

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_RECEIVETIME = 3335

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_LOCALTIME = 3336

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_MESSAGE = 3337

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_SEVERITY = 3338

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_ACTIONTIMESTAMP = 3339

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_STATUS = 3340

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_SERVERID = 3341

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_CLIENTAUDITENTRYID = 3342

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_CLIENTUSERID = 3343

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_EVENTID = 3344

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_EVENTTYPE = 3345

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_SOURCENODE = 3346

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_SOURCENAME = 3347

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_TIME = 3348

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_RECEIVETIME = 3349

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_LOCALTIME = 3350

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_MESSAGE = 3351

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_SEVERITY = 3352

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_ACTIONTIMESTAMP = 3353

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_STATUS = 3354

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_SERVERID = 3355

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_CLIENTAUDITENTRYID = 3356

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_CLIENTUSERID = 3357

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_CERTIFICATE = 3358

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_EVENTID = 3359

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_EVENTTYPE = 3360

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_SOURCENODE = 3361

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_SOURCENAME = 3362

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_TIME = 3363

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_RECEIVETIME = 3364

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_LOCALTIME = 3365

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_MESSAGE = 3366

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_SEVERITY = 3367

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_ACTIONTIMESTAMP = 3368

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_STATUS = 3369

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_SERVERID = 3370

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_CLIENTAUDITENTRYID = 3371

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_CLIENTUSERID = 3372

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_CERTIFICATE = 3373

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_EVENTID = 3374

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_EVENTTYPE = 3375

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_SOURCENODE = 3376

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_SOURCENAME = 3377

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_TIME = 3378

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_RECEIVETIME = 3379

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_LOCALTIME = 3380

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_MESSAGE = 3381

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_SEVERITY = 3382

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_ACTIONTIMESTAMP = 3383

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_STATUS = 3384

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_SERVERID = 3385

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_CLIENTAUDITENTRYID = 3386

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_CLIENTUSERID = 3387

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_CERTIFICATE = 3388

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_EVENTID = 3389

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_EVENTTYPE = 3390

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_SOURCENODE = 3391

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_SOURCENAME = 3392

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_TIME = 3393

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_RECEIVETIME = 3394

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_LOCALTIME = 3395

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_MESSAGE = 3396

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_SEVERITY = 3397

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_ACTIONTIMESTAMP = 3398

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_STATUS = 3399

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_SERVERID = 3400

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_CLIENTAUDITENTRYID = 3401

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_CLIENTUSERID = 3402

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_CERTIFICATE = 3403

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_EVENTID = 3404

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_EVENTTYPE = 3405

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_SOURCENODE = 3406

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_SOURCENAME = 3407

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_TIME = 3408

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_RECEIVETIME = 3409

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_LOCALTIME = 3410

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_MESSAGE = 3411

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_SEVERITY = 3412

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_ACTIONTIMESTAMP = 3413

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_STATUS = 3414

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_SERVERID = 3415

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_CLIENTAUDITENTRYID = 3416

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_CLIENTUSERID = 3417

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_CERTIFICATE = 3418

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_EVENTID = 3419

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_EVENTTYPE = 3420

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_SOURCENODE = 3421

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_SOURCENAME = 3422

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_TIME = 3423

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_RECEIVETIME = 3424

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_LOCALTIME = 3425

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_MESSAGE = 3426

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_SEVERITY = 3427

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_ACTIONTIMESTAMP = 3428

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_STATUS = 3429

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_SERVERID = 3430

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_CLIENTAUDITENTRYID = 3431

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_CLIENTUSERID = 3432

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_CERTIFICATE = 3433

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_EVENTID = 3434

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_EVENTTYPE = 3435

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_SOURCENODE = 3436

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_SOURCENAME = 3437

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_TIME = 3438

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_RECEIVETIME = 3439

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_LOCALTIME = 3440

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_MESSAGE = 3441

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_SEVERITY = 3442

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_ACTIONTIMESTAMP = 3443

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_STATUS = 3444

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_SERVERID = 3445

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_CLIENTAUDITENTRYID = 3446

const UA_NS0ID_AUDITNODEMANAGEMENTEVENTTYPE_CLIENTUSERID = 3447

const UA_NS0ID_AUDITADDNODESEVENTTYPE_EVENTID = 3448

const UA_NS0ID_AUDITADDNODESEVENTTYPE_EVENTTYPE = 3449

const UA_NS0ID_AUDITADDNODESEVENTTYPE_SOURCENODE = 3450

const UA_NS0ID_AUDITADDNODESEVENTTYPE_SOURCENAME = 3451

const UA_NS0ID_AUDITADDNODESEVENTTYPE_TIME = 3452

const UA_NS0ID_AUDITADDNODESEVENTTYPE_RECEIVETIME = 3453

const UA_NS0ID_AUDITADDNODESEVENTTYPE_LOCALTIME = 3454

const UA_NS0ID_AUDITADDNODESEVENTTYPE_MESSAGE = 3455

const UA_NS0ID_AUDITADDNODESEVENTTYPE_SEVERITY = 3456

const UA_NS0ID_AUDITADDNODESEVENTTYPE_ACTIONTIMESTAMP = 3457

const UA_NS0ID_AUDITADDNODESEVENTTYPE_STATUS = 3458

const UA_NS0ID_AUDITADDNODESEVENTTYPE_SERVERID = 3459

const UA_NS0ID_AUDITADDNODESEVENTTYPE_CLIENTAUDITENTRYID = 3460

const UA_NS0ID_AUDITADDNODESEVENTTYPE_CLIENTUSERID = 3461

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_EVENTID = 3462

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_EVENTTYPE = 3463

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_SOURCENODE = 3464

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_SOURCENAME = 3465

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_TIME = 3466

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_RECEIVETIME = 3467

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_LOCALTIME = 3468

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_MESSAGE = 3469

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_SEVERITY = 3470

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_ACTIONTIMESTAMP = 3471

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_STATUS = 3472

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_SERVERID = 3473

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_CLIENTAUDITENTRYID = 3474

const UA_NS0ID_AUDITDELETENODESEVENTTYPE_CLIENTUSERID = 3475

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_EVENTID = 3476

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_EVENTTYPE = 3477

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_SOURCENODE = 3478

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_SOURCENAME = 3479

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_TIME = 3480

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_RECEIVETIME = 3481

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_LOCALTIME = 3482

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_MESSAGE = 3483

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_SEVERITY = 3484

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_ACTIONTIMESTAMP = 3485

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_STATUS = 3486

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_SERVERID = 3487

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_CLIENTAUDITENTRYID = 3488

const UA_NS0ID_AUDITADDREFERENCESEVENTTYPE_CLIENTUSERID = 3489

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_EVENTID = 3490

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_EVENTTYPE = 3491

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_SOURCENODE = 3492

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_SOURCENAME = 3493

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_TIME = 3494

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_RECEIVETIME = 3495

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_LOCALTIME = 3496

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_MESSAGE = 3497

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_SEVERITY = 3498

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_ACTIONTIMESTAMP = 3499

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_STATUS = 3500

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_SERVERID = 3501

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_CLIENTAUDITENTRYID = 3502

const UA_NS0ID_AUDITDELETEREFERENCESEVENTTYPE_CLIENTUSERID = 3503

const UA_NS0ID_AUDITUPDATEEVENTTYPE_EVENTID = 3504

const UA_NS0ID_AUDITUPDATEEVENTTYPE_EVENTTYPE = 3505

const UA_NS0ID_AUDITUPDATEEVENTTYPE_SOURCENODE = 3506

const UA_NS0ID_AUDITUPDATEEVENTTYPE_SOURCENAME = 3507

const UA_NS0ID_AUDITUPDATEEVENTTYPE_TIME = 3508

const UA_NS0ID_AUDITUPDATEEVENTTYPE_RECEIVETIME = 3509

const UA_NS0ID_AUDITUPDATEEVENTTYPE_LOCALTIME = 3510

const UA_NS0ID_AUDITUPDATEEVENTTYPE_MESSAGE = 3511

const UA_NS0ID_AUDITUPDATEEVENTTYPE_SEVERITY = 3512

const UA_NS0ID_AUDITUPDATEEVENTTYPE_ACTIONTIMESTAMP = 3513

const UA_NS0ID_AUDITUPDATEEVENTTYPE_STATUS = 3514

const UA_NS0ID_AUDITUPDATEEVENTTYPE_SERVERID = 3515

const UA_NS0ID_AUDITUPDATEEVENTTYPE_CLIENTAUDITENTRYID = 3516

const UA_NS0ID_AUDITUPDATEEVENTTYPE_CLIENTUSERID = 3517

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_EVENTID = 3518

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_EVENTTYPE = 3519

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_SOURCENODE = 3520

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_SOURCENAME = 3521

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_TIME = 3522

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_RECEIVETIME = 3523

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_LOCALTIME = 3524

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_MESSAGE = 3525

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_SEVERITY = 3526

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_ACTIONTIMESTAMP = 3527

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_STATUS = 3528

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_SERVERID = 3529

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_CLIENTAUDITENTRYID = 3530

const UA_NS0ID_AUDITWRITEUPDATEEVENTTYPE_CLIENTUSERID = 3531

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_EVENTID = 3532

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_EVENTTYPE = 3533

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_SOURCENODE = 3534

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_SOURCENAME = 3535

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_TIME = 3536

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_RECEIVETIME = 3537

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_LOCALTIME = 3538

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_MESSAGE = 3539

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_SEVERITY = 3540

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_ACTIONTIMESTAMP = 3541

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_STATUS = 3542

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_SERVERID = 3543

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_CLIENTAUDITENTRYID = 3544

const UA_NS0ID_AUDITHISTORYUPDATEEVENTTYPE_CLIENTUSERID = 3545

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_EVENTID = 3546

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_EVENTTYPE = 3547

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_SOURCENODE = 3548

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_SOURCENAME = 3549

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_TIME = 3550

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_RECEIVETIME = 3551

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_LOCALTIME = 3552

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_MESSAGE = 3553

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_SEVERITY = 3554

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_ACTIONTIMESTAMP = 3555

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_STATUS = 3556

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_SERVERID = 3557

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_CLIENTAUDITENTRYID = 3558

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_CLIENTUSERID = 3559

const UA_NS0ID_AUDITHISTORYEVENTUPDATEEVENTTYPE_PARAMETERDATATYPEID = 3560

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_EVENTID = 3561

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_EVENTTYPE = 3562

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_SOURCENODE = 3563

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_SOURCENAME = 3564

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_TIME = 3565

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_RECEIVETIME = 3566

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_LOCALTIME = 3567

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_MESSAGE = 3568

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_SEVERITY = 3569

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_ACTIONTIMESTAMP = 3570

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_STATUS = 3571

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_SERVERID = 3572

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_CLIENTAUDITENTRYID = 3573

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_CLIENTUSERID = 3574

const UA_NS0ID_AUDITHISTORYVALUEUPDATEEVENTTYPE_PARAMETERDATATYPEID = 3575

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_EVENTID = 3576

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_EVENTTYPE = 3577

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_SOURCENODE = 3578

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_SOURCENAME = 3579

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_TIME = 3580

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_RECEIVETIME = 3581

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_LOCALTIME = 3582

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_MESSAGE = 3583

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_SEVERITY = 3584

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_ACTIONTIMESTAMP = 3585

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_STATUS = 3586

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_SERVERID = 3587

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_CLIENTAUDITENTRYID = 3588

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_CLIENTUSERID = 3589

const UA_NS0ID_AUDITHISTORYDELETEEVENTTYPE_PARAMETERDATATYPEID = 3590

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_EVENTID = 3591

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_EVENTTYPE = 3592

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_SOURCENODE = 3593

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_SOURCENAME = 3594

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_TIME = 3595

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_RECEIVETIME = 3596

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_LOCALTIME = 3597

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_MESSAGE = 3598

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_SEVERITY = 3599

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_ACTIONTIMESTAMP = 3600

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_STATUS = 3601

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_SERVERID = 3602

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_CLIENTAUDITENTRYID = 3603

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_CLIENTUSERID = 3604

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_PARAMETERDATATYPEID = 3605

const UA_NS0ID_AUDITHISTORYRAWMODIFYDELETEEVENTTYPE_UPDATEDNODE = 3606

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_EVENTID = 3607

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_EVENTTYPE = 3608

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_SOURCENODE = 3609

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_SOURCENAME = 3610

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_TIME = 3611

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_RECEIVETIME = 3612

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_LOCALTIME = 3613

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_MESSAGE = 3614

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_SEVERITY = 3615

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_ACTIONTIMESTAMP = 3616

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_STATUS = 3617

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_SERVERID = 3618

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_CLIENTAUDITENTRYID = 3619

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_CLIENTUSERID = 3620

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_PARAMETERDATATYPEID = 3621

const UA_NS0ID_AUDITHISTORYATTIMEDELETEEVENTTYPE_UPDATEDNODE = 3622

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_EVENTID = 3623

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_EVENTTYPE = 3624

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_SOURCENODE = 3625

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_SOURCENAME = 3626

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_TIME = 3627

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_RECEIVETIME = 3628

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_LOCALTIME = 3629

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_MESSAGE = 3630

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_SEVERITY = 3631

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_ACTIONTIMESTAMP = 3632

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_STATUS = 3633

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_SERVERID = 3634

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_CLIENTAUDITENTRYID = 3635

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_CLIENTUSERID = 3636

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_PARAMETERDATATYPEID = 3637

const UA_NS0ID_AUDITHISTORYEVENTDELETEEVENTTYPE_UPDATEDNODE = 3638

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_EVENTID = 3639

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_EVENTTYPE = 3640

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_SOURCENODE = 3641

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_SOURCENAME = 3642

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_TIME = 3643

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_RECEIVETIME = 3644

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_LOCALTIME = 3645

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_MESSAGE = 3646

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_SEVERITY = 3647

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_ACTIONTIMESTAMP = 3648

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_STATUS = 3649

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_SERVERID = 3650

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_CLIENTAUDITENTRYID = 3651

const UA_NS0ID_AUDITUPDATEMETHODEVENTTYPE_CLIENTUSERID = 3652

const UA_NS0ID_SYSTEMEVENTTYPE_EVENTID = 3653

const UA_NS0ID_SYSTEMEVENTTYPE_EVENTTYPE = 3654

const UA_NS0ID_SYSTEMEVENTTYPE_SOURCENODE = 3655

const UA_NS0ID_SYSTEMEVENTTYPE_SOURCENAME = 3656

const UA_NS0ID_SYSTEMEVENTTYPE_TIME = 3657

const UA_NS0ID_SYSTEMEVENTTYPE_RECEIVETIME = 3658

const UA_NS0ID_SYSTEMEVENTTYPE_LOCALTIME = 3659

const UA_NS0ID_SYSTEMEVENTTYPE_MESSAGE = 3660

const UA_NS0ID_SYSTEMEVENTTYPE_SEVERITY = 3661

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_EVENTID = 3662

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_EVENTTYPE = 3663

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_SOURCENODE = 3664

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_SOURCENAME = 3665

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_TIME = 3666

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_RECEIVETIME = 3667

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_LOCALTIME = 3668

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_MESSAGE = 3669

const UA_NS0ID_DEVICEFAILUREEVENTTYPE_SEVERITY = 3670

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_EVENTID = 3671

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_EVENTTYPE = 3672

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_SOURCENODE = 3673

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_SOURCENAME = 3674

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_TIME = 3675

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_RECEIVETIME = 3676

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_LOCALTIME = 3677

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_MESSAGE = 3678

const UA_NS0ID_BASEMODELCHANGEEVENTTYPE_SEVERITY = 3679

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_EVENTID = 3680

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_EVENTTYPE = 3681

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_SOURCENODE = 3682

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_SOURCENAME = 3683

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_TIME = 3684

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_RECEIVETIME = 3685

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_LOCALTIME = 3686

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_MESSAGE = 3687

const UA_NS0ID_GENERALMODELCHANGEEVENTTYPE_SEVERITY = 3688

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_EVENTID = 3689

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_EVENTTYPE = 3690

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_SOURCENODE = 3691

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_SOURCENAME = 3692

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_TIME = 3693

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_RECEIVETIME = 3694

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_LOCALTIME = 3695

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_MESSAGE = 3696

const UA_NS0ID_SEMANTICCHANGEEVENTTYPE_SEVERITY = 3697

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO_PRODUCTURI = 3698

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO_MANUFACTURERNAME = 3699

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO_PRODUCTNAME = 3700

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO_SOFTWAREVERSION = 3701

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO_BUILDNUMBER = 3702

const UA_NS0ID_SERVERSTATUSTYPE_BUILDINFO_BUILDDATE = 3703

const UA_NS0ID_SERVER_SERVERCAPABILITIES_SOFTWARECERTIFICATES = 3704

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SERVERDIAGNOSTICSSUMMARY_REJECTEDSESSIONCOUNT = 3705

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SESSIONSDIAGNOSTICSSUMMARY = 3706

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SESSIONSDIAGNOSTICSSUMMARY_SESSIONDIAGNOSTICSARRAY = 3707

const UA_NS0ID_SERVER_SERVERDIAGNOSTICS_SESSIONSDIAGNOSTICSSUMMARY_SESSIONSECURITYDIAGNOSTICSARRAY = 3708

const UA_NS0ID_SERVER_SERVERREDUNDANCY_REDUNDANCYSUPPORT = 3709

const UA_NS0ID_FINITESTATEVARIABLETYPE_NAME = 3714

const UA_NS0ID_FINITESTATEVARIABLETYPE_NUMBER = 3715

const UA_NS0ID_FINITESTATEVARIABLETYPE_EFFECTIVEDISPLAYNAME = 3716

const UA_NS0ID_FINITETRANSITIONVARIABLETYPE_NAME = 3717

const UA_NS0ID_FINITETRANSITIONVARIABLETYPE_NUMBER = 3718

const UA_NS0ID_FINITETRANSITIONVARIABLETYPE_TRANSITIONTIME = 3719

const UA_NS0ID_STATEMACHINETYPE_CURRENTSTATE_ID = 3720

const UA_NS0ID_STATEMACHINETYPE_CURRENTSTATE_NAME = 3721

const UA_NS0ID_STATEMACHINETYPE_CURRENTSTATE_NUMBER = 3722

const UA_NS0ID_STATEMACHINETYPE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 3723

const UA_NS0ID_STATEMACHINETYPE_LASTTRANSITION_ID = 3724

const UA_NS0ID_STATEMACHINETYPE_LASTTRANSITION_NAME = 3725

const UA_NS0ID_STATEMACHINETYPE_LASTTRANSITION_NUMBER = 3726

const UA_NS0ID_STATEMACHINETYPE_LASTTRANSITION_TRANSITIONTIME = 3727

const UA_NS0ID_FINITESTATEMACHINETYPE_CURRENTSTATE_ID = 3728

const UA_NS0ID_FINITESTATEMACHINETYPE_CURRENTSTATE_NAME = 3729

const UA_NS0ID_FINITESTATEMACHINETYPE_CURRENTSTATE_NUMBER = 3730

const UA_NS0ID_FINITESTATEMACHINETYPE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 3731

const UA_NS0ID_FINITESTATEMACHINETYPE_LASTTRANSITION_ID = 3732

const UA_NS0ID_FINITESTATEMACHINETYPE_LASTTRANSITION_NAME = 3733

const UA_NS0ID_FINITESTATEMACHINETYPE_LASTTRANSITION_NUMBER = 3734

const UA_NS0ID_FINITESTATEMACHINETYPE_LASTTRANSITION_TRANSITIONTIME = 3735

const UA_NS0ID_INITIALSTATETYPE_STATENUMBER = 3736

const UA_NS0ID_TRANSITIONEVENTTYPE_EVENTID = 3737

const UA_NS0ID_TRANSITIONEVENTTYPE_EVENTTYPE = 3738

const UA_NS0ID_TRANSITIONEVENTTYPE_SOURCENODE = 3739

const UA_NS0ID_TRANSITIONEVENTTYPE_SOURCENAME = 3740

const UA_NS0ID_TRANSITIONEVENTTYPE_TIME = 3741

const UA_NS0ID_TRANSITIONEVENTTYPE_RECEIVETIME = 3742

const UA_NS0ID_TRANSITIONEVENTTYPE_LOCALTIME = 3743

const UA_NS0ID_TRANSITIONEVENTTYPE_MESSAGE = 3744

const UA_NS0ID_TRANSITIONEVENTTYPE_SEVERITY = 3745

const UA_NS0ID_TRANSITIONEVENTTYPE_FROMSTATE_ID = 3746

const UA_NS0ID_TRANSITIONEVENTTYPE_FROMSTATE_NAME = 3747

const UA_NS0ID_TRANSITIONEVENTTYPE_FROMSTATE_NUMBER = 3748

const UA_NS0ID_TRANSITIONEVENTTYPE_FROMSTATE_EFFECTIVEDISPLAYNAME = 3749

const UA_NS0ID_TRANSITIONEVENTTYPE_TOSTATE_ID = 3750

const UA_NS0ID_TRANSITIONEVENTTYPE_TOSTATE_NAME = 3751

const UA_NS0ID_TRANSITIONEVENTTYPE_TOSTATE_NUMBER = 3752

const UA_NS0ID_TRANSITIONEVENTTYPE_TOSTATE_EFFECTIVEDISPLAYNAME = 3753

const UA_NS0ID_TRANSITIONEVENTTYPE_TRANSITION_ID = 3754

const UA_NS0ID_TRANSITIONEVENTTYPE_TRANSITION_NAME = 3755

const UA_NS0ID_TRANSITIONEVENTTYPE_TRANSITION_NUMBER = 3756

const UA_NS0ID_TRANSITIONEVENTTYPE_TRANSITION_TRANSITIONTIME = 3757

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_EVENTID = 3758

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_EVENTTYPE = 3759

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_SOURCENODE = 3760

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_SOURCENAME = 3761

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_TIME = 3762

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_RECEIVETIME = 3763

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_LOCALTIME = 3764

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_MESSAGE = 3765

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_SEVERITY = 3766

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_ACTIONTIMESTAMP = 3767

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_STATUS = 3768

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_SERVERID = 3769

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_CLIENTAUDITENTRYID = 3770

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_CLIENTUSERID = 3771

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_METHODID = 3772

const UA_NS0ID_AUDITUPDATESTATEEVENTTYPE_INPUTARGUMENTS = 3773

const UA_NS0ID_ANALOGITEMTYPE_DEFINITION = 3774

const UA_NS0ID_ANALOGITEMTYPE_VALUEPRECISION = 3775

const UA_NS0ID_DISCRETEITEMTYPE_DEFINITION = 3776

const UA_NS0ID_DISCRETEITEMTYPE_VALUEPRECISION = 3777

const UA_NS0ID_TWOSTATEDISCRETETYPE_DEFINITION = 3778

const UA_NS0ID_TWOSTATEDISCRETETYPE_VALUEPRECISION = 3779

const UA_NS0ID_MULTISTATEDISCRETETYPE_DEFINITION = 3780

const UA_NS0ID_MULTISTATEDISCRETETYPE_VALUEPRECISION = 3781

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_EVENTID = 3782

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_EVENTTYPE = 3783

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_SOURCENODE = 3784

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_SOURCENAME = 3785

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TIME = 3786

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_RECEIVETIME = 3787

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_LOCALTIME = 3788

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_MESSAGE = 3789

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_SEVERITY = 3790

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_FROMSTATE = 3791

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_FROMSTATE_ID = 3792

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_FROMSTATE_NAME = 3793

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_FROMSTATE_NUMBER = 3794

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_FROMSTATE_EFFECTIVEDISPLAYNAME = 3795

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TOSTATE = 3796

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TOSTATE_ID = 3797

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TOSTATE_NAME = 3798

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TOSTATE_NUMBER = 3799

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TOSTATE_EFFECTIVEDISPLAYNAME = 3800

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TRANSITION = 3801

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TRANSITION_ID = 3802

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TRANSITION_NAME = 3803

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TRANSITION_NUMBER = 3804

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TRANSITION_TRANSITIONTIME = 3805

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE = 3806

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_EVENTID = 3807

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_EVENTTYPE = 3808

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_SOURCENODE = 3809

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_SOURCENAME = 3810

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TIME = 3811

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_RECEIVETIME = 3812

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_LOCALTIME = 3813

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_MESSAGE = 3814

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_SEVERITY = 3815

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_ACTIONTIMESTAMP = 3816

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_STATUS = 3817

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_SERVERID = 3818

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_CLIENTAUDITENTRYID = 3819

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_CLIENTUSERID = 3820

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_METHODID = 3821

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_INPUTARGUMENTS = 3822

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_OLDSTATEID = 3823

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_NEWSTATEID = 3824

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TRANSITION = 3825

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TRANSITION_ID = 3826

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TRANSITION_NAME = 3827

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TRANSITION_NUMBER = 3828

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TRANSITION_TRANSITIONTIME = 3829

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_CURRENTSTATE = 3830

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_CURRENTSTATE_ID = 3831

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_CURRENTSTATE_NAME = 3832

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_CURRENTSTATE_NUMBER = 3833

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 3834

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_LASTTRANSITION = 3835

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_LASTTRANSITION_ID = 3836

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_LASTTRANSITION_NAME = 3837

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_LASTTRANSITION_NUMBER = 3838

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_LASTTRANSITION_TRANSITIONTIME = 3839

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_CREATESESSIONID = 3840

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_CREATECLIENTNAME = 3841

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_INVOCATIONCREATIONTIME = 3842

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTTRANSITIONTIME = 3843

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODCALL = 3844

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODSESSIONID = 3845

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODINPUTARGUMENTS = 3846

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODOUTPUTARGUMENTS = 3847

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODCALLTIME = 3848

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODRETURNSTATUS = 3849

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_FINALRESULTDATA = 3850

const UA_NS0ID_ADDCOMMENTMETHODTYPE = 3863

const UA_NS0ID_ADDCOMMENTMETHODTYPE_INPUTARGUMENTS = 3864

const UA_NS0ID_CONDITIONTYPE_EVENTID = 3865

const UA_NS0ID_CONDITIONTYPE_EVENTTYPE = 3866

const UA_NS0ID_CONDITIONTYPE_SOURCENODE = 3867

const UA_NS0ID_CONDITIONTYPE_SOURCENAME = 3868

const UA_NS0ID_CONDITIONTYPE_TIME = 3869

const UA_NS0ID_CONDITIONTYPE_RECEIVETIME = 3870

const UA_NS0ID_CONDITIONTYPE_LOCALTIME = 3871

const UA_NS0ID_CONDITIONTYPE_MESSAGE = 3872

const UA_NS0ID_CONDITIONTYPE_SEVERITY = 3873

const UA_NS0ID_CONDITIONTYPE_RETAIN = 3874

const UA_NS0ID_CONDITIONTYPE_CONDITIONREFRESH = 3875

const UA_NS0ID_CONDITIONTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 3876

const UA_NS0ID_REFRESHSTARTEVENTTYPE_EVENTID = 3969

const UA_NS0ID_REFRESHSTARTEVENTTYPE_EVENTTYPE = 3970

const UA_NS0ID_REFRESHSTARTEVENTTYPE_SOURCENODE = 3971

const UA_NS0ID_REFRESHSTARTEVENTTYPE_SOURCENAME = 3972

const UA_NS0ID_REFRESHSTARTEVENTTYPE_TIME = 3973

const UA_NS0ID_REFRESHSTARTEVENTTYPE_RECEIVETIME = 3974

const UA_NS0ID_REFRESHSTARTEVENTTYPE_LOCALTIME = 3975

const UA_NS0ID_REFRESHSTARTEVENTTYPE_MESSAGE = 3976

const UA_NS0ID_REFRESHSTARTEVENTTYPE_SEVERITY = 3977

const UA_NS0ID_REFRESHENDEVENTTYPE_EVENTID = 3978

const UA_NS0ID_REFRESHENDEVENTTYPE_EVENTTYPE = 3979

const UA_NS0ID_REFRESHENDEVENTTYPE_SOURCENODE = 3980

const UA_NS0ID_REFRESHENDEVENTTYPE_SOURCENAME = 3981

const UA_NS0ID_REFRESHENDEVENTTYPE_TIME = 3982

const UA_NS0ID_REFRESHENDEVENTTYPE_RECEIVETIME = 3983

const UA_NS0ID_REFRESHENDEVENTTYPE_LOCALTIME = 3984

const UA_NS0ID_REFRESHENDEVENTTYPE_MESSAGE = 3985

const UA_NS0ID_REFRESHENDEVENTTYPE_SEVERITY = 3986

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_EVENTID = 3987

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_EVENTTYPE = 3988

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_SOURCENODE = 3989

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_SOURCENAME = 3990

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_TIME = 3991

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_RECEIVETIME = 3992

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_LOCALTIME = 3993

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_MESSAGE = 3994

const UA_NS0ID_REFRESHREQUIREDEVENTTYPE_SEVERITY = 3995

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_EVENTID = 3996

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_EVENTTYPE = 3997

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_SOURCENODE = 3998

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_SOURCENAME = 3999

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_TIME = 4000

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_RECEIVETIME = 4001

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_LOCALTIME = 4002

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_MESSAGE = 4003

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_SEVERITY = 4004

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_ACTIONTIMESTAMP = 4005

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_STATUS = 4006

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_SERVERID = 4007

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_CLIENTAUDITENTRYID = 4008

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_CLIENTUSERID = 4009

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_METHODID = 4010

const UA_NS0ID_AUDITCONDITIONEVENTTYPE_INPUTARGUMENTS = 4011

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_EVENTID = 4106

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_EVENTTYPE = 4107

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_SOURCENODE = 4108

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_SOURCENAME = 4109

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_TIME = 4110

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_RECEIVETIME = 4111

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_LOCALTIME = 4112

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_MESSAGE = 4113

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_SEVERITY = 4114

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_ACTIONTIMESTAMP = 4115

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_STATUS = 4116

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_SERVERID = 4117

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_CLIENTAUDITENTRYID = 4118

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_CLIENTUSERID = 4119

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_METHODID = 4120

const UA_NS0ID_AUDITCONDITIONENABLEEVENTTYPE_INPUTARGUMENTS = 4121

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_EVENTID = 4170

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_EVENTTYPE = 4171

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_SOURCENODE = 4172

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_SOURCENAME = 4173

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_TIME = 4174

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_RECEIVETIME = 4175

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_LOCALTIME = 4176

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_MESSAGE = 4177

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_SEVERITY = 4178

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_ACTIONTIMESTAMP = 4179

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_STATUS = 4180

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_SERVERID = 4181

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_CLIENTAUDITENTRYID = 4182

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_CLIENTUSERID = 4183

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_METHODID = 4184

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_INPUTARGUMENTS = 4185

const UA_NS0ID_DIALOGCONDITIONTYPE_EVENTID = 4188

const UA_NS0ID_DIALOGCONDITIONTYPE_EVENTTYPE = 4189

const UA_NS0ID_DIALOGCONDITIONTYPE_SOURCENODE = 4190

const UA_NS0ID_DIALOGCONDITIONTYPE_SOURCENAME = 4191

const UA_NS0ID_DIALOGCONDITIONTYPE_TIME = 4192

const UA_NS0ID_DIALOGCONDITIONTYPE_RECEIVETIME = 4193

const UA_NS0ID_DIALOGCONDITIONTYPE_LOCALTIME = 4194

const UA_NS0ID_DIALOGCONDITIONTYPE_MESSAGE = 4195

const UA_NS0ID_DIALOGCONDITIONTYPE_SEVERITY = 4196

const UA_NS0ID_DIALOGCONDITIONTYPE_RETAIN = 4197

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONREFRESH = 4198

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 4199

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_EVENTID = 5113

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_EVENTTYPE = 5114

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_SOURCENODE = 5115

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_SOURCENAME = 5116

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_TIME = 5117

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_RECEIVETIME = 5118

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_LOCALTIME = 5119

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_MESSAGE = 5120

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_SEVERITY = 5121

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_RETAIN = 5122

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONREFRESH = 5123

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 5124

const UA_NS0ID_ALARMCONDITIONTYPE_EVENTID = 5540

const UA_NS0ID_ALARMCONDITIONTYPE_EVENTTYPE = 5541

const UA_NS0ID_ALARMCONDITIONTYPE_SOURCENODE = 5542

const UA_NS0ID_ALARMCONDITIONTYPE_SOURCENAME = 5543

const UA_NS0ID_ALARMCONDITIONTYPE_TIME = 5544

const UA_NS0ID_ALARMCONDITIONTYPE_RECEIVETIME = 5545

const UA_NS0ID_ALARMCONDITIONTYPE_LOCALTIME = 5546

const UA_NS0ID_ALARMCONDITIONTYPE_MESSAGE = 5547

const UA_NS0ID_ALARMCONDITIONTYPE_SEVERITY = 5548

const UA_NS0ID_ALARMCONDITIONTYPE_RETAIN = 5549

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONREFRESH = 5550

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 5551

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_CURRENTSTATE = 6088

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_CURRENTSTATE_ID = 6089

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_CURRENTSTATE_NAME = 6090

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_CURRENTSTATE_NUMBER = 6091

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 6092

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_LASTTRANSITION = 6093

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_LASTTRANSITION_ID = 6094

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_LASTTRANSITION_NAME = 6095

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_LASTTRANSITION_NUMBER = 6096

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_LASTTRANSITION_TRANSITIONTIME = 6097

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVED_STATENUMBER = 6098

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVED_STATENUMBER = 6100

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVED_STATENUMBER = 6101

const UA_NS0ID_TIMEDSHELVEMETHODTYPE = 6102

const UA_NS0ID_TIMEDSHELVEMETHODTYPE_INPUTARGUMENTS = 6103

const UA_NS0ID_LIMITALARMTYPE_EVENTID = 6116

const UA_NS0ID_LIMITALARMTYPE_EVENTTYPE = 6117

const UA_NS0ID_LIMITALARMTYPE_SOURCENODE = 6118

const UA_NS0ID_LIMITALARMTYPE_SOURCENAME = 6119

const UA_NS0ID_LIMITALARMTYPE_TIME = 6120

const UA_NS0ID_LIMITALARMTYPE_RECEIVETIME = 6121

const UA_NS0ID_LIMITALARMTYPE_LOCALTIME = 6122

const UA_NS0ID_LIMITALARMTYPE_MESSAGE = 6123

const UA_NS0ID_LIMITALARMTYPE_SEVERITY = 6124

const UA_NS0ID_LIMITALARMTYPE_RETAIN = 6125

const UA_NS0ID_LIMITALARMTYPE_CONDITIONREFRESH = 6126

const UA_NS0ID_LIMITALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 6127

const UA_NS0ID_IDTYPE_ENUMSTRINGS = 7591

const UA_NS0ID_ENUMVALUETYPE = 7594

const UA_NS0ID_MESSAGESECURITYMODE_ENUMSTRINGS = 7595

const UA_NS0ID_USERTOKENTYPE_ENUMSTRINGS = 7596

const UA_NS0ID_APPLICATIONTYPE_ENUMSTRINGS = 7597

const UA_NS0ID_SECURITYTOKENREQUESTTYPE_ENUMSTRINGS = 7598

const UA_NS0ID_BROWSEDIRECTION_ENUMSTRINGS = 7603

const UA_NS0ID_FILTEROPERATOR_ENUMSTRINGS = 7605

const UA_NS0ID_TIMESTAMPSTORETURN_ENUMSTRINGS = 7606

const UA_NS0ID_MONITORINGMODE_ENUMSTRINGS = 7608

const UA_NS0ID_DATACHANGETRIGGER_ENUMSTRINGS = 7609

const UA_NS0ID_DEADBANDTYPE_ENUMSTRINGS = 7610

const UA_NS0ID_REDUNDANCYSUPPORT_ENUMSTRINGS = 7611

const UA_NS0ID_SERVERSTATE_ENUMSTRINGS = 7612

const UA_NS0ID_EXCEPTIONDEVIATIONFORMAT_ENUMSTRINGS = 7614

const UA_NS0ID_ENUMVALUETYPE_ENCODING_DEFAULTXML = 7616

const UA_NS0ID_OPCUA_BINARYSCHEMA = 7617

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEVERSION = 7618

const UA_NS0ID_OPCUA_BINARYSCHEMA_NAMESPACEURI = 7619

const UA_NS0ID_OPCUA_BINARYSCHEMA_ARGUMENT = 7650

const UA_NS0ID_OPCUA_BINARYSCHEMA_ARGUMENT_DATATYPEVERSION = 7651

const UA_NS0ID_OPCUA_BINARYSCHEMA_ARGUMENT_DICTIONARYFRAGMENT = 7652

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMVALUETYPE = 7656

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMVALUETYPE_DATATYPEVERSION = 7657

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMVALUETYPE_DICTIONARYFRAGMENT = 7658

const UA_NS0ID_OPCUA_BINARYSCHEMA_STATUSRESULT = 7659

const UA_NS0ID_OPCUA_BINARYSCHEMA_STATUSRESULT_DATATYPEVERSION = 7660

const UA_NS0ID_OPCUA_BINARYSCHEMA_STATUSRESULT_DICTIONARYFRAGMENT = 7661

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERTOKENPOLICY = 7662

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERTOKENPOLICY_DATATYPEVERSION = 7663

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERTOKENPOLICY_DICTIONARYFRAGMENT = 7664

const UA_NS0ID_OPCUA_BINARYSCHEMA_APPLICATIONDESCRIPTION = 7665

const UA_NS0ID_OPCUA_BINARYSCHEMA_APPLICATIONDESCRIPTION_DATATYPEVERSION = 7666

const UA_NS0ID_OPCUA_BINARYSCHEMA_APPLICATIONDESCRIPTION_DICTIONARYFRAGMENT = 7667

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTDESCRIPTION = 7668

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTDESCRIPTION_DATATYPEVERSION = 7669

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTDESCRIPTION_DICTIONARYFRAGMENT = 7670

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERIDENTITYTOKEN = 7671

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERIDENTITYTOKEN_DATATYPEVERSION = 7672

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERIDENTITYTOKEN_DICTIONARYFRAGMENT = 7673

const UA_NS0ID_OPCUA_BINARYSCHEMA_ANONYMOUSIDENTITYTOKEN = 7674

const UA_NS0ID_OPCUA_BINARYSCHEMA_ANONYMOUSIDENTITYTOKEN_DATATYPEVERSION = 7675

const UA_NS0ID_OPCUA_BINARYSCHEMA_ANONYMOUSIDENTITYTOKEN_DICTIONARYFRAGMENT = 7676

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERNAMEIDENTITYTOKEN = 7677

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERNAMEIDENTITYTOKEN_DATATYPEVERSION = 7678

const UA_NS0ID_OPCUA_BINARYSCHEMA_USERNAMEIDENTITYTOKEN_DICTIONARYFRAGMENT = 7679

const UA_NS0ID_OPCUA_BINARYSCHEMA_X509IDENTITYTOKEN = 7680

const UA_NS0ID_OPCUA_BINARYSCHEMA_X509IDENTITYTOKEN_DATATYPEVERSION = 7681

const UA_NS0ID_OPCUA_BINARYSCHEMA_X509IDENTITYTOKEN_DICTIONARYFRAGMENT = 7682

const UA_NS0ID_OPCUA_BINARYSCHEMA_ISSUEDIDENTITYTOKEN = 7683

const UA_NS0ID_OPCUA_BINARYSCHEMA_ISSUEDIDENTITYTOKEN_DATATYPEVERSION = 7684

const UA_NS0ID_OPCUA_BINARYSCHEMA_ISSUEDIDENTITYTOKEN_DICTIONARYFRAGMENT = 7685

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTCONFIGURATION = 7686

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTCONFIGURATION_DATATYPEVERSION = 7687

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTCONFIGURATION_DICTIONARYFRAGMENT = 7688

const UA_NS0ID_OPCUA_BINARYSCHEMA_BUILDINFO = 7692

const UA_NS0ID_OPCUA_BINARYSCHEMA_BUILDINFO_DATATYPEVERSION = 7693

const UA_NS0ID_OPCUA_BINARYSCHEMA_BUILDINFO_DICTIONARYFRAGMENT = 7694

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIGNEDSOFTWARECERTIFICATE = 7698

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIGNEDSOFTWARECERTIFICATE_DATATYPEVERSION = 7699

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIGNEDSOFTWARECERTIFICATE_DICTIONARYFRAGMENT = 7700

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDNODESITEM = 7728

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDNODESITEM_DATATYPEVERSION = 7729

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDNODESITEM_DICTIONARYFRAGMENT = 7730

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDREFERENCESITEM = 7731

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDREFERENCESITEM_DATATYPEVERSION = 7732

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDREFERENCESITEM_DICTIONARYFRAGMENT = 7733

const UA_NS0ID_OPCUA_BINARYSCHEMA_DELETENODESITEM = 7734

const UA_NS0ID_OPCUA_BINARYSCHEMA_DELETENODESITEM_DATATYPEVERSION = 7735

const UA_NS0ID_OPCUA_BINARYSCHEMA_DELETENODESITEM_DICTIONARYFRAGMENT = 7736

const UA_NS0ID_OPCUA_BINARYSCHEMA_DELETEREFERENCESITEM = 7737

const UA_NS0ID_OPCUA_BINARYSCHEMA_DELETEREFERENCESITEM_DATATYPEVERSION = 7738

const UA_NS0ID_OPCUA_BINARYSCHEMA_DELETEREFERENCESITEM_DICTIONARYFRAGMENT = 7739

const UA_NS0ID_OPCUA_BINARYSCHEMA_REGISTEREDSERVER = 7782

const UA_NS0ID_OPCUA_BINARYSCHEMA_REGISTEREDSERVER_DATATYPEVERSION = 7783

const UA_NS0ID_OPCUA_BINARYSCHEMA_REGISTEREDSERVER_DICTIONARYFRAGMENT = 7784

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONTENTFILTERELEMENT = 7929

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONTENTFILTERELEMENT_DATATYPEVERSION = 7930

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONTENTFILTERELEMENT_DICTIONARYFRAGMENT = 7931

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONTENTFILTER = 7932

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONTENTFILTER_DATATYPEVERSION = 7933

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONTENTFILTER_DICTIONARYFRAGMENT = 7934

const UA_NS0ID_OPCUA_BINARYSCHEMA_FILTEROPERAND = 7935

const UA_NS0ID_OPCUA_BINARYSCHEMA_FILTEROPERAND_DATATYPEVERSION = 7936

const UA_NS0ID_OPCUA_BINARYSCHEMA_FILTEROPERAND_DICTIONARYFRAGMENT = 7937

const UA_NS0ID_OPCUA_BINARYSCHEMA_ELEMENTOPERAND = 7938

const UA_NS0ID_OPCUA_BINARYSCHEMA_ELEMENTOPERAND_DATATYPEVERSION = 7939

const UA_NS0ID_OPCUA_BINARYSCHEMA_ELEMENTOPERAND_DICTIONARYFRAGMENT = 7940

const UA_NS0ID_OPCUA_BINARYSCHEMA_LITERALOPERAND = 7941

const UA_NS0ID_OPCUA_BINARYSCHEMA_LITERALOPERAND_DATATYPEVERSION = 7942

const UA_NS0ID_OPCUA_BINARYSCHEMA_LITERALOPERAND_DICTIONARYFRAGMENT = 7943

const UA_NS0ID_OPCUA_BINARYSCHEMA_ATTRIBUTEOPERAND = 7944

const UA_NS0ID_OPCUA_BINARYSCHEMA_ATTRIBUTEOPERAND_DATATYPEVERSION = 7945

const UA_NS0ID_OPCUA_BINARYSCHEMA_ATTRIBUTEOPERAND_DICTIONARYFRAGMENT = 7946

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIMPLEATTRIBUTEOPERAND = 7947

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIMPLEATTRIBUTEOPERAND_DATATYPEVERSION = 7948

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIMPLEATTRIBUTEOPERAND_DICTIONARYFRAGMENT = 7949

const UA_NS0ID_OPCUA_BINARYSCHEMA_HISTORYEVENT = 8004

const UA_NS0ID_OPCUA_BINARYSCHEMA_HISTORYEVENT_DATATYPEVERSION = 8005

const UA_NS0ID_OPCUA_BINARYSCHEMA_HISTORYEVENT_DICTIONARYFRAGMENT = 8006

const UA_NS0ID_OPCUA_BINARYSCHEMA_MONITORINGFILTER = 8067

const UA_NS0ID_OPCUA_BINARYSCHEMA_MONITORINGFILTER_DATATYPEVERSION = 8068

const UA_NS0ID_OPCUA_BINARYSCHEMA_MONITORINGFILTER_DICTIONARYFRAGMENT = 8069

const UA_NS0ID_OPCUA_BINARYSCHEMA_EVENTFILTER = 8073

const UA_NS0ID_OPCUA_BINARYSCHEMA_EVENTFILTER_DATATYPEVERSION = 8074

const UA_NS0ID_OPCUA_BINARYSCHEMA_EVENTFILTER_DICTIONARYFRAGMENT = 8075

const UA_NS0ID_OPCUA_BINARYSCHEMA_AGGREGATECONFIGURATION = 8076

const UA_NS0ID_OPCUA_BINARYSCHEMA_AGGREGATECONFIGURATION_DATATYPEVERSION = 8077

const UA_NS0ID_OPCUA_BINARYSCHEMA_AGGREGATECONFIGURATION_DICTIONARYFRAGMENT = 8078

const UA_NS0ID_OPCUA_BINARYSCHEMA_HISTORYEVENTFIELDLIST = 8172

const UA_NS0ID_OPCUA_BINARYSCHEMA_HISTORYEVENTFIELDLIST_DATATYPEVERSION = 8173

const UA_NS0ID_OPCUA_BINARYSCHEMA_HISTORYEVENTFIELDLIST_DICTIONARYFRAGMENT = 8174

const UA_NS0ID_OPCUA_BINARYSCHEMA_REDUNDANTSERVERDATATYPE = 8208

const UA_NS0ID_OPCUA_BINARYSCHEMA_REDUNDANTSERVERDATATYPE_DATATYPEVERSION = 8209

const UA_NS0ID_OPCUA_BINARYSCHEMA_REDUNDANTSERVERDATATYPE_DICTIONARYFRAGMENT = 8210

const UA_NS0ID_OPCUA_BINARYSCHEMA_SAMPLINGINTERVALDIAGNOSTICSDATATYPE = 8211

const UA_NS0ID_OPCUA_BINARYSCHEMA_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8212

const UA_NS0ID_OPCUA_BINARYSCHEMA_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8213

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERDIAGNOSTICSSUMMARYDATATYPE = 8214

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERDIAGNOSTICSSUMMARYDATATYPE_DATATYPEVERSION = 8215

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERDIAGNOSTICSSUMMARYDATATYPE_DICTIONARYFRAGMENT = 8216

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERSTATUSDATATYPE = 8217

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERSTATUSDATATYPE_DATATYPEVERSION = 8218

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERSTATUSDATATYPE_DICTIONARYFRAGMENT = 8219

const UA_NS0ID_OPCUA_BINARYSCHEMA_SESSIONDIAGNOSTICSDATATYPE = 8220

const UA_NS0ID_OPCUA_BINARYSCHEMA_SESSIONDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8221

const UA_NS0ID_OPCUA_BINARYSCHEMA_SESSIONDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8222

const UA_NS0ID_OPCUA_BINARYSCHEMA_SESSIONSECURITYDIAGNOSTICSDATATYPE = 8223

const UA_NS0ID_OPCUA_BINARYSCHEMA_SESSIONSECURITYDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8224

const UA_NS0ID_OPCUA_BINARYSCHEMA_SESSIONSECURITYDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8225

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVICECOUNTERDATATYPE = 8226

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVICECOUNTERDATATYPE_DATATYPEVERSION = 8227

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVICECOUNTERDATATYPE_DICTIONARYFRAGMENT = 8228

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIPTIONDIAGNOSTICSDATATYPE = 8229

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIPTIONDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8230

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIPTIONDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8231

const UA_NS0ID_OPCUA_BINARYSCHEMA_MODELCHANGESTRUCTUREDATATYPE = 8232

const UA_NS0ID_OPCUA_BINARYSCHEMA_MODELCHANGESTRUCTUREDATATYPE_DATATYPEVERSION = 8233

const UA_NS0ID_OPCUA_BINARYSCHEMA_MODELCHANGESTRUCTUREDATATYPE_DICTIONARYFRAGMENT = 8234

const UA_NS0ID_OPCUA_BINARYSCHEMA_SEMANTICCHANGESTRUCTUREDATATYPE = 8235

const UA_NS0ID_OPCUA_BINARYSCHEMA_SEMANTICCHANGESTRUCTUREDATATYPE_DATATYPEVERSION = 8236

const UA_NS0ID_OPCUA_BINARYSCHEMA_SEMANTICCHANGESTRUCTUREDATATYPE_DICTIONARYFRAGMENT = 8237

const UA_NS0ID_OPCUA_BINARYSCHEMA_RANGE = 8238

const UA_NS0ID_OPCUA_BINARYSCHEMA_RANGE_DATATYPEVERSION = 8239

const UA_NS0ID_OPCUA_BINARYSCHEMA_RANGE_DICTIONARYFRAGMENT = 8240

const UA_NS0ID_OPCUA_BINARYSCHEMA_EUINFORMATION = 8241

const UA_NS0ID_OPCUA_BINARYSCHEMA_EUINFORMATION_DATATYPEVERSION = 8242

const UA_NS0ID_OPCUA_BINARYSCHEMA_EUINFORMATION_DICTIONARYFRAGMENT = 8243

const UA_NS0ID_OPCUA_BINARYSCHEMA_ANNOTATION = 8244

const UA_NS0ID_OPCUA_BINARYSCHEMA_ANNOTATION_DATATYPEVERSION = 8245

const UA_NS0ID_OPCUA_BINARYSCHEMA_ANNOTATION_DICTIONARYFRAGMENT = 8246

const UA_NS0ID_OPCUA_BINARYSCHEMA_PROGRAMDIAGNOSTICDATATYPE = 8247

const UA_NS0ID_OPCUA_BINARYSCHEMA_PROGRAMDIAGNOSTICDATATYPE_DATATYPEVERSION = 8248

const UA_NS0ID_OPCUA_BINARYSCHEMA_PROGRAMDIAGNOSTICDATATYPE_DICTIONARYFRAGMENT = 8249

const UA_NS0ID_ENUMVALUETYPE_ENCODING_DEFAULTBINARY = 8251

const UA_NS0ID_OPCUA_XMLSCHEMA = 8252

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEVERSION = 8253

const UA_NS0ID_OPCUA_XMLSCHEMA_NAMESPACEURI = 8254

const UA_NS0ID_OPCUA_XMLSCHEMA_ARGUMENT = 8285

const UA_NS0ID_OPCUA_XMLSCHEMA_ARGUMENT_DATATYPEVERSION = 8286

const UA_NS0ID_OPCUA_XMLSCHEMA_ARGUMENT_DICTIONARYFRAGMENT = 8287

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMVALUETYPE = 8291

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMVALUETYPE_DATATYPEVERSION = 8292

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMVALUETYPE_DICTIONARYFRAGMENT = 8293

const UA_NS0ID_OPCUA_XMLSCHEMA_STATUSRESULT = 8294

const UA_NS0ID_OPCUA_XMLSCHEMA_STATUSRESULT_DATATYPEVERSION = 8295

const UA_NS0ID_OPCUA_XMLSCHEMA_STATUSRESULT_DICTIONARYFRAGMENT = 8296

const UA_NS0ID_OPCUA_XMLSCHEMA_USERTOKENPOLICY = 8297

const UA_NS0ID_OPCUA_XMLSCHEMA_USERTOKENPOLICY_DATATYPEVERSION = 8298

const UA_NS0ID_OPCUA_XMLSCHEMA_USERTOKENPOLICY_DICTIONARYFRAGMENT = 8299

const UA_NS0ID_OPCUA_XMLSCHEMA_APPLICATIONDESCRIPTION = 8300

const UA_NS0ID_OPCUA_XMLSCHEMA_APPLICATIONDESCRIPTION_DATATYPEVERSION = 8301

const UA_NS0ID_OPCUA_XMLSCHEMA_APPLICATIONDESCRIPTION_DICTIONARYFRAGMENT = 8302

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTDESCRIPTION = 8303

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTDESCRIPTION_DATATYPEVERSION = 8304

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTDESCRIPTION_DICTIONARYFRAGMENT = 8305

const UA_NS0ID_OPCUA_XMLSCHEMA_USERIDENTITYTOKEN = 8306

const UA_NS0ID_OPCUA_XMLSCHEMA_USERIDENTITYTOKEN_DATATYPEVERSION = 8307

const UA_NS0ID_OPCUA_XMLSCHEMA_USERIDENTITYTOKEN_DICTIONARYFRAGMENT = 8308

const UA_NS0ID_OPCUA_XMLSCHEMA_ANONYMOUSIDENTITYTOKEN = 8309

const UA_NS0ID_OPCUA_XMLSCHEMA_ANONYMOUSIDENTITYTOKEN_DATATYPEVERSION = 8310

const UA_NS0ID_OPCUA_XMLSCHEMA_ANONYMOUSIDENTITYTOKEN_DICTIONARYFRAGMENT = 8311

const UA_NS0ID_OPCUA_XMLSCHEMA_USERNAMEIDENTITYTOKEN = 8312

const UA_NS0ID_OPCUA_XMLSCHEMA_USERNAMEIDENTITYTOKEN_DATATYPEVERSION = 8313

const UA_NS0ID_OPCUA_XMLSCHEMA_USERNAMEIDENTITYTOKEN_DICTIONARYFRAGMENT = 8314

const UA_NS0ID_OPCUA_XMLSCHEMA_X509IDENTITYTOKEN = 8315

const UA_NS0ID_OPCUA_XMLSCHEMA_X509IDENTITYTOKEN_DATATYPEVERSION = 8316

const UA_NS0ID_OPCUA_XMLSCHEMA_X509IDENTITYTOKEN_DICTIONARYFRAGMENT = 8317

const UA_NS0ID_OPCUA_XMLSCHEMA_ISSUEDIDENTITYTOKEN = 8318

const UA_NS0ID_OPCUA_XMLSCHEMA_ISSUEDIDENTITYTOKEN_DATATYPEVERSION = 8319

const UA_NS0ID_OPCUA_XMLSCHEMA_ISSUEDIDENTITYTOKEN_DICTIONARYFRAGMENT = 8320

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTCONFIGURATION = 8321

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTCONFIGURATION_DATATYPEVERSION = 8322

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTCONFIGURATION_DICTIONARYFRAGMENT = 8323

const UA_NS0ID_OPCUA_XMLSCHEMA_BUILDINFO = 8327

const UA_NS0ID_OPCUA_XMLSCHEMA_BUILDINFO_DATATYPEVERSION = 8328

const UA_NS0ID_OPCUA_XMLSCHEMA_BUILDINFO_DICTIONARYFRAGMENT = 8329

const UA_NS0ID_OPCUA_XMLSCHEMA_SIGNEDSOFTWARECERTIFICATE = 8333

const UA_NS0ID_OPCUA_XMLSCHEMA_SIGNEDSOFTWARECERTIFICATE_DATATYPEVERSION = 8334

const UA_NS0ID_OPCUA_XMLSCHEMA_SIGNEDSOFTWARECERTIFICATE_DICTIONARYFRAGMENT = 8335

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDNODESITEM = 8363

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDNODESITEM_DATATYPEVERSION = 8364

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDNODESITEM_DICTIONARYFRAGMENT = 8365

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDREFERENCESITEM = 8366

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDREFERENCESITEM_DATATYPEVERSION = 8367

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDREFERENCESITEM_DICTIONARYFRAGMENT = 8368

const UA_NS0ID_OPCUA_XMLSCHEMA_DELETENODESITEM = 8369

const UA_NS0ID_OPCUA_XMLSCHEMA_DELETENODESITEM_DATATYPEVERSION = 8370

const UA_NS0ID_OPCUA_XMLSCHEMA_DELETENODESITEM_DICTIONARYFRAGMENT = 8371

const UA_NS0ID_OPCUA_XMLSCHEMA_DELETEREFERENCESITEM = 8372

const UA_NS0ID_OPCUA_XMLSCHEMA_DELETEREFERENCESITEM_DATATYPEVERSION = 8373

const UA_NS0ID_OPCUA_XMLSCHEMA_DELETEREFERENCESITEM_DICTIONARYFRAGMENT = 8374

const UA_NS0ID_OPCUA_XMLSCHEMA_REGISTEREDSERVER = 8417

const UA_NS0ID_OPCUA_XMLSCHEMA_REGISTEREDSERVER_DATATYPEVERSION = 8418

const UA_NS0ID_OPCUA_XMLSCHEMA_REGISTEREDSERVER_DICTIONARYFRAGMENT = 8419

const UA_NS0ID_OPCUA_XMLSCHEMA_CONTENTFILTERELEMENT = 8564

const UA_NS0ID_OPCUA_XMLSCHEMA_CONTENTFILTERELEMENT_DATATYPEVERSION = 8565

const UA_NS0ID_OPCUA_XMLSCHEMA_CONTENTFILTERELEMENT_DICTIONARYFRAGMENT = 8566

const UA_NS0ID_OPCUA_XMLSCHEMA_CONTENTFILTER = 8567

const UA_NS0ID_OPCUA_XMLSCHEMA_CONTENTFILTER_DATATYPEVERSION = 8568

const UA_NS0ID_OPCUA_XMLSCHEMA_CONTENTFILTER_DICTIONARYFRAGMENT = 8569

const UA_NS0ID_OPCUA_XMLSCHEMA_FILTEROPERAND = 8570

const UA_NS0ID_OPCUA_XMLSCHEMA_FILTEROPERAND_DATATYPEVERSION = 8571

const UA_NS0ID_OPCUA_XMLSCHEMA_FILTEROPERAND_DICTIONARYFRAGMENT = 8572

const UA_NS0ID_OPCUA_XMLSCHEMA_ELEMENTOPERAND = 8573

const UA_NS0ID_OPCUA_XMLSCHEMA_ELEMENTOPERAND_DATATYPEVERSION = 8574

const UA_NS0ID_OPCUA_XMLSCHEMA_ELEMENTOPERAND_DICTIONARYFRAGMENT = 8575

const UA_NS0ID_OPCUA_XMLSCHEMA_LITERALOPERAND = 8576

const UA_NS0ID_OPCUA_XMLSCHEMA_LITERALOPERAND_DATATYPEVERSION = 8577

const UA_NS0ID_OPCUA_XMLSCHEMA_LITERALOPERAND_DICTIONARYFRAGMENT = 8578

const UA_NS0ID_OPCUA_XMLSCHEMA_ATTRIBUTEOPERAND = 8579

const UA_NS0ID_OPCUA_XMLSCHEMA_ATTRIBUTEOPERAND_DATATYPEVERSION = 8580

const UA_NS0ID_OPCUA_XMLSCHEMA_ATTRIBUTEOPERAND_DICTIONARYFRAGMENT = 8581

const UA_NS0ID_OPCUA_XMLSCHEMA_SIMPLEATTRIBUTEOPERAND = 8582

const UA_NS0ID_OPCUA_XMLSCHEMA_SIMPLEATTRIBUTEOPERAND_DATATYPEVERSION = 8583

const UA_NS0ID_OPCUA_XMLSCHEMA_SIMPLEATTRIBUTEOPERAND_DICTIONARYFRAGMENT = 8584

const UA_NS0ID_OPCUA_XMLSCHEMA_HISTORYEVENT = 8639

const UA_NS0ID_OPCUA_XMLSCHEMA_HISTORYEVENT_DATATYPEVERSION = 8640

const UA_NS0ID_OPCUA_XMLSCHEMA_HISTORYEVENT_DICTIONARYFRAGMENT = 8641

const UA_NS0ID_OPCUA_XMLSCHEMA_MONITORINGFILTER = 8702

const UA_NS0ID_OPCUA_XMLSCHEMA_MONITORINGFILTER_DATATYPEVERSION = 8703

const UA_NS0ID_OPCUA_XMLSCHEMA_MONITORINGFILTER_DICTIONARYFRAGMENT = 8704

const UA_NS0ID_OPCUA_XMLSCHEMA_EVENTFILTER = 8708

const UA_NS0ID_OPCUA_XMLSCHEMA_EVENTFILTER_DATATYPEVERSION = 8709

const UA_NS0ID_OPCUA_XMLSCHEMA_EVENTFILTER_DICTIONARYFRAGMENT = 8710

const UA_NS0ID_OPCUA_XMLSCHEMA_AGGREGATECONFIGURATION = 8711

const UA_NS0ID_OPCUA_XMLSCHEMA_AGGREGATECONFIGURATION_DATATYPEVERSION = 8712

const UA_NS0ID_OPCUA_XMLSCHEMA_AGGREGATECONFIGURATION_DICTIONARYFRAGMENT = 8713

const UA_NS0ID_OPCUA_XMLSCHEMA_HISTORYEVENTFIELDLIST = 8807

const UA_NS0ID_OPCUA_XMLSCHEMA_HISTORYEVENTFIELDLIST_DATATYPEVERSION = 8808

const UA_NS0ID_OPCUA_XMLSCHEMA_HISTORYEVENTFIELDLIST_DICTIONARYFRAGMENT = 8809

const UA_NS0ID_OPCUA_XMLSCHEMA_REDUNDANTSERVERDATATYPE = 8843

const UA_NS0ID_OPCUA_XMLSCHEMA_REDUNDANTSERVERDATATYPE_DATATYPEVERSION = 8844

const UA_NS0ID_OPCUA_XMLSCHEMA_REDUNDANTSERVERDATATYPE_DICTIONARYFRAGMENT = 8845

const UA_NS0ID_OPCUA_XMLSCHEMA_SAMPLINGINTERVALDIAGNOSTICSDATATYPE = 8846

const UA_NS0ID_OPCUA_XMLSCHEMA_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8847

const UA_NS0ID_OPCUA_XMLSCHEMA_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8848

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERDIAGNOSTICSSUMMARYDATATYPE = 8849

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERDIAGNOSTICSSUMMARYDATATYPE_DATATYPEVERSION = 8850

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERDIAGNOSTICSSUMMARYDATATYPE_DICTIONARYFRAGMENT = 8851

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERSTATUSDATATYPE = 8852

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERSTATUSDATATYPE_DATATYPEVERSION = 8853

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERSTATUSDATATYPE_DICTIONARYFRAGMENT = 8854

const UA_NS0ID_OPCUA_XMLSCHEMA_SESSIONDIAGNOSTICSDATATYPE = 8855

const UA_NS0ID_OPCUA_XMLSCHEMA_SESSIONDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8856

const UA_NS0ID_OPCUA_XMLSCHEMA_SESSIONDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8857

const UA_NS0ID_OPCUA_XMLSCHEMA_SESSIONSECURITYDIAGNOSTICSDATATYPE = 8858

const UA_NS0ID_OPCUA_XMLSCHEMA_SESSIONSECURITYDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8859

const UA_NS0ID_OPCUA_XMLSCHEMA_SESSIONSECURITYDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8860

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVICECOUNTERDATATYPE = 8861

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVICECOUNTERDATATYPE_DATATYPEVERSION = 8862

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVICECOUNTERDATATYPE_DICTIONARYFRAGMENT = 8863

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIPTIONDIAGNOSTICSDATATYPE = 8864

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIPTIONDIAGNOSTICSDATATYPE_DATATYPEVERSION = 8865

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIPTIONDIAGNOSTICSDATATYPE_DICTIONARYFRAGMENT = 8866

const UA_NS0ID_OPCUA_XMLSCHEMA_MODELCHANGESTRUCTUREDATATYPE = 8867

const UA_NS0ID_OPCUA_XMLSCHEMA_MODELCHANGESTRUCTUREDATATYPE_DATATYPEVERSION = 8868

const UA_NS0ID_OPCUA_XMLSCHEMA_MODELCHANGESTRUCTUREDATATYPE_DICTIONARYFRAGMENT = 8869

const UA_NS0ID_OPCUA_XMLSCHEMA_SEMANTICCHANGESTRUCTUREDATATYPE = 8870

const UA_NS0ID_OPCUA_XMLSCHEMA_SEMANTICCHANGESTRUCTUREDATATYPE_DATATYPEVERSION = 8871

const UA_NS0ID_OPCUA_XMLSCHEMA_SEMANTICCHANGESTRUCTUREDATATYPE_DICTIONARYFRAGMENT = 8872

const UA_NS0ID_OPCUA_XMLSCHEMA_RANGE = 8873

const UA_NS0ID_OPCUA_XMLSCHEMA_RANGE_DATATYPEVERSION = 8874

const UA_NS0ID_OPCUA_XMLSCHEMA_RANGE_DICTIONARYFRAGMENT = 8875

const UA_NS0ID_OPCUA_XMLSCHEMA_EUINFORMATION = 8876

const UA_NS0ID_OPCUA_XMLSCHEMA_EUINFORMATION_DATATYPEVERSION = 8877

const UA_NS0ID_OPCUA_XMLSCHEMA_EUINFORMATION_DICTIONARYFRAGMENT = 8878

const UA_NS0ID_OPCUA_XMLSCHEMA_ANNOTATION = 8879

const UA_NS0ID_OPCUA_XMLSCHEMA_ANNOTATION_DATATYPEVERSION = 8880

const UA_NS0ID_OPCUA_XMLSCHEMA_ANNOTATION_DICTIONARYFRAGMENT = 8881

const UA_NS0ID_OPCUA_XMLSCHEMA_PROGRAMDIAGNOSTICDATATYPE = 8882

const UA_NS0ID_OPCUA_XMLSCHEMA_PROGRAMDIAGNOSTICDATATYPE_DATATYPEVERSION = 8883

const UA_NS0ID_OPCUA_XMLSCHEMA_PROGRAMDIAGNOSTICDATATYPE_DICTIONARYFRAGMENT = 8884

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_MAXLIFETIMECOUNT = 8888

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_LATEPUBLISHREQUESTCOUNT = 8889

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_CURRENTKEEPALIVECOUNT = 8890

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_CURRENTLIFETIMECOUNT = 8891

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_UNACKNOWLEDGEDMESSAGECOUNT = 8892

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_DISCARDEDMESSAGECOUNT = 8893

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_MONITOREDITEMCOUNT = 8894

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_DISABLEDMONITOREDITEMCOUNT = 8895

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_MONITORINGQUEUEOVERFLOWCOUNT = 8896

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_NEXTSEQUENCENUMBER = 8897

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_TOTALREQUESTCOUNT = 8898

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_TOTALREQUESTCOUNT = 8900

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSTYPE_EVENTQUEUEOVERFLOWCOUNT = 8902

const UA_NS0ID_TIMEZONEDATATYPE = 8912

const UA_NS0ID_TIMEZONEDATATYPE_ENCODING_DEFAULTXML = 8913

const UA_NS0ID_OPCUA_BINARYSCHEMA_TIMEZONEDATATYPE = 8914

const UA_NS0ID_OPCUA_BINARYSCHEMA_TIMEZONEDATATYPE_DATATYPEVERSION = 8915

const UA_NS0ID_OPCUA_BINARYSCHEMA_TIMEZONEDATATYPE_DICTIONARYFRAGMENT = 8916

const UA_NS0ID_TIMEZONEDATATYPE_ENCODING_DEFAULTBINARY = 8917

const UA_NS0ID_OPCUA_XMLSCHEMA_TIMEZONEDATATYPE = 8918

const UA_NS0ID_OPCUA_XMLSCHEMA_TIMEZONEDATATYPE_DATATYPEVERSION = 8919

const UA_NS0ID_OPCUA_XMLSCHEMA_TIMEZONEDATATYPE_DICTIONARYFRAGMENT = 8920

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE = 8927

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_EVENTID = 8928

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_EVENTTYPE = 8929

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_SOURCENODE = 8930

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_SOURCENAME = 8931

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_TIME = 8932

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_RECEIVETIME = 8933

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_LOCALTIME = 8934

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_MESSAGE = 8935

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_SEVERITY = 8936

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_ACTIONTIMESTAMP = 8937

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_STATUS = 8938

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_SERVERID = 8939

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_CLIENTAUDITENTRYID = 8940

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_CLIENTUSERID = 8941

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_METHODID = 8942

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_INPUTARGUMENTS = 8943

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE = 8944

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_EVENTID = 8945

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_EVENTTYPE = 8946

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_SOURCENODE = 8947

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_SOURCENAME = 8948

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_TIME = 8949

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_RECEIVETIME = 8950

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_LOCALTIME = 8951

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_MESSAGE = 8952

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_SEVERITY = 8953

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_ACTIONTIMESTAMP = 8954

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_STATUS = 8955

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_SERVERID = 8956

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_CLIENTAUDITENTRYID = 8957

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_CLIENTUSERID = 8958

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_METHODID = 8959

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_INPUTARGUMENTS = 8960

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE = 8961

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_EVENTID = 8962

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_EVENTTYPE = 8963

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_SOURCENODE = 8964

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_SOURCENAME = 8965

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_TIME = 8966

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_RECEIVETIME = 8967

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_LOCALTIME = 8968

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_MESSAGE = 8969

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_SEVERITY = 8970

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_ACTIONTIMESTAMP = 8971

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_STATUS = 8972

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_SERVERID = 8973

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_CLIENTAUDITENTRYID = 8974

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_CLIENTUSERID = 8975

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_METHODID = 8976

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_INPUTARGUMENTS = 8977

const UA_NS0ID_TWOSTATEVARIABLETYPE = 8995

const UA_NS0ID_TWOSTATEVARIABLETYPE_ID = 8996

const UA_NS0ID_TWOSTATEVARIABLETYPE_NAME = 8997

const UA_NS0ID_TWOSTATEVARIABLETYPE_NUMBER = 8998

const UA_NS0ID_TWOSTATEVARIABLETYPE_EFFECTIVEDISPLAYNAME = 8999

const UA_NS0ID_TWOSTATEVARIABLETYPE_TRANSITIONTIME = 9000

const UA_NS0ID_TWOSTATEVARIABLETYPE_EFFECTIVETRANSITIONTIME = 9001

const UA_NS0ID_CONDITIONVARIABLETYPE = 9002

const UA_NS0ID_CONDITIONVARIABLETYPE_SOURCETIMESTAMP = 9003

const UA_NS0ID_HASTRUESUBSTATE = 9004

const UA_NS0ID_HASFALSESUBSTATE = 9005

const UA_NS0ID_HASCONDITION = 9006

const UA_NS0ID_CONDITIONREFRESHMETHODTYPE = 9007

const UA_NS0ID_CONDITIONREFRESHMETHODTYPE_INPUTARGUMENTS = 9008

const UA_NS0ID_CONDITIONTYPE_CONDITIONNAME = 9009

const UA_NS0ID_CONDITIONTYPE_BRANCHID = 9010

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE = 9011

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_ID = 9012

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_NAME = 9013

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_NUMBER = 9014

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9015

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_TRANSITIONTIME = 9016

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9017

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_TRUESTATE = 9018

const UA_NS0ID_CONDITIONTYPE_ENABLEDSTATE_FALSESTATE = 9019

const UA_NS0ID_CONDITIONTYPE_QUALITY = 9020

const UA_NS0ID_CONDITIONTYPE_QUALITY_SOURCETIMESTAMP = 9021

const UA_NS0ID_CONDITIONTYPE_LASTSEVERITY = 9022

const UA_NS0ID_CONDITIONTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9023

const UA_NS0ID_CONDITIONTYPE_COMMENT = 9024

const UA_NS0ID_CONDITIONTYPE_COMMENT_SOURCETIMESTAMP = 9025

const UA_NS0ID_CONDITIONTYPE_CLIENTUSERID = 9026

const UA_NS0ID_CONDITIONTYPE_ENABLE = 9027

const UA_NS0ID_CONDITIONTYPE_DISABLE = 9028

const UA_NS0ID_CONDITIONTYPE_ADDCOMMENT = 9029

const UA_NS0ID_CONDITIONTYPE_ADDCOMMENT_INPUTARGUMENTS = 9030

const UA_NS0ID_DIALOGRESPONSEMETHODTYPE = 9031

const UA_NS0ID_DIALOGRESPONSEMETHODTYPE_INPUTARGUMENTS = 9032

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONNAME = 9033

const UA_NS0ID_DIALOGCONDITIONTYPE_BRANCHID = 9034

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE = 9035

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_ID = 9036

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_NAME = 9037

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_NUMBER = 9038

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9039

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_TRANSITIONTIME = 9040

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9041

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_TRUESTATE = 9042

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLEDSTATE_FALSESTATE = 9043

const UA_NS0ID_DIALOGCONDITIONTYPE_QUALITY = 9044

const UA_NS0ID_DIALOGCONDITIONTYPE_QUALITY_SOURCETIMESTAMP = 9045

const UA_NS0ID_DIALOGCONDITIONTYPE_LASTSEVERITY = 9046

const UA_NS0ID_DIALOGCONDITIONTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9047

const UA_NS0ID_DIALOGCONDITIONTYPE_COMMENT = 9048

const UA_NS0ID_DIALOGCONDITIONTYPE_COMMENT_SOURCETIMESTAMP = 9049

const UA_NS0ID_DIALOGCONDITIONTYPE_CLIENTUSERID = 9050

const UA_NS0ID_DIALOGCONDITIONTYPE_ENABLE = 9051

const UA_NS0ID_DIALOGCONDITIONTYPE_DISABLE = 9052

const UA_NS0ID_DIALOGCONDITIONTYPE_ADDCOMMENT = 9053

const UA_NS0ID_DIALOGCONDITIONTYPE_ADDCOMMENT_INPUTARGUMENTS = 9054

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE = 9055

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_ID = 9056

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_NAME = 9057

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_NUMBER = 9058

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_EFFECTIVEDISPLAYNAME = 9059

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_TRANSITIONTIME = 9060

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_EFFECTIVETRANSITIONTIME = 9061

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_TRUESTATE = 9062

const UA_NS0ID_DIALOGCONDITIONTYPE_DIALOGSTATE_FALSESTATE = 9063

const UA_NS0ID_DIALOGCONDITIONTYPE_RESPONSEOPTIONSET = 9064

const UA_NS0ID_DIALOGCONDITIONTYPE_DEFAULTRESPONSE = 9065

const UA_NS0ID_DIALOGCONDITIONTYPE_OKRESPONSE = 9066

const UA_NS0ID_DIALOGCONDITIONTYPE_CANCELRESPONSE = 9067

const UA_NS0ID_DIALOGCONDITIONTYPE_LASTRESPONSE = 9068

const UA_NS0ID_DIALOGCONDITIONTYPE_RESPOND = 9069

const UA_NS0ID_DIALOGCONDITIONTYPE_RESPOND_INPUTARGUMENTS = 9070

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONNAME = 9071

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_BRANCHID = 9072

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE = 9073

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_ID = 9074

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_NAME = 9075

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_NUMBER = 9076

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9077

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_TRANSITIONTIME = 9078

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9079

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_TRUESTATE = 9080

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLEDSTATE_FALSESTATE = 9081

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_QUALITY = 9082

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_QUALITY_SOURCETIMESTAMP = 9083

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_LASTSEVERITY = 9084

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9085

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_COMMENT = 9086

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_COMMENT_SOURCETIMESTAMP = 9087

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CLIENTUSERID = 9088

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ENABLE = 9089

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_DISABLE = 9090

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ADDCOMMENT = 9091

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ADDCOMMENT_INPUTARGUMENTS = 9092

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE = 9093

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_ID = 9094

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_NAME = 9095

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_NUMBER = 9096

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9097

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_TRANSITIONTIME = 9098

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9099

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_TRUESTATE = 9100

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKEDSTATE_FALSESTATE = 9101

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE = 9102

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_ID = 9103

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_NAME = 9104

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_NUMBER = 9105

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9106

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9107

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9108

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_TRUESTATE = 9109

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRMEDSTATE_FALSESTATE = 9110

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKNOWLEDGE = 9111

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9112

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRM = 9113

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONFIRM_INPUTARGUMENTS = 9114

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVETIME = 9115

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONNAME = 9116

const UA_NS0ID_ALARMCONDITIONTYPE_BRANCHID = 9117

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE = 9118

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_ID = 9119

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_NAME = 9120

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_NUMBER = 9121

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9122

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_TRANSITIONTIME = 9123

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9124

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_TRUESTATE = 9125

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLEDSTATE_FALSESTATE = 9126

const UA_NS0ID_ALARMCONDITIONTYPE_QUALITY = 9127

const UA_NS0ID_ALARMCONDITIONTYPE_QUALITY_SOURCETIMESTAMP = 9128

const UA_NS0ID_ALARMCONDITIONTYPE_LASTSEVERITY = 9129

const UA_NS0ID_ALARMCONDITIONTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9130

const UA_NS0ID_ALARMCONDITIONTYPE_COMMENT = 9131

const UA_NS0ID_ALARMCONDITIONTYPE_COMMENT_SOURCETIMESTAMP = 9132

const UA_NS0ID_ALARMCONDITIONTYPE_CLIENTUSERID = 9133

const UA_NS0ID_ALARMCONDITIONTYPE_ENABLE = 9134

const UA_NS0ID_ALARMCONDITIONTYPE_DISABLE = 9135

const UA_NS0ID_ALARMCONDITIONTYPE_ADDCOMMENT = 9136

const UA_NS0ID_ALARMCONDITIONTYPE_ADDCOMMENT_INPUTARGUMENTS = 9137

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE = 9138

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_ID = 9139

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_NAME = 9140

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_NUMBER = 9141

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9142

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_TRANSITIONTIME = 9143

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9144

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_TRUESTATE = 9145

const UA_NS0ID_ALARMCONDITIONTYPE_ACKEDSTATE_FALSESTATE = 9146

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE = 9147

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_ID = 9148

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_NAME = 9149

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_NUMBER = 9150

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9151

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9152

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9153

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_TRUESTATE = 9154

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRMEDSTATE_FALSESTATE = 9155

const UA_NS0ID_ALARMCONDITIONTYPE_ACKNOWLEDGE = 9156

const UA_NS0ID_ALARMCONDITIONTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9157

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRM = 9158

const UA_NS0ID_ALARMCONDITIONTYPE_CONFIRM_INPUTARGUMENTS = 9159

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE = 9160

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_ID = 9161

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_NAME = 9162

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_NUMBER = 9163

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9164

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_TRANSITIONTIME = 9165

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9166

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_TRUESTATE = 9167

const UA_NS0ID_ALARMCONDITIONTYPE_ACTIVESTATE_FALSESTATE = 9168

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE = 9169

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_ID = 9170

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_NAME = 9171

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_NUMBER = 9172

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9173

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9174

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9175

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_TRUESTATE = 9176

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDSTATE_FALSESTATE = 9177

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE = 9178

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_CURRENTSTATE = 9179

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9180

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9181

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9182

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9183

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_LASTTRANSITION = 9184

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9185

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9186

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9187

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9188

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_UNSHELVETIME = 9189

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_UNSHELVE = 9211

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_ONESHOTSHELVE = 9212

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_TIMEDSHELVE = 9213

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 9214

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESSEDORSHELVED = 9215

const UA_NS0ID_ALARMCONDITIONTYPE_MAXTIMESHELVED = 9216

const UA_NS0ID_LIMITALARMTYPE_CONDITIONNAME = 9217

const UA_NS0ID_LIMITALARMTYPE_BRANCHID = 9218

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE = 9219

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_ID = 9220

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_NAME = 9221

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_NUMBER = 9222

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9223

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 9224

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9225

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_TRUESTATE = 9226

const UA_NS0ID_LIMITALARMTYPE_ENABLEDSTATE_FALSESTATE = 9227

const UA_NS0ID_LIMITALARMTYPE_QUALITY = 9228

const UA_NS0ID_LIMITALARMTYPE_QUALITY_SOURCETIMESTAMP = 9229

const UA_NS0ID_LIMITALARMTYPE_LASTSEVERITY = 9230

const UA_NS0ID_LIMITALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9231

const UA_NS0ID_LIMITALARMTYPE_COMMENT = 9232

const UA_NS0ID_LIMITALARMTYPE_COMMENT_SOURCETIMESTAMP = 9233

const UA_NS0ID_LIMITALARMTYPE_CLIENTUSERID = 9234

const UA_NS0ID_LIMITALARMTYPE_ENABLE = 9235

const UA_NS0ID_LIMITALARMTYPE_DISABLE = 9236

const UA_NS0ID_LIMITALARMTYPE_ADDCOMMENT = 9237

const UA_NS0ID_LIMITALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 9238

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE = 9239

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_ID = 9240

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_NAME = 9241

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_NUMBER = 9242

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9243

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 9244

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9245

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_TRUESTATE = 9246

const UA_NS0ID_LIMITALARMTYPE_ACKEDSTATE_FALSESTATE = 9247

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE = 9248

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_ID = 9249

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_NAME = 9250

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_NUMBER = 9251

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9252

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9253

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9254

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 9255

const UA_NS0ID_LIMITALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 9256

const UA_NS0ID_LIMITALARMTYPE_ACKNOWLEDGE = 9257

const UA_NS0ID_LIMITALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9258

const UA_NS0ID_LIMITALARMTYPE_CONFIRM = 9259

const UA_NS0ID_LIMITALARMTYPE_CONFIRM_INPUTARGUMENTS = 9260

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE = 9261

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_ID = 9262

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_NAME = 9263

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_NUMBER = 9264

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9265

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 9266

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9267

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_TRUESTATE = 9268

const UA_NS0ID_LIMITALARMTYPE_ACTIVESTATE_FALSESTATE = 9269

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE = 9270

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_ID = 9271

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_NAME = 9272

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_NUMBER = 9273

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9274

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9275

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9276

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 9277

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 9278

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE = 9279

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 9280

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9281

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9282

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9283

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9284

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 9285

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9286

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9287

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9288

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9289

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 9290

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_UNSHELVE = 9312

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 9313

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 9314

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 9315

const UA_NS0ID_LIMITALARMTYPE_SUPPRESSEDORSHELVED = 9316

const UA_NS0ID_LIMITALARMTYPE_MAXTIMESHELVED = 9317

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE = 9318

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_CURRENTSTATE = 9319

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_CURRENTSTATE_ID = 9320

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_CURRENTSTATE_NAME = 9321

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_CURRENTSTATE_NUMBER = 9322

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9323

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LASTTRANSITION = 9324

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LASTTRANSITION_ID = 9325

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LASTTRANSITION_NAME = 9326

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LASTTRANSITION_NUMBER = 9327

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LASTTRANSITION_TRANSITIONTIME = 9328

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGHHIGH = 9329

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGHHIGH_STATENUMBER = 9330

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGH = 9331

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGH_STATENUMBER = 9332

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOW = 9333

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOW_STATENUMBER = 9334

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOWLOW = 9335

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOWLOW_STATENUMBER = 9336

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOWLOWTOLOW = 9337

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOWTOLOWLOW = 9338

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGHHIGHTOHIGH = 9339

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGHTOHIGHHIGH = 9340

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE = 9341

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_EVENTID = 9342

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_EVENTTYPE = 9343

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SOURCENODE = 9344

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SOURCENAME = 9345

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_TIME = 9346

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_RECEIVETIME = 9347

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LOCALTIME = 9348

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_MESSAGE = 9349

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SEVERITY = 9350

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONNAME = 9351

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_BRANCHID = 9352

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_RETAIN = 9353

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE = 9354

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_ID = 9355

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_NAME = 9356

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_NUMBER = 9357

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9358

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 9359

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9360

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_TRUESTATE = 9361

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_FALSESTATE = 9362

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_QUALITY = 9363

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_QUALITY_SOURCETIMESTAMP = 9364

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LASTSEVERITY = 9365

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9366

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_COMMENT = 9367

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_COMMENT_SOURCETIMESTAMP = 9368

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CLIENTUSERID = 9369

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ENABLE = 9370

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_DISABLE = 9371

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ADDCOMMENT = 9372

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 9373

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH = 9374

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 9375

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE = 9376

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_ID = 9377

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_NAME = 9378

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_NUMBER = 9379

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9380

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 9381

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9382

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_TRUESTATE = 9383

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKEDSTATE_FALSESTATE = 9384

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE = 9385

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_ID = 9386

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_NAME = 9387

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_NUMBER = 9388

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9389

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9390

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9391

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 9392

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 9393

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKNOWLEDGE = 9394

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9395

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRM = 9396

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONFIRM_INPUTARGUMENTS = 9397

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE = 9398

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_ID = 9399

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_NAME = 9400

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_NUMBER = 9401

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9402

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 9403

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9404

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_TRUESTATE = 9405

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ACTIVESTATE_FALSESTATE = 9406

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE = 9407

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_ID = 9408

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_NAME = 9409

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_NUMBER = 9410

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9411

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9412

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9413

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 9414

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 9415

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE = 9416

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 9417

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9418

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9419

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9420

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9421

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 9422

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9423

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9424

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9425

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9426

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 9427

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_UNSHELVE = 9449

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 9450

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 9451

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 9452

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESSEDORSHELVED = 9453

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_MAXTIMESHELVED = 9454

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE = 9455

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_CURRENTSTATE = 9456

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_CURRENTSTATE_ID = 9457

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_CURRENTSTATE_NAME = 9458

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_CURRENTSTATE_NUMBER = 9459

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9460

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_LASTTRANSITION = 9461

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_LASTTRANSITION_ID = 9462

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_LASTTRANSITION_NAME = 9463

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_LASTTRANSITION_NUMBER = 9464

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_LASTTRANSITION_TRANSITIONTIME = 9465

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_HIGHHIGHLIMIT = 9478

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_HIGHLIMIT = 9479

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LOWLIMIT = 9480

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LOWLOWLIMIT = 9481

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE = 9482

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_EVENTID = 9483

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_EVENTTYPE = 9484

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SOURCENODE = 9485

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SOURCENAME = 9486

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_TIME = 9487

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_RECEIVETIME = 9488

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LOCALTIME = 9489

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_MESSAGE = 9490

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SEVERITY = 9491

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONNAME = 9492

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_BRANCHID = 9493

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_RETAIN = 9494

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE = 9495

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_ID = 9496

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_NAME = 9497

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_NUMBER = 9498

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9499

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 9500

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9501

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_TRUESTATE = 9502

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_FALSESTATE = 9503

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_QUALITY = 9504

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_QUALITY_SOURCETIMESTAMP = 9505

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LASTSEVERITY = 9506

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9507

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_COMMENT = 9508

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_COMMENT_SOURCETIMESTAMP = 9509

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CLIENTUSERID = 9510

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ENABLE = 9511

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_DISABLE = 9512

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ADDCOMMENT = 9513

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 9514

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH = 9515

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 9516

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE = 9517

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_ID = 9518

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_NAME = 9519

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_NUMBER = 9520

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9521

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 9522

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9523

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_TRUESTATE = 9524

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKEDSTATE_FALSESTATE = 9525

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE = 9526

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_ID = 9527

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_NAME = 9528

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_NUMBER = 9529

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9530

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9531

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9532

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 9533

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 9534

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKNOWLEDGE = 9535

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9536

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRM = 9537

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONFIRM_INPUTARGUMENTS = 9538

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE = 9539

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_ID = 9540

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_NAME = 9541

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_NUMBER = 9542

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9543

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 9544

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9545

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_TRUESTATE = 9546

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ACTIVESTATE_FALSESTATE = 9547

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE = 9548

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_ID = 9549

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_NAME = 9550

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_NUMBER = 9551

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9552

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9553

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9554

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 9555

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 9556

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE = 9557

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 9558

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9559

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9560

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9561

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9562

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 9563

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9564

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9565

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9566

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9567

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 9568

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_UNSHELVE = 9590

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 9591

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 9592

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 9593

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESSEDORSHELVED = 9594

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_MAXTIMESHELVED = 9595

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE = 9596

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_CURRENTSTATE = 9597

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_CURRENTSTATE_ID = 9598

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_CURRENTSTATE_NAME = 9599

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_CURRENTSTATE_NUMBER = 9600

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9601

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_LASTTRANSITION = 9602

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_LASTTRANSITION_ID = 9603

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_LASTTRANSITION_NAME = 9604

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_LASTTRANSITION_NUMBER = 9605

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_LASTTRANSITION_TRANSITIONTIME = 9606

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_HIGHHIGHLIMIT = 9619

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_HIGHLIMIT = 9620

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LOWLIMIT = 9621

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LOWLOWLIMIT = 9622

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE = 9623

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_EVENTID = 9624

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_EVENTTYPE = 9625

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SOURCENODE = 9626

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SOURCENAME = 9627

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_TIME = 9628

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_RECEIVETIME = 9629

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LOCALTIME = 9630

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_MESSAGE = 9631

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SEVERITY = 9632

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONNAME = 9633

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_BRANCHID = 9634

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_RETAIN = 9635

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE = 9636

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_ID = 9637

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_NAME = 9638

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_NUMBER = 9639

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9640

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 9641

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9642

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_TRUESTATE = 9643

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_FALSESTATE = 9644

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_QUALITY = 9645

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_QUALITY_SOURCETIMESTAMP = 9646

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LASTSEVERITY = 9647

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9648

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_COMMENT = 9649

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_COMMENT_SOURCETIMESTAMP = 9650

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CLIENTUSERID = 9651

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENABLE = 9652

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_DISABLE = 9653

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ADDCOMMENT = 9654

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 9655

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH = 9656

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 9657

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE = 9658

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_ID = 9659

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_NAME = 9660

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_NUMBER = 9661

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9662

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 9663

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9664

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_TRUESTATE = 9665

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_FALSESTATE = 9666

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE = 9667

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_ID = 9668

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_NAME = 9669

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_NUMBER = 9670

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9671

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9672

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9673

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 9674

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 9675

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKNOWLEDGE = 9676

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9677

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRM = 9678

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRM_INPUTARGUMENTS = 9679

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE = 9680

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_ID = 9681

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_NAME = 9682

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_NUMBER = 9683

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9684

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 9685

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9686

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_TRUESTATE = 9687

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_FALSESTATE = 9688

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE = 9689

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_ID = 9690

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_NAME = 9691

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_NUMBER = 9692

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9693

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9694

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9695

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 9696

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 9697

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE = 9698

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 9699

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9700

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9701

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9702

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9703

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 9704

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9705

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9706

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9707

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9708

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 9709

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_UNSHELVE = 9731

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 9732

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 9733

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 9734

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDORSHELVED = 9735

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_MAXTIMESHELVED = 9736

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE = 9737

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_CURRENTSTATE = 9738

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_CURRENTSTATE_ID = 9739

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_CURRENTSTATE_NAME = 9740

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_CURRENTSTATE_NUMBER = 9741

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9742

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_LASTTRANSITION = 9743

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_LASTTRANSITION_ID = 9744

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_LASTTRANSITION_NAME = 9745

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_LASTTRANSITION_NUMBER = 9746

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_LASTTRANSITION_TRANSITIONTIME = 9747

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHLIMIT = 9760

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_HIGHLIMIT = 9761

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LOWLIMIT = 9762

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWLIMIT = 9763

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE = 9764

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_EVENTID = 9765

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_EVENTTYPE = 9766

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SOURCENODE = 9767

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SOURCENAME = 9768

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_TIME = 9769

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_RECEIVETIME = 9770

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LOCALTIME = 9771

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_MESSAGE = 9772

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SEVERITY = 9773

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONNAME = 9774

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_BRANCHID = 9775

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_RETAIN = 9776

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE = 9777

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_ID = 9778

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_NAME = 9779

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_NUMBER = 9780

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9781

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 9782

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9783

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_TRUESTATE = 9784

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_FALSESTATE = 9785

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_QUALITY = 9786

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_QUALITY_SOURCETIMESTAMP = 9787

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LASTSEVERITY = 9788

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9789

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_COMMENT = 9790

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_COMMENT_SOURCETIMESTAMP = 9791

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CLIENTUSERID = 9792

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ENABLE = 9793

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_DISABLE = 9794

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ADDCOMMENT = 9795

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 9796

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH = 9797

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 9798

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE = 9799

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_ID = 9800

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_NAME = 9801

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_NUMBER = 9802

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9803

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 9804

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9805

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_TRUESTATE = 9806

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_FALSESTATE = 9807

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE = 9808

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_ID = 9809

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_NAME = 9810

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_NUMBER = 9811

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9812

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9813

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9814

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 9815

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 9816

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKNOWLEDGE = 9817

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9818

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRM = 9819

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONFIRM_INPUTARGUMENTS = 9820

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE = 9821

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_ID = 9822

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_NAME = 9823

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_NUMBER = 9824

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9825

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 9826

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9827

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_TRUESTATE = 9828

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_FALSESTATE = 9829

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE = 9830

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_ID = 9831

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_NAME = 9832

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_NUMBER = 9833

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9834

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9835

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9836

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 9837

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 9838

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE = 9839

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 9840

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9841

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9842

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9843

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9844

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 9845

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9846

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9847

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9848

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9849

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 9850

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_UNSHELVE = 9872

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 9873

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 9874

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 9875

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDORSHELVED = 9876

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_MAXTIMESHELVED = 9877

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE = 9878

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_CURRENTSTATE = 9879

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_CURRENTSTATE_ID = 9880

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_CURRENTSTATE_NAME = 9881

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_CURRENTSTATE_NUMBER = 9882

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9883

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_LASTTRANSITION = 9884

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_LASTTRANSITION_ID = 9885

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_LASTTRANSITION_NAME = 9886

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_LASTTRANSITION_NUMBER = 9887

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_LASTTRANSITION_TRANSITIONTIME = 9888

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHLIMIT = 9901

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_HIGHLIMIT = 9902

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LOWLIMIT = 9903

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LOWLOWLIMIT = 9904

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SETPOINTNODE = 9905

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE = 9906

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_EVENTID = 9907

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_EVENTTYPE = 9908

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SOURCENODE = 9909

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SOURCENAME = 9910

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_TIME = 9911

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_RECEIVETIME = 9912

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOCALTIME = 9913

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_MESSAGE = 9914

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SEVERITY = 9915

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONNAME = 9916

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_BRANCHID = 9917

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_RETAIN = 9918

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE = 9919

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_ID = 9920

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_NAME = 9921

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_NUMBER = 9922

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 9923

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 9924

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 9925

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_TRUESTATE = 9926

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLEDSTATE_FALSESTATE = 9927

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_QUALITY = 9928

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_QUALITY_SOURCETIMESTAMP = 9929

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LASTSEVERITY = 9930

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 9931

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_COMMENT = 9932

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_COMMENT_SOURCETIMESTAMP = 9933

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CLIENTUSERID = 9934

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ENABLE = 9935

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_DISABLE = 9936

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ADDCOMMENT = 9937

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 9938

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH = 9939

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 9940

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE = 9941

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_ID = 9942

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_NAME = 9943

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_NUMBER = 9944

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 9945

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 9946

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 9947

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_TRUESTATE = 9948

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKEDSTATE_FALSESTATE = 9949

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE = 9950

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_ID = 9951

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_NAME = 9952

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_NUMBER = 9953

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 9954

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 9955

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 9956

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 9957

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 9958

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKNOWLEDGE = 9959

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 9960

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRM = 9961

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONFIRM_INPUTARGUMENTS = 9962

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE = 9963

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_ID = 9964

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_NAME = 9965

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_NUMBER = 9966

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 9967

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 9968

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 9969

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_TRUESTATE = 9970

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ACTIVESTATE_FALSESTATE = 9971

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE = 9972

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_ID = 9973

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_NAME = 9974

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_NUMBER = 9975

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 9976

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 9977

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 9978

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 9979

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 9980

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE = 9981

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 9982

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 9983

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 9984

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 9985

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 9986

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 9987

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 9988

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 9989

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 9990

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 9991

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 9992

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_UNSHELVE = 10014

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10015

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10016

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10017

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESSEDORSHELVED = 10018

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_MAXTIMESHELVED = 10019

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE = 10020

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_ID = 10021

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_NAME = 10022

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_NUMBER = 10023

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_EFFECTIVEDISPLAYNAME = 10024

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_TRANSITIONTIME = 10025

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_EFFECTIVETRANSITIONTIME = 10026

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_TRUESTATE = 10027

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHSTATE_FALSESTATE = 10028

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE = 10029

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_ID = 10030

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_NAME = 10031

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_NUMBER = 10032

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_EFFECTIVEDISPLAYNAME = 10033

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_TRANSITIONTIME = 10034

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_EFFECTIVETRANSITIONTIME = 10035

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_TRUESTATE = 10036

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHSTATE_FALSESTATE = 10037

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE = 10038

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_ID = 10039

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_NAME = 10040

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_NUMBER = 10041

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_EFFECTIVEDISPLAYNAME = 10042

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_TRANSITIONTIME = 10043

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_EFFECTIVETRANSITIONTIME = 10044

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_TRUESTATE = 10045

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWSTATE_FALSESTATE = 10046

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE = 10047

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_ID = 10048

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_NAME = 10049

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_NUMBER = 10050

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_EFFECTIVEDISPLAYNAME = 10051

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_TRANSITIONTIME = 10052

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_EFFECTIVETRANSITIONTIME = 10053

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_TRUESTATE = 10054

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWSTATE_FALSESTATE = 10055

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHHIGHLIMIT = 10056

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_HIGHLIMIT = 10057

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLIMIT = 10058

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LOWLOWLIMIT = 10059

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE = 10060

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_EVENTID = 10061

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_EVENTTYPE = 10062

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SOURCENODE = 10063

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SOURCENAME = 10064

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_TIME = 10065

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_RECEIVETIME = 10066

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOCALTIME = 10067

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_MESSAGE = 10068

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SEVERITY = 10069

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONNAME = 10070

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_BRANCHID = 10071

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_RETAIN = 10072

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE = 10073

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_ID = 10074

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_NAME = 10075

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_NUMBER = 10076

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 10077

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 10078

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 10079

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_TRUESTATE = 10080

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLEDSTATE_FALSESTATE = 10081

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_QUALITY = 10082

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_QUALITY_SOURCETIMESTAMP = 10083

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LASTSEVERITY = 10084

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 10085

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_COMMENT = 10086

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_COMMENT_SOURCETIMESTAMP = 10087

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CLIENTUSERID = 10088

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ENABLE = 10089

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_DISABLE = 10090

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ADDCOMMENT = 10091

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 10092

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH = 10093

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 10094

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE = 10095

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_ID = 10096

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_NAME = 10097

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_NUMBER = 10098

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 10099

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 10100

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 10101

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_TRUESTATE = 10102

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKEDSTATE_FALSESTATE = 10103

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE = 10104

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_ID = 10105

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_NAME = 10106

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_NUMBER = 10107

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 10108

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 10109

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 10110

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 10111

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 10112

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKNOWLEDGE = 10113

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 10114

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRM = 10115

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONFIRM_INPUTARGUMENTS = 10116

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE = 10117

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_ID = 10118

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_NAME = 10119

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_NUMBER = 10120

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 10121

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 10122

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 10123

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_TRUESTATE = 10124

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ACTIVESTATE_FALSESTATE = 10125

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE = 10126

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_ID = 10127

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_NAME = 10128

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_NUMBER = 10129

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 10130

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 10131

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 10132

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 10133

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 10134

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE = 10135

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 10136

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 10137

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 10138

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 10139

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 10140

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 10141

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 10142

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 10143

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 10144

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 10145

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 10146

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_UNSHELVE = 10168

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10169

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10170

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10171

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESSEDORSHELVED = 10172

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_MAXTIMESHELVED = 10173

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE = 10174

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_ID = 10175

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_NAME = 10176

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_NUMBER = 10177

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_EFFECTIVEDISPLAYNAME = 10178

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_TRANSITIONTIME = 10179

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_EFFECTIVETRANSITIONTIME = 10180

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_TRUESTATE = 10181

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHSTATE_FALSESTATE = 10182

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE = 10183

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_ID = 10184

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_NAME = 10185

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_NUMBER = 10186

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_EFFECTIVEDISPLAYNAME = 10187

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_TRANSITIONTIME = 10188

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_EFFECTIVETRANSITIONTIME = 10189

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_TRUESTATE = 10190

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHSTATE_FALSESTATE = 10191

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE = 10192

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_ID = 10193

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_NAME = 10194

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_NUMBER = 10195

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_EFFECTIVEDISPLAYNAME = 10196

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_TRANSITIONTIME = 10197

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_EFFECTIVETRANSITIONTIME = 10198

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_TRUESTATE = 10199

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWSTATE_FALSESTATE = 10200

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE = 10201

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_ID = 10202

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_NAME = 10203

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_NUMBER = 10204

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_EFFECTIVEDISPLAYNAME = 10205

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_TRANSITIONTIME = 10206

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_EFFECTIVETRANSITIONTIME = 10207

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_TRUESTATE = 10208

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWSTATE_FALSESTATE = 10209

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHHIGHLIMIT = 10210

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_HIGHLIMIT = 10211

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLIMIT = 10212

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LOWLOWLIMIT = 10213

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE = 10214

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_EVENTID = 10215

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_EVENTTYPE = 10216

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SOURCENODE = 10217

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SOURCENAME = 10218

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_TIME = 10219

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_RECEIVETIME = 10220

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOCALTIME = 10221

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_MESSAGE = 10222

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SEVERITY = 10223

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONNAME = 10224

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_BRANCHID = 10225

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_RETAIN = 10226

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE = 10227

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_ID = 10228

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_NAME = 10229

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_NUMBER = 10230

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 10231

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 10232

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 10233

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_TRUESTATE = 10234

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLEDSTATE_FALSESTATE = 10235

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_QUALITY = 10236

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_QUALITY_SOURCETIMESTAMP = 10237

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LASTSEVERITY = 10238

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 10239

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_COMMENT = 10240

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_COMMENT_SOURCETIMESTAMP = 10241

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CLIENTUSERID = 10242

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENABLE = 10243

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_DISABLE = 10244

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ADDCOMMENT = 10245

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 10246

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH = 10247

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 10248

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE = 10249

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_ID = 10250

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_NAME = 10251

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_NUMBER = 10252

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 10253

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 10254

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 10255

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_TRUESTATE = 10256

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKEDSTATE_FALSESTATE = 10257

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE = 10258

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_ID = 10259

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_NAME = 10260

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_NUMBER = 10261

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 10262

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 10263

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 10264

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 10265

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 10266

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKNOWLEDGE = 10267

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 10268

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRM = 10269

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONFIRM_INPUTARGUMENTS = 10270

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE = 10271

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_ID = 10272

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_NAME = 10273

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_NUMBER = 10274

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 10275

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 10276

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 10277

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_TRUESTATE = 10278

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ACTIVESTATE_FALSESTATE = 10279

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE = 10280

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_ID = 10281

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_NAME = 10282

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_NUMBER = 10283

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 10284

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 10285

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 10286

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 10287

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 10288

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE = 10289

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 10290

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 10291

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 10292

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 10293

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 10294

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 10295

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 10296

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 10297

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 10298

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 10299

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 10300

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_UNSHELVE = 10322

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10323

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10324

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10325

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESSEDORSHELVED = 10326

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_MAXTIMESHELVED = 10327

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE = 10328

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_ID = 10329

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_NAME = 10330

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_NUMBER = 10331

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_EFFECTIVEDISPLAYNAME = 10332

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_TRANSITIONTIME = 10333

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_EFFECTIVETRANSITIONTIME = 10334

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_TRUESTATE = 10335

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHSTATE_FALSESTATE = 10336

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE = 10337

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_ID = 10338

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_NAME = 10339

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_NUMBER = 10340

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_EFFECTIVEDISPLAYNAME = 10341

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_TRANSITIONTIME = 10342

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_EFFECTIVETRANSITIONTIME = 10343

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_TRUESTATE = 10344

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHSTATE_FALSESTATE = 10345

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE = 10346

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_ID = 10347

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_NAME = 10348

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_NUMBER = 10349

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_EFFECTIVEDISPLAYNAME = 10350

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_TRANSITIONTIME = 10351

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_EFFECTIVETRANSITIONTIME = 10352

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_TRUESTATE = 10353

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWSTATE_FALSESTATE = 10354

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE = 10355

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_ID = 10356

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_NAME = 10357

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_NUMBER = 10358

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_EFFECTIVEDISPLAYNAME = 10359

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_TRANSITIONTIME = 10360

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_EFFECTIVETRANSITIONTIME = 10361

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_TRUESTATE = 10362

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWSTATE_FALSESTATE = 10363

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHHIGHLIMIT = 10364

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_HIGHLIMIT = 10365

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLIMIT = 10366

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LOWLOWLIMIT = 10367

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE = 10368

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_EVENTID = 10369

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_EVENTTYPE = 10370

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SOURCENODE = 10371

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SOURCENAME = 10372

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_TIME = 10373

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_RECEIVETIME = 10374

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOCALTIME = 10375

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_MESSAGE = 10376

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SEVERITY = 10377

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONNAME = 10378

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_BRANCHID = 10379

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_RETAIN = 10380

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE = 10381

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_ID = 10382

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_NAME = 10383

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_NUMBER = 10384

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 10385

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 10386

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 10387

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_TRUESTATE = 10388

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLEDSTATE_FALSESTATE = 10389

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_QUALITY = 10390

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_QUALITY_SOURCETIMESTAMP = 10391

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LASTSEVERITY = 10392

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 10393

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_COMMENT = 10394

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_COMMENT_SOURCETIMESTAMP = 10395

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CLIENTUSERID = 10396

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ENABLE = 10397

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_DISABLE = 10398

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ADDCOMMENT = 10399

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 10400

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH = 10401

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 10402

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE = 10403

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_ID = 10404

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_NAME = 10405

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_NUMBER = 10406

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 10407

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 10408

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 10409

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_TRUESTATE = 10410

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKEDSTATE_FALSESTATE = 10411

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE = 10412

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_ID = 10413

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_NAME = 10414

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_NUMBER = 10415

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 10416

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 10417

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 10418

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 10419

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 10420

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKNOWLEDGE = 10421

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 10422

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRM = 10423

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONFIRM_INPUTARGUMENTS = 10424

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE = 10425

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_ID = 10426

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_NAME = 10427

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_NUMBER = 10428

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 10429

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 10430

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 10431

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_TRUESTATE = 10432

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ACTIVESTATE_FALSESTATE = 10433

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE = 10434

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_ID = 10435

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_NAME = 10436

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_NUMBER = 10437

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 10438

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 10439

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 10440

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 10441

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 10442

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE = 10443

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 10444

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 10445

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 10446

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 10447

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 10448

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 10449

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 10450

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 10451

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 10452

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 10453

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 10454

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_UNSHELVE = 10476

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10477

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10478

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10479

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESSEDORSHELVED = 10480

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_MAXTIMESHELVED = 10481

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE = 10482

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_ID = 10483

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_NAME = 10484

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_NUMBER = 10485

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_EFFECTIVEDISPLAYNAME = 10486

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_TRANSITIONTIME = 10487

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_EFFECTIVETRANSITIONTIME = 10488

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_TRUESTATE = 10489

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHSTATE_FALSESTATE = 10490

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE = 10491

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_ID = 10492

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_NAME = 10493

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_NUMBER = 10494

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_EFFECTIVEDISPLAYNAME = 10495

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_TRANSITIONTIME = 10496

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_EFFECTIVETRANSITIONTIME = 10497

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_TRUESTATE = 10498

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHSTATE_FALSESTATE = 10499

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE = 10500

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_ID = 10501

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_NAME = 10502

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_NUMBER = 10503

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_EFFECTIVEDISPLAYNAME = 10504

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_TRANSITIONTIME = 10505

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_EFFECTIVETRANSITIONTIME = 10506

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_TRUESTATE = 10507

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWSTATE_FALSESTATE = 10508

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE = 10509

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_ID = 10510

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_NAME = 10511

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_NUMBER = 10512

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_EFFECTIVEDISPLAYNAME = 10513

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_TRANSITIONTIME = 10514

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_EFFECTIVETRANSITIONTIME = 10515

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_TRUESTATE = 10516

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWSTATE_FALSESTATE = 10517

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHHIGHLIMIT = 10518

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_HIGHLIMIT = 10519

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLIMIT = 10520

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LOWLOWLIMIT = 10521

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SETPOINTNODE = 10522

const UA_NS0ID_DISCRETEALARMTYPE = 10523

const UA_NS0ID_DISCRETEALARMTYPE_EVENTID = 10524

const UA_NS0ID_DISCRETEALARMTYPE_EVENTTYPE = 10525

const UA_NS0ID_DISCRETEALARMTYPE_SOURCENODE = 10526

const UA_NS0ID_DISCRETEALARMTYPE_SOURCENAME = 10527

const UA_NS0ID_DISCRETEALARMTYPE_TIME = 10528

const UA_NS0ID_DISCRETEALARMTYPE_RECEIVETIME = 10529

const UA_NS0ID_DISCRETEALARMTYPE_LOCALTIME = 10530

const UA_NS0ID_DISCRETEALARMTYPE_MESSAGE = 10531

const UA_NS0ID_DISCRETEALARMTYPE_SEVERITY = 10532

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONNAME = 10533

const UA_NS0ID_DISCRETEALARMTYPE_BRANCHID = 10534

const UA_NS0ID_DISCRETEALARMTYPE_RETAIN = 10535

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE = 10536

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_ID = 10537

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_NAME = 10538

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_NUMBER = 10539

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 10540

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 10541

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 10542

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_TRUESTATE = 10543

const UA_NS0ID_DISCRETEALARMTYPE_ENABLEDSTATE_FALSESTATE = 10544

const UA_NS0ID_DISCRETEALARMTYPE_QUALITY = 10545

const UA_NS0ID_DISCRETEALARMTYPE_QUALITY_SOURCETIMESTAMP = 10546

const UA_NS0ID_DISCRETEALARMTYPE_LASTSEVERITY = 10547

const UA_NS0ID_DISCRETEALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 10548

const UA_NS0ID_DISCRETEALARMTYPE_COMMENT = 10549

const UA_NS0ID_DISCRETEALARMTYPE_COMMENT_SOURCETIMESTAMP = 10550

const UA_NS0ID_DISCRETEALARMTYPE_CLIENTUSERID = 10551

const UA_NS0ID_DISCRETEALARMTYPE_ENABLE = 10552

const UA_NS0ID_DISCRETEALARMTYPE_DISABLE = 10553

const UA_NS0ID_DISCRETEALARMTYPE_ADDCOMMENT = 10554

const UA_NS0ID_DISCRETEALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 10555

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONREFRESH = 10556

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 10557

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE = 10558

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_ID = 10559

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_NAME = 10560

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_NUMBER = 10561

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 10562

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 10563

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 10564

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_TRUESTATE = 10565

const UA_NS0ID_DISCRETEALARMTYPE_ACKEDSTATE_FALSESTATE = 10566

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE = 10567

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_ID = 10568

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_NAME = 10569

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_NUMBER = 10570

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 10571

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 10572

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 10573

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 10574

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 10575

const UA_NS0ID_DISCRETEALARMTYPE_ACKNOWLEDGE = 10576

const UA_NS0ID_DISCRETEALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 10577

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRM = 10578

const UA_NS0ID_DISCRETEALARMTYPE_CONFIRM_INPUTARGUMENTS = 10579

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE = 10580

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_ID = 10581

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_NAME = 10582

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_NUMBER = 10583

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 10584

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 10585

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 10586

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_TRUESTATE = 10587

const UA_NS0ID_DISCRETEALARMTYPE_ACTIVESTATE_FALSESTATE = 10588

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE = 10589

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_ID = 10590

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_NAME = 10591

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_NUMBER = 10592

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 10593

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 10594

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 10595

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 10596

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 10597

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE = 10598

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 10599

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 10600

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 10601

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 10602

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 10603

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 10604

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 10605

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 10606

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 10607

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 10608

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 10609

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_UNSHELVE = 10631

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10632

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10633

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10634

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESSEDORSHELVED = 10635

const UA_NS0ID_DISCRETEALARMTYPE_MAXTIMESHELVED = 10636

const UA_NS0ID_OFFNORMALALARMTYPE = 10637

const UA_NS0ID_OFFNORMALALARMTYPE_EVENTID = 10638

const UA_NS0ID_OFFNORMALALARMTYPE_EVENTTYPE = 10639

const UA_NS0ID_OFFNORMALALARMTYPE_SOURCENODE = 10640

const UA_NS0ID_OFFNORMALALARMTYPE_SOURCENAME = 10641

const UA_NS0ID_OFFNORMALALARMTYPE_TIME = 10642

const UA_NS0ID_OFFNORMALALARMTYPE_RECEIVETIME = 10643

const UA_NS0ID_OFFNORMALALARMTYPE_LOCALTIME = 10644

const UA_NS0ID_OFFNORMALALARMTYPE_MESSAGE = 10645

const UA_NS0ID_OFFNORMALALARMTYPE_SEVERITY = 10646

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONNAME = 10647

const UA_NS0ID_OFFNORMALALARMTYPE_BRANCHID = 10648

const UA_NS0ID_OFFNORMALALARMTYPE_RETAIN = 10649

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE = 10650

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_ID = 10651

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_NAME = 10652

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_NUMBER = 10653

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 10654

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 10655

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 10656

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_TRUESTATE = 10657

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLEDSTATE_FALSESTATE = 10658

const UA_NS0ID_OFFNORMALALARMTYPE_QUALITY = 10659

const UA_NS0ID_OFFNORMALALARMTYPE_QUALITY_SOURCETIMESTAMP = 10660

const UA_NS0ID_OFFNORMALALARMTYPE_LASTSEVERITY = 10661

const UA_NS0ID_OFFNORMALALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 10662

const UA_NS0ID_OFFNORMALALARMTYPE_COMMENT = 10663

const UA_NS0ID_OFFNORMALALARMTYPE_COMMENT_SOURCETIMESTAMP = 10664

const UA_NS0ID_OFFNORMALALARMTYPE_CLIENTUSERID = 10665

const UA_NS0ID_OFFNORMALALARMTYPE_ENABLE = 10666

const UA_NS0ID_OFFNORMALALARMTYPE_DISABLE = 10667

const UA_NS0ID_OFFNORMALALARMTYPE_ADDCOMMENT = 10668

const UA_NS0ID_OFFNORMALALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 10669

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONREFRESH = 10670

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 10671

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE = 10672

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_ID = 10673

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_NAME = 10674

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_NUMBER = 10675

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 10676

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 10677

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 10678

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_TRUESTATE = 10679

const UA_NS0ID_OFFNORMALALARMTYPE_ACKEDSTATE_FALSESTATE = 10680

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE = 10681

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_ID = 10682

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_NAME = 10683

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_NUMBER = 10684

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 10685

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 10686

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 10687

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 10688

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 10689

const UA_NS0ID_OFFNORMALALARMTYPE_ACKNOWLEDGE = 10690

const UA_NS0ID_OFFNORMALALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 10691

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRM = 10692

const UA_NS0ID_OFFNORMALALARMTYPE_CONFIRM_INPUTARGUMENTS = 10693

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE = 10694

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_ID = 10695

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_NAME = 10696

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_NUMBER = 10697

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 10698

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 10699

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 10700

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_TRUESTATE = 10701

const UA_NS0ID_OFFNORMALALARMTYPE_ACTIVESTATE_FALSESTATE = 10702

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE = 10703

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_ID = 10704

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_NAME = 10705

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_NUMBER = 10706

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 10707

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 10708

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 10709

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 10710

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 10711

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE = 10712

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 10713

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 10714

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 10715

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 10716

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 10717

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 10718

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 10719

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 10720

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 10721

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 10722

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 10723

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_UNSHELVE = 10745

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10746

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10747

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10748

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESSEDORSHELVED = 10749

const UA_NS0ID_OFFNORMALALARMTYPE_MAXTIMESHELVED = 10750

const UA_NS0ID_TRIPALARMTYPE = 10751

const UA_NS0ID_TRIPALARMTYPE_EVENTID = 10752

const UA_NS0ID_TRIPALARMTYPE_EVENTTYPE = 10753

const UA_NS0ID_TRIPALARMTYPE_SOURCENODE = 10754

const UA_NS0ID_TRIPALARMTYPE_SOURCENAME = 10755

const UA_NS0ID_TRIPALARMTYPE_TIME = 10756

const UA_NS0ID_TRIPALARMTYPE_RECEIVETIME = 10757

const UA_NS0ID_TRIPALARMTYPE_LOCALTIME = 10758

const UA_NS0ID_TRIPALARMTYPE_MESSAGE = 10759

const UA_NS0ID_TRIPALARMTYPE_SEVERITY = 10760

const UA_NS0ID_TRIPALARMTYPE_CONDITIONNAME = 10761

const UA_NS0ID_TRIPALARMTYPE_BRANCHID = 10762

const UA_NS0ID_TRIPALARMTYPE_RETAIN = 10763

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE = 10764

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_ID = 10765

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_NAME = 10766

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_NUMBER = 10767

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 10768

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 10769

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 10770

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_TRUESTATE = 10771

const UA_NS0ID_TRIPALARMTYPE_ENABLEDSTATE_FALSESTATE = 10772

const UA_NS0ID_TRIPALARMTYPE_QUALITY = 10773

const UA_NS0ID_TRIPALARMTYPE_QUALITY_SOURCETIMESTAMP = 10774

const UA_NS0ID_TRIPALARMTYPE_LASTSEVERITY = 10775

const UA_NS0ID_TRIPALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 10776

const UA_NS0ID_TRIPALARMTYPE_COMMENT = 10777

const UA_NS0ID_TRIPALARMTYPE_COMMENT_SOURCETIMESTAMP = 10778

const UA_NS0ID_TRIPALARMTYPE_CLIENTUSERID = 10779

const UA_NS0ID_TRIPALARMTYPE_ENABLE = 10780

const UA_NS0ID_TRIPALARMTYPE_DISABLE = 10781

const UA_NS0ID_TRIPALARMTYPE_ADDCOMMENT = 10782

const UA_NS0ID_TRIPALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 10783

const UA_NS0ID_TRIPALARMTYPE_CONDITIONREFRESH = 10784

const UA_NS0ID_TRIPALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 10785

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE = 10786

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_ID = 10787

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_NAME = 10788

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_NUMBER = 10789

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 10790

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 10791

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 10792

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_TRUESTATE = 10793

const UA_NS0ID_TRIPALARMTYPE_ACKEDSTATE_FALSESTATE = 10794

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE = 10795

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_ID = 10796

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_NAME = 10797

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_NUMBER = 10798

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 10799

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 10800

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 10801

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 10802

const UA_NS0ID_TRIPALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 10803

const UA_NS0ID_TRIPALARMTYPE_ACKNOWLEDGE = 10804

const UA_NS0ID_TRIPALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 10805

const UA_NS0ID_TRIPALARMTYPE_CONFIRM = 10806

const UA_NS0ID_TRIPALARMTYPE_CONFIRM_INPUTARGUMENTS = 10807

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE = 10808

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_ID = 10809

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_NAME = 10810

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_NUMBER = 10811

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 10812

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 10813

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 10814

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_TRUESTATE = 10815

const UA_NS0ID_TRIPALARMTYPE_ACTIVESTATE_FALSESTATE = 10816

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE = 10817

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_ID = 10818

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_NAME = 10819

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_NUMBER = 10820

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 10821

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 10822

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 10823

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 10824

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 10825

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE = 10826

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 10827

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 10828

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 10829

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 10830

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 10831

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 10832

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 10833

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 10834

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 10835

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 10836

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 10837

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_UNSHELVE = 10859

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 10860

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 10861

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 10862

const UA_NS0ID_TRIPALARMTYPE_SUPPRESSEDORSHELVED = 10863

const UA_NS0ID_TRIPALARMTYPE_MAXTIMESHELVED = 10864

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE = 11093

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_EVENTID = 11094

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_EVENTTYPE = 11095

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_SOURCENODE = 11096

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_SOURCENAME = 11097

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_TIME = 11098

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_RECEIVETIME = 11099

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_LOCALTIME = 11100

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_MESSAGE = 11101

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_SEVERITY = 11102

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_ACTIONTIMESTAMP = 11103

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_STATUS = 11104

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_SERVERID = 11105

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_CLIENTAUDITENTRYID = 11106

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_CLIENTUSERID = 11107

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_METHODID = 11108

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_INPUTARGUMENTS = 11109

const UA_NS0ID_TWOSTATEVARIABLETYPE_TRUESTATE = 11110

const UA_NS0ID_TWOSTATEVARIABLETYPE_FALSESTATE = 11111

const UA_NS0ID_CONDITIONTYPE_CONDITIONCLASSID = 11112

const UA_NS0ID_CONDITIONTYPE_CONDITIONCLASSNAME = 11113

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONCLASSID = 11114

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONCLASSNAME = 11115

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONCLASSID = 11116

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONCLASSNAME = 11117

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONCLASSID = 11118

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONCLASSNAME = 11119

const UA_NS0ID_ALARMCONDITIONTYPE_INPUTNODE = 11120

const UA_NS0ID_LIMITALARMTYPE_CONDITIONCLASSID = 11121

const UA_NS0ID_LIMITALARMTYPE_CONDITIONCLASSNAME = 11122

const UA_NS0ID_LIMITALARMTYPE_INPUTNODE = 11123

const UA_NS0ID_LIMITALARMTYPE_HIGHHIGHLIMIT = 11124

const UA_NS0ID_LIMITALARMTYPE_HIGHLIMIT = 11125

const UA_NS0ID_LIMITALARMTYPE_LOWLIMIT = 11126

const UA_NS0ID_LIMITALARMTYPE_LOWLOWLIMIT = 11127

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONCLASSID = 11128

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONCLASSNAME = 11129

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_INPUTNODE = 11130

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONCLASSID = 11131

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONCLASSNAME = 11132

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_INPUTNODE = 11133

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONCLASSID = 11134

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONCLASSNAME = 11135

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_INPUTNODE = 11136

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONCLASSID = 11137

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONCLASSNAME = 11138

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_INPUTNODE = 11139

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONCLASSID = 11140

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONCLASSNAME = 11141

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_INPUTNODE = 11142

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONCLASSID = 11143

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONCLASSNAME = 11144

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_INPUTNODE = 11145

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONCLASSID = 11146

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONCLASSNAME = 11147

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_INPUTNODE = 11148

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONCLASSID = 11149

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONCLASSNAME = 11150

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_INPUTNODE = 11151

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONCLASSID = 11152

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONCLASSNAME = 11153

const UA_NS0ID_DISCRETEALARMTYPE_INPUTNODE = 11154

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONCLASSID = 11155

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONCLASSNAME = 11156

const UA_NS0ID_OFFNORMALALARMTYPE_INPUTNODE = 11157

const UA_NS0ID_OFFNORMALALARMTYPE_NORMALSTATE = 11158

const UA_NS0ID_TRIPALARMTYPE_CONDITIONCLASSID = 11159

const UA_NS0ID_TRIPALARMTYPE_CONDITIONCLASSNAME = 11160

const UA_NS0ID_TRIPALARMTYPE_INPUTNODE = 11161

const UA_NS0ID_TRIPALARMTYPE_NORMALSTATE = 11162

const UA_NS0ID_BASECONDITIONCLASSTYPE = 11163

const UA_NS0ID_PROCESSCONDITIONCLASSTYPE = 11164

const UA_NS0ID_MAINTENANCECONDITIONCLASSTYPE = 11165

const UA_NS0ID_SYSTEMCONDITIONCLASSTYPE = 11166

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_AGGREGATECONFIGURATION_TREATUNCERTAINASBAD = 11168

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_AGGREGATECONFIGURATION_PERCENTDATABAD = 11169

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_AGGREGATECONFIGURATION_PERCENTDATAGOOD = 11170

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_AGGREGATECONFIGURATION_USESLOPEDEXTRAPOLATION = 11171

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_AGGREGATEFUNCTIONS = 11172

const UA_NS0ID_AGGREGATECONFIGURATIONTYPE = 11187

const UA_NS0ID_AGGREGATECONFIGURATIONTYPE_TREATUNCERTAINASBAD = 11188

const UA_NS0ID_AGGREGATECONFIGURATIONTYPE_PERCENTDATABAD = 11189

const UA_NS0ID_AGGREGATECONFIGURATIONTYPE_PERCENTDATAGOOD = 11190

const UA_NS0ID_AGGREGATECONFIGURATIONTYPE_USESLOPEDEXTRAPOLATION = 11191

const UA_NS0ID_HISTORYSERVERCAPABILITIES = 11192

const UA_NS0ID_HISTORYSERVERCAPABILITIES_ACCESSHISTORYDATACAPABILITY = 11193

const UA_NS0ID_HISTORYSERVERCAPABILITIES_INSERTDATACAPABILITY = 11196

const UA_NS0ID_HISTORYSERVERCAPABILITIES_REPLACEDATACAPABILITY = 11197

const UA_NS0ID_HISTORYSERVERCAPABILITIES_UPDATEDATACAPABILITY = 11198

const UA_NS0ID_HISTORYSERVERCAPABILITIES_DELETERAWCAPABILITY = 11199

const UA_NS0ID_HISTORYSERVERCAPABILITIES_DELETEATTIMECAPABILITY = 11200

const UA_NS0ID_HISTORYSERVERCAPABILITIES_AGGREGATEFUNCTIONS = 11201

const UA_NS0ID_HACONFIGURATION = 11202

const UA_NS0ID_HACONFIGURATION_AGGREGATECONFIGURATION = 11203

const UA_NS0ID_HACONFIGURATION_AGGREGATECONFIGURATION_TREATUNCERTAINASBAD = 11204

const UA_NS0ID_HACONFIGURATION_AGGREGATECONFIGURATION_PERCENTDATABAD = 11205

const UA_NS0ID_HACONFIGURATION_AGGREGATECONFIGURATION_PERCENTDATAGOOD = 11206

const UA_NS0ID_HACONFIGURATION_AGGREGATECONFIGURATION_USESLOPEDEXTRAPOLATION = 11207

const UA_NS0ID_HACONFIGURATION_STEPPED = 11208

const UA_NS0ID_HACONFIGURATION_DEFINITION = 11209

const UA_NS0ID_HACONFIGURATION_MAXTIMEINTERVAL = 11210

const UA_NS0ID_HACONFIGURATION_MINTIMEINTERVAL = 11211

const UA_NS0ID_HACONFIGURATION_EXCEPTIONDEVIATION = 11212

const UA_NS0ID_HACONFIGURATION_EXCEPTIONDEVIATIONFORMAT = 11213

const UA_NS0ID_ANNOTATIONS = 11214

const UA_NS0ID_HISTORICALEVENTFILTER = 11215

const UA_NS0ID_MODIFICATIONINFO = 11216

const UA_NS0ID_HISTORYMODIFIEDDATA = 11217

const UA_NS0ID_MODIFICATIONINFO_ENCODING_DEFAULTXML = 11218

const UA_NS0ID_HISTORYMODIFIEDDATA_ENCODING_DEFAULTXML = 11219

const UA_NS0ID_MODIFICATIONINFO_ENCODING_DEFAULTBINARY = 11226

const UA_NS0ID_HISTORYMODIFIEDDATA_ENCODING_DEFAULTBINARY = 11227

const UA_NS0ID_HISTORYUPDATETYPE = 11234

const UA_NS0ID_MULTISTATEVALUEDISCRETETYPE = 11238

const UA_NS0ID_MULTISTATEVALUEDISCRETETYPE_DEFINITION = 11239

const UA_NS0ID_MULTISTATEVALUEDISCRETETYPE_VALUEPRECISION = 11240

const UA_NS0ID_MULTISTATEVALUEDISCRETETYPE_ENUMVALUES = 11241

const UA_NS0ID_HISTORYSERVERCAPABILITIES_ACCESSHISTORYEVENTSCAPABILITY = 11242

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_MAXRETURNDATAVALUES = 11268

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_MAXRETURNEVENTVALUES = 11269

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_INSERTANNOTATIONCAPABILITY = 11270

const UA_NS0ID_HISTORYSERVERCAPABILITIES_MAXRETURNDATAVALUES = 11273

const UA_NS0ID_HISTORYSERVERCAPABILITIES_MAXRETURNEVENTVALUES = 11274

const UA_NS0ID_HISTORYSERVERCAPABILITIES_INSERTANNOTATIONCAPABILITY = 11275

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_INSERTEVENTCAPABILITY = 11278

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_REPLACEEVENTCAPABILITY = 11279

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_UPDATEEVENTCAPABILITY = 11280

const UA_NS0ID_HISTORYSERVERCAPABILITIES_INSERTEVENTCAPABILITY = 11281

const UA_NS0ID_HISTORYSERVERCAPABILITIES_REPLACEEVENTCAPABILITY = 11282

const UA_NS0ID_HISTORYSERVERCAPABILITIES_UPDATEEVENTCAPABILITY = 11283

const UA_NS0ID_AGGREGATEFUNCTION_TIMEAVERAGE2 = 11285

const UA_NS0ID_AGGREGATEFUNCTION_MINIMUM2 = 11286

const UA_NS0ID_AGGREGATEFUNCTION_MAXIMUM2 = 11287

const UA_NS0ID_AGGREGATEFUNCTION_RANGE2 = 11288

const UA_NS0ID_AGGREGATEFUNCTION_WORSTQUALITY2 = 11292

const UA_NS0ID_PERFORMUPDATETYPE = 11293

const UA_NS0ID_UPDATESTRUCTUREDATADETAILS = 11295

const UA_NS0ID_UPDATESTRUCTUREDATADETAILS_ENCODING_DEFAULTXML = 11296

const UA_NS0ID_UPDATESTRUCTUREDATADETAILS_ENCODING_DEFAULTBINARY = 11300

const UA_NS0ID_AGGREGATEFUNCTION_TOTAL2 = 11304

const UA_NS0ID_AGGREGATEFUNCTION_MINIMUMACTUALTIME2 = 11305

const UA_NS0ID_AGGREGATEFUNCTION_MAXIMUMACTUALTIME2 = 11306

const UA_NS0ID_AGGREGATEFUNCTION_DURATIONINSTATEZERO = 11307

const UA_NS0ID_AGGREGATEFUNCTION_DURATIONINSTATENONZERO = 11308

const UA_NS0ID_SERVER_SERVERREDUNDANCY_CURRENTSERVERID = 11312

const UA_NS0ID_SERVER_SERVERREDUNDANCY_REDUNDANTSERVERARRAY = 11313

const UA_NS0ID_SERVER_SERVERREDUNDANCY_SERVERURIARRAY = 11314

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVEDTOTIMEDSHELVED_TRANSITIONNUMBER = 11322

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_UNSHELVEDTOONESHOTSHELVED_TRANSITIONNUMBER = 11323

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVEDTOUNSHELVED_TRANSITIONNUMBER = 11324

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_TIMEDSHELVEDTOONESHOTSHELVED_TRANSITIONNUMBER = 11325

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVEDTOUNSHELVED_TRANSITIONNUMBER = 11326

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_ONESHOTSHELVEDTOTIMEDSHELVED_TRANSITIONNUMBER = 11327

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOWLOWTOLOW_TRANSITIONNUMBER = 11340

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LOWTOLOWLOW_TRANSITIONNUMBER = 11341

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGHHIGHTOHIGH_TRANSITIONNUMBER = 11342

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_HIGHTOHIGHHIGH_TRANSITIONNUMBER = 11343

const UA_NS0ID_AGGREGATEFUNCTION_STANDARDDEVIATIONSAMPLE = 11426

const UA_NS0ID_AGGREGATEFUNCTION_STANDARDDEVIATIONPOPULATION = 11427

const UA_NS0ID_AGGREGATEFUNCTION_VARIANCESAMPLE = 11428

const UA_NS0ID_AGGREGATEFUNCTION_VARIANCEPOPULATION = 11429

const UA_NS0ID_ENUMSTRINGS = 11432

const UA_NS0ID_VALUEASTEXT = 11433

const UA_NS0ID_PROGRESSEVENTTYPE = 11436

const UA_NS0ID_PROGRESSEVENTTYPE_EVENTID = 11437

const UA_NS0ID_PROGRESSEVENTTYPE_EVENTTYPE = 11438

const UA_NS0ID_PROGRESSEVENTTYPE_SOURCENODE = 11439

const UA_NS0ID_PROGRESSEVENTTYPE_SOURCENAME = 11440

const UA_NS0ID_PROGRESSEVENTTYPE_TIME = 11441

const UA_NS0ID_PROGRESSEVENTTYPE_RECEIVETIME = 11442

const UA_NS0ID_PROGRESSEVENTTYPE_LOCALTIME = 11443

const UA_NS0ID_PROGRESSEVENTTYPE_MESSAGE = 11444

const UA_NS0ID_PROGRESSEVENTTYPE_SEVERITY = 11445

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE = 11446

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_EVENTID = 11447

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_EVENTTYPE = 11448

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_SOURCENODE = 11449

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_SOURCENAME = 11450

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_TIME = 11451

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_RECEIVETIME = 11452

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_LOCALTIME = 11453

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_MESSAGE = 11454

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_SEVERITY = 11455

const UA_NS0ID_TRANSITIONVARIABLETYPE_EFFECTIVETRANSITIONTIME = 11456

const UA_NS0ID_FINITETRANSITIONVARIABLETYPE_EFFECTIVETRANSITIONTIME = 11457

const UA_NS0ID_STATEMACHINETYPE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11458

const UA_NS0ID_FINITESTATEMACHINETYPE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11459

const UA_NS0ID_TRANSITIONEVENTTYPE_TRANSITION_EFFECTIVETRANSITIONTIME = 11460

const UA_NS0ID_MULTISTATEVALUEDISCRETETYPE_VALUEASTEXT = 11461

const UA_NS0ID_PROGRAMTRANSITIONEVENTTYPE_TRANSITION_EFFECTIVETRANSITIONTIME = 11462

const UA_NS0ID_PROGRAMTRANSITIONAUDITEVENTTYPE_TRANSITION_EFFECTIVETRANSITIONTIME = 11463

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11464

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11465

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11466

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11467

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11468

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11469

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11470

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11471

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11472

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11473

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11474

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11475

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11476

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11477

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11478

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11479

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11480

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11481

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11482

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11483

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_SECURECHANNELID = 11485

const UA_NS0ID_OPTIONSETTYPE = 11487

const UA_NS0ID_OPTIONSETTYPE_OPTIONSETVALUES = 11488

const UA_NS0ID_SERVERTYPE_GETMONITOREDITEMS = 11489

const UA_NS0ID_SERVERTYPE_GETMONITOREDITEMS_INPUTARGUMENTS = 11490

const UA_NS0ID_SERVERTYPE_GETMONITOREDITEMS_OUTPUTARGUMENTS = 11491

const UA_NS0ID_SERVER_GETMONITOREDITEMS = 11492

const UA_NS0ID_SERVER_GETMONITOREDITEMS_INPUTARGUMENTS = 11493

const UA_NS0ID_SERVER_GETMONITOREDITEMS_OUTPUTARGUMENTS = 11494

const UA_NS0ID_GETMONITOREDITEMSMETHODTYPE = 11495

const UA_NS0ID_GETMONITOREDITEMSMETHODTYPE_INPUTARGUMENTS = 11496

const UA_NS0ID_GETMONITOREDITEMSMETHODTYPE_OUTPUTARGUMENTS = 11497

const UA_NS0ID_MAXSTRINGLENGTH = 11498

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_STARTOFARCHIVE = 11499

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_STARTOFONLINEARCHIVE = 11500

const UA_NS0ID_HISTORYSERVERCAPABILITIESTYPE_DELETEEVENTCAPABILITY = 11501

const UA_NS0ID_HISTORYSERVERCAPABILITIES_DELETEEVENTCAPABILITY = 11502

const UA_NS0ID_HACONFIGURATION_STARTOFARCHIVE = 11503

const UA_NS0ID_HACONFIGURATION_STARTOFONLINEARCHIVE = 11504

const UA_NS0ID_AGGREGATEFUNCTION_STARTBOUND = 11505

const UA_NS0ID_AGGREGATEFUNCTION_ENDBOUND = 11506

const UA_NS0ID_AGGREGATEFUNCTION_DELTABOUNDS = 11507

const UA_NS0ID_MODELLINGRULE_OPTIONALPLACEHOLDER = 11508

const UA_NS0ID_MODELLINGRULE_OPTIONALPLACEHOLDER_NAMINGRULE = 11509

const UA_NS0ID_MODELLINGRULE_MANDATORYPLACEHOLDER = 11510

const UA_NS0ID_MODELLINGRULE_MANDATORYPLACEHOLDER_NAMINGRULE = 11511

const UA_NS0ID_MAXARRAYLENGTH = 11512

const UA_NS0ID_ENGINEERINGUNITS = 11513

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MAXARRAYLENGTH = 11514

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MAXSTRINGLENGTH = 11515

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS = 11516

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERREAD = 11517

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERWRITE = 11519

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERMETHODCALL = 11521

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERBROWSE = 11522

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERREGISTERNODES = 11523

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERTRANSLATEBROWSEPATHSTONODEIDS = 11524

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERNODEMANAGEMENT = 11525

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXMONITOREDITEMSPERCALL = 11526

const UA_NS0ID_SERVERTYPE_NAMESPACES = 11527

const UA_NS0ID_SERVERCAPABILITIESTYPE_MAXARRAYLENGTH = 11549

const UA_NS0ID_SERVERCAPABILITIESTYPE_MAXSTRINGLENGTH = 11550

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS = 11551

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERREAD = 11552

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERWRITE = 11554

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERMETHODCALL = 11556

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERBROWSE = 11557

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERREGISTERNODES = 11558

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERTRANSLATEBROWSEPATHSTONODEIDS = 11559

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERNODEMANAGEMENT = 11560

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXMONITOREDITEMSPERCALL = 11561

const UA_NS0ID_SERVERCAPABILITIESTYPE_VENDORCAPABILITY_PLACEHOLDER = 11562

const UA_NS0ID_OPERATIONLIMITSTYPE = 11564

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERREAD = 11565

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERWRITE = 11567

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERMETHODCALL = 11569

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERBROWSE = 11570

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERREGISTERNODES = 11571

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERTRANSLATEBROWSEPATHSTONODEIDS = 11572

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERNODEMANAGEMENT = 11573

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXMONITOREDITEMSPERCALL = 11574

const UA_NS0ID_FILETYPE = 11575

const UA_NS0ID_FILETYPE_SIZE = 11576

const UA_NS0ID_FILETYPE_OPENCOUNT = 11579

const UA_NS0ID_FILETYPE_OPEN = 11580

const UA_NS0ID_FILETYPE_OPEN_INPUTARGUMENTS = 11581

const UA_NS0ID_FILETYPE_OPEN_OUTPUTARGUMENTS = 11582

const UA_NS0ID_FILETYPE_CLOSE = 11583

const UA_NS0ID_FILETYPE_CLOSE_INPUTARGUMENTS = 11584

const UA_NS0ID_FILETYPE_READ = 11585

const UA_NS0ID_FILETYPE_READ_INPUTARGUMENTS = 11586

const UA_NS0ID_FILETYPE_READ_OUTPUTARGUMENTS = 11587

const UA_NS0ID_FILETYPE_WRITE = 11588

const UA_NS0ID_FILETYPE_WRITE_INPUTARGUMENTS = 11589

const UA_NS0ID_FILETYPE_GETPOSITION = 11590

const UA_NS0ID_FILETYPE_GETPOSITION_INPUTARGUMENTS = 11591

const UA_NS0ID_FILETYPE_GETPOSITION_OUTPUTARGUMENTS = 11592

const UA_NS0ID_FILETYPE_SETPOSITION = 11593

const UA_NS0ID_FILETYPE_SETPOSITION_INPUTARGUMENTS = 11594

const UA_NS0ID_ADDRESSSPACEFILETYPE = 11595

const UA_NS0ID_ADDRESSSPACEFILETYPE_SIZE = 11596

const UA_NS0ID_ADDRESSSPACEFILETYPE_OPENCOUNT = 11599

const UA_NS0ID_ADDRESSSPACEFILETYPE_OPEN = 11600

const UA_NS0ID_ADDRESSSPACEFILETYPE_OPEN_INPUTARGUMENTS = 11601

const UA_NS0ID_ADDRESSSPACEFILETYPE_OPEN_OUTPUTARGUMENTS = 11602

const UA_NS0ID_ADDRESSSPACEFILETYPE_CLOSE = 11603

const UA_NS0ID_ADDRESSSPACEFILETYPE_CLOSE_INPUTARGUMENTS = 11604

const UA_NS0ID_ADDRESSSPACEFILETYPE_READ = 11605

const UA_NS0ID_ADDRESSSPACEFILETYPE_READ_INPUTARGUMENTS = 11606

const UA_NS0ID_ADDRESSSPACEFILETYPE_READ_OUTPUTARGUMENTS = 11607

const UA_NS0ID_ADDRESSSPACEFILETYPE_WRITE = 11608

const UA_NS0ID_ADDRESSSPACEFILETYPE_WRITE_INPUTARGUMENTS = 11609

const UA_NS0ID_ADDRESSSPACEFILETYPE_GETPOSITION = 11610

const UA_NS0ID_ADDRESSSPACEFILETYPE_GETPOSITION_INPUTARGUMENTS = 11611

const UA_NS0ID_ADDRESSSPACEFILETYPE_GETPOSITION_OUTPUTARGUMENTS = 11612

const UA_NS0ID_ADDRESSSPACEFILETYPE_SETPOSITION = 11613

const UA_NS0ID_ADDRESSSPACEFILETYPE_SETPOSITION_INPUTARGUMENTS = 11614

const UA_NS0ID_ADDRESSSPACEFILETYPE_EXPORTNAMESPACE = 11615

const UA_NS0ID_NAMESPACEMETADATATYPE = 11616

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEURI = 11617

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEVERSION = 11618

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEPUBLICATIONDATE = 11619

const UA_NS0ID_NAMESPACEMETADATATYPE_ISNAMESPACESUBSET = 11620

const UA_NS0ID_NAMESPACEMETADATATYPE_STATICNODEIDTYPES = 11621

const UA_NS0ID_NAMESPACEMETADATATYPE_STATICNUMERICNODEIDRANGE = 11622

const UA_NS0ID_NAMESPACEMETADATATYPE_STATICSTRINGNODEIDPATTERN = 11623

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE = 11624

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_SIZE = 11625

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_OPENCOUNT = 11628

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_OPEN = 11629

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_OPEN_INPUTARGUMENTS = 11630

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_OPEN_OUTPUTARGUMENTS = 11631

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_CLOSE = 11632

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_CLOSE_INPUTARGUMENTS = 11633

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_READ = 11634

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_READ_INPUTARGUMENTS = 11635

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_READ_OUTPUTARGUMENTS = 11636

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_WRITE = 11637

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_WRITE_INPUTARGUMENTS = 11638

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_GETPOSITION = 11639

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_GETPOSITION_INPUTARGUMENTS = 11640

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_GETPOSITION_OUTPUTARGUMENTS = 11641

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_SETPOSITION = 11642

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_SETPOSITION_INPUTARGUMENTS = 11643

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_EXPORTNAMESPACE = 11644

const UA_NS0ID_NAMESPACESTYPE = 11645

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER = 11646

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEURI = 11647

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEVERSION = 11648

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEPUBLICATIONDATE = 11649

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_ISNAMESPACESUBSET = 11650

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_STATICNODEIDTYPES = 11651

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_STATICNUMERICNODEIDRANGE = 11652

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_STATICSTRINGNODEIDPATTERN = 11653

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE = 11654

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_SIZE = 11655

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_OPENCOUNT = 11658

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_OPEN = 11659

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_OPEN_INPUTARGUMENTS = 11660

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_OPEN_OUTPUTARGUMENTS = 11661

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_CLOSE = 11662

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_CLOSE_INPUTARGUMENTS = 11663

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_READ = 11664

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_READ_INPUTARGUMENTS = 11665

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_READ_OUTPUTARGUMENTS = 11666

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_WRITE = 11667

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_WRITE_INPUTARGUMENTS = 11668

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_GETPOSITION = 11669

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_GETPOSITION_INPUTARGUMENTS = 11670

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_GETPOSITION_OUTPUTARGUMENTS = 11671

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_SETPOSITION = 11672

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_SETPOSITION_INPUTARGUMENTS = 11673

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_EXPORTNAMESPACE = 11674

const UA_NS0ID_SYSTEMSTATUSCHANGEEVENTTYPE_SYSTEMSTATE = 11696

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSTYPE_SAMPLEDMONITOREDITEMSCOUNT = 11697

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSTYPE_MAXSAMPLEDMONITOREDITEMSCOUNT = 11698

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSTYPE_DISABLEDMONITOREDITEMSSAMPLINGCOUNT = 11699

const UA_NS0ID_OPTIONSETTYPE_BITMASK = 11701

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MAXARRAYLENGTH = 11702

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MAXSTRINGLENGTH = 11703

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS = 11704

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERREAD = 11705

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERWRITE = 11707

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERMETHODCALL = 11709

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERBROWSE = 11710

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERREGISTERNODES = 11711

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERTRANSLATEBROWSEPATHSTONODEIDS = 11712

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERNODEMANAGEMENT = 11713

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXMONITOREDITEMSPERCALL = 11714

const UA_NS0ID_SERVER_NAMESPACES = 11715

const UA_NS0ID_BITFIELDMASKDATATYPE = 11737

const UA_NS0ID_OPENMETHODTYPE = 11738

const UA_NS0ID_OPENMETHODTYPE_INPUTARGUMENTS = 11739

const UA_NS0ID_OPENMETHODTYPE_OUTPUTARGUMENTS = 11740

const UA_NS0ID_CLOSEMETHODTYPE = 11741

const UA_NS0ID_CLOSEMETHODTYPE_INPUTARGUMENTS = 11742

const UA_NS0ID_READMETHODTYPE = 11743

const UA_NS0ID_READMETHODTYPE_INPUTARGUMENTS = 11744

const UA_NS0ID_READMETHODTYPE_OUTPUTARGUMENTS = 11745

const UA_NS0ID_WRITEMETHODTYPE = 11746

const UA_NS0ID_WRITEMETHODTYPE_INPUTARGUMENTS = 11747

const UA_NS0ID_GETPOSITIONMETHODTYPE = 11748

const UA_NS0ID_GETPOSITIONMETHODTYPE_INPUTARGUMENTS = 11749

const UA_NS0ID_GETPOSITIONMETHODTYPE_OUTPUTARGUMENTS = 11750

const UA_NS0ID_SETPOSITIONMETHODTYPE = 11751

const UA_NS0ID_SETPOSITIONMETHODTYPE_INPUTARGUMENTS = 11752

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE = 11753

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_EVENTID = 11754

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_EVENTTYPE = 11755

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SOURCENODE = 11756

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SOURCENAME = 11757

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_TIME = 11758

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_RECEIVETIME = 11759

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LOCALTIME = 11760

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_MESSAGE = 11761

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SEVERITY = 11762

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONCLASSID = 11763

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONCLASSNAME = 11764

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONNAME = 11765

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_BRANCHID = 11766

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_RETAIN = 11767

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE = 11768

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_ID = 11769

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_NAME = 11770

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_NUMBER = 11771

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 11772

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 11773

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 11774

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_TRUESTATE = 11775

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLEDSTATE_FALSESTATE = 11776

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_QUALITY = 11777

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_QUALITY_SOURCETIMESTAMP = 11778

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LASTSEVERITY = 11779

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 11780

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_COMMENT = 11781

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_COMMENT_SOURCETIMESTAMP = 11782

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CLIENTUSERID = 11783

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_DISABLE = 11784

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ENABLE = 11785

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ADDCOMMENT = 11786

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 11787

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONREFRESH = 11788

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 11789

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE = 11790

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_ID = 11791

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_NAME = 11792

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_NUMBER = 11793

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 11794

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 11795

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 11796

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_TRUESTATE = 11797

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKEDSTATE_FALSESTATE = 11798

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE = 11799

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_ID = 11800

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_NAME = 11801

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_NUMBER = 11802

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 11803

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 11804

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 11805

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 11806

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 11807

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKNOWLEDGE = 11808

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 11809

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRM = 11810

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONFIRM_INPUTARGUMENTS = 11811

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE = 11812

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_ID = 11813

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_NAME = 11814

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_NUMBER = 11815

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 11816

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 11817

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 11818

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_TRUESTATE = 11819

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ACTIVESTATE_FALSESTATE = 11820

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_INPUTNODE = 11821

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE = 11822

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_ID = 11823

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_NAME = 11824

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_NUMBER = 11825

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 11826

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 11827

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 11828

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 11829

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 11830

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE = 11831

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 11832

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 11833

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 11834

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 11835

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 11836

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 11837

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 11838

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 11839

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 11840

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 11841

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 11842

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 11843

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_UNSHELVE = 11844

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 11845

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 11846

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 11847

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESSEDORSHELVED = 11848

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_MAXTIMESHELVED = 11849

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_NORMALSTATE = 11850

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_COMMENT = 11851

const UA_NS0ID_AUDITCONDITIONRESPONDEVENTTYPE_SELECTEDRESPONSE = 11852

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_COMMENT = 11853

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_COMMENT = 11854

const UA_NS0ID_AUDITCONDITIONSHELVINGEVENTTYPE_SHELVINGTIME = 11855

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE = 11856

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_EVENTID = 11857

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_EVENTTYPE = 11858

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_SOURCENODE = 11859

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_SOURCENAME = 11860

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_TIME = 11861

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_RECEIVETIME = 11862

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_LOCALTIME = 11863

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_MESSAGE = 11864

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_SEVERITY = 11865

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_ACTIONTIMESTAMP = 11866

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_STATUS = 11867

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_SERVERID = 11868

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_CLIENTAUDITENTRYID = 11869

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_CLIENTUSERID = 11870

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_METHODID = 11871

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_INPUTARGUMENTS = 11872

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_OLDSTATEID = 11873

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_NEWSTATEID = 11874

const UA_NS0ID_AUDITPROGRAMTRANSITIONEVENTTYPE_TRANSITIONNUMBER = 11875

const UA_NS0ID_HISTORICALDATACONFIGURATIONTYPE_AGGREGATEFUNCTIONS = 11876

const UA_NS0ID_HACONFIGURATION_AGGREGATEFUNCTIONS = 11877

const UA_NS0ID_NODECLASS_ENUMVALUES = 11878

const UA_NS0ID_INSTANCENODE = 11879

const UA_NS0ID_TYPENODE = 11880

const UA_NS0ID_NODEATTRIBUTESMASK_ENUMVALUES = 11881

const UA_NS0ID_BROWSERESULTMASK_ENUMVALUES = 11883

const UA_NS0ID_HISTORYUPDATETYPE_ENUMVALUES = 11884

const UA_NS0ID_PERFORMUPDATETYPE_ENUMVALUES = 11885

const UA_NS0ID_INSTANCENODE_ENCODING_DEFAULTXML = 11887

const UA_NS0ID_TYPENODE_ENCODING_DEFAULTXML = 11888

const UA_NS0ID_INSTANCENODE_ENCODING_DEFAULTBINARY = 11889

const UA_NS0ID_TYPENODE_ENCODING_DEFAULTBINARY = 11890

const UA_NS0ID_SESSIONDIAGNOSTICSOBJECTTYPE_SESSIONDIAGNOSTICS_UNAUTHORIZEDREQUESTCOUNT = 11891

const UA_NS0ID_SESSIONDIAGNOSTICSVARIABLETYPE_UNAUTHORIZEDREQUESTCOUNT = 11892

const UA_NS0ID_OPENFILEMODE = 11939

const UA_NS0ID_OPENFILEMODE_ENUMVALUES = 11940

const UA_NS0ID_MODELCHANGESTRUCTUREVERBMASK = 11941

const UA_NS0ID_MODELCHANGESTRUCTUREVERBMASK_ENUMVALUES = 11942

const UA_NS0ID_ENDPOINTURLLISTDATATYPE = 11943

const UA_NS0ID_NETWORKGROUPDATATYPE = 11944

const UA_NS0ID_NONTRANSPARENTNETWORKREDUNDANCYTYPE = 11945

const UA_NS0ID_NONTRANSPARENTNETWORKREDUNDANCYTYPE_REDUNDANCYSUPPORT = 11946

const UA_NS0ID_NONTRANSPARENTNETWORKREDUNDANCYTYPE_SERVERURIARRAY = 11947

const UA_NS0ID_NONTRANSPARENTNETWORKREDUNDANCYTYPE_SERVERNETWORKGROUPS = 11948

const UA_NS0ID_ENDPOINTURLLISTDATATYPE_ENCODING_DEFAULTXML = 11949

const UA_NS0ID_NETWORKGROUPDATATYPE_ENCODING_DEFAULTXML = 11950

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTURLLISTDATATYPE = 11951

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTURLLISTDATATYPE_DATATYPEVERSION = 11952

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTURLLISTDATATYPE_DICTIONARYFRAGMENT = 11953

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKGROUPDATATYPE = 11954

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKGROUPDATATYPE_DATATYPEVERSION = 11955

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKGROUPDATATYPE_DICTIONARYFRAGMENT = 11956

const UA_NS0ID_ENDPOINTURLLISTDATATYPE_ENCODING_DEFAULTBINARY = 11957

const UA_NS0ID_NETWORKGROUPDATATYPE_ENCODING_DEFAULTBINARY = 11958

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTURLLISTDATATYPE = 11959

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTURLLISTDATATYPE_DATATYPEVERSION = 11960

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTURLLISTDATATYPE_DICTIONARYFRAGMENT = 11961

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKGROUPDATATYPE = 11962

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKGROUPDATATYPE_DATATYPEVERSION = 11963

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKGROUPDATATYPE_DICTIONARYFRAGMENT = 11964

const UA_NS0ID_ARRAYITEMTYPE = 12021

const UA_NS0ID_ARRAYITEMTYPE_DEFINITION = 12022

const UA_NS0ID_ARRAYITEMTYPE_VALUEPRECISION = 12023

const UA_NS0ID_ARRAYITEMTYPE_INSTRUMENTRANGE = 12024

const UA_NS0ID_ARRAYITEMTYPE_EURANGE = 12025

const UA_NS0ID_ARRAYITEMTYPE_ENGINEERINGUNITS = 12026

const UA_NS0ID_ARRAYITEMTYPE_TITLE = 12027

const UA_NS0ID_ARRAYITEMTYPE_AXISSCALETYPE = 12028

const UA_NS0ID_YARRAYITEMTYPE = 12029

const UA_NS0ID_YARRAYITEMTYPE_DEFINITION = 12030

const UA_NS0ID_YARRAYITEMTYPE_VALUEPRECISION = 12031

const UA_NS0ID_YARRAYITEMTYPE_INSTRUMENTRANGE = 12032

const UA_NS0ID_YARRAYITEMTYPE_EURANGE = 12033

const UA_NS0ID_YARRAYITEMTYPE_ENGINEERINGUNITS = 12034

const UA_NS0ID_YARRAYITEMTYPE_TITLE = 12035

const UA_NS0ID_YARRAYITEMTYPE_AXISSCALETYPE = 12036

const UA_NS0ID_YARRAYITEMTYPE_XAXISDEFINITION = 12037

const UA_NS0ID_XYARRAYITEMTYPE = 12038

const UA_NS0ID_XYARRAYITEMTYPE_DEFINITION = 12039

const UA_NS0ID_XYARRAYITEMTYPE_VALUEPRECISION = 12040

const UA_NS0ID_XYARRAYITEMTYPE_INSTRUMENTRANGE = 12041

const UA_NS0ID_XYARRAYITEMTYPE_EURANGE = 12042

const UA_NS0ID_XYARRAYITEMTYPE_ENGINEERINGUNITS = 12043

const UA_NS0ID_XYARRAYITEMTYPE_TITLE = 12044

const UA_NS0ID_XYARRAYITEMTYPE_AXISSCALETYPE = 12045

const UA_NS0ID_XYARRAYITEMTYPE_XAXISDEFINITION = 12046

const UA_NS0ID_IMAGEITEMTYPE = 12047

const UA_NS0ID_IMAGEITEMTYPE_DEFINITION = 12048

const UA_NS0ID_IMAGEITEMTYPE_VALUEPRECISION = 12049

const UA_NS0ID_IMAGEITEMTYPE_INSTRUMENTRANGE = 12050

const UA_NS0ID_IMAGEITEMTYPE_EURANGE = 12051

const UA_NS0ID_IMAGEITEMTYPE_ENGINEERINGUNITS = 12052

const UA_NS0ID_IMAGEITEMTYPE_TITLE = 12053

const UA_NS0ID_IMAGEITEMTYPE_AXISSCALETYPE = 12054

const UA_NS0ID_IMAGEITEMTYPE_XAXISDEFINITION = 12055

const UA_NS0ID_IMAGEITEMTYPE_YAXISDEFINITION = 12056

const UA_NS0ID_CUBEITEMTYPE = 12057

const UA_NS0ID_CUBEITEMTYPE_DEFINITION = 12058

const UA_NS0ID_CUBEITEMTYPE_VALUEPRECISION = 12059

const UA_NS0ID_CUBEITEMTYPE_INSTRUMENTRANGE = 12060

const UA_NS0ID_CUBEITEMTYPE_EURANGE = 12061

const UA_NS0ID_CUBEITEMTYPE_ENGINEERINGUNITS = 12062

const UA_NS0ID_CUBEITEMTYPE_TITLE = 12063

const UA_NS0ID_CUBEITEMTYPE_AXISSCALETYPE = 12064

const UA_NS0ID_CUBEITEMTYPE_XAXISDEFINITION = 12065

const UA_NS0ID_CUBEITEMTYPE_YAXISDEFINITION = 12066

const UA_NS0ID_CUBEITEMTYPE_ZAXISDEFINITION = 12067

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE = 12068

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_DEFINITION = 12069

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_VALUEPRECISION = 12070

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_INSTRUMENTRANGE = 12071

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_EURANGE = 12072

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_ENGINEERINGUNITS = 12073

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_TITLE = 12074

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_AXISSCALETYPE = 12075

const UA_NS0ID_NDIMENSIONARRAYITEMTYPE_AXISDEFINITION = 12076

const UA_NS0ID_AXISSCALEENUMERATION = 12077

const UA_NS0ID_AXISSCALEENUMERATION_ENUMSTRINGS = 12078

const UA_NS0ID_AXISINFORMATION = 12079

const UA_NS0ID_XVTYPE = 12080

const UA_NS0ID_AXISINFORMATION_ENCODING_DEFAULTXML = 12081

const UA_NS0ID_XVTYPE_ENCODING_DEFAULTXML = 12082

const UA_NS0ID_OPCUA_XMLSCHEMA_AXISINFORMATION = 12083

const UA_NS0ID_OPCUA_XMLSCHEMA_AXISINFORMATION_DATATYPEVERSION = 12084

const UA_NS0ID_OPCUA_XMLSCHEMA_AXISINFORMATION_DICTIONARYFRAGMENT = 12085

const UA_NS0ID_OPCUA_XMLSCHEMA_XVTYPE = 12086

const UA_NS0ID_OPCUA_XMLSCHEMA_XVTYPE_DATATYPEVERSION = 12087

const UA_NS0ID_OPCUA_XMLSCHEMA_XVTYPE_DICTIONARYFRAGMENT = 12088

const UA_NS0ID_AXISINFORMATION_ENCODING_DEFAULTBINARY = 12089

const UA_NS0ID_XVTYPE_ENCODING_DEFAULTBINARY = 12090

const UA_NS0ID_OPCUA_BINARYSCHEMA_AXISINFORMATION = 12091

const UA_NS0ID_OPCUA_BINARYSCHEMA_AXISINFORMATION_DATATYPEVERSION = 12092

const UA_NS0ID_OPCUA_BINARYSCHEMA_AXISINFORMATION_DICTIONARYFRAGMENT = 12093

const UA_NS0ID_OPCUA_BINARYSCHEMA_XVTYPE = 12094

const UA_NS0ID_OPCUA_BINARYSCHEMA_XVTYPE_DATATYPEVERSION = 12095

const UA_NS0ID_OPCUA_BINARYSCHEMA_XVTYPE_DICTIONARYFRAGMENT = 12096

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER = 12097

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS = 12098

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_SESSIONID = 12099

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_SESSIONNAME = 12100

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CLIENTDESCRIPTION = 12101

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_SERVERURI = 12102

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_ENDPOINTURL = 12103

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_LOCALEIDS = 12104

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_ACTUALSESSIONTIMEOUT = 12105

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_MAXRESPONSEMESSAGESIZE = 12106

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CLIENTCONNECTIONTIME = 12107

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CLIENTLASTCONTACTTIME = 12108

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CURRENTSUBSCRIPTIONSCOUNT = 12109

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CURRENTMONITOREDITEMSCOUNT = 12110

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CURRENTPUBLISHREQUESTSINQUEUE = 12111

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_TOTALREQUESTCOUNT = 12112

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_UNAUTHORIZEDREQUESTCOUNT = 12113

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_READCOUNT = 12114

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_HISTORYREADCOUNT = 12115

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_WRITECOUNT = 12116

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_HISTORYUPDATECOUNT = 12117

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CALLCOUNT = 12118

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CREATEMONITOREDITEMSCOUNT = 12119

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_MODIFYMONITOREDITEMSCOUNT = 12120

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_SETMONITORINGMODECOUNT = 12121

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_SETTRIGGERINGCOUNT = 12122

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_DELETEMONITOREDITEMSCOUNT = 12123

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_CREATESUBSCRIPTIONCOUNT = 12124

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_MODIFYSUBSCRIPTIONCOUNT = 12125

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_SETPUBLISHINGMODECOUNT = 12126

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_PUBLISHCOUNT = 12127

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_REPUBLISHCOUNT = 12128

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_TRANSFERSUBSCRIPTIONSCOUNT = 12129

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_DELETESUBSCRIPTIONSCOUNT = 12130

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_ADDNODESCOUNT = 12131

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_ADDREFERENCESCOUNT = 12132

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_DELETENODESCOUNT = 12133

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_DELETEREFERENCESCOUNT = 12134

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_BROWSECOUNT = 12135

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_BROWSENEXTCOUNT = 12136

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_TRANSLATEBROWSEPATHSTONODEIDSCOUNT = 12137

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_QUERYFIRSTCOUNT = 12138

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_QUERYNEXTCOUNT = 12139

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_REGISTERNODESCOUNT = 12140

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONDIAGNOSTICS_UNREGISTERNODESCOUNT = 12141

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS = 12142

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_SESSIONID = 12143

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_CLIENTUSERIDOFSESSION = 12144

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_CLIENTUSERIDHISTORY = 12145

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_AUTHENTICATIONMECHANISM = 12146

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_ENCODING = 12147

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_TRANSPORTPROTOCOL = 12148

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_SECURITYMODE = 12149

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_SECURITYPOLICYURI = 12150

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SESSIONSECURITYDIAGNOSTICS_CLIENTCERTIFICATE = 12151

const UA_NS0ID_SESSIONSDIAGNOSTICSSUMMARYTYPE_CLIENTNAME_PLACEHOLDER_SUBSCRIPTIONDIAGNOSTICSARRAY = 12152

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYREADDATA = 12153

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYREADEVENTS = 12154

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYUPDATEDATA = 12155

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYUPDATEEVENTS = 12156

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERHISTORYREADDATA = 12157

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERHISTORYREADEVENTS = 12158

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERHISTORYUPDATEDATA = 12159

const UA_NS0ID_SERVERCAPABILITIESTYPE_OPERATIONLIMITS_MAXNODESPERHISTORYUPDATEEVENTS = 12160

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERHISTORYREADDATA = 12161

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERHISTORYREADEVENTS = 12162

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERHISTORYUPDATEDATA = 12163

const UA_NS0ID_OPERATIONLIMITSTYPE_MAXNODESPERHISTORYUPDATEEVENTS = 12164

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYREADDATA = 12165

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYREADEVENTS = 12166

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYUPDATEDATA = 12167

const UA_NS0ID_SERVER_SERVERCAPABILITIES_OPERATIONLIMITS_MAXNODESPERHISTORYUPDATEEVENTS = 12168

const UA_NS0ID_NAMINGRULETYPE_ENUMVALUES = 12169

const UA_NS0ID_VIEWVERSION = 12170

const UA_NS0ID_COMPLEXNUMBERTYPE = 12171

const UA_NS0ID_DOUBLECOMPLEXNUMBERTYPE = 12172

const UA_NS0ID_COMPLEXNUMBERTYPE_ENCODING_DEFAULTXML = 12173

const UA_NS0ID_DOUBLECOMPLEXNUMBERTYPE_ENCODING_DEFAULTXML = 12174

const UA_NS0ID_OPCUA_XMLSCHEMA_COMPLEXNUMBERTYPE = 12175

const UA_NS0ID_OPCUA_XMLSCHEMA_COMPLEXNUMBERTYPE_DATATYPEVERSION = 12176

const UA_NS0ID_OPCUA_XMLSCHEMA_COMPLEXNUMBERTYPE_DICTIONARYFRAGMENT = 12177

const UA_NS0ID_OPCUA_XMLSCHEMA_DOUBLECOMPLEXNUMBERTYPE = 12178

const UA_NS0ID_OPCUA_XMLSCHEMA_DOUBLECOMPLEXNUMBERTYPE_DATATYPEVERSION = 12179

const UA_NS0ID_OPCUA_XMLSCHEMA_DOUBLECOMPLEXNUMBERTYPE_DICTIONARYFRAGMENT = 12180

const UA_NS0ID_COMPLEXNUMBERTYPE_ENCODING_DEFAULTBINARY = 12181

const UA_NS0ID_DOUBLECOMPLEXNUMBERTYPE_ENCODING_DEFAULTBINARY = 12182

const UA_NS0ID_OPCUA_BINARYSCHEMA_COMPLEXNUMBERTYPE = 12183

const UA_NS0ID_OPCUA_BINARYSCHEMA_COMPLEXNUMBERTYPE_DATATYPEVERSION = 12184

const UA_NS0ID_OPCUA_BINARYSCHEMA_COMPLEXNUMBERTYPE_DICTIONARYFRAGMENT = 12185

const UA_NS0ID_OPCUA_BINARYSCHEMA_DOUBLECOMPLEXNUMBERTYPE = 12186

const UA_NS0ID_OPCUA_BINARYSCHEMA_DOUBLECOMPLEXNUMBERTYPE_DATATYPEVERSION = 12187

const UA_NS0ID_OPCUA_BINARYSCHEMA_DOUBLECOMPLEXNUMBERTYPE_DICTIONARYFRAGMENT = 12188

const UA_NS0ID_SERVERONNETWORK = 12189

const UA_NS0ID_FINDSERVERSONNETWORKREQUEST = 12190

const UA_NS0ID_FINDSERVERSONNETWORKRESPONSE = 12191

const UA_NS0ID_REGISTERSERVER2REQUEST = 12193

const UA_NS0ID_REGISTERSERVER2RESPONSE = 12194

const UA_NS0ID_SERVERONNETWORK_ENCODING_DEFAULTXML = 12195

const UA_NS0ID_FINDSERVERSONNETWORKREQUEST_ENCODING_DEFAULTXML = 12196

const UA_NS0ID_FINDSERVERSONNETWORKRESPONSE_ENCODING_DEFAULTXML = 12197

const UA_NS0ID_REGISTERSERVER2REQUEST_ENCODING_DEFAULTXML = 12199

const UA_NS0ID_REGISTERSERVER2RESPONSE_ENCODING_DEFAULTXML = 12200

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERONNETWORK = 12201

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERONNETWORK_DATATYPEVERSION = 12202

const UA_NS0ID_OPCUA_XMLSCHEMA_SERVERONNETWORK_DICTIONARYFRAGMENT = 12203

const UA_NS0ID_SERVERONNETWORK_ENCODING_DEFAULTBINARY = 12207

const UA_NS0ID_FINDSERVERSONNETWORKREQUEST_ENCODING_DEFAULTBINARY = 12208

const UA_NS0ID_FINDSERVERSONNETWORKRESPONSE_ENCODING_DEFAULTBINARY = 12209

const UA_NS0ID_REGISTERSERVER2REQUEST_ENCODING_DEFAULTBINARY = 12211

const UA_NS0ID_REGISTERSERVER2RESPONSE_ENCODING_DEFAULTBINARY = 12212

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERONNETWORK = 12213

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERONNETWORK_DATATYPEVERSION = 12214

const UA_NS0ID_OPCUA_BINARYSCHEMA_SERVERONNETWORK_DICTIONARYFRAGMENT = 12215

const UA_NS0ID_PROGRESSEVENTTYPE_CONTEXT = 12502

const UA_NS0ID_PROGRESSEVENTTYPE_PROGRESS = 12503

const UA_NS0ID_OPENWITHMASKSMETHODTYPE = 12513

const UA_NS0ID_OPENWITHMASKSMETHODTYPE_INPUTARGUMENTS = 12514

const UA_NS0ID_OPENWITHMASKSMETHODTYPE_OUTPUTARGUMENTS = 12515

const UA_NS0ID_CLOSEANDUPDATEMETHODTYPE = 12516

const UA_NS0ID_CLOSEANDUPDATEMETHODTYPE_OUTPUTARGUMENTS = 12517

const UA_NS0ID_ADDCERTIFICATEMETHODTYPE = 12518

const UA_NS0ID_ADDCERTIFICATEMETHODTYPE_INPUTARGUMENTS = 12519

const UA_NS0ID_REMOVECERTIFICATEMETHODTYPE = 12520

const UA_NS0ID_REMOVECERTIFICATEMETHODTYPE_INPUTARGUMENTS = 12521

const UA_NS0ID_TRUSTLISTTYPE = 12522

const UA_NS0ID_TRUSTLISTTYPE_SIZE = 12523

const UA_NS0ID_TRUSTLISTTYPE_OPENCOUNT = 12526

const UA_NS0ID_TRUSTLISTTYPE_OPEN = 12527

const UA_NS0ID_TRUSTLISTTYPE_OPEN_INPUTARGUMENTS = 12528

const UA_NS0ID_TRUSTLISTTYPE_OPEN_OUTPUTARGUMENTS = 12529

const UA_NS0ID_TRUSTLISTTYPE_CLOSE = 12530

const UA_NS0ID_TRUSTLISTTYPE_CLOSE_INPUTARGUMENTS = 12531

const UA_NS0ID_TRUSTLISTTYPE_READ = 12532

const UA_NS0ID_TRUSTLISTTYPE_READ_INPUTARGUMENTS = 12533

const UA_NS0ID_TRUSTLISTTYPE_READ_OUTPUTARGUMENTS = 12534

const UA_NS0ID_TRUSTLISTTYPE_WRITE = 12535

const UA_NS0ID_TRUSTLISTTYPE_WRITE_INPUTARGUMENTS = 12536

const UA_NS0ID_TRUSTLISTTYPE_GETPOSITION = 12537

const UA_NS0ID_TRUSTLISTTYPE_GETPOSITION_INPUTARGUMENTS = 12538

const UA_NS0ID_TRUSTLISTTYPE_GETPOSITION_OUTPUTARGUMENTS = 12539

const UA_NS0ID_TRUSTLISTTYPE_SETPOSITION = 12540

const UA_NS0ID_TRUSTLISTTYPE_SETPOSITION_INPUTARGUMENTS = 12541

const UA_NS0ID_TRUSTLISTTYPE_LASTUPDATETIME = 12542

const UA_NS0ID_TRUSTLISTTYPE_OPENWITHMASKS = 12543

const UA_NS0ID_TRUSTLISTTYPE_OPENWITHMASKS_INPUTARGUMENTS = 12544

const UA_NS0ID_TRUSTLISTTYPE_OPENWITHMASKS_OUTPUTARGUMENTS = 12545

const UA_NS0ID_TRUSTLISTTYPE_CLOSEANDUPDATE = 12546

const UA_NS0ID_TRUSTLISTTYPE_CLOSEANDUPDATE_OUTPUTARGUMENTS = 12547

const UA_NS0ID_TRUSTLISTTYPE_ADDCERTIFICATE = 12548

const UA_NS0ID_TRUSTLISTTYPE_ADDCERTIFICATE_INPUTARGUMENTS = 12549

const UA_NS0ID_TRUSTLISTTYPE_REMOVECERTIFICATE = 12550

const UA_NS0ID_TRUSTLISTTYPE_REMOVECERTIFICATE_INPUTARGUMENTS = 12551

const UA_NS0ID_TRUSTLISTMASKS = 12552

const UA_NS0ID_TRUSTLISTMASKS_ENUMVALUES = 12553

const UA_NS0ID_TRUSTLISTDATATYPE = 12554

const UA_NS0ID_CERTIFICATEGROUPTYPE = 12555

const UA_NS0ID_CERTIFICATETYPE = 12556

const UA_NS0ID_APPLICATIONCERTIFICATETYPE = 12557

const UA_NS0ID_HTTPSCERTIFICATETYPE = 12558

const UA_NS0ID_RSAMINAPPLICATIONCERTIFICATETYPE = 12559

const UA_NS0ID_RSASHA256APPLICATIONCERTIFICATETYPE = 12560

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE = 12561

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_EVENTID = 12562

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_EVENTTYPE = 12563

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_SOURCENODE = 12564

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_SOURCENAME = 12565

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_TIME = 12566

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_RECEIVETIME = 12567

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_LOCALTIME = 12568

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_MESSAGE = 12569

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_SEVERITY = 12570

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_ACTIONTIMESTAMP = 12571

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_STATUS = 12572

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_SERVERID = 12573

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_CLIENTAUDITENTRYID = 12574

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_CLIENTUSERID = 12575

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_METHODID = 12576

const UA_NS0ID_TRUSTLISTUPDATEDAUDITEVENTTYPE_INPUTARGUMENTS = 12577

const UA_NS0ID_UPDATECERTIFICATEMETHODTYPE = 12578

const UA_NS0ID_UPDATECERTIFICATEMETHODTYPE_INPUTARGUMENTS = 12579

const UA_NS0ID_UPDATECERTIFICATEMETHODTYPE_OUTPUTARGUMENTS = 12580

const UA_NS0ID_SERVERCONFIGURATIONTYPE = 12581

const UA_NS0ID_SERVERCONFIGURATIONTYPE_SUPPORTEDPRIVATEKEYFORMATS = 12583

const UA_NS0ID_SERVERCONFIGURATIONTYPE_MAXTRUSTLISTSIZE = 12584

const UA_NS0ID_SERVERCONFIGURATIONTYPE_MULTICASTDNSENABLED = 12585

const UA_NS0ID_SERVERCONFIGURATIONTYPE_UPDATECERTIFICATE = 12616

const UA_NS0ID_SERVERCONFIGURATIONTYPE_UPDATECERTIFICATE_INPUTARGUMENTS = 12617

const UA_NS0ID_SERVERCONFIGURATIONTYPE_UPDATECERTIFICATE_OUTPUTARGUMENTS = 12618

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE = 12620

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_EVENTID = 12621

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_EVENTTYPE = 12622

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_SOURCENODE = 12623

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_SOURCENAME = 12624

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_TIME = 12625

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_RECEIVETIME = 12626

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_LOCALTIME = 12627

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_MESSAGE = 12628

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_SEVERITY = 12629

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_ACTIONTIMESTAMP = 12630

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_STATUS = 12631

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_SERVERID = 12632

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_CLIENTAUDITENTRYID = 12633

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_CLIENTUSERID = 12634

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_METHODID = 12635

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_INPUTARGUMENTS = 12636

const UA_NS0ID_SERVERCONFIGURATION = 12637

const UA_NS0ID_SERVERCONFIGURATION_SUPPORTEDPRIVATEKEYFORMATS = 12639

const UA_NS0ID_SERVERCONFIGURATION_MAXTRUSTLISTSIZE = 12640

const UA_NS0ID_SERVERCONFIGURATION_MULTICASTDNSENABLED = 12641

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST = 12642

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SIZE = 12643

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENCOUNT = 12646

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN = 12647

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 12648

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 12649

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSE = 12650

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 12651

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ = 12652

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 12653

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 12654

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITE = 12655

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 12656

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION = 12657

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 12658

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 12659

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SETPOSITION = 12660

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 12661

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_LASTUPDATETIME = 12662

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS = 12663

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 12664

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 12665

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE = 12666

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 12667

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_ADDCERTIFICATE = 12668

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 12669

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_REMOVECERTIFICATE = 12670

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 12671

const UA_NS0ID_TRUSTLISTDATATYPE_ENCODING_DEFAULTXML = 12676

const UA_NS0ID_OPCUA_XMLSCHEMA_TRUSTLISTDATATYPE = 12677

const UA_NS0ID_OPCUA_XMLSCHEMA_TRUSTLISTDATATYPE_DATATYPEVERSION = 12678

const UA_NS0ID_OPCUA_XMLSCHEMA_TRUSTLISTDATATYPE_DICTIONARYFRAGMENT = 12679

const UA_NS0ID_TRUSTLISTDATATYPE_ENCODING_DEFAULTBINARY = 12680

const UA_NS0ID_OPCUA_BINARYSCHEMA_TRUSTLISTDATATYPE = 12681

const UA_NS0ID_OPCUA_BINARYSCHEMA_TRUSTLISTDATATYPE_DATATYPEVERSION = 12682

const UA_NS0ID_OPCUA_BINARYSCHEMA_TRUSTLISTDATATYPE_DICTIONARYFRAGMENT = 12683

const UA_NS0ID_FILETYPE_WRITABLE = 12686

const UA_NS0ID_FILETYPE_USERWRITABLE = 12687

const UA_NS0ID_ADDRESSSPACEFILETYPE_WRITABLE = 12688

const UA_NS0ID_ADDRESSSPACEFILETYPE_USERWRITABLE = 12689

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_WRITABLE = 12690

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_USERWRITABLE = 12691

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_WRITABLE = 12692

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_USERWRITABLE = 12693

const UA_NS0ID_TRUSTLISTTYPE_WRITABLE = 12698

const UA_NS0ID_TRUSTLISTTYPE_USERWRITABLE = 12699

const UA_NS0ID_CLOSEANDUPDATEMETHODTYPE_INPUTARGUMENTS = 12704

const UA_NS0ID_TRUSTLISTTYPE_CLOSEANDUPDATE_INPUTARGUMENTS = 12705

const UA_NS0ID_SERVERCONFIGURATIONTYPE_SERVERCAPABILITIES = 12708

const UA_NS0ID_SERVERCONFIGURATION_SERVERCAPABILITIES = 12710

const UA_NS0ID_OPCUA_XMLSCHEMA_RELATIVEPATHELEMENT = 12712

const UA_NS0ID_OPCUA_XMLSCHEMA_RELATIVEPATHELEMENT_DATATYPEVERSION = 12713

const UA_NS0ID_OPCUA_XMLSCHEMA_RELATIVEPATHELEMENT_DICTIONARYFRAGMENT = 12714

const UA_NS0ID_OPCUA_XMLSCHEMA_RELATIVEPATH = 12715

const UA_NS0ID_OPCUA_XMLSCHEMA_RELATIVEPATH_DATATYPEVERSION = 12716

const UA_NS0ID_OPCUA_XMLSCHEMA_RELATIVEPATH_DICTIONARYFRAGMENT = 12717

const UA_NS0ID_OPCUA_BINARYSCHEMA_RELATIVEPATHELEMENT = 12718

const UA_NS0ID_OPCUA_BINARYSCHEMA_RELATIVEPATHELEMENT_DATATYPEVERSION = 12719

const UA_NS0ID_OPCUA_BINARYSCHEMA_RELATIVEPATHELEMENT_DICTIONARYFRAGMENT = 12720

const UA_NS0ID_OPCUA_BINARYSCHEMA_RELATIVEPATH = 12721

const UA_NS0ID_OPCUA_BINARYSCHEMA_RELATIVEPATH_DATATYPEVERSION = 12722

const UA_NS0ID_OPCUA_BINARYSCHEMA_RELATIVEPATH_DICTIONARYFRAGMENT = 12723

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CREATESIGNINGREQUEST = 12731

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CREATESIGNINGREQUEST_INPUTARGUMENTS = 12732

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CREATESIGNINGREQUEST_OUTPUTARGUMENTS = 12733

const UA_NS0ID_SERVERCONFIGURATIONTYPE_APPLYCHANGES = 12734

const UA_NS0ID_SERVERCONFIGURATION_CREATESIGNINGREQUEST = 12737

const UA_NS0ID_SERVERCONFIGURATION_CREATESIGNINGREQUEST_INPUTARGUMENTS = 12738

const UA_NS0ID_SERVERCONFIGURATION_CREATESIGNINGREQUEST_OUTPUTARGUMENTS = 12739

const UA_NS0ID_SERVERCONFIGURATION_APPLYCHANGES = 12740

const UA_NS0ID_CREATESIGNINGREQUESTMETHODTYPE = 12741

const UA_NS0ID_CREATESIGNINGREQUESTMETHODTYPE_INPUTARGUMENTS = 12742

const UA_NS0ID_CREATESIGNINGREQUESTMETHODTYPE_OUTPUTARGUMENTS = 12743

const UA_NS0ID_OPTIONSETVALUES = 12745

const UA_NS0ID_SERVERTYPE_SETSUBSCRIPTIONDURABLE = 12746

const UA_NS0ID_SERVERTYPE_SETSUBSCRIPTIONDURABLE_INPUTARGUMENTS = 12747

const UA_NS0ID_SERVERTYPE_SETSUBSCRIPTIONDURABLE_OUTPUTARGUMENTS = 12748

const UA_NS0ID_SERVER_SETSUBSCRIPTIONDURABLE = 12749

const UA_NS0ID_SERVER_SETSUBSCRIPTIONDURABLE_INPUTARGUMENTS = 12750

const UA_NS0ID_SERVER_SETSUBSCRIPTIONDURABLE_OUTPUTARGUMENTS = 12751

const UA_NS0ID_SETSUBSCRIPTIONDURABLEMETHODTYPE = 12752

const UA_NS0ID_SETSUBSCRIPTIONDURABLEMETHODTYPE_INPUTARGUMENTS = 12753

const UA_NS0ID_SETSUBSCRIPTIONDURABLEMETHODTYPE_OUTPUTARGUMENTS = 12754

const UA_NS0ID_OPTIONSET = 12755

const UA_NS0ID_UNION = 12756

const UA_NS0ID_OPTIONSET_ENCODING_DEFAULTXML = 12757

const UA_NS0ID_UNION_ENCODING_DEFAULTXML = 12758

const UA_NS0ID_OPCUA_XMLSCHEMA_OPTIONSET = 12759

const UA_NS0ID_OPCUA_XMLSCHEMA_OPTIONSET_DATATYPEVERSION = 12760

const UA_NS0ID_OPCUA_XMLSCHEMA_OPTIONSET_DICTIONARYFRAGMENT = 12761

const UA_NS0ID_OPCUA_XMLSCHEMA_UNION = 12762

const UA_NS0ID_OPCUA_XMLSCHEMA_UNION_DATATYPEVERSION = 12763

const UA_NS0ID_OPCUA_XMLSCHEMA_UNION_DICTIONARYFRAGMENT = 12764

const UA_NS0ID_OPTIONSET_ENCODING_DEFAULTBINARY = 12765

const UA_NS0ID_UNION_ENCODING_DEFAULTBINARY = 12766

const UA_NS0ID_OPCUA_BINARYSCHEMA_OPTIONSET = 12767

const UA_NS0ID_OPCUA_BINARYSCHEMA_OPTIONSET_DATATYPEVERSION = 12768

const UA_NS0ID_OPCUA_BINARYSCHEMA_OPTIONSET_DICTIONARYFRAGMENT = 12769

const UA_NS0ID_OPCUA_BINARYSCHEMA_UNION = 12770

const UA_NS0ID_OPCUA_BINARYSCHEMA_UNION_DATATYPEVERSION = 12771

const UA_NS0ID_OPCUA_BINARYSCHEMA_UNION_DICTIONARYFRAGMENT = 12772

const UA_NS0ID_GETREJECTEDLISTMETHODTYPE = 12773

const UA_NS0ID_GETREJECTEDLISTMETHODTYPE_OUTPUTARGUMENTS = 12774

const UA_NS0ID_SERVERCONFIGURATIONTYPE_GETREJECTEDLIST = 12775

const UA_NS0ID_SERVERCONFIGURATIONTYPE_GETREJECTEDLIST_OUTPUTARGUMENTS = 12776

const UA_NS0ID_SERVERCONFIGURATION_GETREJECTEDLIST = 12777

const UA_NS0ID_SERVERCONFIGURATION_GETREJECTEDLIST_OUTPUTARGUMENTS = 12778

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSARRAYTYPE_SAMPLINGINTERVALDIAGNOSTICS = 12779

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSARRAYTYPE_SAMPLINGINTERVALDIAGNOSTICS_SAMPLINGINTERVAL = 12780

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSARRAYTYPE_SAMPLINGINTERVALDIAGNOSTICS_SAMPLEDMONITOREDITEMSCOUNT = 12781

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSARRAYTYPE_SAMPLINGINTERVALDIAGNOSTICS_MAXSAMPLEDMONITOREDITEMSCOUNT = 12782

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSARRAYTYPE_SAMPLINGINTERVALDIAGNOSTICS_DISABLEDMONITOREDITEMSSAMPLINGCOUNT = 12783

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS = 12784

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_SESSIONID = 12785

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_SUBSCRIPTIONID = 12786

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_PRIORITY = 12787

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_PUBLISHINGINTERVAL = 12788

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_MAXKEEPALIVECOUNT = 12789

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_MAXLIFETIMECOUNT = 12790

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_MAXNOTIFICATIONSPERPUBLISH = 12791

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_PUBLISHINGENABLED = 12792

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_MODIFYCOUNT = 12793

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_ENABLECOUNT = 12794

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_DISABLECOUNT = 12795

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_REPUBLISHREQUESTCOUNT = 12796

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_REPUBLISHMESSAGEREQUESTCOUNT = 12797

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_REPUBLISHMESSAGECOUNT = 12798

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_TRANSFERREQUESTCOUNT = 12799

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_TRANSFERREDTOALTCLIENTCOUNT = 12800

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_TRANSFERREDTOSAMECLIENTCOUNT = 12801

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_PUBLISHREQUESTCOUNT = 12802

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_DATACHANGENOTIFICATIONSCOUNT = 12803

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_EVENTNOTIFICATIONSCOUNT = 12804

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_NOTIFICATIONSCOUNT = 12805

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_LATEPUBLISHREQUESTCOUNT = 12806

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_CURRENTKEEPALIVECOUNT = 12807

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_CURRENTLIFETIMECOUNT = 12808

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_UNACKNOWLEDGEDMESSAGECOUNT = 12809

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_DISCARDEDMESSAGECOUNT = 12810

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_MONITOREDITEMCOUNT = 12811

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_DISABLEDMONITOREDITEMCOUNT = 12812

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_MONITORINGQUEUEOVERFLOWCOUNT = 12813

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_NEXTSEQUENCENUMBER = 12814

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSARRAYTYPE_SUBSCRIPTIONDIAGNOSTICS_EVENTQUEUEOVERFLOWCOUNT = 12815

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS = 12816

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_SESSIONID = 12817

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_SESSIONNAME = 12818

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CLIENTDESCRIPTION = 12819

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_SERVERURI = 12820

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_ENDPOINTURL = 12821

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_LOCALEIDS = 12822

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_ACTUALSESSIONTIMEOUT = 12823

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_MAXRESPONSEMESSAGESIZE = 12824

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CLIENTCONNECTIONTIME = 12825

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CLIENTLASTCONTACTTIME = 12826

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CURRENTSUBSCRIPTIONSCOUNT = 12827

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CURRENTMONITOREDITEMSCOUNT = 12828

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CURRENTPUBLISHREQUESTSINQUEUE = 12829

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_TOTALREQUESTCOUNT = 12830

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_UNAUTHORIZEDREQUESTCOUNT = 12831

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_READCOUNT = 12832

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_HISTORYREADCOUNT = 12833

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_WRITECOUNT = 12834

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_HISTORYUPDATECOUNT = 12835

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CALLCOUNT = 12836

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CREATEMONITOREDITEMSCOUNT = 12837

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_MODIFYMONITOREDITEMSCOUNT = 12838

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_SETMONITORINGMODECOUNT = 12839

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_SETTRIGGERINGCOUNT = 12840

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_DELETEMONITOREDITEMSCOUNT = 12841

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_CREATESUBSCRIPTIONCOUNT = 12842

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_MODIFYSUBSCRIPTIONCOUNT = 12843

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_SETPUBLISHINGMODECOUNT = 12844

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_PUBLISHCOUNT = 12845

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_REPUBLISHCOUNT = 12846

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_TRANSFERSUBSCRIPTIONSCOUNT = 12847

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_DELETESUBSCRIPTIONSCOUNT = 12848

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_ADDNODESCOUNT = 12849

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_ADDREFERENCESCOUNT = 12850

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_DELETENODESCOUNT = 12851

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_DELETEREFERENCESCOUNT = 12852

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_BROWSECOUNT = 12853

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_BROWSENEXTCOUNT = 12854

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_TRANSLATEBROWSEPATHSTONODEIDSCOUNT = 12855

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_QUERYFIRSTCOUNT = 12856

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_QUERYNEXTCOUNT = 12857

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_REGISTERNODESCOUNT = 12858

const UA_NS0ID_SESSIONDIAGNOSTICSARRAYTYPE_SESSIONDIAGNOSTICS_UNREGISTERNODESCOUNT = 12859

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS = 12860

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_SESSIONID = 12861

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_CLIENTUSERIDOFSESSION = 12862

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_CLIENTUSERIDHISTORY = 12863

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_AUTHENTICATIONMECHANISM = 12864

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_ENCODING = 12865

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_TRANSPORTPROTOCOL = 12866

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_SECURITYMODE = 12867

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_SECURITYPOLICYURI = 12868

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSARRAYTYPE_SESSIONSECURITYDIAGNOSTICS_CLIENTCERTIFICATE = 12869

const UA_NS0ID_SERVERTYPE_RESENDDATA = 12871

const UA_NS0ID_SERVERTYPE_RESENDDATA_INPUTARGUMENTS = 12872

const UA_NS0ID_SERVER_RESENDDATA = 12873

const UA_NS0ID_SERVER_RESENDDATA_INPUTARGUMENTS = 12874

const UA_NS0ID_RESENDDATAMETHODTYPE = 12875

const UA_NS0ID_RESENDDATAMETHODTYPE_INPUTARGUMENTS = 12876

const UA_NS0ID_NORMALIZEDSTRING = 12877

const UA_NS0ID_DECIMALSTRING = 12878

const UA_NS0ID_DURATIONSTRING = 12879

const UA_NS0ID_TIMESTRING = 12880

const UA_NS0ID_DATESTRING = 12881

const UA_NS0ID_SERVERTYPE_ESTIMATEDRETURNTIME = 12882

const UA_NS0ID_SERVERTYPE_REQUESTSERVERSTATECHANGE = 12883

const UA_NS0ID_SERVERTYPE_REQUESTSERVERSTATECHANGE_INPUTARGUMENTS = 12884

const UA_NS0ID_SERVER_ESTIMATEDRETURNTIME = 12885

const UA_NS0ID_SERVER_REQUESTSERVERSTATECHANGE = 12886

const UA_NS0ID_SERVER_REQUESTSERVERSTATECHANGE_INPUTARGUMENTS = 12887

const UA_NS0ID_REQUESTSERVERSTATECHANGEMETHODTYPE = 12888

const UA_NS0ID_REQUESTSERVERSTATECHANGEMETHODTYPE_INPUTARGUMENTS = 12889

const UA_NS0ID_DISCOVERYCONFIGURATION = 12890

const UA_NS0ID_MDNSDISCOVERYCONFIGURATION = 12891

const UA_NS0ID_DISCOVERYCONFIGURATION_ENCODING_DEFAULTXML = 12892

const UA_NS0ID_MDNSDISCOVERYCONFIGURATION_ENCODING_DEFAULTXML = 12893

const UA_NS0ID_OPCUA_XMLSCHEMA_DISCOVERYCONFIGURATION = 12894

const UA_NS0ID_OPCUA_XMLSCHEMA_DISCOVERYCONFIGURATION_DATATYPEVERSION = 12895

const UA_NS0ID_OPCUA_XMLSCHEMA_DISCOVERYCONFIGURATION_DICTIONARYFRAGMENT = 12896

const UA_NS0ID_OPCUA_XMLSCHEMA_MDNSDISCOVERYCONFIGURATION = 12897

const UA_NS0ID_OPCUA_XMLSCHEMA_MDNSDISCOVERYCONFIGURATION_DATATYPEVERSION = 12898

const UA_NS0ID_OPCUA_XMLSCHEMA_MDNSDISCOVERYCONFIGURATION_DICTIONARYFRAGMENT = 12899

const UA_NS0ID_DISCOVERYCONFIGURATION_ENCODING_DEFAULTBINARY = 12900

const UA_NS0ID_MDNSDISCOVERYCONFIGURATION_ENCODING_DEFAULTBINARY = 12901

const UA_NS0ID_OPCUA_BINARYSCHEMA_DISCOVERYCONFIGURATION = 12902

const UA_NS0ID_OPCUA_BINARYSCHEMA_DISCOVERYCONFIGURATION_DATATYPEVERSION = 12903

const UA_NS0ID_OPCUA_BINARYSCHEMA_DISCOVERYCONFIGURATION_DICTIONARYFRAGMENT = 12904

const UA_NS0ID_OPCUA_BINARYSCHEMA_MDNSDISCOVERYCONFIGURATION = 12905

const UA_NS0ID_OPCUA_BINARYSCHEMA_MDNSDISCOVERYCONFIGURATION_DATATYPEVERSION = 12906

const UA_NS0ID_OPCUA_BINARYSCHEMA_MDNSDISCOVERYCONFIGURATION_DICTIONARYFRAGMENT = 12907

const UA_NS0ID_MAXBYTESTRINGLENGTH = 12908

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_MAXBYTESTRINGLENGTH = 12909

const UA_NS0ID_SERVERCAPABILITIESTYPE_MAXBYTESTRINGLENGTH = 12910

const UA_NS0ID_SERVER_SERVERCAPABILITIES_MAXBYTESTRINGLENGTH = 12911

const UA_NS0ID_CONDITIONTYPE_CONDITIONREFRESH2 = 12912

const UA_NS0ID_CONDITIONTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12913

const UA_NS0ID_CONDITIONREFRESH2METHODTYPE = 12914

const UA_NS0ID_CONDITIONREFRESH2METHODTYPE_INPUTARGUMENTS = 12915

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONREFRESH2 = 12916

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12917

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONREFRESH2 = 12918

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12919

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONREFRESH2 = 12984

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12985

const UA_NS0ID_LIMITALARMTYPE_CONDITIONREFRESH2 = 12986

const UA_NS0ID_LIMITALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12987

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH2 = 12988

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12989

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH2 = 12990

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12991

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH2 = 12992

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12993

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH2 = 12994

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12995

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH2 = 12996

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12997

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH2 = 12998

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 12999

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH2 = 13000

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13001

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH2 = 13002

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13003

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONREFRESH2 = 13004

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13005

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONREFRESH2 = 13006

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13007

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONREFRESH2 = 13008

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13009

const UA_NS0ID_TRIPALARMTYPE_CONDITIONREFRESH2 = 13010

const UA_NS0ID_TRIPALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13011

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE = 13225

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_EVENTID = 13226

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_EVENTTYPE = 13227

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SOURCENODE = 13228

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SOURCENAME = 13229

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_TIME = 13230

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_RECEIVETIME = 13231

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LOCALTIME = 13232

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_MESSAGE = 13233

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SEVERITY = 13234

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONCLASSID = 13235

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONCLASSNAME = 13236

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONNAME = 13237

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_BRANCHID = 13238

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_RETAIN = 13239

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE = 13240

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_ID = 13241

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_NAME = 13242

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_NUMBER = 13243

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 13244

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 13245

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 13246

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_TRUESTATE = 13247

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLEDSTATE_FALSESTATE = 13248

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_QUALITY = 13249

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_QUALITY_SOURCETIMESTAMP = 13250

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LASTSEVERITY = 13251

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 13252

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_COMMENT = 13253

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_COMMENT_SOURCETIMESTAMP = 13254

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CLIENTUSERID = 13255

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_DISABLE = 13256

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ENABLE = 13257

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ADDCOMMENT = 13258

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 13259

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONREFRESH = 13260

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 13261

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONREFRESH2 = 13262

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 13263

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE = 13264

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_ID = 13265

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_NAME = 13266

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_NUMBER = 13267

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 13268

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 13269

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 13270

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_TRUESTATE = 13271

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKEDSTATE_FALSESTATE = 13272

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE = 13273

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_ID = 13274

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_NAME = 13275

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_NUMBER = 13276

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 13277

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 13278

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 13279

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 13280

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 13281

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKNOWLEDGE = 13282

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 13283

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRM = 13284

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONFIRM_INPUTARGUMENTS = 13285

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE = 13286

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_ID = 13287

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_NAME = 13288

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_NUMBER = 13289

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 13290

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 13291

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 13292

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_TRUESTATE = 13293

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ACTIVESTATE_FALSESTATE = 13294

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_INPUTNODE = 13295

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE = 13296

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_ID = 13297

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_NAME = 13298

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_NUMBER = 13299

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 13300

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 13301

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 13302

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 13303

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 13304

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE = 13305

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 13306

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 13307

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 13308

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 13309

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 13310

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 13311

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 13312

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 13313

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 13314

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 13315

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 13316

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 13317

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_UNSHELVE = 13318

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 13319

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 13320

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 13321

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESSEDORSHELVED = 13322

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_MAXTIMESHELVED = 13323

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_NORMALSTATE = 13324

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_EXPIRATIONDATE = 13325

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CERTIFICATETYPE = 13326

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CERTIFICATE = 13327

const UA_NS0ID_FILETYPE_MIMETYPE = 13341

const UA_NS0ID_CREATEDIRECTORYMETHODTYPE = 13342

const UA_NS0ID_CREATEDIRECTORYMETHODTYPE_INPUTARGUMENTS = 13343

const UA_NS0ID_CREATEDIRECTORYMETHODTYPE_OUTPUTARGUMENTS = 13344

const UA_NS0ID_CREATEFILEMETHODTYPE = 13345

const UA_NS0ID_CREATEFILEMETHODTYPE_INPUTARGUMENTS = 13346

const UA_NS0ID_CREATEFILEMETHODTYPE_OUTPUTARGUMENTS = 13347

const UA_NS0ID_DELETEFILEMETHODTYPE = 13348

const UA_NS0ID_DELETEFILEMETHODTYPE_INPUTARGUMENTS = 13349

const UA_NS0ID_MOVEORCOPYMETHODTYPE = 13350

const UA_NS0ID_MOVEORCOPYMETHODTYPE_INPUTARGUMENTS = 13351

const UA_NS0ID_MOVEORCOPYMETHODTYPE_OUTPUTARGUMENTS = 13352

const UA_NS0ID_FILEDIRECTORYTYPE = 13353

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER = 13354

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_CREATEDIRECTORY = 13355

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_CREATEDIRECTORY_INPUTARGUMENTS = 13356

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_CREATEDIRECTORY_OUTPUTARGUMENTS = 13357

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_CREATEFILE = 13358

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_CREATEFILE_INPUTARGUMENTS = 13359

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_CREATEFILE_OUTPUTARGUMENTS = 13360

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_MOVEORCOPY = 13363

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_MOVEORCOPY_INPUTARGUMENTS = 13364

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_MOVEORCOPY_OUTPUTARGUMENTS = 13365

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER = 13366

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_SIZE = 13367

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_WRITABLE = 13368

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_USERWRITABLE = 13369

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_OPENCOUNT = 13370

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_MIMETYPE = 13371

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_OPEN = 13372

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_OPEN_INPUTARGUMENTS = 13373

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_OPEN_OUTPUTARGUMENTS = 13374

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_CLOSE = 13375

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_CLOSE_INPUTARGUMENTS = 13376

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_READ = 13377

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_READ_INPUTARGUMENTS = 13378

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_READ_OUTPUTARGUMENTS = 13379

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_WRITE = 13380

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_WRITE_INPUTARGUMENTS = 13381

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_GETPOSITION = 13382

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_GETPOSITION_INPUTARGUMENTS = 13383

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_GETPOSITION_OUTPUTARGUMENTS = 13384

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_SETPOSITION = 13385

const UA_NS0ID_FILEDIRECTORYTYPE_FILENAME_PLACEHOLDER_SETPOSITION_INPUTARGUMENTS = 13386

const UA_NS0ID_FILEDIRECTORYTYPE_CREATEDIRECTORY = 13387

const UA_NS0ID_FILEDIRECTORYTYPE_CREATEDIRECTORY_INPUTARGUMENTS = 13388

const UA_NS0ID_FILEDIRECTORYTYPE_CREATEDIRECTORY_OUTPUTARGUMENTS = 13389

const UA_NS0ID_FILEDIRECTORYTYPE_CREATEFILE = 13390

const UA_NS0ID_FILEDIRECTORYTYPE_CREATEFILE_INPUTARGUMENTS = 13391

const UA_NS0ID_FILEDIRECTORYTYPE_CREATEFILE_OUTPUTARGUMENTS = 13392

const UA_NS0ID_FILEDIRECTORYTYPE_DELETEFILESYSTEMOBJECT = 13393

const UA_NS0ID_FILEDIRECTORYTYPE_DELETEFILESYSTEMOBJECT_INPUTARGUMENTS = 13394

const UA_NS0ID_FILEDIRECTORYTYPE_MOVEORCOPY = 13395

const UA_NS0ID_FILEDIRECTORYTYPE_MOVEORCOPY_INPUTARGUMENTS = 13396

const UA_NS0ID_FILEDIRECTORYTYPE_MOVEORCOPY_OUTPUTARGUMENTS = 13397

const UA_NS0ID_ADDRESSSPACEFILETYPE_MIMETYPE = 13398

const UA_NS0ID_NAMESPACEMETADATATYPE_NAMESPACEFILE_MIMETYPE = 13399

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_NAMESPACEFILE_MIMETYPE = 13400

const UA_NS0ID_TRUSTLISTTYPE_MIMETYPE = 13403

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST = 13599

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_SIZE = 13600

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_WRITABLE = 13601

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_USERWRITABLE = 13602

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPENCOUNT = 13603

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_MIMETYPE = 13604

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPEN = 13605

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPEN_INPUTARGUMENTS = 13606

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13607

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_CLOSE = 13608

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13609

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_READ = 13610

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_READ_INPUTARGUMENTS = 13611

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_READ_OUTPUTARGUMENTS = 13612

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_WRITE = 13613

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_WRITE_INPUTARGUMENTS = 13614

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_GETPOSITION = 13615

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 13616

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 13617

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_SETPOSITION = 13618

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 13619

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_LASTUPDATETIME = 13620

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPENWITHMASKS = 13621

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 13622

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 13623

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_CLOSEANDUPDATE = 13624

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 13625

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 13626

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_ADDCERTIFICATE = 13627

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 13628

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_REMOVECERTIFICATE = 13629

const UA_NS0ID_CERTIFICATEGROUPTYPE_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 13630

const UA_NS0ID_CERTIFICATEGROUPTYPE_CERTIFICATETYPES = 13631

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_CERTIFICATEGROUP = 13735

const UA_NS0ID_CERTIFICATEUPDATEDAUDITEVENTTYPE_CERTIFICATETYPE = 13736

const UA_NS0ID_SERVERCONFIGURATION_UPDATECERTIFICATE = 13737

const UA_NS0ID_SERVERCONFIGURATION_UPDATECERTIFICATE_INPUTARGUMENTS = 13738

const UA_NS0ID_SERVERCONFIGURATION_UPDATECERTIFICATE_OUTPUTARGUMENTS = 13739

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE = 13813

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP = 13814

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST = 13815

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SIZE = 13816

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITABLE = 13817

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_USERWRITABLE = 13818

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENCOUNT = 13819

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_MIMETYPE = 13820

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN = 13821

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 13822

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13823

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSE = 13824

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13825

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ = 13826

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 13827

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 13828

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITE = 13829

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 13830

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION = 13831

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 13832

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 13833

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SETPOSITION = 13834

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 13835

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_LASTUPDATETIME = 13836

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS = 13837

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 13838

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 13839

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE = 13840

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 13841

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 13842

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_ADDCERTIFICATE = 13843

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 13844

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_REMOVECERTIFICATE = 13845

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 13846

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTAPPLICATIONGROUP_CERTIFICATETYPES = 13847

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP = 13848

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST = 13849

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_SIZE = 13850

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_WRITABLE = 13851

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_USERWRITABLE = 13852

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPENCOUNT = 13853

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_MIMETYPE = 13854

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN = 13855

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 13856

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13857

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSE = 13858

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13859

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_READ = 13860

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 13861

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 13862

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_WRITE = 13863

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 13864

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION = 13865

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 13866

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 13867

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_SETPOSITION = 13868

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 13869

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_LASTUPDATETIME = 13870

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS = 13871

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 13872

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 13873

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE = 13874

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 13875

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 13876

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_ADDCERTIFICATE = 13877

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 13878

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_REMOVECERTIFICATE = 13879

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 13880

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTHTTPSGROUP_CERTIFICATETYPES = 13881

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP = 13882

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST = 13883

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_SIZE = 13884

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITABLE = 13885

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_USERWRITABLE = 13886

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENCOUNT = 13887

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_MIMETYPE = 13888

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN = 13889

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 13890

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13891

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSE = 13892

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13893

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ = 13894

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 13895

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 13896

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITE = 13897

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 13898

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION = 13899

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 13900

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 13901

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_SETPOSITION = 13902

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 13903

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_LASTUPDATETIME = 13904

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS = 13905

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 13906

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 13907

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE = 13908

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 13909

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 13910

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_ADDCERTIFICATE = 13911

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 13912

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_REMOVECERTIFICATE = 13913

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 13914

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_DEFAULTUSERTOKENGROUP_CERTIFICATETYPES = 13915

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER = 13916

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST = 13917

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_SIZE = 13918

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_WRITABLE = 13919

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_USERWRITABLE = 13920

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPENCOUNT = 13921

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_MIMETYPE = 13922

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPEN = 13923

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPEN_INPUTARGUMENTS = 13924

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13925

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_CLOSE = 13926

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13927

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_READ = 13928

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_READ_INPUTARGUMENTS = 13929

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_READ_OUTPUTARGUMENTS = 13930

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_WRITE = 13931

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_WRITE_INPUTARGUMENTS = 13932

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_GETPOSITION = 13933

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 13934

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 13935

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_SETPOSITION = 13936

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 13937

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_LASTUPDATETIME = 13938

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPENWITHMASKS = 13939

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 13940

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 13941

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_CLOSEANDUPDATE = 13942

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 13943

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 13944

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_ADDCERTIFICATE = 13945

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 13946

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_REMOVECERTIFICATE = 13947

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 13948

const UA_NS0ID_CERTIFICATEGROUPFOLDERTYPE_ADDITIONALGROUP_PLACEHOLDER_CERTIFICATETYPES = 13949

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS = 13950

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP = 13951

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST = 13952

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SIZE = 13953

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITABLE = 13954

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_USERWRITABLE = 13955

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENCOUNT = 13956

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_MIMETYPE = 13957

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN = 13958

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 13959

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13960

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSE = 13961

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13962

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ = 13963

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 13964

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 13965

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITE = 13966

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 13967

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION = 13968

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 13969

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 13970

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SETPOSITION = 13971

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 13972

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_LASTUPDATETIME = 13973

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS = 13974

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 13975

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 13976

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE = 13977

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 13978

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 13979

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_ADDCERTIFICATE = 13980

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 13981

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_REMOVECERTIFICATE = 13982

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 13983

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_CERTIFICATETYPES = 13984

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP = 13985

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST = 13986

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_SIZE = 13987

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_WRITABLE = 13988

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_USERWRITABLE = 13989

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENCOUNT = 13990

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_MIMETYPE = 13991

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN = 13992

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 13993

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 13994

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSE = 13995

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 13996

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_READ = 13997

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 13998

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 13999

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_WRITE = 14000

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 14001

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION = 14002

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 14003

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 14004

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_SETPOSITION = 14005

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 14006

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_LASTUPDATETIME = 14007

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS = 14008

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 14009

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 14010

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE = 14011

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 14012

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 14013

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_ADDCERTIFICATE = 14014

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 14015

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_REMOVECERTIFICATE = 14016

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 14017

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_CERTIFICATETYPES = 14018

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP = 14019

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST = 14020

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_SIZE = 14021

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITABLE = 14022

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_USERWRITABLE = 14023

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENCOUNT = 14024

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_MIMETYPE = 14025

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN = 14026

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 14027

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 14028

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSE = 14029

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 14030

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ = 14031

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 14032

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 14033

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITE = 14034

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 14035

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION = 14036

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 14037

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 14038

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_SETPOSITION = 14039

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 14040

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_LASTUPDATETIME = 14041

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS = 14042

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 14043

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 14044

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE = 14045

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 14046

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 14047

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_ADDCERTIFICATE = 14048

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 14049

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_REMOVECERTIFICATE = 14050

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 14051

const UA_NS0ID_SERVERCONFIGURATIONTYPE_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_CERTIFICATETYPES = 14052

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS = 14053

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP = 14088

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST = 14089

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_SIZE = 14090

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_WRITABLE = 14091

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_USERWRITABLE = 14092

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENCOUNT = 14093

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_MIMETYPE = 14094

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN = 14095

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 14096

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 14097

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSE = 14098

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 14099

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_READ = 14100

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 14101

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 14102

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_WRITE = 14103

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 14104

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION = 14105

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 14106

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 14107

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_SETPOSITION = 14108

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 14109

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_LASTUPDATETIME = 14110

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS = 14111

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 14112

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 14113

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE = 14114

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 14115

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 14116

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_ADDCERTIFICATE = 14117

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 14118

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_REMOVECERTIFICATE = 14119

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 14120

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTHTTPSGROUP_CERTIFICATETYPES = 14121

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP = 14122

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST = 14123

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_SIZE = 14124

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITABLE = 14125

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_USERWRITABLE = 14126

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENCOUNT = 14127

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_MIMETYPE = 14128

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN = 14129

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN_INPUTARGUMENTS = 14130

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPEN_OUTPUTARGUMENTS = 14131

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSE = 14132

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSE_INPUTARGUMENTS = 14133

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ = 14134

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ_INPUTARGUMENTS = 14135

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_READ_OUTPUTARGUMENTS = 14136

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITE = 14137

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_WRITE_INPUTARGUMENTS = 14138

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION = 14139

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION_INPUTARGUMENTS = 14140

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_GETPOSITION_OUTPUTARGUMENTS = 14141

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_SETPOSITION = 14142

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_SETPOSITION_INPUTARGUMENTS = 14143

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_LASTUPDATETIME = 14144

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS = 14145

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS_INPUTARGUMENTS = 14146

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_OPENWITHMASKS_OUTPUTARGUMENTS = 14147

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE = 14148

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 14149

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_CLOSEANDUPDATE_OUTPUTARGUMENTS = 14150

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_ADDCERTIFICATE = 14151

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_ADDCERTIFICATE_INPUTARGUMENTS = 14152

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_REMOVECERTIFICATE = 14153

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_TRUSTLIST_REMOVECERTIFICATE_INPUTARGUMENTS = 14154

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTUSERTOKENGROUP_CERTIFICATETYPES = 14155

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP = 14156

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_WRITABLE = 14157

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_USERWRITABLE = 14158

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_MIMETYPE = 14159

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_TRUSTLIST_CLOSEANDUPDATE_INPUTARGUMENTS = 14160

const UA_NS0ID_SERVERCONFIGURATION_CERTIFICATEGROUPS_DEFAULTAPPLICATIONGROUP_CERTIFICATETYPES = 14161

const UA_NS0ID_REMOVECONNECTIONMETHODTYPE = 14183

const UA_NS0ID_REMOVECONNECTIONMETHODTYPE_INPUTARGUMENTS = 14184

const UA_NS0ID_PUBSUBCONNECTIONTYPE = 14209

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDRESS = 14221

const UA_NS0ID_PUBSUBCONNECTIONTYPE_REMOVEGROUP = 14225

const UA_NS0ID_PUBSUBCONNECTIONTYPE_REMOVEGROUP_INPUTARGUMENTS = 14226

const UA_NS0ID_PUBSUBGROUPTYPE = 14232

const UA_NS0ID_PUBLISHEDVARIABLEDATATYPE = 14273

const UA_NS0ID_PUBLISHEDVARIABLEDATATYPE_ENCODING_DEFAULTXML = 14319

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDVARIABLEDATATYPE = 14320

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDVARIABLEDATATYPE_DATATYPEVERSION = 14321

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDVARIABLEDATATYPE_DICTIONARYFRAGMENT = 14322

const UA_NS0ID_PUBLISHEDVARIABLEDATATYPE_ENCODING_DEFAULTBINARY = 14323

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDVARIABLEDATATYPE = 14324

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDVARIABLEDATATYPE_DATATYPEVERSION = 14325

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDVARIABLEDATATYPE_DICTIONARYFRAGMENT = 14326

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_SESSIONID = 14413

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_SESSIONID = 14414

const UA_NS0ID_SERVER_SERVERREDUNDANCY_SERVERNETWORKGROUPS = 14415

const UA_NS0ID_PUBLISHSUBSCRIBETYPE = 14416

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER = 14417

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_PUBLISHERID = 14418

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_STATUS = 14419

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_STATUS_STATE = 14420

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_STATUS_ENABLE = 14421

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_STATUS_DISABLE = 14422

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDRESS = 14423

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_REMOVEGROUP = 14424

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_REMOVEGROUP_INPUTARGUMENTS = 14425

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_REMOVECONNECTION = 14432

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_REMOVECONNECTION_INPUTARGUMENTS = 14433

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS = 14434

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMS = 14435

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMS_INPUTARGUMENTS = 14436

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMS_OUTPUTARGUMENTS = 14437

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTS = 14438

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTS_INPUTARGUMENTS = 14439

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTS_OUTPUTARGUMENTS = 14440

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_REMOVEPUBLISHEDDATASET = 14441

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_REMOVEPUBLISHEDDATASET_INPUTARGUMENTS = 14442

const UA_NS0ID_PUBLISHSUBSCRIBE = 14443

const UA_NS0ID_HASPUBSUBCONNECTION = 14476

const UA_NS0ID_DATASETFOLDERTYPE = 14477

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER = 14478

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDDATAITEMS = 14479

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDDATAITEMS_INPUTARGUMENTS = 14480

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDDATAITEMS_OUTPUTARGUMENTS = 14481

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDEVENTS = 14482

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDEVENTS_INPUTARGUMENTS = 14483

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDEVENTS_OUTPUTARGUMENTS = 14484

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_REMOVEPUBLISHEDDATASET = 14485

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_REMOVEPUBLISHEDDATASET_INPUTARGUMENTS = 14486

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER = 14487

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_CONFIGURATIONVERSION = 14489

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDDATAITEMS = 14493

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDDATAITEMS_INPUTARGUMENTS = 14494

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDDATAITEMS_OUTPUTARGUMENTS = 14495

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDEVENTS = 14496

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDEVENTS_INPUTARGUMENTS = 14497

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDEVENTS_OUTPUTARGUMENTS = 14498

const UA_NS0ID_DATASETFOLDERTYPE_REMOVEPUBLISHEDDATASET = 14499

const UA_NS0ID_DATASETFOLDERTYPE_REMOVEPUBLISHEDDATASET_INPUTARGUMENTS = 14500

const UA_NS0ID_ADDPUBLISHEDDATAITEMSMETHODTYPE = 14501

const UA_NS0ID_ADDPUBLISHEDDATAITEMSMETHODTYPE_INPUTARGUMENTS = 14502

const UA_NS0ID_ADDPUBLISHEDDATAITEMSMETHODTYPE_OUTPUTARGUMENTS = 14503

const UA_NS0ID_ADDPUBLISHEDEVENTSMETHODTYPE = 14504

const UA_NS0ID_ADDPUBLISHEDEVENTSMETHODTYPE_INPUTARGUMENTS = 14505

const UA_NS0ID_ADDPUBLISHEDEVENTSMETHODTYPE_OUTPUTARGUMENTS = 14506

const UA_NS0ID_REMOVEPUBLISHEDDATASETMETHODTYPE = 14507

const UA_NS0ID_REMOVEPUBLISHEDDATASETMETHODTYPE_INPUTARGUMENTS = 14508

const UA_NS0ID_PUBLISHEDDATASETTYPE = 14509

const UA_NS0ID_PUBLISHEDDATASETTYPE_CONFIGURATIONVERSION = 14519

const UA_NS0ID_DATASETMETADATATYPE = 14523

const UA_NS0ID_FIELDMETADATA = 14524

const UA_NS0ID_DATATYPEDESCRIPTION = 14525

const UA_NS0ID_STRUCTURETYPE_ENUMSTRINGS = 14528

const UA_NS0ID_KEYVALUEPAIR = 14533

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE = 14534

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_CONFIGURATIONVERSION = 14544

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_PUBLISHEDDATA = 14548

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_ADDVARIABLES = 14555

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_ADDVARIABLES_INPUTARGUMENTS = 14556

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_ADDVARIABLES_OUTPUTARGUMENTS = 14557

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_REMOVEVARIABLES = 14558

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_REMOVEVARIABLES_INPUTARGUMENTS = 14559

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_REMOVEVARIABLES_OUTPUTARGUMENTS = 14560

const UA_NS0ID_PUBLISHEDDATAITEMSADDVARIABLESMETHODTYPE = 14564

const UA_NS0ID_PUBLISHEDDATAITEMSADDVARIABLESMETHODTYPE_INPUTARGUMENTS = 14565

const UA_NS0ID_PUBLISHEDDATAITEMSADDVARIABLESMETHODTYPE_OUTPUTARGUMENTS = 14566

const UA_NS0ID_PUBLISHEDDATAITEMSREMOVEVARIABLESMETHODTYPE = 14567

const UA_NS0ID_PUBLISHEDDATAITEMSREMOVEVARIABLESMETHODTYPE_INPUTARGUMENTS = 14568

const UA_NS0ID_PUBLISHEDDATAITEMSREMOVEVARIABLESMETHODTYPE_OUTPUTARGUMENTS = 14569

const UA_NS0ID_PUBLISHEDEVENTSTYPE = 14572

const UA_NS0ID_PUBLISHEDEVENTSTYPE_CONFIGURATIONVERSION = 14582

const UA_NS0ID_PUBLISHEDEVENTSTYPE_PUBSUBEVENTNOTIFIER = 14586

const UA_NS0ID_PUBLISHEDEVENTSTYPE_SELECTEDFIELDS = 14587

const UA_NS0ID_PUBLISHEDEVENTSTYPE_FILTER = 14588

const UA_NS0ID_CONFIGURATIONVERSIONDATATYPE = 14593

const UA_NS0ID_PUBSUBCONNECTIONTYPE_PUBLISHERID = 14595

const UA_NS0ID_PUBSUBCONNECTIONTYPE_STATUS = 14600

const UA_NS0ID_PUBSUBCONNECTIONTYPE_STATUS_STATE = 14601

const UA_NS0ID_PUBSUBCONNECTIONTYPE_STATUS_ENABLE = 14602

const UA_NS0ID_PUBSUBCONNECTIONTYPE_STATUS_DISABLE = 14603

const UA_NS0ID_PUBSUBCONNECTIONTYPEREMOVEGROUPMETHODTYPE = 14604

const UA_NS0ID_PUBSUBCONNECTIONTYPEREMOVEGROUPMETHODTYPE_INPUTARGUMENTS = 14605

const UA_NS0ID_PUBSUBGROUPTYPEREMOVEWRITERMETHODTYPE = 14623

const UA_NS0ID_PUBSUBGROUPTYPEREMOVEWRITERMETHODTYPE_INPUTARGUMENTS = 14624

const UA_NS0ID_PUBSUBGROUPTYPEREMOVEREADERMETHODTYPE = 14625

const UA_NS0ID_PUBSUBGROUPTYPEREMOVEREADERMETHODTYPE_INPUTARGUMENTS = 14626

const UA_NS0ID_PUBSUBSTATUSTYPE = 14643

const UA_NS0ID_PUBSUBSTATUSTYPE_STATE = 14644

const UA_NS0ID_PUBSUBSTATUSTYPE_ENABLE = 14645

const UA_NS0ID_PUBSUBSTATUSTYPE_DISABLE = 14646

const UA_NS0ID_PUBSUBSTATE = 14647

const UA_NS0ID_PUBSUBSTATE_ENUMSTRINGS = 14648

const UA_NS0ID_FIELDTARGETDATATYPE = 14744

const UA_NS0ID_DATASETMETADATATYPE_ENCODING_DEFAULTXML = 14794

const UA_NS0ID_FIELDMETADATA_ENCODING_DEFAULTXML = 14795

const UA_NS0ID_DATATYPEDESCRIPTION_ENCODING_DEFAULTXML = 14796

const UA_NS0ID_DATATYPEDEFINITION_ENCODING_DEFAULTXML = 14797

const UA_NS0ID_STRUCTUREDEFINITION_ENCODING_DEFAULTXML = 14798

const UA_NS0ID_ENUMDEFINITION_ENCODING_DEFAULTXML = 14799

const UA_NS0ID_STRUCTUREFIELD_ENCODING_DEFAULTXML = 14800

const UA_NS0ID_ENUMFIELD_ENCODING_DEFAULTXML = 14801

const UA_NS0ID_KEYVALUEPAIR_ENCODING_DEFAULTXML = 14802

const UA_NS0ID_CONFIGURATIONVERSIONDATATYPE_ENCODING_DEFAULTXML = 14803

const UA_NS0ID_FIELDTARGETDATATYPE_ENCODING_DEFAULTXML = 14804

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETMETADATATYPE = 14805

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETMETADATATYPE_DATATYPEVERSION = 14806

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETMETADATATYPE_DICTIONARYFRAGMENT = 14807

const UA_NS0ID_OPCUA_XMLSCHEMA_FIELDMETADATA = 14808

const UA_NS0ID_OPCUA_XMLSCHEMA_FIELDMETADATA_DATATYPEVERSION = 14809

const UA_NS0ID_OPCUA_XMLSCHEMA_FIELDMETADATA_DICTIONARYFRAGMENT = 14810

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEDESCRIPTION = 14811

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEDESCRIPTION_DATATYPEVERSION = 14812

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEDESCRIPTION_DICTIONARYFRAGMENT = 14813

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMFIELD = 14826

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMFIELD_DATATYPEVERSION = 14827

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMFIELD_DICTIONARYFRAGMENT = 14828

const UA_NS0ID_OPCUA_XMLSCHEMA_KEYVALUEPAIR = 14829

const UA_NS0ID_OPCUA_XMLSCHEMA_KEYVALUEPAIR_DATATYPEVERSION = 14830

const UA_NS0ID_OPCUA_XMLSCHEMA_KEYVALUEPAIR_DICTIONARYFRAGMENT = 14831

const UA_NS0ID_OPCUA_XMLSCHEMA_CONFIGURATIONVERSIONDATATYPE = 14832

const UA_NS0ID_OPCUA_XMLSCHEMA_CONFIGURATIONVERSIONDATATYPE_DATATYPEVERSION = 14833

const UA_NS0ID_OPCUA_XMLSCHEMA_CONFIGURATIONVERSIONDATATYPE_DICTIONARYFRAGMENT = 14834

const UA_NS0ID_OPCUA_XMLSCHEMA_FIELDTARGETDATATYPE = 14835

const UA_NS0ID_OPCUA_XMLSCHEMA_FIELDTARGETDATATYPE_DATATYPEVERSION = 14836

const UA_NS0ID_OPCUA_XMLSCHEMA_FIELDTARGETDATATYPE_DICTIONARYFRAGMENT = 14837

const UA_NS0ID_FIELDMETADATA_ENCODING_DEFAULTBINARY = 14839

const UA_NS0ID_STRUCTUREFIELD_ENCODING_DEFAULTBINARY = 14844

const UA_NS0ID_ENUMFIELD_ENCODING_DEFAULTBINARY = 14845

const UA_NS0ID_KEYVALUEPAIR_ENCODING_DEFAULTBINARY = 14846

const UA_NS0ID_CONFIGURATIONVERSIONDATATYPE_ENCODING_DEFAULTBINARY = 14847

const UA_NS0ID_FIELDTARGETDATATYPE_ENCODING_DEFAULTBINARY = 14848

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETMETADATATYPE = 14849

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETMETADATATYPE_DATATYPEVERSION = 14850

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETMETADATATYPE_DICTIONARYFRAGMENT = 14851

const UA_NS0ID_OPCUA_BINARYSCHEMA_FIELDMETADATA = 14852

const UA_NS0ID_OPCUA_BINARYSCHEMA_FIELDMETADATA_DATATYPEVERSION = 14853

const UA_NS0ID_OPCUA_BINARYSCHEMA_FIELDMETADATA_DICTIONARYFRAGMENT = 14854

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEDESCRIPTION = 14855

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEDESCRIPTION_DATATYPEVERSION = 14856

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEDESCRIPTION_DICTIONARYFRAGMENT = 14857

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMFIELD = 14870

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMFIELD_DATATYPEVERSION = 14871

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMFIELD_DICTIONARYFRAGMENT = 14872

const UA_NS0ID_OPCUA_BINARYSCHEMA_KEYVALUEPAIR = 14873

const UA_NS0ID_OPCUA_BINARYSCHEMA_KEYVALUEPAIR_DATATYPEVERSION = 14874

const UA_NS0ID_OPCUA_BINARYSCHEMA_KEYVALUEPAIR_DICTIONARYFRAGMENT = 14875

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONFIGURATIONVERSIONDATATYPE = 14876

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONFIGURATIONVERSIONDATATYPE_DATATYPEVERSION = 14877

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONFIGURATIONVERSIONDATATYPE_DICTIONARYFRAGMENT = 14878

const UA_NS0ID_OPCUA_BINARYSCHEMA_FIELDTARGETDATATYPE_DATATYPEVERSION = 14880

const UA_NS0ID_OPCUA_BINARYSCHEMA_FIELDTARGETDATATYPE_DICTIONARYFRAGMENT = 14881

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_EXPIRATIONLIMIT = 14900

const UA_NS0ID_DATASETTOWRITER = 14936

const UA_NS0ID_DATATYPEDICTIONARYTYPE_DEPRECATED = 15001

const UA_NS0ID_MAXCHARACTERS = 15002

const UA_NS0ID_SERVERTYPE_URISVERSION = 15003

const UA_NS0ID_SERVER_URISVERSION = 15004

const UA_NS0ID_SIMPLETYPEDESCRIPTION = 15005

const UA_NS0ID_UABINARYFILEDATATYPE = 15006

const UA_NS0ID_BROKERCONNECTIONTRANSPORTDATATYPE = 15007

const UA_NS0ID_BROKERTRANSPORTQUALITYOFSERVICE = 15008

const UA_NS0ID_BROKERTRANSPORTQUALITYOFSERVICE_ENUMSTRINGS = 15009

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPNAME_PLACEHOLDER_KEYLIFETIME = 15010

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPNAME_PLACEHOLDER_SECURITYPOLICYURI = 15011

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPNAME_PLACEHOLDER_MAXFUTUREKEYCOUNT = 15012

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE = 15013

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_EVENTID = 15014

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_EVENTTYPE = 15015

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_SOURCENODE = 15016

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_SOURCENAME = 15017

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_TIME = 15018

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_RECEIVETIME = 15019

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_LOCALTIME = 15020

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_MESSAGE = 15021

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_SEVERITY = 15022

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_ACTIONTIMESTAMP = 15023

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_STATUS = 15024

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_SERVERID = 15025

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_CLIENTAUDITENTRYID = 15026

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_CLIENTUSERID = 15027

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_METHODID = 15028

const UA_NS0ID_AUDITCONDITIONRESETEVENTTYPE_INPUTARGUMENTS = 15029

const UA_NS0ID_PERMISSIONTYPE_OPTIONSETVALUES = 15030

const UA_NS0ID_ACCESSLEVELTYPE = 15031

const UA_NS0ID_ACCESSLEVELTYPE_OPTIONSETVALUES = 15032

const UA_NS0ID_EVENTNOTIFIERTYPE = 15033

const UA_NS0ID_EVENTNOTIFIERTYPE_OPTIONSETVALUES = 15034

const UA_NS0ID_ACCESSRESTRICTIONTYPE_OPTIONSETVALUES = 15035

const UA_NS0ID_ATTRIBUTEWRITEMASK_OPTIONSETVALUES = 15036

const UA_NS0ID_OPCUA_BINARYSCHEMA_DEPRECATED = 15037

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODINPUTVALUES = 15038

const UA_NS0ID_OPCUA_XMLSCHEMA_DEPRECATED = 15039

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_PROGRAMDIAGNOSTIC_LASTMETHODOUTPUTVALUES = 15040

const UA_NS0ID_KEYVALUEPAIR_ENCODING_DEFAULTJSON = 15041

const UA_NS0ID_IDENTITYMAPPINGRULETYPE_ENCODING_DEFAULTJSON = 15042

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPNAME_PLACEHOLDER_MAXPASTKEYCOUNT = 15043

const UA_NS0ID_TRUSTLISTDATATYPE_ENCODING_DEFAULTJSON = 15044

const UA_NS0ID_DECIMALDATATYPE_ENCODING_DEFAULTJSON = 15045

const UA_NS0ID_SECURITYGROUPTYPE_KEYLIFETIME = 15046

const UA_NS0ID_SECURITYGROUPTYPE_SECURITYPOLICYURI = 15047

const UA_NS0ID_SECURITYGROUPTYPE_MAXFUTUREKEYCOUNT = 15048

const UA_NS0ID_CONFIGURATIONVERSIONDATATYPE_ENCODING_DEFAULTJSON = 15049

const UA_NS0ID_DATASETMETADATATYPE_ENCODING_DEFAULTJSON = 15050

const UA_NS0ID_FIELDMETADATA_ENCODING_DEFAULTJSON = 15051

const UA_NS0ID_PUBLISHEDEVENTSTYPE_MODIFYFIELDSELECTION = 15052

const UA_NS0ID_PUBLISHEDEVENTSTYPE_MODIFYFIELDSELECTION_INPUTARGUMENTS = 15053

const UA_NS0ID_PUBLISHEDEVENTSTYPEMODIFYFIELDSELECTIONMETHODTYPE = 15054

const UA_NS0ID_PUBLISHEDEVENTSTYPEMODIFYFIELDSELECTIONMETHODTYPE_INPUTARGUMENTS = 15055

const UA_NS0ID_SECURITYGROUPTYPE_MAXPASTKEYCOUNT = 15056

const UA_NS0ID_DATATYPEDESCRIPTION_ENCODING_DEFAULTJSON = 15057

const UA_NS0ID_STRUCTUREDESCRIPTION_ENCODING_DEFAULTJSON = 15058

const UA_NS0ID_ENUMDESCRIPTION_ENCODING_DEFAULTJSON = 15059

const UA_NS0ID_PUBLISHEDVARIABLEDATATYPE_ENCODING_DEFAULTJSON = 15060

const UA_NS0ID_FIELDTARGETDATATYPE_ENCODING_DEFAULTJSON = 15061

const UA_NS0ID_ROLEPERMISSIONTYPE_ENCODING_DEFAULTJSON = 15062

const UA_NS0ID_DATATYPEDEFINITION_ENCODING_DEFAULTJSON = 15063

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTTYPE = 15064

const UA_NS0ID_STRUCTUREFIELD_ENCODING_DEFAULTJSON = 15065

const UA_NS0ID_STRUCTUREDEFINITION_ENCODING_DEFAULTJSON = 15066

const UA_NS0ID_ENUMDEFINITION_ENCODING_DEFAULTJSON = 15067

const UA_NS0ID_NODE_ENCODING_DEFAULTJSON = 15068

const UA_NS0ID_INSTANCENODE_ENCODING_DEFAULTJSON = 15069

const UA_NS0ID_TYPENODE_ENCODING_DEFAULTJSON = 15070

const UA_NS0ID_OBJECTNODE_ENCODING_DEFAULTJSON = 15071

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTTYPE_DISCOVERYADDRESS = 15072

const UA_NS0ID_OBJECTTYPENODE_ENCODING_DEFAULTJSON = 15073

const UA_NS0ID_VARIABLENODE_ENCODING_DEFAULTJSON = 15074

const UA_NS0ID_VARIABLETYPENODE_ENCODING_DEFAULTJSON = 15075

const UA_NS0ID_REFERENCETYPENODE_ENCODING_DEFAULTJSON = 15076

const UA_NS0ID_METHODNODE_ENCODING_DEFAULTJSON = 15077

const UA_NS0ID_VIEWNODE_ENCODING_DEFAULTJSON = 15078

const UA_NS0ID_DATATYPENODE_ENCODING_DEFAULTJSON = 15079

const UA_NS0ID_REFERENCENODE_ENCODING_DEFAULTJSON = 15080

const UA_NS0ID_ARGUMENT_ENCODING_DEFAULTJSON = 15081

const UA_NS0ID_ENUMVALUETYPE_ENCODING_DEFAULTJSON = 15082

const UA_NS0ID_ENUMFIELD_ENCODING_DEFAULTJSON = 15083

const UA_NS0ID_OPTIONSET_ENCODING_DEFAULTJSON = 15084

const UA_NS0ID_UNION_ENCODING_DEFAULTJSON = 15085

const UA_NS0ID_TIMEZONEDATATYPE_ENCODING_DEFAULTJSON = 15086

const UA_NS0ID_APPLICATIONDESCRIPTION_ENCODING_DEFAULTJSON = 15087

const UA_NS0ID_REQUESTHEADER_ENCODING_DEFAULTJSON = 15088

const UA_NS0ID_RESPONSEHEADER_ENCODING_DEFAULTJSON = 15089

const UA_NS0ID_SERVICEFAULT_ENCODING_DEFAULTJSON = 15090

const UA_NS0ID_SESSIONLESSINVOKEREQUESTTYPE_ENCODING_DEFAULTJSON = 15091

const UA_NS0ID_SESSIONLESSINVOKERESPONSETYPE_ENCODING_DEFAULTJSON = 15092

const UA_NS0ID_FINDSERVERSREQUEST_ENCODING_DEFAULTJSON = 15093

const UA_NS0ID_FINDSERVERSRESPONSE_ENCODING_DEFAULTJSON = 15094

const UA_NS0ID_SERVERONNETWORK_ENCODING_DEFAULTJSON = 15095

const UA_NS0ID_FINDSERVERSONNETWORKREQUEST_ENCODING_DEFAULTJSON = 15096

const UA_NS0ID_FINDSERVERSONNETWORKRESPONSE_ENCODING_DEFAULTJSON = 15097

const UA_NS0ID_USERTOKENPOLICY_ENCODING_DEFAULTJSON = 15098

const UA_NS0ID_ENDPOINTDESCRIPTION_ENCODING_DEFAULTJSON = 15099

const UA_NS0ID_GETENDPOINTSREQUEST_ENCODING_DEFAULTJSON = 15100

const UA_NS0ID_GETENDPOINTSRESPONSE_ENCODING_DEFAULTJSON = 15101

const UA_NS0ID_REGISTEREDSERVER_ENCODING_DEFAULTJSON = 15102

const UA_NS0ID_REGISTERSERVERREQUEST_ENCODING_DEFAULTJSON = 15103

const UA_NS0ID_REGISTERSERVERRESPONSE_ENCODING_DEFAULTJSON = 15104

const UA_NS0ID_DISCOVERYCONFIGURATION_ENCODING_DEFAULTJSON = 15105

const UA_NS0ID_MDNSDISCOVERYCONFIGURATION_ENCODING_DEFAULTJSON = 15106

const UA_NS0ID_REGISTERSERVER2REQUEST_ENCODING_DEFAULTJSON = 15107

const UA_NS0ID_SUBSCRIBEDDATASETTYPE = 15108

const UA_NS0ID_CHOICESTATETYPE = 15109

const UA_NS0ID_CHOICESTATETYPE_STATENUMBER = 15110

const UA_NS0ID_TARGETVARIABLESTYPE = 15111

const UA_NS0ID_HASGUARD = 15112

const UA_NS0ID_GUARDVARIABLETYPE = 15113

const UA_NS0ID_TARGETVARIABLESTYPE_TARGETVARIABLES = 15114

const UA_NS0ID_TARGETVARIABLESTYPE_ADDTARGETVARIABLES = 15115

const UA_NS0ID_TARGETVARIABLESTYPE_ADDTARGETVARIABLES_INPUTARGUMENTS = 15116

const UA_NS0ID_TARGETVARIABLESTYPE_ADDTARGETVARIABLES_OUTPUTARGUMENTS = 15117

const UA_NS0ID_TARGETVARIABLESTYPE_REMOVETARGETVARIABLES = 15118

const UA_NS0ID_TARGETVARIABLESTYPE_REMOVETARGETVARIABLES_INPUTARGUMENTS = 15119

const UA_NS0ID_TARGETVARIABLESTYPE_REMOVETARGETVARIABLES_OUTPUTARGUMENTS = 15120

const UA_NS0ID_TARGETVARIABLESTYPEADDTARGETVARIABLESMETHODTYPE = 15121

const UA_NS0ID_TARGETVARIABLESTYPEADDTARGETVARIABLESMETHODTYPE_INPUTARGUMENTS = 15122

const UA_NS0ID_TARGETVARIABLESTYPEADDTARGETVARIABLESMETHODTYPE_OUTPUTARGUMENTS = 15123

const UA_NS0ID_TARGETVARIABLESTYPEREMOVETARGETVARIABLESMETHODTYPE = 15124

const UA_NS0ID_TARGETVARIABLESTYPEREMOVETARGETVARIABLESMETHODTYPE_INPUTARGUMENTS = 15125

const UA_NS0ID_TARGETVARIABLESTYPEREMOVETARGETVARIABLESMETHODTYPE_OUTPUTARGUMENTS = 15126

const UA_NS0ID_SUBSCRIBEDDATASETMIRRORTYPE = 15127

const UA_NS0ID_EXPRESSIONGUARDVARIABLETYPE = 15128

const UA_NS0ID_EXPRESSIONGUARDVARIABLETYPE_EXPRESSION = 15129

const UA_NS0ID_REGISTERSERVER2RESPONSE_ENCODING_DEFAULTJSON = 15130

const UA_NS0ID_CHANNELSECURITYTOKEN_ENCODING_DEFAULTJSON = 15131

const UA_NS0ID_OPENSECURECHANNELREQUEST_ENCODING_DEFAULTJSON = 15132

const UA_NS0ID_OPENSECURECHANNELRESPONSE_ENCODING_DEFAULTJSON = 15133

const UA_NS0ID_CLOSESECURECHANNELREQUEST_ENCODING_DEFAULTJSON = 15134

const UA_NS0ID_CLOSESECURECHANNELRESPONSE_ENCODING_DEFAULTJSON = 15135

const UA_NS0ID_SIGNEDSOFTWARECERTIFICATE_ENCODING_DEFAULTJSON = 15136

const UA_NS0ID_SIGNATUREDATA_ENCODING_DEFAULTJSON = 15137

const UA_NS0ID_CREATESESSIONREQUEST_ENCODING_DEFAULTJSON = 15138

const UA_NS0ID_CREATESESSIONRESPONSE_ENCODING_DEFAULTJSON = 15139

const UA_NS0ID_USERIDENTITYTOKEN_ENCODING_DEFAULTJSON = 15140

const UA_NS0ID_ANONYMOUSIDENTITYTOKEN_ENCODING_DEFAULTJSON = 15141

const UA_NS0ID_USERNAMEIDENTITYTOKEN_ENCODING_DEFAULTJSON = 15142

const UA_NS0ID_X509IDENTITYTOKEN_ENCODING_DEFAULTJSON = 15143

const UA_NS0ID_ISSUEDIDENTITYTOKEN_ENCODING_DEFAULTJSON = 15144

const UA_NS0ID_ACTIVATESESSIONREQUEST_ENCODING_DEFAULTJSON = 15145

const UA_NS0ID_ACTIVATESESSIONRESPONSE_ENCODING_DEFAULTJSON = 15146

const UA_NS0ID_CLOSESESSIONREQUEST_ENCODING_DEFAULTJSON = 15147

const UA_NS0ID_CLOSESESSIONRESPONSE_ENCODING_DEFAULTJSON = 15148

const UA_NS0ID_CANCELREQUEST_ENCODING_DEFAULTJSON = 15149

const UA_NS0ID_CANCELRESPONSE_ENCODING_DEFAULTJSON = 15150

const UA_NS0ID_NODEATTRIBUTES_ENCODING_DEFAULTJSON = 15151

const UA_NS0ID_OBJECTATTRIBUTES_ENCODING_DEFAULTJSON = 15152

const UA_NS0ID_VARIABLEATTRIBUTES_ENCODING_DEFAULTJSON = 15153

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTTYPE_DISCOVERYADDRESS_NETWORKINTERFACE = 15154

const UA_NS0ID_BROKERCONNECTIONTRANSPORTTYPE = 15155

const UA_NS0ID_BROKERCONNECTIONTRANSPORTTYPE_RESOURCEURI = 15156

const UA_NS0ID_METHODATTRIBUTES_ENCODING_DEFAULTJSON = 15157

const UA_NS0ID_OBJECTTYPEATTRIBUTES_ENCODING_DEFAULTJSON = 15158

const UA_NS0ID_VARIABLETYPEATTRIBUTES_ENCODING_DEFAULTJSON = 15159

const UA_NS0ID_REFERENCETYPEATTRIBUTES_ENCODING_DEFAULTJSON = 15160

const UA_NS0ID_DATATYPEATTRIBUTES_ENCODING_DEFAULTJSON = 15161

const UA_NS0ID_VIEWATTRIBUTES_ENCODING_DEFAULTJSON = 15162

const UA_NS0ID_GENERICATTRIBUTEVALUE_ENCODING_DEFAULTJSON = 15163

const UA_NS0ID_GENERICATTRIBUTES_ENCODING_DEFAULTJSON = 15164

const UA_NS0ID_ADDNODESITEM_ENCODING_DEFAULTJSON = 15165

const UA_NS0ID_ADDNODESRESULT_ENCODING_DEFAULTJSON = 15166

const UA_NS0ID_ADDNODESREQUEST_ENCODING_DEFAULTJSON = 15167

const UA_NS0ID_ADDNODESRESPONSE_ENCODING_DEFAULTJSON = 15168

const UA_NS0ID_ADDREFERENCESITEM_ENCODING_DEFAULTJSON = 15169

const UA_NS0ID_ADDREFERENCESREQUEST_ENCODING_DEFAULTJSON = 15170

const UA_NS0ID_ADDREFERENCESRESPONSE_ENCODING_DEFAULTJSON = 15171

const UA_NS0ID_DELETENODESITEM_ENCODING_DEFAULTJSON = 15172

const UA_NS0ID_DELETENODESREQUEST_ENCODING_DEFAULTJSON = 15173

const UA_NS0ID_DELETENODESRESPONSE_ENCODING_DEFAULTJSON = 15174

const UA_NS0ID_DELETEREFERENCESITEM_ENCODING_DEFAULTJSON = 15175

const UA_NS0ID_DELETEREFERENCESREQUEST_ENCODING_DEFAULTJSON = 15176

const UA_NS0ID_DELETEREFERENCESRESPONSE_ENCODING_DEFAULTJSON = 15177

const UA_NS0ID_BROKERCONNECTIONTRANSPORTTYPE_AUTHENTICATIONPROFILEURI = 15178

const UA_NS0ID_VIEWDESCRIPTION_ENCODING_DEFAULTJSON = 15179

const UA_NS0ID_BROWSEDESCRIPTION_ENCODING_DEFAULTJSON = 15180

const UA_NS0ID_USERCREDENTIALCERTIFICATETYPE = 15181

const UA_NS0ID_REFERENCEDESCRIPTION_ENCODING_DEFAULTJSON = 15182

const UA_NS0ID_BROWSERESULT_ENCODING_DEFAULTJSON = 15183

const UA_NS0ID_BROWSEREQUEST_ENCODING_DEFAULTJSON = 15184

const UA_NS0ID_BROWSERESPONSE_ENCODING_DEFAULTJSON = 15185

const UA_NS0ID_BROWSENEXTREQUEST_ENCODING_DEFAULTJSON = 15186

const UA_NS0ID_BROWSENEXTRESPONSE_ENCODING_DEFAULTJSON = 15187

const UA_NS0ID_RELATIVEPATHELEMENT_ENCODING_DEFAULTJSON = 15188

const UA_NS0ID_RELATIVEPATH_ENCODING_DEFAULTJSON = 15189

const UA_NS0ID_BROWSEPATH_ENCODING_DEFAULTJSON = 15190

const UA_NS0ID_BROWSEPATHTARGET_ENCODING_DEFAULTJSON = 15191

const UA_NS0ID_BROWSEPATHRESULT_ENCODING_DEFAULTJSON = 15192

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSREQUEST_ENCODING_DEFAULTJSON = 15193

const UA_NS0ID_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE_ENCODING_DEFAULTJSON = 15194

const UA_NS0ID_REGISTERNODESREQUEST_ENCODING_DEFAULTJSON = 15195

const UA_NS0ID_REGISTERNODESRESPONSE_ENCODING_DEFAULTJSON = 15196

const UA_NS0ID_UNREGISTERNODESREQUEST_ENCODING_DEFAULTJSON = 15197

const UA_NS0ID_UNREGISTERNODESRESPONSE_ENCODING_DEFAULTJSON = 15198

const UA_NS0ID_ENDPOINTCONFIGURATION_ENCODING_DEFAULTJSON = 15199

const UA_NS0ID_QUERYDATADESCRIPTION_ENCODING_DEFAULTJSON = 15200

const UA_NS0ID_NODETYPEDESCRIPTION_ENCODING_DEFAULTJSON = 15201

const UA_NS0ID_QUERYDATASET_ENCODING_DEFAULTJSON = 15202

const UA_NS0ID_NODEREFERENCE_ENCODING_DEFAULTJSON = 15203

const UA_NS0ID_CONTENTFILTERELEMENT_ENCODING_DEFAULTJSON = 15204

const UA_NS0ID_CONTENTFILTER_ENCODING_DEFAULTJSON = 15205

const UA_NS0ID_FILTEROPERAND_ENCODING_DEFAULTJSON = 15206

const UA_NS0ID_ELEMENTOPERAND_ENCODING_DEFAULTJSON = 15207

const UA_NS0ID_LITERALOPERAND_ENCODING_DEFAULTJSON = 15208

const UA_NS0ID_ATTRIBUTEOPERAND_ENCODING_DEFAULTJSON = 15209

const UA_NS0ID_SIMPLEATTRIBUTEOPERAND_ENCODING_DEFAULTJSON = 15210

const UA_NS0ID_CONTENTFILTERELEMENTRESULT_ENCODING_DEFAULTJSON = 15211

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_GETSECURITYKEYS = 15212

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_GETSECURITYKEYS_INPUTARGUMENTS = 15213

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_GETSECURITYKEYS_OUTPUTARGUMENTS = 15214

const UA_NS0ID_PUBLISHSUBSCRIBE_GETSECURITYKEYS = 15215

const UA_NS0ID_PUBLISHSUBSCRIBE_GETSECURITYKEYS_INPUTARGUMENTS = 15216

const UA_NS0ID_PUBLISHSUBSCRIBE_GETSECURITYKEYS_OUTPUTARGUMENTS = 15217

const UA_NS0ID_GETSECURITYKEYSMETHODTYPE = 15218

const UA_NS0ID_GETSECURITYKEYSMETHODTYPE_INPUTARGUMENTS = 15219

const UA_NS0ID_GETSECURITYKEYSMETHODTYPE_OUTPUTARGUMENTS = 15220

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_DATASETMETADATA = 15221

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER = 15222

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS = 15223

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_STATE = 15224

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_ENABLE = 15225

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_DISABLE = 15226

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_TRANSPORTSETTINGS = 15227

const UA_NS0ID_CONTENTFILTERRESULT_ENCODING_DEFAULTJSON = 15228

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETMETADATA = 15229

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER = 15230

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS = 15231

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_STATE = 15232

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_ENABLE = 15233

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_DISABLE = 15234

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_TRANSPORTSETTINGS = 15235

const UA_NS0ID_PARSINGRESULT_ENCODING_DEFAULTJSON = 15236

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETMETADATA = 15237

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER = 15238

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS = 15239

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_STATE = 15240

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_ENABLE = 15241

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_DISABLE = 15242

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_TRANSPORTSETTINGS = 15243

const UA_NS0ID_QUERYFIRSTREQUEST_ENCODING_DEFAULTJSON = 15244

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETMETADATA = 15245

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTTYPE_RESOURCEURI = 15246

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTTYPE_AUTHENTICATIONPROFILEURI = 15247

const UA_NS0ID_CREATECREDENTIALMETHODTYPE = 15248

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTTYPE_REQUESTEDDELIVERYGUARANTEE = 15249

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE_RESOURCEURI = 15250

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE_AUTHENTICATIONPROFILEURI = 15251

const UA_NS0ID_QUERYFIRSTRESPONSE_ENCODING_DEFAULTJSON = 15252

const UA_NS0ID_CREATECREDENTIALMETHODTYPE_INPUTARGUMENTS = 15253

const UA_NS0ID_QUERYNEXTREQUEST_ENCODING_DEFAULTJSON = 15254

const UA_NS0ID_QUERYNEXTRESPONSE_ENCODING_DEFAULTJSON = 15255

const UA_NS0ID_READVALUEID_ENCODING_DEFAULTJSON = 15256

const UA_NS0ID_READREQUEST_ENCODING_DEFAULTJSON = 15257

const UA_NS0ID_READRESPONSE_ENCODING_DEFAULTJSON = 15258

const UA_NS0ID_HISTORYREADVALUEID_ENCODING_DEFAULTJSON = 15259

const UA_NS0ID_HISTORYREADRESULT_ENCODING_DEFAULTJSON = 15260

const UA_NS0ID_HISTORYREADDETAILS_ENCODING_DEFAULTJSON = 15261

const UA_NS0ID_READEVENTDETAILS_ENCODING_DEFAULTJSON = 15262

const UA_NS0ID_READRAWMODIFIEDDETAILS_ENCODING_DEFAULTJSON = 15263

const UA_NS0ID_READPROCESSEDDETAILS_ENCODING_DEFAULTJSON = 15264

const UA_NS0ID_PUBSUBGROUPTYPE_STATUS = 15265

const UA_NS0ID_PUBSUBGROUPTYPE_STATUS_STATE = 15266

const UA_NS0ID_PUBSUBGROUPTYPE_STATUS_ENABLE = 15267

const UA_NS0ID_PUBSUBGROUPTYPE_STATUS_DISABLE = 15268

const UA_NS0ID_READATTIMEDETAILS_ENCODING_DEFAULTJSON = 15269

const UA_NS0ID_HISTORYDATA_ENCODING_DEFAULTJSON = 15270

const UA_NS0ID_MODIFICATIONINFO_ENCODING_DEFAULTJSON = 15271

const UA_NS0ID_HISTORYMODIFIEDDATA_ENCODING_DEFAULTJSON = 15272

const UA_NS0ID_HISTORYEVENT_ENCODING_DEFAULTJSON = 15273

const UA_NS0ID_HISTORYREADREQUEST_ENCODING_DEFAULTJSON = 15274

const UA_NS0ID_HISTORYREADRESPONSE_ENCODING_DEFAULTJSON = 15275

const UA_NS0ID_WRITEVALUE_ENCODING_DEFAULTJSON = 15276

const UA_NS0ID_WRITEREQUEST_ENCODING_DEFAULTJSON = 15277

const UA_NS0ID_WRITERESPONSE_ENCODING_DEFAULTJSON = 15278

const UA_NS0ID_HISTORYUPDATEDETAILS_ENCODING_DEFAULTJSON = 15279

const UA_NS0ID_UPDATEDATADETAILS_ENCODING_DEFAULTJSON = 15280

const UA_NS0ID_UPDATESTRUCTUREDATADETAILS_ENCODING_DEFAULTJSON = 15281

const UA_NS0ID_UPDATEEVENTDETAILS_ENCODING_DEFAULTJSON = 15282

const UA_NS0ID_DELETERAWMODIFIEDDETAILS_ENCODING_DEFAULTJSON = 15283

const UA_NS0ID_DELETEATTIMEDETAILS_ENCODING_DEFAULTJSON = 15284

const UA_NS0ID_DELETEEVENTDETAILS_ENCODING_DEFAULTJSON = 15285

const UA_NS0ID_HISTORYUPDATERESULT_ENCODING_DEFAULTJSON = 15286

const UA_NS0ID_HISTORYUPDATEREQUEST_ENCODING_DEFAULTJSON = 15287

const UA_NS0ID_HISTORYUPDATERESPONSE_ENCODING_DEFAULTJSON = 15288

const UA_NS0ID_CALLMETHODREQUEST_ENCODING_DEFAULTJSON = 15289

const UA_NS0ID_CALLMETHODRESULT_ENCODING_DEFAULTJSON = 15290

const UA_NS0ID_CALLREQUEST_ENCODING_DEFAULTJSON = 15291

const UA_NS0ID_CALLRESPONSE_ENCODING_DEFAULTJSON = 15292

const UA_NS0ID_MONITORINGFILTER_ENCODING_DEFAULTJSON = 15293

const UA_NS0ID_DATACHANGEFILTER_ENCODING_DEFAULTJSON = 15294

const UA_NS0ID_EVENTFILTER_ENCODING_DEFAULTJSON = 15295

const UA_NS0ID_HASDATASETWRITER = 15296

const UA_NS0ID_HASDATASETREADER = 15297

const UA_NS0ID_DATASETWRITERTYPE = 15298

const UA_NS0ID_DATASETWRITERTYPE_STATUS = 15299

const UA_NS0ID_DATASETWRITERTYPE_STATUS_STATE = 15300

const UA_NS0ID_DATASETWRITERTYPE_STATUS_ENABLE = 15301

const UA_NS0ID_DATASETWRITERTYPE_STATUS_DISABLE = 15302

const UA_NS0ID_DATASETWRITERTYPE_TRANSPORTSETTINGS = 15303

const UA_NS0ID_AGGREGATECONFIGURATION_ENCODING_DEFAULTJSON = 15304

const UA_NS0ID_DATASETWRITERTRANSPORTTYPE = 15305

const UA_NS0ID_DATASETREADERTYPE = 15306

const UA_NS0ID_DATASETREADERTYPE_STATUS = 15307

const UA_NS0ID_DATASETREADERTYPE_STATUS_STATE = 15308

const UA_NS0ID_DATASETREADERTYPE_STATUS_ENABLE = 15309

const UA_NS0ID_DATASETREADERTYPE_STATUS_DISABLE = 15310

const UA_NS0ID_DATASETREADERTYPE_TRANSPORTSETTINGS = 15311

const UA_NS0ID_AGGREGATEFILTER_ENCODING_DEFAULTJSON = 15312

const UA_NS0ID_MONITORINGFILTERRESULT_ENCODING_DEFAULTJSON = 15313

const UA_NS0ID_EVENTFILTERRESULT_ENCODING_DEFAULTJSON = 15314

const UA_NS0ID_AGGREGATEFILTERRESULT_ENCODING_DEFAULTJSON = 15315

const UA_NS0ID_DATASETREADERTYPE_SUBSCRIBEDDATASET = 15316

const UA_NS0ID_ELSEGUARDVARIABLETYPE = 15317

const UA_NS0ID_BASEANALOGTYPE = 15318

const UA_NS0ID_DATASETREADERTRANSPORTTYPE = 15319

const UA_NS0ID_MONITORINGPARAMETERS_ENCODING_DEFAULTJSON = 15320

const UA_NS0ID_MONITOREDITEMCREATEREQUEST_ENCODING_DEFAULTJSON = 15321

const UA_NS0ID_MONITOREDITEMCREATERESULT_ENCODING_DEFAULTJSON = 15322

const UA_NS0ID_CREATEMONITOREDITEMSREQUEST_ENCODING_DEFAULTJSON = 15323

const UA_NS0ID_CREATEMONITOREDITEMSRESPONSE_ENCODING_DEFAULTJSON = 15324

const UA_NS0ID_MONITOREDITEMMODIFYREQUEST_ENCODING_DEFAULTJSON = 15325

const UA_NS0ID_MONITOREDITEMMODIFYRESULT_ENCODING_DEFAULTJSON = 15326

const UA_NS0ID_MODIFYMONITOREDITEMSREQUEST_ENCODING_DEFAULTJSON = 15327

const UA_NS0ID_MODIFYMONITOREDITEMSRESPONSE_ENCODING_DEFAULTJSON = 15328

const UA_NS0ID_SETMONITORINGMODEREQUEST_ENCODING_DEFAULTJSON = 15329

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE_REQUESTEDDELIVERYGUARANTEE = 15330

const UA_NS0ID_SETMONITORINGMODERESPONSE_ENCODING_DEFAULTJSON = 15331

const UA_NS0ID_SETTRIGGERINGREQUEST_ENCODING_DEFAULTJSON = 15332

const UA_NS0ID_SETTRIGGERINGRESPONSE_ENCODING_DEFAULTJSON = 15333

const UA_NS0ID_BROKERDATASETREADERTRANSPORTTYPE_RESOURCEURI = 15334

const UA_NS0ID_DELETEMONITOREDITEMSREQUEST_ENCODING_DEFAULTJSON = 15335

const UA_NS0ID_DELETEMONITOREDITEMSRESPONSE_ENCODING_DEFAULTJSON = 15336

const UA_NS0ID_CREATESUBSCRIPTIONREQUEST_ENCODING_DEFAULTJSON = 15337

const UA_NS0ID_CREATESUBSCRIPTIONRESPONSE_ENCODING_DEFAULTJSON = 15338

const UA_NS0ID_MODIFYSUBSCRIPTIONREQUEST_ENCODING_DEFAULTJSON = 15339

const UA_NS0ID_MODIFYSUBSCRIPTIONRESPONSE_ENCODING_DEFAULTJSON = 15340

const UA_NS0ID_SETPUBLISHINGMODEREQUEST_ENCODING_DEFAULTJSON = 15341

const UA_NS0ID_SETPUBLISHINGMODERESPONSE_ENCODING_DEFAULTJSON = 15342

const UA_NS0ID_NOTIFICATIONMESSAGE_ENCODING_DEFAULTJSON = 15343

const UA_NS0ID_NOTIFICATIONDATA_ENCODING_DEFAULTJSON = 15344

const UA_NS0ID_DATACHANGENOTIFICATION_ENCODING_DEFAULTJSON = 15345

const UA_NS0ID_MONITOREDITEMNOTIFICATION_ENCODING_DEFAULTJSON = 15346

const UA_NS0ID_EVENTNOTIFICATIONLIST_ENCODING_DEFAULTJSON = 15347

const UA_NS0ID_EVENTFIELDLIST_ENCODING_DEFAULTJSON = 15348

const UA_NS0ID_HISTORYEVENTFIELDLIST_ENCODING_DEFAULTJSON = 15349

const UA_NS0ID_STATUSCHANGENOTIFICATION_ENCODING_DEFAULTJSON = 15350

const UA_NS0ID_SUBSCRIPTIONACKNOWLEDGEMENT_ENCODING_DEFAULTJSON = 15351

const UA_NS0ID_PUBLISHREQUEST_ENCODING_DEFAULTJSON = 15352

const UA_NS0ID_PUBLISHRESPONSE_ENCODING_DEFAULTJSON = 15353

const UA_NS0ID_REPUBLISHREQUEST_ENCODING_DEFAULTJSON = 15354

const UA_NS0ID_REPUBLISHRESPONSE_ENCODING_DEFAULTJSON = 15355

const UA_NS0ID_TRANSFERRESULT_ENCODING_DEFAULTJSON = 15356

const UA_NS0ID_TRANSFERSUBSCRIPTIONSREQUEST_ENCODING_DEFAULTJSON = 15357

const UA_NS0ID_TRANSFERSUBSCRIPTIONSRESPONSE_ENCODING_DEFAULTJSON = 15358

const UA_NS0ID_DELETESUBSCRIPTIONSREQUEST_ENCODING_DEFAULTJSON = 15359

const UA_NS0ID_DELETESUBSCRIPTIONSRESPONSE_ENCODING_DEFAULTJSON = 15360

const UA_NS0ID_BUILDINFO_ENCODING_DEFAULTJSON = 15361

const UA_NS0ID_REDUNDANTSERVERDATATYPE_ENCODING_DEFAULTJSON = 15362

const UA_NS0ID_ENDPOINTURLLISTDATATYPE_ENCODING_DEFAULTJSON = 15363

const UA_NS0ID_NETWORKGROUPDATATYPE_ENCODING_DEFAULTJSON = 15364

const UA_NS0ID_SAMPLINGINTERVALDIAGNOSTICSDATATYPE_ENCODING_DEFAULTJSON = 15365

const UA_NS0ID_SERVERDIAGNOSTICSSUMMARYDATATYPE_ENCODING_DEFAULTJSON = 15366

const UA_NS0ID_SERVERSTATUSDATATYPE_ENCODING_DEFAULTJSON = 15367

const UA_NS0ID_SESSIONDIAGNOSTICSDATATYPE_ENCODING_DEFAULTJSON = 15368

const UA_NS0ID_SESSIONSECURITYDIAGNOSTICSDATATYPE_ENCODING_DEFAULTJSON = 15369

const UA_NS0ID_SERVICECOUNTERDATATYPE_ENCODING_DEFAULTJSON = 15370

const UA_NS0ID_STATUSRESULT_ENCODING_DEFAULTJSON = 15371

const UA_NS0ID_SUBSCRIPTIONDIAGNOSTICSDATATYPE_ENCODING_DEFAULTJSON = 15372

const UA_NS0ID_MODELCHANGESTRUCTUREDATATYPE_ENCODING_DEFAULTJSON = 15373

const UA_NS0ID_SEMANTICCHANGESTRUCTUREDATATYPE_ENCODING_DEFAULTJSON = 15374

const UA_NS0ID_RANGE_ENCODING_DEFAULTJSON = 15375

const UA_NS0ID_EUINFORMATION_ENCODING_DEFAULTJSON = 15376

const UA_NS0ID_COMPLEXNUMBERTYPE_ENCODING_DEFAULTJSON = 15377

const UA_NS0ID_DOUBLECOMPLEXNUMBERTYPE_ENCODING_DEFAULTJSON = 15378

const UA_NS0ID_AXISINFORMATION_ENCODING_DEFAULTJSON = 15379

const UA_NS0ID_XVTYPE_ENCODING_DEFAULTJSON = 15380

const UA_NS0ID_PROGRAMDIAGNOSTICDATATYPE_ENCODING_DEFAULTJSON = 15381

const UA_NS0ID_ANNOTATION_ENCODING_DEFAULTJSON = 15382

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE = 15383

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_CREATESESSIONID = 15384

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_CREATECLIENTNAME = 15385

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_INVOCATIONCREATIONTIME = 15386

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTTRANSITIONTIME = 15387

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODCALL = 15388

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODSESSIONID = 15389

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODINPUTARGUMENTS = 15390

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODOUTPUTARGUMENTS = 15391

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODINPUTVALUES = 15392

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODOUTPUTVALUES = 15393

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODCALLTIME = 15394

const UA_NS0ID_PROGRAMDIAGNOSTIC2TYPE_LASTMETHODRETURNSTATUS = 15395

const UA_NS0ID_PROGRAMDIAGNOSTIC2DATATYPE = 15396

const UA_NS0ID_PROGRAMDIAGNOSTIC2DATATYPE_ENCODING_DEFAULTBINARY = 15397

const UA_NS0ID_OPCUA_BINARYSCHEMA_PROGRAMDIAGNOSTIC2DATATYPE = 15398

const UA_NS0ID_OPCUA_BINARYSCHEMA_PROGRAMDIAGNOSTIC2DATATYPE_DATATYPEVERSION = 15399

const UA_NS0ID_OPCUA_BINARYSCHEMA_PROGRAMDIAGNOSTIC2DATATYPE_DICTIONARYFRAGMENT = 15400

const UA_NS0ID_PROGRAMDIAGNOSTIC2DATATYPE_ENCODING_DEFAULTXML = 15401

const UA_NS0ID_OPCUA_XMLSCHEMA_PROGRAMDIAGNOSTIC2DATATYPE = 15402

const UA_NS0ID_OPCUA_XMLSCHEMA_PROGRAMDIAGNOSTIC2DATATYPE_DATATYPEVERSION = 15403

const UA_NS0ID_OPCUA_XMLSCHEMA_PROGRAMDIAGNOSTIC2DATATYPE_DICTIONARYFRAGMENT = 15404

const UA_NS0ID_PROGRAMDIAGNOSTIC2DATATYPE_ENCODING_DEFAULTJSON = 15405

const UA_NS0ID_ACCESSLEVELEXTYPE = 15406

const UA_NS0ID_ACCESSLEVELEXTYPE_OPTIONSETVALUES = 15407

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_APPLICATIONSEXCLUDE = 15408

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ENDPOINTSEXCLUDE = 15409

const UA_NS0ID_ROLETYPE_APPLICATIONSEXCLUDE = 15410

const UA_NS0ID_ROLETYPE_ENDPOINTSEXCLUDE = 15411

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_APPLICATIONSEXCLUDE = 15412

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ENDPOINTSEXCLUDE = 15413

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_APPLICATIONSEXCLUDE = 15414

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ENDPOINTSEXCLUDE = 15415

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_APPLICATIONSEXCLUDE = 15416

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ENDPOINTSEXCLUDE = 15417

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_APPLICATIONSEXCLUDE = 15418

const UA_NS0ID_BROKERDATASETREADERTRANSPORTTYPE_AUTHENTICATIONPROFILEURI = 15419

const UA_NS0ID_BROKERDATASETREADERTRANSPORTTYPE_REQUESTEDDELIVERYGUARANTEE = 15420

const UA_NS0ID_SIMPLETYPEDESCRIPTION_ENCODING_DEFAULTBINARY = 15421

const UA_NS0ID_UABINARYFILEDATATYPE_ENCODING_DEFAULTBINARY = 15422

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ENDPOINTSEXCLUDE = 15423

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_APPLICATIONSEXCLUDE = 15424

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ENDPOINTSEXCLUDE = 15425

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_APPLICATIONSEXCLUDE = 15426

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ENDPOINTSEXCLUDE = 15427

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_APPLICATIONSEXCLUDE = 15428

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ENDPOINTSEXCLUDE = 15429

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_APPLICATIONSEXCLUDE = 15430

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_GETSECURITYGROUP = 15431

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_GETSECURITYGROUP_INPUTARGUMENTS = 15432

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_GETSECURITYGROUP_OUTPUTARGUMENTS = 15433

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SECURITYGROUPS = 15434

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SECURITYGROUPS_ADDSECURITYGROUP = 15435

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SECURITYGROUPS_ADDSECURITYGROUP_INPUTARGUMENTS = 15436

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SECURITYGROUPS_ADDSECURITYGROUP_OUTPUTARGUMENTS = 15437

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SECURITYGROUPS_REMOVESECURITYGROUP = 15438

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SECURITYGROUPS_REMOVESECURITYGROUP_INPUTARGUMENTS = 15439

const UA_NS0ID_PUBLISHSUBSCRIBE_GETSECURITYGROUP = 15440

const UA_NS0ID_PUBLISHSUBSCRIBE_GETSECURITYGROUP_INPUTARGUMENTS = 15441

const UA_NS0ID_PUBLISHSUBSCRIBE_GETSECURITYGROUP_OUTPUTARGUMENTS = 15442

const UA_NS0ID_PUBLISHSUBSCRIBE_SECURITYGROUPS = 15443

const UA_NS0ID_PUBLISHSUBSCRIBE_SECURITYGROUPS_ADDSECURITYGROUP = 15444

const UA_NS0ID_PUBLISHSUBSCRIBE_SECURITYGROUPS_ADDSECURITYGROUP_INPUTARGUMENTS = 15445

const UA_NS0ID_PUBLISHSUBSCRIBE_SECURITYGROUPS_ADDSECURITYGROUP_OUTPUTARGUMENTS = 15446

const UA_NS0ID_PUBLISHSUBSCRIBE_SECURITYGROUPS_REMOVESECURITYGROUP = 15447

const UA_NS0ID_PUBLISHSUBSCRIBE_SECURITYGROUPS_REMOVESECURITYGROUP_INPUTARGUMENTS = 15448

const UA_NS0ID_GETSECURITYGROUPMETHODTYPE = 15449

const UA_NS0ID_GETSECURITYGROUPMETHODTYPE_INPUTARGUMENTS = 15450

const UA_NS0ID_GETSECURITYGROUPMETHODTYPE_OUTPUTARGUMENTS = 15451

const UA_NS0ID_SECURITYGROUPFOLDERTYPE = 15452

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPFOLDERNAME_PLACEHOLDER = 15453

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPFOLDERNAME_PLACEHOLDER_ADDSECURITYGROUP = 15454

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPFOLDERNAME_PLACEHOLDER_ADDSECURITYGROUP_INPUTARGUMENTS = 15455

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPFOLDERNAME_PLACEHOLDER_ADDSECURITYGROUP_OUTPUTARGUMENTS = 15456

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPFOLDERNAME_PLACEHOLDER_REMOVESECURITYGROUP = 15457

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPFOLDERNAME_PLACEHOLDER_REMOVESECURITYGROUP_INPUTARGUMENTS = 15458

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPNAME_PLACEHOLDER = 15459

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_SECURITYGROUPNAME_PLACEHOLDER_SECURITYGROUPID = 15460

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_ADDSECURITYGROUP = 15461

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_ADDSECURITYGROUP_INPUTARGUMENTS = 15462

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_ADDSECURITYGROUP_OUTPUTARGUMENTS = 15463

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_REMOVESECURITYGROUP = 15464

const UA_NS0ID_SECURITYGROUPFOLDERTYPE_REMOVESECURITYGROUP_INPUTARGUMENTS = 15465

const UA_NS0ID_ADDSECURITYGROUPMETHODTYPE = 15466

const UA_NS0ID_ADDSECURITYGROUPMETHODTYPE_INPUTARGUMENTS = 15467

const UA_NS0ID_ADDSECURITYGROUPMETHODTYPE_OUTPUTARGUMENTS = 15468

const UA_NS0ID_REMOVESECURITYGROUPMETHODTYPE = 15469

const UA_NS0ID_REMOVESECURITYGROUPMETHODTYPE_INPUTARGUMENTS = 15470

const UA_NS0ID_SECURITYGROUPTYPE = 15471

const UA_NS0ID_SECURITYGROUPTYPE_SECURITYGROUPID = 15472

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_EXTENSIONFIELDS = 15473

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_EXTENSIONFIELDS_ADDEXTENSIONFIELD = 15474

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_EXTENSIONFIELDS_ADDEXTENSIONFIELD_INPUTARGUMENTS = 15475

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_EXTENSIONFIELDS_ADDEXTENSIONFIELD_OUTPUTARGUMENTS = 15476

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD = 15477

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD_INPUTARGUMENTS = 15478

const UA_NS0ID_BROKERCONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15479

const UA_NS0ID_WRITERGROUPDATATYPE = 15480

const UA_NS0ID_PUBLISHEDDATASETTYPE_EXTENSIONFIELDS = 15481

const UA_NS0ID_PUBLISHEDDATASETTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD = 15482

const UA_NS0ID_PUBLISHEDDATASETTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD_INPUTARGUMENTS = 15483

const UA_NS0ID_PUBLISHEDDATASETTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD_OUTPUTARGUMENTS = 15484

const UA_NS0ID_PUBLISHEDDATASETTYPE_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD = 15485

const UA_NS0ID_PUBLISHEDDATASETTYPE_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD_INPUTARGUMENTS = 15486

const UA_NS0ID_STRUCTUREDESCRIPTION = 15487

const UA_NS0ID_ENUMDESCRIPTION = 15488

const UA_NS0ID_EXTENSIONFIELDSTYPE = 15489

const UA_NS0ID_EXTENSIONFIELDSTYPE_EXTENSIONFIELDNAME_PLACEHOLDER = 15490

const UA_NS0ID_EXTENSIONFIELDSTYPE_ADDEXTENSIONFIELD = 15491

const UA_NS0ID_EXTENSIONFIELDSTYPE_ADDEXTENSIONFIELD_INPUTARGUMENTS = 15492

const UA_NS0ID_EXTENSIONFIELDSTYPE_ADDEXTENSIONFIELD_OUTPUTARGUMENTS = 15493

const UA_NS0ID_EXTENSIONFIELDSTYPE_REMOVEEXTENSIONFIELD = 15494

const UA_NS0ID_EXTENSIONFIELDSTYPE_REMOVEEXTENSIONFIELD_INPUTARGUMENTS = 15495

const UA_NS0ID_ADDEXTENSIONFIELDMETHODTYPE = 15496

const UA_NS0ID_ADDEXTENSIONFIELDMETHODTYPE_INPUTARGUMENTS = 15497

const UA_NS0ID_ADDEXTENSIONFIELDMETHODTYPE_OUTPUTARGUMENTS = 15498

const UA_NS0ID_REMOVEEXTENSIONFIELDMETHODTYPE = 15499

const UA_NS0ID_REMOVEEXTENSIONFIELDMETHODTYPE_INPUTARGUMENTS = 15500

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIMPLETYPEDESCRIPTION = 15501

const UA_NS0ID_NETWORKADDRESSDATATYPE = 15502

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_EXTENSIONFIELDS = 15503

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD = 15504

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD_INPUTARGUMENTS = 15505

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD_OUTPUTARGUMENTS = 15506

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD = 15507

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD_INPUTARGUMENTS = 15508

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIMPLETYPEDESCRIPTION_DATATYPEVERSION = 15509

const UA_NS0ID_NETWORKADDRESSURLDATATYPE = 15510

const UA_NS0ID_PUBLISHEDEVENTSTYPE_EXTENSIONFIELDS = 15511

const UA_NS0ID_PUBLISHEDEVENTSTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD = 15512

const UA_NS0ID_PUBLISHEDEVENTSTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD_INPUTARGUMENTS = 15513

const UA_NS0ID_PUBLISHEDEVENTSTYPE_EXTENSIONFIELDS_ADDEXTENSIONFIELD_OUTPUTARGUMENTS = 15514

const UA_NS0ID_PUBLISHEDEVENTSTYPE_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD = 15515

const UA_NS0ID_PUBLISHEDEVENTSTYPE_EXTENSIONFIELDS_REMOVEEXTENSIONFIELD_INPUTARGUMENTS = 15516

const UA_NS0ID_PUBLISHEDEVENTSTYPE_MODIFYFIELDSELECTION_OUTPUTARGUMENTS = 15517

const UA_NS0ID_PUBLISHEDEVENTSTYPEMODIFYFIELDSELECTIONMETHODTYPE_OUTPUTARGUMENTS = 15518

const UA_NS0ID_OPCUA_BINARYSCHEMA_SIMPLETYPEDESCRIPTION_DICTIONARYFRAGMENT = 15519

const UA_NS0ID_READERGROUPDATATYPE = 15520

const UA_NS0ID_OPCUA_BINARYSCHEMA_UABINARYFILEDATATYPE = 15521

const UA_NS0ID_OPCUA_BINARYSCHEMA_UABINARYFILEDATATYPE_DATATYPEVERSION = 15522

const UA_NS0ID_OPCUA_BINARYSCHEMA_UABINARYFILEDATATYPE_DICTIONARYFRAGMENT = 15523

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERCONNECTIONTRANSPORTDATATYPE = 15524

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERCONNECTIONTRANSPORTDATATYPE_DATATYPEVERSION = 15525

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERCONNECTIONTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15526

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ENDPOINTSEXCLUDE = 15527

const UA_NS0ID_ENDPOINTTYPE = 15528

const UA_NS0ID_SIMPLETYPEDESCRIPTION_ENCODING_DEFAULTXML = 15529

const UA_NS0ID_PUBSUBCONFIGURATIONDATATYPE = 15530

const UA_NS0ID_UABINARYFILEDATATYPE_ENCODING_DEFAULTXML = 15531

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTDATATYPE = 15532

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE = 15533

const UA_NS0ID_DATATYPESCHEMAHEADER = 15534

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE = 15535

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_EVENTID = 15536

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_EVENTTYPE = 15537

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_SOURCENODE = 15538

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_SOURCENAME = 15539

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_TIME = 15540

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_RECEIVETIME = 15541

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_LOCALTIME = 15542

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_MESSAGE = 15543

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_SEVERITY = 15544

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_CONNECTIONID = 15545

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_GROUPID = 15546

const UA_NS0ID_PUBSUBSTATUSEVENTTYPE_STATE = 15547

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE = 15548

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_EVENTID = 15549

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_EVENTTYPE = 15550

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_SOURCENODE = 15551

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_SOURCENAME = 15552

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_TIME = 15553

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_RECEIVETIME = 15554

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_LOCALTIME = 15555

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_MESSAGE = 15556

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_SEVERITY = 15557

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_CONNECTIONID = 15558

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_GROUPID = 15559

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_STATE = 15560

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_ACTUAL = 15561

const UA_NS0ID_PUBSUBTRANSPORTLIMITSEXCEEDEVENTTYPE_MAXIMUM = 15562

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE = 15563

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_EVENTID = 15564

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_EVENTTYPE = 15565

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_SOURCENODE = 15566

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_SOURCENAME = 15567

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_TIME = 15568

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_RECEIVETIME = 15569

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_LOCALTIME = 15570

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_MESSAGE = 15571

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_SEVERITY = 15572

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_CONNECTIONID = 15573

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_GROUPID = 15574

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_STATE = 15575

const UA_NS0ID_PUBSUBCOMMUNICATIONFAILUREEVENTTYPE_ERROR = 15576

const UA_NS0ID_DATASETFIELDFLAGS_OPTIONSETVALUES = 15577

const UA_NS0ID_PUBLISHEDDATASETDATATYPE = 15578

const UA_NS0ID_BROKERCONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 15579

const UA_NS0ID_PUBLISHEDDATASETSOURCEDATATYPE = 15580

const UA_NS0ID_PUBLISHEDDATAITEMSDATATYPE = 15581

const UA_NS0ID_PUBLISHEDEVENTSDATATYPE = 15582

const UA_NS0ID_DATASETFIELDCONTENTMASK = 15583

const UA_NS0ID_DATASETFIELDCONTENTMASK_OPTIONSETVALUES = 15584

const UA_NS0ID_OPCUA_XMLSCHEMA_SIMPLETYPEDESCRIPTION = 15585

const UA_NS0ID_OPCUA_XMLSCHEMA_SIMPLETYPEDESCRIPTION_DATATYPEVERSION = 15586

const UA_NS0ID_OPCUA_XMLSCHEMA_SIMPLETYPEDESCRIPTION_DICTIONARYFRAGMENT = 15587

const UA_NS0ID_OPCUA_XMLSCHEMA_UABINARYFILEDATATYPE = 15588

const UA_NS0ID_STRUCTUREDESCRIPTION_ENCODING_DEFAULTXML = 15589

const UA_NS0ID_ENUMDESCRIPTION_ENCODING_DEFAULTXML = 15590

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREDESCRIPTION = 15591

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREDESCRIPTION_DATATYPEVERSION = 15592

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREDESCRIPTION_DICTIONARYFRAGMENT = 15593

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMDESCRIPTION = 15594

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMDESCRIPTION_DATATYPEVERSION = 15595

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMDESCRIPTION_DICTIONARYFRAGMENT = 15596

const UA_NS0ID_DATASETWRITERDATATYPE = 15597

const UA_NS0ID_DATASETWRITERTRANSPORTDATATYPE = 15598

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREDESCRIPTION = 15599

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREDESCRIPTION_DATATYPEVERSION = 15600

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREDESCRIPTION_DICTIONARYFRAGMENT = 15601

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMDESCRIPTION = 15602

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMDESCRIPTION_DATATYPEVERSION = 15603

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMDESCRIPTION_DICTIONARYFRAGMENT = 15604

const UA_NS0ID_DATASETWRITERMESSAGEDATATYPE = 15605

const UA_NS0ID_SERVER_SERVERCAPABILITIES_ROLESET = 15606

const UA_NS0ID_ROLESETTYPE = 15607

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER = 15608

const UA_NS0ID_PUBSUBGROUPDATATYPE = 15609

const UA_NS0ID_OPCUA_XMLSCHEMA_UABINARYFILEDATATYPE_DATATYPEVERSION = 15610

const UA_NS0ID_WRITERGROUPTRANSPORTDATATYPE = 15611

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ADDIDENTITY = 15612

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ADDIDENTITY_INPUTARGUMENTS = 15613

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_REMOVEIDENTITY = 15614

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_REMOVEIDENTITY_INPUTARGUMENTS = 15615

const UA_NS0ID_WRITERGROUPMESSAGEDATATYPE = 15616

const UA_NS0ID_PUBSUBCONNECTIONDATATYPE = 15617

const UA_NS0ID_CONNECTIONTRANSPORTDATATYPE = 15618

const UA_NS0ID_OPCUA_XMLSCHEMA_UABINARYFILEDATATYPE_DICTIONARYFRAGMENT = 15619

const UA_NS0ID_ROLETYPE = 15620

const UA_NS0ID_READERGROUPTRANSPORTDATATYPE = 15621

const UA_NS0ID_READERGROUPMESSAGEDATATYPE = 15622

const UA_NS0ID_DATASETREADERDATATYPE = 15623

const UA_NS0ID_ROLETYPE_ADDIDENTITY = 15624

const UA_NS0ID_ROLETYPE_ADDIDENTITY_INPUTARGUMENTS = 15625

const UA_NS0ID_ROLETYPE_REMOVEIDENTITY = 15626

const UA_NS0ID_ROLETYPE_REMOVEIDENTITY_INPUTARGUMENTS = 15627

const UA_NS0ID_DATASETREADERTRANSPORTDATATYPE = 15628

const UA_NS0ID_DATASETREADERMESSAGEDATATYPE = 15629

const UA_NS0ID_SUBSCRIBEDDATASETDATATYPE = 15630

const UA_NS0ID_TARGETVARIABLESDATATYPE = 15631

const UA_NS0ID_IDENTITYCRITERIATYPE = 15632

const UA_NS0ID_IDENTITYCRITERIATYPE_ENUMVALUES = 15633

const UA_NS0ID_IDENTITYMAPPINGRULETYPE = 15634

const UA_NS0ID_SUBSCRIBEDDATASETMIRRORDATATYPE = 15635

const UA_NS0ID_ADDIDENTITYMETHODTYPE = 15636

const UA_NS0ID_ADDIDENTITYMETHODTYPE_INPUTARGUMENTS = 15637

const UA_NS0ID_REMOVEIDENTITYMETHODTYPE = 15638

const UA_NS0ID_REMOVEIDENTITYMETHODTYPE_INPUTARGUMENTS = 15639

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERCONNECTIONTRANSPORTDATATYPE = 15640

const UA_NS0ID_DATASETORDERINGTYPE_ENUMSTRINGS = 15641

const UA_NS0ID_UADPNETWORKMESSAGECONTENTMASK = 15642

const UA_NS0ID_UADPNETWORKMESSAGECONTENTMASK_OPTIONSETVALUES = 15643

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS = 15644

const UA_NS0ID_UADPWRITERGROUPMESSAGEDATATYPE = 15645

const UA_NS0ID_UADPDATASETMESSAGECONTENTMASK = 15646

const UA_NS0ID_UADPDATASETMESSAGECONTENTMASK_OPTIONSETVALUES = 15647

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ADDIDENTITY = 15648

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ADDIDENTITY_INPUTARGUMENTS = 15649

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_REMOVEIDENTITY = 15650

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_REMOVEIDENTITY_INPUTARGUMENTS = 15651

const UA_NS0ID_UADPDATASETWRITERMESSAGEDATATYPE = 15652

const UA_NS0ID_UADPDATASETREADERMESSAGEDATATYPE = 15653

const UA_NS0ID_JSONNETWORKMESSAGECONTENTMASK = 15654

const UA_NS0ID_JSONNETWORKMESSAGECONTENTMASK_OPTIONSETVALUES = 15655

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER = 15656

const UA_NS0ID_JSONWRITERGROUPMESSAGEDATATYPE = 15657

const UA_NS0ID_JSONDATASETMESSAGECONTENTMASK = 15658

const UA_NS0ID_JSONDATASETMESSAGECONTENTMASK_OPTIONSETVALUES = 15659

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ADDIDENTITY = 15660

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ADDIDENTITY_INPUTARGUMENTS = 15661

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_REMOVEIDENTITY = 15662

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_REMOVEIDENTITY_INPUTARGUMENTS = 15663

const UA_NS0ID_JSONDATASETWRITERMESSAGEDATATYPE = 15664

const UA_NS0ID_JSONDATASETREADERMESSAGEDATATYPE = 15665

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERCONNECTIONTRANSPORTDATATYPE_DATATYPEVERSION = 15666

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTDATATYPE = 15667

const UA_NS0ID_WELLKNOWNROLE_OBSERVER = 15668

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTDATATYPE = 15669

const UA_NS0ID_BROKERDATASETREADERTRANSPORTDATATYPE = 15670

const UA_NS0ID_ENDPOINTTYPE_ENCODING_DEFAULTBINARY = 15671

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ADDIDENTITY = 15672

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ADDIDENTITY_INPUTARGUMENTS = 15673

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_REMOVEIDENTITY = 15674

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_REMOVEIDENTITY_INPUTARGUMENTS = 15675

const UA_NS0ID_DATATYPESCHEMAHEADER_ENCODING_DEFAULTBINARY = 15676

const UA_NS0ID_PUBLISHEDDATASETDATATYPE_ENCODING_DEFAULTBINARY = 15677

const UA_NS0ID_PUBLISHEDDATASETSOURCEDATATYPE_ENCODING_DEFAULTBINARY = 15678

const UA_NS0ID_PUBLISHEDDATAITEMSDATATYPE_ENCODING_DEFAULTBINARY = 15679

const UA_NS0ID_WELLKNOWNROLE_OPERATOR = 15680

const UA_NS0ID_PUBLISHEDEVENTSDATATYPE_ENCODING_DEFAULTBINARY = 15681

const UA_NS0ID_DATASETWRITERDATATYPE_ENCODING_DEFAULTBINARY = 15682

const UA_NS0ID_DATASETWRITERTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15683

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ADDIDENTITY = 15684

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ADDIDENTITY_INPUTARGUMENTS = 15685

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_REMOVEIDENTITY = 15686

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_REMOVEIDENTITY_INPUTARGUMENTS = 15687

const UA_NS0ID_DATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15688

const UA_NS0ID_PUBSUBGROUPDATATYPE_ENCODING_DEFAULTBINARY = 15689

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERCONNECTIONTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15690

const UA_NS0ID_WRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15691

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR = 15692

const UA_NS0ID_WRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15693

const UA_NS0ID_PUBSUBCONNECTIONDATATYPE_ENCODING_DEFAULTBINARY = 15694

const UA_NS0ID_CONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15695

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ADDIDENTITY = 15696

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ADDIDENTITY_INPUTARGUMENTS = 15697

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_REMOVEIDENTITY = 15698

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_REMOVEIDENTITY_INPUTARGUMENTS = 15699

const UA_NS0ID_SIMPLETYPEDESCRIPTION_ENCODING_DEFAULTJSON = 15700

const UA_NS0ID_READERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15701

const UA_NS0ID_READERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15702

const UA_NS0ID_DATASETREADERDATATYPE_ENCODING_DEFAULTBINARY = 15703

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN = 15704

const UA_NS0ID_DATASETREADERTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15705

const UA_NS0ID_DATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15706

const UA_NS0ID_SUBSCRIBEDDATASETDATATYPE_ENCODING_DEFAULTBINARY = 15707

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ADDIDENTITY = 15708

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ADDIDENTITY_INPUTARGUMENTS = 15709

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_REMOVEIDENTITY = 15710

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_REMOVEIDENTITY_INPUTARGUMENTS = 15711

const UA_NS0ID_TARGETVARIABLESDATATYPE_ENCODING_DEFAULTBINARY = 15712

const UA_NS0ID_SUBSCRIBEDDATASETMIRRORDATATYPE_ENCODING_DEFAULTBINARY = 15713

const UA_NS0ID_UABINARYFILEDATATYPE_ENCODING_DEFAULTJSON = 15714

const UA_NS0ID_UADPWRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15715

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN = 15716

const UA_NS0ID_UADPDATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15717

const UA_NS0ID_UADPDATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15718

const UA_NS0ID_JSONWRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15719

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ADDIDENTITY = 15720

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ADDIDENTITY_INPUTARGUMENTS = 15721

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_REMOVEIDENTITY = 15722

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_REMOVEIDENTITY_INPUTARGUMENTS = 15723

const UA_NS0ID_JSONDATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15724

const UA_NS0ID_JSONDATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTBINARY = 15725

const UA_NS0ID_BROKERCONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 15726

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15727

const UA_NS0ID_IDENTITYMAPPINGRULETYPE_ENCODING_DEFAULTXML = 15728

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15729

const UA_NS0ID_OPCUA_XMLSCHEMA_IDENTITYMAPPINGRULETYPE = 15730

const UA_NS0ID_OPCUA_XMLSCHEMA_IDENTITYMAPPINGRULETYPE_DATATYPEVERSION = 15731

const UA_NS0ID_OPCUA_XMLSCHEMA_IDENTITYMAPPINGRULETYPE_DICTIONARYFRAGMENT = 15732

const UA_NS0ID_BROKERDATASETREADERTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 15733

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTTYPE = 15734

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTTYPE_DATATYPEVERSION = 15735

const UA_NS0ID_IDENTITYMAPPINGRULETYPE_ENCODING_DEFAULTBINARY = 15736

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENDPOINTTYPE_DICTIONARYFRAGMENT = 15737

const UA_NS0ID_OPCUA_BINARYSCHEMA_IDENTITYMAPPINGRULETYPE = 15738

const UA_NS0ID_OPCUA_BINARYSCHEMA_IDENTITYMAPPINGRULETYPE_DATATYPEVERSION = 15739

const UA_NS0ID_OPCUA_BINARYSCHEMA_IDENTITYMAPPINGRULETYPE_DICTIONARYFRAGMENT = 15740

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPESCHEMAHEADER = 15741

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPESCHEMAHEADER_DATATYPEVERSION = 15742

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPESCHEMAHEADER_DICTIONARYFRAGMENT = 15743

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE = 15744

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_CLIENTPROCESSINGTIMEOUT = 15745

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_GENERATEFILEFORREAD = 15746

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_GENERATEFILEFORREAD_INPUTARGUMENTS = 15747

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_GENERATEFILEFORREAD_OUTPUTARGUMENTS = 15748

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_GENERATEFILEFORWRITE = 15749

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_GENERATEFILEFORWRITE_OUTPUTARGUMENTS = 15750

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_CLOSEANDCOMMIT = 15751

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_CLOSEANDCOMMIT_INPUTARGUMENTS = 15752

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_CLOSEANDCOMMIT_OUTPUTARGUMENTS = 15753

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER = 15754

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_CURRENTSTATE = 15755

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_CURRENTSTATE_ID = 15756

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_CURRENTSTATE_NAME = 15757

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_CURRENTSTATE_NUMBER = 15758

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 15759

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_LASTTRANSITION = 15760

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_LASTTRANSITION_ID = 15761

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_LASTTRANSITION_NAME = 15762

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_LASTTRANSITION_NUMBER = 15763

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_LASTTRANSITION_TRANSITIONTIME = 15764

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 15765

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATASETDATATYPE = 15766

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATASETDATATYPE_DATATYPEVERSION = 15767

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATASETDATATYPE_DICTIONARYFRAGMENT = 15768

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATASETSOURCEDATATYPE = 15769

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATASETSOURCEDATATYPE_DATATYPEVERSION = 15770

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATASETSOURCEDATATYPE_DICTIONARYFRAGMENT = 15771

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATAITEMSDATATYPE = 15772

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATAITEMSDATATYPE_DATATYPEVERSION = 15773

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDDATAITEMSDATATYPE_DICTIONARYFRAGMENT = 15774

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDEVENTSDATATYPE = 15775

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDEVENTSDATATYPE_DATATYPEVERSION = 15776

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBLISHEDEVENTSDATATYPE_DICTIONARYFRAGMENT = 15777

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERDATATYPE = 15778

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERDATATYPE_DATATYPEVERSION = 15779

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERDATATYPE_DICTIONARYFRAGMENT = 15780

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERTRANSPORTDATATYPE = 15781

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERTRANSPORTDATATYPE_DATATYPEVERSION = 15782

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15783

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERMESSAGEDATATYPE = 15784

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERMESSAGEDATATYPE_DATATYPEVERSION = 15785

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETWRITERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15786

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBGROUPDATATYPE = 15787

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBGROUPDATATYPE_DATATYPEVERSION = 15788

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBGROUPDATATYPE_DICTIONARYFRAGMENT = 15789

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER = 15790

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_PUBLISHERID = 15791

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI = 15792

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPTRANSPORTDATATYPE = 15793

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_RESET = 15794

const UA_NS0ID_GENERATEFILEFORREADMETHODTYPE = 15795

const UA_NS0ID_GENERATEFILEFORREADMETHODTYPE_INPUTARGUMENTS = 15796

const UA_NS0ID_GENERATEFILEFORREADMETHODTYPE_OUTPUTARGUMENTS = 15797

const UA_NS0ID_GENERATEFILEFORWRITEMETHODTYPE = 15798

const UA_NS0ID_GENERATEFILEFORWRITEMETHODTYPE_OUTPUTARGUMENTS = 15799

const UA_NS0ID_CLOSEANDCOMMITMETHODTYPE = 15800

const UA_NS0ID_CLOSEANDCOMMITMETHODTYPE_INPUTARGUMENTS = 15801

const UA_NS0ID_CLOSEANDCOMMITMETHODTYPE_OUTPUTARGUMENTS = 15802

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE = 15803

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_CURRENTSTATE = 15804

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_CURRENTSTATE_ID = 15805

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_CURRENTSTATE_NAME = 15806

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_CURRENTSTATE_NUMBER = 15807

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 15808

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_LASTTRANSITION = 15809

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_LASTTRANSITION_ID = 15810

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_LASTTRANSITION_NAME = 15811

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_LASTTRANSITION_NUMBER = 15812

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_LASTTRANSITION_TRANSITIONTIME = 15813

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 15814

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_IDLE = 15815

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_IDLE_STATENUMBER = 15816

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READPREPARE = 15817

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READPREPARE_STATENUMBER = 15818

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READTRANSFER = 15819

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READTRANSFER_STATENUMBER = 15820

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_APPLYWRITE = 15821

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_APPLYWRITE_STATENUMBER = 15822

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_ERROR = 15823

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_ERROR_STATENUMBER = 15824

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_IDLETOREADPREPARE = 15825

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_IDLETOREADPREPARE_TRANSITIONNUMBER = 15826

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READPREPARETOREADTRANSFER = 15827

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READPREPARETOREADTRANSFER_TRANSITIONNUMBER = 15828

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READTRANSFERTOIDLE = 15829

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READTRANSFERTOIDLE_TRANSITIONNUMBER = 15830

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_IDLETOAPPLYWRITE = 15831

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_IDLETOAPPLYWRITE_TRANSITIONNUMBER = 15832

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_APPLYWRITETOIDLE = 15833

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_APPLYWRITETOIDLE_TRANSITIONNUMBER = 15834

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READPREPARETOERROR = 15835

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READPREPARETOERROR_TRANSITIONNUMBER = 15836

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READTRANSFERTOERROR = 15837

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_READTRANSFERTOERROR_TRANSITIONNUMBER = 15838

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_APPLYWRITETOERROR = 15839

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_APPLYWRITETOERROR_TRANSITIONNUMBER = 15840

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_ERRORTOIDLE = 15841

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_ERRORTOIDLE_TRANSITIONNUMBER = 15842

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_RESET = 15843

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_STATUS = 15844

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_STATUS_STATE = 15845

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_STATUS_ENABLE = 15846

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_STATUS_DISABLE = 15847

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI_SELECTIONS = 15848

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI_SELECTIONDESCRIPTIONS = 15849

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI_RESTRICTTOLIST = 15850

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDRESS = 15851

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 15852

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15853

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPMESSAGEDATATYPE = 15854

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 15855

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15856

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBCONNECTIONDATATYPE = 15857

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBCONNECTIONDATATYPE_DATATYPEVERSION = 15858

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBCONNECTIONDATATYPE_DICTIONARYFRAGMENT = 15859

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONNECTIONTRANSPORTDATATYPE = 15860

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONNECTIONTRANSPORTDATATYPE_DATATYPEVERSION = 15861

const UA_NS0ID_OPCUA_BINARYSCHEMA_CONNECTIONTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15862

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE = 15863

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTSETTINGS = 15864

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_STATUS = 15865

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPTRANSPORTDATATYPE = 15866

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 15867

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15868

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPMESSAGEDATATYPE = 15869

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 15870

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15871

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERDATATYPE = 15872

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERDATATYPE_DATATYPEVERSION = 15873

const UA_NS0ID_OVERRIDEVALUEHANDLING = 15874

const UA_NS0ID_OVERRIDEVALUEHANDLING_ENUMSTRINGS = 15875

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERDATATYPE_DICTIONARYFRAGMENT = 15876

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERTRANSPORTDATATYPE = 15877

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERTRANSPORTDATATYPE_DATATYPEVERSION = 15878

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15879

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERMESSAGEDATATYPE = 15880

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERMESSAGEDATATYPE_DATATYPEVERSION = 15881

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATASETREADERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15882

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIBEDDATASETDATATYPE = 15883

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIBEDDATASETDATATYPE_DATATYPEVERSION = 15884

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIBEDDATASETDATATYPE_DICTIONARYFRAGMENT = 15885

const UA_NS0ID_OPCUA_BINARYSCHEMA_TARGETVARIABLESDATATYPE = 15886

const UA_NS0ID_OPCUA_BINARYSCHEMA_TARGETVARIABLESDATATYPE_DATATYPEVERSION = 15887

const UA_NS0ID_OPCUA_BINARYSCHEMA_TARGETVARIABLESDATATYPE_DICTIONARYFRAGMENT = 15888

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIBEDDATASETMIRRORDATATYPE = 15889

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIBEDDATASETMIRRORDATATYPE_DATATYPEVERSION = 15890

const UA_NS0ID_OPCUA_BINARYSCHEMA_SUBSCRIBEDDATASETMIRRORDATATYPE_DICTIONARYFRAGMENT = 15891

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_STATUS_STATE = 15892

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_STATUS_ENABLE = 15893

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_STATUS_DISABLE = 15894

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPWRITERGROUPMESSAGEDATATYPE = 15895

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPWRITERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 15896

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPWRITERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15897

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPDATASETWRITERMESSAGEDATATYPE = 15898

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPDATASETWRITERMESSAGEDATATYPE_DATATYPEVERSION = 15899

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPDATASETWRITERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15900

const UA_NS0ID_SESSIONLESSINVOKEREQUESTTYPE = 15901

const UA_NS0ID_SESSIONLESSINVOKEREQUESTTYPE_ENCODING_DEFAULTXML = 15902

const UA_NS0ID_SESSIONLESSINVOKEREQUESTTYPE_ENCODING_DEFAULTBINARY = 15903

const UA_NS0ID_DATASETFIELDFLAGS = 15904

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTSETTINGS = 15905

const UA_NS0ID_PUBSUBKEYSERVICETYPE = 15906

const UA_NS0ID_PUBSUBKEYSERVICETYPE_GETSECURITYKEYS = 15907

const UA_NS0ID_PUBSUBKEYSERVICETYPE_GETSECURITYKEYS_INPUTARGUMENTS = 15908

const UA_NS0ID_PUBSUBKEYSERVICETYPE_GETSECURITYKEYS_OUTPUTARGUMENTS = 15909

const UA_NS0ID_PUBSUBKEYSERVICETYPE_GETSECURITYGROUP = 15910

const UA_NS0ID_PUBSUBKEYSERVICETYPE_GETSECURITYGROUP_INPUTARGUMENTS = 15911

const UA_NS0ID_PUBSUBKEYSERVICETYPE_GETSECURITYGROUP_OUTPUTARGUMENTS = 15912

const UA_NS0ID_PUBSUBKEYSERVICETYPE_SECURITYGROUPS = 15913

const UA_NS0ID_PUBSUBKEYSERVICETYPE_SECURITYGROUPS_ADDSECURITYGROUP = 15914

const UA_NS0ID_PUBSUBKEYSERVICETYPE_SECURITYGROUPS_ADDSECURITYGROUP_INPUTARGUMENTS = 15915

const UA_NS0ID_PUBSUBKEYSERVICETYPE_SECURITYGROUPS_ADDSECURITYGROUP_OUTPUTARGUMENTS = 15916

const UA_NS0ID_PUBSUBKEYSERVICETYPE_SECURITYGROUPS_REMOVESECURITYGROUP = 15917

const UA_NS0ID_PUBSUBKEYSERVICETYPE_SECURITYGROUPS_REMOVESECURITYGROUP_INPUTARGUMENTS = 15918

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPDATASETREADERMESSAGEDATATYPE = 15919

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPDATASETREADERMESSAGEDATATYPE_DATATYPEVERSION = 15920

const UA_NS0ID_OPCUA_BINARYSCHEMA_UADPDATASETREADERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15921

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONWRITERGROUPMESSAGEDATATYPE = 15922

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONWRITERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 15923

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONWRITERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15924

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONDATASETWRITERMESSAGEDATATYPE = 15925

const UA_NS0ID_PUBSUBGROUPTYPE_SECURITYMODE = 15926

const UA_NS0ID_PUBSUBGROUPTYPE_SECURITYGROUPID = 15927

const UA_NS0ID_PUBSUBGROUPTYPE_SECURITYKEYSERVICES = 15928

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONDATASETWRITERMESSAGEDATATYPE_DATATYPEVERSION = 15929

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONDATASETWRITERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15930

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONDATASETREADERMESSAGEDATATYPE = 15931

const UA_NS0ID_DATASETREADERTYPE_SECURITYMODE = 15932

const UA_NS0ID_DATASETREADERTYPE_SECURITYGROUPID = 15933

const UA_NS0ID_DATASETREADERTYPE_SECURITYKEYSERVICES = 15934

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONDATASETREADERMESSAGEDATATYPE_DATATYPEVERSION = 15935

const UA_NS0ID_OPCUA_BINARYSCHEMA_JSONDATASETREADERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 15936

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS = 15937

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 15938

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 15939

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERWRITERGROUPTRANSPORTDATATYPE = 15940

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERWRITERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 15941

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERWRITERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15942

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERDATASETWRITERTRANSPORTDATATYPE = 15943

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERDATASETWRITERTRANSPORTDATATYPE_DATATYPEVERSION = 15944

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERDATASETWRITERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15945

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERDATASETREADERTRANSPORTDATATYPE = 15946

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERDATASETREADERTRANSPORTDATATYPE_DATATYPEVERSION = 15947

const UA_NS0ID_OPCUA_BINARYSCHEMA_BROKERDATASETREADERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 15948

const UA_NS0ID_ENDPOINTTYPE_ENCODING_DEFAULTXML = 15949

const UA_NS0ID_DATATYPESCHEMAHEADER_ENCODING_DEFAULTXML = 15950

const UA_NS0ID_PUBLISHEDDATASETDATATYPE_ENCODING_DEFAULTXML = 15951

const UA_NS0ID_PUBLISHEDDATASETSOURCEDATATYPE_ENCODING_DEFAULTXML = 15952

const UA_NS0ID_PUBLISHEDDATAITEMSDATATYPE_ENCODING_DEFAULTXML = 15953

const UA_NS0ID_PUBLISHEDEVENTSDATATYPE_ENCODING_DEFAULTXML = 15954

const UA_NS0ID_DATASETWRITERDATATYPE_ENCODING_DEFAULTXML = 15955

const UA_NS0ID_DATASETWRITERTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 15956

const UA_NS0ID_OPCUANAMESPACEMETADATA = 15957

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEURI = 15958

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEVERSION = 15959

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEPUBLICATIONDATE = 15960

const UA_NS0ID_OPCUANAMESPACEMETADATA_ISNAMESPACESUBSET = 15961

const UA_NS0ID_OPCUANAMESPACEMETADATA_STATICNODEIDTYPES = 15962

const UA_NS0ID_OPCUANAMESPACEMETADATA_STATICNUMERICNODEIDRANGE = 15963

const UA_NS0ID_OPCUANAMESPACEMETADATA_STATICSTRINGNODEIDPATTERN = 15964

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE = 15965

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_SIZE = 15966

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_WRITABLE = 15967

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_USERWRITABLE = 15968

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_OPENCOUNT = 15969

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_MIMETYPE = 15970

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_OPEN = 15971

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_OPEN_INPUTARGUMENTS = 15972

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_OPEN_OUTPUTARGUMENTS = 15973

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_CLOSE = 15974

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_CLOSE_INPUTARGUMENTS = 15975

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_READ = 15976

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_READ_INPUTARGUMENTS = 15977

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_READ_OUTPUTARGUMENTS = 15978

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_WRITE = 15979

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_WRITE_INPUTARGUMENTS = 15980

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_GETPOSITION = 15981

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_GETPOSITION_INPUTARGUMENTS = 15982

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_GETPOSITION_OUTPUTARGUMENTS = 15983

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_SETPOSITION = 15984

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_SETPOSITION_INPUTARGUMENTS = 15985

const UA_NS0ID_OPCUANAMESPACEMETADATA_NAMESPACEFILE_EXPORTNAMESPACE = 15986

const UA_NS0ID_DATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTXML = 15987

const UA_NS0ID_PUBSUBGROUPDATATYPE_ENCODING_DEFAULTXML = 15988

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 15989

const UA_NS0ID_WRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 15990

const UA_NS0ID_WRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTXML = 15991

const UA_NS0ID_PUBSUBCONNECTIONDATATYPE_ENCODING_DEFAULTXML = 15992

const UA_NS0ID_CONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 15993

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 15994

const UA_NS0ID_READERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 15995

const UA_NS0ID_READERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTXML = 15996

const UA_NS0ID_ROLESETTYPE_ADDROLE = 15997

const UA_NS0ID_ROLESETTYPE_ADDROLE_INPUTARGUMENTS = 15998

const UA_NS0ID_ROLESETTYPE_ADDROLE_OUTPUTARGUMENTS = 15999

const UA_NS0ID_ROLESETTYPE_REMOVEROLE = 16000

const UA_NS0ID_ROLESETTYPE_REMOVEROLE_INPUTARGUMENTS = 16001

const UA_NS0ID_ADDROLEMETHODTYPE = 16002

const UA_NS0ID_ADDROLEMETHODTYPE_INPUTARGUMENTS = 16003

const UA_NS0ID_ADDROLEMETHODTYPE_OUTPUTARGUMENTS = 16004

const UA_NS0ID_REMOVEROLEMETHODTYPE = 16005

const UA_NS0ID_REMOVEROLEMETHODTYPE_INPUTARGUMENTS = 16006

const UA_NS0ID_DATASETREADERDATATYPE_ENCODING_DEFAULTXML = 16007

const UA_NS0ID_DATASETREADERTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 16008

const UA_NS0ID_DATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16009

const UA_NS0ID_SUBSCRIBEDDATASETDATATYPE_ENCODING_DEFAULTXML = 16010

const UA_NS0ID_TARGETVARIABLESDATATYPE_ENCODING_DEFAULTXML = 16011

const UA_NS0ID_SUBSCRIBEDDATASETMIRRORDATATYPE_ENCODING_DEFAULTXML = 16012

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 16013

const UA_NS0ID_UADPWRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16014

const UA_NS0ID_UADPDATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16015

const UA_NS0ID_UADPDATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16016

const UA_NS0ID_JSONWRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16017

const UA_NS0ID_JSONDATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16018

const UA_NS0ID_JSONDATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTXML = 16019

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 16020

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 16021

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 16022

const UA_NS0ID_BROKERDATASETREADERTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 16023

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTTYPE = 16024

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTTYPE_DATATYPEVERSION = 16025

const UA_NS0ID_OPCUA_XMLSCHEMA_ENDPOINTTYPE_DICTIONARYFRAGMENT = 16026

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPESCHEMAHEADER = 16027

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPESCHEMAHEADER_DATATYPEVERSION = 16028

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPESCHEMAHEADER_DICTIONARYFRAGMENT = 16029

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATASETDATATYPE = 16030

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATASETDATATYPE_DATATYPEVERSION = 16031

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATASETDATATYPE_DICTIONARYFRAGMENT = 16032

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATASETSOURCEDATATYPE = 16033

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATASETSOURCEDATATYPE_DATATYPEVERSION = 16034

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATASETSOURCEDATATYPE_DICTIONARYFRAGMENT = 16035

const UA_NS0ID_WELLKNOWNROLE_ENGINEER = 16036

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATAITEMSDATATYPE = 16037

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATAITEMSDATATYPE_DATATYPEVERSION = 16038

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDDATAITEMSDATATYPE_DICTIONARYFRAGMENT = 16039

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDEVENTSDATATYPE = 16040

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ADDIDENTITY = 16041

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ADDIDENTITY_INPUTARGUMENTS = 16042

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_REMOVEIDENTITY = 16043

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_REMOVEIDENTITY_INPUTARGUMENTS = 16044

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDEVENTSDATATYPE_DATATYPEVERSION = 16045

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBLISHEDEVENTSDATATYPE_DICTIONARYFRAGMENT = 16046

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERDATATYPE = 16047

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERDATATYPE_DATATYPEVERSION = 16048

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERDATATYPE_DICTIONARYFRAGMENT = 16049

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERTRANSPORTDATATYPE = 16050

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERTRANSPORTDATATYPE_DATATYPEVERSION = 16051

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16052

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERMESSAGEDATATYPE = 16053

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERMESSAGEDATATYPE_DATATYPEVERSION = 16054

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETWRITERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16055

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBGROUPDATATYPE = 16056

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBGROUPDATATYPE_DATATYPEVERSION = 16057

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBGROUPDATATYPE_DICTIONARYFRAGMENT = 16058

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 16059

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 16060

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 16061

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPTRANSPORTDATATYPE = 16062

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 16063

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16064

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPMESSAGEDATATYPE = 16065

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 16066

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16067

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBCONNECTIONDATATYPE = 16068

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBCONNECTIONDATATYPE_DATATYPEVERSION = 16069

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBCONNECTIONDATATYPE_DICTIONARYFRAGMENT = 16070

const UA_NS0ID_OPCUA_XMLSCHEMA_CONNECTIONTRANSPORTDATATYPE = 16071

const UA_NS0ID_OPCUA_XMLSCHEMA_CONNECTIONTRANSPORTDATATYPE_DATATYPEVERSION = 16072

const UA_NS0ID_OPCUA_XMLSCHEMA_CONNECTIONTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16073

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 16074

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 16075

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 16076

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPTRANSPORTDATATYPE = 16077

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 16078

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16079

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPMESSAGEDATATYPE = 16080

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 16081

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16082

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERDATATYPE = 16083

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERDATATYPE_DATATYPEVERSION = 16084

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERDATATYPE_DICTIONARYFRAGMENT = 16085

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERTRANSPORTDATATYPE = 16086

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERTRANSPORTDATATYPE_DATATYPEVERSION = 16087

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16088

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERMESSAGEDATATYPE = 16089

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERMESSAGEDATATYPE_DATATYPEVERSION = 16090

const UA_NS0ID_OPCUA_XMLSCHEMA_DATASETREADERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16091

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIBEDDATASETDATATYPE = 16092

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIBEDDATASETDATATYPE_DATATYPEVERSION = 16093

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIBEDDATASETDATATYPE_DICTIONARYFRAGMENT = 16094

const UA_NS0ID_OPCUA_XMLSCHEMA_TARGETVARIABLESDATATYPE = 16095

const UA_NS0ID_OPCUA_XMLSCHEMA_TARGETVARIABLESDATATYPE_DATATYPEVERSION = 16096

const UA_NS0ID_OPCUA_XMLSCHEMA_TARGETVARIABLESDATATYPE_DICTIONARYFRAGMENT = 16097

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIBEDDATASETMIRRORDATATYPE = 16098

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIBEDDATASETMIRRORDATATYPE_DATATYPEVERSION = 16099

const UA_NS0ID_OPCUA_XMLSCHEMA_SUBSCRIBEDDATASETMIRRORDATATYPE_DICTIONARYFRAGMENT = 16100

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 16101

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 16102

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 16103

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPWRITERGROUPMESSAGEDATATYPE = 16104

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPWRITERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 16105

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPWRITERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16106

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPDATASETWRITERMESSAGEDATATYPE = 16107

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPDATASETWRITERMESSAGEDATATYPE_DATATYPEVERSION = 16108

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPDATASETWRITERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16109

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPDATASETREADERMESSAGEDATATYPE = 16110

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPDATASETREADERMESSAGEDATATYPE_DATATYPEVERSION = 16111

const UA_NS0ID_OPCUA_XMLSCHEMA_UADPDATASETREADERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16112

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONWRITERGROUPMESSAGEDATATYPE = 16113

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONWRITERGROUPMESSAGEDATATYPE_DATATYPEVERSION = 16114

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONWRITERGROUPMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16115

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONDATASETWRITERMESSAGEDATATYPE = 16116

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONDATASETWRITERMESSAGEDATATYPE_DATATYPEVERSION = 16117

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONDATASETWRITERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16118

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONDATASETREADERMESSAGEDATATYPE = 16119

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONDATASETREADERMESSAGEDATATYPE_DATATYPEVERSION = 16120

const UA_NS0ID_OPCUA_XMLSCHEMA_JSONDATASETREADERMESSAGEDATATYPE_DICTIONARYFRAGMENT = 16121

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 16122

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 16123

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 16124

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERWRITERGROUPTRANSPORTDATATYPE = 16125

const UA_NS0ID_ROLEPERMISSIONTYPE_ENCODING_DEFAULTXML = 16126

const UA_NS0ID_OPCUA_XMLSCHEMA_ROLEPERMISSIONTYPE = 16127

const UA_NS0ID_OPCUA_XMLSCHEMA_ROLEPERMISSIONTYPE_DATATYPEVERSION = 16128

const UA_NS0ID_OPCUA_XMLSCHEMA_ROLEPERMISSIONTYPE_DICTIONARYFRAGMENT = 16129

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERWRITERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 16130

const UA_NS0ID_OPCUA_BINARYSCHEMA_ROLEPERMISSIONTYPE = 16131

const UA_NS0ID_OPCUA_BINARYSCHEMA_ROLEPERMISSIONTYPE_DATATYPEVERSION = 16132

const UA_NS0ID_OPCUA_BINARYSCHEMA_ROLEPERMISSIONTYPE_DICTIONARYFRAGMENT = 16133

const UA_NS0ID_OPCUANAMESPACEMETADATA_DEFAULTROLEPERMISSIONS = 16134

const UA_NS0ID_OPCUANAMESPACEMETADATA_DEFAULTUSERROLEPERMISSIONS = 16135

const UA_NS0ID_OPCUANAMESPACEMETADATA_DEFAULTACCESSRESTRICTIONS = 16136

const UA_NS0ID_NAMESPACEMETADATATYPE_DEFAULTROLEPERMISSIONS = 16137

const UA_NS0ID_NAMESPACEMETADATATYPE_DEFAULTUSERROLEPERMISSIONS = 16138

const UA_NS0ID_NAMESPACEMETADATATYPE_DEFAULTACCESSRESTRICTIONS = 16139

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_DEFAULTROLEPERMISSIONS = 16140

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_DEFAULTUSERROLEPERMISSIONS = 16141

const UA_NS0ID_NAMESPACESTYPE_NAMESPACEIDENTIFIER_PLACEHOLDER_DEFAULTACCESSRESTRICTIONS = 16142

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERWRITERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16143

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERDATASETWRITERTRANSPORTDATATYPE = 16144

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERDATASETWRITERTRANSPORTDATATYPE_DATATYPEVERSION = 16145

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERDATASETWRITERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16146

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERDATASETREADERTRANSPORTDATATYPE = 16147

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERDATASETREADERTRANSPORTDATATYPE_DATATYPEVERSION = 16148

const UA_NS0ID_OPCUA_XMLSCHEMA_BROKERDATASETREADERTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 16149

const UA_NS0ID_ENDPOINTTYPE_ENCODING_DEFAULTJSON = 16150

const UA_NS0ID_DATATYPESCHEMAHEADER_ENCODING_DEFAULTJSON = 16151

const UA_NS0ID_PUBLISHEDDATASETDATATYPE_ENCODING_DEFAULTJSON = 16152

const UA_NS0ID_PUBLISHEDDATASETSOURCEDATATYPE_ENCODING_DEFAULTJSON = 16153

const UA_NS0ID_PUBLISHEDDATAITEMSDATATYPE_ENCODING_DEFAULTJSON = 16154

const UA_NS0ID_PUBLISHEDEVENTSDATATYPE_ENCODING_DEFAULTJSON = 16155

const UA_NS0ID_DATASETWRITERDATATYPE_ENCODING_DEFAULTJSON = 16156

const UA_NS0ID_DATASETWRITERTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16157

const UA_NS0ID_DATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16158

const UA_NS0ID_PUBSUBGROUPDATATYPE_ENCODING_DEFAULTJSON = 16159

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 16160

const UA_NS0ID_WRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16161

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_IDENTITIES = 16162

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_APPLICATIONS = 16163

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ENDPOINTS = 16164

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ADDAPPLICATION = 16165

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ADDAPPLICATION_INPUTARGUMENTS = 16166

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_REMOVEAPPLICATION = 16167

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_REMOVEAPPLICATION_INPUTARGUMENTS = 16168

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ADDENDPOINT = 16169

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_ADDENDPOINT_INPUTARGUMENTS = 16170

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_REMOVEENDPOINT = 16171

const UA_NS0ID_ROLESETTYPE_ROLENAME_PLACEHOLDER_REMOVEENDPOINT_INPUTARGUMENTS = 16172

const UA_NS0ID_ROLETYPE_IDENTITIES = 16173

const UA_NS0ID_ROLETYPE_APPLICATIONS = 16174

const UA_NS0ID_ROLETYPE_ENDPOINTS = 16175

const UA_NS0ID_ROLETYPE_ADDAPPLICATION = 16176

const UA_NS0ID_ROLETYPE_ADDAPPLICATION_INPUTARGUMENTS = 16177

const UA_NS0ID_ROLETYPE_REMOVEAPPLICATION = 16178

const UA_NS0ID_ROLETYPE_REMOVEAPPLICATION_INPUTARGUMENTS = 16179

const UA_NS0ID_ROLETYPE_ADDENDPOINT = 16180

const UA_NS0ID_ROLETYPE_ADDENDPOINT_INPUTARGUMENTS = 16181

const UA_NS0ID_ROLETYPE_REMOVEENDPOINT = 16182

const UA_NS0ID_ROLETYPE_REMOVEENDPOINT_INPUTARGUMENTS = 16183

const UA_NS0ID_ADDAPPLICATIONMETHODTYPE = 16184

const UA_NS0ID_ADDAPPLICATIONMETHODTYPE_INPUTARGUMENTS = 16185

const UA_NS0ID_REMOVEAPPLICATIONMETHODTYPE = 16186

const UA_NS0ID_REMOVEAPPLICATIONMETHODTYPE_INPUTARGUMENTS = 16187

const UA_NS0ID_ADDENDPOINTMETHODTYPE = 16188

const UA_NS0ID_ADDENDPOINTMETHODTYPE_INPUTARGUMENTS = 16189

const UA_NS0ID_REMOVEENDPOINTMETHODTYPE = 16190

const UA_NS0ID_REMOVEENDPOINTMETHODTYPE_INPUTARGUMENTS = 16191

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_IDENTITIES = 16192

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_APPLICATIONS = 16193

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ENDPOINTS = 16194

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ADDAPPLICATION = 16195

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ADDAPPLICATION_INPUTARGUMENTS = 16196

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_REMOVEAPPLICATION = 16197

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_REMOVEAPPLICATION_INPUTARGUMENTS = 16198

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ADDENDPOINT = 16199

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_ADDENDPOINT_INPUTARGUMENTS = 16200

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_REMOVEENDPOINT = 16201

const UA_NS0ID_WELLKNOWNROLE_ANONYMOUS_REMOVEENDPOINT_INPUTARGUMENTS = 16202

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_IDENTITIES = 16203

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_APPLICATIONS = 16204

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ENDPOINTS = 16205

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ADDAPPLICATION = 16206

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ADDAPPLICATION_INPUTARGUMENTS = 16207

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_REMOVEAPPLICATION = 16208

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_REMOVEAPPLICATION_INPUTARGUMENTS = 16209

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ADDENDPOINT = 16210

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_ADDENDPOINT_INPUTARGUMENTS = 16211

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_REMOVEENDPOINT = 16212

const UA_NS0ID_WELLKNOWNROLE_AUTHENTICATEDUSER_REMOVEENDPOINT_INPUTARGUMENTS = 16213

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_IDENTITIES = 16214

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_APPLICATIONS = 16215

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ENDPOINTS = 16216

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ADDAPPLICATION = 16217

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ADDAPPLICATION_INPUTARGUMENTS = 16218

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_REMOVEAPPLICATION = 16219

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_REMOVEAPPLICATION_INPUTARGUMENTS = 16220

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ADDENDPOINT = 16221

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_ADDENDPOINT_INPUTARGUMENTS = 16222

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_REMOVEENDPOINT = 16223

const UA_NS0ID_WELLKNOWNROLE_OBSERVER_REMOVEENDPOINT_INPUTARGUMENTS = 16224

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_IDENTITIES = 16225

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_APPLICATIONS = 16226

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ENDPOINTS = 16227

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ADDAPPLICATION = 16228

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ADDAPPLICATION_INPUTARGUMENTS = 16229

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_REMOVEAPPLICATION = 16230

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_REMOVEAPPLICATION_INPUTARGUMENTS = 16231

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ADDENDPOINT = 16232

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_ADDENDPOINT_INPUTARGUMENTS = 16233

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_REMOVEENDPOINT = 16234

const UA_NS0ID_WELLKNOWNROLE_OPERATOR_REMOVEENDPOINT_INPUTARGUMENTS = 16235

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_IDENTITIES = 16236

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_APPLICATIONS = 16237

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ENDPOINTS = 16238

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ADDAPPLICATION = 16239

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ADDAPPLICATION_INPUTARGUMENTS = 16240

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_REMOVEAPPLICATION = 16241

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_REMOVEAPPLICATION_INPUTARGUMENTS = 16242

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ADDENDPOINT = 16243

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_ADDENDPOINT_INPUTARGUMENTS = 16244

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_REMOVEENDPOINT = 16245

const UA_NS0ID_WELLKNOWNROLE_ENGINEER_REMOVEENDPOINT_INPUTARGUMENTS = 16246

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_IDENTITIES = 16247

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_APPLICATIONS = 16248

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ENDPOINTS = 16249

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ADDAPPLICATION = 16250

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ADDAPPLICATION_INPUTARGUMENTS = 16251

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_REMOVEAPPLICATION = 16252

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_REMOVEAPPLICATION_INPUTARGUMENTS = 16253

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ADDENDPOINT = 16254

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_ADDENDPOINT_INPUTARGUMENTS = 16255

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_REMOVEENDPOINT = 16256

const UA_NS0ID_WELLKNOWNROLE_SUPERVISOR_REMOVEENDPOINT_INPUTARGUMENTS = 16257

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_IDENTITIES = 16258

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_APPLICATIONS = 16259

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ENDPOINTS = 16260

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ADDAPPLICATION = 16261

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ADDAPPLICATION_INPUTARGUMENTS = 16262

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_REMOVEAPPLICATION = 16263

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_REMOVEAPPLICATION_INPUTARGUMENTS = 16264

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ADDENDPOINT = 16265

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_ADDENDPOINT_INPUTARGUMENTS = 16266

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_REMOVEENDPOINT = 16267

const UA_NS0ID_WELLKNOWNROLE_SECURITYADMIN_REMOVEENDPOINT_INPUTARGUMENTS = 16268

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_IDENTITIES = 16269

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_APPLICATIONS = 16270

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ENDPOINTS = 16271

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ADDAPPLICATION = 16272

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ADDAPPLICATION_INPUTARGUMENTS = 16273

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_REMOVEAPPLICATION = 16274

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_REMOVEAPPLICATION_INPUTARGUMENTS = 16275

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ADDENDPOINT = 16276

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_ADDENDPOINT_INPUTARGUMENTS = 16277

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_REMOVEENDPOINT = 16278

const UA_NS0ID_WELLKNOWNROLE_CONFIGUREADMIN_REMOVEENDPOINT_INPUTARGUMENTS = 16279

const UA_NS0ID_WRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16280

const UA_NS0ID_PUBSUBCONNECTIONDATATYPE_ENCODING_DEFAULTJSON = 16281

const UA_NS0ID_CONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16282

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 16283

const UA_NS0ID_READERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16284

const UA_NS0ID_READERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16285

const UA_NS0ID_DATASETREADERDATATYPE_ENCODING_DEFAULTJSON = 16286

const UA_NS0ID_DATASETREADERTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16287

const UA_NS0ID_DATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16288

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_ROLESET = 16289

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_ROLESET_ADDROLE = 16290

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_ROLESET_ADDROLE_INPUTARGUMENTS = 16291

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_ROLESET_ADDROLE_OUTPUTARGUMENTS = 16292

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_ROLESET_REMOVEROLE = 16293

const UA_NS0ID_SERVERTYPE_SERVERCAPABILITIES_ROLESET_REMOVEROLE_INPUTARGUMENTS = 16294

const UA_NS0ID_SERVERCAPABILITIESTYPE_ROLESET = 16295

const UA_NS0ID_SERVERCAPABILITIESTYPE_ROLESET_ADDROLE = 16296

const UA_NS0ID_SERVERCAPABILITIESTYPE_ROLESET_ADDROLE_INPUTARGUMENTS = 16297

const UA_NS0ID_SERVERCAPABILITIESTYPE_ROLESET_ADDROLE_OUTPUTARGUMENTS = 16298

const UA_NS0ID_SERVERCAPABILITIESTYPE_ROLESET_REMOVEROLE = 16299

const UA_NS0ID_SERVERCAPABILITIESTYPE_ROLESET_REMOVEROLE_INPUTARGUMENTS = 16300

const UA_NS0ID_SERVER_SERVERCAPABILITIES_ROLESET_ADDROLE = 16301

const UA_NS0ID_SERVER_SERVERCAPABILITIES_ROLESET_ADDROLE_INPUTARGUMENTS = 16302

const UA_NS0ID_SERVER_SERVERCAPABILITIES_ROLESET_ADDROLE_OUTPUTARGUMENTS = 16303

const UA_NS0ID_SERVER_SERVERCAPABILITIES_ROLESET_REMOVEROLE = 16304

const UA_NS0ID_SERVER_SERVERCAPABILITIES_ROLESET_REMOVEROLE_INPUTARGUMENTS = 16305

const UA_NS0ID_DEFAULTINPUTVALUES = 16306

const UA_NS0ID_AUDIODATATYPE = 16307

const UA_NS0ID_SUBSCRIBEDDATASETDATATYPE_ENCODING_DEFAULTJSON = 16308

const UA_NS0ID_SELECTIONLISTTYPE = 16309

const UA_NS0ID_TARGETVARIABLESDATATYPE_ENCODING_DEFAULTJSON = 16310

const UA_NS0ID_SUBSCRIBEDDATASETMIRRORDATATYPE_ENCODING_DEFAULTJSON = 16311

const UA_NS0ID_SELECTIONLISTTYPE_RESTRICTTOLIST = 16312

const UA_NS0ID_ADDITIONALPARAMETERSTYPE = 16313

const UA_NS0ID_FILESYSTEM = 16314

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER = 16315

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_CREATEDIRECTORY = 16316

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_CREATEDIRECTORY_INPUTARGUMENTS = 16317

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_CREATEDIRECTORY_OUTPUTARGUMENTS = 16318

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_CREATEFILE = 16319

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_CREATEFILE_INPUTARGUMENTS = 16320

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_CREATEFILE_OUTPUTARGUMENTS = 16321

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 16322

const UA_NS0ID_UADPWRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16323

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_MOVEORCOPY = 16324

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_MOVEORCOPY_INPUTARGUMENTS = 16325

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_MOVEORCOPY_OUTPUTARGUMENTS = 16326

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER = 16327

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_SIZE = 16328

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_WRITABLE = 16329

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_USERWRITABLE = 16330

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_OPENCOUNT = 16331

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_MIMETYPE = 16332

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_OPEN = 16333

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_OPEN_INPUTARGUMENTS = 16334

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_OPEN_OUTPUTARGUMENTS = 16335

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_CLOSE = 16336

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_CLOSE_INPUTARGUMENTS = 16337

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_READ = 16338

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_READ_INPUTARGUMENTS = 16339

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_READ_OUTPUTARGUMENTS = 16340

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_WRITE = 16341

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_WRITE_INPUTARGUMENTS = 16342

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_GETPOSITION = 16343

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_GETPOSITION_INPUTARGUMENTS = 16344

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_GETPOSITION_OUTPUTARGUMENTS = 16345

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_SETPOSITION = 16346

const UA_NS0ID_FILESYSTEM_FILENAME_PLACEHOLDER_SETPOSITION_INPUTARGUMENTS = 16347

const UA_NS0ID_FILESYSTEM_CREATEDIRECTORY = 16348

const UA_NS0ID_FILESYSTEM_CREATEDIRECTORY_INPUTARGUMENTS = 16349

const UA_NS0ID_FILESYSTEM_CREATEDIRECTORY_OUTPUTARGUMENTS = 16350

const UA_NS0ID_FILESYSTEM_CREATEFILE = 16351

const UA_NS0ID_FILESYSTEM_CREATEFILE_INPUTARGUMENTS = 16352

const UA_NS0ID_FILESYSTEM_CREATEFILE_OUTPUTARGUMENTS = 16353

const UA_NS0ID_FILESYSTEM_DELETEFILESYSTEMOBJECT = 16354

const UA_NS0ID_FILESYSTEM_DELETEFILESYSTEMOBJECT_INPUTARGUMENTS = 16355

const UA_NS0ID_FILESYSTEM_MOVEORCOPY = 16356

const UA_NS0ID_FILESYSTEM_MOVEORCOPY_INPUTARGUMENTS = 16357

const UA_NS0ID_FILESYSTEM_MOVEORCOPY_OUTPUTARGUMENTS = 16358

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_GENERATEFILEFORWRITE_INPUTARGUMENTS = 16359

const UA_NS0ID_GENERATEFILEFORWRITEMETHODTYPE_INPUTARGUMENTS = 16360

const UA_NS0ID_HASALARMSUPPRESSIONGROUP = 16361

const UA_NS0ID_ALARMGROUPMEMBER = 16362

const UA_NS0ID_CONDITIONTYPE_CONDITIONSUBCLASSID = 16363

const UA_NS0ID_CONDITIONTYPE_CONDITIONSUBCLASSNAME = 16364

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONSUBCLASSID = 16365

const UA_NS0ID_DIALOGCONDITIONTYPE_CONDITIONSUBCLASSNAME = 16366

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONSUBCLASSID = 16367

const UA_NS0ID_ACKNOWLEDGEABLECONDITIONTYPE_CONDITIONSUBCLASSNAME = 16368

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONSUBCLASSID = 16369

const UA_NS0ID_ALARMCONDITIONTYPE_CONDITIONSUBCLASSNAME = 16370

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE = 16371

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_ID = 16372

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_NAME = 16373

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_NUMBER = 16374

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16375

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16376

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16377

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_TRUESTATE = 16378

const UA_NS0ID_ALARMCONDITIONTYPE_OUTOFSERVICESTATE_FALSESTATE = 16379

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE = 16380

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_ID = 16381

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_NAME = 16382

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_NUMBER = 16383

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16384

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_TRANSITIONTIME = 16385

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16386

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_TRUESTATE = 16387

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCESTATE_FALSESTATE = 16388

const UA_NS0ID_ALARMCONDITIONTYPE_AUDIBLEENABLED = 16389

const UA_NS0ID_ALARMCONDITIONTYPE_AUDIBLESOUND = 16390

const UA_NS0ID_UADPDATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16391

const UA_NS0ID_UADPDATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16392

const UA_NS0ID_JSONWRITERGROUPMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16393

const UA_NS0ID_JSONDATASETWRITERMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16394

const UA_NS0ID_ALARMCONDITIONTYPE_ONDELAY = 16395

const UA_NS0ID_ALARMCONDITIONTYPE_OFFDELAY = 16396

const UA_NS0ID_ALARMCONDITIONTYPE_FIRSTINGROUPFLAG = 16397

const UA_NS0ID_ALARMCONDITIONTYPE_FIRSTINGROUP = 16398

const UA_NS0ID_ALARMCONDITIONTYPE_ALARMGROUP_PLACEHOLDER = 16399

const UA_NS0ID_ALARMCONDITIONTYPE_REALARMTIME = 16400

const UA_NS0ID_ALARMCONDITIONTYPE_REALARMREPEATCOUNT = 16401

const UA_NS0ID_ALARMCONDITIONTYPE_SILENCE = 16402

const UA_NS0ID_ALARMCONDITIONTYPE_SUPPRESS = 16403

const UA_NS0ID_JSONDATASETREADERMESSAGEDATATYPE_ENCODING_DEFAULTJSON = 16404

const UA_NS0ID_ALARMGROUPTYPE = 16405

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER = 16406

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_EVENTID = 16407

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_EVENTTYPE = 16408

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SOURCENODE = 16409

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SOURCENAME = 16410

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_TIME = 16411

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_RECEIVETIME = 16412

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LOCALTIME = 16413

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_MESSAGE = 16414

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SEVERITY = 16415

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONDITIONCLASSID = 16416

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONDITIONCLASSNAME = 16417

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONDITIONSUBCLASSID = 16418

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONDITIONSUBCLASSNAME = 16419

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONDITIONNAME = 16420

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_BRANCHID = 16421

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_RETAIN = 16422

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE = 16423

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_ID = 16424

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_NAME = 16425

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_NUMBER = 16426

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 16427

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_TRANSITIONTIME = 16428

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 16429

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_TRUESTATE = 16430

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLEDSTATE_FALSESTATE = 16431

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_QUALITY = 16432

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_QUALITY_SOURCETIMESTAMP = 16433

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LASTSEVERITY = 16434

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LASTSEVERITY_SOURCETIMESTAMP = 16435

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_COMMENT = 16436

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_COMMENT_SOURCETIMESTAMP = 16437

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CLIENTUSERID = 16438

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_DISABLE = 16439

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ENABLE = 16440

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ADDCOMMENT = 16441

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ADDCOMMENT_INPUTARGUMENTS = 16442

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE = 16443

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_ID = 16444

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_NAME = 16445

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_NUMBER = 16446

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 16447

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_TRANSITIONTIME = 16448

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 16449

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_TRUESTATE = 16450

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKEDSTATE_FALSESTATE = 16451

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE = 16452

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_ID = 16453

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_NAME = 16454

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_NUMBER = 16455

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 16456

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_TRANSITIONTIME = 16457

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 16458

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_TRUESTATE = 16459

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRMEDSTATE_FALSESTATE = 16460

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKNOWLEDGE = 16461

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACKNOWLEDGE_INPUTARGUMENTS = 16462

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRM = 16463

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_CONFIRM_INPUTARGUMENTS = 16464

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE = 16465

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_ID = 16466

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_NAME = 16467

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_NUMBER = 16468

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 16469

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_TRANSITIONTIME = 16470

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 16471

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_TRUESTATE = 16472

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ACTIVESTATE_FALSESTATE = 16473

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_INPUTNODE = 16474

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE = 16475

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_ID = 16476

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_NAME = 16477

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_NUMBER = 16478

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 16479

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_TRANSITIONTIME = 16480

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 16481

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_TRUESTATE = 16482

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDSTATE_FALSESTATE = 16483

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE = 16484

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_ID = 16485

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_NAME = 16486

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_NUMBER = 16487

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16488

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_TRANSITIONTIME = 16489

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16490

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_TRUESTATE = 16491

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OUTOFSERVICESTATE_FALSESTATE = 16492

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE = 16493

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_ID = 16494

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_NAME = 16495

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_NUMBER = 16496

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16497

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_TRANSITIONTIME = 16498

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16499

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_TRUESTATE = 16500

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCESTATE_FALSESTATE = 16501

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE = 16502

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_CURRENTSTATE = 16503

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_CURRENTSTATE_ID = 16504

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_CURRENTSTATE_NAME = 16505

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_CURRENTSTATE_NUMBER = 16506

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 16507

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_LASTTRANSITION = 16508

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_LASTTRANSITION_ID = 16509

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_LASTTRANSITION_NAME = 16510

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_LASTTRANSITION_NUMBER = 16511

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 16512

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 16513

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_UNSHELVETIME = 16514

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_UNSHELVE = 16515

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_ONESHOTSHELVE = 16516

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_TIMEDSHELVE = 16517

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 16518

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESSEDORSHELVED = 16519

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_MAXTIMESHELVED = 16520

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_AUDIBLEENABLED = 16521

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_AUDIBLESOUND = 16522

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 16523

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16524

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16525

const UA_NS0ID_BROKERDATASETREADERTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 16526

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_ONDELAY = 16527

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_OFFDELAY = 16528

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_FIRSTINGROUPFLAG = 16529

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_FIRSTINGROUP = 16530

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_REALARMTIME = 16531

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_REALARMREPEATCOUNT = 16532

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SILENCE = 16533

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SUPPRESS = 16534

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDWRITERGROUP = 16535

const UA_NS0ID_LIMITALARMTYPE_CONDITIONSUBCLASSID = 16536

const UA_NS0ID_LIMITALARMTYPE_CONDITIONSUBCLASSNAME = 16537

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE = 16538

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_ID = 16539

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_NAME = 16540

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16541

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16542

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16543

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16544

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16545

const UA_NS0ID_LIMITALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16546

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE = 16547

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_ID = 16548

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_NAME = 16549

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_NUMBER = 16550

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16551

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16552

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16553

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_TRUESTATE = 16554

const UA_NS0ID_LIMITALARMTYPE_SILENCESTATE_FALSESTATE = 16555

const UA_NS0ID_LIMITALARMTYPE_AUDIBLEENABLED = 16556

const UA_NS0ID_LIMITALARMTYPE_AUDIBLESOUND = 16557

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDWRITERGROUP_INPUTARGUMENTS = 16558

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDWRITERGROUP_OUTPUTARGUMENTS = 16559

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDREADERGROUP = 16560

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDREADERGROUP_INPUTARGUMENTS = 16561

const UA_NS0ID_LIMITALARMTYPE_ONDELAY = 16562

const UA_NS0ID_LIMITALARMTYPE_OFFDELAY = 16563

const UA_NS0ID_LIMITALARMTYPE_FIRSTINGROUPFLAG = 16564

const UA_NS0ID_LIMITALARMTYPE_FIRSTINGROUP = 16565

const UA_NS0ID_LIMITALARMTYPE_ALARMGROUP_PLACEHOLDER = 16566

const UA_NS0ID_LIMITALARMTYPE_REALARMTIME = 16567

const UA_NS0ID_LIMITALARMTYPE_REALARMREPEATCOUNT = 16568

const UA_NS0ID_LIMITALARMTYPE_SILENCE = 16569

const UA_NS0ID_LIMITALARMTYPE_SUPPRESS = 16570

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDREADERGROUP_OUTPUTARGUMENTS = 16571

const UA_NS0ID_LIMITALARMTYPE_BASEHIGHHIGHLIMIT = 16572

const UA_NS0ID_LIMITALARMTYPE_BASEHIGHLIMIT = 16573

const UA_NS0ID_LIMITALARMTYPE_BASELOWLIMIT = 16574

const UA_NS0ID_LIMITALARMTYPE_BASELOWLOWLIMIT = 16575

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONSUBCLASSID = 16576

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_CONDITIONSUBCLASSNAME = 16577

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE = 16578

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_ID = 16579

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_NAME = 16580

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16581

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16582

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16583

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16584

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16585

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16586

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE = 16587

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_ID = 16588

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_NAME = 16589

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_NUMBER = 16590

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16591

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16592

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16593

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_TRUESTATE = 16594

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCESTATE_FALSESTATE = 16595

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_AUDIBLEENABLED = 16596

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_AUDIBLESOUND = 16597

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_ADDCONNECTION = 16598

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_ADDCONNECTION_INPUTARGUMENTS = 16599

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_ADDCONNECTION_OUTPUTARGUMENTS = 16600

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMSTEMPLATE = 16601

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ONDELAY = 16602

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_OFFDELAY = 16603

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_FIRSTINGROUPFLAG = 16604

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_FIRSTINGROUP = 16605

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_ALARMGROUP_PLACEHOLDER = 16606

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_REALARMTIME = 16607

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_REALARMREPEATCOUNT = 16608

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SILENCE = 16609

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SUPPRESS = 16610

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMSTEMPLATE_INPUTARGUMENTS = 16611

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_BASEHIGHHIGHLIMIT = 16612

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_BASEHIGHLIMIT = 16613

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_BASELOWLIMIT = 16614

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_BASELOWLOWLIMIT = 16615

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONSUBCLASSID = 16616

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_CONDITIONSUBCLASSNAME = 16617

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE = 16618

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_ID = 16619

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_NAME = 16620

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16621

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16622

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16623

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16624

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16625

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16626

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE = 16627

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_ID = 16628

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_NAME = 16629

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_NUMBER = 16630

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16631

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16632

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16633

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_TRUESTATE = 16634

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCESTATE_FALSESTATE = 16635

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_AUDIBLEENABLED = 16636

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_AUDIBLESOUND = 16637

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMSTEMPLATE_OUTPUTARGUMENTS = 16638

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTSTEMPLATE = 16639

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTSTEMPLATE_INPUTARGUMENTS = 16640

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTSTEMPLATE_OUTPUTARGUMENTS = 16641

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ONDELAY = 16642

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_OFFDELAY = 16643

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_FIRSTINGROUPFLAG = 16644

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_FIRSTINGROUP = 16645

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_ALARMGROUP_PLACEHOLDER = 16646

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_REALARMTIME = 16647

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_REALARMREPEATCOUNT = 16648

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SILENCE = 16649

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SUPPRESS = 16650

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDDATASETFOLDER = 16651

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_BASEHIGHHIGHLIMIT = 16652

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_BASEHIGHLIMIT = 16653

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_BASELOWLIMIT = 16654

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_BASELOWLOWLIMIT = 16655

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONSUBCLASSID = 16656

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_CONDITIONSUBCLASSNAME = 16657

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE = 16658

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_ID = 16659

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_NAME = 16660

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16661

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16662

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16663

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16664

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16665

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16666

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE = 16667

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_ID = 16668

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_NAME = 16669

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_NUMBER = 16670

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16671

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16672

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16673

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_TRUESTATE = 16674

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCESTATE_FALSESTATE = 16675

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_AUDIBLEENABLED = 16676

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_AUDIBLESOUND = 16677

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDDATASETFOLDER_INPUTARGUMENTS = 16678

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_ADDDATASETFOLDER_OUTPUTARGUMENTS = 16679

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_REMOVEDATASETFOLDER = 16680

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_PUBLISHEDDATASETS_REMOVEDATASETFOLDER_INPUTARGUMENTS = 16681

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ONDELAY = 16682

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_OFFDELAY = 16683

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_FIRSTINGROUPFLAG = 16684

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_FIRSTINGROUP = 16685

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_ALARMGROUP_PLACEHOLDER = 16686

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_REALARMTIME = 16687

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_REALARMREPEATCOUNT = 16688

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SILENCE = 16689

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SUPPRESS = 16690

const UA_NS0ID_ADDCONNECTIONMETHODTYPE = 16691

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_BASEHIGHHIGHLIMIT = 16692

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_BASEHIGHLIMIT = 16693

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_BASELOWLIMIT = 16694

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_BASELOWLOWLIMIT = 16695

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONSUBCLASSID = 16696

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_CONDITIONSUBCLASSNAME = 16697

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE = 16698

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_ID = 16699

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_NAME = 16700

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16701

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16702

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16703

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16704

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16705

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16706

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE = 16707

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_ID = 16708

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_NAME = 16709

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_NUMBER = 16710

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16711

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16712

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16713

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_TRUESTATE = 16714

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCESTATE_FALSESTATE = 16715

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_AUDIBLEENABLED = 16716

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_AUDIBLESOUND = 16717

const UA_NS0ID_ADDCONNECTIONMETHODTYPE_INPUTARGUMENTS = 16718

const UA_NS0ID_ADDCONNECTIONMETHODTYPE_OUTPUTARGUMENTS = 16719

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERID = 16720

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETFIELDCONTENTMASK = 16721

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ONDELAY = 16722

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_OFFDELAY = 16723

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_FIRSTINGROUPFLAG = 16724

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_FIRSTINGROUP = 16725

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_ALARMGROUP_PLACEHOLDER = 16726

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_REALARMTIME = 16727

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_REALARMREPEATCOUNT = 16728

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SILENCE = 16729

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SUPPRESS = 16730

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_KEYFRAMECOUNT = 16731

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_BASEHIGHHIGHLIMIT = 16732

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_BASEHIGHLIMIT = 16733

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_BASELOWLIMIT = 16734

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_BASELOWLOWLIMIT = 16735

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONSUBCLASSID = 16736

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_CONDITIONSUBCLASSNAME = 16737

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE = 16738

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_ID = 16739

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_NAME = 16740

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16741

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16742

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16743

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16744

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16745

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16746

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE = 16747

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_ID = 16748

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_NAME = 16749

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_NUMBER = 16750

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16751

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16752

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16753

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_TRUESTATE = 16754

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_FALSESTATE = 16755

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_AUDIBLEENABLED = 16756

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND = 16757

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_MESSAGESETTINGS = 16758

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETCLASSID = 16759

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERID = 16760

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETFIELDCONTENTMASK = 16761

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ONDELAY = 16762

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_OFFDELAY = 16763

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_FIRSTINGROUPFLAG = 16764

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_FIRSTINGROUP = 16765

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_ALARMGROUP_PLACEHOLDER = 16766

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_REALARMTIME = 16767

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_REALARMREPEATCOUNT = 16768

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SILENCE = 16769

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SUPPRESS = 16770

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_KEYFRAMECOUNT = 16771

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_BASEHIGHHIGHLIMIT = 16772

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_BASEHIGHLIMIT = 16773

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_BASELOWLIMIT = 16774

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_BASELOWLOWLIMIT = 16775

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_BASESETPOINTNODE = 16776

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONSUBCLASSID = 16777

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_CONDITIONSUBCLASSNAME = 16778

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE = 16779

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_ID = 16780

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_NAME = 16781

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16782

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16783

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16784

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16785

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16786

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16787

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE = 16788

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_ID = 16789

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_NAME = 16790

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_NUMBER = 16791

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16792

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16793

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16794

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_TRUESTATE = 16795

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCESTATE_FALSESTATE = 16796

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_AUDIBLEENABLED = 16797

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND = 16798

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_MESSAGESETTINGS = 16799

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETCLASSID = 16800

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERID = 16801

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETFIELDCONTENTMASK = 16802

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ONDELAY = 16803

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_OFFDELAY = 16804

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_FIRSTINGROUPFLAG = 16805

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_FIRSTINGROUP = 16806

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_ALARMGROUP_PLACEHOLDER = 16807

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_REALARMTIME = 16808

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_REALARMREPEATCOUNT = 16809

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SILENCE = 16810

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SUPPRESS = 16811

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_KEYFRAMECOUNT = 16812

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_BASEHIGHHIGHLIMIT = 16813

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_BASEHIGHLIMIT = 16814

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_BASELOWLIMIT = 16815

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_BASELOWLOWLIMIT = 16816

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_BASESETPOINTNODE = 16817

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONSUBCLASSID = 16818

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONSUBCLASSNAME = 16819

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE = 16820

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_ID = 16821

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_NAME = 16822

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16823

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16824

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16825

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16826

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16827

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16828

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE = 16829

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_ID = 16830

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_NAME = 16831

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_NUMBER = 16832

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16833

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16834

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16835

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_TRUESTATE = 16836

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_FALSESTATE = 16837

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLEENABLED = 16838

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND = 16839

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_MESSAGESETTINGS = 16840

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETCLASSID = 16841

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDDATAITEMSTEMPLATE = 16842

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDDATAITEMSTEMPLATE_INPUTARGUMENTS = 16843

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ONDELAY = 16844

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_OFFDELAY = 16845

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_FIRSTINGROUPFLAG = 16846

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_FIRSTINGROUP = 16847

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ALARMGROUP_PLACEHOLDER = 16848

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_REALARMTIME = 16849

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_REALARMREPEATCOUNT = 16850

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SILENCE = 16851

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESS = 16852

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDDATAITEMSTEMPLATE_OUTPUTARGUMENTS = 16853

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_BASEHIGHHIGHLIMIT = 16854

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_BASEHIGHLIMIT = 16855

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_BASELOWLIMIT = 16856

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_BASELOWLOWLIMIT = 16857

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_ENGINEERINGUNITS = 16858

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONSUBCLASSID = 16859

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_CONDITIONSUBCLASSNAME = 16860

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE = 16861

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_ID = 16862

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_NAME = 16863

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16864

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16865

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16866

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16867

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16868

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16869

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE = 16870

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_ID = 16871

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_NAME = 16872

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_NUMBER = 16873

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16874

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16875

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16876

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_TRUESTATE = 16877

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCESTATE_FALSESTATE = 16878

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLEENABLED = 16879

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND = 16880

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDEVENTSTEMPLATE = 16881

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDEVENTSTEMPLATE_INPUTARGUMENTS = 16882

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDPUBLISHEDEVENTSTEMPLATE_OUTPUTARGUMENTS = 16883

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDDATASETFOLDER = 16884

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ONDELAY = 16885

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_OFFDELAY = 16886

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_FIRSTINGROUPFLAG = 16887

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_FIRSTINGROUP = 16888

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ALARMGROUP_PLACEHOLDER = 16889

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_REALARMTIME = 16890

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_REALARMREPEATCOUNT = 16891

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SILENCE = 16892

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SUPPRESS = 16893

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDDATASETFOLDER_INPUTARGUMENTS = 16894

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_BASEHIGHHIGHLIMIT = 16895

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_BASEHIGHLIMIT = 16896

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_BASELOWLIMIT = 16897

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_BASELOWLOWLIMIT = 16898

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_ENGINEERINGUNITS = 16899

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONSUBCLASSID = 16900

const UA_NS0ID_DISCRETEALARMTYPE_CONDITIONSUBCLASSNAME = 16901

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE = 16902

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_ID = 16903

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_NAME = 16904

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16905

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16906

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16907

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16908

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16909

const UA_NS0ID_DISCRETEALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16910

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE = 16911

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_ID = 16912

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_NAME = 16913

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_NUMBER = 16914

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16915

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16916

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16917

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_TRUESTATE = 16918

const UA_NS0ID_DISCRETEALARMTYPE_SILENCESTATE_FALSESTATE = 16919

const UA_NS0ID_DISCRETEALARMTYPE_AUDIBLEENABLED = 16920

const UA_NS0ID_DISCRETEALARMTYPE_AUDIBLESOUND = 16921

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_ADDDATASETFOLDER_OUTPUTARGUMENTS = 16922

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_REMOVEDATASETFOLDER = 16923

const UA_NS0ID_DATASETFOLDERTYPE_DATASETFOLDERNAME_PLACEHOLDER_REMOVEDATASETFOLDER_INPUTARGUMENTS = 16924

const UA_NS0ID_DATASETFOLDERTYPE_PUBLISHEDDATASETNAME_PLACEHOLDER_DATASETCLASSID = 16925

const UA_NS0ID_DISCRETEALARMTYPE_ONDELAY = 16926

const UA_NS0ID_DISCRETEALARMTYPE_OFFDELAY = 16927

const UA_NS0ID_DISCRETEALARMTYPE_FIRSTINGROUPFLAG = 16928

const UA_NS0ID_DISCRETEALARMTYPE_FIRSTINGROUP = 16929

const UA_NS0ID_DISCRETEALARMTYPE_ALARMGROUP_PLACEHOLDER = 16930

const UA_NS0ID_DISCRETEALARMTYPE_REALARMTIME = 16931

const UA_NS0ID_DISCRETEALARMTYPE_REALARMREPEATCOUNT = 16932

const UA_NS0ID_DISCRETEALARMTYPE_SILENCE = 16933

const UA_NS0ID_DISCRETEALARMTYPE_SUPPRESS = 16934

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDDATAITEMSTEMPLATE = 16935

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONSUBCLASSID = 16936

const UA_NS0ID_OFFNORMALALARMTYPE_CONDITIONSUBCLASSNAME = 16937

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE = 16938

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_ID = 16939

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_NAME = 16940

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16941

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16942

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16943

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16944

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16945

const UA_NS0ID_OFFNORMALALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16946

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE = 16947

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_ID = 16948

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_NAME = 16949

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_NUMBER = 16950

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16951

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16952

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16953

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_TRUESTATE = 16954

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCESTATE_FALSESTATE = 16955

const UA_NS0ID_OFFNORMALALARMTYPE_AUDIBLEENABLED = 16956

const UA_NS0ID_OFFNORMALALARMTYPE_AUDIBLESOUND = 16957

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDDATAITEMSTEMPLATE_INPUTARGUMENTS = 16958

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDDATAITEMSTEMPLATE_OUTPUTARGUMENTS = 16959

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDEVENTSTEMPLATE = 16960

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDEVENTSTEMPLATE_INPUTARGUMENTS = 16961

const UA_NS0ID_OFFNORMALALARMTYPE_ONDELAY = 16962

const UA_NS0ID_OFFNORMALALARMTYPE_OFFDELAY = 16963

const UA_NS0ID_OFFNORMALALARMTYPE_FIRSTINGROUPFLAG = 16964

const UA_NS0ID_OFFNORMALALARMTYPE_FIRSTINGROUP = 16965

const UA_NS0ID_OFFNORMALALARMTYPE_ALARMGROUP_PLACEHOLDER = 16966

const UA_NS0ID_OFFNORMALALARMTYPE_REALARMTIME = 16967

const UA_NS0ID_OFFNORMALALARMTYPE_REALARMREPEATCOUNT = 16968

const UA_NS0ID_OFFNORMALALARMTYPE_SILENCE = 16969

const UA_NS0ID_OFFNORMALALARMTYPE_SUPPRESS = 16970

const UA_NS0ID_DATASETFOLDERTYPE_ADDPUBLISHEDEVENTSTEMPLATE_OUTPUTARGUMENTS = 16971

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONSUBCLASSID = 16972

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_CONDITIONSUBCLASSNAME = 16973

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE = 16974

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_ID = 16975

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_NAME = 16976

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_NUMBER = 16977

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 16978

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 16979

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 16980

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 16981

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 16982

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE = 16983

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_ID = 16984

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_NAME = 16985

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_NUMBER = 16986

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 16987

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_TRANSITIONTIME = 16988

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 16989

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_TRUESTATE = 16990

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCESTATE_FALSESTATE = 16991

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_AUDIBLEENABLED = 16992

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_AUDIBLESOUND = 16993

const UA_NS0ID_DATASETFOLDERTYPE_ADDDATASETFOLDER = 16994

const UA_NS0ID_DATASETFOLDERTYPE_ADDDATASETFOLDER_INPUTARGUMENTS = 16995

const UA_NS0ID_DATASETFOLDERTYPE_ADDDATASETFOLDER_OUTPUTARGUMENTS = 16996

const UA_NS0ID_DATASETFOLDERTYPE_REMOVEDATASETFOLDER = 16997

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ONDELAY = 16998

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_OFFDELAY = 16999

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_FIRSTINGROUPFLAG = 17000

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_FIRSTINGROUP = 17001

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_ALARMGROUP_PLACEHOLDER = 17002

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_REALARMTIME = 17003

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_REALARMREPEATCOUNT = 17004

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SILENCE = 17005

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SUPPRESS = 17006

const UA_NS0ID_DATASETFOLDERTYPE_REMOVEDATASETFOLDER_INPUTARGUMENTS = 17007

const UA_NS0ID_TRIPALARMTYPE_CONDITIONSUBCLASSID = 17008

const UA_NS0ID_TRIPALARMTYPE_CONDITIONSUBCLASSNAME = 17009

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE = 17010

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_ID = 17011

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_NAME = 17012

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_NUMBER = 17013

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 17014

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 17015

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 17016

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 17017

const UA_NS0ID_TRIPALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 17018

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE = 17019

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_ID = 17020

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_NAME = 17021

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_NUMBER = 17022

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 17023

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_TRANSITIONTIME = 17024

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 17025

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_TRUESTATE = 17026

const UA_NS0ID_TRIPALARMTYPE_SILENCESTATE_FALSESTATE = 17027

const UA_NS0ID_TRIPALARMTYPE_AUDIBLEENABLED = 17028

const UA_NS0ID_TRIPALARMTYPE_AUDIBLESOUND = 17029

const UA_NS0ID_ADDPUBLISHEDDATAITEMSTEMPLATEMETHODTYPE = 17030

const UA_NS0ID_ADDPUBLISHEDDATAITEMSTEMPLATEMETHODTYPE_INPUTARGUMENTS = 17031

const UA_NS0ID_ADDPUBLISHEDDATAITEMSTEMPLATEMETHODTYPE_OUTPUTARGUMENTS = 17032

const UA_NS0ID_ADDPUBLISHEDEVENTSTEMPLATEMETHODTYPE = 17033

const UA_NS0ID_TRIPALARMTYPE_ONDELAY = 17034

const UA_NS0ID_TRIPALARMTYPE_OFFDELAY = 17035

const UA_NS0ID_TRIPALARMTYPE_FIRSTINGROUPFLAG = 17036

const UA_NS0ID_TRIPALARMTYPE_FIRSTINGROUP = 17037

const UA_NS0ID_TRIPALARMTYPE_ALARMGROUP_PLACEHOLDER = 17038

const UA_NS0ID_TRIPALARMTYPE_REALARMTIME = 17039

const UA_NS0ID_TRIPALARMTYPE_REALARMREPEATCOUNT = 17040

const UA_NS0ID_TRIPALARMTYPE_SILENCE = 17041

const UA_NS0ID_TRIPALARMTYPE_SUPPRESS = 17042

const UA_NS0ID_ADDPUBLISHEDEVENTSTEMPLATEMETHODTYPE_INPUTARGUMENTS = 17043

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONSUBCLASSID = 17044

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_CONDITIONSUBCLASSNAME = 17045

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE = 17046

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_ID = 17047

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_NAME = 17048

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_NUMBER = 17049

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 17050

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 17051

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 17052

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 17053

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 17054

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE = 17055

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_ID = 17056

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_NAME = 17057

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_NUMBER = 17058

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 17059

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_TRANSITIONTIME = 17060

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 17061

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_TRUESTATE = 17062

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCESTATE_FALSESTATE = 17063

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_AUDIBLEENABLED = 17064

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_AUDIBLESOUND = 17065

const UA_NS0ID_ADDPUBLISHEDEVENTSTEMPLATEMETHODTYPE_OUTPUTARGUMENTS = 17066

const UA_NS0ID_ADDDATASETFOLDERMETHODTYPE = 17067

const UA_NS0ID_ADDDATASETFOLDERMETHODTYPE_INPUTARGUMENTS = 17068

const UA_NS0ID_ADDDATASETFOLDERMETHODTYPE_OUTPUTARGUMENTS = 17069

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ONDELAY = 17070

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_OFFDELAY = 17071

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_FIRSTINGROUPFLAG = 17072

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_FIRSTINGROUP = 17073

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_ALARMGROUP_PLACEHOLDER = 17074

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_REALARMTIME = 17075

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_REALARMREPEATCOUNT = 17076

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SILENCE = 17077

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SUPPRESS = 17078

const UA_NS0ID_REMOVEDATASETFOLDERMETHODTYPE = 17079

const UA_NS0ID_DISCREPANCYALARMTYPE = 17080

const UA_NS0ID_DISCREPANCYALARMTYPE_EVENTID = 17081

const UA_NS0ID_DISCREPANCYALARMTYPE_EVENTTYPE = 17082

const UA_NS0ID_DISCREPANCYALARMTYPE_SOURCENODE = 17083

const UA_NS0ID_DISCREPANCYALARMTYPE_SOURCENAME = 17084

const UA_NS0ID_DISCREPANCYALARMTYPE_TIME = 17085

const UA_NS0ID_DISCREPANCYALARMTYPE_RECEIVETIME = 17086

const UA_NS0ID_DISCREPANCYALARMTYPE_LOCALTIME = 17087

const UA_NS0ID_DISCREPANCYALARMTYPE_MESSAGE = 17088

const UA_NS0ID_DISCREPANCYALARMTYPE_SEVERITY = 17089

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONCLASSID = 17090

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONCLASSNAME = 17091

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONSUBCLASSID = 17092

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONSUBCLASSNAME = 17093

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONNAME = 17094

const UA_NS0ID_DISCREPANCYALARMTYPE_BRANCHID = 17095

const UA_NS0ID_DISCREPANCYALARMTYPE_RETAIN = 17096

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE = 17097

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_ID = 17098

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_NAME = 17099

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_NUMBER = 17100

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 17101

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 17102

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 17103

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_TRUESTATE = 17104

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLEDSTATE_FALSESTATE = 17105

const UA_NS0ID_DISCREPANCYALARMTYPE_QUALITY = 17106

const UA_NS0ID_DISCREPANCYALARMTYPE_QUALITY_SOURCETIMESTAMP = 17107

const UA_NS0ID_DISCREPANCYALARMTYPE_LASTSEVERITY = 17108

const UA_NS0ID_DISCREPANCYALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 17109

const UA_NS0ID_DISCREPANCYALARMTYPE_COMMENT = 17110

const UA_NS0ID_DISCREPANCYALARMTYPE_COMMENT_SOURCETIMESTAMP = 17111

const UA_NS0ID_DISCREPANCYALARMTYPE_CLIENTUSERID = 17112

const UA_NS0ID_DISCREPANCYALARMTYPE_DISABLE = 17113

const UA_NS0ID_DISCREPANCYALARMTYPE_ENABLE = 17114

const UA_NS0ID_DISCREPANCYALARMTYPE_ADDCOMMENT = 17115

const UA_NS0ID_DISCREPANCYALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 17116

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONREFRESH = 17117

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 17118

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONREFRESH2 = 17119

const UA_NS0ID_DISCREPANCYALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 17120

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE = 17121

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_ID = 17122

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_NAME = 17123

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_NUMBER = 17124

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 17125

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 17126

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 17127

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_TRUESTATE = 17128

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKEDSTATE_FALSESTATE = 17129

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE = 17130

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_ID = 17131

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_NAME = 17132

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_NUMBER = 17133

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 17134

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 17135

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 17136

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 17137

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 17138

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKNOWLEDGE = 17139

const UA_NS0ID_DISCREPANCYALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 17140

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRM = 17141

const UA_NS0ID_DISCREPANCYALARMTYPE_CONFIRM_INPUTARGUMENTS = 17142

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE = 17143

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_ID = 17144

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_NAME = 17145

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_NUMBER = 17146

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 17147

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 17148

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 17149

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_TRUESTATE = 17150

const UA_NS0ID_DISCREPANCYALARMTYPE_ACTIVESTATE_FALSESTATE = 17151

const UA_NS0ID_DISCREPANCYALARMTYPE_INPUTNODE = 17152

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE = 17153

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_ID = 17154

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_NAME = 17155

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_NUMBER = 17156

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 17157

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 17158

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 17159

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 17160

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 17161

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE = 17162

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_ID = 17163

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_NAME = 17164

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_NUMBER = 17165

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 17166

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 17167

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 17168

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 17169

const UA_NS0ID_DISCREPANCYALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 17170

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE = 17171

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_ID = 17172

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_NAME = 17173

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_NUMBER = 17174

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 17175

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_TRANSITIONTIME = 17176

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 17177

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_TRUESTATE = 17178

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCESTATE_FALSESTATE = 17179

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE = 17180

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 17181

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 17182

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 17183

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 17184

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 17185

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 17186

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 17187

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 17188

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 17189

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 17190

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 17191

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 17192

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_UNSHELVE = 17193

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 17194

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 17195

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 17196

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESSEDORSHELVED = 17197

const UA_NS0ID_DISCREPANCYALARMTYPE_MAXTIMESHELVED = 17198

const UA_NS0ID_DISCREPANCYALARMTYPE_AUDIBLEENABLED = 17199

const UA_NS0ID_DISCREPANCYALARMTYPE_AUDIBLESOUND = 17200

const UA_NS0ID_REMOVEDATASETFOLDERMETHODTYPE_INPUTARGUMENTS = 17201

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDRESS_NETWORKINTERFACE = 17202

const UA_NS0ID_PUBSUBCONNECTIONTYPE_TRANSPORTSETTINGS = 17203

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_MAXNETWORKMESSAGESIZE = 17204

const UA_NS0ID_DISCREPANCYALARMTYPE_ONDELAY = 17205

const UA_NS0ID_DISCREPANCYALARMTYPE_OFFDELAY = 17206

const UA_NS0ID_DISCREPANCYALARMTYPE_FIRSTINGROUPFLAG = 17207

const UA_NS0ID_DISCREPANCYALARMTYPE_FIRSTINGROUP = 17208

const UA_NS0ID_DISCREPANCYALARMTYPE_ALARMGROUP_PLACEHOLDER = 17209

const UA_NS0ID_DISCREPANCYALARMTYPE_REALARMTIME = 17210

const UA_NS0ID_DISCREPANCYALARMTYPE_REALARMREPEATCOUNT = 17211

const UA_NS0ID_DISCREPANCYALARMTYPE_SILENCE = 17212

const UA_NS0ID_DISCREPANCYALARMTYPE_SUPPRESS = 17213

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_WRITERGROUPID = 17214

const UA_NS0ID_DISCREPANCYALARMTYPE_TARGETVALUENODE = 17215

const UA_NS0ID_DISCREPANCYALARMTYPE_EXPECTEDTIME = 17216

const UA_NS0ID_DISCREPANCYALARMTYPE_TOLERANCE = 17217

const UA_NS0ID_SAFETYCONDITIONCLASSTYPE = 17218

const UA_NS0ID_HIGHLYMANAGEDALARMCONDITIONCLASSTYPE = 17219

const UA_NS0ID_TRAININGCONDITIONCLASSTYPE = 17220

const UA_NS0ID_TESTINGCONDITIONSUBCLASSTYPE = 17221

const UA_NS0ID_AUDITCONDITIONCOMMENTEVENTTYPE_CONDITIONEVENTID = 17222

const UA_NS0ID_AUDITCONDITIONACKNOWLEDGEEVENTTYPE_CONDITIONEVENTID = 17223

const UA_NS0ID_AUDITCONDITIONCONFIRMEVENTTYPE_CONDITIONEVENTID = 17224

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE = 17225

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_EVENTID = 17226

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_EVENTTYPE = 17227

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_SOURCENODE = 17228

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_SOURCENAME = 17229

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_TIME = 17230

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_RECEIVETIME = 17231

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_LOCALTIME = 17232

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_MESSAGE = 17233

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_SEVERITY = 17234

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_ACTIONTIMESTAMP = 17235

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_STATUS = 17236

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_SERVERID = 17237

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_CLIENTAUDITENTRYID = 17238

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_CLIENTUSERID = 17239

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_METHODID = 17240

const UA_NS0ID_AUDITCONDITIONSUPPRESSIONEVENTTYPE_INPUTARGUMENTS = 17241

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE = 17242

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_EVENTID = 17243

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_EVENTTYPE = 17244

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_SOURCENODE = 17245

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_SOURCENAME = 17246

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_TIME = 17247

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_RECEIVETIME = 17248

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_LOCALTIME = 17249

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_MESSAGE = 17250

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_SEVERITY = 17251

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_ACTIONTIMESTAMP = 17252

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_STATUS = 17253

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_SERVERID = 17254

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_CLIENTAUDITENTRYID = 17255

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_CLIENTUSERID = 17256

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_METHODID = 17257

const UA_NS0ID_AUDITCONDITIONSILENCEEVENTTYPE_INPUTARGUMENTS = 17258

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE = 17259

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_EVENTID = 17260

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_EVENTTYPE = 17261

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_SOURCENODE = 17262

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_SOURCENAME = 17263

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_TIME = 17264

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_RECEIVETIME = 17265

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_LOCALTIME = 17266

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_MESSAGE = 17267

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_SEVERITY = 17268

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_ACTIONTIMESTAMP = 17269

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_STATUS = 17270

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_SERVERID = 17271

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_CLIENTAUDITENTRYID = 17272

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_CLIENTUSERID = 17273

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_METHODID = 17274

const UA_NS0ID_AUDITCONDITIONOUTOFSERVICEEVENTTYPE_INPUTARGUMENTS = 17275

const UA_NS0ID_HASEFFECTDISABLE = 17276

const UA_NS0ID_ALARMRATEVARIABLETYPE = 17277

const UA_NS0ID_ALARMRATEVARIABLETYPE_RATE = 17278

const UA_NS0ID_ALARMMETRICSTYPE = 17279

const UA_NS0ID_ALARMMETRICSTYPE_ALARMCOUNT = 17280

const UA_NS0ID_ALARMMETRICSTYPE_MAXIMUMACTIVESTATE = 17281

const UA_NS0ID_ALARMMETRICSTYPE_MAXIMUMUNACK = 17282

const UA_NS0ID_ALARMMETRICSTYPE_MAXIMUMREALARMCOUNT = 17283

const UA_NS0ID_ALARMMETRICSTYPE_CURRENTALARMRATE = 17284

const UA_NS0ID_ALARMMETRICSTYPE_CURRENTALARMRATE_RATE = 17285

const UA_NS0ID_ALARMMETRICSTYPE_MAXIMUMALARMRATE = 17286

const UA_NS0ID_ALARMMETRICSTYPE_MAXIMUMALARMRATE_RATE = 17287

const UA_NS0ID_ALARMMETRICSTYPE_AVERAGEALARMRATE = 17288

const UA_NS0ID_ALARMMETRICSTYPE_AVERAGEALARMRATE_RATE = 17289

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_TRANSPORTSETTINGS = 17290

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_MESSAGESETTINGS = 17291

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI = 17292

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_ADDDATASETWRITER = 17293

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_ADDDATASETWRITER_INPUTARGUMENTS = 17294

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI_RESTRICTTOLIST = 17295

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SETSECURITYKEYS = 17296

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SETSECURITYKEYS_INPUTARGUMENTS = 17297

const UA_NS0ID_SETSECURITYKEYSMETHODTYPE = 17298

const UA_NS0ID_SETSECURITYKEYSMETHODTYPE_INPUTARGUMENTS = 17299

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 17300

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_ADDDATASETWRITER_OUTPUTARGUMENTS = 17301

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_MAXNETWORKMESSAGESIZE = 17302

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 17303

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 17304

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 17305

const UA_NS0ID_PUBSUBCONNECTIONTYPE_TRANSPORTPROFILEURI = 17306

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_TRANSPORTSETTINGS = 17307

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_MESSAGESETTINGS = 17308

const UA_NS0ID_PUBSUBCONNECTIONTYPE_TRANSPORTPROFILEURI_RESTRICTTOLIST = 17309

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER = 17310

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_SECURITYMODE = 17311

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_SECURITYGROUPID = 17312

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_SECURITYKEYSERVICES = 17313

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_STATUS = 17314

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_STATUS_STATE = 17315

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_STATUS_ENABLE = 17316

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_STATUS_DISABLE = 17317

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_PUBLISHINGINTERVAL = 17318

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_KEEPALIVETIME = 17319

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 17320

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_PRIORITY = 17321

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_LOCALEIDS = 17322

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_REMOVEDATASETWRITER = 17323

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_REMOVEDATASETWRITER_INPUTARGUMENTS = 17324

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER = 17325

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_SECURITYMODE = 17326

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_SECURITYGROUPID = 17327

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_SECURITYKEYSERVICES = 17328

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_STATUS = 17329

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_STATUS_STATE = 17330

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_STATUS_ENABLE = 17331

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_STATUS_DISABLE = 17332

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_REMOVEDATASETREADER = 17333

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_REMOVEDATASETREADER_INPUTARGUMENTS = 17334

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 17335

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 17336

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 17337

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 17338

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 17339

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 17340

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 17341

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 17342

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 17343

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 17344

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 17345

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 17346

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 17347

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 17348

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 17349

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 17350

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 17351

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 17352

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_RESOLVEDADDRESS = 17353

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_RESOLVEDADDRESS_DIAGNOSTICSLEVEL = 17354

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_ADDDATASETREADER = 17355

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDWRITERGROUP = 17356

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDWRITERGROUP_INPUTARGUMENTS = 17357

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDWRITERGROUP_OUTPUTARGUMENTS = 17358

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDREADERGROUP = 17359

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDREADERGROUP_INPUTARGUMENTS = 17360

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDREADERGROUP_OUTPUTARGUMENTS = 17361

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_REMOVEGROUP = 17362

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_REMOVEGROUP_INPUTARGUMENTS = 17363

const UA_NS0ID_PUBLISHSUBSCRIBE_SETSECURITYKEYS = 17364

const UA_NS0ID_PUBLISHSUBSCRIBE_SETSECURITYKEYS_INPUTARGUMENTS = 17365

const UA_NS0ID_PUBLISHSUBSCRIBE_ADDCONNECTION = 17366

const UA_NS0ID_PUBLISHSUBSCRIBE_ADDCONNECTION_INPUTARGUMENTS = 17367

const UA_NS0ID_PUBLISHSUBSCRIBE_ADDCONNECTION_OUTPUTARGUMENTS = 17368

const UA_NS0ID_PUBLISHSUBSCRIBE_REMOVECONNECTION = 17369

const UA_NS0ID_PUBLISHSUBSCRIBE_REMOVECONNECTION_INPUTARGUMENTS = 17370

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS = 17371

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMS = 17372

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMS_INPUTARGUMENTS = 17373

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMS_OUTPUTARGUMENTS = 17374

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTS = 17375

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTS_INPUTARGUMENTS = 17376

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTS_OUTPUTARGUMENTS = 17377

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMSTEMPLATE = 17378

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMSTEMPLATE_INPUTARGUMENTS = 17379

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDDATAITEMSTEMPLATE_OUTPUTARGUMENTS = 17380

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTSTEMPLATE = 17381

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTSTEMPLATE_INPUTARGUMENTS = 17382

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDPUBLISHEDEVENTSTEMPLATE_OUTPUTARGUMENTS = 17383

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_REMOVEPUBLISHEDDATASET = 17384

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_REMOVEPUBLISHEDDATASET_INPUTARGUMENTS = 17385

const UA_NS0ID_DATASETREADERTYPE_CREATETARGETVARIABLES = 17386

const UA_NS0ID_DATASETREADERTYPE_CREATETARGETVARIABLES_INPUTARGUMENTS = 17387

const UA_NS0ID_DATASETREADERTYPE_CREATETARGETVARIABLES_OUTPUTARGUMENTS = 17388

const UA_NS0ID_DATASETREADERTYPE_CREATEDATASETMIRROR = 17389

const UA_NS0ID_DATASETREADERTYPE_CREATEDATASETMIRROR_INPUTARGUMENTS = 17390

const UA_NS0ID_DATASETREADERTYPE_CREATEDATASETMIRROR_OUTPUTARGUMENTS = 17391

const UA_NS0ID_DATASETREADERTYPECREATETARGETVARIABLESMETHODTYPE = 17392

const UA_NS0ID_DATASETREADERTYPECREATETARGETVARIABLESMETHODTYPE_INPUTARGUMENTS = 17393

const UA_NS0ID_DATASETREADERTYPECREATETARGETVARIABLESMETHODTYPE_OUTPUTARGUMENTS = 17394

const UA_NS0ID_DATASETREADERTYPECREATEDATASETMIRRORMETHODTYPE = 17395

const UA_NS0ID_DATASETREADERTYPECREATEDATASETMIRRORMETHODTYPE_INPUTARGUMENTS = 17396

const UA_NS0ID_DATASETREADERTYPECREATEDATASETMIRRORMETHODTYPE_OUTPUTARGUMENTS = 17397

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDDATASETFOLDER = 17398

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_ADDDATASETREADER_INPUTARGUMENTS = 17399

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_ADDDATASETREADER_OUTPUTARGUMENTS = 17400

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDDATASETFOLDER_INPUTARGUMENTS = 17401

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_ADDDATASETFOLDER_OUTPUTARGUMENTS = 17402

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_REMOVEDATASETFOLDER = 17403

const UA_NS0ID_PUBLISHSUBSCRIBE_PUBLISHEDDATASETS_REMOVEDATASETFOLDER_INPUTARGUMENTS = 17404

const UA_NS0ID_PUBLISHSUBSCRIBE_STATUS = 17405

const UA_NS0ID_PUBLISHSUBSCRIBE_STATUS_STATE = 17406

const UA_NS0ID_PUBLISHSUBSCRIBE_STATUS_ENABLE = 17407

const UA_NS0ID_PUBLISHSUBSCRIBE_STATUS_DISABLE = 17408

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS = 17409

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 17410

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALINFORMATION = 17411

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 17412

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 17413

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 17414

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 17415

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALERROR = 17416

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALERROR_ACTIVE = 17417

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 17418

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 17419

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 17420

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_RESET = 17421

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_SUBERROR = 17422

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS = 17423

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEERROR = 17424

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 17425

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 17426

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDWRITERGROUP = 17427

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDWRITERGROUP_INPUTARGUMENTS = 17428

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 17429

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 17430

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 17431

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 17432

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 17433

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 17434

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 17435

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 17436

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 17437

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 17438

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 17439

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 17440

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 17441

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 17442

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 17443

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 17444

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 17445

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 17446

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 17447

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 17448

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 17449

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 17450

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 17451

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 17452

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 17453

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 17454

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 17455

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDWRITERGROUP_OUTPUTARGUMENTS = 17456

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES = 17457

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS = 17458

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS_DIAGNOSTICSLEVEL = 17459

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS = 17460

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS_DIAGNOSTICSLEVEL = 17461

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS = 17462

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS_DIAGNOSTICSLEVEL = 17463

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS = 17464

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDREADERGROUP = 17465

const UA_NS0ID_PUBLISHSUBSCRIBE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS_DIAGNOSTICSLEVEL = 17466

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTDATATYPE = 17467

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 17468

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATAGRAMCONNECTIONTRANSPORTDATATYPE = 17469

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATAGRAMCONNECTIONTRANSPORTDATATYPE_DATATYPEVERSION = 17470

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATAGRAMCONNECTIONTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 17471

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 17472

const UA_NS0ID_OPCUA_XMLSCHEMA_DATAGRAMCONNECTIONTRANSPORTDATATYPE = 17473

const UA_NS0ID_OPCUA_XMLSCHEMA_DATAGRAMCONNECTIONTRANSPORTDATATYPE_DATATYPEVERSION = 17474

const UA_NS0ID_OPCUA_XMLSCHEMA_DATAGRAMCONNECTIONTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 17475

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 17476

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_DATASETOFFSET = 17477

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_CONNECTIONPROPERTIES = 17478

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_SUPPORTEDTRANSPORTPROFILES = 17479

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_CONNECTIONPROPERTIES = 17480

const UA_NS0ID_PUBLISHSUBSCRIBE_SUPPORTEDTRANSPORTPROFILES = 17481

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERPROPERTIES = 17482

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERPROPERTIES = 17483

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERPROPERTIES = 17484

const UA_NS0ID_PUBSUBCONNECTIONTYPE_CONNECTIONPROPERTIES = 17485

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_GROUPPROPERTIES = 17486

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_GROUPPROPERTIES = 17487

const UA_NS0ID_PUBSUBGROUPTYPE_GROUPPROPERTIES = 17488

const UA_NS0ID_WRITERGROUPTYPE_GROUPPROPERTIES = 17489

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERPROPERTIES = 17490

const UA_NS0ID_READERGROUPTYPE_GROUPPROPERTIES = 17491

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DATASETREADERPROPERTIES = 17492

const UA_NS0ID_DATASETWRITERTYPE_DATASETWRITERPROPERTIES = 17493

const UA_NS0ID_DATASETREADERTYPE_DATASETREADERPROPERTIES = 17494

const UA_NS0ID_CREATECREDENTIALMETHODTYPE_OUTPUTARGUMENTS = 17495

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE = 17496

const UA_NS0ID_ANALOGUNITTYPE = 17497

const UA_NS0ID_ANALOGUNITTYPE_DEFINITION = 17498

const UA_NS0ID_ANALOGUNITTYPE_VALUEPRECISION = 17499

const UA_NS0ID_ANALOGUNITTYPE_INSTRUMENTRANGE = 17500

const UA_NS0ID_ANALOGUNITTYPE_EURANGE = 17501

const UA_NS0ID_ANALOGUNITTYPE_ENGINEERINGUNITS = 17502

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE_SELECTIONS = 17503

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE_SELECTIONDESCRIPTIONS = 17504

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE_RESTRICTTOLIST = 17505

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE_SELECTIONS = 17506

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDREADERGROUP_INPUTARGUMENTS = 17507

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDREADERGROUP_OUTPUTARGUMENTS = 17508

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE_SELECTIONDESCRIPTIONS = 17509

const UA_NS0ID_PUBLISHSUBSCRIBE_CONNECTIONNAME_PLACEHOLDER_ADDRESS_NETWORKINTERFACE_RESTRICTTOLIST = 17510

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER = 17511

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_RESOURCEURI = 17512

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_PROFILEURI = 17513

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_ENDPOINTURLS = 17514

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_SERVICESTATUS = 17515

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_GETENCRYPTINGKEY = 17516

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_GETENCRYPTINGKEY_INPUTARGUMENTS = 17517

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_GETENCRYPTINGKEY_OUTPUTARGUMENTS = 17518

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_UPDATECREDENTIAL = 17519

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_UPDATECREDENTIAL_INPUTARGUMENTS = 17520

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_SERVICENAME_PLACEHOLDER_DELETECREDENTIAL = 17521

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_CREATECREDENTIAL = 17522

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_CREATECREDENTIAL_INPUTARGUMENTS = 17523

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONFOLDERTYPE_CREATECREDENTIAL_OUTPUTARGUMENTS = 17524

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_GETENCRYPTINGKEY = 17525

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_GETENCRYPTINGKEY_INPUTARGUMENTS = 17526

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_GETENCRYPTINGKEY_OUTPUTARGUMENTS = 17527

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_CREATECREDENTIAL = 17528

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_CREATECREDENTIAL_INPUTARGUMENTS = 17529

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_CREATECREDENTIAL_OUTPUTARGUMENTS = 17530

const UA_NS0ID_GETENCRYPTINGKEYMETHODTYPE = 17531

const UA_NS0ID_GETENCRYPTINGKEYMETHODTYPE_INPUTARGUMENTS = 17532

const UA_NS0ID_GETENCRYPTINGKEYMETHODTYPE_OUTPUTARGUMENTS = 17533

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_GETENCRYPTINGKEY = 17534

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_GETENCRYPTINGKEY_INPUTARGUMENTS = 17535

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_GETENCRYPTINGKEY_OUTPUTARGUMENTS = 17536

const UA_NS0ID_ADDITIONALPARAMETERSTYPE_ENCODING_DEFAULTBINARY = 17537

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDITIONALPARAMETERSTYPE = 17538

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDITIONALPARAMETERSTYPE_DATATYPEVERSION = 17539

const UA_NS0ID_OPCUA_BINARYSCHEMA_ADDITIONALPARAMETERSTYPE_DICTIONARYFRAGMENT = 17540

const UA_NS0ID_ADDITIONALPARAMETERSTYPE_ENCODING_DEFAULTXML = 17541

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDITIONALPARAMETERSTYPE = 17542

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDITIONALPARAMETERSTYPE_DATATYPEVERSION = 17543

const UA_NS0ID_OPCUA_XMLSCHEMA_ADDITIONALPARAMETERSTYPE_DICTIONARYFRAGMENT = 17544

const UA_NS0ID_RSAENCRYPTEDSECRET = 17545

const UA_NS0ID_ECCENCRYPTEDSECRET = 17546

const UA_NS0ID_ADDITIONALPARAMETERSTYPE_ENCODING_DEFAULTJSON = 17547

const UA_NS0ID_EPHEMERALKEYTYPE = 17548

const UA_NS0ID_EPHEMERALKEYTYPE_ENCODING_DEFAULTBINARY = 17549

const UA_NS0ID_OPCUA_BINARYSCHEMA_EPHEMERALKEYTYPE = 17550

const UA_NS0ID_OPCUA_BINARYSCHEMA_EPHEMERALKEYTYPE_DATATYPEVERSION = 17551

const UA_NS0ID_OPCUA_BINARYSCHEMA_EPHEMERALKEYTYPE_DICTIONARYFRAGMENT = 17552

const UA_NS0ID_EPHEMERALKEYTYPE_ENCODING_DEFAULTXML = 17553

const UA_NS0ID_OPCUA_XMLSCHEMA_EPHEMERALKEYTYPE = 17554

const UA_NS0ID_OPCUA_XMLSCHEMA_EPHEMERALKEYTYPE_DATATYPEVERSION = 17555

const UA_NS0ID_OPCUA_XMLSCHEMA_EPHEMERALKEYTYPE_DICTIONARYFRAGMENT = 17556

const UA_NS0ID_EPHEMERALKEYTYPE_ENCODING_DEFAULTJSON = 17557

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_HEADERLAYOUTURI = 17558

const UA_NS0ID_WRITERGROUPTYPE_HEADERLAYOUTURI = 17559

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_KEYFRAMECOUNT = 17560

const UA_NS0ID_PUBSUBCONNECTIONTYPEADDWRITERGROUPMETHODTYPE = 17561

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_HEADERLAYOUTURI = 17562

const UA_NS0ID_DATASETREADERTYPE_KEYFRAMECOUNT = 17563

const UA_NS0ID_DATASETREADERTYPE_HEADERLAYOUTURI = 17564

const UA_NS0ID_BASEANALOGTYPE_DEFINITION = 17565

const UA_NS0ID_BASEANALOGTYPE_VALUEPRECISION = 17566

const UA_NS0ID_BASEANALOGTYPE_INSTRUMENTRANGE = 17567

const UA_NS0ID_BASEANALOGTYPE_EURANGE = 17568

const UA_NS0ID_BASEANALOGTYPE_ENGINEERINGUNITS = 17569

const UA_NS0ID_ANALOGUNITRANGETYPE = 17570

const UA_NS0ID_ANALOGUNITRANGETYPE_DEFINITION = 17571

const UA_NS0ID_ANALOGUNITRANGETYPE_VALUEPRECISION = 17572

const UA_NS0ID_ANALOGUNITRANGETYPE_INSTRUMENTRANGE = 17573

const UA_NS0ID_ANALOGUNITRANGETYPE_EURANGE = 17574

const UA_NS0ID_ANALOGUNITRANGETYPE_ENGINEERINGUNITS = 17575

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDRESS_NETWORKINTERFACE_SELECTIONS = 17576

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDRESS_NETWORKINTERFACE_SELECTIONDESCRIPTIONS = 17577

const UA_NS0ID_PUBSUBCONNECTIONTYPE_ADDRESS_NETWORKINTERFACE_RESTRICTTOLIST = 17578

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTTYPE_DISCOVERYADDRESS_NETWORKINTERFACE_SELECTIONS = 17579

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTTYPE_DISCOVERYADDRESS_NETWORKINTERFACE_SELECTIONDESCRIPTIONS = 17580

const UA_NS0ID_DATAGRAMCONNECTIONTRANSPORTTYPE_DISCOVERYADDRESS_NETWORKINTERFACE_RESTRICTTOLIST = 17581

const UA_NS0ID_NETWORKADDRESSTYPE_NETWORKINTERFACE_SELECTIONS = 17582

const UA_NS0ID_NETWORKADDRESSTYPE_NETWORKINTERFACE_SELECTIONDESCRIPTIONS = 17583

const UA_NS0ID_NETWORKADDRESSTYPE_NETWORKINTERFACE_RESTRICTTOLIST = 17584

const UA_NS0ID_NETWORKADDRESSURLTYPE_NETWORKINTERFACE_SELECTIONS = 17585

const UA_NS0ID_NETWORKADDRESSURLTYPE_NETWORKINTERFACE_SELECTIONDESCRIPTIONS = 17586

const UA_NS0ID_NETWORKADDRESSURLTYPE_NETWORKINTERFACE_RESTRICTTOLIST = 17587

const UA_NS0ID_INDEX = 17588

const UA_NS0ID_DICTIONARYENTRYTYPE = 17589

const UA_NS0ID_DICTIONARYENTRYTYPE_DICTIONARYENTRYNAME_PLACEHOLDER = 17590

const UA_NS0ID_DICTIONARYFOLDERTYPE = 17591

const UA_NS0ID_DICTIONARYFOLDERTYPE_DICTIONARYFOLDERNAME_PLACEHOLDER = 17592

const UA_NS0ID_DICTIONARYFOLDERTYPE_DICTIONARYENTRYNAME_PLACEHOLDER = 17593

const UA_NS0ID_DICTIONARIES = 17594

const UA_NS0ID_DICTIONARIES_DICTIONARYFOLDERNAME_PLACEHOLDER = 17595

const UA_NS0ID_DICTIONARIES_DICTIONARYENTRYNAME_PLACEHOLDER = 17596

const UA_NS0ID_HASDICTIONARYENTRY = 17597

const UA_NS0ID_IRDIDICTIONARYENTRYTYPE = 17598

const UA_NS0ID_IRDIDICTIONARYENTRYTYPE_DICTIONARYENTRYNAME_PLACEHOLDER = 17599

const UA_NS0ID_URIDICTIONARYENTRYTYPE = 17600

const UA_NS0ID_URIDICTIONARYENTRYTYPE_DICTIONARYENTRYNAME_PLACEHOLDER = 17601

const UA_NS0ID_BASEINTERFACETYPE = 17602

const UA_NS0ID_HASINTERFACE = 17603

const UA_NS0ID_HASADDIN = 17604

const UA_NS0ID_DEFAULTINSTANCEBROWSENAME = 17605

const UA_NS0ID_GENERICATTRIBUTEVALUE = 17606

const UA_NS0ID_GENERICATTRIBUTES = 17607

const UA_NS0ID_GENERICATTRIBUTEVALUE_ENCODING_DEFAULTXML = 17608

const UA_NS0ID_GENERICATTRIBUTES_ENCODING_DEFAULTXML = 17609

const UA_NS0ID_GENERICATTRIBUTEVALUE_ENCODING_DEFAULTBINARY = 17610

const UA_NS0ID_GENERICATTRIBUTES_ENCODING_DEFAULTBINARY = 17611

const UA_NS0ID_SERVERTYPE_LOCALTIME = 17612

const UA_NS0ID_PUBSUBCONNECTIONTYPEADDWRITERGROUPMETHODTYPE_INPUTARGUMENTS = 17613

const UA_NS0ID_PUBSUBCONNECTIONTYPEADDWRITERGROUPMETHODTYPE_OUTPUTARGUMENTS = 17614

const UA_NS0ID_AUDITSECURITYEVENTTYPE_STATUSCODEID = 17615

const UA_NS0ID_AUDITCHANNELEVENTTYPE_STATUSCODEID = 17616

const UA_NS0ID_AUDITOPENSECURECHANNELEVENTTYPE_STATUSCODEID = 17617

const UA_NS0ID_AUDITSESSIONEVENTTYPE_STATUSCODEID = 17618

const UA_NS0ID_AUDITCREATESESSIONEVENTTYPE_STATUSCODEID = 17619

const UA_NS0ID_AUDITURLMISMATCHEVENTTYPE_STATUSCODEID = 17620

const UA_NS0ID_AUDITACTIVATESESSIONEVENTTYPE_STATUSCODEID = 17621

const UA_NS0ID_AUDITCANCELEVENTTYPE_STATUSCODEID = 17622

const UA_NS0ID_AUDITCERTIFICATEEVENTTYPE_STATUSCODEID = 17623

const UA_NS0ID_AUDITCERTIFICATEDATAMISMATCHEVENTTYPE_STATUSCODEID = 17624

const UA_NS0ID_AUDITCERTIFICATEEXPIREDEVENTTYPE_STATUSCODEID = 17625

const UA_NS0ID_AUDITCERTIFICATEINVALIDEVENTTYPE_STATUSCODEID = 17626

const UA_NS0ID_AUDITCERTIFICATEUNTRUSTEDEVENTTYPE_STATUSCODEID = 17627

const UA_NS0ID_AUDITCERTIFICATEREVOKEDEVENTTYPE_STATUSCODEID = 17628

const UA_NS0ID_AUDITCERTIFICATEMISMATCHEVENTTYPE_STATUSCODEID = 17629

const UA_NS0ID_PUBSUBCONNECTIONADDREADERGROUPGROUPMETHODTYPE = 17630

const UA_NS0ID_PUBSUBCONNECTIONADDREADERGROUPGROUPMETHODTYPE_INPUTARGUMENTS = 17631

const UA_NS0ID_SELECTIONLISTTYPE_SELECTIONS = 17632

const UA_NS0ID_SELECTIONLISTTYPE_SELECTIONDESCRIPTIONS = 17633

const UA_NS0ID_SERVER_LOCALTIME = 17634

const UA_NS0ID_FINITESTATEMACHINETYPE_AVAILABLESTATES = 17635

const UA_NS0ID_FINITESTATEMACHINETYPE_AVAILABLETRANSITIONS = 17636

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_AVAILABLESTATES = 17637

const UA_NS0ID_TEMPORARYFILETRANSFERTYPE_TRANSFERSTATE_PLACEHOLDER_AVAILABLETRANSITIONS = 17638

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_AVAILABLESTATES = 17639

const UA_NS0ID_FILETRANSFERSTATEMACHINETYPE_AVAILABLETRANSITIONS = 17640

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE = 17641

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_EVENTID = 17642

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_EVENTTYPE = 17643

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_SOURCENODE = 17644

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_SOURCENAME = 17645

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_TIME = 17646

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_RECEIVETIME = 17647

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_LOCALTIME = 17648

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_MESSAGE = 17649

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_SEVERITY = 17650

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_ACTIONTIMESTAMP = 17651

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_STATUS = 17652

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_SERVERID = 17653

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_CLIENTAUDITENTRYID = 17654

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_CLIENTUSERID = 17655

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_METHODID = 17656

const UA_NS0ID_ROLEMAPPINGRULECHANGEDAUDITEVENTTYPE_INPUTARGUMENTS = 17657

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_AVAILABLESTATES = 17658

const UA_NS0ID_ALARMCONDITIONTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17659

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_AVAILABLESTATES = 17660

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_SHELVINGSTATE_AVAILABLETRANSITIONS = 17661

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_AVAILABLESTATES = 17662

const UA_NS0ID_SHELVEDSTATEMACHINETYPE_AVAILABLETRANSITIONS = 17663

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17664

const UA_NS0ID_LIMITALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17665

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_AVAILABLESTATES = 17666

const UA_NS0ID_EXCLUSIVELIMITSTATEMACHINETYPE_AVAILABLETRANSITIONS = 17667

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17668

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17669

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_AVAILABLESTATES = 17670

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LIMITSTATE_AVAILABLETRANSITIONS = 17671

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17672

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17673

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17674

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17675

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17676

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17677

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_AVAILABLESTATES = 17678

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LIMITSTATE_AVAILABLETRANSITIONS = 17679

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17680

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17681

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17682

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17683

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_AVAILABLESTATES = 17684

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LIMITSTATE_AVAILABLETRANSITIONS = 17685

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17686

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17687

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17688

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17689

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_AVAILABLESTATES = 17690

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LIMITSTATE_AVAILABLETRANSITIONS = 17691

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17692

const UA_NS0ID_DISCRETEALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17693

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17694

const UA_NS0ID_OFFNORMALALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17695

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17696

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17697

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17698

const UA_NS0ID_TRIPALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17699

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17700

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17701

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 17702

const UA_NS0ID_DISCREPANCYALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 17703

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_AVAILABLESTATES = 17704

const UA_NS0ID_PROGRAMSTATEMACHINETYPE_AVAILABLETRANSITIONS = 17705

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI_SELECTIONS = 17706

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_TRANSPORTPROFILEURI_SELECTIONDESCRIPTIONS = 17707

const UA_NS0ID_PUBSUBCONNECTIONTYPE_TRANSPORTPROFILEURI_SELECTIONS = 17710

const UA_NS0ID_PUBSUBCONNECTIONTYPE_TRANSPORTPROFILEURI_SELECTIONDESCRIPTIONS = 17711

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_DELETEFILESYSTEMOBJECT = 17718

const UA_NS0ID_FILEDIRECTORYTYPE_FILEDIRECTORYNAME_PLACEHOLDER_DELETEFILESYSTEMOBJECT_INPUTARGUMENTS = 17719

const UA_NS0ID_PUBSUBCONNECTIONADDREADERGROUPGROUPMETHODTYPE_OUTPUTARGUMENTS = 17720

const UA_NS0ID_CONNECTIONTRANSPORTTYPE = 17721

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_DELETEFILESYSTEMOBJECT = 17722

const UA_NS0ID_FILESYSTEM_FILEDIRECTORYNAME_PLACEHOLDER_DELETEFILESYSTEMOBJECT_INPUTARGUMENTS = 17723

const UA_NS0ID_PUBSUBGROUPTYPE_MAXNETWORKMESSAGESIZE = 17724

const UA_NS0ID_WRITERGROUPTYPE = 17725

const UA_NS0ID_WRITERGROUPTYPE_SECURITYMODE = 17726

const UA_NS0ID_WRITERGROUPTYPE_SECURITYGROUPID = 17727

const UA_NS0ID_WRITERGROUPTYPE_SECURITYKEYSERVICES = 17728

const UA_NS0ID_WRITERGROUPTYPE_MAXNETWORKMESSAGESIZE = 17729

const UA_NS0ID_WRITERGROUPTYPE_STATUS = 17730

const UA_NS0ID_WRITERGROUPTYPE_STATUS_STATE = 17731

const UA_NS0ID_AUTHORIZATIONSERVICES = 17732

const UA_NS0ID_AUTHORIZATIONSERVICES_SERVICENAME_PLACEHOLDER = 17733

const UA_NS0ID_WRITERGROUPTYPE_STATUS_ENABLE = 17734

const UA_NS0ID_WRITERGROUPTYPE_STATUS_DISABLE = 17735

const UA_NS0ID_WRITERGROUPTYPE_WRITERGROUPID = 17736

const UA_NS0ID_WRITERGROUPTYPE_PUBLISHINGINTERVAL = 17737

const UA_NS0ID_WRITERGROUPTYPE_KEEPALIVETIME = 17738

const UA_NS0ID_WRITERGROUPTYPE_PRIORITY = 17739

const UA_NS0ID_WRITERGROUPTYPE_LOCALEIDS = 17740

const UA_NS0ID_WRITERGROUPTYPE_TRANSPORTSETTINGS = 17741

const UA_NS0ID_WRITERGROUPTYPE_MESSAGESETTINGS = 17742

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER = 17743

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETWRITERID = 17744

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DATASETFIELDCONTENTMASK = 17745

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_KEYFRAMECOUNT = 17746

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_TRANSPORTSETTINGS = 17747

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_MESSAGESETTINGS = 17748

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS = 17749

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_STATE = 17750

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_ENABLE = 17751

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_STATUS_DISABLE = 17752

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS = 17753

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 17754

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 17755

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 17756

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 17757

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 17758

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 17759

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 17760

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 17761

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 17762

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 17763

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 17764

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 17765

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 17766

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 17767

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 17768

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 17769

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 17770

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 17771

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 17772

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 17773

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 17774

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 17775

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 17776

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 17777

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 17778

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 17779

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 17780

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 17781

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 17782

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 17783

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 17784

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 17785

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 17786

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 17787

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 17788

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 17789

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 17790

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 17791

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 17792

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 17793

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 17794

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 17795

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 17796

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 17797

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 17798

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 17799

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 17800

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 17801

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 17802

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 17803

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 17804

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 17805

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 17806

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 17807

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 17808

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 17809

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 17810

const UA_NS0ID_WRITERGROUPTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 17811

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS = 17812

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 17813

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION = 17814

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 17815

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 17816

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 17817

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 17818

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALERROR = 17819

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALERROR_ACTIVE = 17820

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 17821

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 17822

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 17823

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_RESET = 17824

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_SUBERROR = 17825

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS = 17826

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR = 17827

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 17828

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 17829

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 17830

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 17831

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 17832

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 17833

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 17834

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 17835

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 17836

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 17837

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 17838

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 17839

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 17840

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 17841

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 17842

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 17843

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 17844

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 17845

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 17846

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 17847

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 17848

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 17849

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 17850

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 17851

const UA_NS0ID_AUTHORIZATIONSERVICECONFIGURATIONTYPE = 17852

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 17853

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 17854

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 17855

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 17856

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 17857

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES = 17858

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES = 17859

const UA_NS0ID_AUTHORIZATIONSERVICECONFIGURATIONTYPE_SERVICECERTIFICATE = 17860

const UA_NS0ID_DECIMALDATATYPE = 17861

const UA_NS0ID_DECIMALDATATYPE_ENCODING_DEFAULTXML = 17862

const UA_NS0ID_DECIMALDATATYPE_ENCODING_DEFAULTBINARY = 17863

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_ACTIVE = 17864

const UA_NS0ID_ALARMCONDITIONTYPE_AUDIBLESOUND_LISTID = 17865

const UA_NS0ID_ALARMCONDITIONTYPE_AUDIBLESOUND_AGENCYID = 17866

const UA_NS0ID_ALARMCONDITIONTYPE_AUDIBLESOUND_VERSIONID = 17867

const UA_NS0ID_ALARMCONDITIONTYPE_UNSUPPRESS = 17868

const UA_NS0ID_ALARMCONDITIONTYPE_REMOVEFROMSERVICE = 17869

const UA_NS0ID_ALARMCONDITIONTYPE_PLACEINSERVICE = 17870

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_CLASSIFICATION = 17871

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_DIAGNOSTICSLEVEL = 17872

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_TIMEFIRSTCHANGE = 17873

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS = 17874

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_UNSUPPRESS = 17875

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_REMOVEFROMSERVICE = 17876

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_PLACEINSERVICE = 17877

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_ACTIVE = 17878

const UA_NS0ID_LIMITALARMTYPE_AUDIBLESOUND_LISTID = 17879

const UA_NS0ID_LIMITALARMTYPE_AUDIBLESOUND_AGENCYID = 17880

const UA_NS0ID_LIMITALARMTYPE_AUDIBLESOUND_VERSIONID = 17881

const UA_NS0ID_LIMITALARMTYPE_UNSUPPRESS = 17882

const UA_NS0ID_LIMITALARMTYPE_REMOVEFROMSERVICE = 17883

const UA_NS0ID_LIMITALARMTYPE_PLACEINSERVICE = 17884

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_CLASSIFICATION = 17885

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_AUDIBLESOUND_LISTID = 17886

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_AUDIBLESOUND_AGENCYID = 17887

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_AUDIBLESOUND_VERSIONID = 17888

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_UNSUPPRESS = 17889

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_REMOVEFROMSERVICE = 17890

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_PLACEINSERVICE = 17891

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_DIAGNOSTICSLEVEL = 17892

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_AUDIBLESOUND_LISTID = 17893

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_AUDIBLESOUND_AGENCYID = 17894

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_AUDIBLESOUND_VERSIONID = 17895

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_UNSUPPRESS = 17896

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_REMOVEFROMSERVICE = 17897

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_PLACEINSERVICE = 17898

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_TIMEFIRSTCHANGE = 17899

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS = 17900

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_ACTIVE = 17901

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_CLASSIFICATION = 17902

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_DIAGNOSTICSLEVEL = 17903

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_REMOVEFROMSERVICE = 17904

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_PLACEINSERVICE = 17905

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_TIMEFIRSTCHANGE = 17906

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_AUDIBLESOUND_LISTID = 17907

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_AUDIBLESOUND_AGENCYID = 17908

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_AUDIBLESOUND_VERSIONID = 17909

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_UNSUPPRESS = 17910

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_REMOVEFROMSERVICE = 17911

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_PLACEINSERVICE = 17912

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS = 17913

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND_LISTID = 17914

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND_AGENCYID = 17915

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND_VERSIONID = 17916

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_UNSUPPRESS = 17917

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_REMOVEFROMSERVICE = 17918

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_PLACEINSERVICE = 17919

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS_DIAGNOSTICSLEVEL = 17920

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND_LISTID = 17921

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND_AGENCYID = 17922

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND_VERSIONID = 17923

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_UNSUPPRESS = 17924

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_REMOVEFROMSERVICE = 17925

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_PLACEINSERVICE = 17926

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS = 17927

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND_LISTID = 17928

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND_AGENCYID = 17929

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_AUDIBLESOUND_VERSIONID = 17930

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_UNSUPPRESS = 17931

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_REMOVEFROMSERVICE = 17932

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_PLACEINSERVICE = 17933

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS_DIAGNOSTICSLEVEL = 17934

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND_LISTID = 17935

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND_AGENCYID = 17936

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_AUDIBLESOUND_VERSIONID = 17937

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_UNSUPPRESS = 17938

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_REMOVEFROMSERVICE = 17939

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_PLACEINSERVICE = 17940

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID = 17941

const UA_NS0ID_DISCRETEALARMTYPE_AUDIBLESOUND_LISTID = 17942

const UA_NS0ID_DISCRETEALARMTYPE_AUDIBLESOUND_AGENCYID = 17943

const UA_NS0ID_DISCRETEALARMTYPE_AUDIBLESOUND_VERSIONID = 17944

const UA_NS0ID_DISCRETEALARMTYPE_UNSUPPRESS = 17945

const UA_NS0ID_DISCRETEALARMTYPE_REMOVEFROMSERVICE = 17946

const UA_NS0ID_DISCRETEALARMTYPE_PLACEINSERVICE = 17947

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID_DIAGNOSTICSLEVEL = 17948

const UA_NS0ID_OFFNORMALALARMTYPE_AUDIBLESOUND_LISTID = 17949

const UA_NS0ID_OFFNORMALALARMTYPE_AUDIBLESOUND_AGENCYID = 17950

const UA_NS0ID_OFFNORMALALARMTYPE_AUDIBLESOUND_VERSIONID = 17951

const UA_NS0ID_OFFNORMALALARMTYPE_UNSUPPRESS = 17952

const UA_NS0ID_OFFNORMALALARMTYPE_REMOVEFROMSERVICE = 17953

const UA_NS0ID_OFFNORMALALARMTYPE_PLACEINSERVICE = 17954

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID = 17955

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_AUDIBLESOUND_LISTID = 17956

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_AUDIBLESOUND_AGENCYID = 17957

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_AUDIBLESOUND_VERSIONID = 17958

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_UNSUPPRESS = 17959

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_REMOVEFROMSERVICE = 17960

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_PLACEINSERVICE = 17961

const UA_NS0ID_WRITERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID_DIAGNOSTICSLEVEL = 17962

const UA_NS0ID_TRIPALARMTYPE_AUDIBLESOUND_LISTID = 17963

const UA_NS0ID_TRIPALARMTYPE_AUDIBLESOUND_AGENCYID = 17964

const UA_NS0ID_TRIPALARMTYPE_AUDIBLESOUND_VERSIONID = 17965

const UA_NS0ID_TRIPALARMTYPE_UNSUPPRESS = 17966

const UA_NS0ID_TRIPALARMTYPE_REMOVEFROMSERVICE = 17967

const UA_NS0ID_TRIPALARMTYPE_PLACEINSERVICE = 17968

const UA_NS0ID_WRITERGROUPTYPE_ADDDATASETWRITER = 17969

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_AUDIBLESOUND_LISTID = 17970

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_AUDIBLESOUND_AGENCYID = 17971

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_AUDIBLESOUND_VERSIONID = 17972

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_UNSUPPRESS = 17973

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_REMOVEFROMSERVICE = 17974

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_PLACEINSERVICE = 17975

const UA_NS0ID_WRITERGROUPTYPE_ADDDATASETWRITER_INPUTARGUMENTS = 17976

const UA_NS0ID_DISCREPANCYALARMTYPE_AUDIBLESOUND_LISTID = 17977

const UA_NS0ID_DISCREPANCYALARMTYPE_AUDIBLESOUND_AGENCYID = 17978

const UA_NS0ID_DISCREPANCYALARMTYPE_AUDIBLESOUND_VERSIONID = 17979

const UA_NS0ID_DISCREPANCYALARMTYPE_UNSUPPRESS = 17980

const UA_NS0ID_DISCREPANCYALARMTYPE_REMOVEFROMSERVICE = 17981

const UA_NS0ID_DISCREPANCYALARMTYPE_PLACEINSERVICE = 17982

const UA_NS0ID_HASEFFECTENABLE = 17983

const UA_NS0ID_HASEFFECTSUPPRESSED = 17984

const UA_NS0ID_HASEFFECTUNSUPPRESSED = 17985

const UA_NS0ID_AUDIOVARIABLETYPE = 17986

const UA_NS0ID_WRITERGROUPTYPE_ADDDATASETWRITER_OUTPUTARGUMENTS = 17987

const UA_NS0ID_AUDIOVARIABLETYPE_LISTID = 17988

const UA_NS0ID_AUDIOVARIABLETYPE_AGENCYID = 17989

const UA_NS0ID_AUDIOVARIABLETYPE_VERSIONID = 17990

const UA_NS0ID_ALARMMETRICSTYPE_STARTTIME = 17991

const UA_NS0ID_WRITERGROUPTYPE_REMOVEDATASETWRITER = 17992

const UA_NS0ID_WRITERGROUPTYPE_REMOVEDATASETWRITER_INPUTARGUMENTS = 17993

const UA_NS0ID_PUBSUBGROUPTYPEADDWRITERRMETHODTYPE = 17994

const UA_NS0ID_PUBSUBGROUPTYPEADDWRITERRMETHODTYPE_INPUTARGUMENTS = 17995

const UA_NS0ID_PUBSUBGROUPTYPEADDWRITERRMETHODTYPE_OUTPUTARGUMENTS = 17996

const UA_NS0ID_WRITERGROUPTRANSPORTTYPE = 17997

const UA_NS0ID_WRITERGROUPMESSAGETYPE = 17998

const UA_NS0ID_READERGROUPTYPE = 17999

const UA_NS0ID_READERGROUPTYPE_SECURITYMODE = 18000

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE = 18001

const UA_NS0ID_READERGROUPTYPE_SECURITYGROUPID = 18002

const UA_NS0ID_READERGROUPTYPE_SECURITYKEYSERVICES = 18003

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_ENDPOINTURLS = 18004

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_SERVICESTATUS = 18005

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_UPDATECREDENTIAL = 18006

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_UPDATECREDENTIAL_INPUTARGUMENTS = 18007

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_DELETECREDENTIAL = 18008

const UA_NS0ID_KEYCREDENTIALUPDATEMETHODTYPE = 18009

const UA_NS0ID_KEYCREDENTIALUPDATEMETHODTYPE_INPUTARGUMENTS = 18010

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE = 18011

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_EVENTID = 18012

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_EVENTTYPE = 18013

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_SOURCENODE = 18014

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_SOURCENAME = 18015

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_TIME = 18016

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_RECEIVETIME = 18017

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_LOCALTIME = 18018

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_MESSAGE = 18019

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_SEVERITY = 18020

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_ACTIONTIMESTAMP = 18021

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_STATUS = 18022

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_SERVERID = 18023

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_CLIENTAUDITENTRYID = 18024

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_CLIENTUSERID = 18025

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_METHODID = 18026

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_INPUTARGUMENTS = 18027

const UA_NS0ID_KEYCREDENTIALAUDITEVENTTYPE_RESOURCEURI = 18028

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE = 18029

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_EVENTID = 18030

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_EVENTTYPE = 18031

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_SOURCENODE = 18032

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_SOURCENAME = 18033

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_TIME = 18034

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_RECEIVETIME = 18035

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_LOCALTIME = 18036

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_MESSAGE = 18037

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_SEVERITY = 18038

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_ACTIONTIMESTAMP = 18039

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_STATUS = 18040

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_SERVERID = 18041

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_CLIENTAUDITENTRYID = 18042

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_CLIENTUSERID = 18043

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_METHODID = 18044

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_INPUTARGUMENTS = 18045

const UA_NS0ID_KEYCREDENTIALUPDATEDAUDITEVENTTYPE_RESOURCEURI = 18046

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE = 18047

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_EVENTID = 18048

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_EVENTTYPE = 18049

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_SOURCENODE = 18050

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_SOURCENAME = 18051

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_TIME = 18052

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_RECEIVETIME = 18053

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_LOCALTIME = 18054

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_MESSAGE = 18055

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_SEVERITY = 18056

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_ACTIONTIMESTAMP = 18057

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_STATUS = 18058

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_SERVERID = 18059

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_CLIENTAUDITENTRYID = 18060

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_CLIENTUSERID = 18061

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_METHODID = 18062

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_INPUTARGUMENTS = 18063

const UA_NS0ID_KEYCREDENTIALDELETEDAUDITEVENTTYPE_RESOURCEURI = 18064

const UA_NS0ID_READERGROUPTYPE_MAXNETWORKMESSAGESIZE = 18065

const UA_NS0ID_AUTHORIZATIONSERVICES_SERVICENAME_PLACEHOLDER_SERVICECERTIFICATE = 18066

const UA_NS0ID_READERGROUPTYPE_STATUS = 18067

const UA_NS0ID_READERGROUPTYPE_STATUS_STATE = 18068

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_RESOURCEURI = 18069

const UA_NS0ID_AUTHORIZATIONSERVICES_SERVICENAME_PLACEHOLDER_SERVICEURI = 18070

const UA_NS0ID_AUTHORIZATIONSERVICES_SERVICENAME_PLACEHOLDER_ISSUERENDPOINTURL = 18071

const UA_NS0ID_AUTHORIZATIONSERVICECONFIGURATIONTYPE_SERVICEURI = 18072

const UA_NS0ID_AUTHORIZATIONSERVICECONFIGURATIONTYPE_ISSUERENDPOINTURL = 18073

const UA_NS0ID_READERGROUPTYPE_STATUS_ENABLE = 18074

const UA_NS0ID_READERGROUPTYPE_STATUS_DISABLE = 18075

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER = 18076

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_PUBLISHERID = 18077

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_WRITERGROUPID = 18078

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DATASETWRITERID = 18079

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DATASETMETADATA = 18080

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DATASETFIELDCONTENTMASK = 18081

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_MESSAGERECEIVETIMEOUT = 18082

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_SECURITYMODE = 18083

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_SECURITYGROUPID = 18084

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_SECURITYKEYSERVICES = 18085

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_TRANSPORTSETTINGS = 18086

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_MESSAGESETTINGS = 18087

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_STATUS = 18088

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_STATUS_STATE = 18089

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_STATUS_ENABLE = 18090

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_STATUS_DISABLE = 18091

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS = 18092

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 18093

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 18094

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 18095

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 18096

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 18097

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 18098

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 18099

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 18100

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 18101

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 18102

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 18103

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 18104

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 18105

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 18106

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 18107

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 18108

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 18109

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 18110

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 18111

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 18112

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 18113

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 18114

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 18115

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 18116

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 18117

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 18118

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 18119

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 18120

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 18121

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 18122

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 18123

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 18124

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 18125

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 18126

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 18127

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 18128

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 18129

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 18130

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 18131

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 18132

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 18133

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 18134

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 18135

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 18136

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 18137

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 18138

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 18139

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 18140

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 18141

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 18142

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS = 18143

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_ACTIVE = 18144

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_CLASSIFICATION = 18145

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_DIAGNOSTICSLEVEL = 18146

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_TIMEFIRSTCHANGE = 18147

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 18148

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 18149

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 18150

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 18151

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 18152

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 18153

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 18154

const UA_NS0ID_KEYCREDENTIALCONFIGURATION = 18155

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER = 18156

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_RESOURCEURI = 18157

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 18158

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_ENDPOINTURLS = 18159

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_SERVICESTATUS = 18160

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_UPDATECREDENTIAL = 18161

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_UPDATECREDENTIAL_INPUTARGUMENTS = 18162

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_DELETECREDENTIAL = 18163

const UA_NS0ID_KEYCREDENTIALCONFIGURATION_SERVICENAME_PLACEHOLDER_PROFILEURI = 18164

const UA_NS0ID_KEYCREDENTIALCONFIGURATIONTYPE_PROFILEURI = 18165

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEDEFINITION = 18166

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEDEFINITION_DATATYPEVERSION = 18167

const UA_NS0ID_OPCUA_XMLSCHEMA_DATATYPEDEFINITION_DICTIONARYFRAGMENT = 18168

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREFIELD = 18169

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREFIELD_DATATYPEVERSION = 18170

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREFIELD_DICTIONARYFRAGMENT = 18171

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREDEFINITION = 18172

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREDEFINITION_DATATYPEVERSION = 18173

const UA_NS0ID_OPCUA_XMLSCHEMA_STRUCTUREDEFINITION_DICTIONARYFRAGMENT = 18174

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMDEFINITION = 18175

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMDEFINITION_DATATYPEVERSION = 18176

const UA_NS0ID_OPCUA_XMLSCHEMA_ENUMDEFINITION_DICTIONARYFRAGMENT = 18177

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEDEFINITION = 18178

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEDEFINITION_DATATYPEVERSION = 18179

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATATYPEDEFINITION_DICTIONARYFRAGMENT = 18180

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREFIELD = 18181

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREFIELD_DATATYPEVERSION = 18182

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREFIELD_DICTIONARYFRAGMENT = 18183

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREDEFINITION = 18184

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREDEFINITION_DATATYPEVERSION = 18185

const UA_NS0ID_OPCUA_BINARYSCHEMA_STRUCTUREDEFINITION_DICTIONARYFRAGMENT = 18186

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMDEFINITION = 18187

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMDEFINITION_DATATYPEVERSION = 18188

const UA_NS0ID_OPCUA_BINARYSCHEMA_ENUMDEFINITION_DICTIONARYFRAGMENT = 18189

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE = 18190

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_ID = 18191

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_NAME = 18192

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_NUMBER = 18193

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18194

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_TRANSITIONTIME = 18195

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18196

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_TRUESTATE = 18197

const UA_NS0ID_ALARMCONDITIONTYPE_LATCHEDSTATE_FALSESTATE = 18198

const UA_NS0ID_ALARMCONDITIONTYPE_RESET = 18199

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_AUDIBLESOUND_LISTID = 18200

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_AUDIBLESOUND_AGENCYID = 18201

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_AUDIBLESOUND_VERSIONID = 18202

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE = 18203

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_ID = 18204

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_NAME = 18205

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_NUMBER = 18206

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18207

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_TRANSITIONTIME = 18208

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18209

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_TRUESTATE = 18210

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_LATCHEDSTATE_FALSESTATE = 18211

const UA_NS0ID_ALARMGROUPTYPE_ALARMCONDITIONINSTANCE_PLACEHOLDER_RESET = 18212

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE = 18213

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_ID = 18214

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_NAME = 18215

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_NUMBER = 18216

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18217

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18218

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18219

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_TRUESTATE = 18220

const UA_NS0ID_LIMITALARMTYPE_LATCHEDSTATE_FALSESTATE = 18221

const UA_NS0ID_LIMITALARMTYPE_RESET = 18222

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE = 18223

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_ID = 18224

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_NAME = 18225

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_NUMBER = 18226

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18227

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18228

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18229

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_TRUESTATE = 18230

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_FALSESTATE = 18231

const UA_NS0ID_EXCLUSIVELIMITALARMTYPE_RESET = 18232

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE = 18233

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_ID = 18234

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_NAME = 18235

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_NUMBER = 18236

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18237

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18238

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18239

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_TRUESTATE = 18240

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_LATCHEDSTATE_FALSESTATE = 18241

const UA_NS0ID_NONEXCLUSIVELIMITALARMTYPE_RESET = 18242

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_AUDIBLESOUND_LISTID = 18243

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_AUDIBLESOUND_AGENCYID = 18244

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_AUDIBLESOUND_VERSIONID = 18245

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE = 18246

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_ID = 18247

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_NAME = 18248

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_NUMBER = 18249

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18250

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18251

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18252

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_TRUESTATE = 18253

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_FALSESTATE = 18254

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_UNSUPPRESS = 18255

const UA_NS0ID_NONEXCLUSIVELEVELALARMTYPE_RESET = 18256

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE = 18257

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_ID = 18258

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_NAME = 18259

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_NUMBER = 18260

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18261

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18262

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18263

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_TRUESTATE = 18264

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_LATCHEDSTATE_FALSESTATE = 18265

const UA_NS0ID_EXCLUSIVELEVELALARMTYPE_RESET = 18266

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE = 18267

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_ID = 18268

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_NAME = 18269

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_NUMBER = 18270

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18271

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18272

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18273

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_TRUESTATE = 18274

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_FALSESTATE = 18275

const UA_NS0ID_NONEXCLUSIVEDEVIATIONALARMTYPE_RESET = 18276

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE = 18277

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_ID = 18278

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_NAME = 18279

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_NUMBER = 18280

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18281

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18282

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18283

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_TRUESTATE = 18284

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_FALSESTATE = 18285

const UA_NS0ID_NONEXCLUSIVERATEOFCHANGEALARMTYPE_RESET = 18286

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE = 18287

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_ID = 18288

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_NAME = 18289

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_NUMBER = 18290

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18291

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18292

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18293

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_TRUESTATE = 18294

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_LATCHEDSTATE_FALSESTATE = 18295

const UA_NS0ID_EXCLUSIVEDEVIATIONALARMTYPE_RESET = 18296

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE = 18297

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_ID = 18298

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_NAME = 18299

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_NUMBER = 18300

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18301

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18302

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18303

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_TRUESTATE = 18304

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_LATCHEDSTATE_FALSESTATE = 18305

const UA_NS0ID_EXCLUSIVERATEOFCHANGEALARMTYPE_RESET = 18306

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE = 18307

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_ID = 18308

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_NAME = 18309

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_NUMBER = 18310

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18311

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18312

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18313

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_TRUESTATE = 18314

const UA_NS0ID_DISCRETEALARMTYPE_LATCHEDSTATE_FALSESTATE = 18315

const UA_NS0ID_DISCRETEALARMTYPE_RESET = 18316

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE = 18317

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_ID = 18318

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_NAME = 18319

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_NUMBER = 18320

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18321

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18322

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18323

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_TRUESTATE = 18324

const UA_NS0ID_OFFNORMALALARMTYPE_LATCHEDSTATE_FALSESTATE = 18325

const UA_NS0ID_OFFNORMALALARMTYPE_RESET = 18326

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE = 18327

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_ID = 18328

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_NAME = 18329

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_NUMBER = 18330

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18331

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18332

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18333

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_TRUESTATE = 18334

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_LATCHEDSTATE_FALSESTATE = 18335

const UA_NS0ID_SYSTEMOFFNORMALALARMTYPE_RESET = 18336

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE = 18337

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_ID = 18338

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_NAME = 18339

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_NUMBER = 18340

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18341

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18342

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18343

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_TRUESTATE = 18344

const UA_NS0ID_TRIPALARMTYPE_LATCHEDSTATE_FALSESTATE = 18345

const UA_NS0ID_TRIPALARMTYPE_RESET = 18346

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE = 18347

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_EVENTID = 18348

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_EVENTTYPE = 18349

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SOURCENODE = 18350

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SOURCENAME = 18351

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_TIME = 18352

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_RECEIVETIME = 18353

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LOCALTIME = 18354

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_MESSAGE = 18355

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SEVERITY = 18356

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONCLASSID = 18357

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONCLASSNAME = 18358

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONSUBCLASSID = 18359

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONSUBCLASSNAME = 18360

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONNAME = 18361

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_BRANCHID = 18362

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_RETAIN = 18363

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE = 18364

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_ID = 18365

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_NAME = 18366

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_NUMBER = 18367

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 18368

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 18369

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 18370

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_TRUESTATE = 18371

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLEDSTATE_FALSESTATE = 18372

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_QUALITY = 18373

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_QUALITY_SOURCETIMESTAMP = 18374

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LASTSEVERITY = 18375

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 18376

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_COMMENT = 18377

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_COMMENT_SOURCETIMESTAMP = 18378

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CLIENTUSERID = 18379

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_DISABLE = 18380

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ENABLE = 18381

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ADDCOMMENT = 18382

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 18383

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONREFRESH = 18384

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 18385

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONREFRESH2 = 18386

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 18387

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE = 18388

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_ID = 18389

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_NAME = 18390

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_NUMBER = 18391

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 18392

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 18393

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 18394

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_TRUESTATE = 18395

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKEDSTATE_FALSESTATE = 18396

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE = 18397

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_ID = 18398

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_NAME = 18399

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_NUMBER = 18400

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 18401

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 18402

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 18403

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 18404

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 18405

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKNOWLEDGE = 18406

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 18407

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRM = 18408

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_CONFIRM_INPUTARGUMENTS = 18409

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE = 18410

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_ID = 18411

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_NAME = 18412

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_NUMBER = 18413

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 18414

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 18415

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 18416

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_TRUESTATE = 18417

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ACTIVESTATE_FALSESTATE = 18418

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_INPUTNODE = 18419

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE = 18420

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_ID = 18421

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_NAME = 18422

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_NUMBER = 18423

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 18424

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 18425

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 18426

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 18427

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 18428

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE = 18429

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_ID = 18430

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_NAME = 18431

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_NUMBER = 18432

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 18433

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 18434

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 18435

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 18436

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 18437

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE = 18438

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 18439

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 18440

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 18441

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 18442

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 18443

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 18444

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 18445

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 18446

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 18447

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 18448

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 18449

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 18450

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 18451

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 18452

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 18453

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 18454

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_UNSHELVE = 18455

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 18456

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESSEDORSHELVED = 18457

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_MAXTIMESHELVED = 18458

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_AUDIBLEENABLED = 18459

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_AUDIBLESOUND = 18460

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_AUDIBLESOUND_LISTID = 18461

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_AUDIBLESOUND_AGENCYID = 18462

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_AUDIBLESOUND_VERSIONID = 18463

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE = 18464

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_ID = 18465

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_NAME = 18466

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_NUMBER = 18467

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 18468

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_TRANSITIONTIME = 18469

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 18470

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_TRUESTATE = 18471

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCESTATE_FALSESTATE = 18472

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ONDELAY = 18473

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_OFFDELAY = 18474

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_FIRSTINGROUPFLAG = 18475

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_FIRSTINGROUP = 18476

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE = 18477

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_ID = 18478

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_NAME = 18479

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_NUMBER = 18480

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18481

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18482

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18483

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_TRUESTATE = 18484

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_LATCHEDSTATE_FALSESTATE = 18485

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_ALARMGROUP_PLACEHOLDER = 18486

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_REALARMTIME = 18487

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_REALARMREPEATCOUNT = 18488

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SILENCE = 18489

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_SUPPRESS = 18490

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_UNSUPPRESS = 18491

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_REMOVEFROMSERVICE = 18492

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_PLACEINSERVICE = 18493

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_RESET = 18494

const UA_NS0ID_INSTRUMENTDIAGNOSTICALARMTYPE_NORMALSTATE = 18495

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE = 18496

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_EVENTID = 18497

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_EVENTTYPE = 18498

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SOURCENODE = 18499

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SOURCENAME = 18500

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_TIME = 18501

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_RECEIVETIME = 18502

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LOCALTIME = 18503

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_MESSAGE = 18504

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SEVERITY = 18505

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONCLASSID = 18506

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONCLASSNAME = 18507

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONSUBCLASSID = 18508

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONSUBCLASSNAME = 18509

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONNAME = 18510

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_BRANCHID = 18511

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_RETAIN = 18512

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE = 18513

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_ID = 18514

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_NAME = 18515

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_NUMBER = 18516

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_EFFECTIVEDISPLAYNAME = 18517

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_TRANSITIONTIME = 18518

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_EFFECTIVETRANSITIONTIME = 18519

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_TRUESTATE = 18520

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLEDSTATE_FALSESTATE = 18521

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_QUALITY = 18522

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_QUALITY_SOURCETIMESTAMP = 18523

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LASTSEVERITY = 18524

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LASTSEVERITY_SOURCETIMESTAMP = 18525

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_COMMENT = 18526

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_COMMENT_SOURCETIMESTAMP = 18527

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CLIENTUSERID = 18528

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_DISABLE = 18529

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ENABLE = 18530

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ADDCOMMENT = 18531

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ADDCOMMENT_INPUTARGUMENTS = 18532

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONREFRESH = 18533

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONREFRESH_INPUTARGUMENTS = 18534

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONREFRESH2 = 18535

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONDITIONREFRESH2_INPUTARGUMENTS = 18536

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE = 18537

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_ID = 18538

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_NAME = 18539

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_NUMBER = 18540

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_EFFECTIVEDISPLAYNAME = 18541

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_TRANSITIONTIME = 18542

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_EFFECTIVETRANSITIONTIME = 18543

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_TRUESTATE = 18544

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKEDSTATE_FALSESTATE = 18545

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE = 18546

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_ID = 18547

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_NAME = 18548

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_NUMBER = 18549

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_EFFECTIVEDISPLAYNAME = 18550

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_TRANSITIONTIME = 18551

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_EFFECTIVETRANSITIONTIME = 18552

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_TRUESTATE = 18553

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRMEDSTATE_FALSESTATE = 18554

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKNOWLEDGE = 18555

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACKNOWLEDGE_INPUTARGUMENTS = 18556

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRM = 18557

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_CONFIRM_INPUTARGUMENTS = 18558

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE = 18559

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_ID = 18560

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_NAME = 18561

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_NUMBER = 18562

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_EFFECTIVEDISPLAYNAME = 18563

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_TRANSITIONTIME = 18564

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_EFFECTIVETRANSITIONTIME = 18565

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_TRUESTATE = 18566

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ACTIVESTATE_FALSESTATE = 18567

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_INPUTNODE = 18568

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE = 18569

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_ID = 18570

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_NAME = 18571

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_NUMBER = 18572

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_EFFECTIVEDISPLAYNAME = 18573

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_TRANSITIONTIME = 18574

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_EFFECTIVETRANSITIONTIME = 18575

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_TRUESTATE = 18576

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDSTATE_FALSESTATE = 18577

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE = 18578

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_ID = 18579

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_NAME = 18580

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_NUMBER = 18581

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_EFFECTIVEDISPLAYNAME = 18582

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_TRANSITIONTIME = 18583

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_EFFECTIVETRANSITIONTIME = 18584

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_TRUESTATE = 18585

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OUTOFSERVICESTATE_FALSESTATE = 18586

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE = 18587

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE = 18588

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_ID = 18589

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NAME = 18590

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_NUMBER = 18591

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_CURRENTSTATE_EFFECTIVEDISPLAYNAME = 18592

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION = 18593

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_ID = 18594

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NAME = 18595

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_NUMBER = 18596

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_TRANSITIONTIME = 18597

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_LASTTRANSITION_EFFECTIVETRANSITIONTIME = 18598

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_AVAILABLESTATES = 18599

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_AVAILABLETRANSITIONS = 18600

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_UNSHELVETIME = 18601

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_TIMEDSHELVE = 18602

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_TIMEDSHELVE_INPUTARGUMENTS = 18603

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_UNSHELVE = 18604

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SHELVINGSTATE_ONESHOTSHELVE = 18605

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESSEDORSHELVED = 18606

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_MAXTIMESHELVED = 18607

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_AUDIBLEENABLED = 18608

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_AUDIBLESOUND = 18609

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_AUDIBLESOUND_LISTID = 18610

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_AUDIBLESOUND_AGENCYID = 18611

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_AUDIBLESOUND_VERSIONID = 18612

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE = 18613

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_ID = 18614

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_NAME = 18615

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_NUMBER = 18616

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_EFFECTIVEDISPLAYNAME = 18617

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_TRANSITIONTIME = 18618

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_EFFECTIVETRANSITIONTIME = 18619

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_TRUESTATE = 18620

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCESTATE_FALSESTATE = 18621

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ONDELAY = 18622

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_OFFDELAY = 18623

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_FIRSTINGROUPFLAG = 18624

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_FIRSTINGROUP = 18625

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE = 18626

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_ID = 18627

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_NAME = 18628

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_NUMBER = 18629

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18630

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18631

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18632

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_TRUESTATE = 18633

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_LATCHEDSTATE_FALSESTATE = 18634

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_ALARMGROUP_PLACEHOLDER = 18635

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_REALARMTIME = 18636

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_REALARMREPEATCOUNT = 18637

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SILENCE = 18638

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_SUPPRESS = 18639

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_UNSUPPRESS = 18640

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_REMOVEFROMSERVICE = 18641

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_PLACEINSERVICE = 18642

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_RESET = 18643

const UA_NS0ID_SYSTEMDIAGNOSTICALARMTYPE_NORMALSTATE = 18644

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE = 18645

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_ID = 18646

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_NAME = 18647

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_NUMBER = 18648

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18649

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18650

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18651

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_TRUESTATE = 18652

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_LATCHEDSTATE_FALSESTATE = 18653

const UA_NS0ID_CERTIFICATEEXPIRATIONALARMTYPE_RESET = 18654

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE = 18655

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_ID = 18656

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_NAME = 18657

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_NUMBER = 18658

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_EFFECTIVEDISPLAYNAME = 18659

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_TRANSITIONTIME = 18660

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_EFFECTIVETRANSITIONTIME = 18661

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_TRUESTATE = 18662

const UA_NS0ID_DISCREPANCYALARMTYPE_LATCHEDSTATE_FALSESTATE = 18663

const UA_NS0ID_DISCREPANCYALARMTYPE_RESET = 18664

const UA_NS0ID_STATISTICALCONDITIONCLASSTYPE = 18665

const UA_NS0ID_ALARMMETRICSTYPE_RESET = 18666

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS = 18667

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 18668

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 18669

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 18670

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 18671

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 18672

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 18673

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 18674

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 18675

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 18676

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 18677

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 18678

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 18679

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 18680

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 18681

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 18682

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 18683

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 18684

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 18685

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 18686

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 18687

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 18688

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 18689

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 18690

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 18691

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 18692

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 18693

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 18694

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 18695

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 18696

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 18697

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 18698

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 18699

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 18700

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 18701

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 18702

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 18703

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 18704

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 18705

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 18706

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 18707

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 18708

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 18709

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 18710

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 18711

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 18712

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_RESOLVEDADDRESS = 18713

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_CONNECTIONNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_RESOLVEDADDRESS_DIAGNOSTICSLEVEL = 18714

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS = 18715

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 18716

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALINFORMATION = 18717

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 18718

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 18719

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 18720

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 18721

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALERROR = 18722

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALERROR_ACTIVE = 18723

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 18724

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 18725

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 18726

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_RESET = 18727

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_SUBERROR = 18728

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS = 18729

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEERROR = 18730

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 18731

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 18732

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 18733

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 18734

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 18735

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 18736

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 18737

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 18738

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 18739

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 18740

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 18741

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 18742

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 18743

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 18744

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 18745

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 18746

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 18747

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 18748

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 18749

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 18750

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 18751

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 18752

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 18753

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 18754

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 18755

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 18756

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 18757

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 18758

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 18759

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES = 18760

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS = 18761

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS_DIAGNOSTICSLEVEL = 18762

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS = 18763

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS_DIAGNOSTICSLEVEL = 18764

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS = 18765

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS_DIAGNOSTICSLEVEL = 18766

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS = 18767

const UA_NS0ID_PUBLISHSUBSCRIBETYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS_DIAGNOSTICSLEVEL = 18768

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS = 18871

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 18872

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 18873

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 18874

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 18875

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 18876

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 18877

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 18878

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 18879

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 18880

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 18881

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 18882

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 18883

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 18884

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 18885

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 18886

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 18887

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 18888

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 18889

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 18890

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 18891

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 18892

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 18893

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 18894

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 18895

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 18896

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 18897

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 18898

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 18899

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 18900

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 18901

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 18902

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 18903

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 18904

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 18905

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 18906

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 18907

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 18908

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 18909

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 18910

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 18911

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 18912

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 18913

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 18914

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 18915

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 18916

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 18917

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 18918

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 18919

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 18920

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 18921

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 18922

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 18923

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 18924

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 18925

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 18926

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 18927

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 18928

const UA_NS0ID_PUBLISHEDDATASETTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 18929

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS = 18930

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 18931

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 18932

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 18933

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 18934

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 18935

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 18936

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 18937

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 18938

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 18939

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 18940

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 18941

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 18942

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 18943

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 18944

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 18945

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 18946

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 18947

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 18948

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 18949

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 18950

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 18951

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 18952

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 18953

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 18954

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 18955

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 18956

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 18957

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 18958

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 18959

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 18960

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 18961

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 18962

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 18963

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 18964

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 18965

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 18966

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 18967

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 18968

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 18969

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 18970

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 18971

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 18972

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 18973

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 18974

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 18975

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 18976

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 18977

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 18978

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 18979

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 18980

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 18981

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 18982

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 18983

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 18984

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 18985

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 18986

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 18987

const UA_NS0ID_PUBLISHEDDATAITEMSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 18988

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS = 18989

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 18990

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 18991

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 18992

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 18993

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 18994

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 18995

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 18996

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 18997

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 18998

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 18999

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 19000

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 19001

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 19002

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 19003

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 19004

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 19005

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 19006

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19007

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19008

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 19009

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19010

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19011

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19012

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19013

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 19014

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19015

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19016

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19017

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19018

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 19019

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19020

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19021

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19022

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19023

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 19024

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19025

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19026

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19027

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19028

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 19029

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19030

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19031

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19032

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19033

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 19034

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 19035

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 19036

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 19037

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 19038

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 19039

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 19040

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 19041

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 19042

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 19043

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 19044

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 19045

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 19046

const UA_NS0ID_PUBLISHEDEVENTSTYPE_DATASETWRITERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 19047

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS = 19107

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 19108

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 19109

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 19110

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 19111

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19112

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 19113

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 19114

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 19115

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 19116

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 19117

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 19118

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 19119

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 19120

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 19121

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 19122

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 19123

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 19124

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19125

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19126

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 19127

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19128

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19129

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19130

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19131

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 19132

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19133

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19134

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19135

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19136

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 19137

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19138

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19139

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19140

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19141

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 19142

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19143

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19144

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19145

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19146

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 19147

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19148

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19149

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19150

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19151

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 19152

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES = 19153

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_ACTIVE = 19154

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_CLASSIFICATION = 19155

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_DIAGNOSTICSLEVEL = 19156

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_SENTNETWORKMESSAGES_TIMEFIRSTCHANGE = 19157

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS = 19158

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_ACTIVE = 19159

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_CLASSIFICATION = 19160

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_DIAGNOSTICSLEVEL = 19161

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_FAILEDTRANSMISSIONS_TIMEFIRSTCHANGE = 19162

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS = 19163

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_ACTIVE = 19164

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_CLASSIFICATION = 19165

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_DIAGNOSTICSLEVEL = 19166

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_ENCRYPTIONERRORS_TIMEFIRSTCHANGE = 19167

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS = 19168

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETWRITERS_DIAGNOSTICSLEVEL = 19169

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS = 19170

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETWRITERS_DIAGNOSTICSLEVEL = 19171

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID = 19172

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID_DIAGNOSTICSLEVEL = 19173

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID = 19174

const UA_NS0ID_PUBSUBCONNECTIONTYPE_WRITERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID_DIAGNOSTICSLEVEL = 19175

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS = 19176

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_DIAGNOSTICSLEVEL = 19177

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION = 19178

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 19179

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 19180

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19181

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 19182

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR = 19183

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_ACTIVE = 19184

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 19185

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 19186

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 19187

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_RESET = 19188

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_SUBERROR = 19189

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS = 19190

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR = 19191

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 19192

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 19193

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19194

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19195

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 19196

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19197

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19198

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19199

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19200

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 19201

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19202

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19203

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19204

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19205

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 19206

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19207

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19208

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19209

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19210

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 19211

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19212

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19213

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19214

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19215

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 19216

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19217

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19218

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19219

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19220

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES = 19221

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES = 19222

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_ACTIVE = 19223

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_CLASSIFICATION = 19224

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_DIAGNOSTICSLEVEL = 19225

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_TIMEFIRSTCHANGE = 19226

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES = 19227

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_ACTIVE = 19228

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_CLASSIFICATION = 19229

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_DIAGNOSTICSLEVEL = 19230

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_TIMEFIRSTCHANGE = 19231

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS = 19232

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_ACTIVE = 19233

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_CLASSIFICATION = 19234

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_DIAGNOSTICSLEVEL = 19235

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_TIMEFIRSTCHANGE = 19236

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS = 19237

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS_DIAGNOSTICSLEVEL = 19238

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS = 19239

const UA_NS0ID_PUBSUBCONNECTIONTYPE_READERGROUPNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS_DIAGNOSTICSLEVEL = 19240

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS = 19241

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 19242

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALINFORMATION = 19243

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 19244

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 19245

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19246

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 19247

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALERROR = 19248

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALERROR_ACTIVE = 19249

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 19250

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 19251

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 19252

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_RESET = 19253

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_SUBERROR = 19254

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS = 19255

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEERROR = 19256

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 19257

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 19258

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19259

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19260

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 19261

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19262

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19263

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19264

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19265

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 19266

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19267

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19268

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19269

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19270

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 19271

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19272

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19273

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19274

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19275

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 19276

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19277

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19278

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19279

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19280

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 19281

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19282

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19283

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19284

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19285

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_LIVEVALUES = 19286

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_LIVEVALUES_RESOLVEDADDRESS = 19287

const UA_NS0ID_PUBSUBCONNECTIONTYPE_DIAGNOSTICS_LIVEVALUES_RESOLVEDADDRESS_DIAGNOSTICSLEVEL = 19288

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS = 19550

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 19551

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALINFORMATION = 19552

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 19553

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 19554

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19555

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 19556

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALERROR = 19557

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALERROR_ACTIVE = 19558

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 19559

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 19560

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 19561

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_RESET = 19562

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_SUBERROR = 19563

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS = 19564

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR = 19565

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 19566

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 19567

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19568

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19569

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 19570

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19571

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19572

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19573

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19574

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 19575

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19576

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19577

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19578

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19579

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 19580

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19581

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19582

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19583

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19584

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 19585

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19586

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19587

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19588

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19589

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 19590

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19591

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19592

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19593

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19594

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES = 19595

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 19596

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 19597

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 19598

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 19599

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 19600

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 19601

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 19602

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 19603

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 19604

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 19605

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 19606

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 19607

const UA_NS0ID_DATASETWRITERTYPE_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 19608

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS = 19609

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 19610

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALINFORMATION = 19611

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 19612

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 19613

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19614

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 19615

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALERROR = 19616

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALERROR_ACTIVE = 19617

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 19618

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 19619

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 19620

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_RESET = 19621

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_SUBERROR = 19622

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS = 19623

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR = 19624

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 19625

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 19626

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19627

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19628

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 19629

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19630

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19631

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19632

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19633

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 19634

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19635

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19636

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19637

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19638

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 19639

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19640

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19641

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19642

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19643

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 19644

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19645

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19646

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19647

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19648

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 19649

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19650

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19651

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19652

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19653

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES = 19654

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES = 19655

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 19656

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 19657

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 19658

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 19659

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS = 19660

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_ACTIVE = 19661

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_CLASSIFICATION = 19662

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_DIAGNOSTICSLEVEL = 19663

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_TIMEFIRSTCHANGE = 19664

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER = 19665

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 19666

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_STATUSCODE = 19667

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 19668

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_MAJORVERSION = 19669

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 19670

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_MINORVERSION = 19671

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 19672

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID = 19673

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID_DIAGNOSTICSLEVEL = 19674

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID = 19675

const UA_NS0ID_DATASETREADERTYPE_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID_DIAGNOSTICSLEVEL = 19676

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE = 19677

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_DIAGNOSTICSLEVEL = 19678

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALINFORMATION = 19679

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALINFORMATION_ACTIVE = 19680

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALINFORMATION_CLASSIFICATION = 19681

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19682

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 19683

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALERROR = 19684

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALERROR_ACTIVE = 19685

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALERROR_CLASSIFICATION = 19686

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 19687

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_TOTALERROR_TIMEFIRSTCHANGE = 19688

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_RESET = 19689

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_SUBERROR = 19690

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS = 19691

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEERROR = 19692

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEERROR_ACTIVE = 19693

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 19694

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19695

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19696

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 19697

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19698

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19699

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19700

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19701

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 19702

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19703

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19704

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19705

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19706

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 19707

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19708

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19709

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19710

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19711

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEPAUSEDBYPARENT = 19712

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19713

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19714

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19715

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19716

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 19717

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19718

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19719

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19720

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19721

const UA_NS0ID_PUBSUBDIAGNOSTICSTYPE_LIVEVALUES = 19722

const UA_NS0ID_DIAGNOSTICSLEVEL = 19723

const UA_NS0ID_DIAGNOSTICSLEVEL_ENUMSTRINGS = 19724

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERTYPE = 19725

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERTYPE_ACTIVE = 19726

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERTYPE_CLASSIFICATION = 19727

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERTYPE_DIAGNOSTICSLEVEL = 19728

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERTYPE_TIMEFIRSTCHANGE = 19729

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERCLASSIFICATION = 19730

const UA_NS0ID_PUBSUBDIAGNOSTICSCOUNTERCLASSIFICATION_ENUMSTRINGS = 19731

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE = 19732

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_DIAGNOSTICSLEVEL = 19733

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALINFORMATION = 19734

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALINFORMATION_ACTIVE = 19735

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALINFORMATION_CLASSIFICATION = 19736

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19737

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 19738

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALERROR = 19739

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALERROR_ACTIVE = 19740

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALERROR_CLASSIFICATION = 19741

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 19742

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_TOTALERROR_TIMEFIRSTCHANGE = 19743

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_RESET = 19744

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_SUBERROR = 19745

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS = 19746

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEERROR = 19747

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEERROR_ACTIVE = 19748

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 19749

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19750

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19751

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 19752

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19753

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19754

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19755

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19756

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 19757

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19758

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19759

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19760

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19761

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 19762

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19763

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19764

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19765

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19766

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEPAUSEDBYPARENT = 19767

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19768

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19769

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19770

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19771

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 19772

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19773

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19774

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19775

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19776

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES = 19777

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_CONFIGUREDDATASETWRITERS = 19778

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_CONFIGUREDDATASETWRITERS_DIAGNOSTICSLEVEL = 19779

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_CONFIGUREDDATASETREADERS = 19780

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_CONFIGUREDDATASETREADERS_DIAGNOSTICSLEVEL = 19781

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_OPERATIONALDATASETWRITERS = 19782

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_OPERATIONALDATASETWRITERS_DIAGNOSTICSLEVEL = 19783

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_OPERATIONALDATASETREADERS = 19784

const UA_NS0ID_PUBSUBDIAGNOSTICSROOTTYPE_LIVEVALUES_OPERATIONALDATASETREADERS_DIAGNOSTICSLEVEL = 19785

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE = 19786

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_DIAGNOSTICSLEVEL = 19787

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALINFORMATION = 19788

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALINFORMATION_ACTIVE = 19789

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALINFORMATION_CLASSIFICATION = 19790

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19791

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 19792

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALERROR = 19793

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALERROR_ACTIVE = 19794

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALERROR_CLASSIFICATION = 19795

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 19796

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_TOTALERROR_TIMEFIRSTCHANGE = 19797

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_RESET = 19798

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_SUBERROR = 19799

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS = 19800

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEERROR = 19801

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEERROR_ACTIVE = 19802

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 19803

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19804

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19805

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 19806

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19807

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19808

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19809

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19810

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 19811

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19812

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19813

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19814

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19815

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 19816

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19817

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19818

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19819

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19820

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEPAUSEDBYPARENT = 19821

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19822

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19823

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19824

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19825

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 19826

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19827

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19828

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19829

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19830

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_LIVEVALUES = 19831

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_LIVEVALUES_RESOLVEDADDRESS = 19832

const UA_NS0ID_PUBSUBDIAGNOSTICSCONNECTIONTYPE_LIVEVALUES_RESOLVEDADDRESS_DIAGNOSTICSLEVEL = 19833

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE = 19834

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_DIAGNOSTICSLEVEL = 19835

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALINFORMATION = 19836

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALINFORMATION_ACTIVE = 19837

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALINFORMATION_CLASSIFICATION = 19838

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19839

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 19840

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALERROR = 19841

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALERROR_ACTIVE = 19842

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALERROR_CLASSIFICATION = 19843

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 19844

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_TOTALERROR_TIMEFIRSTCHANGE = 19845

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_RESET = 19846

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_SUBERROR = 19847

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS = 19848

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEERROR = 19849

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEERROR_ACTIVE = 19850

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 19851

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19852

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19853

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 19854

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19855

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19856

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19857

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19858

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 19859

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19860

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19861

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19862

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19863

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 19864

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19865

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19866

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19867

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19868

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT = 19869

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19870

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19871

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19872

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19873

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 19874

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19875

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19876

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19877

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19878

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES = 19879

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_SENTNETWORKMESSAGES = 19880

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_SENTNETWORKMESSAGES_ACTIVE = 19881

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_SENTNETWORKMESSAGES_CLASSIFICATION = 19882

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_SENTNETWORKMESSAGES_DIAGNOSTICSLEVEL = 19883

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_SENTNETWORKMESSAGES_TIMEFIRSTCHANGE = 19884

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_FAILEDTRANSMISSIONS = 19885

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_FAILEDTRANSMISSIONS_ACTIVE = 19886

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_FAILEDTRANSMISSIONS_CLASSIFICATION = 19887

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_FAILEDTRANSMISSIONS_DIAGNOSTICSLEVEL = 19888

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_FAILEDTRANSMISSIONS_TIMEFIRSTCHANGE = 19889

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_ENCRYPTIONERRORS = 19890

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_ENCRYPTIONERRORS_ACTIVE = 19891

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_ENCRYPTIONERRORS_CLASSIFICATION = 19892

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_ENCRYPTIONERRORS_DIAGNOSTICSLEVEL = 19893

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_COUNTERS_ENCRYPTIONERRORS_TIMEFIRSTCHANGE = 19894

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_CONFIGUREDDATASETWRITERS = 19895

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_CONFIGUREDDATASETWRITERS_DIAGNOSTICSLEVEL = 19896

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_OPERATIONALDATASETWRITERS = 19897

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_OPERATIONALDATASETWRITERS_DIAGNOSTICSLEVEL = 19898

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_SECURITYTOKENID = 19899

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_SECURITYTOKENID_DIAGNOSTICSLEVEL = 19900

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_TIMETONEXTTOKENID = 19901

const UA_NS0ID_PUBSUBDIAGNOSTICSWRITERGROUPTYPE_LIVEVALUES_TIMETONEXTTOKENID_DIAGNOSTICSLEVEL = 19902

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE = 19903

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_DIAGNOSTICSLEVEL = 19904

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALINFORMATION = 19905

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALINFORMATION_ACTIVE = 19906

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALINFORMATION_CLASSIFICATION = 19907

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19908

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 19909

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALERROR = 19910

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALERROR_ACTIVE = 19911

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALERROR_CLASSIFICATION = 19912

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 19913

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_TOTALERROR_TIMEFIRSTCHANGE = 19914

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_RESET = 19915

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_SUBERROR = 19916

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS = 19917

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEERROR = 19918

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEERROR_ACTIVE = 19919

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 19920

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19921

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19922

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 19923

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19924

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19925

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19926

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19927

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 19928

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19929

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19930

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19931

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19932

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 19933

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19934

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 19935

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 19936

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 19937

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT = 19938

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 19939

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 19940

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 19941

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 19942

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 19943

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 19944

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 19945

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 19946

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 19947

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_LIVEVALUES = 19948

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDNETWORKMESSAGES = 19949

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDNETWORKMESSAGES_ACTIVE = 19950

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDNETWORKMESSAGES_CLASSIFICATION = 19951

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDNETWORKMESSAGES_DIAGNOSTICSLEVEL = 19952

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDNETWORKMESSAGES_TIMEFIRSTCHANGE = 19953

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES = 19954

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_ACTIVE = 19955

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_CLASSIFICATION = 19956

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_DIAGNOSTICSLEVEL = 19957

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_TIMEFIRSTCHANGE = 19958

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_DECRYPTIONERRORS = 19959

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_DECRYPTIONERRORS_ACTIVE = 19960

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_DECRYPTIONERRORS_CLASSIFICATION = 19961

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_DECRYPTIONERRORS_DIAGNOSTICSLEVEL = 19962

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_COUNTERS_DECRYPTIONERRORS_TIMEFIRSTCHANGE = 19963

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_LIVEVALUES_CONFIGUREDDATASETREADERS = 19964

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_LIVEVALUES_CONFIGUREDDATASETREADERS_DIAGNOSTICSLEVEL = 19965

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_LIVEVALUES_OPERATIONALDATASETREADERS = 19966

const UA_NS0ID_PUBSUBDIAGNOSTICSREADERGROUPTYPE_LIVEVALUES_OPERATIONALDATASETREADERS_DIAGNOSTICSLEVEL = 19967

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE = 19968

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_DIAGNOSTICSLEVEL = 19969

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALINFORMATION = 19970

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALINFORMATION_ACTIVE = 19971

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALINFORMATION_CLASSIFICATION = 19972

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 19973

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 19974

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALERROR = 19975

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALERROR_ACTIVE = 19976

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALERROR_CLASSIFICATION = 19977

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 19978

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_TOTALERROR_TIMEFIRSTCHANGE = 19979

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_RESET = 19980

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_SUBERROR = 19981

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS = 19982

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEERROR = 19983

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEERROR_ACTIVE = 19984

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 19985

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 19986

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 19987

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 19988

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 19989

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 19990

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 19991

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 19992

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 19993

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 19994

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 19995

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 19996

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 19997

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 19998

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 19999

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 20000

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 20001

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 20002

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEPAUSEDBYPARENT = 20003

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 20004

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 20005

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 20006

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 20007

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 20008

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 20009

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 20010

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 20011

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 20012

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES = 20013

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_FAILEDDATASETMESSAGES = 20014

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 20015

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 20016

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 20017

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 20018

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_MESSAGESEQUENCENUMBER = 20019

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 20020

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_STATUSCODE = 20021

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 20022

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_MAJORVERSION = 20023

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 20024

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_MINORVERSION = 20025

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETWRITERTYPE_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 20026

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE = 20027

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_DIAGNOSTICSLEVEL = 20028

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALINFORMATION = 20029

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALINFORMATION_ACTIVE = 20030

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALINFORMATION_CLASSIFICATION = 20031

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALINFORMATION_DIAGNOSTICSLEVEL = 20032

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALINFORMATION_TIMEFIRSTCHANGE = 20033

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALERROR = 20034

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALERROR_ACTIVE = 20035

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALERROR_CLASSIFICATION = 20036

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALERROR_DIAGNOSTICSLEVEL = 20037

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_TOTALERROR_TIMEFIRSTCHANGE = 20038

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_RESET = 20039

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_SUBERROR = 20040

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS = 20041

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEERROR = 20042

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEERROR_ACTIVE = 20043

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEERROR_CLASSIFICATION = 20044

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 20045

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 20046

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD = 20047

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 20048

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 20049

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 20050

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 20051

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYPARENT = 20052

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 20053

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 20054

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 20055

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 20056

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALFROMERROR = 20057

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 20058

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 20059

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 20060

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 20061

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEPAUSEDBYPARENT = 20062

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 20063

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 20064

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 20065

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 20066

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEDISABLEDBYMETHOD = 20067

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 20068

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 20069

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 20070

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 20071

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES = 20072

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_FAILEDDATASETMESSAGES = 20073

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_FAILEDDATASETMESSAGES_ACTIVE = 20074

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_FAILEDDATASETMESSAGES_CLASSIFICATION = 20075

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_FAILEDDATASETMESSAGES_DIAGNOSTICSLEVEL = 20076

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_FAILEDDATASETMESSAGES_TIMEFIRSTCHANGE = 20077

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_DECRYPTIONERRORS = 20078

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_DECRYPTIONERRORS_ACTIVE = 20079

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_DECRYPTIONERRORS_CLASSIFICATION = 20080

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_DECRYPTIONERRORS_DIAGNOSTICSLEVEL = 20081

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_COUNTERS_DECRYPTIONERRORS_TIMEFIRSTCHANGE = 20082

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_MESSAGESEQUENCENUMBER = 20083

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_MESSAGESEQUENCENUMBER_DIAGNOSTICSLEVEL = 20084

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_STATUSCODE = 20085

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_STATUSCODE_DIAGNOSTICSLEVEL = 20086

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_MAJORVERSION = 20087

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_MAJORVERSION_DIAGNOSTICSLEVEL = 20088

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_MINORVERSION = 20089

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_MINORVERSION_DIAGNOSTICSLEVEL = 20090

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_SECURITYTOKENID = 20091

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_SECURITYTOKENID_DIAGNOSTICSLEVEL = 20092

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_TIMETONEXTTOKENID = 20093

const UA_NS0ID_PUBSUBDIAGNOSTICSDATASETREADERTYPE_LIVEVALUES_TIMETONEXTTOKENID_DIAGNOSTICSLEVEL = 20094

const UA_NS0ID_DATASETORDERINGTYPE = 20408

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID = 20409

const UA_NS0ID_VERSIONTIME = 20998

const UA_NS0ID_SESSIONLESSINVOKERESPONSETYPE = 20999

const UA_NS0ID_SESSIONLESSINVOKERESPONSETYPE_ENCODING_DEFAULTXML = 21000

const UA_NS0ID_SESSIONLESSINVOKERESPONSETYPE_ENCODING_DEFAULTBINARY = 21001

const UA_NS0ID_OPCUA_BINARYSCHEMA_FIELDTARGETDATATYPE = 21002

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_SECURITYTOKENID_DIAGNOSTICSLEVEL = 21003

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID = 21004

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_DIAGNOSTICS_LIVEVALUES_TIMETONEXTTOKENID_DIAGNOSTICSLEVEL = 21005

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_SUBSCRIBEDDATASET = 21006

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_CREATETARGETVARIABLES = 21009

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_CREATETARGETVARIABLES_INPUTARGUMENTS = 21010

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_CREATETARGETVARIABLES_OUTPUTARGUMENTS = 21011

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_CREATEDATASETMIRROR = 21012

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_CREATEDATASETMIRROR_INPUTARGUMENTS = 21013

const UA_NS0ID_READERGROUPTYPE_DATASETREADERNAME_PLACEHOLDER_CREATEDATASETMIRROR_OUTPUTARGUMENTS = 21014

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS = 21015

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_DIAGNOSTICSLEVEL = 21016

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION = 21017

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_ACTIVE = 21018

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_CLASSIFICATION = 21019

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_DIAGNOSTICSLEVEL = 21020

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALINFORMATION_TIMEFIRSTCHANGE = 21021

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALERROR = 21022

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALERROR_ACTIVE = 21023

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALERROR_CLASSIFICATION = 21024

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALERROR_DIAGNOSTICSLEVEL = 21025

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_TOTALERROR_TIMEFIRSTCHANGE = 21026

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_RESET = 21027

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_SUBERROR = 21028

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS = 21029

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR = 21030

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_ACTIVE = 21031

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_CLASSIFICATION = 21032

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_DIAGNOSTICSLEVEL = 21033

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEERROR_TIMEFIRSTCHANGE = 21034

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD = 21035

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_ACTIVE = 21036

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_CLASSIFICATION = 21037

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_DIAGNOSTICSLEVEL = 21038

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYMETHOD_TIMEFIRSTCHANGE = 21039

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT = 21040

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_ACTIVE = 21041

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_CLASSIFICATION = 21042

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_DIAGNOSTICSLEVEL = 21043

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALBYPARENT_TIMEFIRSTCHANGE = 21044

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR = 21045

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_ACTIVE = 21046

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_CLASSIFICATION = 21047

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_DIAGNOSTICSLEVEL = 21048

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEOPERATIONALFROMERROR_TIMEFIRSTCHANGE = 21049

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT = 21050

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_ACTIVE = 21051

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_CLASSIFICATION = 21052

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_DIAGNOSTICSLEVEL = 21053

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEPAUSEDBYPARENT_TIMEFIRSTCHANGE = 21054

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD = 21055

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_ACTIVE = 21056

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_CLASSIFICATION = 21057

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_DIAGNOSTICSLEVEL = 21058

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_STATEDISABLEDBYMETHOD_TIMEFIRSTCHANGE = 21059

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_LIVEVALUES = 21060

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES = 21061

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_ACTIVE = 21062

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_CLASSIFICATION = 21063

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_DIAGNOSTICSLEVEL = 21064

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDNETWORKMESSAGES_TIMEFIRSTCHANGE = 21065

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES = 21066

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_ACTIVE = 21067

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_CLASSIFICATION = 21068

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_DIAGNOSTICSLEVEL = 21069

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_RECEIVEDINVALIDNETWORKMESSAGES_TIMEFIRSTCHANGE = 21070

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS = 21071

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_ACTIVE = 21072

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_CLASSIFICATION = 21073

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_DIAGNOSTICSLEVEL = 21074

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_COUNTERS_DECRYPTIONERRORS_TIMEFIRSTCHANGE = 21075

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS = 21076

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_CONFIGUREDDATASETREADERS_DIAGNOSTICSLEVEL = 21077

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS = 21078

const UA_NS0ID_READERGROUPTYPE_DIAGNOSTICS_LIVEVALUES_OPERATIONALDATASETREADERS_DIAGNOSTICSLEVEL = 21079

const UA_NS0ID_READERGROUPTYPE_TRANSPORTSETTINGS = 21080

const UA_NS0ID_READERGROUPTYPE_MESSAGESETTINGS = 21081

const UA_NS0ID_READERGROUPTYPE_ADDDATASETREADER = 21082

const UA_NS0ID_READERGROUPTYPE_ADDDATASETREADER_INPUTARGUMENTS = 21083

const UA_NS0ID_READERGROUPTYPE_ADDDATASETREADER_OUTPUTARGUMENTS = 21084

const UA_NS0ID_READERGROUPTYPE_REMOVEDATASETREADER = 21085

const UA_NS0ID_READERGROUPTYPE_REMOVEDATASETREADER_INPUTARGUMENTS = 21086

const UA_NS0ID_PUBSUBGROUPTYPEADDREADERMETHODTYPE = 21087

const UA_NS0ID_PUBSUBGROUPTYPEADDREADERMETHODTYPE_INPUTARGUMENTS = 21088

const UA_NS0ID_PUBSUBGROUPTYPEADDREADERMETHODTYPE_OUTPUTARGUMENTS = 21089

const UA_NS0ID_READERGROUPTRANSPORTTYPE = 21090

const UA_NS0ID_READERGROUPMESSAGETYPE = 21091

const UA_NS0ID_DATASETWRITERTYPE_DATASETWRITERID = 21092

const UA_NS0ID_DATASETWRITERTYPE_DATASETFIELDCONTENTMASK = 21093

const UA_NS0ID_DATASETWRITERTYPE_KEYFRAMECOUNT = 21094

const UA_NS0ID_DATASETWRITERTYPE_MESSAGESETTINGS = 21095

const UA_NS0ID_DATASETWRITERMESSAGETYPE = 21096

const UA_NS0ID_DATASETREADERTYPE_PUBLISHERID = 21097

const UA_NS0ID_DATASETREADERTYPE_WRITERGROUPID = 21098

const UA_NS0ID_DATASETREADERTYPE_DATASETWRITERID = 21099

const UA_NS0ID_DATASETREADERTYPE_DATASETMETADATA = 21100

const UA_NS0ID_DATASETREADERTYPE_DATASETFIELDCONTENTMASK = 21101

const UA_NS0ID_DATASETREADERTYPE_MESSAGERECEIVETIMEOUT = 21102

const UA_NS0ID_DATASETREADERTYPE_MESSAGESETTINGS = 21103

const UA_NS0ID_DATASETREADERMESSAGETYPE = 21104

const UA_NS0ID_UADPWRITERGROUPMESSAGETYPE = 21105

const UA_NS0ID_UADPWRITERGROUPMESSAGETYPE_GROUPVERSION = 21106

const UA_NS0ID_UADPWRITERGROUPMESSAGETYPE_DATASETORDERING = 21107

const UA_NS0ID_UADPWRITERGROUPMESSAGETYPE_NETWORKMESSAGECONTENTMASK = 21108

const UA_NS0ID_UADPWRITERGROUPMESSAGETYPE_SAMPLINGOFFSET = 21109

const UA_NS0ID_UADPWRITERGROUPMESSAGETYPE_PUBLISHINGOFFSET = 21110

const UA_NS0ID_UADPDATASETWRITERMESSAGETYPE = 21111

const UA_NS0ID_UADPDATASETWRITERMESSAGETYPE_DATASETMESSAGECONTENTMASK = 21112

const UA_NS0ID_UADPDATASETWRITERMESSAGETYPE_CONFIGUREDSIZE = 21113

const UA_NS0ID_UADPDATASETWRITERMESSAGETYPE_NETWORKMESSAGENUMBER = 21114

const UA_NS0ID_UADPDATASETWRITERMESSAGETYPE_DATASETOFFSET = 21115

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE = 21116

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_GROUPVERSION = 21117

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_NETWORKMESSAGENUMBER = 21119

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_DATASETCLASSID = 21120

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_NETWORKMESSAGECONTENTMASK = 21121

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_DATASETMESSAGECONTENTMASK = 21122

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_PUBLISHINGINTERVAL = 21123

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_PROCESSINGOFFSET = 21124

const UA_NS0ID_UADPDATASETREADERMESSAGETYPE_RECEIVEOFFSET = 21125

const UA_NS0ID_JSONWRITERGROUPMESSAGETYPE = 21126

const UA_NS0ID_JSONWRITERGROUPMESSAGETYPE_NETWORKMESSAGECONTENTMASK = 21127

const UA_NS0ID_JSONDATASETWRITERMESSAGETYPE = 21128

const UA_NS0ID_JSONDATASETWRITERMESSAGETYPE_DATASETMESSAGECONTENTMASK = 21129

const UA_NS0ID_JSONDATASETREADERMESSAGETYPE = 21130

const UA_NS0ID_JSONDATASETREADERMESSAGETYPE_NETWORKMESSAGECONTENTMASK = 21131

const UA_NS0ID_JSONDATASETREADERMESSAGETYPE_DATASETMESSAGECONTENTMASK = 21132

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTTYPE = 21133

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTTYPE_MESSAGEREPEATCOUNT = 21134

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTTYPE_MESSAGEREPEATDELAY = 21135

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTTYPE = 21136

const UA_NS0ID_BROKERWRITERGROUPTRANSPORTTYPE_QUEUENAME = 21137

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE = 21138

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE_QUEUENAME = 21139

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE_METADATAQUEUENAME = 21140

const UA_NS0ID_BROKERDATASETWRITERTRANSPORTTYPE_METADATAUPDATETIME = 21141

const UA_NS0ID_BROKERDATASETREADERTRANSPORTTYPE = 21142

const UA_NS0ID_BROKERDATASETREADERTRANSPORTTYPE_QUEUENAME = 21143

const UA_NS0ID_BROKERDATASETREADERTRANSPORTTYPE_METADATAQUEUENAME = 21144

const UA_NS0ID_NETWORKADDRESSTYPE = 21145

const UA_NS0ID_NETWORKADDRESSTYPE_NETWORKINTERFACE = 21146

const UA_NS0ID_NETWORKADDRESSURLTYPE = 21147

const UA_NS0ID_NETWORKADDRESSURLTYPE_NETWORKINTERFACE = 21148

const UA_NS0ID_NETWORKADDRESSURLTYPE_URL = 21149

const UA_NS0ID_WRITERGROUPDATATYPE_ENCODING_DEFAULTBINARY = 21150

const UA_NS0ID_NETWORKADDRESSDATATYPE_ENCODING_DEFAULTBINARY = 21151

const UA_NS0ID_NETWORKADDRESSURLDATATYPE_ENCODING_DEFAULTBINARY = 21152

const UA_NS0ID_READERGROUPDATATYPE_ENCODING_DEFAULTBINARY = 21153

const UA_NS0ID_PUBSUBCONFIGURATIONDATATYPE_ENCODING_DEFAULTBINARY = 21154

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTBINARY = 21155

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPDATATYPE = 21156

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPDATATYPE_DATATYPEVERSION = 21157

const UA_NS0ID_OPCUA_BINARYSCHEMA_WRITERGROUPDATATYPE_DICTIONARYFRAGMENT = 21158

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKADDRESSDATATYPE = 21159

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKADDRESSDATATYPE_DATATYPEVERSION = 21160

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKADDRESSDATATYPE_DICTIONARYFRAGMENT = 21161

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKADDRESSURLDATATYPE = 21162

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKADDRESSURLDATATYPE_DATATYPEVERSION = 21163

const UA_NS0ID_OPCUA_BINARYSCHEMA_NETWORKADDRESSURLDATATYPE_DICTIONARYFRAGMENT = 21164

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPDATATYPE = 21165

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPDATATYPE_DATATYPEVERSION = 21166

const UA_NS0ID_OPCUA_BINARYSCHEMA_READERGROUPDATATYPE_DICTIONARYFRAGMENT = 21167

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBCONFIGURATIONDATATYPE = 21168

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBCONFIGURATIONDATATYPE_DATATYPEVERSION = 21169

const UA_NS0ID_OPCUA_BINARYSCHEMA_PUBSUBCONFIGURATIONDATATYPE_DICTIONARYFRAGMENT = 21170

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATAGRAMWRITERGROUPTRANSPORTDATATYPE = 21171

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 21172

const UA_NS0ID_OPCUA_BINARYSCHEMA_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 21173

const UA_NS0ID_WRITERGROUPDATATYPE_ENCODING_DEFAULTXML = 21174

const UA_NS0ID_NETWORKADDRESSDATATYPE_ENCODING_DEFAULTXML = 21175

const UA_NS0ID_NETWORKADDRESSURLDATATYPE_ENCODING_DEFAULTXML = 21176

const UA_NS0ID_READERGROUPDATATYPE_ENCODING_DEFAULTXML = 21177

const UA_NS0ID_PUBSUBCONFIGURATIONDATATYPE_ENCODING_DEFAULTXML = 21178

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTXML = 21179

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPDATATYPE = 21180

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPDATATYPE_DATATYPEVERSION = 21181

const UA_NS0ID_OPCUA_XMLSCHEMA_WRITERGROUPDATATYPE_DICTIONARYFRAGMENT = 21182

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKADDRESSDATATYPE = 21183

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKADDRESSDATATYPE_DATATYPEVERSION = 21184

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKADDRESSDATATYPE_DICTIONARYFRAGMENT = 21185

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKADDRESSURLDATATYPE = 21186

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKADDRESSURLDATATYPE_DATATYPEVERSION = 21187

const UA_NS0ID_OPCUA_XMLSCHEMA_NETWORKADDRESSURLDATATYPE_DICTIONARYFRAGMENT = 21188

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPDATATYPE = 21189

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPDATATYPE_DATATYPEVERSION = 21190

const UA_NS0ID_OPCUA_XMLSCHEMA_READERGROUPDATATYPE_DICTIONARYFRAGMENT = 21191

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBCONFIGURATIONDATATYPE = 21192

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBCONFIGURATIONDATATYPE_DATATYPEVERSION = 21193

const UA_NS0ID_OPCUA_XMLSCHEMA_PUBSUBCONFIGURATIONDATATYPE_DICTIONARYFRAGMENT = 21194

const UA_NS0ID_OPCUA_XMLSCHEMA_DATAGRAMWRITERGROUPTRANSPORTDATATYPE = 21195

const UA_NS0ID_OPCUA_XMLSCHEMA_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_DATATYPEVERSION = 21196

const UA_NS0ID_OPCUA_XMLSCHEMA_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_DICTIONARYFRAGMENT = 21197

const UA_NS0ID_WRITERGROUPDATATYPE_ENCODING_DEFAULTJSON = 21198

const UA_NS0ID_NETWORKADDRESSDATATYPE_ENCODING_DEFAULTJSON = 21199

const UA_NS0ID_NETWORKADDRESSURLDATATYPE_ENCODING_DEFAULTJSON = 21200

const UA_NS0ID_READERGROUPDATATYPE_ENCODING_DEFAULTJSON = 21201

const UA_NS0ID_PUBSUBCONFIGURATIONDATATYPE_ENCODING_DEFAULTJSON = 21202

const UA_NS0ID_DATAGRAMWRITERGROUPTRANSPORTDATATYPE_ENCODING_DEFAULTJSON = 21203

const UA_ACCESSLEVELMASK_READ = Cuint(0x01) << Cuint(0)

const UA_ACCESSLEVELMASK_WRITE = Cuint(0x01) << Cuint(1)

const UA_ACCESSLEVELMASK_HISTORYREAD = Cuint(0x01) << Cuint(2)

const UA_ACCESSLEVELMASK_HISTORYWRITE = Cuint(0x01) << Cuint(3)

const UA_ACCESSLEVELMASK_SEMANTICCHANGE = Cuint(0x01) << Cuint(4)

const UA_ACCESSLEVELMASK_STATUSWRITE = Cuint(0x01) << Cuint(5)

const UA_ACCESSLEVELMASK_TIMESTAMPWRITE = Cuint(0x01) << Cuint(6)

const UA_WRITEMASK_ACCESSLEVEL = Cuint(0x01) << Cuint(0)

const UA_WRITEMASK_ARRRAYDIMENSIONS = Cuint(0x01) << Cuint(1)

const UA_WRITEMASK_BROWSENAME = Cuint(0x01) << Cuint(2)

const UA_WRITEMASK_CONTAINSNOLOOPS = Cuint(0x01) << Cuint(3)

const UA_WRITEMASK_DATATYPE = Cuint(0x01) << Cuint(4)

const UA_WRITEMASK_DESCRIPTION = Cuint(0x01) << Cuint(5)

const UA_WRITEMASK_DISPLAYNAME = Cuint(0x01) << Cuint(6)

const UA_WRITEMASK_EVENTNOTIFIER = Cuint(0x01) << Cuint(7)

const UA_WRITEMASK_EXECUTABLE = Cuint(0x01) << Cuint(8)

const UA_WRITEMASK_HISTORIZING = Cuint(0x01) << Cuint(9)

const UA_WRITEMASK_INVERSENAME = Cuint(0x01) << Cuint(10)

const UA_WRITEMASK_ISABSTRACT = Cuint(0x01) << Cuint(11)

const UA_WRITEMASK_MINIMUMSAMPLINGINTERVAL = Cuint(0x01) << Cuint(12)

const UA_WRITEMASK_NODECLASS = Cuint(0x01) << Cuint(13)

const UA_WRITEMASK_NODEID = Cuint(0x01) << Cuint(14)

const UA_WRITEMASK_SYMMETRIC = Cuint(0x01) << Cuint(15)

const UA_WRITEMASK_USERACCESSLEVEL = Cuint(0x01) << Cuint(16)

const UA_WRITEMASK_USEREXECUTABLE = Cuint(0x01) << Cuint(17)

const UA_WRITEMASK_USERWRITEMASK = Cuint(0x01) << Cuint(18)

const UA_WRITEMASK_VALUERANK = Cuint(0x01) << Cuint(19)

const UA_WRITEMASK_WRITEMASK = Cuint(0x01) << Cuint(20)

const UA_WRITEMASK_VALUEFORVARIABLETYPE = Cuint(0x01) << Cuint(21)

const UA_VALUERANK_SCALAR_OR_ONE_DIMENSION = -3

const UA_VALUERANK_ANY = -2

const UA_VALUERANK_SCALAR = -1

const UA_VALUERANK_ONE_OR_MORE_DIMENSIONS = 0

const UA_VALUERANK_ONE_DIMENSION = 1

const UA_VALUERANK_TWO_DIMENSIONS = 2

const UA_VALUERANK_THREE_DIMENSIONS = 3

const UA_BUILTIN_TYPES_COUNT = Cuint(25)

const UA_SBYTE_MIN = -128

const UA_SBYTE_MAX = 127

const UA_BYTE_MIN = 0

const UA_BYTE_MAX = 255

const UA_INT16_MIN = -32768

const UA_INT16_MAX = 32767

const UA_UINT16_MIN = 0

const UA_UINT16_MAX = 65535

const UA_INT32_MIN = -2147483648

const UA_INT32_MAX = 2147483647

const UA_UINT32_MIN = 0

const UA_UINT32_MAX = 4294967295

const UA_DATETIME_USEC = Clonglong(10)

const UA_DATETIME_MSEC = UA_DATETIME_USEC * Clonglong(1000)

const UA_DATETIME_SEC = UA_DATETIME_MSEC * Clonglong(1000)

const UA_DATETIME_UNIX_EPOCH = Clonglong(11644473600) * UA_DATETIME_SEC

# Skipping MacroDefinition: UA_EMPTY_ARRAY_SENTINEL ( ( void * ) 0x01 )

const UA_DATATYPEKINDS = 31

const UA_TYPES_COUNT = 190

const UA_TYPES_BOOLEAN = 0

const UA_TYPES_SBYTE = 1

const UA_TYPES_BYTE = 2

const UA_TYPES_INT16 = 3

const UA_TYPES_UINT16 = 4

const UA_TYPES_INT32 = 5

const UA_TYPES_UINT32 = 6

const UA_TYPES_INT64 = 7

const UA_TYPES_UINT64 = 8

const UA_TYPES_FLOAT = 9

const UA_TYPES_DOUBLE = 10

const UA_TYPES_STRING = 11

const UA_TYPES_DATETIME = 12

const UA_TYPES_GUID = 13

const UA_TYPES_BYTESTRING = 14

const UA_TYPES_XMLELEMENT = 15

const UA_TYPES_NODEID = 16

const UA_TYPES_EXPANDEDNODEID = 17

const UA_TYPES_STATUSCODE = 18

const UA_TYPES_QUALIFIEDNAME = 19

const UA_TYPES_LOCALIZEDTEXT = 20

const UA_TYPES_EXTENSIONOBJECT = 21

const UA_TYPES_DATAVALUE = 22

const UA_TYPES_VARIANT = 23

const UA_TYPES_DIAGNOSTICINFO = 24

const UA_TYPES_VIEWATTRIBUTES = 25

const UA_TYPES_XVTYPE = 26

const UA_TYPES_ELEMENTOPERAND = 27

const UA_TYPES_VARIABLEATTRIBUTES = 28

const UA_TYPES_ENUMVALUETYPE = 29

const UA_TYPES_EVENTFIELDLIST = 30

const UA_TYPES_MONITOREDITEMCREATERESULT = 31

const UA_TYPES_EUINFORMATION = 32

const UA_TYPES_SERVERDIAGNOSTICSSUMMARYDATATYPE = 33

const UA_TYPES_CONTENTFILTERELEMENTRESULT = 34

const UA_TYPES_LITERALOPERAND = 35

const UA_TYPES_MESSAGESECURITYMODE = 36

const UA_TYPES_UTCTIME = 37

const UA_TYPES_USERIDENTITYTOKEN = 38

const UA_TYPES_X509IDENTITYTOKEN = 39

const UA_TYPES_MONITOREDITEMNOTIFICATION = 40

const UA_TYPES_STRUCTURETYPE = 41

const UA_TYPES_RESPONSEHEADER = 42

const UA_TYPES_SIGNATUREDATA = 43

const UA_TYPES_MODIFYSUBSCRIPTIONRESPONSE = 44

const UA_TYPES_NODEATTRIBUTES = 45

const UA_TYPES_ACTIVATESESSIONRESPONSE = 46

const UA_TYPES_ENUMFIELD = 47

const UA_TYPES_VARIABLETYPEATTRIBUTES = 48

const UA_TYPES_CALLMETHODRESULT = 49

const UA_TYPES_MONITORINGMODE = 50

const UA_TYPES_SETMONITORINGMODERESPONSE = 51

const UA_TYPES_BROWSERESULTMASK = 52

const UA_TYPES_REQUESTHEADER = 53

const UA_TYPES_MONITOREDITEMMODIFYRESULT = 54

const UA_TYPES_CLOSESECURECHANNELREQUEST = 55

const UA_TYPES_NOTIFICATIONMESSAGE = 56

const UA_TYPES_CREATESUBSCRIPTIONRESPONSE = 57

const UA_TYPES_ENUMDEFINITION = 58

const UA_TYPES_AXISSCALEENUMERATION = 59

const UA_TYPES_BROWSEDIRECTION = 60

const UA_TYPES_CALLMETHODREQUEST = 61

const UA_TYPES_READRESPONSE = 62

const UA_TYPES_TIMESTAMPSTORETURN = 63

const UA_TYPES_NODECLASS = 64

const UA_TYPES_OBJECTTYPEATTRIBUTES = 65

const UA_TYPES_SECURITYTOKENREQUESTTYPE = 66

const UA_TYPES_CLOSESESSIONRESPONSE = 67

const UA_TYPES_SETPUBLISHINGMODEREQUEST = 68

const UA_TYPES_ISSUEDIDENTITYTOKEN = 69

const UA_TYPES_DELETEMONITOREDITEMSRESPONSE = 70

const UA_TYPES_APPLICATIONTYPE = 71

const UA_TYPES_BROWSENEXTREQUEST = 72

const UA_TYPES_MODIFYSUBSCRIPTIONREQUEST = 73

const UA_TYPES_BROWSEDESCRIPTION = 74

const UA_TYPES_SIGNEDSOFTWARECERTIFICATE = 75

const UA_TYPES_BROWSEPATHTARGET = 76

const UA_TYPES_WRITERESPONSE = 77

const UA_TYPES_ADDNODESRESULT = 78

const UA_TYPES_ADDREFERENCESITEM = 79

const UA_TYPES_DELETEREFERENCESRESPONSE = 80

const UA_TYPES_RELATIVEPATHELEMENT = 81

const UA_TYPES_SUBSCRIPTIONACKNOWLEDGEMENT = 82

const UA_TYPES_TRANSFERRESULT = 83

const UA_TYPES_CREATEMONITOREDITEMSRESPONSE = 84

const UA_TYPES_DELETEREFERENCESITEM = 85

const UA_TYPES_WRITEVALUE = 86

const UA_TYPES_DATATYPEATTRIBUTES = 87

const UA_TYPES_TRANSFERSUBSCRIPTIONSRESPONSE = 88

const UA_TYPES_ADDREFERENCESRESPONSE = 89

const UA_TYPES_DEADBANDTYPE = 90

const UA_TYPES_DATACHANGETRIGGER = 91

const UA_TYPES_BUILDINFO = 92

const UA_TYPES_FILTEROPERAND = 93

const UA_TYPES_MONITORINGPARAMETERS = 94

const UA_TYPES_DOUBLECOMPLEXNUMBERTYPE = 95

const UA_TYPES_DELETENODESITEM = 96

const UA_TYPES_READVALUEID = 97

const UA_TYPES_CALLREQUEST = 98

const UA_TYPES_RELATIVEPATH = 99

const UA_TYPES_DELETENODESREQUEST = 100

const UA_TYPES_MONITOREDITEMMODIFYREQUEST = 101

const UA_TYPES_USERTOKENTYPE = 102

const UA_TYPES_AGGREGATECONFIGURATION = 103

const UA_TYPES_LOCALEID = 104

const UA_TYPES_UNREGISTERNODESRESPONSE = 105

const UA_TYPES_CONTENTFILTERRESULT = 106

const UA_TYPES_USERTOKENPOLICY = 107

const UA_TYPES_DELETEMONITOREDITEMSREQUEST = 108

const UA_TYPES_SETMONITORINGMODEREQUEST = 109

const UA_TYPES_DURATION = 110

const UA_TYPES_REFERENCETYPEATTRIBUTES = 111

const UA_TYPES_GETENDPOINTSREQUEST = 112

const UA_TYPES_CLOSESECURECHANNELRESPONSE = 113

const UA_TYPES_VIEWDESCRIPTION = 114

const UA_TYPES_SETPUBLISHINGMODERESPONSE = 115

const UA_TYPES_STATUSCHANGENOTIFICATION = 116

const UA_TYPES_STRUCTUREFIELD = 117

const UA_TYPES_NODEATTRIBUTESMASK = 118

const UA_TYPES_EVENTFILTERRESULT = 119

const UA_TYPES_MONITOREDITEMCREATEREQUEST = 120

const UA_TYPES_COMPLEXNUMBERTYPE = 121

const UA_TYPES_RANGE = 122

const UA_TYPES_DATACHANGENOTIFICATION = 123

const UA_TYPES_ARGUMENT = 124

const UA_TYPES_TRANSFERSUBSCRIPTIONSREQUEST = 125

const UA_TYPES_CHANNELSECURITYTOKEN = 126

const UA_TYPES_SERVERSTATE = 127

const UA_TYPES_EVENTNOTIFICATIONLIST = 128

const UA_TYPES_ANONYMOUSIDENTITYTOKEN = 129

const UA_TYPES_FILTEROPERATOR = 130

const UA_TYPES_AGGREGATEFILTER = 131

const UA_TYPES_REPUBLISHRESPONSE = 132

const UA_TYPES_DELETESUBSCRIPTIONSRESPONSE = 133

const UA_TYPES_REGISTERNODESREQUEST = 134

const UA_TYPES_STRUCTUREDEFINITION = 135

const UA_TYPES_METHODATTRIBUTES = 136

const UA_TYPES_USERNAMEIDENTITYTOKEN = 137

const UA_TYPES_UNREGISTERNODESREQUEST = 138

const UA_TYPES_OPENSECURECHANNELRESPONSE = 139

const UA_TYPES_SETTRIGGERINGRESPONSE = 140

const UA_TYPES_SIMPLEATTRIBUTEOPERAND = 141

const UA_TYPES_REPUBLISHREQUEST = 142

const UA_TYPES_REGISTERNODESRESPONSE = 143

const UA_TYPES_MODIFYMONITOREDITEMSRESPONSE = 144

const UA_TYPES_DELETESUBSCRIPTIONSREQUEST = 145

const UA_TYPES_REDUNDANCYSUPPORT = 146

const UA_TYPES_BROWSEPATH = 147

const UA_TYPES_OBJECTATTRIBUTES = 148

const UA_TYPES_PUBLISHREQUEST = 149

const UA_TYPES_FINDSERVERSREQUEST = 150

const UA_TYPES_REFERENCEDESCRIPTION = 151

const UA_TYPES_CREATESUBSCRIPTIONREQUEST = 152

const UA_TYPES_CALLRESPONSE = 153

const UA_TYPES_DELETENODESRESPONSE = 154

const UA_TYPES_MODIFYMONITOREDITEMSREQUEST = 155

const UA_TYPES_SERVICEFAULT = 156

const UA_TYPES_PUBLISHRESPONSE = 157

const UA_TYPES_CREATEMONITOREDITEMSREQUEST = 158

const UA_TYPES_OPENSECURECHANNELREQUEST = 159

const UA_TYPES_CLOSESESSIONREQUEST = 160

const UA_TYPES_SETTRIGGERINGREQUEST = 161

const UA_TYPES_BROWSERESULT = 162

const UA_TYPES_ADDREFERENCESREQUEST = 163

const UA_TYPES_ADDNODESITEM = 164

const UA_TYPES_SERVERSTATUSDATATYPE = 165

const UA_TYPES_BROWSENEXTRESPONSE = 166

const UA_TYPES_AXISINFORMATION = 167

const UA_TYPES_APPLICATIONDESCRIPTION = 168

const UA_TYPES_READREQUEST = 169

const UA_TYPES_ACTIVATESESSIONREQUEST = 170

const UA_TYPES_BROWSEPATHRESULT = 171

const UA_TYPES_ADDNODESREQUEST = 172

const UA_TYPES_BROWSEREQUEST = 173

const UA_TYPES_WRITEREQUEST = 174

const UA_TYPES_ADDNODESRESPONSE = 175

const UA_TYPES_ATTRIBUTEOPERAND = 176

const UA_TYPES_DATACHANGEFILTER = 177

const UA_TYPES_ENDPOINTDESCRIPTION = 178

const UA_TYPES_DELETEREFERENCESREQUEST = 179

const UA_TYPES_TRANSLATEBROWSEPATHSTONODEIDSREQUEST = 180

const UA_TYPES_FINDSERVERSRESPONSE = 181

const UA_TYPES_CREATESESSIONREQUEST = 182

const UA_TYPES_CONTENTFILTERELEMENT = 183

const UA_TYPES_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE = 184

const UA_TYPES_BROWSERESPONSE = 185

const UA_TYPES_CREATESESSIONRESPONSE = 186

const UA_TYPES_CONTENTFILTER = 187

const UA_TYPES_GETENDPOINTSRESPONSE = 188

const UA_TYPES_EVENTFILTER = 189

const UA_PRINTF_GUID_FORMAT = "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x"

const UA_PRINTF_STRING_FORMAT = "\"%.*s\""

const UA_REFERENCETYPEINDEX_REFERENCES = 0

const UA_REFERENCETYPEINDEX_HASSUBTYPE = 1

const UA_REFERENCETYPEINDEX_AGGREGATES = 2

const UA_REFERENCETYPEINDEX_HIERARCHICALREFERENCES = 3

const UA_REFERENCETYPEINDEX_NONHIERARCHICALREFERENCES = 4

const UA_REFERENCETYPEINDEX_HASCHILD = 5

const UA_REFERENCETYPEINDEX_ORGANIZES = 6

const UA_REFERENCETYPEINDEX_HASEVENTSOURCE = 7

const UA_REFERENCETYPEINDEX_HASMODELLINGRULE = 8

const UA_REFERENCETYPEINDEX_HASENCODING = 9

const UA_REFERENCETYPEINDEX_HASDESCRIPTION = 10

const UA_REFERENCETYPEINDEX_HASTYPEDEFINITION = 11

const UA_REFERENCETYPEINDEX_GENERATESEVENT = 12

const UA_REFERENCETYPEINDEX_HASPROPERTY = 13

const UA_REFERENCETYPEINDEX_HASCOMPONENT = 14

const UA_REFERENCETYPEINDEX_HASNOTIFIER = 15

const UA_REFERENCETYPEINDEX_HASORDEREDCOMPONENT = 16

const UA_REFERENCETYPEINDEX_HASINTERFACE = 17

const UA_REFERENCETYPESET_MAX = 128

# Skipping MacroDefinition: UA_NODE_VARIABLEATTRIBUTES /* Constraints on possible values */ UA_NodeId dataType ; UA_Int32 valueRank ; size_t arrayDimensionsSize ; UA_UInt32 * arrayDimensions ; UA_ValueBackend valueBackend ; /* The current value */ UA_ValueSource valueSource ; union { struct { UA_DataValue value ; UA_ValueCallback callback ; } data ; UA_DataSource dataSource ; } value ;

include("generated_defs.jl")
include("types.jl")
include("server.jl")
include("client.jl")
include("init.jl")

# exports
const PREFIXES = ["UA_", "__UA_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
