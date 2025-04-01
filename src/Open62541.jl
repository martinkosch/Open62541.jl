module Open62541

using open62541_jll
export open62541_jll

using CEnum: CEnum, @cenum

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

@static if VERSION < v"1.7"
    getmethodindex(m::Base.MethodList, i::Integer) = m.ms[i]
else
    getmethodindex(m::Base.MethodList, i::Integer) = Base.getindex(m, i)
end

@static if VERSION < v"1.9"
    using Pkg
    pkgdir_old(m::Core.Module) = abspath(Base.pathof(Base.moduleroot(m)), "..", "..")
    function pkgproject_old(m::Core.Module)
        Pkg.Operations.read_project(Pkg.Types.projectfile_path(pkgdir_old(m)))
    end
    pkgversion_old(m::Core.Module) = pkgproject_old(m).version
    open62541_version = pkgversion_old(open62541_jll)
else
    open62541_version = pkgversion(open62541_jll)
end
__versionnumbertostring(vn::VersionNumber) = "$(vn.major).$(vn.minor).$(vn.patch)"
const UA_OPEN62541_VER_MAJOR = open62541_version.major
const UA_OPEN62541_VER_MINOR = open62541_version.minor
const UA_OPEN62541_VER_PATCH = open62541_version.patch
const UA_OPEN62541_VER_LABEL = ""
const UA_OPEN62541_VER_COMMIT = __versionnumbertostring(open62541_version)
const UA_OPEN62541_VERSION = __versionnumbertostring(open62541_version)

mutable struct UA_Client end

const UA_UInt64 = UInt64

function UA_Client_removeCallback(client, callbackId)
    @ccall libopen62541.UA_Client_removeCallback(
        client::Ptr{UA_Client}, callbackId::UA_UInt64)::Cvoid
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_Logger
    log::Ptr{Cvoid}
    context::Ptr{Cvoid}
    clear::Ptr{Cvoid}
end

const UA_UInt32 = UInt32

const UA_Byte = UInt8

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_String
    length::Csize_t
    data::Ptr{UA_Byte}
end
function Base.getproperty(x::Ptr{UA_String}, f::Symbol)
    f === :length && return Ptr{Csize_t}(x + 0)
    f === :data && return Ptr{Ptr{UA_Byte}}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_String}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_LocalizedText
    locale::UA_String
    text::UA_String
end
function Base.getproperty(x::Ptr{UA_LocalizedText}, f::Symbol)
    f === :locale && return Ptr{UA_String}(x + 0)
    f === :text && return Ptr{UA_String}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_LocalizedText}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_ApplicationType::UInt32 begin
    UA_APPLICATIONTYPE_SERVER = 0
    UA_APPLICATIONTYPE_CLIENT = 1
    UA_APPLICATIONTYPE_CLIENTANDSERVER = 2
    UA_APPLICATIONTYPE_DISCOVERYSERVER = 3
    __UA_APPLICATIONTYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_ApplicationDescription}, f::Symbol)
    f === :applicationUri && return Ptr{UA_String}(x + 0)
    f === :productUri && return Ptr{UA_String}(x + 16)
    f === :applicationName && return Ptr{UA_LocalizedText}(x + 32)
    f === :applicationType && return Ptr{UA_ApplicationType}(x + 64)
    f === :gatewayServerUri && return Ptr{UA_String}(x + 72)
    f === :discoveryProfileUri && return Ptr{UA_String}(x + 88)
    f === :discoveryUrlsSize && return Ptr{Csize_t}(x + 104)
    f === :discoveryUrls && return Ptr{Ptr{UA_String}}(x + 112)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ApplicationDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_ExtensionObjectEncoding::UInt32 begin
    UA_EXTENSIONOBJECT_ENCODED_NOBODY = 0
    UA_EXTENSIONOBJECT_ENCODED_BYTESTRING = 1
    UA_EXTENSIONOBJECT_ENCODED_XML = 2
    UA_EXTENSIONOBJECT_DECODED = 3
    UA_EXTENSIONOBJECT_DECODED_NODELETE = 4
end

struct __JL_Ctag_35
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_35}) = (:encoded, :decoded)
Base.fieldnames(::Type{Ptr{__JL_Ctag_35}}) = (:encoded, :decoded)

function Base.getproperty(x::Ptr{__JL_Ctag_35}, f::Symbol)
    f === :encoded && return Ptr{__JL_Ctag_36}(x + 0)
    f === :decoded && return Ptr{__JL_Ctag_37}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_35, f::Symbol)
    r = Ref{__JL_Ctag_35}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_35}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_35}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `encoding`

- `content`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_ExtensionObject
    data::NTuple{48, UInt8}
end

Base.fieldnames(::Type{UA_ExtensionObject}) = (:encoding, :content)
Base.fieldnames(::Type{Ptr{UA_ExtensionObject}}) = (:encoding, :content)

function Base.getproperty(x::Ptr{UA_ExtensionObject}, f::Symbol)
    f === :encoding && return Ptr{UA_ExtensionObjectEncoding}(x + 0)
    f === :content && return Ptr{__JL_Ctag_35}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ExtensionObject, f::Symbol)
    r = Ref{UA_ExtensionObject}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ExtensionObject}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ExtensionObject}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_MessageSecurityMode::UInt32 begin
    UA_MESSAGESECURITYMODE_INVALID = 0
    UA_MESSAGESECURITYMODE_NONE = 1
    UA_MESSAGESECURITYMODE_SIGN = 2
    UA_MESSAGESECURITYMODE_SIGNANDENCRYPT = 3
    __UA_MESSAGESECURITYMODE_FORCE32BIT = 2147483647
end

const UA_Boolean = Bool

const UA_ByteString = UA_String

@cenum UA_UserTokenType::UInt32 begin
    UA_USERTOKENTYPE_ANONYMOUS = 0
    UA_USERTOKENTYPE_USERNAME = 1
    UA_USERTOKENTYPE_CERTIFICATE = 2
    UA_USERTOKENTYPE_ISSUEDTOKEN = 3
    __UA_USERTOKENTYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UserTokenPolicy
    policyId::UA_String
    tokenType::UA_UserTokenType
    issuedTokenType::UA_String
    issuerEndpointUrl::UA_String
    securityPolicyUri::UA_String
end
function Base.getproperty(x::Ptr{UA_UserTokenPolicy}, f::Symbol)
    f === :policyId && return Ptr{UA_String}(x + 0)
    f === :tokenType && return Ptr{UA_UserTokenType}(x + 16)
    f === :issuedTokenType && return Ptr{UA_String}(x + 24)
    f === :issuerEndpointUrl && return Ptr{UA_String}(x + 40)
    f === :securityPolicyUri && return Ptr{UA_String}(x + 56)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_UserTokenPolicy}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_EndpointDescription}, f::Symbol)
    f === :endpointUrl && return Ptr{UA_String}(x + 0)
    f === :server && return Ptr{UA_ApplicationDescription}(x + 16)
    f === :serverCertificate && return Ptr{UA_ByteString}(x + 136)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 152)
    f === :securityPolicyUri && return Ptr{UA_String}(x + 160)
    f === :userIdentityTokensSize && return Ptr{Csize_t}(x + 176)
    f === :userIdentityTokens && return Ptr{Ptr{UA_UserTokenPolicy}}(x + 184)
    f === :transportProfileUri && return Ptr{UA_String}(x + 192)
    f === :securityLevel && return Ptr{UA_Byte}(x + 208)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EndpointDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_UInt16 = UInt16

@cenum UA_NodeIdType::UInt32 begin
    UA_NODEIDTYPE_NUMERIC = 0
    UA_NODEIDTYPE_STRING = 3
    UA_NODEIDTYPE_GUID = 4
    UA_NODEIDTYPE_BYTESTRING = 5
end

struct __JL_Ctag_43
    data::NTuple{16, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_43}) = (:numeric, :string, :guid, :byteString)
Base.fieldnames(::Type{Ptr{__JL_Ctag_43}}) = (:numeric, :string, :guid, :byteString)

function Base.getproperty(x::Ptr{__JL_Ctag_43}, f::Symbol)
    f === :numeric && return Ptr{UA_UInt32}(x + 0)
    f === :string && return Ptr{UA_String}(x + 0)
    f === :guid && return Ptr{UA_Guid}(x + 0)
    f === :byteString && return Ptr{UA_ByteString}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_43, f::Symbol)
    r = Ref{__JL_Ctag_43}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_43}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_43}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)

Fields:

- `nameSpaceIndex`

- `identifierType`

- `identifier`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_NodeId
    data::NTuple{24, UInt8}
end

Base.fieldnames(::Type{UA_NodeId}) = (:namespaceIndex, :identifierType, :identifier)
Base.fieldnames(::Type{Ptr{UA_NodeId}}) = (:namespaceIndex, :identifierType, :identifier)

function Base.getproperty(x::Ptr{UA_NodeId}, f::Symbol)
    f === :namespaceIndex && return Ptr{UA_UInt16}(x + 0)
    f === :identifierType && return Ptr{UA_NodeIdType}(x + 4)
    f === :identifier && return Ptr{__JL_Ctag_43}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_NodeId, f::Symbol)
    r = Ref{UA_NodeId}(x)
    ptr = Base.unsafe_convert(Ptr{UA_NodeId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_NodeId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `memberName`

- `memberType`
- `padding`
- `isArray`
- `isOptional`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_DataTypeMember
    data::NTuple{24, UInt8}
end

function Base.fieldnames(::Type{UA_DataTypeMember})
    (:memberName, :memberType, :padding, :isArray, :isOptional)
end
function Base.fieldnames(::Type{Ptr{UA_DataTypeMember}})
    (:memberName, :memberType, :padding, :isArray, :isOptional)
end

function Base.getproperty(x::Ptr{UA_DataTypeMember}, f::Symbol)
    f === :memberName && return Ptr{Cstring}(x + 0)
    f === :memberType && return Ptr{Ptr{UA_DataType}}(x + 8)
    f === :padding && return (Ptr{UA_Byte}(x + 16), 0, 6)
    f === :isArray && return (Ptr{UA_Byte}(x + 16), 6, 1)
    f === :isOptional && return (Ptr{UA_Byte}(x + 16), 7, 1)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataTypeMember, f::Symbol)
    r = Ref{UA_DataTypeMember}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataTypeMember}, r)
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

function Base.setproperty!(x::Ptr{UA_DataTypeMember}, f::Symbol, v)
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

"""

$(TYPEDEF)

Fields:

- `typeName`

- `typeId`

- `binaryEncodingId`

- `memSize`

- `typeKind`

- `pointerFree`

- `overlayable`

- `membersSize`

- `members`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_DataType
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_DataType})
    (:typeName, :typeId, :binaryEncodingId, :memSize, :typeKind,
        :pointerFree, :overlayable, :membersSize, :members)
end
function Base.fieldnames(::Type{Ptr{UA_DataType}})
    (:typeName, :typeId, :binaryEncodingId, :memSize, :typeKind,
        :pointerFree, :overlayable, :membersSize, :members)
end

function Base.getproperty(x::Ptr{UA_DataType}, f::Symbol)
    f === :typeName && return Ptr{Cstring}(x + 0)
    f === :typeId && return Ptr{UA_NodeId}(x + 8)
    f === :binaryEncodingId && return Ptr{UA_NodeId}(x + 32)
    f === :memSize && return (Ptr{UA_UInt32}(x + 56), 0, 16)
    f === :typeKind && return (Ptr{UA_UInt32}(x + 56), 16, 6)
    f === :pointerFree && return (Ptr{UA_UInt32}(x + 56), 22, 1)
    f === :overlayable && return (Ptr{UA_UInt32}(x + 56), 23, 1)
    f === :membersSize && return (Ptr{UA_UInt32}(x + 56), 24, 8)
    f === :members && return Ptr{Ptr{UA_DataTypeMember}}(x + 64)
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

struct UA_DataTypeArray
    next::Ptr{UA_DataTypeArray}
    typesSize::Csize_t
    types::Ptr{UA_DataType}
    cleanup::UA_Boolean
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QualifiedName
    namespaceIndex::UA_UInt16
    name::UA_String
end
function Base.getproperty(x::Ptr{UA_QualifiedName}, f::Symbol)
    f === :namespaceIndex && return Ptr{UA_UInt16}(x + 0)
    f === :name && return Ptr{UA_String}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_QualifiedName}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_VariantStorageType::UInt32 begin
    UA_VARIANT_DATA = 0
    UA_VARIANT_DATA_NODELETE = 1
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_Variant
    type::Ptr{UA_DataType}
    storageType::UA_VariantStorageType
    arrayLength::Csize_t
    data::Ptr{Cvoid}
    arrayDimensionsSize::Csize_t
    arrayDimensions::Ptr{UA_UInt32}
end
function Base.getproperty(x::Ptr{UA_Variant}, f::Symbol)
    f === :type && return Ptr{Ptr{UA_DataType}}(x + 0)
    f === :storageType && return Ptr{UA_VariantStorageType}(x + 8)
    f === :arrayLength && return Ptr{Csize_t}(x + 16)
    f === :data && return Ptr{Ptr{Cvoid}}(x + 24)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 32)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 40)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_Variant}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_KeyValuePair
    key::UA_QualifiedName
    value::UA_Variant
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_KeyValueMap
    mapSize::Csize_t
    map::Ptr{UA_KeyValuePair}
end

@cenum UA_EventLoopState::UInt32 begin
    UA_EVENTLOOPSTATE_FRESH = 0
    UA_EVENTLOOPSTATE_STOPPED = 1
    UA_EVENTLOOPSTATE_STARTED = 2
    UA_EVENTLOOPSTATE_STOPPING = 3
end

@cenum UA_EventSourceType::UInt32 begin
    UA_EVENTSOURCETYPE_CONNECTIONMANAGER = 0
    UA_EVENTSOURCETYPE_INTERRUPTMANAGER = 1
end

@cenum UA_EventSourceState::UInt32 begin
    UA_EVENTSOURCESTATE_FRESH = 0
    UA_EVENTSOURCESTATE_STOPPED = 1
    UA_EVENTSOURCESTATE_STARTING = 2
    UA_EVENTSOURCESTATE_STARTED = 3
    UA_EVENTSOURCESTATE_STOPPING = 4
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EventSource
    next::Ptr{UA_EventSource}
    eventSourceType::UA_EventSourceType
    name::UA_String
    eventLoop::Ptr{Cvoid} # eventLoop::Ptr{UA_EventLoop}
    params::UA_KeyValueMap
    state::UA_EventSourceState
    start::Ptr{Cvoid}
    stop::Ptr{Cvoid}
    free::Ptr{Cvoid}
end

function Base.getproperty(x::UA_EventSource, f::Symbol)
    f === :eventLoop && return Ptr{UA_EventLoop}(getfield(x, f))
    return getfield(x, f)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EventLoop
    logger::Ptr{UA_Logger}
    params::Ptr{UA_KeyValueMap}
    state::UA_EventLoopState
    start::Ptr{Cvoid}
    stop::Ptr{Cvoid}
    run::Ptr{Cvoid}
    free::Ptr{Cvoid}
    dateTime_now::Ptr{Cvoid}
    dateTime_nowMonotonic::Ptr{Cvoid}
    dateTime_localTimeUtcOffset::Ptr{Cvoid}
    nextCyclicTime::Ptr{Cvoid}
    addCyclicCallback::Ptr{Cvoid}
    modifyCyclicCallback::Ptr{Cvoid}
    removeCyclicCallback::Ptr{Cvoid}
    addTimedCallback::Ptr{Cvoid}
    addDelayedCallback::Ptr{Cvoid}
    removeDelayedCallback::Ptr{Cvoid}
    eventSources::Ptr{UA_EventSource}
    registerEventSource::Ptr{Cvoid}
    deregisterEventSource::Ptr{Cvoid}
    lock::Ptr{Cvoid}
    unlock::Ptr{Cvoid}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicySignatureAlgorithm
    data::NTuple{64, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicySignatureAlgorithm})
    (:uri, :verify, :sign, :getLocalSignatureSize,
        :getRemoteSignatureSize, :getLocalKeyLength, :getRemoteKeyLength)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicySignatureAlgorithm}})
    (:uri, :verify, :sign, :getLocalSignatureSize,
        :getRemoteSignatureSize, :getLocalKeyLength, :getRemoteKeyLength)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicySignatureAlgorithm}, f::Symbol)
    f === :uri && return Ptr{UA_String}(x + 0)
    f === :verify && return Ptr{Ptr{Cvoid}}(x + 16)
    f === :sign && return Ptr{Ptr{Cvoid}}(x + 24)
    f === :getLocalSignatureSize && return Ptr{Ptr{Cvoid}}(x + 32)
    f === :getRemoteSignatureSize && return Ptr{Ptr{Cvoid}}(x + 40)
    f === :getLocalKeyLength && return Ptr{Ptr{Cvoid}}(x + 48)
    f === :getRemoteKeyLength && return Ptr{Ptr{Cvoid}}(x + 56)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicySignatureAlgorithm, f::Symbol)
    r = Ref{UA_SecurityPolicySignatureAlgorithm}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicySignatureAlgorithm}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicySignatureAlgorithm}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicyEncryptionAlgorithm
    data::NTuple{64, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicyEncryptionAlgorithm})
    (:uri, :encrypt, :decrypt, :getLocalKeyLength, :getRemoteKeyLength,
        :getRemoteBlockSize, :getRemotePlainTextBlockSize)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicyEncryptionAlgorithm}})
    (:uri, :encrypt, :decrypt, :getLocalKeyLength, :getRemoteKeyLength,
        :getRemoteBlockSize, :getRemotePlainTextBlockSize)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicyEncryptionAlgorithm}, f::Symbol)
    f === :uri && return Ptr{UA_String}(x + 0)
    f === :encrypt && return Ptr{Ptr{Cvoid}}(x + 16)
    f === :decrypt && return Ptr{Ptr{Cvoid}}(x + 24)
    f === :getLocalKeyLength && return Ptr{Ptr{Cvoid}}(x + 32)
    f === :getRemoteKeyLength && return Ptr{Ptr{Cvoid}}(x + 40)
    f === :getRemoteBlockSize && return Ptr{Ptr{Cvoid}}(x + 48)
    f === :getRemotePlainTextBlockSize && return Ptr{Ptr{Cvoid}}(x + 56)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicyEncryptionAlgorithm, f::Symbol)
    r = Ref{UA_SecurityPolicyEncryptionAlgorithm}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicyEncryptionAlgorithm}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicyEncryptionAlgorithm}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicyCryptoModule
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicyCryptoModule})
    (:signatureAlgorithm, :encryptionAlgorithm)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicyCryptoModule}})
    (:signatureAlgorithm, :encryptionAlgorithm)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicyCryptoModule}, f::Symbol)
    f === :signatureAlgorithm && return Ptr{UA_SecurityPolicySignatureAlgorithm}(x + 0)
    f === :encryptionAlgorithm && return Ptr{UA_SecurityPolicyEncryptionAlgorithm}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicyCryptoModule, f::Symbol)
    r = Ref{UA_SecurityPolicyCryptoModule}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicyCryptoModule}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicyCryptoModule}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicyAsymmetricModule
    data::NTuple{144, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicyAsymmetricModule})
    (:makeCertificateThumbprint, :compareCertificateThumbprint, :cryptoModule)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicyAsymmetricModule}})
    (:makeCertificateThumbprint, :compareCertificateThumbprint, :cryptoModule)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicyAsymmetricModule}, f::Symbol)
    f === :makeCertificateThumbprint && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :compareCertificateThumbprint && return Ptr{Ptr{Cvoid}}(x + 8)
    f === :cryptoModule && return Ptr{UA_SecurityPolicyCryptoModule}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicyAsymmetricModule, f::Symbol)
    r = Ref{UA_SecurityPolicyAsymmetricModule}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicyAsymmetricModule}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicyAsymmetricModule}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicySymmetricModule
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicySymmetricModule})
    (:generateKey, :generateNonce, :secureChannelNonceLength, :cryptoModule)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicySymmetricModule}})
    (:generateKey, :generateNonce, :secureChannelNonceLength, :cryptoModule)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicySymmetricModule}, f::Symbol)
    f === :generateKey && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :generateNonce && return Ptr{Ptr{Cvoid}}(x + 8)
    f === :secureChannelNonceLength && return Ptr{Csize_t}(x + 16)
    f === :cryptoModule && return Ptr{UA_SecurityPolicyCryptoModule}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicySymmetricModule, f::Symbol)
    r = Ref{UA_SecurityPolicySymmetricModule}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicySymmetricModule}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicySymmetricModule}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicyChannelModule
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicyChannelModule})
    (:newContext, :deleteContext, :setLocalSymEncryptingKey,
        :setLocalSymSigningKey, :setLocalSymIv, :setRemoteSymEncryptingKey,
        :setRemoteSymSigningKey, :setRemoteSymIv, :compareCertificate)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicyChannelModule}})
    (:newContext, :deleteContext, :setLocalSymEncryptingKey,
        :setLocalSymSigningKey, :setLocalSymIv, :setRemoteSymEncryptingKey,
        :setRemoteSymSigningKey, :setRemoteSymIv, :compareCertificate)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicyChannelModule}, f::Symbol)
    f === :newContext && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :deleteContext && return Ptr{Ptr{Cvoid}}(x + 8)
    f === :setLocalSymEncryptingKey && return Ptr{Ptr{Cvoid}}(x + 16)
    f === :setLocalSymSigningKey && return Ptr{Ptr{Cvoid}}(x + 24)
    f === :setLocalSymIv && return Ptr{Ptr{Cvoid}}(x + 32)
    f === :setRemoteSymEncryptingKey && return Ptr{Ptr{Cvoid}}(x + 40)
    f === :setRemoteSymSigningKey && return Ptr{Ptr{Cvoid}}(x + 48)
    f === :setRemoteSymIv && return Ptr{Ptr{Cvoid}}(x + 56)
    f === :compareCertificate && return Ptr{Ptr{Cvoid}}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicyChannelModule, f::Symbol)
    r = Ref{UA_SecurityPolicyChannelModule}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicyChannelModule}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicyChannelModule}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityPolicy
    data::NTuple{496, UInt8}
end

function Base.fieldnames(::Type{UA_SecurityPolicy})
    (:policyContext, :policyUri, :localCertificate, :asymmetricModule,
        :symmetricModule, :certificateSigningAlgorithm, :channelModule,
        :logger, :updateCertificateAndPrivateKey, :clear)
end
function Base.fieldnames(::Type{Ptr{UA_SecurityPolicy}})
    (:policyContext, :policyUri, :localCertificate, :asymmetricModule,
        :symmetricModule, :certificateSigningAlgorithm, :channelModule,
        :logger, :updateCertificateAndPrivateKey, :clear)
end

function Base.getproperty(x::Ptr{UA_SecurityPolicy}, f::Symbol)
    f === :policyContext && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :policyUri && return Ptr{UA_String}(x + 8)
    f === :localCertificate && return Ptr{UA_ByteString}(x + 24)
    f === :asymmetricModule && return Ptr{UA_SecurityPolicyAsymmetricModule}(x + 40)
    f === :symmetricModule && return Ptr{UA_SecurityPolicySymmetricModule}(x + 184)
    f === :certificateSigningAlgorithm &&
        return Ptr{UA_SecurityPolicySignatureAlgorithm}(x + 336)
    f === :channelModule && return Ptr{UA_SecurityPolicyChannelModule}(x + 400)
    f === :logger && return Ptr{Ptr{UA_Logger}}(x + 472)
    f === :updateCertificateAndPrivateKey && return Ptr{Ptr{Cvoid}}(x + 480)
    f === :clear && return Ptr{Ptr{Cvoid}}(x + 488)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SecurityPolicy, f::Symbol)
    r = Ref{UA_SecurityPolicy}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SecurityPolicy}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SecurityPolicy}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CertificateVerification
    context::Ptr{Cvoid}
    verifyCertificate::Ptr{Cvoid}
    verifyApplicationURI::Ptr{Cvoid}
    getExpirationDate::Ptr{Cvoid}
    getSubjectName::Ptr{Cvoid}
    clear::Ptr{Cvoid}
    logging::Ptr{UA_Logger}
end

const UA_LocaleId = UA_String

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ClientConfig
    data::NTuple{784, UInt8}
end

function Base.fieldnames(::Type{UA_ClientConfig})
    (:clientContext, :logging, :timeout, :clientDescription, :endpointUrl,
        :userIdentityToken, :securityMode, :securityPolicyUri, :noSession, :noReconnect,
        :noNewSession, :endpoint, :userTokenPolicy, :applicationUri, :customDataTypes,
        :secureChannelLifeTime, :requestedSessionTimeout, :localConnectionConfig,
        :connectivityCheckInterval, :eventLoop, :externalEventLoop, :securityPoliciesSize,
        :securityPolicies, :certificateVerification, :authSecurityPoliciesSize,
        :authSecurityPolicies, :authSecurityPolicyUri, :stateCallback, :inactivityCallback,
        :outStandingPublishRequests, :subscriptionInactivityCallback, :sessionName,
        :sessionLocaleIds, :sessionLocaleIdsSize, :privateKeyPasswordCallback)
end
function Base.fieldnames(::Type{Ptr{UA_ClientConfig}})
    (:clientContext, :logging, :timeout, :clientDescription, :endpointUrl,
        :userIdentityToken, :securityMode, :securityPolicyUri, :noSession, :noReconnect,
        :noNewSession, :endpoint, :userTokenPolicy, :applicationUri, :customDataTypes,
        :secureChannelLifeTime, :requestedSessionTimeout, :localConnectionConfig,
        :connectivityCheckInterval, :eventLoop, :externalEventLoop, :securityPoliciesSize,
        :securityPolicies, :certificateVerification, :authSecurityPoliciesSize,
        :authSecurityPolicies, :authSecurityPolicyUri, :stateCallback, :inactivityCallback,
        :outStandingPublishRequests, :subscriptionInactivityCallback, :sessionName,
        :sessionLocaleIds, :sessionLocaleIdsSize, :privateKeyPasswordCallback)
end

function Base.getproperty(x::Ptr{UA_ClientConfig}, f::Symbol)
    f === :clientContext && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :logging && return Ptr{Ptr{UA_Logger}}(x + 8)
    f === :timeout && return Ptr{UA_UInt32}(x + 16)
    f === :clientDescription && return Ptr{UA_ApplicationDescription}(x + 24)
    f === :endpointUrl && return Ptr{UA_String}(x + 144)
    f === :userIdentityToken && return Ptr{UA_ExtensionObject}(x + 160)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 208)
    f === :securityPolicyUri && return Ptr{UA_String}(x + 216)
    f === :noSession && return Ptr{UA_Boolean}(x + 232)
    f === :noReconnect && return Ptr{UA_Boolean}(x + 233)
    f === :noNewSession && return Ptr{UA_Boolean}(x + 234)
    f === :endpoint && return Ptr{UA_EndpointDescription}(x + 240)
    f === :userTokenPolicy && return Ptr{UA_UserTokenPolicy}(x + 456)
    f === :applicationUri && return Ptr{UA_String}(x + 528)
    f === :customDataTypes && return Ptr{Ptr{UA_DataTypeArray}}(x + 544)
    f === :secureChannelLifeTime && return Ptr{UA_UInt32}(x + 552)
    f === :requestedSessionTimeout && return Ptr{UA_UInt32}(x + 556)
    f === :localConnectionConfig && return Ptr{UA_ConnectionConfig}(x + 560)
    f === :connectivityCheckInterval && return Ptr{UA_UInt32}(x + 588)
    f === :eventLoop && return Ptr{Ptr{UA_EventLoop}}(x + 592)
    f === :externalEventLoop && return Ptr{UA_Boolean}(x + 600)
    f === :securityPoliciesSize && return Ptr{Csize_t}(x + 608)
    f === :securityPolicies && return Ptr{Ptr{UA_SecurityPolicy}}(x + 616)
    f === :certificateVerification && return Ptr{UA_CertificateVerification}(x + 624)
    f === :authSecurityPoliciesSize && return Ptr{Csize_t}(x + 680)
    f === :authSecurityPolicies && return Ptr{Ptr{UA_SecurityPolicy}}(x + 688)
    f === :authSecurityPolicyUri && return Ptr{UA_String}(x + 696)
    f === :stateCallback && return Ptr{Ptr{Cvoid}}(x + 712)
    f === :inactivityCallback && return Ptr{Ptr{Cvoid}}(x + 720)
    f === :outStandingPublishRequests && return Ptr{UA_UInt16}(x + 728)
    f === :subscriptionInactivityCallback && return Ptr{Ptr{Cvoid}}(x + 736)
    f === :sessionName && return Ptr{UA_String}(x + 744)
    f === :sessionLocaleIds && return Ptr{Ptr{UA_LocaleId}}(x + 760)
    f === :sessionLocaleIdsSize && return Ptr{Csize_t}(x + 768)
    f === :privateKeyPasswordCallback && return Ptr{Ptr{Cvoid}}(x + 776)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ClientConfig, f::Symbol)
    r = Ref{UA_ClientConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ClientConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ClientConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_StatusCode = UInt32

function UA_ClientConfig_copy(src, dst)
    @ccall libopen62541.UA_ClientConfig_copy(
        src::Ptr{UA_ClientConfig}, dst::Ptr{UA_ClientConfig})::UA_StatusCode
end

function UA_ClientConfig_delete(config)
    @ccall libopen62541.UA_ClientConfig_delete(config::Ptr{UA_ClientConfig})::Cvoid
end

function UA_ClientConfig_clear(config)
    @ccall libopen62541.UA_ClientConfig_clear(config::Ptr{UA_ClientConfig})::Cvoid
end

function UA_Client_new()
    @ccall libopen62541.UA_Client_new()::Ptr{UA_Client}
end

function UA_Client_newWithConfig(config)
    @ccall libopen62541.UA_Client_newWithConfig(config::Ptr{UA_ClientConfig})::Ptr{UA_Client}
end

@cenum UA_SecureChannelState::UInt32 begin
    UA_SECURECHANNELSTATE_CLOSED = 0
    UA_SECURECHANNELSTATE_REVERSE_LISTENING = 1
    UA_SECURECHANNELSTATE_CONNECTING = 2
    UA_SECURECHANNELSTATE_CONNECTED = 3
    UA_SECURECHANNELSTATE_REVERSE_CONNECTED = 4
    UA_SECURECHANNELSTATE_RHE_SENT = 5
    UA_SECURECHANNELSTATE_HEL_SENT = 6
    UA_SECURECHANNELSTATE_HEL_RECEIVED = 7
    UA_SECURECHANNELSTATE_ACK_SENT = 8
    UA_SECURECHANNELSTATE_ACK_RECEIVED = 9
    UA_SECURECHANNELSTATE_OPN_SENT = 10
    UA_SECURECHANNELSTATE_OPEN = 11
    UA_SECURECHANNELSTATE_CLOSING = 12
end

@cenum UA_SessionState::UInt32 begin
    UA_SESSIONSTATE_CLOSED = 0
    UA_SESSIONSTATE_CREATE_REQUESTED = 1
    UA_SESSIONSTATE_CREATED = 2
    UA_SESSIONSTATE_ACTIVATE_REQUESTED = 3
    UA_SESSIONSTATE_ACTIVATED = 4
    UA_SESSIONSTATE_CLOSING = 5
end

function UA_Client_getState(client, channelState, sessionState, connectStatus)
    @ccall libopen62541.UA_Client_getState(
        client::Ptr{UA_Client}, channelState::Ptr{UA_SecureChannelState},
        sessionState::Ptr{UA_SessionState}, connectStatus::Ptr{UA_StatusCode})::Cvoid
end

function UA_Client_getConfig(client)
    @ccall libopen62541.UA_Client_getConfig(client::Ptr{UA_Client})::Ptr{UA_ClientConfig}
end

function UA_Client_delete(client)
    @ccall libopen62541.UA_Client_delete(client::Ptr{UA_Client})::Cvoid
end

function UA_Client_getConnectionAttribute(client, key, outValue)
    @ccall libopen62541.UA_Client_getConnectionAttribute(
        client::Ptr{UA_Client}, key::UA_QualifiedName,
        outValue::Ptr{UA_Variant})::UA_StatusCode
end

function UA_Client_getConnectionAttributeCopy(client, key, outValue)
    @ccall libopen62541.UA_Client_getConnectionAttributeCopy(
        client::Ptr{UA_Client}, key::UA_QualifiedName,
        outValue::Ptr{UA_Variant})::UA_StatusCode
end

function UA_Client_getConnectionAttribute_scalar(client, key, type, outValue)
    @ccall libopen62541.UA_Client_getConnectionAttribute_scalar(
        client::Ptr{UA_Client}, key::UA_QualifiedName,
        type::Ptr{UA_DataType}, outValue::Ptr{Cvoid})::UA_StatusCode
end

function __UA_Client_connect(client, async)
    @ccall libopen62541.__UA_Client_connect(
        client::Ptr{UA_Client}, async::UA_Boolean)::UA_StatusCode
end

function UA_Client_startListeningForReverseConnect(
        client, listenHostnames, listenHostnamesLength, port)
    @ccall libopen62541.UA_Client_startListeningForReverseConnect(
        client::Ptr{UA_Client}, listenHostnames::Ptr{UA_String},
        listenHostnamesLength::Csize_t, port::UA_UInt16)::UA_StatusCode
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

function UA_Client_disconnectSecureChannelAsync(client)
    @ccall libopen62541.UA_Client_disconnectSecureChannelAsync(client::Ptr{UA_Client})::UA_StatusCode
end

function UA_Client_getSessionAuthenticationToken(client, authenticationToken, serverNonce)
    @ccall libopen62541.UA_Client_getSessionAuthenticationToken(
        client::Ptr{UA_Client}, authenticationToken::Ptr{UA_NodeId},
        serverNonce::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_Client_activateCurrentSession(client)
    @ccall libopen62541.UA_Client_activateCurrentSession(client::Ptr{UA_Client})::UA_StatusCode
end

function UA_Client_activateCurrentSessionAsync(client)
    @ccall libopen62541.UA_Client_activateCurrentSessionAsync(client::Ptr{UA_Client})::UA_StatusCode
end

function UA_Client_activateSession(client, authenticationToken, serverNonce)
    @ccall libopen62541.UA_Client_activateSession(
        client::Ptr{UA_Client}, authenticationToken::UA_NodeId,
        serverNonce::UA_ByteString)::UA_StatusCode
end

function UA_Client_activateSessionAsync(client, authenticationToken, serverNonce)
    @ccall libopen62541.UA_Client_activateSessionAsync(
        client::Ptr{UA_Client}, authenticationToken::UA_NodeId,
        serverNonce::UA_ByteString)::UA_StatusCode
end

function UA_Client_getEndpoints(
        client, serverUrl, endpointDescriptionsSize, endpointDescriptions)
    @ccall libopen62541.UA_Client_getEndpoints(
        client::Ptr{UA_Client}, serverUrl::Cstring, endpointDescriptionsSize::Ptr{Csize_t},
        endpointDescriptions::Ptr{Ptr{UA_EndpointDescription}})::UA_StatusCode
end

function UA_Client_findServers(
        client, serverUrl, serverUrisSize, serverUris, localeIdsSize,
        localeIds, registeredServersSize, registeredServers)
    @ccall libopen62541.UA_Client_findServers(
        client::Ptr{UA_Client}, serverUrl::Cstring, serverUrisSize::Csize_t,
        serverUris::Ptr{UA_String}, localeIdsSize::Csize_t,
        localeIds::Ptr{UA_String}, registeredServersSize::Ptr{Csize_t},
        registeredServers::Ptr{Ptr{UA_ApplicationDescription}})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ServerOnNetwork
    recordId::UA_UInt32
    serverName::UA_String
    discoveryUrl::UA_String
    serverCapabilitiesSize::Csize_t
    serverCapabilities::Ptr{UA_String}
end

function UA_Client_findServersOnNetwork(
        client, serverUrl, startingRecordId, maxRecordsToReturn, serverCapabilityFilterSize,
        serverCapabilityFilter, serverOnNetworkSize, serverOnNetwork)
    @ccall libopen62541.UA_Client_findServersOnNetwork(
        client::Ptr{UA_Client}, serverUrl::Cstring, startingRecordId::UA_UInt32,
        maxRecordsToReturn::UA_UInt32, serverCapabilityFilterSize::Csize_t,
        serverCapabilityFilter::Ptr{UA_String}, serverOnNetworkSize::Ptr{Csize_t},
        serverOnNetwork::Ptr{Ptr{UA_ServerOnNetwork}})::UA_StatusCode
end

function __UA_Client_Service(client, request, requestType, response, responseType)
    @ccall libopen62541.__UA_Client_Service(
        client::Ptr{UA_Client}, request::Ptr{Cvoid}, requestType::Ptr{UA_DataType},
        response::Ptr{Cvoid}, responseType::Ptr{UA_DataType})::Cvoid
end

# typedef void ( * UA_ClientAsyncServiceCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , void * response )
const UA_ClientAsyncServiceCallback = Ptr{Cvoid}

function __UA_Client_AsyncService(
        client, request, requestType, callback, responseType, userdata, requestId)
    @ccall libopen62541.__UA_Client_AsyncService(
        client::Ptr{UA_Client}, request::Ptr{Cvoid}, requestType::Ptr{UA_DataType},
        callback::UA_ClientAsyncServiceCallback, responseType::Ptr{UA_DataType},
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_cancelByRequestHandle(client, requestHandle, cancelCount)
    @ccall libopen62541.UA_Client_cancelByRequestHandle(
        client::Ptr{UA_Client}, requestHandle::UA_UInt32,
        cancelCount::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_cancelByRequestId(client, requestId, cancelCount)
    @ccall libopen62541.UA_Client_cancelByRequestId(
        client::Ptr{UA_Client}, requestId::UA_UInt32,
        cancelCount::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_modifyAsyncCallback(client, requestId, userdata, callback)
    @ccall libopen62541.UA_Client_modifyAsyncCallback(
        client::Ptr{UA_Client}, requestId::UA_UInt32, userdata::Ptr{Cvoid},
        callback::UA_ClientAsyncServiceCallback)::UA_StatusCode
end

function UA_Client_run_iterate(client, timeout)
    @ccall libopen62541.UA_Client_run_iterate(
        client::Ptr{UA_Client}, timeout::UA_UInt32)::UA_StatusCode
end

function UA_Client_renewSecureChannel(client)
    @ccall libopen62541.UA_Client_renewSecureChannel(client::Ptr{UA_Client})::UA_StatusCode
end

# typedef void ( * UA_ClientCallback ) ( UA_Client * client , void * data )
const UA_ClientCallback = Ptr{Cvoid}

const UA_DateTime = Int64

function UA_Client_addTimedCallback(client, callback, data, date, callbackId)
    @ccall libopen62541.UA_Client_addTimedCallback(
        client::Ptr{UA_Client}, callback::UA_ClientCallback, data::Ptr{Cvoid},
        date::UA_DateTime, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

const UA_Double = Cdouble

function UA_Client_addRepeatedCallback(client, callback, data, interval_ms, callbackId)
    @ccall libopen62541.UA_Client_addRepeatedCallback(
        client::Ptr{UA_Client}, callback::UA_ClientCallback, data::Ptr{Cvoid},
        interval_ms::UA_Double, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Client_changeRepeatedCallbackInterval(client, callbackId, interval_ms)
    @ccall libopen62541.UA_Client_changeRepeatedCallbackInterval(
        client::Ptr{UA_Client}, callbackId::UA_UInt64,
        interval_ms::UA_Double)::UA_StatusCode
end

function UA_Client_findDataType(client, typeId)
    @ccall libopen62541.UA_Client_findDataType(
        client::Ptr{UA_Client}, typeId::Ptr{UA_NodeId})::Ptr{UA_DataType}
end

function UA_ClientConfig_setDefault(config)
    @ccall libopen62541.UA_ClientConfig_setDefault(config::Ptr{UA_ClientConfig})::UA_StatusCode
end

function UA_ClientConfig_setAuthenticationCert(config, certificateAuth, privateKeyAuth)
    @ccall libopen62541.UA_ClientConfig_setAuthenticationCert(
        config::Ptr{UA_ClientConfig}, certificateAuth::UA_ByteString,
        privateKeyAuth::UA_ByteString)::UA_StatusCode
end

function UA_ClientConfig_setDefaultEncryption(
        config, localCertificate, privateKey, trustList,
        trustListSize, revocationList, revocationListSize)
    @ccall libopen62541.UA_ClientConfig_setDefaultEncryption(
        config::Ptr{UA_ClientConfig}, localCertificate::UA_ByteString,
        privateKey::UA_ByteString, trustList::Ptr{UA_ByteString}, trustListSize::Csize_t,
        revocationList::Ptr{UA_ByteString}, revocationListSize::Csize_t)::UA_StatusCode
end

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

function __UA_Client_readAttribute(client, nodeId, attributeId, out, outDataType)
    @ccall libopen62541.__UA_Client_readAttribute(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId,
        out::Ptr{Cvoid}, outDataType::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Client_readArrayDimensionsAttribute(
        client, nodeId, outArrayDimensionsSize, outArrayDimensions)
    @ccall libopen62541.UA_Client_readArrayDimensionsAttribute(
        client::Ptr{UA_Client}, nodeId::UA_NodeId, outArrayDimensionsSize::Ptr{Csize_t},
        outArrayDimensions::Ptr{Ptr{UA_UInt32}})::UA_StatusCode
end

# typedef UA_Boolean ( * UA_HistoricalIteratorCallback ) ( UA_Client * client , const UA_NodeId * nodeId , UA_Boolean moreDataAvailable , const UA_ExtensionObject * data , void * callbackContext )
const UA_HistoricalIteratorCallback = Ptr{Cvoid}

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SimpleAttributeOperand
    data::NTuple{64, UInt8}
end

function Base.fieldnames(::Type{UA_SimpleAttributeOperand})
    (:typeDefinitionId, :browsePathSize, :browsePath, :attributeId, :indexRange)
end
function Base.fieldnames(::Type{Ptr{UA_SimpleAttributeOperand}})
    (:typeDefinitionId, :browsePathSize, :browsePath, :attributeId, :indexRange)
end

function Base.getproperty(x::Ptr{UA_SimpleAttributeOperand}, f::Symbol)
    f === :typeDefinitionId && return Ptr{UA_NodeId}(x + 0)
    f === :browsePathSize && return Ptr{Csize_t}(x + 24)
    f === :browsePath && return Ptr{Ptr{UA_QualifiedName}}(x + 32)
    f === :attributeId && return Ptr{UA_UInt32}(x + 40)
    f === :indexRange && return Ptr{UA_String}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SimpleAttributeOperand, f::Symbol)
    r = Ref{UA_SimpleAttributeOperand}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SimpleAttributeOperand}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SimpleAttributeOperand}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

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

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ContentFilterElement
    filterOperator::UA_FilterOperator
    filterOperandsSize::Csize_t
    filterOperands::Ptr{UA_ExtensionObject}
end
function Base.getproperty(x::Ptr{UA_ContentFilterElement}, f::Symbol)
    f === :filterOperator && return Ptr{UA_FilterOperator}(x + 0)
    f === :filterOperandsSize && return Ptr{Csize_t}(x + 8)
    f === :filterOperands && return Ptr{Ptr{UA_ExtensionObject}}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ContentFilterElement}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ContentFilter
    elementsSize::Csize_t
    elements::Ptr{UA_ContentFilterElement}
end
function Base.getproperty(x::Ptr{UA_ContentFilter}, f::Symbol)
    f === :elementsSize && return Ptr{Csize_t}(x + 0)
    f === :elements && return Ptr{Ptr{UA_ContentFilterElement}}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ContentFilter}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EventFilter
    selectClausesSize::Csize_t
    selectClauses::Ptr{UA_SimpleAttributeOperand}
    whereClause::UA_ContentFilter
end
function Base.getproperty(x::Ptr{UA_EventFilter}, f::Symbol)
    f === :selectClausesSize && return Ptr{Csize_t}(x + 0)
    f === :selectClauses && return Ptr{Ptr{UA_SimpleAttributeOperand}}(x + 8)
    f === :whereClause && return Ptr{UA_ContentFilter}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EventFilter}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_TimestampsToReturn::UInt32 begin
    UA_TIMESTAMPSTORETURN_SOURCE = 0
    UA_TIMESTAMPSTORETURN_SERVER = 1
    UA_TIMESTAMPSTORETURN_BOTH = 2
    UA_TIMESTAMPSTORETURN_NEITHER = 3
    UA_TIMESTAMPSTORETURN_INVALID = 4
    __UA_TIMESTAMPSTORETURN_FORCE32BIT = 2147483647
end

function UA_Client_HistoryRead_events(
        client, nodeId, callback, startTime, endTime, indexRange,
        filter, numValuesPerNode, timestampsToReturn, callbackContext)
    @ccall libopen62541.UA_Client_HistoryRead_events(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        callback::UA_HistoricalIteratorCallback, startTime::UA_DateTime,
        endTime::UA_DateTime, indexRange::UA_String, filter::UA_EventFilter,
        numValuesPerNode::UA_UInt32, timestampsToReturn::UA_TimestampsToReturn,
        callbackContext::Ptr{Cvoid})::UA_StatusCode
end

function UA_Client_HistoryRead_raw(
        client, nodeId, callback, startTime, endTime, indexRange,
        returnBounds, numValuesPerNode, timestampsToReturn, callbackContext)
    @ccall libopen62541.UA_Client_HistoryRead_raw(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        callback::UA_HistoricalIteratorCallback, startTime::UA_DateTime,
        endTime::UA_DateTime, indexRange::UA_String, returnBounds::UA_Boolean,
        numValuesPerNode::UA_UInt32, timestampsToReturn::UA_TimestampsToReturn,
        callbackContext::Ptr{Cvoid})::UA_StatusCode
end

function UA_Client_HistoryRead_modified(
        client, nodeId, callback, startTime, endTime, indexRange,
        returnBounds, numValuesPerNode, timestampsToReturn, callbackContext)
    @ccall libopen62541.UA_Client_HistoryRead_modified(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        callback::UA_HistoricalIteratorCallback, startTime::UA_DateTime,
        endTime::UA_DateTime, indexRange::UA_String, returnBounds::UA_Boolean,
        numValuesPerNode::UA_UInt32, timestampsToReturn::UA_TimestampsToReturn,
        callbackContext::Ptr{Cvoid})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataValue
    data::NTuple{80, UInt8}
end

function Base.fieldnames(::Type{UA_DataValue})
    (:value, :sourceTimestamp, :serverTimestamp, :sourcePicoseconds,
        :serverPicoseconds, :status, :hasValue, :hasStatus, :hasSourceTimestamp,
        :hasServerTimestamp, :hasSourcePicoseconds, :hasServerPicoseconds)
end
function Base.fieldnames(::Type{Ptr{UA_DataValue}})
    (:value, :sourceTimestamp, :serverTimestamp, :sourcePicoseconds,
        :serverPicoseconds, :status, :hasValue, :hasStatus, :hasSourceTimestamp,
        :hasServerTimestamp, :hasSourcePicoseconds, :hasServerPicoseconds)
end

function Base.getproperty(x::Ptr{UA_DataValue}, f::Symbol)
    f === :value && return Ptr{UA_Variant}(x + 0)
    f === :sourceTimestamp && return Ptr{UA_DateTime}(x + 48)
    f === :serverTimestamp && return Ptr{UA_DateTime}(x + 56)
    f === :sourcePicoseconds && return Ptr{UA_UInt16}(x + 64)
    f === :serverPicoseconds && return Ptr{UA_UInt16}(x + 66)
    f === :status && return Ptr{UA_StatusCode}(x + 68)
    f === :hasValue && return (Ptr{UA_Boolean}(x + 72), 0, 1)
    f === :hasStatus && return (Ptr{UA_Boolean}(x + 72), 1, 1)
    f === :hasSourceTimestamp && return (Ptr{UA_Boolean}(x + 72), 2, 1)
    f === :hasServerTimestamp && return (Ptr{UA_Boolean}(x + 72), 3, 1)
    f === :hasSourcePicoseconds && return (Ptr{UA_Boolean}(x + 72), 4, 1)
    f === :hasServerPicoseconds && return (Ptr{UA_Boolean}(x + 72), 5, 1)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataValue, f::Symbol)
    r = Ref{UA_DataValue}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataValue}, r)
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

function Base.setproperty!(x::Ptr{UA_DataValue}, f::Symbol, v)
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

function UA_Client_HistoryUpdate_insert(client, nodeId, value)
    @ccall libopen62541.UA_Client_HistoryUpdate_insert(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        value::Ptr{UA_DataValue})::UA_StatusCode
end

function UA_Client_HistoryUpdate_replace(client, nodeId, value)
    @ccall libopen62541.UA_Client_HistoryUpdate_replace(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        value::Ptr{UA_DataValue})::UA_StatusCode
end

function UA_Client_HistoryUpdate_update(client, nodeId, value)
    @ccall libopen62541.UA_Client_HistoryUpdate_update(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        value::Ptr{UA_DataValue})::UA_StatusCode
end

function UA_Client_HistoryUpdate_deleteRaw(client, nodeId, startTimestamp, endTimestamp)
    @ccall libopen62541.UA_Client_HistoryUpdate_deleteRaw(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        startTimestamp::UA_DateTime, endTimestamp::UA_DateTime)::UA_StatusCode
end

function __UA_Client_writeAttribute(client, nodeId, attributeId, in, inDataType)
    @ccall libopen62541.__UA_Client_writeAttribute(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId,
        in::Ptr{Cvoid}, inDataType::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Client_writeArrayDimensionsAttribute(
        client, nodeId, newArrayDimensionsSize, newArrayDimensions)
    @ccall libopen62541.UA_Client_writeArrayDimensionsAttribute(
        client::Ptr{UA_Client}, nodeId::UA_NodeId, newArrayDimensionsSize::Csize_t,
        newArrayDimensions::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_call(client, objectId, methodId, inputSize, input, outputSize, output)
    @ccall libopen62541.UA_Client_call(
        client::Ptr{UA_Client}, objectId::UA_NodeId, methodId::UA_NodeId,
        inputSize::Csize_t, input::Ptr{UA_Variant}, outputSize::Ptr{Csize_t},
        output::Ptr{Ptr{UA_Variant}})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ExpandedNodeId
    data::NTuple{48, UInt8}
end

Base.fieldnames(::Type{UA_ExpandedNodeId}) = (:nodeId, :namespaceUri, :serverIndex)
Base.fieldnames(::Type{Ptr{UA_ExpandedNodeId}}) = (:nodeId, :namespaceUri, :serverIndex)

function Base.getproperty(x::Ptr{UA_ExpandedNodeId}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :namespaceUri && return Ptr{UA_String}(x + 24)
    f === :serverIndex && return Ptr{UA_UInt32}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ExpandedNodeId, f::Symbol)
    r = Ref{UA_ExpandedNodeId}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ExpandedNodeId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ExpandedNodeId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

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

function UA_Client_addReference(client, sourceNodeId, referenceTypeId, isForward,
        targetServerUri, targetNodeId, targetNodeClass)
    @ccall libopen62541.UA_Client_addReference(
        client::Ptr{UA_Client}, sourceNodeId::UA_NodeId, referenceTypeId::UA_NodeId,
        isForward::UA_Boolean, targetServerUri::UA_String,
        targetNodeId::UA_ExpandedNodeId, targetNodeClass::UA_NodeClass)::UA_StatusCode
end

function UA_Client_deleteReference(
        client, sourceNodeId, referenceTypeId, isForward, targetNodeId, deleteBidirectional)
    @ccall libopen62541.UA_Client_deleteReference(
        client::Ptr{UA_Client}, sourceNodeId::UA_NodeId, referenceTypeId::UA_NodeId,
        isForward::UA_Boolean, targetNodeId::UA_ExpandedNodeId,
        deleteBidirectional::UA_Boolean)::UA_StatusCode
end

function UA_Client_deleteNode(client, nodeId, deleteTargetReferences)
    @ccall libopen62541.UA_Client_deleteNode(client::Ptr{UA_Client}, nodeId::UA_NodeId,
        deleteTargetReferences::UA_Boolean)::UA_StatusCode
end

struct UA_NodeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
end
function Base.getproperty(x::Ptr{UA_NodeAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_NodeAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function __UA_Client_addNode(
        client, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId,
        browseName, typeDefinition, attr, attributeType, outNewNodeId)
    @ccall libopen62541.__UA_Client_addNode(
        client::Ptr{UA_Client}, nodeClass::UA_NodeClass, requestedNewNodeId::UA_NodeId,
        parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName,
        typeDefinition::UA_NodeId, attr::Ptr{UA_NodeAttributes},
        attributeType::Ptr{UA_DataType}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Client_NamespaceGetIndex(client, namespaceUri, namespaceIndex)
    @ccall libopen62541.UA_Client_NamespaceGetIndex(
        client::Ptr{UA_Client}, namespaceUri::Ptr{UA_String},
        namespaceIndex::Ptr{UA_UInt16})::UA_StatusCode
end

# typedef UA_StatusCode ( * UA_NodeIteratorCallback ) ( UA_NodeId childId , UA_Boolean isInverse , UA_NodeId referenceTypeId , void * handle )
const UA_NodeIteratorCallback = Ptr{Cvoid}

function UA_Client_forEachChildNodeCall(client, parentNodeId, callback, handle)
    @ccall libopen62541.UA_Client_forEachChildNodeCall(
        client::Ptr{UA_Client}, parentNodeId::UA_NodeId,
        callback::UA_NodeIteratorCallback, handle::Ptr{Cvoid})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_ReadResponse * rr )
const UA_ClientAsyncReadCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncWriteCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_WriteResponse * wr )
const UA_ClientAsyncWriteCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncBrowseCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_BrowseResponse * wr )
const UA_ClientAsyncBrowseCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncBrowseNextCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_BrowseNextResponse * wr )
const UA_ClientAsyncBrowseNextCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncOperationCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , void * result )
const UA_ClientAsyncOperationCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncReadAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_DataValue * attribute )
const UA_ClientAsyncReadAttributeCallback = Ptr{Cvoid}

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadValueId
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_ReadValueId})
    (:nodeId, :attributeId, :indexRange, :dataEncoding)
end
function Base.fieldnames(::Type{Ptr{UA_ReadValueId}})
    (:nodeId, :attributeId, :indexRange, :dataEncoding)
end

function Base.getproperty(x::Ptr{UA_ReadValueId}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :attributeId && return Ptr{UA_UInt32}(x + 24)
    f === :indexRange && return Ptr{UA_String}(x + 32)
    f === :dataEncoding && return Ptr{UA_QualifiedName}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReadValueId, f::Symbol)
    r = Ref{UA_ReadValueId}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReadValueId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReadValueId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_readAttribute_async(
        client, rvi, timestampsToReturn, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readAttribute_async(
        client::Ptr{UA_Client}, rvi::Ptr{UA_ReadValueId},
        timestampsToReturn::UA_TimestampsToReturn,
        callback::UA_ClientAsyncReadAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadValueAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_DataValue * value )
const UA_ClientAsyncReadValueAttributeCallback = Ptr{Cvoid}

function UA_Client_readValueAttribute_async(client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readValueAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadValueAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadDataTypeAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_NodeId * dataType )
const UA_ClientAsyncReadDataTypeAttributeCallback = Ptr{Cvoid}

function UA_Client_readDataTypeAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readDataTypeAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadDataTypeAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientReadArrayDimensionsAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Variant * arrayDimensions )
const UA_ClientReadArrayDimensionsAttributeCallback = Ptr{Cvoid}

function UA_Client_readArrayDimensionsAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readArrayDimensionsAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientReadArrayDimensionsAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadNodeClassAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_NodeClass * nodeClass )
const UA_ClientAsyncReadNodeClassAttributeCallback = Ptr{Cvoid}

function UA_Client_readNodeClassAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readNodeClassAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadNodeClassAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadBrowseNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_QualifiedName * browseName )
const UA_ClientAsyncReadBrowseNameAttributeCallback = Ptr{Cvoid}

function UA_Client_readBrowseNameAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readBrowseNameAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadBrowseNameAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadDisplayNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_LocalizedText * displayName )
const UA_ClientAsyncReadDisplayNameAttributeCallback = Ptr{Cvoid}

function UA_Client_readDisplayNameAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readDisplayNameAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadDisplayNameAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadDescriptionAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_LocalizedText * description )
const UA_ClientAsyncReadDescriptionAttributeCallback = Ptr{Cvoid}

function UA_Client_readDescriptionAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readDescriptionAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadDescriptionAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadWriteMaskAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_UInt32 * writeMask )
const UA_ClientAsyncReadWriteMaskAttributeCallback = Ptr{Cvoid}

function UA_Client_readWriteMaskAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readWriteMaskAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadWriteMaskAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadUserWriteMaskAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_UInt32 * writeMask )
const UA_ClientAsyncReadUserWriteMaskAttributeCallback = Ptr{Cvoid}

function UA_Client_readUserWriteMaskAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readUserWriteMaskAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadUserWriteMaskAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadIsAbstractAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * isAbstract )
const UA_ClientAsyncReadIsAbstractAttributeCallback = Ptr{Cvoid}

function UA_Client_readIsAbstractAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readIsAbstractAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadIsAbstractAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadSymmetricAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * symmetric )
const UA_ClientAsyncReadSymmetricAttributeCallback = Ptr{Cvoid}

function UA_Client_readSymmetricAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readSymmetricAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadSymmetricAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadInverseNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_LocalizedText * inverseName )
const UA_ClientAsyncReadInverseNameAttributeCallback = Ptr{Cvoid}

function UA_Client_readInverseNameAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readInverseNameAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadInverseNameAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadContainsNoLoopsAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * containsNoLoops )
const UA_ClientAsyncReadContainsNoLoopsAttributeCallback = Ptr{Cvoid}

function UA_Client_readContainsNoLoopsAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readContainsNoLoopsAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadContainsNoLoopsAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadEventNotifierAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Byte * eventNotifier )
const UA_ClientAsyncReadEventNotifierAttributeCallback = Ptr{Cvoid}

function UA_Client_readEventNotifierAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readEventNotifierAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadEventNotifierAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadValueRankAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Int32 * valueRank )
const UA_ClientAsyncReadValueRankAttributeCallback = Ptr{Cvoid}

function UA_Client_readValueRankAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readValueRankAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadValueRankAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadAccessLevelAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Byte * accessLevel )
const UA_ClientAsyncReadAccessLevelAttributeCallback = Ptr{Cvoid}

function UA_Client_readAccessLevelAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readAccessLevelAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadAccessLevelAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadAccessLevelExAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_UInt32 * accessLevelEx )
const UA_ClientAsyncReadAccessLevelExAttributeCallback = Ptr{Cvoid}

function UA_Client_readAccessLevelExAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readAccessLevelExAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadAccessLevelExAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadUserAccessLevelAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Byte * userAccessLevel )
const UA_ClientAsyncReadUserAccessLevelAttributeCallback = Ptr{Cvoid}

function UA_Client_readUserAccessLevelAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readUserAccessLevelAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadUserAccessLevelAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Double * minimumSamplingInterval )
const UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback = Ptr{Cvoid}

function UA_Client_readMinimumSamplingIntervalAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readMinimumSamplingIntervalAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadHistorizingAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * historizing )
const UA_ClientAsyncReadHistorizingAttributeCallback = Ptr{Cvoid}

function UA_Client_readHistorizingAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readHistorizingAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadHistorizingAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadExecutableAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * executable )
const UA_ClientAsyncReadExecutableAttributeCallback = Ptr{Cvoid}

function UA_Client_readExecutableAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readExecutableAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadExecutableAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncReadUserExecutableAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * userExecutable )
const UA_ClientAsyncReadUserExecutableAttributeCallback = Ptr{Cvoid}

function UA_Client_readUserExecutableAttribute_async(
        client, nodeId, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_readUserExecutableAttribute_async(
        client::Ptr{UA_Client}, nodeId::UA_NodeId,
        callback::UA_ClientAsyncReadUserExecutableAttributeCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function __UA_Client_writeAttribute_async(
        client, nodeId, attributeId, in, inDataType, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_writeAttribute_async(
        client::Ptr{UA_Client}, nodeId::Ptr{UA_NodeId},
        attributeId::UA_AttributeId, in::Ptr{Cvoid},
        inDataType::Ptr{UA_DataType}, callback::UA_ClientAsyncServiceCallback,
        userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

function __UA_Client_call_async(
        client, objectId, methodId, inputSize, input, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_call_async(client::Ptr{UA_Client}, objectId::UA_NodeId,
        methodId::UA_NodeId, inputSize::Csize_t,
        input::Ptr{UA_Variant}, callback::UA_ClientAsyncServiceCallback,
        userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_ClientAsyncCallCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_CallResponse * cr )
const UA_ClientAsyncCallCallback = Ptr{Cvoid}

# typedef void ( * UA_ClientAsyncAddNodesCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_AddNodesResponse * ar )
const UA_ClientAsyncAddNodesCallback = Ptr{Cvoid}

function __UA_Client_addNode_async(
        client, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId, browseName,
        typeDefinition, attr, attributeType, outNewNodeId, callback, userdata, reqId)
    @ccall libopen62541.__UA_Client_addNode_async(
        client::Ptr{UA_Client}, nodeClass::UA_NodeClass, requestedNewNodeId::UA_NodeId,
        parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId,
        browseName::UA_QualifiedName, typeDefinition::UA_NodeId,
        attr::Ptr{UA_NodeAttributes}, attributeType::Ptr{UA_DataType},
        outNewNodeId::Ptr{UA_NodeId}, callback::UA_ClientAsyncServiceCallback,
        userdata::Ptr{Cvoid}, reqId::Ptr{UA_UInt32})::UA_StatusCode
end

# typedef void ( * UA_Client_DeleteSubscriptionCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext )
const UA_Client_DeleteSubscriptionCallback = Ptr{Cvoid}

# typedef void ( * UA_Client_StatusChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_StatusChangeNotification * notification )
const UA_Client_StatusChangeNotificationCallback = Ptr{Cvoid}

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RequestHeader
    data::NTuple{112, UInt8}
end

function Base.fieldnames(::Type{UA_RequestHeader})
    (:authenticationToken, :timestamp, :requestHandle,
        :returnDiagnostics, :auditEntryId, :timeoutHint, :additionalHeader)
end
function Base.fieldnames(::Type{Ptr{UA_RequestHeader}})
    (:authenticationToken, :timestamp, :requestHandle,
        :returnDiagnostics, :auditEntryId, :timeoutHint, :additionalHeader)
end

function Base.getproperty(x::Ptr{UA_RequestHeader}, f::Symbol)
    f === :authenticationToken && return Ptr{UA_NodeId}(x + 0)
    f === :timestamp && return Ptr{UA_DateTime}(x + 24)
    f === :requestHandle && return Ptr{UA_UInt32}(x + 32)
    f === :returnDiagnostics && return Ptr{UA_UInt32}(x + 36)
    f === :auditEntryId && return Ptr{UA_String}(x + 40)
    f === :timeoutHint && return Ptr{UA_UInt32}(x + 56)
    f === :additionalHeader && return Ptr{UA_ExtensionObject}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RequestHeader, f::Symbol)
    r = Ref{UA_RequestHeader}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RequestHeader}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RequestHeader}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CreateSubscriptionRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_CreateSubscriptionRequest})
    (:requestHeader, :requestedPublishingInterval,
        :requestedLifetimeCount, :requestedMaxKeepAliveCount,
        :maxNotificationsPerPublish, :publishingEnabled, :priority)
end
function Base.fieldnames(::Type{Ptr{UA_CreateSubscriptionRequest}})
    (:requestHeader, :requestedPublishingInterval,
        :requestedLifetimeCount, :requestedMaxKeepAliveCount,
        :maxNotificationsPerPublish, :publishingEnabled, :priority)
end

function Base.getproperty(x::Ptr{UA_CreateSubscriptionRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :requestedPublishingInterval && return Ptr{UA_Double}(x + 112)
    f === :requestedLifetimeCount && return Ptr{UA_UInt32}(x + 120)
    f === :requestedMaxKeepAliveCount && return Ptr{UA_UInt32}(x + 124)
    f === :maxNotificationsPerPublish && return Ptr{UA_UInt32}(x + 128)
    f === :publishingEnabled && return Ptr{UA_Boolean}(x + 132)
    f === :priority && return Ptr{UA_Byte}(x + 133)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CreateSubscriptionRequest, f::Symbol)
    r = Ref{UA_CreateSubscriptionRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CreateSubscriptionRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CreateSubscriptionRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_Int32 = Int32

"""

$(TYPEDEF)

Fields:

- `hasSymbolicId`

- `hasNamespaceUri`

- `hasLocalizedText`

- `hasLocale`

- `hasAdditionalInfo`

- `hasInnerStatusCode`

- `hasInnerDiagnosticInfo`

- `symbolicId`

- `namespaceUri`

- `localizedText`

- `locale`

- `additionalInfo`

- `innerStatusCode`

- `innerDiagnosticInfo`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_DiagnosticInfo
    data::NTuple{56, UInt8}
end

function Base.fieldnames(::Type{UA_DiagnosticInfo})
    (:hasSymbolicId, :hasNamespaceUri, :hasLocalizedText, :hasLocale, :hasAdditionalInfo,
        :hasInnerStatusCode, :hasInnerDiagnosticInfo, :symbolicId, :namespaceUri,
        :localizedText, :locale, :additionalInfo, :innerStatusCode, :innerDiagnosticInfo)
end
function Base.fieldnames(::Type{Ptr{UA_DiagnosticInfo}})
    (:hasSymbolicId, :hasNamespaceUri, :hasLocalizedText, :hasLocale, :hasAdditionalInfo,
        :hasInnerStatusCode, :hasInnerDiagnosticInfo, :symbolicId, :namespaceUri,
        :localizedText, :locale, :additionalInfo, :innerStatusCode, :innerDiagnosticInfo)
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

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ResponseHeader
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_ResponseHeader})
    (:timestamp, :requestHandle, :serviceResult, :serviceDiagnostics,
        :stringTableSize, :stringTable, :additionalHeader)
end
function Base.fieldnames(::Type{Ptr{UA_ResponseHeader}})
    (:timestamp, :requestHandle, :serviceResult, :serviceDiagnostics,
        :stringTableSize, :stringTable, :additionalHeader)
end

function Base.getproperty(x::Ptr{UA_ResponseHeader}, f::Symbol)
    f === :timestamp && return Ptr{UA_DateTime}(x + 0)
    f === :requestHandle && return Ptr{UA_UInt32}(x + 8)
    f === :serviceResult && return Ptr{UA_StatusCode}(x + 12)
    f === :serviceDiagnostics && return Ptr{UA_DiagnosticInfo}(x + 16)
    f === :stringTableSize && return Ptr{Csize_t}(x + 72)
    f === :stringTable && return Ptr{Ptr{UA_String}}(x + 80)
    f === :additionalHeader && return Ptr{UA_ExtensionObject}(x + 88)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ResponseHeader, f::Symbol)
    r = Ref{UA_ResponseHeader}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ResponseHeader}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ResponseHeader}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CreateSubscriptionResponse
    data::NTuple{160, UInt8}
end

function Base.fieldnames(::Type{UA_CreateSubscriptionResponse})
    (:responseHeader, :subscriptionId, :revisedPublishingInterval,
        :revisedLifetimeCount, :revisedMaxKeepAliveCount)
end
function Base.fieldnames(::Type{Ptr{UA_CreateSubscriptionResponse}})
    (:responseHeader, :subscriptionId, :revisedPublishingInterval,
        :revisedLifetimeCount, :revisedMaxKeepAliveCount)
end

function Base.getproperty(x::Ptr{UA_CreateSubscriptionResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 136)
    f === :revisedPublishingInterval && return Ptr{UA_Double}(x + 144)
    f === :revisedLifetimeCount && return Ptr{UA_UInt32}(x + 152)
    f === :revisedMaxKeepAliveCount && return Ptr{UA_UInt32}(x + 156)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CreateSubscriptionResponse, f::Symbol)
    r = Ref{UA_CreateSubscriptionResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CreateSubscriptionResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CreateSubscriptionResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_Subscriptions_create(
        client, request, subscriptionContext, statusChangeCallback, deleteCallback)
    @ccall libopen62541.UA_Client_Subscriptions_create(client::Ptr{UA_Client},
        request::UA_CreateSubscriptionRequest,
        subscriptionContext::Ptr{Cvoid},
        statusChangeCallback::UA_Client_StatusChangeNotificationCallback,
        deleteCallback::UA_Client_DeleteSubscriptionCallback)::UA_CreateSubscriptionResponse
end

function UA_Client_Subscriptions_create_async(
        client, request, subscriptionContext, statusChangeCallback,
        deleteCallback, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_Subscriptions_create_async(
        client::Ptr{UA_Client}, request::UA_CreateSubscriptionRequest,
        subscriptionContext::Ptr{Cvoid},
        statusChangeCallback::UA_Client_StatusChangeNotificationCallback,
        deleteCallback::UA_Client_DeleteSubscriptionCallback,
        callback::UA_ClientAsyncServiceCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ModifySubscriptionRequest
    data::NTuple{144, UInt8}
end

function Base.fieldnames(::Type{UA_ModifySubscriptionRequest})
    (:requestHeader, :subscriptionId, :requestedPublishingInterval,
        :requestedLifetimeCount, :requestedMaxKeepAliveCount,
        :maxNotificationsPerPublish, :priority)
end
function Base.fieldnames(::Type{Ptr{UA_ModifySubscriptionRequest}})
    (:requestHeader, :subscriptionId, :requestedPublishingInterval,
        :requestedLifetimeCount, :requestedMaxKeepAliveCount,
        :maxNotificationsPerPublish, :priority)
end

function Base.getproperty(x::Ptr{UA_ModifySubscriptionRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :requestedPublishingInterval && return Ptr{UA_Double}(x + 120)
    f === :requestedLifetimeCount && return Ptr{UA_UInt32}(x + 128)
    f === :requestedMaxKeepAliveCount && return Ptr{UA_UInt32}(x + 132)
    f === :maxNotificationsPerPublish && return Ptr{UA_UInt32}(x + 136)
    f === :priority && return Ptr{UA_Byte}(x + 140)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ModifySubscriptionRequest, f::Symbol)
    r = Ref{UA_ModifySubscriptionRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ModifySubscriptionRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ModifySubscriptionRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ModifySubscriptionResponse
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_ModifySubscriptionResponse})
    (:responseHeader, :revisedPublishingInterval,
        :revisedLifetimeCount, :revisedMaxKeepAliveCount)
end
function Base.fieldnames(::Type{Ptr{UA_ModifySubscriptionResponse}})
    (:responseHeader, :revisedPublishingInterval,
        :revisedLifetimeCount, :revisedMaxKeepAliveCount)
end

function Base.getproperty(x::Ptr{UA_ModifySubscriptionResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :revisedPublishingInterval && return Ptr{UA_Double}(x + 136)
    f === :revisedLifetimeCount && return Ptr{UA_UInt32}(x + 144)
    f === :revisedMaxKeepAliveCount && return Ptr{UA_UInt32}(x + 148)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ModifySubscriptionResponse, f::Symbol)
    r = Ref{UA_ModifySubscriptionResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ModifySubscriptionResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ModifySubscriptionResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_Subscriptions_modify(client, request)
    @ccall libopen62541.UA_Client_Subscriptions_modify(client::Ptr{UA_Client},
        request::UA_ModifySubscriptionRequest)::UA_ModifySubscriptionResponse
end

function UA_Client_Subscriptions_modify_async(
        client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_Subscriptions_modify_async(
        client::Ptr{UA_Client}, request::UA_ModifySubscriptionRequest,
        callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid},
        requestId::Ptr{UA_UInt32})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteSubscriptionsRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteSubscriptionsRequest})
    (:requestHeader, :subscriptionIdsSize, :subscriptionIds)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteSubscriptionsRequest}})
    (:requestHeader, :subscriptionIdsSize, :subscriptionIds)
end

function Base.getproperty(x::Ptr{UA_DeleteSubscriptionsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionIdsSize && return Ptr{Csize_t}(x + 112)
    f === :subscriptionIds && return Ptr{Ptr{UA_UInt32}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteSubscriptionsRequest, f::Symbol)
    r = Ref{UA_DeleteSubscriptionsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteSubscriptionsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteSubscriptionsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteSubscriptionsResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteSubscriptionsResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteSubscriptionsResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_DeleteSubscriptionsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteSubscriptionsResponse, f::Symbol)
    r = Ref{UA_DeleteSubscriptionsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteSubscriptionsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteSubscriptionsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_Subscriptions_delete(client, request)
    @ccall libopen62541.UA_Client_Subscriptions_delete(client::Ptr{UA_Client},
        request::UA_DeleteSubscriptionsRequest)::UA_DeleteSubscriptionsResponse
end

function UA_Client_Subscriptions_delete_async(
        client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_Subscriptions_delete_async(
        client::Ptr{UA_Client}, request::UA_DeleteSubscriptionsRequest,
        callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid},
        requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_Subscriptions_deleteSingle(client, subscriptionId)
    @ccall libopen62541.UA_Client_Subscriptions_deleteSingle(
        client::Ptr{UA_Client}, subscriptionId::UA_UInt32)::UA_StatusCode
end

# typedef void ( * UA_Client_DeleteMonitoredItemCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext )
const UA_Client_DeleteMonitoredItemCallback = Ptr{Cvoid}

# typedef void ( * UA_Client_DataChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , UA_DataValue * value )
const UA_Client_DataChangeNotificationCallback = Ptr{Cvoid}

# typedef void ( * UA_Client_EventNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , size_t nEventFields , UA_Variant * eventFields )
const UA_Client_EventNotificationCallback = Ptr{Cvoid}

@cenum UA_MonitoringMode::UInt32 begin
    UA_MONITORINGMODE_DISABLED = 0
    UA_MONITORINGMODE_SAMPLING = 1
    UA_MONITORINGMODE_REPORTING = 2
    __UA_MONITORINGMODE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MonitoringParameters
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_MonitoringParameters})
    (:clientHandle, :samplingInterval, :filter, :queueSize, :discardOldest)
end
function Base.fieldnames(::Type{Ptr{UA_MonitoringParameters}})
    (:clientHandle, :samplingInterval, :filter, :queueSize, :discardOldest)
end

function Base.getproperty(x::Ptr{UA_MonitoringParameters}, f::Symbol)
    f === :clientHandle && return Ptr{UA_UInt32}(x + 0)
    f === :samplingInterval && return Ptr{UA_Double}(x + 8)
    f === :filter && return Ptr{UA_ExtensionObject}(x + 16)
    f === :queueSize && return Ptr{UA_UInt32}(x + 64)
    f === :discardOldest && return Ptr{UA_Boolean}(x + 68)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MonitoringParameters, f::Symbol)
    r = Ref{UA_MonitoringParameters}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MonitoringParameters}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MonitoringParameters}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MonitoredItemCreateRequest
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_MonitoredItemCreateRequest})
    (:itemToMonitor, :monitoringMode, :requestedParameters)
end
function Base.fieldnames(::Type{Ptr{UA_MonitoredItemCreateRequest}})
    (:itemToMonitor, :monitoringMode, :requestedParameters)
end

function Base.getproperty(x::Ptr{UA_MonitoredItemCreateRequest}, f::Symbol)
    f === :itemToMonitor && return Ptr{UA_ReadValueId}(x + 0)
    f === :monitoringMode && return Ptr{UA_MonitoringMode}(x + 72)
    f === :requestedParameters && return Ptr{UA_MonitoringParameters}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MonitoredItemCreateRequest, f::Symbol)
    r = Ref{UA_MonitoredItemCreateRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MonitoredItemCreateRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MonitoredItemCreateRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CreateMonitoredItemsRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_CreateMonitoredItemsRequest})
    (:requestHeader, :subscriptionId, :timestampsToReturn,
        :itemsToCreateSize, :itemsToCreate)
end
function Base.fieldnames(::Type{Ptr{UA_CreateMonitoredItemsRequest}})
    (:requestHeader, :subscriptionId, :timestampsToReturn,
        :itemsToCreateSize, :itemsToCreate)
end

function Base.getproperty(x::Ptr{UA_CreateMonitoredItemsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :timestampsToReturn && return Ptr{UA_TimestampsToReturn}(x + 116)
    f === :itemsToCreateSize && return Ptr{Csize_t}(x + 120)
    f === :itemsToCreate && return Ptr{Ptr{UA_MonitoredItemCreateRequest}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CreateMonitoredItemsRequest, f::Symbol)
    r = Ref{UA_CreateMonitoredItemsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CreateMonitoredItemsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CreateMonitoredItemsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MonitoredItemCreateResult
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_MonitoredItemCreateResult})
    (:statusCode, :monitoredItemId, :revisedSamplingInterval,
        :revisedQueueSize, :filterResult)
end
function Base.fieldnames(::Type{Ptr{UA_MonitoredItemCreateResult}})
    (:statusCode, :monitoredItemId, :revisedSamplingInterval,
        :revisedQueueSize, :filterResult)
end

function Base.getproperty(x::Ptr{UA_MonitoredItemCreateResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :monitoredItemId && return Ptr{UA_UInt32}(x + 4)
    f === :revisedSamplingInterval && return Ptr{UA_Double}(x + 8)
    f === :revisedQueueSize && return Ptr{UA_UInt32}(x + 16)
    f === :filterResult && return Ptr{UA_ExtensionObject}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MonitoredItemCreateResult, f::Symbol)
    r = Ref{UA_MonitoredItemCreateResult}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MonitoredItemCreateResult}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MonitoredItemCreateResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CreateMonitoredItemsResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_CreateMonitoredItemsResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_CreateMonitoredItemsResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_CreateMonitoredItemsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_MonitoredItemCreateResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CreateMonitoredItemsResponse, f::Symbol)
    r = Ref{UA_CreateMonitoredItemsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CreateMonitoredItemsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CreateMonitoredItemsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_MonitoredItems_createDataChanges(
        client, request, contexts, callbacks, deleteCallbacks)
    @ccall libopen62541.UA_Client_MonitoredItems_createDataChanges(client::Ptr{UA_Client},
        request::UA_CreateMonitoredItemsRequest,
        contexts::Ptr{Ptr{Cvoid}},
        callbacks::Ptr{UA_Client_DataChangeNotificationCallback},
        deleteCallbacks::Ptr{UA_Client_DeleteMonitoredItemCallback})::UA_CreateMonitoredItemsResponse
end

function UA_Client_MonitoredItems_createDataChanges_async(
        client, request, contexts, callbacks,
        deleteCallbacks, createCallback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_createDataChanges_async(
        client::Ptr{UA_Client}, request::UA_CreateMonitoredItemsRequest,
        contexts::Ptr{Ptr{Cvoid}},
        callbacks::Ptr{UA_Client_DataChangeNotificationCallback},
        deleteCallbacks::Ptr{UA_Client_DeleteMonitoredItemCallback},
        createCallback::UA_ClientAsyncServiceCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_MonitoredItems_createDataChange(
        client, subscriptionId, timestampsToReturn, item, context, callback, deleteCallback)
    @ccall libopen62541.UA_Client_MonitoredItems_createDataChange(client::Ptr{UA_Client},
        subscriptionId::UA_UInt32,
        timestampsToReturn::UA_TimestampsToReturn,
        item::UA_MonitoredItemCreateRequest,
        context::Ptr{Cvoid},
        callback::UA_Client_DataChangeNotificationCallback,
        deleteCallback::UA_Client_DeleteMonitoredItemCallback)::UA_MonitoredItemCreateResult
end

function UA_Client_MonitoredItems_createEvents(
        client, request, contexts, callback, deleteCallback)
    @ccall libopen62541.UA_Client_MonitoredItems_createEvents(client::Ptr{UA_Client},
        request::UA_CreateMonitoredItemsRequest,
        contexts::Ptr{Ptr{Cvoid}},
        callback::Ptr{UA_Client_EventNotificationCallback},
        deleteCallback::Ptr{UA_Client_DeleteMonitoredItemCallback})::UA_CreateMonitoredItemsResponse
end

function UA_Client_MonitoredItems_createEvents_async(client, request, contexts, callbacks,
        deleteCallbacks, createCallback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_createEvents_async(
        client::Ptr{UA_Client}, request::UA_CreateMonitoredItemsRequest,
        contexts::Ptr{Ptr{Cvoid}}, callbacks::Ptr{UA_Client_EventNotificationCallback},
        deleteCallbacks::Ptr{UA_Client_DeleteMonitoredItemCallback},
        createCallback::UA_ClientAsyncServiceCallback,
        userdata::Ptr{Cvoid}, requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_MonitoredItems_createEvent(
        client, subscriptionId, timestampsToReturn, item, context, callback, deleteCallback)
    @ccall libopen62541.UA_Client_MonitoredItems_createEvent(client::Ptr{UA_Client},
        subscriptionId::UA_UInt32,
        timestampsToReturn::UA_TimestampsToReturn,
        item::UA_MonitoredItemCreateRequest,
        context::Ptr{Cvoid},
        callback::UA_Client_EventNotificationCallback,
        deleteCallback::UA_Client_DeleteMonitoredItemCallback)::UA_MonitoredItemCreateResult
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteMonitoredItemsRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteMonitoredItemsRequest})
    (:requestHeader, :subscriptionId, :monitoredItemIdsSize, :monitoredItemIds)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteMonitoredItemsRequest}})
    (:requestHeader, :subscriptionId, :monitoredItemIdsSize, :monitoredItemIds)
end

function Base.getproperty(x::Ptr{UA_DeleteMonitoredItemsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :monitoredItemIdsSize && return Ptr{Csize_t}(x + 120)
    f === :monitoredItemIds && return Ptr{Ptr{UA_UInt32}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteMonitoredItemsRequest, f::Symbol)
    r = Ref{UA_DeleteMonitoredItemsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteMonitoredItemsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteMonitoredItemsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteMonitoredItemsResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteMonitoredItemsResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteMonitoredItemsResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_DeleteMonitoredItemsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteMonitoredItemsResponse, f::Symbol)
    r = Ref{UA_DeleteMonitoredItemsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteMonitoredItemsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteMonitoredItemsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_MonitoredItems_delete(client, arg2)
    @ccall libopen62541.UA_Client_MonitoredItems_delete(client::Ptr{UA_Client},
        arg2::UA_DeleteMonitoredItemsRequest)::UA_DeleteMonitoredItemsResponse
end

function UA_Client_MonitoredItems_delete_async(
        client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_delete_async(
        client::Ptr{UA_Client}, request::UA_DeleteMonitoredItemsRequest,
        callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid},
        requestId::Ptr{UA_UInt32})::UA_StatusCode
end

function UA_Client_MonitoredItems_deleteSingle(client, subscriptionId, monitoredItemId)
    @ccall libopen62541.UA_Client_MonitoredItems_deleteSingle(
        client::Ptr{UA_Client}, subscriptionId::UA_UInt32,
        monitoredItemId::UA_UInt32)::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MonitoredItemModifyRequest
    data::NTuple{80, UInt8}
end

function Base.fieldnames(::Type{UA_MonitoredItemModifyRequest})
    (:monitoredItemId, :requestedParameters)
end
function Base.fieldnames(::Type{Ptr{UA_MonitoredItemModifyRequest}})
    (:monitoredItemId, :requestedParameters)
end

function Base.getproperty(x::Ptr{UA_MonitoredItemModifyRequest}, f::Symbol)
    f === :monitoredItemId && return Ptr{UA_UInt32}(x + 0)
    f === :requestedParameters && return Ptr{UA_MonitoringParameters}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MonitoredItemModifyRequest, f::Symbol)
    r = Ref{UA_MonitoredItemModifyRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MonitoredItemModifyRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MonitoredItemModifyRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ModifyMonitoredItemsRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_ModifyMonitoredItemsRequest})
    (:requestHeader, :subscriptionId, :timestampsToReturn,
        :itemsToModifySize, :itemsToModify)
end
function Base.fieldnames(::Type{Ptr{UA_ModifyMonitoredItemsRequest}})
    (:requestHeader, :subscriptionId, :timestampsToReturn,
        :itemsToModifySize, :itemsToModify)
end

function Base.getproperty(x::Ptr{UA_ModifyMonitoredItemsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :timestampsToReturn && return Ptr{UA_TimestampsToReturn}(x + 116)
    f === :itemsToModifySize && return Ptr{Csize_t}(x + 120)
    f === :itemsToModify && return Ptr{Ptr{UA_MonitoredItemModifyRequest}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ModifyMonitoredItemsRequest, f::Symbol)
    r = Ref{UA_ModifyMonitoredItemsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ModifyMonitoredItemsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ModifyMonitoredItemsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MonitoredItemModifyResult
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_MonitoredItemModifyResult})
    (:statusCode, :revisedSamplingInterval, :revisedQueueSize, :filterResult)
end
function Base.fieldnames(::Type{Ptr{UA_MonitoredItemModifyResult}})
    (:statusCode, :revisedSamplingInterval, :revisedQueueSize, :filterResult)
end

function Base.getproperty(x::Ptr{UA_MonitoredItemModifyResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :revisedSamplingInterval && return Ptr{UA_Double}(x + 8)
    f === :revisedQueueSize && return Ptr{UA_UInt32}(x + 16)
    f === :filterResult && return Ptr{UA_ExtensionObject}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MonitoredItemModifyResult, f::Symbol)
    r = Ref{UA_MonitoredItemModifyResult}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MonitoredItemModifyResult}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MonitoredItemModifyResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ModifyMonitoredItemsResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_ModifyMonitoredItemsResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_ModifyMonitoredItemsResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_ModifyMonitoredItemsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_MonitoredItemModifyResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ModifyMonitoredItemsResponse, f::Symbol)
    r = Ref{UA_ModifyMonitoredItemsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ModifyMonitoredItemsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ModifyMonitoredItemsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Client_MonitoredItems_modify(client, request)
    @ccall libopen62541.UA_Client_MonitoredItems_modify(client::Ptr{UA_Client},
        request::UA_ModifyMonitoredItemsRequest)::UA_ModifyMonitoredItemsResponse
end

function UA_Client_MonitoredItems_modify_async(
        client, request, callback, userdata, requestId)
    @ccall libopen62541.UA_Client_MonitoredItems_modify_async(
        client::Ptr{UA_Client}, request::UA_ModifyMonitoredItemsRequest,
        callback::UA_ClientAsyncServiceCallback, userdata::Ptr{Cvoid},
        requestId::Ptr{UA_UInt32})::UA_StatusCode
end

@cenum UA_RuleHandling::UInt32 begin
    UA_RULEHANDLING_DEFAULT = 0
    UA_RULEHANDLING_ABORT = 1
    UA_RULEHANDLING_WARN = 2
    UA_RULEHANDLING_ACCEPT = 3
end

@cenum UA_Order::Int32 begin
    UA_ORDER_LESS = -1
    UA_ORDER_EQ = 0
    UA_ORDER_MORE = 1
end

@cenum UA_ConnectionState::UInt32 begin
    UA_CONNECTIONSTATE_CLOSED = 0
    UA_CONNECTIONSTATE_OPENING = 1
    UA_CONNECTIONSTATE_ESTABLISHED = 2
    UA_CONNECTIONSTATE_CLOSING = 3
end

@cenum UA_ShutdownReason::UInt32 begin
    UA_SHUTDOWNREASON_CLOSE = 0
    UA_SHUTDOWNREASON_REJECT = 1
    UA_SHUTDOWNREASON_SECURITYREJECT = 2
    UA_SHUTDOWNREASON_TIMEOUT = 3
    UA_SHUTDOWNREASON_ABORT = 4
    UA_SHUTDOWNREASON_PURGE = 5
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecureChannelStatistics
    currentChannelCount::Csize_t
    cumulatedChannelCount::Csize_t
    rejectedChannelCount::Csize_t
    channelTimeoutCount::Csize_t
    channelAbortCount::Csize_t
    channelPurgeCount::Csize_t
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SessionStatistics
    currentSessionCount::Csize_t
    cumulatedSessionCount::Csize_t
    securityRejectedSessionCount::Csize_t
    rejectedSessionCount::Csize_t
    sessionTimeoutCount::Csize_t
    sessionAbortCount::Csize_t
end

@cenum UA_LifecycleState::UInt32 begin
    UA_LIFECYCLESTATE_STOPPED = 0
    UA_LIFECYCLESTATE_STARTED = 1
    UA_LIFECYCLESTATE_STOPPING = 2
end

mutable struct UA_Server end

# typedef void ( * UA_ServerCallback ) ( UA_Server * server , void * data )
const UA_ServerCallback = Ptr{Cvoid}

function UA_Server_removeCallback(server, callbackId)
    @ccall libopen62541.UA_Server_removeCallback(
        server::Ptr{UA_Server}, callbackId::UA_UInt64)::Cvoid
end

# typedef UA_StatusCode ( * UA_MethodCallback ) ( UA_Server * server , const UA_NodeId * sessionId , void * sessionContext , const UA_NodeId * methodId , void * methodContext , const UA_NodeId * objectId , void * objectContext , size_t inputSize , const UA_Variant * input , size_t outputSize , UA_Variant * output )
const UA_MethodCallback = Ptr{Cvoid}

function UA_Server_setMethodNodeCallback(server, methodNodeId, methodCallback)
    @ccall libopen62541.UA_Server_setMethodNodeCallback(
        server::Ptr{UA_Server}, methodNodeId::UA_NodeId,
        methodCallback::UA_MethodCallback)::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConfiguration
    stateChangeCallback::Ptr{Cvoid}
    enableDeltaFrames::UA_Boolean
    enableInformationModelMethods::UA_Boolean
end

# typedef void ( * UA_Server_AsyncOperationNotifyCallback ) ( UA_Server * server )
const UA_Server_AsyncOperationNotifyCallback = Ptr{Cvoid}

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BuildInfo
    productUri::UA_String
    manufacturerName::UA_String
    productName::UA_String
    softwareVersion::UA_String
    buildNumber::UA_String
    buildDate::UA_DateTime
end
function Base.getproperty(x::Ptr{UA_BuildInfo}, f::Symbol)
    f === :productUri && return Ptr{UA_String}(x + 0)
    f === :manufacturerName && return Ptr{UA_String}(x + 16)
    f === :productName && return Ptr{UA_String}(x + 32)
    f === :softwareVersion && return Ptr{UA_String}(x + 48)
    f === :buildNumber && return Ptr{UA_String}(x + 64)
    f === :buildDate && return Ptr{UA_DateTime}(x + 80)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_BuildInfo}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
    allowHistoryUpdateUpdateData::Ptr{Cvoid}
    allowHistoryUpdateDeleteRawModified::Ptr{Cvoid}
end
function Base.getproperty(x::Ptr{UA_AccessControl}, f::Symbol)
    f === :context && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :clear && return Ptr{Ptr{Cvoid}}(x + 8)
    f === :userTokenPoliciesSize && return Ptr{Csize_t}(x + 16)
    f === :userTokenPolicies && return Ptr{Ptr{UA_UserTokenPolicy}}(x + 24)
    f === :activateSession && return Ptr{Ptr{Cvoid}}(x + 32)
    f === :closeSession && return Ptr{Ptr{Cvoid}}(x + 40)
    f === :getUserRightsMask && return Ptr{Ptr{Cvoid}}(x + 48)
    f === :getUserAccessLevel && return Ptr{Ptr{Cvoid}}(x + 56)
    f === :getUserExecutable && return Ptr{Ptr{Cvoid}}(x + 64)
    f === :getUserExecutableOnObject && return Ptr{Ptr{Cvoid}}(x + 72)
    f === :allowAddNode && return Ptr{Ptr{Cvoid}}(x + 80)
    f === :allowAddReference && return Ptr{Ptr{Cvoid}}(x + 88)
    f === :allowDeleteNode && return Ptr{Ptr{Cvoid}}(x + 96)
    f === :allowDeleteReference && return Ptr{Ptr{Cvoid}}(x + 104)
    f === :allowBrowseNode && return Ptr{Ptr{Cvoid}}(x + 112)
    f === :allowTransferSubscription && return Ptr{Ptr{Cvoid}}(x + 120)
    f === :allowHistoryUpdateUpdateData && return Ptr{Ptr{Cvoid}}(x + 128)
    f === :allowHistoryUpdateDeleteRawModified && return Ptr{Ptr{Cvoid}}(x + 136)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_AccessControl}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_Nodestore
    context::Ptr{Cvoid}
    clear::Ptr{Cvoid}
    newNode::Ptr{Cvoid}
    deleteNode::Ptr{Cvoid}
    getNode::Ptr{Cvoid}
    getNodeFromPtr::Ptr{Cvoid}
    releaseNode::Ptr{Cvoid}
    getNodeCopy::Ptr{Cvoid}
    insertNode::Ptr{Cvoid}
    replaceNode::Ptr{Cvoid}
    removeNode::Ptr{Cvoid}
    getReferenceTypeId::Ptr{Cvoid}
    iterate::Ptr{Cvoid}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_GlobalNodeLifecycle
    constructor::Ptr{Cvoid}
    destructor::Ptr{Cvoid}
    createOptionalChild::Ptr{Cvoid}
    generateChildNodeId::Ptr{Cvoid}
end
const UA_Duration = UA_Double

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DurationRange
    min::UA_Duration
    max::UA_Duration
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UInt32Range
    min::UA_UInt32
    max::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryDatabase
    context::Ptr{Cvoid}
    clear::Ptr{Cvoid}
    setValue::Ptr{Cvoid}
    setEvent::Ptr{Cvoid}
    readRaw::Ptr{Cvoid}
    readModified::Ptr{Cvoid}
    readEvent::Ptr{Cvoid}
    readProcessed::Ptr{Cvoid}
    readAtTime::Ptr{Cvoid}
    updateData::Ptr{Cvoid}
    deleteRawModified::Ptr{Cvoid}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ServerConfig
    context::Ptr{Cvoid}
    logging::Ptr{UA_Logger}
    buildInfo::UA_BuildInfo
    applicationDescription::UA_ApplicationDescription
    shutdownDelay::UA_Double
    notifyLifecycleState::Ptr{Cvoid}
    verifyRequestTimestamp::UA_RuleHandling
    allowEmptyVariables::UA_RuleHandling
    customDataTypes::Ptr{UA_DataTypeArray}
    eventLoop::Ptr{UA_EventLoop}
    externalEventLoop::UA_Boolean
    serverUrls::Ptr{UA_String}
    serverUrlsSize::Csize_t
    tcpEnabled::UA_Boolean
    tcpBufSize::UA_UInt32
    tcpMaxMsgSize::UA_UInt32
    tcpMaxChunks::UA_UInt32
    tcpReuseAddr::UA_Boolean
    securityPoliciesSize::Csize_t
    securityPolicies::Ptr{UA_SecurityPolicy}
    endpointsSize::Csize_t
    endpoints::Ptr{UA_EndpointDescription}
    securityPolicyNoneDiscoveryOnly::UA_Boolean
    allowNonePolicyPassword::UA_Boolean
    secureChannelPKI::UA_CertificateVerification
    sessionPKI::UA_CertificateVerification
    accessControl::UA_AccessControl
    nodestore::UA_Nodestore
    nodeLifecycle::UA_GlobalNodeLifecycle
    modellingRulesOnInstances::UA_Boolean
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
    asyncOperationTimeout::UA_Double
    maxAsyncOperationQueueSize::Csize_t
    asyncOperationNotifyCallback::UA_Server_AsyncOperationNotifyCallback
    discoveryCleanupTimeout::UA_UInt32
    subscriptionsEnabled::UA_Boolean
    maxSubscriptions::UA_UInt32
    maxSubscriptionsPerSession::UA_UInt32
    publishingIntervalLimits::UA_DurationRange
    lifeTimeCountLimits::UA_UInt32Range
    keepAliveCountLimits::UA_UInt32Range
    maxNotificationsPerPublish::UA_UInt32
    enableRetransmissionQueue::UA_Boolean
    maxRetransmissionQueueSize::UA_UInt32
    maxEventsPerNode::UA_UInt32
    maxMonitoredItems::UA_UInt32
    maxMonitoredItemsPerSubscription::UA_UInt32
    samplingIntervalLimits::UA_DurationRange
    queueSizeLimits::UA_UInt32Range
    maxPublishReqPerSession::UA_UInt32
    monitoredItemRegisterCallback::Ptr{Cvoid}
    pubsubEnabled::UA_Boolean
    pubSubConfig::UA_PubSubConfiguration
    historizingEnabled::UA_Boolean
    historyDatabase::UA_HistoryDatabase
    accessHistoryDataCapability::UA_Boolean
    maxReturnDataValues::UA_UInt32
    accessHistoryEventsCapability::UA_Boolean
    maxReturnEventValues::UA_UInt32
    insertDataCapability::UA_Boolean
    insertEventCapability::UA_Boolean
    insertAnnotationsCapability::UA_Boolean
    replaceDataCapability::UA_Boolean
    replaceEventCapability::UA_Boolean
    updateDataCapability::UA_Boolean
    updateEventCapability::UA_Boolean
    deleteRawCapability::UA_Boolean
    deleteEventCapability::UA_Boolean
    deleteAtTimeDataCapability::UA_Boolean
    reverseReconnectInterval::UA_UInt32
    privateKeyPasswordCallback::Ptr{Cvoid}
end
function Base.getproperty(x::Ptr{UA_ServerConfig}, f::Symbol)
    f === :context && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :logging && return Ptr{Ptr{UA_Logger}}(x + 8)
    f === :buildInfo && return Ptr{UA_BuildInfo}(x + 16)
    f === :applicationDescription && return Ptr{UA_ApplicationDescription}(x + 104)
    f === :shutdownDelay && return Ptr{UA_Double}(x + 224)
    f === :notifyLifecycleState && return Ptr{Ptr{Cvoid}}(x + 232)
    f === :verifyRequestTimestamp && return Ptr{UA_RuleHandling}(x + 240)
    f === :allowEmptyVariables && return Ptr{UA_RuleHandling}(x + 244)
    f === :customDataTypes && return Ptr{Ptr{UA_DataTypeArray}}(x + 248)
    f === :eventLoop && return Ptr{Ptr{UA_EventLoop}}(x + 256)
    f === :externalEventLoop && return Ptr{UA_Boolean}(x + 264)
    f === :serverUrls && return Ptr{Ptr{UA_String}}(x + 272)
    f === :serverUrlsSize && return Ptr{Csize_t}(x + 280)
    f === :tcpEnabled && return Ptr{UA_Boolean}(x + 288)
    f === :tcpBufSize && return Ptr{UA_UInt32}(x + 292)
    f === :tcpMaxMsgSize && return Ptr{UA_UInt32}(x + 296)
    f === :tcpMaxChunks && return Ptr{UA_UInt32}(x + 300)
    f === :tcpReuseAddr && return Ptr{UA_Boolean}(x + 304)
    f === :securityPoliciesSize && return Ptr{Csize_t}(x + 312)
    f === :securityPolicies && return Ptr{Ptr{UA_SecurityPolicy}}(x + 320)
    f === :endpointsSize && return Ptr{Csize_t}(x + 328)
    f === :endpoints && return Ptr{Ptr{UA_EndpointDescription}}(x + 336)
    f === :securityPolicyNoneDiscoveryOnly && return Ptr{UA_Boolean}(x + 344)
    f === :allowNonePolicyPassword && return Ptr{UA_Boolean}(x + 345)
    f === :secureChannelPKI && return Ptr{UA_CertificateVerification}(x + 352)
    f === :sessionPKI && return Ptr{UA_CertificateVerification}(x + 408)
    f === :accessControl && return Ptr{UA_AccessControl}(x + 464)
    f === :nodestore && return Ptr{UA_Nodestore}(x + 608)
    f === :nodeLifecycle && return Ptr{UA_GlobalNodeLifecycle}(x + 712)
    f === :modellingRulesOnInstances && return Ptr{UA_Boolean}(x + 744)
    f === :maxSecureChannels && return Ptr{UA_UInt16}(x + 746)
    f === :maxSecurityTokenLifetime && return Ptr{UA_UInt32}(x + 748)
    f === :maxSessions && return Ptr{UA_UInt16}(x + 752)
    f === :maxSessionTimeout && return Ptr{UA_Double}(x + 760)
    f === :maxNodesPerRead && return Ptr{UA_UInt32}(x + 768)
    f === :maxNodesPerWrite && return Ptr{UA_UInt32}(x + 772)
    f === :maxNodesPerMethodCall && return Ptr{UA_UInt32}(x + 776)
    f === :maxNodesPerBrowse && return Ptr{UA_UInt32}(x + 780)
    f === :maxNodesPerRegisterNodes && return Ptr{UA_UInt32}(x + 784)
    f === :maxNodesPerTranslateBrowsePathsToNodeIds && return Ptr{UA_UInt32}(x + 788)
    f === :maxNodesPerNodeManagement && return Ptr{UA_UInt32}(x + 792)
    f === :maxMonitoredItemsPerCall && return Ptr{UA_UInt32}(x + 796)
    f === :maxReferencesPerNode && return Ptr{UA_UInt32}(x + 800)
    f === :asyncOperationTimeout && return Ptr{UA_Double}(x + 808)
    f === :maxAsyncOperationQueueSize && return Ptr{Csize_t}(x + 816)
    f === :asyncOperationNotifyCallback &&
        return Ptr{UA_Server_AsyncOperationNotifyCallback}(x + 824)
    f === :discoveryCleanupTimeout && return Ptr{UA_UInt32}(x + 832)
    f === :subscriptionsEnabled && return Ptr{UA_Boolean}(x + 836)
    f === :maxSubscriptions && return Ptr{UA_UInt32}(x + 840)
    f === :maxSubscriptionsPerSession && return Ptr{UA_UInt32}(x + 844)
    f === :publishingIntervalLimits && return Ptr{UA_DurationRange}(x + 848)
    f === :lifeTimeCountLimits && return Ptr{UA_UInt32Range}(x + 864)
    f === :keepAliveCountLimits && return Ptr{UA_UInt32Range}(x + 872)
    f === :maxNotificationsPerPublish && return Ptr{UA_UInt32}(x + 880)
    f === :enableRetransmissionQueue && return Ptr{UA_Boolean}(x + 884)
    f === :maxRetransmissionQueueSize && return Ptr{UA_UInt32}(x + 888)
    f === :maxEventsPerNode && return Ptr{UA_UInt32}(x + 892)
    f === :maxMonitoredItems && return Ptr{UA_UInt32}(x + 896)
    f === :maxMonitoredItemsPerSubscription && return Ptr{UA_UInt32}(x + 900)
    f === :samplingIntervalLimits && return Ptr{UA_DurationRange}(x + 904)
    f === :queueSizeLimits && return Ptr{UA_UInt32Range}(x + 920)
    f === :maxPublishReqPerSession && return Ptr{UA_UInt32}(x + 928)
    f === :monitoredItemRegisterCallback && return Ptr{Ptr{Cvoid}}(x + 936)
    f === :pubsubEnabled && return Ptr{UA_Boolean}(x + 944)
    f === :pubSubConfig && return Ptr{UA_PubSubConfiguration}(x + 952)
    f === :historizingEnabled && return Ptr{UA_Boolean}(x + 968)
    f === :historyDatabase && return Ptr{UA_HistoryDatabase}(x + 976)
    f === :accessHistoryDataCapability && return Ptr{UA_Boolean}(x + 1064)
    f === :maxReturnDataValues && return Ptr{UA_UInt32}(x + 1068)
    f === :accessHistoryEventsCapability && return Ptr{UA_Boolean}(x + 1072)
    f === :maxReturnEventValues && return Ptr{UA_UInt32}(x + 1076)
    f === :insertDataCapability && return Ptr{UA_Boolean}(x + 1080)
    f === :insertEventCapability && return Ptr{UA_Boolean}(x + 1081)
    f === :insertAnnotationsCapability && return Ptr{UA_Boolean}(x + 1082)
    f === :replaceDataCapability && return Ptr{UA_Boolean}(x + 1083)
    f === :replaceEventCapability && return Ptr{UA_Boolean}(x + 1084)
    f === :updateDataCapability && return Ptr{UA_Boolean}(x + 1085)
    f === :updateEventCapability && return Ptr{UA_Boolean}(x + 1086)
    f === :deleteRawCapability && return Ptr{UA_Boolean}(x + 1087)
    f === :deleteEventCapability && return Ptr{UA_Boolean}(x + 1088)
    f === :deleteAtTimeDataCapability && return Ptr{UA_Boolean}(x + 1089)
    f === :reverseReconnectInterval && return Ptr{UA_UInt32}(x + 1092)
    f === :privateKeyPasswordCallback && return Ptr{Ptr{Cvoid}}(x + 1096)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ServerConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_ServerConfig_clean(config)
    @ccall libopen62541.UA_ServerConfig_clean(config::Ptr{UA_ServerConfig})::Cvoid
end

function UA_Server_new()
    @ccall libopen62541.UA_Server_new()::Ptr{UA_Server}
end

function UA_Server_newWithConfig(config)
    @ccall libopen62541.UA_Server_newWithConfig(config::Ptr{UA_ServerConfig})::Ptr{UA_Server}
end

function UA_Server_delete(server)
    @ccall libopen62541.UA_Server_delete(server::Ptr{UA_Server})::UA_StatusCode
end

function UA_Server_getConfig(server)
    @ccall libopen62541.UA_Server_getConfig(server::Ptr{UA_Server})::Ptr{UA_ServerConfig}
end

function UA_Server_getLifecycleState(server)
    @ccall libopen62541.UA_Server_getLifecycleState(server::Ptr{UA_Server})::UA_LifecycleState
end

function UA_Server_run(server, running)
    @ccall libopen62541.UA_Server_run(
        server::Ptr{UA_Server}, running::Ptr{UA_Boolean})::UA_StatusCode
end

function UA_Server_runUntilInterrupt(server)
    @ccall libopen62541.UA_Server_runUntilInterrupt(server::Ptr{UA_Server})::UA_StatusCode
end

function UA_Server_run_startup(server)
    @ccall libopen62541.UA_Server_run_startup(server::Ptr{UA_Server})::UA_StatusCode
end

function UA_Server_run_iterate(server, waitInternal)
    @ccall libopen62541.UA_Server_run_iterate(
        server::Ptr{UA_Server}, waitInternal::UA_Boolean)::UA_UInt16
end

function UA_Server_run_shutdown(server)
    @ccall libopen62541.UA_Server_run_shutdown(server::Ptr{UA_Server})::UA_StatusCode
end

function UA_Server_addTimedCallback(server, callback, data, date, callbackId)
    @ccall libopen62541.UA_Server_addTimedCallback(
        server::Ptr{UA_Server}, callback::UA_ServerCallback, data::Ptr{Cvoid},
        date::UA_DateTime, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Server_addRepeatedCallback(server, callback, data, interval_ms, callbackId)
    @ccall libopen62541.UA_Server_addRepeatedCallback(
        server::Ptr{UA_Server}, callback::UA_ServerCallback, data::Ptr{Cvoid},
        interval_ms::UA_Double, callbackId::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Server_changeRepeatedCallbackInterval(server, callbackId, interval_ms)
    @ccall libopen62541.UA_Server_changeRepeatedCallbackInterval(
        server::Ptr{UA_Server}, callbackId::UA_UInt64,
        interval_ms::UA_Double)::UA_StatusCode
end

function UA_Server_closeSession(server, sessionId)
    @ccall libopen62541.UA_Server_closeSession(
        server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_getSessionAttribute(server, sessionId, key, outValue)
    @ccall libopen62541.UA_Server_getSessionAttribute(
        server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId},
        key::UA_QualifiedName, outValue::Ptr{UA_Variant})::UA_StatusCode
end

function UA_Server_getSessionAttributeCopy(server, sessionId, key, outValue)
    @ccall libopen62541.UA_Server_getSessionAttributeCopy(
        server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId},
        key::UA_QualifiedName, outValue::Ptr{UA_Variant})::UA_StatusCode
end

function UA_Server_getSessionAttribute_scalar(server, sessionId, key, type, outValue)
    @ccall libopen62541.UA_Server_getSessionAttribute_scalar(
        server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId}, key::UA_QualifiedName,
        type::Ptr{UA_DataType}, outValue::Ptr{Cvoid})::UA_StatusCode
end

function UA_Server_setSessionAttribute(server, sessionId, key, value)
    @ccall libopen62541.UA_Server_setSessionAttribute(
        server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId},
        key::UA_QualifiedName, value::Ptr{UA_Variant})::UA_StatusCode
end

function UA_Server_deleteSessionAttribute(server, sessionId, key)
    @ccall libopen62541.UA_Server_deleteSessionAttribute(
        server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId},
        key::UA_QualifiedName)::UA_StatusCode
end

function UA_Server_read(server, item, timestamps)
    @ccall libopen62541.UA_Server_read(server::Ptr{UA_Server}, item::Ptr{UA_ReadValueId},
        timestamps::UA_TimestampsToReturn)::UA_DataValue
end

function __UA_Server_read(server, nodeId, attributeId, v)
    @ccall libopen62541.__UA_Server_read(server::Ptr{UA_Server}, nodeId::Ptr{UA_NodeId},
        attributeId::UA_AttributeId, v::Ptr{Cvoid})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_WriteValue
    data::NTuple{128, UInt8}
end

Base.fieldnames(::Type{UA_WriteValue}) = (:nodeId, :attributeId, :indexRange, :value)
Base.fieldnames(::Type{Ptr{UA_WriteValue}}) = (:nodeId, :attributeId, :indexRange, :value)

function Base.getproperty(x::Ptr{UA_WriteValue}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :attributeId && return Ptr{UA_UInt32}(x + 24)
    f === :indexRange && return Ptr{UA_String}(x + 32)
    f === :value && return Ptr{UA_DataValue}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_WriteValue, f::Symbol)
    r = Ref{UA_WriteValue}(x)
    ptr = Base.unsafe_convert(Ptr{UA_WriteValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_WriteValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_write(server, value)
    @ccall libopen62541.UA_Server_write(
        server::Ptr{UA_Server}, value::Ptr{UA_WriteValue})::UA_StatusCode
end

function __UA_Server_write(server, nodeId, attributeId, attr_type, attr)
    @ccall libopen62541.__UA_Server_write(
        server::Ptr{UA_Server}, nodeId::Ptr{UA_NodeId}, attributeId::UA_AttributeId,
        attr_type::Ptr{UA_DataType}, attr::Ptr{Cvoid})::UA_StatusCode
end

@cenum UA_BrowseDirection::UInt32 begin
    UA_BROWSEDIRECTION_FORWARD = 0
    UA_BROWSEDIRECTION_INVERSE = 1
    UA_BROWSEDIRECTION_BOTH = 2
    UA_BROWSEDIRECTION_INVALID = 3
    __UA_BROWSEDIRECTION_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowseDescription
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_BrowseDescription})
    (:nodeId, :browseDirection, :referenceTypeId,
        :includeSubtypes, :nodeClassMask, :resultMask)
end
function Base.fieldnames(::Type{Ptr{UA_BrowseDescription}})
    (:nodeId, :browseDirection, :referenceTypeId,
        :includeSubtypes, :nodeClassMask, :resultMask)
end

function Base.getproperty(x::Ptr{UA_BrowseDescription}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :browseDirection && return Ptr{UA_BrowseDirection}(x + 24)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 32)
    f === :includeSubtypes && return Ptr{UA_Boolean}(x + 56)
    f === :nodeClassMask && return Ptr{UA_UInt32}(x + 60)
    f === :resultMask && return Ptr{UA_UInt32}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowseDescription, f::Symbol)
    r = Ref{UA_BrowseDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowseDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowseDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReferenceDescription
    data::NTuple{192, UInt8}
end

function Base.fieldnames(::Type{UA_ReferenceDescription})
    (:referenceTypeId, :isForward, :nodeId, :browseName,
        :displayName, :nodeClass, :typeDefinition)
end
function Base.fieldnames(::Type{Ptr{UA_ReferenceDescription}})
    (:referenceTypeId, :isForward, :nodeId, :browseName,
        :displayName, :nodeClass, :typeDefinition)
end

function Base.getproperty(x::Ptr{UA_ReferenceDescription}, f::Symbol)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :isForward && return Ptr{UA_Boolean}(x + 24)
    f === :nodeId && return Ptr{UA_ExpandedNodeId}(x + 32)
    f === :browseName && return Ptr{UA_QualifiedName}(x + 80)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 104)
    f === :nodeClass && return Ptr{UA_NodeClass}(x + 136)
    f === :typeDefinition && return Ptr{UA_ExpandedNodeId}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReferenceDescription, f::Symbol)
    r = Ref{UA_ReferenceDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReferenceDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReferenceDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowseResult
    statusCode::UA_StatusCode
    continuationPoint::UA_ByteString
    referencesSize::Csize_t
    references::Ptr{UA_ReferenceDescription}
end
function Base.getproperty(x::Ptr{UA_BrowseResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :continuationPoint && return Ptr{UA_ByteString}(x + 8)
    f === :referencesSize && return Ptr{Csize_t}(x + 24)
    f === :references && return Ptr{Ptr{UA_ReferenceDescription}}(x + 32)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_BrowseResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_browse(server, maxReferences, bd)
    @ccall libopen62541.UA_Server_browse(server::Ptr{UA_Server}, maxReferences::UA_UInt32,
        bd::Ptr{UA_BrowseDescription})::UA_BrowseResult
end

function UA_Server_browseNext(server, releaseContinuationPoint, continuationPoint)
    @ccall libopen62541.UA_Server_browseNext(
        server::Ptr{UA_Server}, releaseContinuationPoint::UA_Boolean,
        continuationPoint::Ptr{UA_ByteString})::UA_BrowseResult
end

function UA_Server_browseRecursive(server, bd, resultsSize, results)
    @ccall libopen62541.UA_Server_browseRecursive(
        server::Ptr{UA_Server}, bd::Ptr{UA_BrowseDescription},
        resultsSize::Ptr{Csize_t}, results::Ptr{Ptr{UA_ExpandedNodeId}})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RelativePathElement
    data::NTuple{56, UInt8}
end

function Base.fieldnames(::Type{UA_RelativePathElement})
    (:referenceTypeId, :isInverse, :includeSubtypes, :targetName)
end
function Base.fieldnames(::Type{Ptr{UA_RelativePathElement}})
    (:referenceTypeId, :isInverse, :includeSubtypes, :targetName)
end

function Base.getproperty(x::Ptr{UA_RelativePathElement}, f::Symbol)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :isInverse && return Ptr{UA_Boolean}(x + 24)
    f === :includeSubtypes && return Ptr{UA_Boolean}(x + 25)
    f === :targetName && return Ptr{UA_QualifiedName}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RelativePathElement, f::Symbol)
    r = Ref{UA_RelativePathElement}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RelativePathElement}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RelativePathElement}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RelativePath
    elementsSize::Csize_t
    elements::Ptr{UA_RelativePathElement}
end
function Base.getproperty(x::Ptr{UA_RelativePath}, f::Symbol)
    f === :elementsSize && return Ptr{Csize_t}(x + 0)
    f === :elements && return Ptr{Ptr{UA_RelativePathElement}}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_RelativePath}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowsePath
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{UA_BrowsePath}) = (:startingNode, :relativePath)
Base.fieldnames(::Type{Ptr{UA_BrowsePath}}) = (:startingNode, :relativePath)

function Base.getproperty(x::Ptr{UA_BrowsePath}, f::Symbol)
    f === :startingNode && return Ptr{UA_NodeId}(x + 0)
    f === :relativePath && return Ptr{UA_RelativePath}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowsePath, f::Symbol)
    r = Ref{UA_BrowsePath}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowsePath}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowsePath}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowsePathTarget
    data::NTuple{56, UInt8}
end

Base.fieldnames(::Type{UA_BrowsePathTarget}) = (:targetId, :remainingPathIndex)
Base.fieldnames(::Type{Ptr{UA_BrowsePathTarget}}) = (:targetId, :remainingPathIndex)

function Base.getproperty(x::Ptr{UA_BrowsePathTarget}, f::Symbol)
    f === :targetId && return Ptr{UA_ExpandedNodeId}(x + 0)
    f === :remainingPathIndex && return Ptr{UA_UInt32}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowsePathTarget, f::Symbol)
    r = Ref{UA_BrowsePathTarget}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowsePathTarget}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowsePathTarget}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowsePathResult
    statusCode::UA_StatusCode
    targetsSize::Csize_t
    targets::Ptr{UA_BrowsePathTarget}
end
function Base.getproperty(x::Ptr{UA_BrowsePathResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :targetsSize && return Ptr{Csize_t}(x + 8)
    f === :targets && return Ptr{Ptr{UA_BrowsePathTarget}}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_BrowsePathResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_translateBrowsePathToNodeIds(server, browsePath)
    @ccall libopen62541.UA_Server_translateBrowsePathToNodeIds(
        server::Ptr{UA_Server}, browsePath::Ptr{UA_BrowsePath})::UA_BrowsePathResult
end

function UA_Server_browseSimplifiedBrowsePath(server, origin, browsePathSize, browsePath)
    @ccall libopen62541.UA_Server_browseSimplifiedBrowsePath(
        server::Ptr{UA_Server}, origin::UA_NodeId, browsePathSize::Csize_t,
        browsePath::Ptr{UA_QualifiedName})::UA_BrowsePathResult
end

function UA_Server_forEachChildNodeCall(server, parentNodeId, callback, handle)
    @ccall libopen62541.UA_Server_forEachChildNodeCall(
        server::Ptr{UA_Server}, parentNodeId::UA_NodeId,
        callback::UA_NodeIteratorCallback, handle::Ptr{Cvoid})::UA_StatusCode
end

function UA_Server_registerDiscovery(server, cc, discoveryServerUrl, semaphoreFilePath)
    @ccall libopen62541.UA_Server_registerDiscovery(
        server::Ptr{UA_Server}, cc::Ptr{UA_ClientConfig},
        discoveryServerUrl::UA_String, semaphoreFilePath::UA_String)::UA_StatusCode
end

function UA_Server_deregisterDiscovery(server, cc, discoveryServerUrl)
    @ccall libopen62541.UA_Server_deregisterDiscovery(
        server::Ptr{UA_Server}, cc::Ptr{UA_ClientConfig},
        discoveryServerUrl::UA_String)::UA_StatusCode
end

# typedef void ( * UA_Server_registerServerCallback ) ( const UA_RegisteredServer * registeredServer , void * data )
const UA_Server_registerServerCallback = Ptr{Cvoid}

function UA_Server_setRegisterServerCallback(server, cb, data)
    @ccall libopen62541.UA_Server_setRegisterServerCallback(
        server::Ptr{UA_Server}, cb::UA_Server_registerServerCallback,
        data::Ptr{Cvoid})::Cvoid
end

function UA_Server_setAdminSessionContext(server, context)
    @ccall libopen62541.UA_Server_setAdminSessionContext(
        server::Ptr{UA_Server}, context::Ptr{Cvoid})::Cvoid
end

struct UA_NodeTypeLifecycle
    constructor::Ptr{Cvoid}
    destructor::Ptr{Cvoid}
end

function UA_Server_setNodeTypeLifecycle(server, nodeId, lifecycle)
    @ccall libopen62541.UA_Server_setNodeTypeLifecycle(
        server::Ptr{UA_Server}, nodeId::UA_NodeId,
        lifecycle::UA_NodeTypeLifecycle)::UA_StatusCode
end

function UA_Server_getNodeContext(server, nodeId, nodeContext)
    @ccall libopen62541.UA_Server_getNodeContext(server::Ptr{UA_Server}, nodeId::UA_NodeId,
        nodeContext::Ptr{Ptr{Cvoid}})::UA_StatusCode
end

function UA_Server_setNodeContext(server, nodeId, nodeContext)
    @ccall libopen62541.UA_Server_setNodeContext(
        server::Ptr{UA_Server}, nodeId::UA_NodeId, nodeContext::Ptr{Cvoid})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSource
    read::Ptr{Cvoid}
    write::Ptr{Cvoid}
end

function UA_Server_setVariableNode_dataSource(server, nodeId, dataSource)
    @ccall libopen62541.UA_Server_setVariableNode_dataSource(
        server::Ptr{UA_Server}, nodeId::UA_NodeId, dataSource::UA_DataSource)::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ValueCallback
    onRead::Ptr{Cvoid}
    onWrite::Ptr{Cvoid}
end

function UA_Server_setVariableNode_valueCallback(server, nodeId, callback)
    @ccall libopen62541.UA_Server_setVariableNode_valueCallback(
        server::Ptr{UA_Server}, nodeId::UA_NodeId,
        callback::UA_ValueCallback)::UA_StatusCode
end

@cenum UA_ValueBackendType::UInt32 begin
    UA_VALUEBACKENDTYPE_NONE = 0
    UA_VALUEBACKENDTYPE_INTERNAL = 1
    UA_VALUEBACKENDTYPE_DATA_SOURCE_CALLBACK = 2
    UA_VALUEBACKENDTYPE_EXTERNAL = 3
end

struct __JL_Ctag_44
    data::NTuple{96, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_44}) = (:internal, :dataSource, :external)
Base.fieldnames(::Type{Ptr{__JL_Ctag_44}}) = (:internal, :dataSource, :external)

function Base.getproperty(x::Ptr{__JL_Ctag_44}, f::Symbol)
    f === :internal && return Ptr{__JL_Ctag_45}(x + 0)
    f === :dataSource && return Ptr{UA_DataSource}(x + 0)
    f === :external && return Ptr{__JL_Ctag_46}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_44, f::Symbol)
    r = Ref{__JL_Ctag_44}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_44}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_44}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `backendType`

- `backend`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_ValueBackend
    data::NTuple{104, UInt8}
end

Base.fieldnames(::Type{UA_ValueBackend}) = (:backendType, :backend)
Base.fieldnames(::Type{Ptr{UA_ValueBackend}}) = (:backendType, :backend)

function Base.getproperty(x::Ptr{UA_ValueBackend}, f::Symbol)
    f === :backendType && return Ptr{UA_ValueBackendType}(x + 0)
    f === :backend && return Ptr{__JL_Ctag_44}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ValueBackend, f::Symbol)
    r = Ref{UA_ValueBackend}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ValueBackend}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ValueBackend}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_setVariableNode_valueBackend(server, nodeId, valueBackend)
    @ccall libopen62541.UA_Server_setVariableNode_valueBackend(
        server::Ptr{UA_Server}, nodeId::UA_NodeId,
        valueBackend::UA_ValueBackend)::UA_StatusCode
end

# typedef void ( * UA_Server_DataChangeNotificationCallback ) ( UA_Server * server , UA_UInt32 monitoredItemId , void * monitoredItemContext , const UA_NodeId * nodeId , void * nodeContext , UA_UInt32 attributeId , const UA_DataValue * value )
const UA_Server_DataChangeNotificationCallback = Ptr{Cvoid}

# typedef void ( * UA_Server_EventNotificationCallback ) ( UA_Server * server , UA_UInt32 monId , void * monContext , size_t nEventFields , const UA_Variant * eventFields )
const UA_Server_EventNotificationCallback = Ptr{Cvoid}

function UA_Server_createDataChangeMonitoredItem(
        server, timestampsToReturn, item, monitoredItemContext, callback)
    @ccall libopen62541.UA_Server_createDataChangeMonitoredItem(
        server::Ptr{UA_Server}, timestampsToReturn::UA_TimestampsToReturn,
        item::UA_MonitoredItemCreateRequest, monitoredItemContext::Ptr{Cvoid},
        callback::UA_Server_DataChangeNotificationCallback)::UA_MonitoredItemCreateResult
end

function UA_Server_deleteMonitoredItem(server, monitoredItemId)
    @ccall libopen62541.UA_Server_deleteMonitoredItem(
        server::Ptr{UA_Server}, monitoredItemId::UA_UInt32)::UA_StatusCode
end

function UA_Server_getMethodNodeCallback(server, methodNodeId, outMethodCallback)
    @ccall libopen62541.UA_Server_getMethodNodeCallback(
        server::Ptr{UA_Server}, methodNodeId::UA_NodeId,
        outMethodCallback::Ptr{UA_MethodCallback})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CallMethodRequest
    data::NTuple{64, UInt8}
end

function Base.fieldnames(::Type{UA_CallMethodRequest})
    (:objectId, :methodId, :inputArgumentsSize, :inputArguments)
end
function Base.fieldnames(::Type{Ptr{UA_CallMethodRequest}})
    (:objectId, :methodId, :inputArgumentsSize, :inputArguments)
end

function Base.getproperty(x::Ptr{UA_CallMethodRequest}, f::Symbol)
    f === :objectId && return Ptr{UA_NodeId}(x + 0)
    f === :methodId && return Ptr{UA_NodeId}(x + 24)
    f === :inputArgumentsSize && return Ptr{Csize_t}(x + 48)
    f === :inputArguments && return Ptr{Ptr{UA_Variant}}(x + 56)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CallMethodRequest, f::Symbol)
    r = Ref{UA_CallMethodRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CallMethodRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CallMethodRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_CallMethodResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :inputArgumentResultsSize && return Ptr{Csize_t}(x + 8)
    f === :inputArgumentResults && return Ptr{Ptr{UA_StatusCode}}(x + 16)
    f === :inputArgumentDiagnosticInfosSize && return Ptr{Csize_t}(x + 24)
    f === :inputArgumentDiagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 32)
    f === :outputArgumentsSize && return Ptr{Csize_t}(x + 40)
    f === :outputArguments && return Ptr{Ptr{UA_Variant}}(x + 48)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_CallMethodResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_call(server, request)
    @ccall libopen62541.UA_Server_call(
        server::Ptr{UA_Server}, request::Ptr{UA_CallMethodRequest})::UA_CallMethodResult
end

function UA_Server_writeObjectProperty(server, objectId, propertyName, value)
    @ccall libopen62541.UA_Server_writeObjectProperty(
        server::Ptr{UA_Server}, objectId::UA_NodeId,
        propertyName::UA_QualifiedName, value::UA_Variant)::UA_StatusCode
end

function UA_Server_writeObjectProperty_scalar(server, objectId, propertyName, value, type)
    @ccall libopen62541.UA_Server_writeObjectProperty_scalar(
        server::Ptr{UA_Server}, objectId::UA_NodeId, propertyName::UA_QualifiedName,
        value::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Server_readObjectProperty(server, objectId, propertyName, value)
    @ccall libopen62541.UA_Server_readObjectProperty(
        server::Ptr{UA_Server}, objectId::UA_NodeId,
        propertyName::UA_QualifiedName, value::Ptr{UA_Variant})::UA_StatusCode
end

function __UA_Server_addNode(
        server, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId,
        browseName, typeDefinition, attr, attributeType, nodeContext, outNewNodeId)
    @ccall libopen62541.__UA_Server_addNode(
        server::Ptr{UA_Server}, nodeClass::UA_NodeClass, requestedNewNodeId::Ptr{UA_NodeId},
        parentNodeId::Ptr{UA_NodeId}, referenceTypeId::Ptr{UA_NodeId},
        browseName::UA_QualifiedName, typeDefinition::Ptr{UA_NodeId},
        attr::Ptr{UA_NodeAttributes}, attributeType::Ptr{UA_DataType},
        nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_VariableAttributes
    data::NTuple{200, UInt8}
end

function Base.fieldnames(::Type{UA_VariableAttributes})
    (:specifiedAttributes, :displayName, :description, :writeMask, :userWriteMask,
        :value, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions,
        :accessLevel, :userAccessLevel, :minimumSamplingInterval, :historizing)
end
function Base.fieldnames(::Type{Ptr{UA_VariableAttributes}})
    (:specifiedAttributes, :displayName, :description, :writeMask, :userWriteMask,
        :value, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions,
        :accessLevel, :userAccessLevel, :minimumSamplingInterval, :historizing)
end

function Base.getproperty(x::Ptr{UA_VariableAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :value && return Ptr{UA_Variant}(x + 80)
    f === :dataType && return Ptr{UA_NodeId}(x + 128)
    f === :valueRank && return Ptr{UA_Int32}(x + 152)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 160)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 168)
    f === :accessLevel && return Ptr{UA_Byte}(x + 176)
    f === :userAccessLevel && return Ptr{UA_Byte}(x + 177)
    f === :minimumSamplingInterval && return Ptr{UA_Double}(x + 184)
    f === :historizing && return Ptr{UA_Boolean}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::UA_VariableAttributes, f::Symbol)
    r = Ref{UA_VariableAttributes}(x)
    ptr = Base.unsafe_convert(Ptr{UA_VariableAttributes}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_VariableAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_addDataSourceVariableNode(
        server, requestedNewNodeId, parentNodeId, referenceTypeId, browseName,
        typeDefinition, attr, dataSource, nodeContext, outNewNodeId)
    @ccall libopen62541.UA_Server_addDataSourceVariableNode(
        server::Ptr{UA_Server}, requestedNewNodeId::UA_NodeId, parentNodeId::UA_NodeId,
        referenceTypeId::UA_NodeId, browseName::UA_QualifiedName,
        typeDefinition::UA_NodeId, attr::UA_VariableAttributes, dataSource::UA_DataSource,
        nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_setVariableNodeDynamic(server, nodeId, isDynamic)
    @ccall libopen62541.UA_Server_setVariableNodeDynamic(
        server::Ptr{UA_Server}, nodeId::UA_NodeId, isDynamic::UA_Boolean)::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_MethodAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :executable && return Ptr{UA_Boolean}(x + 80)
    f === :userExecutable && return Ptr{UA_Boolean}(x + 81)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_MethodAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_Argument
    data::NTuple{96, UInt8}
end

function Base.fieldnames(::Type{UA_Argument})
    (:name, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions, :description)
end
function Base.fieldnames(::Type{Ptr{UA_Argument}})
    (:name, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions, :description)
end

function Base.getproperty(x::Ptr{UA_Argument}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :dataType && return Ptr{UA_NodeId}(x + 16)
    f === :valueRank && return Ptr{UA_Int32}(x + 40)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 48)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 56)
    f === :description && return Ptr{UA_LocalizedText}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_Argument, f::Symbol)
    r = Ref{UA_Argument}(x)
    ptr = Base.unsafe_convert(Ptr{UA_Argument}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_Argument}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_addMethodNodeEx(
        server, requestedNewNodeId, parentNodeId, referenceTypeId,
        browseName, attr, method, inputArgumentsSize, inputArguments,
        inputArgumentsRequestedNewNodeId, inputArgumentsOutNewNodeId,
        outputArgumentsSize, outputArguments, outputArgumentsRequestedNewNodeId,
        outputArgumentsOutNewNodeId, nodeContext, outNewNodeId)
    @ccall libopen62541.UA_Server_addMethodNodeEx(
        server::Ptr{UA_Server}, requestedNewNodeId::UA_NodeId,
        parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId,
        browseName::UA_QualifiedName, attr::UA_MethodAttributes,
        method::UA_MethodCallback, inputArgumentsSize::Csize_t,
        inputArguments::Ptr{UA_Argument}, inputArgumentsRequestedNewNodeId::UA_NodeId,
        inputArgumentsOutNewNodeId::Ptr{UA_NodeId}, outputArgumentsSize::Csize_t,
        outputArguments::Ptr{UA_Argument}, outputArgumentsRequestedNewNodeId::UA_NodeId,
        outputArgumentsOutNewNodeId::Ptr{UA_NodeId},
        nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_addNode_begin(
        server, nodeClass, requestedNewNodeId, parentNodeId, referenceTypeId,
        browseName, typeDefinition, attr, attributeType, nodeContext, outNewNodeId)
    @ccall libopen62541.UA_Server_addNode_begin(
        server::Ptr{UA_Server}, nodeClass::UA_NodeClass, requestedNewNodeId::UA_NodeId,
        parentNodeId::UA_NodeId, referenceTypeId::UA_NodeId, browseName::UA_QualifiedName,
        typeDefinition::UA_NodeId, attr::Ptr{Cvoid}, attributeType::Ptr{UA_DataType},
        nodeContext::Ptr{Cvoid}, outNewNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_addNode_finish(server, nodeId)
    @ccall libopen62541.UA_Server_addNode_finish(
        server::Ptr{UA_Server}, nodeId::UA_NodeId)::UA_StatusCode
end

function UA_Server_addMethodNode_finish(server, nodeId, method, inputArgumentsSize,
        inputArguments, outputArgumentsSize, outputArguments)
    @ccall libopen62541.UA_Server_addMethodNode_finish(
        server::Ptr{UA_Server}, nodeId::UA_NodeId, method::UA_MethodCallback,
        inputArgumentsSize::Csize_t, inputArguments::Ptr{UA_Argument},
        outputArgumentsSize::Csize_t, outputArguments::Ptr{UA_Argument})::UA_StatusCode
end

function UA_Server_deleteNode(server, nodeId, deleteReferences)
    @ccall libopen62541.UA_Server_deleteNode(server::Ptr{UA_Server}, nodeId::UA_NodeId,
        deleteReferences::UA_Boolean)::UA_StatusCode
end

function UA_Server_addReference(server, sourceId, refTypeId, targetId, isForward)
    @ccall libopen62541.UA_Server_addReference(
        server::Ptr{UA_Server}, sourceId::UA_NodeId, refTypeId::UA_NodeId,
        targetId::UA_ExpandedNodeId, isForward::UA_Boolean)::UA_StatusCode
end

function UA_Server_deleteReference(
        server, sourceNodeId, referenceTypeId, isForward, targetNodeId, deleteBidirectional)
    @ccall libopen62541.UA_Server_deleteReference(
        server::Ptr{UA_Server}, sourceNodeId::UA_NodeId, referenceTypeId::UA_NodeId,
        isForward::UA_Boolean, targetNodeId::UA_ExpandedNodeId,
        deleteBidirectional::UA_Boolean)::UA_StatusCode
end

function UA_Server_createEvent(server, eventType, outNodeId)
    @ccall libopen62541.UA_Server_createEvent(server::Ptr{UA_Server}, eventType::UA_NodeId,
        outNodeId::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_triggerEvent(server, eventNodeId, originId, outEventId, deleteEventNode)
    @ccall libopen62541.UA_Server_triggerEvent(
        server::Ptr{UA_Server}, eventNodeId::UA_NodeId, originId::UA_NodeId,
        outEventId::Ptr{UA_ByteString}, deleteEventNode::UA_Boolean)::UA_StatusCode
end

function UA_Server_updateCertificate(server, oldCertificate, newCertificate,
        newPrivateKey, closeSessions, closeSecureChannels)
    @ccall libopen62541.UA_Server_updateCertificate(
        server::Ptr{UA_Server}, oldCertificate::Ptr{UA_ByteString},
        newCertificate::Ptr{UA_ByteString}, newPrivateKey::Ptr{UA_ByteString},
        closeSessions::UA_Boolean, closeSecureChannels::UA_Boolean)::UA_StatusCode
end

function UA_Server_findDataType(server, typeId)
    @ccall libopen62541.UA_Server_findDataType(
        server::Ptr{UA_Server}, typeId::Ptr{UA_NodeId})::Ptr{UA_DataType}
end

function UA_Server_addNamespace(server, name)
    @ccall libopen62541.UA_Server_addNamespace(
        server::Ptr{UA_Server}, name::Cstring)::UA_UInt16
end

function UA_Server_getNamespaceByName(server, namespaceUri, foundIndex)
    @ccall libopen62541.UA_Server_getNamespaceByName(
        server::Ptr{UA_Server}, namespaceUri::UA_String,
        foundIndex::Ptr{Csize_t})::UA_StatusCode
end

function UA_Server_getNamespaceByIndex(server, namespaceIndex, foundUri)
    @ccall libopen62541.UA_Server_getNamespaceByIndex(
        server::Ptr{UA_Server}, namespaceIndex::Csize_t,
        foundUri::Ptr{UA_String})::UA_StatusCode
end

function UA_Server_setMethodNodeAsync(server, id, isAsync)
    @ccall libopen62541.UA_Server_setMethodNodeAsync(
        server::Ptr{UA_Server}, id::UA_NodeId, isAsync::UA_Boolean)::UA_StatusCode
end

@cenum UA_AsyncOperationType::UInt32 begin
    UA_ASYNCOPERATIONTYPE_INVALID = 0
    UA_ASYNCOPERATIONTYPE_CALL = 1
end

"""

$(TYPEDEF)

Fields:

- `callMethodRequest`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_AsyncOperationRequest
    data::NTuple{64, UInt8}
end

Base.fieldnames(::Type{UA_AsyncOperationRequest}) = (:callMethodRequest,)
Base.fieldnames(::Type{Ptr{UA_AsyncOperationRequest}}) = (:callMethodRequest,)

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

"""

$(TYPEDEF)

Fields:

- `callMethodResult`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_AsyncOperationResponse
    data::NTuple{56, UInt8}
end

Base.fieldnames(::Type{UA_AsyncOperationResponse}) = (:callMethodResult,)
Base.fieldnames(::Type{Ptr{UA_AsyncOperationResponse}}) = (:callMethodResult,)

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
    @ccall libopen62541.UA_Server_getAsyncOperationNonBlocking(
        server::Ptr{UA_Server}, type::Ptr{UA_AsyncOperationType},
        request::Ptr{Ptr{UA_AsyncOperationRequest}},
        context::Ptr{Ptr{Cvoid}}, timeout::Ptr{UA_DateTime})::UA_Boolean
end

function UA_Server_setAsyncOperationResult(server, response, context)
    @ccall libopen62541.UA_Server_setAsyncOperationResult(
        server::Ptr{UA_Server}, response::Ptr{UA_AsyncOperationResponse},
        context::Ptr{Cvoid})::Cvoid
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ServerStatistics
    scs::UA_SecureChannelStatistics
    ss::UA_SessionStatistics
end

function UA_Server_getStatistics(server)
    @ccall libopen62541.UA_Server_getStatistics(server::Ptr{UA_Server})::UA_ServerStatistics
end

# typedef void ( * UA_Server_ReverseConnectStateCallback ) ( UA_Server * server , UA_UInt64 handle , UA_SecureChannelState state , void * context )
const UA_Server_ReverseConnectStateCallback = Ptr{Cvoid}

function UA_Server_addReverseConnect(server, url, stateCallback, callbackContext, handle)
    @ccall libopen62541.UA_Server_addReverseConnect(server::Ptr{UA_Server}, url::UA_String,
        stateCallback::UA_Server_ReverseConnectStateCallback,
        callbackContext::Ptr{Cvoid}, handle::Ptr{UA_UInt64})::UA_StatusCode
end

function UA_Server_removeReverseConnect(server, handle)
    @ccall libopen62541.UA_Server_removeReverseConnect(
        server::Ptr{UA_Server}, handle::UA_UInt64)::UA_StatusCode
end

function UA_ServerConfig_setMinimalCustomBuffer(
        config, portNumber, certificate, sendBufferSize, recvBufferSize)
    @ccall libopen62541.UA_ServerConfig_setMinimalCustomBuffer(
        config::Ptr{UA_ServerConfig}, portNumber::UA_UInt16,
        certificate::Ptr{UA_ByteString}, sendBufferSize::UA_UInt32,
        recvBufferSize::UA_UInt32)::UA_StatusCode
end

function UA_ServerConfig_setDefaultWithSecurityPolicies(
        conf, portNumber, certificate, privateKey, trustList, trustListSize,
        issuerList, issuerListSize, revocationList, revocationListSize)
    @ccall libopen62541.UA_ServerConfig_setDefaultWithSecurityPolicies(
        conf::Ptr{UA_ServerConfig}, portNumber::UA_UInt16, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString}, trustList::Ptr{UA_ByteString},
        trustListSize::Csize_t, issuerList::Ptr{UA_ByteString}, issuerListSize::Csize_t,
        revocationList::Ptr{UA_ByteString}, revocationListSize::Csize_t)::UA_StatusCode
end

function UA_ServerConfig_setDefaultWithSecureSecurityPolicies(
        conf, portNumber, certificate, privateKey, trustList, trustListSize,
        issuerList, issuerListSize, revocationList, revocationListSize)
    @ccall libopen62541.UA_ServerConfig_setDefaultWithSecureSecurityPolicies(
        conf::Ptr{UA_ServerConfig}, portNumber::UA_UInt16, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString}, trustList::Ptr{UA_ByteString},
        trustListSize::Csize_t, issuerList::Ptr{UA_ByteString}, issuerListSize::Csize_t,
        revocationList::Ptr{UA_ByteString}, revocationListSize::Csize_t)::UA_StatusCode
end

function UA_ServerConfig_setBasics(conf)
    @ccall libopen62541.UA_ServerConfig_setBasics(conf::Ptr{UA_ServerConfig})::UA_StatusCode
end

function UA_ServerConfig_setBasics_withPort(conf, portNumber)
    @ccall libopen62541.UA_ServerConfig_setBasics_withPort(
        conf::Ptr{UA_ServerConfig}, portNumber::UA_UInt16)::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyNone(config, certificate)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyNone(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyBasic128Rsa15(config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyBasic128Rsa15(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyBasic256(config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyBasic256(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyBasic256Sha256(config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyBasic256Sha256(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyAes128Sha256RsaOaep(
        config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyAes128Sha256RsaOaep(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addSecurityPolicyAes256Sha256RsaPss(
        config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addSecurityPolicyAes256Sha256RsaPss(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addAllSecurityPolicies(config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addAllSecurityPolicies(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addAllSecureSecurityPolicies(config, certificate, privateKey)
    @ccall libopen62541.UA_ServerConfig_addAllSecureSecurityPolicies(
        config::Ptr{UA_ServerConfig}, certificate::Ptr{UA_ByteString},
        privateKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_ServerConfig_addEndpoint(config, securityPolicyUri, securityMode)
    @ccall libopen62541.UA_ServerConfig_addEndpoint(
        config::Ptr{UA_ServerConfig}, securityPolicyUri::UA_String,
        securityMode::UA_MessageSecurityMode)::UA_StatusCode
end

function UA_ServerConfig_addAllEndpoints(config)
    @ccall libopen62541.UA_ServerConfig_addAllEndpoints(config::Ptr{UA_ServerConfig})::UA_StatusCode
end

function UA_ServerConfig_addAllSecureEndpoints(config)
    @ccall libopen62541.UA_ServerConfig_addAllSecureEndpoints(config::Ptr{UA_ServerConfig})::UA_StatusCode
end

function UA_Server_newFromFile(json_config)
    @ccall libopen62541.UA_Server_newFromFile(json_config::UA_ByteString)::Ptr{UA_Server}
end

function UA_ServerConfig_updateFromFile(config, json_config)
    @ccall libopen62541.UA_ServerConfig_updateFromFile(
        config::Ptr{UA_ServerConfig}, json_config::UA_ByteString)::UA_StatusCode
end

@cenum UA_PubSubComponentEnumType::UInt32 begin
    UA_PUBSUB_COMPONENT_CONNECTION = 0
    UA_PUBSUB_COMPONENT_WRITERGROUP = 1
    UA_PUBSUB_COMPONENT_DATASETWRITER = 2
    UA_PUBSUB_COMPONENT_READERGROUP = 3
    UA_PUBSUB_COMPONENT_DATASETREADER = 4
end

@cenum UA_PublisherIdType::UInt32 begin
    UA_PUBLISHERIDTYPE_BYTE = 0
    UA_PUBLISHERIDTYPE_UINT16 = 1
    UA_PUBLISHERIDTYPE_UINT32 = 2
    UA_PUBLISHERIDTYPE_UINT64 = 3
    UA_PUBLISHERIDTYPE_STRING = 4
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublisherId
    data::NTuple{16, UInt8}
end

Base.fieldnames(::Type{UA_PublisherId}) = (:byte, :uint16, :uint32, :uint64, :string)
Base.fieldnames(::Type{Ptr{UA_PublisherId}}) = (:byte, :uint16, :uint32, :uint64, :string)

function Base.getproperty(x::Ptr{UA_PublisherId}, f::Symbol)
    f === :byte && return Ptr{UA_Byte}(x + 0)
    f === :uint16 && return Ptr{UA_UInt16}(x + 0)
    f === :uint32 && return Ptr{UA_UInt32}(x + 0)
    f === :uint64 && return Ptr{UA_UInt64}(x + 0)
    f === :string && return Ptr{UA_String}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublisherId, f::Symbol)
    r = Ref{UA_PublisherId}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublisherId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublisherId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConnectionConfig
    data::NTuple{176, UInt8}
end

function Base.fieldnames(::Type{UA_PubSubConnectionConfig})
    (:name, :enabled, :publisherIdType, :publisherId, :transportProfileUri,
        :address, :connectionProperties, :connectionTransportSettings, :eventLoop)
end
function Base.fieldnames(::Type{Ptr{UA_PubSubConnectionConfig}})
    (:name, :enabled, :publisherIdType, :publisherId, :transportProfileUri,
        :address, :connectionProperties, :connectionTransportSettings, :eventLoop)
end

function Base.getproperty(x::Ptr{UA_PubSubConnectionConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :publisherIdType && return Ptr{UA_PublisherIdType}(x + 20)
    f === :publisherId && return Ptr{UA_PublisherId}(x + 24)
    f === :transportProfileUri && return Ptr{UA_String}(x + 40)
    f === :address && return Ptr{UA_Variant}(x + 56)
    f === :connectionProperties && return Ptr{UA_KeyValueMap}(x + 104)
    f === :connectionTransportSettings && return Ptr{UA_Variant}(x + 120)
    f === :eventLoop && return Ptr{Ptr{UA_EventLoop}}(x + 168)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PubSubConnectionConfig, f::Symbol)
    r = Ref{UA_PubSubConnectionConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PubSubConnectionConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PubSubConnectionConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_Server_addPubSubConnection(server, connectionConfig, connectionIdentifier)
    @ccall libopen62541.UA_Server_addPubSubConnection(
        server::Ptr{UA_Server}, connectionConfig::Ptr{UA_PubSubConnectionConfig},
        connectionIdentifier::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_getPubSubConnectionConfig(server, connection, config)
    @ccall libopen62541.UA_Server_getPubSubConnectionConfig(
        server::Ptr{UA_Server}, connection::UA_NodeId,
        config::Ptr{UA_PubSubConnectionConfig})::UA_StatusCode
end

function UA_Server_removePubSubConnection(server, connection)
    @ccall libopen62541.UA_Server_removePubSubConnection(
        server::Ptr{UA_Server}, connection::UA_NodeId)::UA_StatusCode
end

@cenum UA_PublishedDataSetType::UInt32 begin
    UA_PUBSUB_DATASET_PUBLISHEDITEMS = 0
    UA_PUBSUB_DATASET_PUBLISHEDEVENTS = 1
    UA_PUBSUB_DATASET_PUBLISHEDITEMS_TEMPLATE = 2
    UA_PUBSUB_DATASET_PUBLISHEDEVENTS_TEMPLATE = 3
end

@cenum UA_StructureType::UInt32 begin
    UA_STRUCTURETYPE_STRUCTURE = 0
    UA_STRUCTURETYPE_STRUCTUREWITHOPTIONALFIELDS = 1
    UA_STRUCTURETYPE_UNION = 2
    UA_STRUCTURETYPE_STRUCTUREWITHSUBTYPEDVALUES = 3
    UA_STRUCTURETYPE_UNIONWITHSUBTYPEDVALUES = 4
    __UA_STRUCTURETYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StructureField
    data::NTuple{104, UInt8}
end

function Base.fieldnames(::Type{UA_StructureField})
    (:name, :description, :dataType, :valueRank, :arrayDimensionsSize,
        :arrayDimensions, :maxStringLength, :isOptional)
end
function Base.fieldnames(::Type{Ptr{UA_StructureField}})
    (:name, :description, :dataType, :valueRank, :arrayDimensionsSize,
        :arrayDimensions, :maxStringLength, :isOptional)
end

function Base.getproperty(x::Ptr{UA_StructureField}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :description && return Ptr{UA_LocalizedText}(x + 16)
    f === :dataType && return Ptr{UA_NodeId}(x + 48)
    f === :valueRank && return Ptr{UA_Int32}(x + 72)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 80)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 88)
    f === :maxStringLength && return Ptr{UA_UInt32}(x + 96)
    f === :isOptional && return Ptr{UA_Boolean}(x + 100)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StructureField, f::Symbol)
    r = Ref{UA_StructureField}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StructureField}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StructureField}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StructureDefinition
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_StructureDefinition})
    (:defaultEncodingId, :baseDataType, :structureType, :fieldsSize, :fields)
end
function Base.fieldnames(::Type{Ptr{UA_StructureDefinition}})
    (:defaultEncodingId, :baseDataType, :structureType, :fieldsSize, :fields)
end

function Base.getproperty(x::Ptr{UA_StructureDefinition}, f::Symbol)
    f === :defaultEncodingId && return Ptr{UA_NodeId}(x + 0)
    f === :baseDataType && return Ptr{UA_NodeId}(x + 24)
    f === :structureType && return Ptr{UA_StructureType}(x + 48)
    f === :fieldsSize && return Ptr{Csize_t}(x + 56)
    f === :fields && return Ptr{Ptr{UA_StructureField}}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StructureDefinition, f::Symbol)
    r = Ref{UA_StructureDefinition}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StructureDefinition}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StructureDefinition}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StructureDescription
    data::NTuple{120, UInt8}
end

function Base.fieldnames(::Type{UA_StructureDescription})
    (:dataTypeId, :name, :structureDefinition)
end
function Base.fieldnames(::Type{Ptr{UA_StructureDescription}})
    (:dataTypeId, :name, :structureDefinition)
end

function Base.getproperty(x::Ptr{UA_StructureDescription}, f::Symbol)
    f === :dataTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :name && return Ptr{UA_QualifiedName}(x + 24)
    f === :structureDefinition && return Ptr{UA_StructureDefinition}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StructureDescription, f::Symbol)
    r = Ref{UA_StructureDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StructureDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StructureDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_Int64 = Int64

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EnumField
    value::UA_Int64
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    name::UA_String
end
function Base.getproperty(x::Ptr{UA_EnumField}, f::Symbol)
    f === :value && return Ptr{UA_Int64}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :name && return Ptr{UA_String}(x + 72)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EnumField}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EnumDefinition
    fieldsSize::Csize_t
    fields::Ptr{UA_EnumField}
end
function Base.getproperty(x::Ptr{UA_EnumDefinition}, f::Symbol)
    f === :fieldsSize && return Ptr{Csize_t}(x + 0)
    f === :fields && return Ptr{Ptr{UA_EnumField}}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EnumDefinition}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EnumDescription
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_EnumDescription})
    (:dataTypeId, :name, :enumDefinition, :builtInType)
end
function Base.fieldnames(::Type{Ptr{UA_EnumDescription}})
    (:dataTypeId, :name, :enumDefinition, :builtInType)
end

function Base.getproperty(x::Ptr{UA_EnumDescription}, f::Symbol)
    f === :dataTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :name && return Ptr{UA_QualifiedName}(x + 24)
    f === :enumDefinition && return Ptr{UA_EnumDefinition}(x + 48)
    f === :builtInType && return Ptr{UA_Byte}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_EnumDescription, f::Symbol)
    r = Ref{UA_EnumDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_EnumDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_EnumDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SimpleTypeDescription
    data::NTuple{80, UInt8}
end

function Base.fieldnames(::Type{UA_SimpleTypeDescription})
    (:dataTypeId, :name, :baseDataType, :builtInType)
end
function Base.fieldnames(::Type{Ptr{UA_SimpleTypeDescription}})
    (:dataTypeId, :name, :baseDataType, :builtInType)
end

function Base.getproperty(x::Ptr{UA_SimpleTypeDescription}, f::Symbol)
    f === :dataTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :name && return Ptr{UA_QualifiedName}(x + 24)
    f === :baseDataType && return Ptr{UA_NodeId}(x + 48)
    f === :builtInType && return Ptr{UA_Byte}(x + 72)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SimpleTypeDescription, f::Symbol)
    r = Ref{UA_SimpleTypeDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SimpleTypeDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SimpleTypeDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end
const UA_DataSetFieldFlags = UA_UInt16

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_Guid
    data1::UA_UInt32
    data2::UA_UInt16
    data3::UA_UInt16
    data4::NTuple{8, UA_Byte}
end
function Base.getproperty(x::Ptr{UA_Guid}, f::Symbol)
    f === :data1 && return Ptr{UA_UInt32}(x + 0)
    f === :data2 && return Ptr{UA_UInt16}(x + 4)
    f === :data3 && return Ptr{UA_UInt16}(x + 6)
    f === :data4 && return Ptr{NTuple{8, UA_Byte}}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_Guid}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FieldMetaData
    data::NTuple{144, UInt8}
end

function Base.fieldnames(::Type{UA_FieldMetaData})
    (:name, :description, :fieldFlags, :builtInType, :dataType,
        :valueRank, :arrayDimensionsSize, :arrayDimensions,
        :maxStringLength, :dataSetFieldId, :propertiesSize, :properties)
end
function Base.fieldnames(::Type{Ptr{UA_FieldMetaData}})
    (:name, :description, :fieldFlags, :builtInType, :dataType,
        :valueRank, :arrayDimensionsSize, :arrayDimensions,
        :maxStringLength, :dataSetFieldId, :propertiesSize, :properties)
end

function Base.getproperty(x::Ptr{UA_FieldMetaData}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :description && return Ptr{UA_LocalizedText}(x + 16)
    f === :fieldFlags && return Ptr{UA_DataSetFieldFlags}(x + 48)
    f === :builtInType && return Ptr{UA_Byte}(x + 50)
    f === :dataType && return Ptr{UA_NodeId}(x + 56)
    f === :valueRank && return Ptr{UA_Int32}(x + 80)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 88)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 96)
    f === :maxStringLength && return Ptr{UA_UInt32}(x + 104)
    f === :dataSetFieldId && return Ptr{UA_Guid}(x + 108)
    f === :propertiesSize && return Ptr{Csize_t}(x + 128)
    f === :properties && return Ptr{Ptr{UA_KeyValuePair}}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FieldMetaData, f::Symbol)
    r = Ref{UA_FieldMetaData}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FieldMetaData}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FieldMetaData}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ConfigurationVersionDataType
    majorVersion::UA_UInt32
    minorVersion::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetMetaDataType
    namespacesSize::Csize_t
    namespaces::Ptr{UA_String}
    structureDataTypesSize::Csize_t
    structureDataTypes::Ptr{UA_StructureDescription}
    enumDataTypesSize::Csize_t
    enumDataTypes::Ptr{UA_EnumDescription}
    simpleDataTypesSize::Csize_t
    simpleDataTypes::Ptr{UA_SimpleTypeDescription}
    name::UA_String
    description::UA_LocalizedText
    fieldsSize::Csize_t
    fields::Ptr{UA_FieldMetaData}
    dataSetClassId::UA_Guid
    configurationVersion::UA_ConfigurationVersionDataType
end
function Base.getproperty(x::Ptr{UA_DataSetMetaDataType}, f::Symbol)
    f === :namespacesSize && return Ptr{Csize_t}(x + 0)
    f === :namespaces && return Ptr{Ptr{UA_String}}(x + 8)
    f === :structureDataTypesSize && return Ptr{Csize_t}(x + 16)
    f === :structureDataTypes && return Ptr{Ptr{UA_StructureDescription}}(x + 24)
    f === :enumDataTypesSize && return Ptr{Csize_t}(x + 32)
    f === :enumDataTypes && return Ptr{Ptr{UA_EnumDescription}}(x + 40)
    f === :simpleDataTypesSize && return Ptr{Csize_t}(x + 48)
    f === :simpleDataTypes && return Ptr{Ptr{UA_SimpleTypeDescription}}(x + 56)
    f === :name && return Ptr{UA_String}(x + 64)
    f === :description && return Ptr{UA_LocalizedText}(x + 80)
    f === :fieldsSize && return Ptr{Csize_t}(x + 112)
    f === :fields && return Ptr{Ptr{UA_FieldMetaData}}(x + 120)
    f === :dataSetClassId && return Ptr{UA_Guid}(x + 128)
    f === :configurationVersion && return Ptr{UA_ConfigurationVersionDataType}(x + 144)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_DataSetMetaDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedVariableDataType
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_PublishedVariableDataType})
    (:publishedVariable, :attributeId, :samplingIntervalHint,
        :deadbandType, :deadbandValue, :indexRange, :substituteValue,
        :metaDataPropertiesSize, :metaDataProperties)
end
function Base.fieldnames(::Type{Ptr{UA_PublishedVariableDataType}})
    (:publishedVariable, :attributeId, :samplingIntervalHint,
        :deadbandType, :deadbandValue, :indexRange, :substituteValue,
        :metaDataPropertiesSize, :metaDataProperties)
end

function Base.getproperty(x::Ptr{UA_PublishedVariableDataType}, f::Symbol)
    f === :publishedVariable && return Ptr{UA_NodeId}(x + 0)
    f === :attributeId && return Ptr{UA_UInt32}(x + 24)
    f === :samplingIntervalHint && return Ptr{UA_Double}(x + 32)
    f === :deadbandType && return Ptr{UA_UInt32}(x + 40)
    f === :deadbandValue && return Ptr{UA_Double}(x + 48)
    f === :indexRange && return Ptr{UA_String}(x + 56)
    f === :substituteValue && return Ptr{UA_Variant}(x + 72)
    f === :metaDataPropertiesSize && return Ptr{Csize_t}(x + 120)
    f === :metaDataProperties && return Ptr{Ptr{UA_QualifiedName}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishedVariableDataType, f::Symbol)
    r = Ref{UA_PublishedVariableDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishedVariableDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishedVariableDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedDataItemsTemplateConfig
    metaData::UA_DataSetMetaDataType
    variablesToAddSize::Csize_t
    variablesToAdd::Ptr{UA_PublishedVariableDataType}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedEventConfig
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{UA_PublishedEventConfig}) = (:eventNotfier, :filter)
Base.fieldnames(::Type{Ptr{UA_PublishedEventConfig}}) = (:eventNotfier, :filter)

function Base.getproperty(x::Ptr{UA_PublishedEventConfig}, f::Symbol)
    f === :eventNotfier && return Ptr{UA_NodeId}(x + 0)
    f === :filter && return Ptr{UA_ContentFilter}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishedEventConfig, f::Symbol)
    r = Ref{UA_PublishedEventConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishedEventConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishedEventConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedEventTemplateConfig
    data::NTuple{208, UInt8}
end

function Base.fieldnames(::Type{UA_PublishedEventTemplateConfig})
    (:metaData, :eventNotfier, :selectedFieldsSize, :selectedFields, :filter)
end
function Base.fieldnames(::Type{Ptr{UA_PublishedEventTemplateConfig}})
    (:metaData, :eventNotfier, :selectedFieldsSize, :selectedFields, :filter)
end

function Base.getproperty(x::Ptr{UA_PublishedEventTemplateConfig}, f::Symbol)
    f === :metaData && return Ptr{UA_DataSetMetaDataType}(x + 0)
    f === :eventNotfier && return Ptr{UA_NodeId}(x + 152)
    f === :selectedFieldsSize && return Ptr{Csize_t}(x + 176)
    f === :selectedFields && return Ptr{Ptr{UA_SimpleAttributeOperand}}(x + 184)
    f === :filter && return Ptr{UA_ContentFilter}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishedEventTemplateConfig, f::Symbol)
    r = Ref{UA_PublishedEventTemplateConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishedEventTemplateConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishedEventTemplateConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_47
    data::NTuple{208, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_47}) = (:itemsTemplate, :event, :eventTemplate)
Base.fieldnames(::Type{Ptr{__JL_Ctag_47}}) = (:itemsTemplate, :event, :eventTemplate)

function Base.getproperty(x::Ptr{__JL_Ctag_47}, f::Symbol)
    f === :itemsTemplate && return Ptr{UA_PublishedDataItemsTemplateConfig}(x + 0)
    f === :event && return Ptr{UA_PublishedEventConfig}(x + 0)
    f === :eventTemplate && return Ptr{UA_PublishedEventTemplateConfig}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_47, f::Symbol)
    r = Ref{__JL_Ctag_47}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_47}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_47}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedDataSetConfig
    data::NTuple{232, UInt8}
end

Base.fieldnames(::Type{UA_PublishedDataSetConfig}) = (:name, :publishedDataSetType, :config)
function Base.fieldnames(::Type{Ptr{UA_PublishedDataSetConfig}})
    (:name, :publishedDataSetType, :config)
end

function Base.getproperty(x::Ptr{UA_PublishedDataSetConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :publishedDataSetType && return Ptr{UA_PublishedDataSetType}(x + 16)
    f === :config && return Ptr{__JL_Ctag_47}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishedDataSetConfig, f::Symbol)
    r = Ref{UA_PublishedDataSetConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishedDataSetConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishedDataSetConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_PublishedDataSetConfig_clear(pdsConfig)
    @ccall libopen62541.UA_PublishedDataSetConfig_clear(pdsConfig::Ptr{UA_PublishedDataSetConfig})::Cvoid
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddPublishedDataSetResult
    addResult::UA_StatusCode
    fieldAddResultsSize::Csize_t
    fieldAddResults::Ptr{UA_StatusCode}
    configurationVersion::UA_ConfigurationVersionDataType
end

function UA_Server_addPublishedDataSet(server, publishedDataSetConfig, pdsIdentifier)
    @ccall libopen62541.UA_Server_addPublishedDataSet(
        server::Ptr{UA_Server}, publishedDataSetConfig::Ptr{UA_PublishedDataSetConfig},
        pdsIdentifier::Ptr{UA_NodeId})::UA_AddPublishedDataSetResult
end

function UA_Server_getPublishedDataSetConfig(server, pds, config)
    @ccall libopen62541.UA_Server_getPublishedDataSetConfig(
        server::Ptr{UA_Server}, pds::UA_NodeId,
        config::Ptr{UA_PublishedDataSetConfig})::UA_StatusCode
end

function UA_Server_getPublishedDataSetMetaData(server, pds, metaData)
    @ccall libopen62541.UA_Server_getPublishedDataSetMetaData(
        server::Ptr{UA_Server}, pds::UA_NodeId,
        metaData::Ptr{UA_DataSetMetaDataType})::UA_StatusCode
end

function UA_Server_removePublishedDataSet(server, pds)
    @ccall libopen62541.UA_Server_removePublishedDataSet(
        server::Ptr{UA_Server}, pds::UA_NodeId)::UA_StatusCode
end

struct __JL_Ctag_34
    rtFieldSourceEnabled::UA_Boolean
    rtInformationModelNode::UA_Boolean
    staticValueSource::Ptr{Ptr{UA_DataValue}}
end
function Base.getproperty(x::Ptr{__JL_Ctag_34}, f::Symbol)
    f === :rtFieldSourceEnabled && return Ptr{UA_Boolean}(x + 0)
    f === :rtInformationModelNode && return Ptr{UA_Boolean}(x + 1)
    f === :staticValueSource && return Ptr{Ptr{Ptr{UA_DataValue}}}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_34, f::Symbol)
    r = Ref{__JL_Ctag_34}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_34}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_34}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetVariableConfig
    data::NTuple{192, UInt8}
end

function Base.fieldnames(::Type{UA_DataSetVariableConfig})
    (:configurationVersion, :fieldNameAlias, :promotedField,
        :publishParameters, :rtValueSource, :maxStringLength)
end
function Base.fieldnames(::Type{Ptr{UA_DataSetVariableConfig}})
    (:configurationVersion, :fieldNameAlias, :promotedField,
        :publishParameters, :rtValueSource, :maxStringLength)
end

function Base.getproperty(x::Ptr{UA_DataSetVariableConfig}, f::Symbol)
    f === :configurationVersion && return Ptr{UA_ConfigurationVersionDataType}(x + 0)
    f === :fieldNameAlias && return Ptr{UA_String}(x + 8)
    f === :promotedField && return Ptr{UA_Boolean}(x + 24)
    f === :publishParameters && return Ptr{UA_PublishedVariableDataType}(x + 32)
    f === :rtValueSource && return Ptr{__JL_Ctag_34}(x + 168)
    f === :maxStringLength && return Ptr{UA_UInt32}(x + 184)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataSetVariableConfig, f::Symbol)
    r = Ref{UA_DataSetVariableConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataSetVariableConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataSetVariableConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_DataSetFieldType::UInt32 begin
    UA_PUBSUB_DATASETFIELD_VARIABLE = 0
    UA_PUBSUB_DATASETFIELD_EVENT = 1
end

struct __JL_Ctag_52
    data::NTuple{192, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_52}) = (:variable,)
Base.fieldnames(::Type{Ptr{__JL_Ctag_52}}) = (:variable,)

function Base.getproperty(x::Ptr{__JL_Ctag_52}, f::Symbol)
    f === :variable && return Ptr{UA_DataSetVariableConfig}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_52, f::Symbol)
    r = Ref{__JL_Ctag_52}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_52}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_52}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetFieldConfig
    data::NTuple{200, UInt8}
end

Base.fieldnames(::Type{UA_DataSetFieldConfig}) = (:dataSetFieldType, :field)
Base.fieldnames(::Type{Ptr{UA_DataSetFieldConfig}}) = (:dataSetFieldType, :field)

function Base.getproperty(x::Ptr{UA_DataSetFieldConfig}, f::Symbol)
    f === :dataSetFieldType && return Ptr{UA_DataSetFieldType}(x + 0)
    f === :field && return Ptr{__JL_Ctag_52}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataSetFieldConfig, f::Symbol)
    r = Ref{UA_DataSetFieldConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataSetFieldConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataSetFieldConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_DataSetFieldConfig_clear(dataSetFieldConfig)
    @ccall libopen62541.UA_DataSetFieldConfig_clear(dataSetFieldConfig::Ptr{UA_DataSetFieldConfig})::Cvoid
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetFieldResult
    result::UA_StatusCode
    configurationVersion::UA_ConfigurationVersionDataType
end

function UA_Server_addDataSetField(server, publishedDataSet, fieldConfig, fieldIdentifier)
    @ccall libopen62541.UA_Server_addDataSetField(
        server::Ptr{UA_Server}, publishedDataSet::UA_NodeId,
        fieldConfig::Ptr{UA_DataSetFieldConfig},
        fieldIdentifier::Ptr{UA_NodeId})::UA_DataSetFieldResult
end

function UA_Server_getDataSetFieldConfig(server, dsf, config)
    @ccall libopen62541.UA_Server_getDataSetFieldConfig(
        server::Ptr{UA_Server}, dsf::UA_NodeId,
        config::Ptr{UA_DataSetFieldConfig})::UA_StatusCode
end

function UA_Server_removeDataSetField(server, dsf)
    @ccall libopen62541.UA_Server_removeDataSetField(
        server::Ptr{UA_Server}, dsf::UA_NodeId)::UA_DataSetFieldResult
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSub_CallbackLifecycle
    addCustomCallback::Ptr{Cvoid}
    changeCustomCallback::Ptr{Cvoid}
    removeCustomCallback::Ptr{Cvoid}
end

@cenum UA_PubSubEncodingType::UInt32 begin
    UA_PUBSUB_ENCODING_UADP = 0
    UA_PUBSUB_ENCODING_JSON = 1
    UA_PUBSUB_ENCODING_BINARY = 2
end

@cenum UA_PubSubRTLevel::UInt32 begin
    UA_PUBSUB_RT_NONE = 0
    UA_PUBSUB_RT_DIRECT_VALUE_ACCESS = 1
    UA_PUBSUB_RT_FIXED_SIZE = 2
    UA_PUBSUB_RT_DETERMINISTIC = 3
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_WriterGroupConfig
    data::NTuple{208, UInt8}
end

function Base.fieldnames(::Type{UA_WriterGroupConfig})
    (:name, :enabled, :writerGroupId, :publishingInterval,
        :keepAliveTime, :priority, :transportSettings, :messageSettings,
        :groupProperties, :encodingMimeType, :pubsubManagerCallback,
        :maxEncapsulatedDataSetMessageCount, :rtLevel, :securityMode)
end
function Base.fieldnames(::Type{Ptr{UA_WriterGroupConfig}})
    (:name, :enabled, :writerGroupId, :publishingInterval,
        :keepAliveTime, :priority, :transportSettings, :messageSettings,
        :groupProperties, :encodingMimeType, :pubsubManagerCallback,
        :maxEncapsulatedDataSetMessageCount, :rtLevel, :securityMode)
end

function Base.getproperty(x::Ptr{UA_WriterGroupConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :writerGroupId && return Ptr{UA_UInt16}(x + 18)
    f === :publishingInterval && return Ptr{UA_Duration}(x + 24)
    f === :keepAliveTime && return Ptr{UA_Double}(x + 32)
    f === :priority && return Ptr{UA_Byte}(x + 40)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 48)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 96)
    f === :groupProperties && return Ptr{UA_KeyValueMap}(x + 144)
    f === :encodingMimeType && return Ptr{UA_PubSubEncodingType}(x + 160)
    f === :pubsubManagerCallback && return Ptr{UA_PubSub_CallbackLifecycle}(x + 168)
    f === :maxEncapsulatedDataSetMessageCount && return Ptr{UA_UInt16}(x + 192)
    f === :rtLevel && return Ptr{UA_PubSubRTLevel}(x + 196)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 200)
    return getfield(x, f)
end

function Base.getproperty(x::UA_WriterGroupConfig, f::Symbol)
    r = Ref{UA_WriterGroupConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_WriterGroupConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_WriterGroupConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_WriterGroupConfig_clear(writerGroupConfig)
    @ccall libopen62541.UA_WriterGroupConfig_clear(writerGroupConfig::Ptr{UA_WriterGroupConfig})::Cvoid
end

function UA_Server_addWriterGroup(
        server, connection, writerGroupConfig, writerGroupIdentifier)
    @ccall libopen62541.UA_Server_addWriterGroup(
        server::Ptr{UA_Server}, connection::UA_NodeId,
        writerGroupConfig::Ptr{UA_WriterGroupConfig},
        writerGroupIdentifier::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_getWriterGroupConfig(server, writerGroup, config)
    @ccall libopen62541.UA_Server_getWriterGroupConfig(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId,
        config::Ptr{UA_WriterGroupConfig})::UA_StatusCode
end

function UA_Server_updateWriterGroupConfig(server, writerGroupIdentifier, config)
    @ccall libopen62541.UA_Server_updateWriterGroupConfig(
        server::Ptr{UA_Server}, writerGroupIdentifier::UA_NodeId,
        config::Ptr{UA_WriterGroupConfig})::UA_StatusCode
end

@cenum UA_PubSubState::UInt32 begin
    UA_PUBSUBSTATE_DISABLED = 0
    UA_PUBSUBSTATE_PAUSED = 1
    UA_PUBSUBSTATE_OPERATIONAL = 2
    UA_PUBSUBSTATE_ERROR = 3
    UA_PUBSUBSTATE_PREOPERATIONAL = 4
    __UA_PUBSUBSTATE_FORCE32BIT = 2147483647
end

function UA_Server_WriterGroup_getState(server, writerGroupIdentifier, state)
    @ccall libopen62541.UA_Server_WriterGroup_getState(
        server::Ptr{UA_Server}, writerGroupIdentifier::UA_NodeId,
        state::Ptr{UA_PubSubState})::UA_StatusCode
end

function UA_Server_WriterGroup_publish(server, writerGroupIdentifier)
    @ccall libopen62541.UA_Server_WriterGroup_publish(
        server::Ptr{UA_Server}, writerGroupIdentifier::UA_NodeId)::UA_StatusCode
end

function UA_WriterGroup_lastPublishTimestamp(server, writerGroupId, timestamp)
    @ccall libopen62541.UA_WriterGroup_lastPublishTimestamp(
        server::Ptr{UA_Server}, writerGroupId::UA_NodeId,
        timestamp::Ptr{UA_DateTime})::UA_StatusCode
end

function UA_Server_removeWriterGroup(server, writerGroup)
    @ccall libopen62541.UA_Server_removeWriterGroup(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId)::UA_StatusCode
end

function UA_Server_freezeWriterGroupConfiguration(server, writerGroup)
    @ccall libopen62541.UA_Server_freezeWriterGroupConfiguration(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId)::UA_StatusCode
end

function UA_Server_unfreezeWriterGroupConfiguration(server, writerGroup)
    @ccall libopen62541.UA_Server_unfreezeWriterGroupConfiguration(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId)::UA_StatusCode
end

function UA_Server_setWriterGroupOperational(server, writerGroup)
    @ccall libopen62541.UA_Server_setWriterGroupOperational(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId)::UA_StatusCode
end

function UA_Server_setWriterGroupDisabled(server, writerGroup)
    @ccall libopen62541.UA_Server_setWriterGroupDisabled(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId)::UA_StatusCode
end
const UA_DataSetFieldContentMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetWriterConfig
    data::NTuple{160, UInt8}
end

function Base.fieldnames(::Type{UA_DataSetWriterConfig})
    (:name, :dataSetWriterId, :dataSetFieldContentMask, :keyFrameCount,
        :messageSettings, :transportSettings, :dataSetName, :dataSetWriterProperties)
end
function Base.fieldnames(::Type{Ptr{UA_DataSetWriterConfig}})
    (:name, :dataSetWriterId, :dataSetFieldContentMask, :keyFrameCount,
        :messageSettings, :transportSettings, :dataSetName, :dataSetWriterProperties)
end

function Base.getproperty(x::Ptr{UA_DataSetWriterConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :dataSetWriterId && return Ptr{UA_UInt16}(x + 16)
    f === :dataSetFieldContentMask && return Ptr{UA_DataSetFieldContentMask}(x + 20)
    f === :keyFrameCount && return Ptr{UA_UInt32}(x + 24)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 32)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 80)
    f === :dataSetName && return Ptr{UA_String}(x + 128)
    f === :dataSetWriterProperties && return Ptr{UA_KeyValueMap}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataSetWriterConfig, f::Symbol)
    r = Ref{UA_DataSetWriterConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataSetWriterConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataSetWriterConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_DataSetWriterConfig_clear(pdsConfig)
    @ccall libopen62541.UA_DataSetWriterConfig_clear(pdsConfig::Ptr{UA_DataSetWriterConfig})::Cvoid
end

function UA_Server_addDataSetWriter(
        server, writerGroup, dataSet, dataSetWriterConfig, writerIdentifier)
    @ccall libopen62541.UA_Server_addDataSetWriter(
        server::Ptr{UA_Server}, writerGroup::UA_NodeId, dataSet::UA_NodeId,
        dataSetWriterConfig::Ptr{UA_DataSetWriterConfig},
        writerIdentifier::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_getDataSetWriterConfig(server, dsw, config)
    @ccall libopen62541.UA_Server_getDataSetWriterConfig(
        server::Ptr{UA_Server}, dsw::UA_NodeId,
        config::Ptr{UA_DataSetWriterConfig})::UA_StatusCode
end

function UA_Server_DataSetWriter_getState(server, dataSetWriterIdentifier, state)
    @ccall libopen62541.UA_Server_DataSetWriter_getState(
        server::Ptr{UA_Server}, dataSetWriterIdentifier::UA_NodeId,
        state::Ptr{UA_PubSubState})::UA_StatusCode
end

function UA_Server_removeDataSetWriter(server, dsw)
    @ccall libopen62541.UA_Server_removeDataSetWriter(
        server::Ptr{UA_Server}, dsw::UA_NodeId)::UA_StatusCode
end

@cenum UA_SubscribedDataSetEnumType::UInt32 begin
    UA_PUBSUB_SDS_TARGET = 0
    UA_PUBSUB_SDS_MIRROR = 1
end

@cenum UA_OverrideValueHandling::UInt32 begin
    UA_OVERRIDEVALUEHANDLING_DISABLED = 0
    UA_OVERRIDEVALUEHANDLING_LASTUSABLEVALUE = 1
    UA_OVERRIDEVALUEHANDLING_OVERRIDEVALUE = 2
    __UA_OVERRIDEVALUEHANDLING_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FieldTargetDataType
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_FieldTargetDataType})
    (:dataSetFieldId, :receiverIndexRange, :targetNodeId, :attributeId,
        :writeIndexRange, :overrideValueHandling, :overrideValue)
end
function Base.fieldnames(::Type{Ptr{UA_FieldTargetDataType}})
    (:dataSetFieldId, :receiverIndexRange, :targetNodeId, :attributeId,
        :writeIndexRange, :overrideValueHandling, :overrideValue)
end

function Base.getproperty(x::Ptr{UA_FieldTargetDataType}, f::Symbol)
    f === :dataSetFieldId && return Ptr{UA_Guid}(x + 0)
    f === :receiverIndexRange && return Ptr{UA_String}(x + 16)
    f === :targetNodeId && return Ptr{UA_NodeId}(x + 32)
    f === :attributeId && return Ptr{UA_UInt32}(x + 56)
    f === :writeIndexRange && return Ptr{UA_String}(x + 64)
    f === :overrideValueHandling && return Ptr{UA_OverrideValueHandling}(x + 80)
    f === :overrideValue && return Ptr{UA_Variant}(x + 88)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FieldTargetDataType, f::Symbol)
    r = Ref{UA_FieldTargetDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FieldTargetDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FieldTargetDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FieldTargetVariable
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_FieldTargetVariable})
    (:targetVariable, :externalDataValue, :targetVariableContext, :beforeWrite, :afterWrite)
end
function Base.fieldnames(::Type{Ptr{UA_FieldTargetVariable}})
    (:targetVariable, :externalDataValue, :targetVariableContext, :beforeWrite, :afterWrite)
end

function Base.getproperty(x::Ptr{UA_FieldTargetVariable}, f::Symbol)
    f === :targetVariable && return Ptr{UA_FieldTargetDataType}(x + 0)
    f === :externalDataValue && return Ptr{Ptr{Ptr{UA_DataValue}}}(x + 136)
    f === :targetVariableContext && return Ptr{Ptr{Cvoid}}(x + 144)
    f === :beforeWrite && return Ptr{Ptr{Cvoid}}(x + 152)
    f === :afterWrite && return Ptr{Ptr{Cvoid}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FieldTargetVariable, f::Symbol)
    r = Ref{UA_FieldTargetVariable}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FieldTargetVariable}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FieldTargetVariable}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TargetVariables
    targetVariablesSize::Csize_t
    targetVariables::Ptr{UA_FieldTargetVariable}
end

function UA_Server_DataSetReader_createTargetVariables(
        server, dataSetReaderIdentifier, targetVariablesSize, targetVariables)
    @ccall libopen62541.UA_Server_DataSetReader_createTargetVariables(
        server::Ptr{UA_Server}, dataSetReaderIdentifier::UA_NodeId,
        targetVariablesSize::Csize_t,
        targetVariables::Ptr{UA_FieldTargetVariable})::UA_StatusCode
end

@cenum UA_PubSubRtEncoding::UInt32 begin
    UA_PUBSUB_RT_UNKNOWN = 0
    UA_PUBSUB_RT_VARIANT = 1
    UA_PUBSUB_RT_DATA_VALUE = 2
    UA_PUBSUB_RT_RAW = 4
end

struct __JL_Ctag_38
    data::NTuple{16, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_38}) = (:subscribedDataSetTarget,)
Base.fieldnames(::Type{Ptr{__JL_Ctag_38}}) = (:subscribedDataSetTarget,)

function Base.getproperty(x::Ptr{__JL_Ctag_38}, f::Symbol)
    f === :subscribedDataSetTarget && return Ptr{UA_TargetVariables}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_38, f::Symbol)
    r = Ref{__JL_Ctag_38}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_38}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_38}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetReaderConfig
    data::NTuple{384, UInt8}
end

function Base.fieldnames(::Type{UA_DataSetReaderConfig})
    (:name, :publisherId, :writerGroupId, :dataSetWriterId, :dataSetMetaData,
        :dataSetFieldContentMask, :messageReceiveTimeout, :messageSettings,
        :transportSettings, :subscribedDataSetType, :subscribedDataSet,
        :linkedStandaloneSubscribedDataSetName, :expectedEncoding)
end
function Base.fieldnames(::Type{Ptr{UA_DataSetReaderConfig}})
    (:name, :publisherId, :writerGroupId, :dataSetWriterId, :dataSetMetaData,
        :dataSetFieldContentMask, :messageReceiveTimeout, :messageSettings,
        :transportSettings, :subscribedDataSetType, :subscribedDataSet,
        :linkedStandaloneSubscribedDataSetName, :expectedEncoding)
end

function Base.getproperty(x::Ptr{UA_DataSetReaderConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :publisherId && return Ptr{UA_Variant}(x + 16)
    f === :writerGroupId && return Ptr{UA_UInt16}(x + 64)
    f === :dataSetWriterId && return Ptr{UA_UInt16}(x + 66)
    f === :dataSetMetaData && return Ptr{UA_DataSetMetaDataType}(x + 72)
    f === :dataSetFieldContentMask && return Ptr{UA_DataSetFieldContentMask}(x + 224)
    f === :messageReceiveTimeout && return Ptr{UA_Double}(x + 232)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 240)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 288)
    f === :subscribedDataSetType && return Ptr{UA_SubscribedDataSetEnumType}(x + 336)
    f === :subscribedDataSet && return Ptr{__JL_Ctag_38}(x + 344)
    f === :linkedStandaloneSubscribedDataSetName && return Ptr{UA_String}(x + 360)
    f === :expectedEncoding && return Ptr{UA_PubSubRtEncoding}(x + 376)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataSetReaderConfig, f::Symbol)
    r = Ref{UA_DataSetReaderConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataSetReaderConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataSetReaderConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_DataSetReaderConfig_copy(src, dst)
    @ccall libopen62541.UA_DataSetReaderConfig_copy(
        src::Ptr{UA_DataSetReaderConfig}, dst::Ptr{UA_DataSetReaderConfig})::UA_StatusCode
end

function UA_DataSetReaderConfig_clear(cfg)
    @ccall libopen62541.UA_DataSetReaderConfig_clear(cfg::Ptr{UA_DataSetReaderConfig})::Cvoid
end

function UA_Server_DataSetReader_updateConfig(
        server, dataSetReaderIdentifier, readerGroupIdentifier, config)
    @ccall libopen62541.UA_Server_DataSetReader_updateConfig(
        server::Ptr{UA_Server}, dataSetReaderIdentifier::UA_NodeId,
        readerGroupIdentifier::UA_NodeId,
        config::Ptr{UA_DataSetReaderConfig})::UA_StatusCode
end

function UA_Server_DataSetReader_getConfig(server, dataSetReaderIdentifier, config)
    @ccall libopen62541.UA_Server_DataSetReader_getConfig(
        server::Ptr{UA_Server}, dataSetReaderIdentifier::UA_NodeId,
        config::Ptr{UA_DataSetReaderConfig})::UA_StatusCode
end

function UA_Server_DataSetReader_getState(server, dataSetReaderIdentifier, state)
    @ccall libopen62541.UA_Server_DataSetReader_getState(
        server::Ptr{UA_Server}, dataSetReaderIdentifier::UA_NodeId,
        state::Ptr{UA_PubSubState})::UA_StatusCode
end

struct __JL_Ctag_53
    data::NTuple{16, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_53}) = (:target,)
Base.fieldnames(::Type{Ptr{__JL_Ctag_53}}) = (:target,)

function Base.getproperty(x::Ptr{__JL_Ctag_53}, f::Symbol)
    f === :target && return Ptr{UA_TargetVariablesDataType}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_53, f::Symbol)
    r = Ref{__JL_Ctag_53}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_53}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_53}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StandaloneSubscribedDataSetConfig
    data::NTuple{200, UInt8}
end

function Base.fieldnames(::Type{UA_StandaloneSubscribedDataSetConfig})
    (:name, :subscribedDataSetType, :subscribedDataSet, :dataSetMetaData, :isConnected)
end
function Base.fieldnames(::Type{Ptr{UA_StandaloneSubscribedDataSetConfig}})
    (:name, :subscribedDataSetType, :subscribedDataSet, :dataSetMetaData, :isConnected)
end

function Base.getproperty(x::Ptr{UA_StandaloneSubscribedDataSetConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :subscribedDataSetType && return Ptr{UA_SubscribedDataSetEnumType}(x + 16)
    f === :subscribedDataSet && return Ptr{__JL_Ctag_53}(x + 24)
    f === :dataSetMetaData && return Ptr{UA_DataSetMetaDataType}(x + 40)
    f === :isConnected && return Ptr{UA_Boolean}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StandaloneSubscribedDataSetConfig, f::Symbol)
    r = Ref{UA_StandaloneSubscribedDataSetConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StandaloneSubscribedDataSetConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StandaloneSubscribedDataSetConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_StandaloneSubscribedDataSetConfig_clear(sdsConfig)
    @ccall libopen62541.UA_StandaloneSubscribedDataSetConfig_clear(sdsConfig::Ptr{UA_StandaloneSubscribedDataSetConfig})::Cvoid
end

function UA_Server_addStandaloneSubscribedDataSet(
        server, subscribedDataSetConfig, sdsIdentifier)
    @ccall libopen62541.UA_Server_addStandaloneSubscribedDataSet(server::Ptr{UA_Server},
        subscribedDataSetConfig::Ptr{UA_StandaloneSubscribedDataSetConfig},
        sdsIdentifier::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_removeStandaloneSubscribedDataSet(server, sds)
    @ccall libopen62541.UA_Server_removeStandaloneSubscribedDataSet(
        server::Ptr{UA_Server}, sds::UA_NodeId)::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReaderGroupConfig
    data::NTuple{104, UInt8}
end

function Base.fieldnames(::Type{UA_ReaderGroupConfig})
    (:name, :rtLevel, :groupProperties, :encodingMimeType,
        :transportSettings, :securityMode)
end
function Base.fieldnames(::Type{Ptr{UA_ReaderGroupConfig}})
    (:name, :rtLevel, :groupProperties, :encodingMimeType,
        :transportSettings, :securityMode)
end

function Base.getproperty(x::Ptr{UA_ReaderGroupConfig}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :rtLevel && return Ptr{UA_PubSubRTLevel}(x + 16)
    f === :groupProperties && return Ptr{UA_KeyValueMap}(x + 24)
    f === :encodingMimeType && return Ptr{UA_PubSubEncodingType}(x + 40)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 48)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 96)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReaderGroupConfig, f::Symbol)
    r = Ref{UA_ReaderGroupConfig}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReaderGroupConfig}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReaderGroupConfig}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_ReaderGroupConfig_clear(readerGroupConfig)
    @ccall libopen62541.UA_ReaderGroupConfig_clear(readerGroupConfig::Ptr{UA_ReaderGroupConfig})::Cvoid
end

function UA_Server_addDataSetReader(
        server, readerGroupIdentifier, dataSetReaderConfig, readerIdentifier)
    @ccall libopen62541.UA_Server_addDataSetReader(
        server::Ptr{UA_Server}, readerGroupIdentifier::UA_NodeId,
        dataSetReaderConfig::Ptr{UA_DataSetReaderConfig},
        readerIdentifier::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_removeDataSetReader(server, readerIdentifier)
    @ccall libopen62541.UA_Server_removeDataSetReader(
        server::Ptr{UA_Server}, readerIdentifier::UA_NodeId)::UA_StatusCode
end

function UA_Server_ReaderGroup_getConfig(server, readerGroupIdentifier, config)
    @ccall libopen62541.UA_Server_ReaderGroup_getConfig(
        server::Ptr{UA_Server}, readerGroupIdentifier::UA_NodeId,
        config::Ptr{UA_ReaderGroupConfig})::UA_StatusCode
end

function UA_Server_ReaderGroup_getState(server, readerGroupIdentifier, state)
    @ccall libopen62541.UA_Server_ReaderGroup_getState(
        server::Ptr{UA_Server}, readerGroupIdentifier::UA_NodeId,
        state::Ptr{UA_PubSubState})::UA_StatusCode
end

function UA_Server_addReaderGroup(
        server, connectionIdentifier, readerGroupConfig, readerGroupIdentifier)
    @ccall libopen62541.UA_Server_addReaderGroup(
        server::Ptr{UA_Server}, connectionIdentifier::UA_NodeId,
        readerGroupConfig::Ptr{UA_ReaderGroupConfig},
        readerGroupIdentifier::Ptr{UA_NodeId})::UA_StatusCode
end

function UA_Server_removeReaderGroup(server, groupIdentifier)
    @ccall libopen62541.UA_Server_removeReaderGroup(
        server::Ptr{UA_Server}, groupIdentifier::UA_NodeId)::UA_StatusCode
end

function UA_Server_freezeReaderGroupConfiguration(server, readerGroupId)
    @ccall libopen62541.UA_Server_freezeReaderGroupConfiguration(
        server::Ptr{UA_Server}, readerGroupId::UA_NodeId)::UA_StatusCode
end

function UA_Server_unfreezeReaderGroupConfiguration(server, readerGroupId)
    @ccall libopen62541.UA_Server_unfreezeReaderGroupConfiguration(
        server::Ptr{UA_Server}, readerGroupId::UA_NodeId)::UA_StatusCode
end

function UA_Server_setReaderGroupOperational(server, readerGroupId)
    @ccall libopen62541.UA_Server_setReaderGroupOperational(
        server::Ptr{UA_Server}, readerGroupId::UA_NodeId)::UA_StatusCode
end

function UA_Server_setReaderGroupDisabled(server, readerGroupId)
    @ccall libopen62541.UA_Server_setReaderGroupDisabled(
        server::Ptr{UA_Server}, readerGroupId::UA_NodeId)::UA_StatusCode
end

function UA_String_fromChars(src)
    @ccall libopen62541.UA_String_fromChars(src::Cstring)::UA_String
end

function UA_clear(p, type)
    @ccall libopen62541.UA_clear(p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

const UA_SByte = Int8

const UA_Int16 = Int16

const UA_Float = Cfloat

function UA_StatusCode_name(code)
    @ccall libopen62541.UA_StatusCode_name(code::UA_StatusCode)::Cstring
end

function UA_String_isEmpty(s)
    @ccall libopen62541.UA_String_isEmpty(s::Ptr{UA_String})::UA_Boolean
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

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DateTimeStruct
    nanoSec::UA_UInt16
    microSec::UA_UInt16
    milliSec::UA_UInt16
    sec::UA_UInt16
    min::UA_UInt16
    hour::UA_UInt16
    day::UA_UInt16
    month::UA_UInt16
    year::UA_Int16
end

function UA_DateTime_toStruct(t)
    @ccall libopen62541.UA_DateTime_toStruct(t::UA_DateTime)::UA_DateTimeStruct
end

function UA_DateTime_fromStruct(ts)
    @ccall libopen62541.UA_DateTime_fromStruct(ts::UA_DateTimeStruct)::UA_DateTime
end

function UA_Guid_print(guid, output)
    @ccall libopen62541.UA_Guid_print(
        guid::Ptr{UA_Guid}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_Guid_parse(guid, str)
    @ccall libopen62541.UA_Guid_parse(guid::Ptr{UA_Guid}, str::UA_String)::UA_StatusCode
end

function UA_ByteString_allocBuffer(bs, length)
    @ccall libopen62541.UA_ByteString_allocBuffer(
        bs::Ptr{UA_ByteString}, length::Csize_t)::UA_StatusCode
end

function UA_ByteString_toBase64(bs, output)
    @ccall libopen62541.UA_ByteString_toBase64(
        bs::Ptr{UA_ByteString}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_ByteString_fromBase64(bs, input)
    @ccall libopen62541.UA_ByteString_fromBase64(
        bs::Ptr{UA_ByteString}, input::Ptr{UA_String})::UA_StatusCode
end

function UA_ByteString_hash(initialHashValue, data, size)
    @ccall libopen62541.UA_ByteString_hash(
        initialHashValue::UA_UInt32, data::Ptr{UA_Byte}, size::Csize_t)::UA_UInt32
end

const UA_XmlElement = UA_String

function UA_NodeId_isNull(p)
    @ccall libopen62541.UA_NodeId_isNull(p::Ptr{UA_NodeId})::UA_Boolean
end

function UA_NodeId_print(id, output)
    @ccall libopen62541.UA_NodeId_print(
        id::Ptr{UA_NodeId}, output::Ptr{UA_String})::UA_StatusCode
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

function UA_ExpandedNodeId_print(id, output)
    @ccall libopen62541.UA_ExpandedNodeId_print(
        id::Ptr{UA_ExpandedNodeId}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_ExpandedNodeId_parse(id, str)
    @ccall libopen62541.UA_ExpandedNodeId_parse(
        id::Ptr{UA_ExpandedNodeId}, str::UA_String)::UA_StatusCode
end

function UA_ExpandedNodeId_isLocal(n)
    @ccall libopen62541.UA_ExpandedNodeId_isLocal(n::Ptr{UA_ExpandedNodeId})::UA_Boolean
end

function UA_ExpandedNodeId_order(n1, n2)
    @ccall libopen62541.UA_ExpandedNodeId_order(
        n1::Ptr{UA_ExpandedNodeId}, n2::Ptr{UA_ExpandedNodeId})::UA_Order
end

function UA_ExpandedNodeId_hash(n)
    @ccall libopen62541.UA_ExpandedNodeId_hash(n::Ptr{UA_ExpandedNodeId})::UA_UInt32
end

function UA_QualifiedName_hash(q)
    @ccall libopen62541.UA_QualifiedName_hash(q::Ptr{UA_QualifiedName})::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_NumericRangeDimension
    min::UA_UInt32
    max::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_NumericRange
    dimensionsSize::Csize_t
    dimensions::Ptr{UA_NumericRangeDimension}
end

function UA_NumericRange_parse(range, str)
    @ccall libopen62541.UA_NumericRange_parse(
        range::Ptr{UA_NumericRange}, str::UA_String)::UA_StatusCode
end

function UA_Variant_setScalar(v, p, type)
    @ccall libopen62541.UA_Variant_setScalar(
        v::Ptr{UA_Variant}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_Variant_setScalarCopy(v, p, type)
    @ccall libopen62541.UA_Variant_setScalarCopy(
        v::Ptr{UA_Variant}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Variant_setArray(v, array, arraySize, type)
    @ccall libopen62541.UA_Variant_setArray(v::Ptr{UA_Variant}, array::Ptr{Cvoid},
        arraySize::Csize_t, type::Ptr{UA_DataType})::Cvoid
end

function UA_Variant_setArrayCopy(v, array, arraySize, type)
    @ccall libopen62541.UA_Variant_setArrayCopy(
        v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t,
        type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Variant_copyRange(src, dst, range)
    @ccall libopen62541.UA_Variant_copyRange(
        src::Ptr{UA_Variant}, dst::Ptr{UA_Variant}, range::UA_NumericRange)::UA_StatusCode
end

function UA_Variant_setRange(v, array, arraySize, range)
    @ccall libopen62541.UA_Variant_setRange(
        v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t,
        range::UA_NumericRange)::UA_StatusCode
end

function UA_Variant_setRangeCopy(v, array, arraySize, range)
    @ccall libopen62541.UA_Variant_setRangeCopy(
        v::Ptr{UA_Variant}, array::Ptr{Cvoid}, arraySize::Csize_t,
        range::UA_NumericRange)::UA_StatusCode
end

function UA_ExtensionObject_setValue(eo, p, type)
    @ccall libopen62541.UA_ExtensionObject_setValue(
        eo::Ptr{UA_ExtensionObject}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_ExtensionObject_setValueNoDelete(eo, p, type)
    @ccall libopen62541.UA_ExtensionObject_setValueNoDelete(
        eo::Ptr{UA_ExtensionObject}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_ExtensionObject_setValueCopy(eo, p, type)
    @ccall libopen62541.UA_ExtensionObject_setValueCopy(
        eo::Ptr{UA_ExtensionObject}, p::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_DataValue_copyVariantRange(src, dst, range)
    @ccall libopen62541.UA_DataValue_copyVariantRange(
        src::Ptr{UA_DataValue}, dst::Ptr{UA_DataValue},
        range::UA_NumericRange)::UA_StatusCode
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

function UA_DataType_getStructMember(type, memberName, outOffset, outMemberType, outIsArray)
    @ccall libopen62541.UA_DataType_getStructMember(
        type::Ptr{UA_DataType}, memberName::Cstring, outOffset::Ptr{Csize_t},
        outMemberType::Ptr{Ptr{UA_DataType}}, outIsArray::Ptr{UA_Boolean})::UA_Boolean
end

function UA_DataType_isNumeric(type)
    @ccall libopen62541.UA_DataType_isNumeric(type::Ptr{UA_DataType})::UA_Boolean
end

function UA_findDataType(typeId)
    @ccall libopen62541.UA_findDataType(typeId::Ptr{UA_NodeId})::Ptr{UA_DataType}
end

function UA_findDataTypeWithCustom(typeId, customTypes)
    @ccall libopen62541.UA_findDataTypeWithCustom(
        typeId::Ptr{UA_NodeId}, customTypes::Ptr{UA_DataTypeArray})::Ptr{UA_DataType}
end

function UA_new(type)
    @ccall libopen62541.UA_new(type::Ptr{UA_DataType})::Ptr{Cvoid}
end

function UA_copy(src, dst, type)
    @ccall libopen62541.UA_copy(
        src::Ptr{Cvoid}, dst::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_delete(p, type)
    @ccall libopen62541.UA_delete(p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Cvoid
end

function UA_print(p, type, output)
    @ccall libopen62541.UA_print(
        p::Ptr{Cvoid}, type::Ptr{UA_DataType}, output::Ptr{UA_String})::UA_StatusCode
end

function UA_order(p1, p2, type)
    @ccall libopen62541.UA_order(
        p1::Ptr{Cvoid}, p2::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_Order
end

function UA_calcSizeBinary(p, type)
    @ccall libopen62541.UA_calcSizeBinary(p::Ptr{Cvoid}, type::Ptr{UA_DataType})::Csize_t
end

function UA_encodeBinary(p, type, outBuf)
    @ccall libopen62541.UA_encodeBinary(
        p::Ptr{Cvoid}, type::Ptr{UA_DataType}, outBuf::Ptr{UA_ByteString})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DecodeBinaryOptions
    customTypes::Ptr{UA_DataTypeArray}
end

function UA_decodeBinary(inBuf, p, type, options)
    @ccall libopen62541.UA_decodeBinary(
        inBuf::Ptr{UA_ByteString}, p::Ptr{Cvoid}, type::Ptr{UA_DataType},
        options::Ptr{UA_DecodeBinaryOptions})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EncodeJsonOptions
    namespaces::Ptr{UA_String}
    namespacesSize::Csize_t
    serverUris::Ptr{UA_String}
    serverUrisSize::Csize_t
    useReversible::UA_Boolean
    prettyPrint::UA_Boolean
    unquotedKeys::UA_Boolean
    stringNodeIds::UA_Boolean
end

function UA_calcSizeJson(src, type, options)
    @ccall libopen62541.UA_calcSizeJson(src::Ptr{Cvoid}, type::Ptr{UA_DataType},
        options::Ptr{UA_EncodeJsonOptions})::Csize_t
end

function UA_encodeJson(src, type, outBuf, options)
    @ccall libopen62541.UA_encodeJson(
        src::Ptr{Cvoid}, type::Ptr{UA_DataType}, outBuf::Ptr{UA_ByteString},
        options::Ptr{UA_EncodeJsonOptions})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DecodeJsonOptions
    namespaces::Ptr{UA_String}
    namespacesSize::Csize_t
    serverUris::Ptr{UA_String}
    serverUrisSize::Csize_t
    customTypes::Ptr{UA_DataTypeArray}
end

function UA_decodeJson(src, dst, type, options)
    @ccall libopen62541.UA_decodeJson(
        src::Ptr{UA_ByteString}, dst::Ptr{Cvoid}, type::Ptr{UA_DataType},
        options::Ptr{UA_DecodeJsonOptions})::UA_StatusCode
end

function UA_Array_new(size, type)
    @ccall libopen62541.UA_Array_new(size::Csize_t, type::Ptr{UA_DataType})::Ptr{Cvoid}
end

function UA_Array_copy(src, size, dst, type)
    @ccall libopen62541.UA_Array_copy(src::Ptr{Cvoid}, size::Csize_t, dst::Ptr{Ptr{Cvoid}},
        type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Array_resize(p, size, newSize, type)
    @ccall libopen62541.UA_Array_resize(p::Ptr{Ptr{Cvoid}}, size::Ptr{Csize_t},
        newSize::Csize_t, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Array_append(p, size, newElem, type)
    @ccall libopen62541.UA_Array_append(p::Ptr{Ptr{Cvoid}}, size::Ptr{Csize_t},
        newElem::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Array_appendCopy(p, size, newElem, type)
    @ccall libopen62541.UA_Array_appendCopy(p::Ptr{Ptr{Cvoid}}, size::Ptr{Csize_t},
        newElem::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Array_delete(p, size, type)
    @ccall libopen62541.UA_Array_delete(
        p::Ptr{Cvoid}, size::Csize_t, type::Ptr{UA_DataType})::Cvoid
end

@cenum UA_NamingRuleType::UInt32 begin
    UA_NAMINGRULETYPE_MANDATORY = 1
    UA_NAMINGRULETYPE_OPTIONAL = 2
    UA_NAMINGRULETYPE_CONSTRAINT = 3
    __UA_NAMINGRULETYPE_FORCE32BIT = 2147483647
end

@cenum UA_Enumeration::UInt32 begin
    __UA_ENUMERATION_FORCE32BIT = 2147483647
end

const UA_ImageBMP = UA_ByteString

const UA_ImageGIF = UA_ByteString

const UA_ImageJPG = UA_ByteString

const UA_ImagePNG = UA_ByteString

const UA_AudioDataType = UA_ByteString

const UA_UriString = UA_String
const UA_BitFieldMaskDataType = UA_UInt64

const UA_SemanticVersionString = UA_String

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AdditionalParametersType
    parametersSize::Csize_t
    parameters::Ptr{UA_KeyValuePair}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EphemeralKeyType
    publicKey::UA_ByteString
    signature::UA_ByteString
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RationalNumber
    numerator::UA_Int32
    denominator::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ThreeDVector
    x::UA_Double
    y::UA_Double
    z::UA_Double
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ThreeDCartesianCoordinates
    x::UA_Double
    y::UA_Double
    z::UA_Double
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ThreeDOrientation
    a::UA_Double
    b::UA_Double
    c::UA_Double
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ThreeDFrame
    cartesianCoordinates::UA_ThreeDCartesianCoordinates
    orientation::UA_ThreeDOrientation
end

@cenum UA_OpenFileMode::UInt32 begin
    UA_OPENFILEMODE_READ = 1
    UA_OPENFILEMODE_WRITE = 2
    UA_OPENFILEMODE_ERASEEXISTING = 4
    UA_OPENFILEMODE_APPEND = 8
    __UA_OPENFILEMODE_FORCE32BIT = 2147483647
end

@cenum UA_IdentityCriteriaType::UInt32 begin
    UA_IDENTITYCRITERIATYPE_USERNAME = 1
    UA_IDENTITYCRITERIATYPE_THUMBPRINT = 2
    UA_IDENTITYCRITERIATYPE_ROLE = 3
    UA_IDENTITYCRITERIATYPE_GROUPID = 4
    UA_IDENTITYCRITERIATYPE_ANONYMOUS = 5
    UA_IDENTITYCRITERIATYPE_AUTHENTICATEDUSER = 6
    UA_IDENTITYCRITERIATYPE_APPLICATION = 7
    UA_IDENTITYCRITERIATYPE_X509SUBJECT = 8
    __UA_IDENTITYCRITERIATYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_IdentityMappingRuleType
    criteriaType::UA_IdentityCriteriaType
    criteria::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CurrencyUnitType
    numericCode::UA_Int16
    exponent::UA_SByte
    alphabeticCode::UA_String
    currency::UA_LocalizedText
end

@cenum UA_TrustListMasks::UInt32 begin
    UA_TRUSTLISTMASKS_NONE = 0
    UA_TRUSTLISTMASKS_TRUSTEDCERTIFICATES = 1
    UA_TRUSTLISTMASKS_TRUSTEDCRLS = 2
    UA_TRUSTLISTMASKS_ISSUERCERTIFICATES = 4
    UA_TRUSTLISTMASKS_ISSUERCRLS = 8
    UA_TRUSTLISTMASKS_ALL = 15
    __UA_TRUSTLISTMASKS_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TrustListDataType
    specifiedLists::UA_UInt32
    trustedCertificatesSize::Csize_t
    trustedCertificates::Ptr{UA_ByteString}
    trustedCrlsSize::Csize_t
    trustedCrls::Ptr{UA_ByteString}
    issuerCertificatesSize::Csize_t
    issuerCertificates::Ptr{UA_ByteString}
    issuerCrlsSize::Csize_t
    issuerCrls::Ptr{UA_ByteString}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DecimalDataType
    scale::UA_Int16
    value::UA_ByteString
end

struct UA_DataTypeDescription
    data::NTuple{48, UInt8}
end

Base.fieldnames(::Type{UA_DataTypeDescription}) = (:dataTypeId, :name)
Base.fieldnames(::Type{Ptr{UA_DataTypeDescription}}) = (:dataTypeId, :name)

function Base.getproperty(x::Ptr{UA_DataTypeDescription}, f::Symbol)
    f === :dataTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :name && return Ptr{UA_QualifiedName}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataTypeDescription, f::Symbol)
    r = Ref{UA_DataTypeDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataTypeDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataTypeDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PortableQualifiedName
    namespaceUri::UA_String
    name::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PortableNodeId
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{UA_PortableNodeId}) = (:namespaceUri, :identifier)
Base.fieldnames(::Type{Ptr{UA_PortableNodeId}}) = (:namespaceUri, :identifier)

function Base.getproperty(x::Ptr{UA_PortableNodeId}, f::Symbol)
    f === :namespaceUri && return Ptr{UA_String}(x + 0)
    f === :identifier && return Ptr{UA_NodeId}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PortableNodeId, f::Symbol)
    r = Ref{UA_PortableNodeId}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PortableNodeId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PortableNodeId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UnsignedRationalNumber
    numerator::UA_UInt32
    denominator::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedDataItemsDataType
    publishedDataSize::Csize_t
    publishedData::Ptr{UA_PublishedVariableDataType}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedDataSetCustomSourceDataType
    cyclicDataSet::UA_Boolean
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetWriterDataType
    data::NTuple{160, UInt8}
end

function Base.fieldnames(::Type{UA_DataSetWriterDataType})
    (:name, :enabled, :dataSetWriterId, :dataSetFieldContentMask,
        :keyFrameCount, :dataSetName, :dataSetWriterPropertiesSize,
        :dataSetWriterProperties, :transportSettings, :messageSettings)
end
function Base.fieldnames(::Type{Ptr{UA_DataSetWriterDataType}})
    (:name, :enabled, :dataSetWriterId, :dataSetFieldContentMask,
        :keyFrameCount, :dataSetName, :dataSetWriterPropertiesSize,
        :dataSetWriterProperties, :transportSettings, :messageSettings)
end

function Base.getproperty(x::Ptr{UA_DataSetWriterDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :dataSetWriterId && return Ptr{UA_UInt16}(x + 18)
    f === :dataSetFieldContentMask && return Ptr{UA_DataSetFieldContentMask}(x + 20)
    f === :keyFrameCount && return Ptr{UA_UInt32}(x + 24)
    f === :dataSetName && return Ptr{UA_String}(x + 32)
    f === :dataSetWriterPropertiesSize && return Ptr{Csize_t}(x + 48)
    f === :dataSetWriterProperties && return Ptr{Ptr{UA_KeyValuePair}}(x + 56)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 64)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataSetWriterDataType, f::Symbol)
    r = Ref{UA_DataSetWriterDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataSetWriterDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataSetWriterDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_NetworkAddressDataType
    networkInterface::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_NetworkAddressUrlDataType
    networkInterface::UA_String
    url::UA_String
end
function Base.getproperty(x::Ptr{UA_NetworkAddressUrlDataType}, f::Symbol)
    f === :networkInterface && return Ptr{UA_String}(x + 0)
    f === :url && return Ptr{UA_String}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_NetworkAddressUrlDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StandaloneSubscribedDataSetRefDataType
    dataSetName::UA_String
end

@cenum UA_DataSetOrderingType::UInt32 begin
    UA_DATASETORDERINGTYPE_UNDEFINED = 0
    UA_DATASETORDERINGTYPE_ASCENDINGWRITERID = 1
    UA_DATASETORDERINGTYPE_ASCENDINGWRITERIDSINGLE = 2
    __UA_DATASETORDERINGTYPE_FORCE32BIT = 2147483647
end
const UA_UadpNetworkMessageContentMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UadpWriterGroupMessageDataType
    groupVersion::UA_UInt32
    dataSetOrdering::UA_DataSetOrderingType
    networkMessageContentMask::UA_UadpNetworkMessageContentMask
    samplingOffset::UA_Double
    publishingOffsetSize::Csize_t
    publishingOffset::Ptr{UA_Double}
end
function Base.getproperty(x::Ptr{UA_UadpWriterGroupMessageDataType}, f::Symbol)
    f === :groupVersion && return Ptr{UA_UInt32}(x + 0)
    f === :dataSetOrdering && return Ptr{UA_DataSetOrderingType}(x + 4)
    f === :networkMessageContentMask && return Ptr{UA_UadpNetworkMessageContentMask}(x + 8)
    f === :samplingOffset && return Ptr{UA_Double}(x + 16)
    f === :publishingOffsetSize && return Ptr{Csize_t}(x + 24)
    f === :publishingOffset && return Ptr{Ptr{UA_Double}}(x + 32)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_UadpWriterGroupMessageDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_UadpDataSetMessageContentMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UadpDataSetWriterMessageDataType
    dataSetMessageContentMask::UA_UadpDataSetMessageContentMask
    configuredSize::UA_UInt16
    networkMessageNumber::UA_UInt16
    dataSetOffset::UA_UInt16
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UadpDataSetReaderMessageDataType
    groupVersion::UA_UInt32
    networkMessageNumber::UA_UInt16
    dataSetOffset::UA_UInt16
    dataSetClassId::UA_Guid
    networkMessageContentMask::UA_UadpNetworkMessageContentMask
    dataSetMessageContentMask::UA_UadpDataSetMessageContentMask
    publishingInterval::UA_Double
    receiveOffset::UA_Double
    processingOffset::UA_Double
end
const UA_JsonNetworkMessageContentMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_JsonWriterGroupMessageDataType
    networkMessageContentMask::UA_JsonNetworkMessageContentMask
end
const UA_JsonDataSetMessageContentMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_JsonDataSetWriterMessageDataType
    dataSetMessageContentMask::UA_JsonDataSetMessageContentMask
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_JsonDataSetReaderMessageDataType
    networkMessageContentMask::UA_JsonNetworkMessageContentMask
    dataSetMessageContentMask::UA_JsonDataSetMessageContentMask
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TransmitQosPriorityDataType
    priorityLabel::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReceiveQosPriorityDataType
    priorityLabel::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DatagramConnectionTransportDataType
    data::NTuple{48, UInt8}
end

Base.fieldnames(::Type{UA_DatagramConnectionTransportDataType}) = (:discoveryAddress,)
Base.fieldnames(::Type{Ptr{UA_DatagramConnectionTransportDataType}}) = (:discoveryAddress,)

function Base.getproperty(x::Ptr{UA_DatagramConnectionTransportDataType}, f::Symbol)
    f === :discoveryAddress && return Ptr{UA_ExtensionObject}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DatagramConnectionTransportDataType, f::Symbol)
    r = Ref{UA_DatagramConnectionTransportDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DatagramConnectionTransportDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DatagramConnectionTransportDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DatagramConnectionTransport2DataType
    data::NTuple{88, UInt8}
end

function Base.fieldnames(::Type{UA_DatagramConnectionTransport2DataType})
    (:discoveryAddress, :discoveryAnnounceRate, :discoveryMaxMessageSize,
        :qosCategory, :datagramQosSize, :datagramQos)
end
function Base.fieldnames(::Type{Ptr{UA_DatagramConnectionTransport2DataType}})
    (:discoveryAddress, :discoveryAnnounceRate, :discoveryMaxMessageSize,
        :qosCategory, :datagramQosSize, :datagramQos)
end

function Base.getproperty(x::Ptr{UA_DatagramConnectionTransport2DataType}, f::Symbol)
    f === :discoveryAddress && return Ptr{UA_ExtensionObject}(x + 0)
    f === :discoveryAnnounceRate && return Ptr{UA_UInt32}(x + 48)
    f === :discoveryMaxMessageSize && return Ptr{UA_UInt32}(x + 52)
    f === :qosCategory && return Ptr{UA_String}(x + 56)
    f === :datagramQosSize && return Ptr{Csize_t}(x + 72)
    f === :datagramQos && return Ptr{Ptr{UA_ExtensionObject}}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DatagramConnectionTransport2DataType, f::Symbol)
    r = Ref{UA_DatagramConnectionTransport2DataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DatagramConnectionTransport2DataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DatagramConnectionTransport2DataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DatagramWriterGroupTransportDataType
    messageRepeatCount::UA_Byte
    messageRepeatDelay::UA_Double
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DatagramWriterGroupTransport2DataType
    data::NTuple{120, UInt8}
end

function Base.fieldnames(::Type{UA_DatagramWriterGroupTransport2DataType})
    (:messageRepeatCount, :messageRepeatDelay, :address, :qosCategory,
        :datagramQosSize, :datagramQos, :discoveryAnnounceRate, :topic)
end
function Base.fieldnames(::Type{Ptr{UA_DatagramWriterGroupTransport2DataType}})
    (:messageRepeatCount, :messageRepeatDelay, :address, :qosCategory,
        :datagramQosSize, :datagramQos, :discoveryAnnounceRate, :topic)
end

function Base.getproperty(x::Ptr{UA_DatagramWriterGroupTransport2DataType}, f::Symbol)
    f === :messageRepeatCount && return Ptr{UA_Byte}(x + 0)
    f === :messageRepeatDelay && return Ptr{UA_Double}(x + 8)
    f === :address && return Ptr{UA_ExtensionObject}(x + 16)
    f === :qosCategory && return Ptr{UA_String}(x + 64)
    f === :datagramQosSize && return Ptr{Csize_t}(x + 80)
    f === :datagramQos && return Ptr{Ptr{UA_ExtensionObject}}(x + 88)
    f === :discoveryAnnounceRate && return Ptr{UA_UInt32}(x + 96)
    f === :topic && return Ptr{UA_String}(x + 104)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DatagramWriterGroupTransport2DataType, f::Symbol)
    r = Ref{UA_DatagramWriterGroupTransport2DataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DatagramWriterGroupTransport2DataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DatagramWriterGroupTransport2DataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DatagramDataSetReaderTransportDataType
    data::NTuple{96, UInt8}
end

function Base.fieldnames(::Type{UA_DatagramDataSetReaderTransportDataType})
    (:address, :qosCategory, :datagramQosSize, :datagramQos, :topic)
end
function Base.fieldnames(::Type{Ptr{UA_DatagramDataSetReaderTransportDataType}})
    (:address, :qosCategory, :datagramQosSize, :datagramQos, :topic)
end

function Base.getproperty(x::Ptr{UA_DatagramDataSetReaderTransportDataType}, f::Symbol)
    f === :address && return Ptr{UA_ExtensionObject}(x + 0)
    f === :qosCategory && return Ptr{UA_String}(x + 48)
    f === :datagramQosSize && return Ptr{Csize_t}(x + 64)
    f === :datagramQos && return Ptr{Ptr{UA_ExtensionObject}}(x + 72)
    f === :topic && return Ptr{UA_String}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DatagramDataSetReaderTransportDataType, f::Symbol)
    r = Ref{UA_DatagramDataSetReaderTransportDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DatagramDataSetReaderTransportDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DatagramDataSetReaderTransportDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrokerConnectionTransportDataType
    resourceUri::UA_String
    authenticationProfileUri::UA_String
end

@cenum UA_BrokerTransportQualityOfService::UInt32 begin
    UA_BROKERTRANSPORTQUALITYOFSERVICE_NOTSPECIFIED = 0
    UA_BROKERTRANSPORTQUALITYOFSERVICE_BESTEFFORT = 1
    UA_BROKERTRANSPORTQUALITYOFSERVICE_ATLEASTONCE = 2
    UA_BROKERTRANSPORTQUALITYOFSERVICE_ATMOSTONCE = 3
    UA_BROKERTRANSPORTQUALITYOFSERVICE_EXACTLYONCE = 4
    __UA_BROKERTRANSPORTQUALITYOFSERVICE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrokerWriterGroupTransportDataType
    queueName::UA_String
    resourceUri::UA_String
    authenticationProfileUri::UA_String
    requestedDeliveryGuarantee::UA_BrokerTransportQualityOfService
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrokerDataSetWriterTransportDataType
    queueName::UA_String
    resourceUri::UA_String
    authenticationProfileUri::UA_String
    requestedDeliveryGuarantee::UA_BrokerTransportQualityOfService
    metaDataQueueName::UA_String
    metaDataUpdateTime::UA_Double
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrokerDataSetReaderTransportDataType
    queueName::UA_String
    resourceUri::UA_String
    authenticationProfileUri::UA_String
    requestedDeliveryGuarantee::UA_BrokerTransportQualityOfService
    metaDataQueueName::UA_String
end
const UA_PubSubConfigurationRefMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConfigurationRefDataType
    configurationMask::UA_PubSubConfigurationRefMask
    elementIndex::UA_UInt16
    connectionIndex::UA_UInt16
    groupIndex::UA_UInt16
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConfigurationValueDataType
    configurationElement::UA_PubSubConfigurationRefDataType
    name::UA_String
    identifier::UA_Variant
end

@cenum UA_DiagnosticsLevel::UInt32 begin
    UA_DIAGNOSTICSLEVEL_BASIC = 0
    UA_DIAGNOSTICSLEVEL_ADVANCED = 1
    UA_DIAGNOSTICSLEVEL_INFO = 2
    UA_DIAGNOSTICSLEVEL_LOG = 3
    UA_DIAGNOSTICSLEVEL_DEBUG = 4
    __UA_DIAGNOSTICSLEVEL_FORCE32BIT = 2147483647
end

@cenum UA_PubSubDiagnosticsCounterClassification::UInt32 begin
    UA_PUBSUBDIAGNOSTICSCOUNTERCLASSIFICATION_INFORMATION = 0
    UA_PUBSUBDIAGNOSTICSCOUNTERCLASSIFICATION_ERROR = 1
    __UA_PUBSUBDIAGNOSTICSCOUNTERCLASSIFICATION_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AliasNameDataType
    aliasName::UA_QualifiedName
    referencedNodesSize::Csize_t
    referencedNodes::Ptr{UA_ExpandedNodeId}
end
const UA_PasswordOptionsMask = UA_UInt32
const UA_UserConfigurationMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UserManagementDataType
    userName::UA_String
    userConfiguration::UA_UserConfigurationMask
    description::UA_String
end

@cenum UA_Duplex::UInt32 begin
    UA_DUPLEX_FULL = 0
    UA_DUPLEX_HALF = 1
    UA_DUPLEX_UNKNOWN = 2
    __UA_DUPLEX_FORCE32BIT = 2147483647
end

@cenum UA_InterfaceAdminStatus::UInt32 begin
    UA_INTERFACEADMINSTATUS_UP = 0
    UA_INTERFACEADMINSTATUS_DOWN = 1
    UA_INTERFACEADMINSTATUS_TESTING = 2
    __UA_INTERFACEADMINSTATUS_FORCE32BIT = 2147483647
end

@cenum UA_InterfaceOperStatus::UInt32 begin
    UA_INTERFACEOPERSTATUS_UP = 0
    UA_INTERFACEOPERSTATUS_DOWN = 1
    UA_INTERFACEOPERSTATUS_TESTING = 2
    UA_INTERFACEOPERSTATUS_UNKNOWN = 3
    UA_INTERFACEOPERSTATUS_DORMANT = 4
    UA_INTERFACEOPERSTATUS_NOTPRESENT = 5
    UA_INTERFACEOPERSTATUS_LOWERLAYERDOWN = 6
    __UA_INTERFACEOPERSTATUS_FORCE32BIT = 2147483647
end

@cenum UA_NegotiationStatus::UInt32 begin
    UA_NEGOTIATIONSTATUS_INPROGRESS = 0
    UA_NEGOTIATIONSTATUS_COMPLETE = 1
    UA_NEGOTIATIONSTATUS_FAILED = 2
    UA_NEGOTIATIONSTATUS_UNKNOWN = 3
    UA_NEGOTIATIONSTATUS_NONEGOTIATION = 4
    __UA_NEGOTIATIONSTATUS_FORCE32BIT = 2147483647
end

@cenum UA_TsnFailureCode::UInt32 begin
    UA_TSNFAILURECODE_NOFAILURE = 0
    UA_TSNFAILURECODE_INSUFFICIENTBANDWIDTH = 1
    UA_TSNFAILURECODE_INSUFFICIENTRESOURCES = 2
    UA_TSNFAILURECODE_INSUFFICIENTTRAFFICCLASSBANDWIDTH = 3
    UA_TSNFAILURECODE_STREAMIDINUSE = 4
    UA_TSNFAILURECODE_STREAMDESTINATIONADDRESSINUSE = 5
    UA_TSNFAILURECODE_STREAMPREEMPTEDBYHIGHERRANK = 6
    UA_TSNFAILURECODE_LATENCYHASCHANGED = 7
    UA_TSNFAILURECODE_EGRESSPORTNOTAVBCAPABLE = 8
    UA_TSNFAILURECODE_USEDIFFERENTDESTINATIONADDRESS = 9
    UA_TSNFAILURECODE_OUTOFMSRPRESOURCES = 10
    UA_TSNFAILURECODE_OUTOFMMRPRESOURCES = 11
    UA_TSNFAILURECODE_CANNOTSTOREDESTINATIONADDRESS = 12
    UA_TSNFAILURECODE_PRIORITYISNOTANSRCCLASS = 13
    UA_TSNFAILURECODE_MAXFRAMESIZETOOLARGE = 14
    UA_TSNFAILURECODE_MAXFANINPORTSLIMITREACHED = 15
    UA_TSNFAILURECODE_FIRSTVALUECHANGEDFORSTREAMID = 16
    UA_TSNFAILURECODE_VLANBLOCKEDONEGRESS = 17
    UA_TSNFAILURECODE_VLANTAGGINGDISABLEDONEGRESS = 18
    UA_TSNFAILURECODE_SRCLASSPRIORITYMISMATCH = 19
    UA_TSNFAILURECODE_FEATURENOTPROPAGATED = 20
    UA_TSNFAILURECODE_MAXLATENCYEXCEEDED = 21
    UA_TSNFAILURECODE_BRIDGEDOESNOTPROVIDENETWORKID = 22
    UA_TSNFAILURECODE_STREAMTRANSFORMNOTSUPPORTED = 23
    UA_TSNFAILURECODE_STREAMIDTYPENOTSUPPORTED = 24
    UA_TSNFAILURECODE_FEATURENOTSUPPORTED = 25
    __UA_TSNFAILURECODE_FORCE32BIT = 2147483647
end

@cenum UA_TsnStreamState::UInt32 begin
    UA_TSNSTREAMSTATE_DISABLED = 0
    UA_TSNSTREAMSTATE_CONFIGURING = 1
    UA_TSNSTREAMSTATE_READY = 2
    UA_TSNSTREAMSTATE_OPERATIONAL = 3
    UA_TSNSTREAMSTATE_ERROR = 4
    __UA_TSNSTREAMSTATE_FORCE32BIT = 2147483647
end

@cenum UA_TsnTalkerStatus::UInt32 begin
    UA_TSNTALKERSTATUS_NONE = 0
    UA_TSNTALKERSTATUS_READY = 1
    UA_TSNTALKERSTATUS_FAILED = 2
    __UA_TSNTALKERSTATUS_FORCE32BIT = 2147483647
end

@cenum UA_TsnListenerStatus::UInt32 begin
    UA_TSNLISTENERSTATUS_NONE = 0
    UA_TSNLISTENERSTATUS_READY = 1
    UA_TSNLISTENERSTATUS_PARTIALFAILED = 2
    UA_TSNLISTENERSTATUS_FAILED = 3
    __UA_TSNLISTENERSTATUS_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PriorityMappingEntryType
    mappingUri::UA_String
    priorityLabel::UA_String
    priorityValue_PCP::UA_Byte
    priorityValue_DSCP::UA_UInt32
end

@cenum UA_IdType::UInt32 begin
    UA_IDTYPE_NUMERIC = 0
    UA_IDTYPE_STRING = 1
    UA_IDTYPE_GUID = 2
    UA_IDTYPE_OPAQUE = 3
    __UA_IDTYPE_FORCE32BIT = 2147483647
end
const UA_PermissionType = UA_UInt32
const UA_AccessLevelType = UA_Byte
const UA_AccessLevelExType = UA_UInt32
const UA_EventNotifierType = UA_Byte
const UA_AccessRestrictionType = UA_UInt16

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RolePermissionType
    data::NTuple{32, UInt8}
end

Base.fieldnames(::Type{UA_RolePermissionType}) = (:roleId, :permissions)
Base.fieldnames(::Type{Ptr{UA_RolePermissionType}}) = (:roleId, :permissions)

function Base.getproperty(x::Ptr{UA_RolePermissionType}, f::Symbol)
    f === :roleId && return Ptr{UA_NodeId}(x + 0)
    f === :permissions && return Ptr{UA_PermissionType}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RolePermissionType, f::Symbol)
    r = Ref{UA_RolePermissionType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RolePermissionType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RolePermissionType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReferenceNode
    data::NTuple{80, UInt8}
end

Base.fieldnames(::Type{UA_ReferenceNode}) = (:referenceTypeId, :isInverse, :targetId)
Base.fieldnames(::Type{Ptr{UA_ReferenceNode}}) = (:referenceTypeId, :isInverse, :targetId)

function Base.getproperty(x::Ptr{UA_ReferenceNode}, f::Symbol)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 0)
    f === :isInverse && return Ptr{UA_Boolean}(x + 24)
    f === :targetId && return Ptr{UA_ExpandedNodeId}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReferenceNode, f::Symbol)
    r = Ref{UA_ReferenceNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReferenceNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReferenceNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EnumValueType
    value::UA_Int64
    displayName::UA_LocalizedText
    description::UA_LocalizedText
end
function Base.getproperty(x::Ptr{UA_EnumValueType}, f::Symbol)
    f === :value && return Ptr{UA_Int64}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EnumValueType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_OptionSet
    value::UA_ByteString
    validBits::UA_ByteString
end

const UA_NormalizedString = UA_String

const UA_DecimalString = UA_String

const UA_DurationString = UA_String

const UA_TimeString = UA_String

const UA_DateString = UA_String
const UA_UtcTime = UA_DateTime

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TimeZoneDataType
    offset::UA_Int16
    daylightSavingInOffset::UA_Boolean
end

const UA_Index = UA_ByteString
const UA_IntegerId = UA_UInt32

const UA_VersionTime = UA_ByteString

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ServiceFault
    data::NTuple{136, UInt8}
end

Base.fieldnames(::Type{UA_ServiceFault}) = (:responseHeader,)
Base.fieldnames(::Type{Ptr{UA_ServiceFault}}) = (:responseHeader,)

function Base.getproperty(x::Ptr{UA_ServiceFault}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ServiceFault, f::Symbol)
    r = Ref{UA_ServiceFault}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ServiceFault}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ServiceFault}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SessionlessInvokeRequestType
    urisVersion::UA_UInt32
    namespaceUrisSize::Csize_t
    namespaceUris::Ptr{UA_String}
    serverUrisSize::Csize_t
    serverUris::Ptr{UA_String}
    localeIdsSize::Csize_t
    localeIds::Ptr{UA_String}
    serviceId::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SessionlessInvokeResponseType
    namespaceUrisSize::Csize_t
    namespaceUris::Ptr{UA_String}
    serverUrisSize::Csize_t
    serverUris::Ptr{UA_String}
    serviceId::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FindServersRequest
    data::NTuple{160, UInt8}
end

function Base.fieldnames(::Type{UA_FindServersRequest})
    (:requestHeader, :endpointUrl, :localeIdsSize, :localeIds, :serverUrisSize, :serverUris)
end
function Base.fieldnames(::Type{Ptr{UA_FindServersRequest}})
    (:requestHeader, :endpointUrl, :localeIdsSize, :localeIds, :serverUrisSize, :serverUris)
end

function Base.getproperty(x::Ptr{UA_FindServersRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :endpointUrl && return Ptr{UA_String}(x + 112)
    f === :localeIdsSize && return Ptr{Csize_t}(x + 128)
    f === :localeIds && return Ptr{Ptr{UA_String}}(x + 136)
    f === :serverUrisSize && return Ptr{Csize_t}(x + 144)
    f === :serverUris && return Ptr{Ptr{UA_String}}(x + 152)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FindServersRequest, f::Symbol)
    r = Ref{UA_FindServersRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FindServersRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FindServersRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FindServersResponse
    data::NTuple{152, UInt8}
end

Base.fieldnames(::Type{UA_FindServersResponse}) = (:responseHeader, :serversSize, :servers)
function Base.fieldnames(::Type{Ptr{UA_FindServersResponse}})
    (:responseHeader, :serversSize, :servers)
end

function Base.getproperty(x::Ptr{UA_FindServersResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :serversSize && return Ptr{Csize_t}(x + 136)
    f === :servers && return Ptr{Ptr{UA_ApplicationDescription}}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FindServersResponse, f::Symbol)
    r = Ref{UA_FindServersResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FindServersResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FindServersResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FindServersOnNetworkRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_FindServersOnNetworkRequest})
    (:requestHeader, :startingRecordId, :maxRecordsToReturn,
        :serverCapabilityFilterSize, :serverCapabilityFilter)
end
function Base.fieldnames(::Type{Ptr{UA_FindServersOnNetworkRequest}})
    (:requestHeader, :startingRecordId, :maxRecordsToReturn,
        :serverCapabilityFilterSize, :serverCapabilityFilter)
end

function Base.getproperty(x::Ptr{UA_FindServersOnNetworkRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :startingRecordId && return Ptr{UA_UInt32}(x + 112)
    f === :maxRecordsToReturn && return Ptr{UA_UInt32}(x + 116)
    f === :serverCapabilityFilterSize && return Ptr{Csize_t}(x + 120)
    f === :serverCapabilityFilter && return Ptr{Ptr{UA_String}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FindServersOnNetworkRequest, f::Symbol)
    r = Ref{UA_FindServersOnNetworkRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FindServersOnNetworkRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FindServersOnNetworkRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_FindServersOnNetworkResponse
    data::NTuple{160, UInt8}
end

function Base.fieldnames(::Type{UA_FindServersOnNetworkResponse})
    (:responseHeader, :lastCounterResetTime, :serversSize, :servers)
end
function Base.fieldnames(::Type{Ptr{UA_FindServersOnNetworkResponse}})
    (:responseHeader, :lastCounterResetTime, :serversSize, :servers)
end

function Base.getproperty(x::Ptr{UA_FindServersOnNetworkResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :lastCounterResetTime && return Ptr{UA_DateTime}(x + 136)
    f === :serversSize && return Ptr{Csize_t}(x + 144)
    f === :servers && return Ptr{Ptr{UA_ServerOnNetwork}}(x + 152)
    return getfield(x, f)
end

function Base.getproperty(x::UA_FindServersOnNetworkResponse, f::Symbol)
    r = Ref{UA_FindServersOnNetworkResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_FindServersOnNetworkResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_FindServersOnNetworkResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_ApplicationInstanceCertificate = UA_ByteString

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_GetEndpointsRequest
    data::NTuple{160, UInt8}
end

function Base.fieldnames(::Type{UA_GetEndpointsRequest})
    (:requestHeader, :endpointUrl, :localeIdsSize,
        :localeIds, :profileUrisSize, :profileUris)
end
function Base.fieldnames(::Type{Ptr{UA_GetEndpointsRequest}})
    (:requestHeader, :endpointUrl, :localeIdsSize,
        :localeIds, :profileUrisSize, :profileUris)
end

function Base.getproperty(x::Ptr{UA_GetEndpointsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :endpointUrl && return Ptr{UA_String}(x + 112)
    f === :localeIdsSize && return Ptr{Csize_t}(x + 128)
    f === :localeIds && return Ptr{Ptr{UA_String}}(x + 136)
    f === :profileUrisSize && return Ptr{Csize_t}(x + 144)
    f === :profileUris && return Ptr{Ptr{UA_String}}(x + 152)
    return getfield(x, f)
end

function Base.getproperty(x::UA_GetEndpointsRequest, f::Symbol)
    r = Ref{UA_GetEndpointsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_GetEndpointsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_GetEndpointsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_GetEndpointsResponse
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_GetEndpointsResponse})
    (:responseHeader, :endpointsSize, :endpoints)
end
function Base.fieldnames(::Type{Ptr{UA_GetEndpointsResponse}})
    (:responseHeader, :endpointsSize, :endpoints)
end

function Base.getproperty(x::Ptr{UA_GetEndpointsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :endpointsSize && return Ptr{Csize_t}(x + 136)
    f === :endpoints && return Ptr{Ptr{UA_EndpointDescription}}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_GetEndpointsResponse, f::Symbol)
    r = Ref{UA_GetEndpointsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_GetEndpointsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_GetEndpointsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisteredServer
    serverUri::UA_String
    productUri::UA_String
    serverNamesSize::Csize_t
    serverNames::Ptr{UA_LocalizedText}
    serverType::UA_ApplicationType
    gatewayServerUri::UA_String
    discoveryUrlsSize::Csize_t
    discoveryUrls::Ptr{UA_String}
    semaphoreFilePath::UA_String
    isOnline::UA_Boolean
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisterServerRequest
    data::NTuple{224, UInt8}
end

Base.fieldnames(::Type{UA_RegisterServerRequest}) = (:requestHeader, :server)
Base.fieldnames(::Type{Ptr{UA_RegisterServerRequest}}) = (:requestHeader, :server)

function Base.getproperty(x::Ptr{UA_RegisterServerRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :server && return Ptr{UA_RegisteredServer}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RegisterServerRequest, f::Symbol)
    r = Ref{UA_RegisterServerRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RegisterServerRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RegisterServerRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisterServerResponse
    data::NTuple{136, UInt8}
end

Base.fieldnames(::Type{UA_RegisterServerResponse}) = (:responseHeader,)
Base.fieldnames(::Type{Ptr{UA_RegisterServerResponse}}) = (:responseHeader,)

function Base.getproperty(x::Ptr{UA_RegisterServerResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RegisterServerResponse, f::Symbol)
    r = Ref{UA_RegisterServerResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RegisterServerResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RegisterServerResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MdnsDiscoveryConfiguration
    mdnsServerName::UA_String
    serverCapabilitiesSize::Csize_t
    serverCapabilities::Ptr{UA_String}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisterServer2Request
    data::NTuple{240, UInt8}
end

function Base.fieldnames(::Type{UA_RegisterServer2Request})
    (:requestHeader, :server, :discoveryConfigurationSize, :discoveryConfiguration)
end
function Base.fieldnames(::Type{Ptr{UA_RegisterServer2Request}})
    (:requestHeader, :server, :discoveryConfigurationSize, :discoveryConfiguration)
end

function Base.getproperty(x::Ptr{UA_RegisterServer2Request}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :server && return Ptr{UA_RegisteredServer}(x + 112)
    f === :discoveryConfigurationSize && return Ptr{Csize_t}(x + 224)
    f === :discoveryConfiguration && return Ptr{Ptr{UA_ExtensionObject}}(x + 232)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RegisterServer2Request, f::Symbol)
    r = Ref{UA_RegisterServer2Request}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RegisterServer2Request}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RegisterServer2Request}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisterServer2Response
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_RegisterServer2Response})
    (:responseHeader, :configurationResultsSize,
        :configurationResults, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_RegisterServer2Response}})
    (:responseHeader, :configurationResultsSize,
        :configurationResults, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_RegisterServer2Response}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :configurationResultsSize && return Ptr{Csize_t}(x + 136)
    f === :configurationResults && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RegisterServer2Response, f::Symbol)
    r = Ref{UA_RegisterServer2Response}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RegisterServer2Response}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RegisterServer2Response}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_SecurityTokenRequestType::UInt32 begin
    UA_SECURITYTOKENREQUESTTYPE_ISSUE = 0
    UA_SECURITYTOKENREQUESTTYPE_RENEW = 1
    __UA_SECURITYTOKENREQUESTTYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ChannelSecurityToken
    channelId::UA_UInt32
    tokenId::UA_UInt32
    createdAt::UA_DateTime
    revisedLifetime::UA_UInt32
end
function Base.getproperty(x::Ptr{UA_ChannelSecurityToken}, f::Symbol)
    f === :channelId && return Ptr{UA_UInt32}(x + 0)
    f === :tokenId && return Ptr{UA_UInt32}(x + 4)
    f === :createdAt && return Ptr{UA_DateTime}(x + 8)
    f === :revisedLifetime && return Ptr{UA_UInt32}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ChannelSecurityToken}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_OpenSecureChannelRequest
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_OpenSecureChannelRequest})
    (:requestHeader, :clientProtocolVersion, :requestType,
        :securityMode, :clientNonce, :requestedLifetime)
end
function Base.fieldnames(::Type{Ptr{UA_OpenSecureChannelRequest}})
    (:requestHeader, :clientProtocolVersion, :requestType,
        :securityMode, :clientNonce, :requestedLifetime)
end

function Base.getproperty(x::Ptr{UA_OpenSecureChannelRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :clientProtocolVersion && return Ptr{UA_UInt32}(x + 112)
    f === :requestType && return Ptr{UA_SecurityTokenRequestType}(x + 116)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 120)
    f === :clientNonce && return Ptr{UA_ByteString}(x + 128)
    f === :requestedLifetime && return Ptr{UA_UInt32}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_OpenSecureChannelRequest, f::Symbol)
    r = Ref{UA_OpenSecureChannelRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_OpenSecureChannelRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_OpenSecureChannelRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_OpenSecureChannelResponse
    data::NTuple{184, UInt8}
end

function Base.fieldnames(::Type{UA_OpenSecureChannelResponse})
    (:responseHeader, :serverProtocolVersion, :securityToken, :serverNonce)
end
function Base.fieldnames(::Type{Ptr{UA_OpenSecureChannelResponse}})
    (:responseHeader, :serverProtocolVersion, :securityToken, :serverNonce)
end

function Base.getproperty(x::Ptr{UA_OpenSecureChannelResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :serverProtocolVersion && return Ptr{UA_UInt32}(x + 136)
    f === :securityToken && return Ptr{UA_ChannelSecurityToken}(x + 144)
    f === :serverNonce && return Ptr{UA_ByteString}(x + 168)
    return getfield(x, f)
end

function Base.getproperty(x::UA_OpenSecureChannelResponse, f::Symbol)
    r = Ref{UA_OpenSecureChannelResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_OpenSecureChannelResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_OpenSecureChannelResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CloseSecureChannelRequest
    data::NTuple{112, UInt8}
end

Base.fieldnames(::Type{UA_CloseSecureChannelRequest}) = (:requestHeader,)
Base.fieldnames(::Type{Ptr{UA_CloseSecureChannelRequest}}) = (:requestHeader,)

function Base.getproperty(x::Ptr{UA_CloseSecureChannelRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CloseSecureChannelRequest, f::Symbol)
    r = Ref{UA_CloseSecureChannelRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CloseSecureChannelRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CloseSecureChannelRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CloseSecureChannelResponse
    data::NTuple{136, UInt8}
end

Base.fieldnames(::Type{UA_CloseSecureChannelResponse}) = (:responseHeader,)
Base.fieldnames(::Type{Ptr{UA_CloseSecureChannelResponse}}) = (:responseHeader,)

function Base.getproperty(x::Ptr{UA_CloseSecureChannelResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CloseSecureChannelResponse, f::Symbol)
    r = Ref{UA_CloseSecureChannelResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CloseSecureChannelResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CloseSecureChannelResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SignedSoftwareCertificate
    certificateData::UA_ByteString
    signature::UA_ByteString
end
function Base.getproperty(x::Ptr{UA_SignedSoftwareCertificate}, f::Symbol)
    f === :certificateData && return Ptr{UA_ByteString}(x + 0)
    f === :signature && return Ptr{UA_ByteString}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_SignedSoftwareCertificate}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_SessionAuthenticationToken = UA_NodeId

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SignatureData
    algorithm::UA_String
    signature::UA_ByteString
end
function Base.getproperty(x::Ptr{UA_SignatureData}, f::Symbol)
    f === :algorithm && return Ptr{UA_String}(x + 0)
    f === :signature && return Ptr{UA_ByteString}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_SignatureData}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CreateSessionRequest
    data::NTuple{328, UInt8}
end

function Base.fieldnames(::Type{UA_CreateSessionRequest})
    (:requestHeader, :clientDescription, :serverUri, :endpointUrl,
        :sessionName, :clientNonce, :clientCertificate,
        :requestedSessionTimeout, :maxResponseMessageSize)
end
function Base.fieldnames(::Type{Ptr{UA_CreateSessionRequest}})
    (:requestHeader, :clientDescription, :serverUri, :endpointUrl,
        :sessionName, :clientNonce, :clientCertificate,
        :requestedSessionTimeout, :maxResponseMessageSize)
end

function Base.getproperty(x::Ptr{UA_CreateSessionRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :clientDescription && return Ptr{UA_ApplicationDescription}(x + 112)
    f === :serverUri && return Ptr{UA_String}(x + 232)
    f === :endpointUrl && return Ptr{UA_String}(x + 248)
    f === :sessionName && return Ptr{UA_String}(x + 264)
    f === :clientNonce && return Ptr{UA_ByteString}(x + 280)
    f === :clientCertificate && return Ptr{UA_ByteString}(x + 296)
    f === :requestedSessionTimeout && return Ptr{UA_Double}(x + 312)
    f === :maxResponseMessageSize && return Ptr{UA_UInt32}(x + 320)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CreateSessionRequest, f::Symbol)
    r = Ref{UA_CreateSessionRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CreateSessionRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CreateSessionRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CreateSessionResponse
    data::NTuple{296, UInt8}
end

function Base.fieldnames(::Type{UA_CreateSessionResponse})
    (:responseHeader, :sessionId, :authenticationToken,
        :revisedSessionTimeout, :serverNonce, :serverCertificate,
        :serverEndpointsSize, :serverEndpoints, :serverSoftwareCertificatesSize,
        :serverSoftwareCertificates, :serverSignature, :maxRequestMessageSize)
end
function Base.fieldnames(::Type{Ptr{UA_CreateSessionResponse}})
    (:responseHeader, :sessionId, :authenticationToken,
        :revisedSessionTimeout, :serverNonce, :serverCertificate,
        :serverEndpointsSize, :serverEndpoints, :serverSoftwareCertificatesSize,
        :serverSoftwareCertificates, :serverSignature, :maxRequestMessageSize)
end

function Base.getproperty(x::Ptr{UA_CreateSessionResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :sessionId && return Ptr{UA_NodeId}(x + 136)
    f === :authenticationToken && return Ptr{UA_NodeId}(x + 160)
    f === :revisedSessionTimeout && return Ptr{UA_Double}(x + 184)
    f === :serverNonce && return Ptr{UA_ByteString}(x + 192)
    f === :serverCertificate && return Ptr{UA_ByteString}(x + 208)
    f === :serverEndpointsSize && return Ptr{Csize_t}(x + 224)
    f === :serverEndpoints && return Ptr{Ptr{UA_EndpointDescription}}(x + 232)
    f === :serverSoftwareCertificatesSize && return Ptr{Csize_t}(x + 240)
    f === :serverSoftwareCertificates &&
        return Ptr{Ptr{UA_SignedSoftwareCertificate}}(x + 248)
    f === :serverSignature && return Ptr{UA_SignatureData}(x + 256)
    f === :maxRequestMessageSize && return Ptr{UA_UInt32}(x + 288)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CreateSessionResponse, f::Symbol)
    r = Ref{UA_CreateSessionResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CreateSessionResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CreateSessionResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UserIdentityToken
    policyId::UA_String
end
function Base.getproperty(x::Ptr{UA_UserIdentityToken}, f::Symbol)
    f === :policyId && return Ptr{UA_String}(x + 0)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_UserIdentityToken}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AnonymousIdentityToken
    policyId::UA_String
end
function Base.getproperty(x::Ptr{UA_AnonymousIdentityToken}, f::Symbol)
    f === :policyId && return Ptr{UA_String}(x + 0)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_AnonymousIdentityToken}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UserNameIdentityToken
    policyId::UA_String
    userName::UA_String
    password::UA_ByteString
    encryptionAlgorithm::UA_String
end
function Base.getproperty(x::Ptr{UA_UserNameIdentityToken}, f::Symbol)
    f === :policyId && return Ptr{UA_String}(x + 0)
    f === :userName && return Ptr{UA_String}(x + 16)
    f === :password && return Ptr{UA_ByteString}(x + 32)
    f === :encryptionAlgorithm && return Ptr{UA_String}(x + 48)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_UserNameIdentityToken}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_X509IdentityToken
    policyId::UA_String
    certificateData::UA_ByteString
end
function Base.getproperty(x::Ptr{UA_X509IdentityToken}, f::Symbol)
    f === :policyId && return Ptr{UA_String}(x + 0)
    f === :certificateData && return Ptr{UA_ByteString}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_X509IdentityToken}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_IssuedIdentityToken
    policyId::UA_String
    tokenData::UA_ByteString
    encryptionAlgorithm::UA_String
end
function Base.getproperty(x::Ptr{UA_IssuedIdentityToken}, f::Symbol)
    f === :policyId && return Ptr{UA_String}(x + 0)
    f === :tokenData && return Ptr{UA_ByteString}(x + 16)
    f === :encryptionAlgorithm && return Ptr{UA_String}(x + 32)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_IssuedIdentityToken}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const UA_RsaEncryptedSecret = UA_ByteString

const UA_EccEncryptedSecret = UA_ByteString

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ActivateSessionRequest
    data::NTuple{256, UInt8}
end

function Base.fieldnames(::Type{UA_ActivateSessionRequest})
    (:requestHeader, :clientSignature, :clientSoftwareCertificatesSize,
        :clientSoftwareCertificates, :localeIdsSize,
        :localeIds, :userIdentityToken, :userTokenSignature)
end
function Base.fieldnames(::Type{Ptr{UA_ActivateSessionRequest}})
    (:requestHeader, :clientSignature, :clientSoftwareCertificatesSize,
        :clientSoftwareCertificates, :localeIdsSize,
        :localeIds, :userIdentityToken, :userTokenSignature)
end

function Base.getproperty(x::Ptr{UA_ActivateSessionRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :clientSignature && return Ptr{UA_SignatureData}(x + 112)
    f === :clientSoftwareCertificatesSize && return Ptr{Csize_t}(x + 144)
    f === :clientSoftwareCertificates &&
        return Ptr{Ptr{UA_SignedSoftwareCertificate}}(x + 152)
    f === :localeIdsSize && return Ptr{Csize_t}(x + 160)
    f === :localeIds && return Ptr{Ptr{UA_String}}(x + 168)
    f === :userIdentityToken && return Ptr{UA_ExtensionObject}(x + 176)
    f === :userTokenSignature && return Ptr{UA_SignatureData}(x + 224)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ActivateSessionRequest, f::Symbol)
    r = Ref{UA_ActivateSessionRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ActivateSessionRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ActivateSessionRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ActivateSessionResponse
    data::NTuple{184, UInt8}
end

function Base.fieldnames(::Type{UA_ActivateSessionResponse})
    (:responseHeader, :serverNonce, :resultsSize,
        :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_ActivateSessionResponse}})
    (:responseHeader, :serverNonce, :resultsSize,
        :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_ActivateSessionResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :serverNonce && return Ptr{UA_ByteString}(x + 136)
    f === :resultsSize && return Ptr{Csize_t}(x + 152)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 160)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 168)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 176)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ActivateSessionResponse, f::Symbol)
    r = Ref{UA_ActivateSessionResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ActivateSessionResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ActivateSessionResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CloseSessionRequest
    data::NTuple{120, UInt8}
end

Base.fieldnames(::Type{UA_CloseSessionRequest}) = (:requestHeader, :deleteSubscriptions)
function Base.fieldnames(::Type{Ptr{UA_CloseSessionRequest}})
    (:requestHeader, :deleteSubscriptions)
end

function Base.getproperty(x::Ptr{UA_CloseSessionRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :deleteSubscriptions && return Ptr{UA_Boolean}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CloseSessionRequest, f::Symbol)
    r = Ref{UA_CloseSessionRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CloseSessionRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CloseSessionRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CloseSessionResponse
    data::NTuple{136, UInt8}
end

Base.fieldnames(::Type{UA_CloseSessionResponse}) = (:responseHeader,)
Base.fieldnames(::Type{Ptr{UA_CloseSessionResponse}}) = (:responseHeader,)

function Base.getproperty(x::Ptr{UA_CloseSessionResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CloseSessionResponse, f::Symbol)
    r = Ref{UA_CloseSessionResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CloseSessionResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CloseSessionResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CancelRequest
    data::NTuple{120, UInt8}
end

Base.fieldnames(::Type{UA_CancelRequest}) = (:requestHeader, :requestHandle)
Base.fieldnames(::Type{Ptr{UA_CancelRequest}}) = (:requestHeader, :requestHandle)

function Base.getproperty(x::Ptr{UA_CancelRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :requestHandle && return Ptr{UA_UInt32}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CancelRequest, f::Symbol)
    r = Ref{UA_CancelRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CancelRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CancelRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CancelResponse
    data::NTuple{144, UInt8}
end

Base.fieldnames(::Type{UA_CancelResponse}) = (:responseHeader, :cancelCount)
Base.fieldnames(::Type{Ptr{UA_CancelResponse}}) = (:responseHeader, :cancelCount)

function Base.getproperty(x::Ptr{UA_CancelResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :cancelCount && return Ptr{UA_UInt32}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CancelResponse, f::Symbol)
    r = Ref{UA_CancelResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CancelResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CancelResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

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

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ObjectAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    eventNotifier::UA_Byte
end
function Base.getproperty(x::Ptr{UA_ObjectAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :eventNotifier && return Ptr{UA_Byte}(x + 80)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ObjectAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ObjectTypeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    isAbstract::UA_Boolean
end
function Base.getproperty(x::Ptr{UA_ObjectTypeAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 80)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ObjectTypeAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_VariableTypeAttributes
    data::NTuple{184, UInt8}
end

function Base.fieldnames(::Type{UA_VariableTypeAttributes})
    (:specifiedAttributes, :displayName, :description, :writeMask, :userWriteMask,
        :value, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions, :isAbstract)
end
function Base.fieldnames(::Type{Ptr{UA_VariableTypeAttributes}})
    (:specifiedAttributes, :displayName, :description, :writeMask, :userWriteMask,
        :value, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions, :isAbstract)
end

function Base.getproperty(x::Ptr{UA_VariableTypeAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :value && return Ptr{UA_Variant}(x + 80)
    f === :dataType && return Ptr{UA_NodeId}(x + 128)
    f === :valueRank && return Ptr{UA_Int32}(x + 152)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 160)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 168)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 176)
    return getfield(x, f)
end

function Base.getproperty(x::UA_VariableTypeAttributes, f::Symbol)
    r = Ref{UA_VariableTypeAttributes}(x)
    ptr = Base.unsafe_convert(Ptr{UA_VariableTypeAttributes}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_VariableTypeAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_ReferenceTypeAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 80)
    f === :symmetric && return Ptr{UA_Boolean}(x + 81)
    f === :inverseName && return Ptr{UA_LocalizedText}(x + 88)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ReferenceTypeAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_DataTypeAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    isAbstract::UA_Boolean
end
function Base.getproperty(x::Ptr{UA_DataTypeAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 80)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_DataTypeAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_ViewAttributes}, f::Symbol)
    f === :specifiedAttributes && return Ptr{UA_UInt32}(x + 0)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 8)
    f === :description && return Ptr{UA_LocalizedText}(x + 40)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :userWriteMask && return Ptr{UA_UInt32}(x + 76)
    f === :containsNoLoops && return Ptr{UA_Boolean}(x + 80)
    f === :eventNotifier && return Ptr{UA_Byte}(x + 81)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ViewAttributes}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_GenericAttributeValue
    attributeId::UA_UInt32
    value::UA_Variant
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_GenericAttributes
    specifiedAttributes::UA_UInt32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
    writeMask::UA_UInt32
    userWriteMask::UA_UInt32
    attributeValuesSize::Csize_t
    attributeValues::Ptr{UA_GenericAttributeValue}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddNodesItem
    data::NTuple{248, UInt8}
end

function Base.fieldnames(::Type{UA_AddNodesItem})
    (:parentNodeId, :referenceTypeId, :requestedNewNodeId,
        :browseName, :nodeClass, :nodeAttributes, :typeDefinition)
end
function Base.fieldnames(::Type{Ptr{UA_AddNodesItem}})
    (:parentNodeId, :referenceTypeId, :requestedNewNodeId,
        :browseName, :nodeClass, :nodeAttributes, :typeDefinition)
end

function Base.getproperty(x::Ptr{UA_AddNodesItem}, f::Symbol)
    f === :parentNodeId && return Ptr{UA_ExpandedNodeId}(x + 0)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 48)
    f === :requestedNewNodeId && return Ptr{UA_ExpandedNodeId}(x + 72)
    f === :browseName && return Ptr{UA_QualifiedName}(x + 120)
    f === :nodeClass && return Ptr{UA_NodeClass}(x + 144)
    f === :nodeAttributes && return Ptr{UA_ExtensionObject}(x + 152)
    f === :typeDefinition && return Ptr{UA_ExpandedNodeId}(x + 200)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddNodesItem, f::Symbol)
    r = Ref{UA_AddNodesItem}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddNodesItem}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddNodesItem}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddNodesResult
    data::NTuple{32, UInt8}
end

Base.fieldnames(::Type{UA_AddNodesResult}) = (:statusCode, :addedNodeId)
Base.fieldnames(::Type{Ptr{UA_AddNodesResult}}) = (:statusCode, :addedNodeId)

function Base.getproperty(x::Ptr{UA_AddNodesResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :addedNodeId && return Ptr{UA_NodeId}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddNodesResult, f::Symbol)
    r = Ref{UA_AddNodesResult}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddNodesResult}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddNodesResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddNodesRequest
    data::NTuple{128, UInt8}
end

Base.fieldnames(::Type{UA_AddNodesRequest}) = (:requestHeader, :nodesToAddSize, :nodesToAdd)
function Base.fieldnames(::Type{Ptr{UA_AddNodesRequest}})
    (:requestHeader, :nodesToAddSize, :nodesToAdd)
end

function Base.getproperty(x::Ptr{UA_AddNodesRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :nodesToAddSize && return Ptr{Csize_t}(x + 112)
    f === :nodesToAdd && return Ptr{Ptr{UA_AddNodesItem}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddNodesRequest, f::Symbol)
    r = Ref{UA_AddNodesRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddNodesRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddNodesRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddNodesResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_AddNodesResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_AddNodesResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_AddNodesResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_AddNodesResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddNodesResponse, f::Symbol)
    r = Ref{UA_AddNodesResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddNodesResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddNodesResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddReferencesItem
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_AddReferencesItem})
    (:sourceNodeId, :referenceTypeId, :isForward,
        :targetServerUri, :targetNodeId, :targetNodeClass)
end
function Base.fieldnames(::Type{Ptr{UA_AddReferencesItem}})
    (:sourceNodeId, :referenceTypeId, :isForward,
        :targetServerUri, :targetNodeId, :targetNodeClass)
end

function Base.getproperty(x::Ptr{UA_AddReferencesItem}, f::Symbol)
    f === :sourceNodeId && return Ptr{UA_NodeId}(x + 0)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 24)
    f === :isForward && return Ptr{UA_Boolean}(x + 48)
    f === :targetServerUri && return Ptr{UA_String}(x + 56)
    f === :targetNodeId && return Ptr{UA_ExpandedNodeId}(x + 72)
    f === :targetNodeClass && return Ptr{UA_NodeClass}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddReferencesItem, f::Symbol)
    r = Ref{UA_AddReferencesItem}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddReferencesItem}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddReferencesItem}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddReferencesRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_AddReferencesRequest})
    (:requestHeader, :referencesToAddSize, :referencesToAdd)
end
function Base.fieldnames(::Type{Ptr{UA_AddReferencesRequest}})
    (:requestHeader, :referencesToAddSize, :referencesToAdd)
end

function Base.getproperty(x::Ptr{UA_AddReferencesRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :referencesToAddSize && return Ptr{Csize_t}(x + 112)
    f === :referencesToAdd && return Ptr{Ptr{UA_AddReferencesItem}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddReferencesRequest, f::Symbol)
    r = Ref{UA_AddReferencesRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddReferencesRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddReferencesRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AddReferencesResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_AddReferencesResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_AddReferencesResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_AddReferencesResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AddReferencesResponse, f::Symbol)
    r = Ref{UA_AddReferencesResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AddReferencesResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AddReferencesResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteNodesItem
    data::NTuple{32, UInt8}
end

Base.fieldnames(::Type{UA_DeleteNodesItem}) = (:nodeId, :deleteTargetReferences)
Base.fieldnames(::Type{Ptr{UA_DeleteNodesItem}}) = (:nodeId, :deleteTargetReferences)

function Base.getproperty(x::Ptr{UA_DeleteNodesItem}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :deleteTargetReferences && return Ptr{UA_Boolean}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteNodesItem, f::Symbol)
    r = Ref{UA_DeleteNodesItem}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteNodesItem}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteNodesItem}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteNodesRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteNodesRequest})
    (:requestHeader, :nodesToDeleteSize, :nodesToDelete)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteNodesRequest}})
    (:requestHeader, :nodesToDeleteSize, :nodesToDelete)
end

function Base.getproperty(x::Ptr{UA_DeleteNodesRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :nodesToDeleteSize && return Ptr{Csize_t}(x + 112)
    f === :nodesToDelete && return Ptr{Ptr{UA_DeleteNodesItem}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteNodesRequest, f::Symbol)
    r = Ref{UA_DeleteNodesRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteNodesRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteNodesRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteNodesResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteNodesResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteNodesResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_DeleteNodesResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteNodesResponse, f::Symbol)
    r = Ref{UA_DeleteNodesResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteNodesResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteNodesResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteReferencesItem
    data::NTuple{112, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteReferencesItem})
    (:sourceNodeId, :referenceTypeId, :isForward, :targetNodeId, :deleteBidirectional)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteReferencesItem}})
    (:sourceNodeId, :referenceTypeId, :isForward, :targetNodeId, :deleteBidirectional)
end

function Base.getproperty(x::Ptr{UA_DeleteReferencesItem}, f::Symbol)
    f === :sourceNodeId && return Ptr{UA_NodeId}(x + 0)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 24)
    f === :isForward && return Ptr{UA_Boolean}(x + 48)
    f === :targetNodeId && return Ptr{UA_ExpandedNodeId}(x + 56)
    f === :deleteBidirectional && return Ptr{UA_Boolean}(x + 104)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteReferencesItem, f::Symbol)
    r = Ref{UA_DeleteReferencesItem}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteReferencesItem}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteReferencesItem}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteReferencesRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteReferencesRequest})
    (:requestHeader, :referencesToDeleteSize, :referencesToDelete)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteReferencesRequest}})
    (:requestHeader, :referencesToDeleteSize, :referencesToDelete)
end

function Base.getproperty(x::Ptr{UA_DeleteReferencesRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :referencesToDeleteSize && return Ptr{Csize_t}(x + 112)
    f === :referencesToDelete && return Ptr{Ptr{UA_DeleteReferencesItem}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteReferencesRequest, f::Symbol)
    r = Ref{UA_DeleteReferencesRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteReferencesRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteReferencesRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteReferencesResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteReferencesResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteReferencesResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_DeleteReferencesResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteReferencesResponse, f::Symbol)
    r = Ref{UA_DeleteReferencesResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteReferencesResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteReferencesResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end
const UA_AttributeWriteMask = UA_UInt32

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ViewDescription
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{UA_ViewDescription}) = (:viewId, :timestamp, :viewVersion)
Base.fieldnames(::Type{Ptr{UA_ViewDescription}}) = (:viewId, :timestamp, :viewVersion)

function Base.getproperty(x::Ptr{UA_ViewDescription}, f::Symbol)
    f === :viewId && return Ptr{UA_NodeId}(x + 0)
    f === :timestamp && return Ptr{UA_DateTime}(x + 24)
    f === :viewVersion && return Ptr{UA_UInt32}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ViewDescription, f::Symbol)
    r = Ref{UA_ViewDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ViewDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ViewDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

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

const UA_ContinuationPoint = UA_ByteString

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowseRequest
    data::NTuple{176, UInt8}
end

function Base.fieldnames(::Type{UA_BrowseRequest})
    (:requestHeader, :view, :requestedMaxReferencesPerNode,
        :nodesToBrowseSize, :nodesToBrowse)
end
function Base.fieldnames(::Type{Ptr{UA_BrowseRequest}})
    (:requestHeader, :view, :requestedMaxReferencesPerNode,
        :nodesToBrowseSize, :nodesToBrowse)
end

function Base.getproperty(x::Ptr{UA_BrowseRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :view && return Ptr{UA_ViewDescription}(x + 112)
    f === :requestedMaxReferencesPerNode && return Ptr{UA_UInt32}(x + 152)
    f === :nodesToBrowseSize && return Ptr{Csize_t}(x + 160)
    f === :nodesToBrowse && return Ptr{Ptr{UA_BrowseDescription}}(x + 168)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowseRequest, f::Symbol)
    r = Ref{UA_BrowseRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowseRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowseRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowseResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_BrowseResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_BrowseResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_BrowseResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_BrowseResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowseResponse, f::Symbol)
    r = Ref{UA_BrowseResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowseResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowseResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowseNextRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_BrowseNextRequest})
    (:requestHeader, :releaseContinuationPoints,
        :continuationPointsSize, :continuationPoints)
end
function Base.fieldnames(::Type{Ptr{UA_BrowseNextRequest}})
    (:requestHeader, :releaseContinuationPoints,
        :continuationPointsSize, :continuationPoints)
end

function Base.getproperty(x::Ptr{UA_BrowseNextRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :releaseContinuationPoints && return Ptr{UA_Boolean}(x + 112)
    f === :continuationPointsSize && return Ptr{Csize_t}(x + 120)
    f === :continuationPoints && return Ptr{Ptr{UA_ByteString}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowseNextRequest, f::Symbol)
    r = Ref{UA_BrowseNextRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowseNextRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowseNextRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_BrowseNextResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_BrowseNextResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_BrowseNextResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_BrowseNextResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_BrowseResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_BrowseNextResponse, f::Symbol)
    r = Ref{UA_BrowseNextResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_BrowseNextResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_BrowseNextResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TranslateBrowsePathsToNodeIdsRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_TranslateBrowsePathsToNodeIdsRequest})
    (:requestHeader, :browsePathsSize, :browsePaths)
end
function Base.fieldnames(::Type{Ptr{UA_TranslateBrowsePathsToNodeIdsRequest}})
    (:requestHeader, :browsePathsSize, :browsePaths)
end

function Base.getproperty(x::Ptr{UA_TranslateBrowsePathsToNodeIdsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :browsePathsSize && return Ptr{Csize_t}(x + 112)
    f === :browsePaths && return Ptr{Ptr{UA_BrowsePath}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_TranslateBrowsePathsToNodeIdsRequest, f::Symbol)
    r = Ref{UA_TranslateBrowsePathsToNodeIdsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_TranslateBrowsePathsToNodeIdsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_TranslateBrowsePathsToNodeIdsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TranslateBrowsePathsToNodeIdsResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_TranslateBrowsePathsToNodeIdsResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_TranslateBrowsePathsToNodeIdsResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_TranslateBrowsePathsToNodeIdsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_BrowsePathResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_TranslateBrowsePathsToNodeIdsResponse, f::Symbol)
    r = Ref{UA_TranslateBrowsePathsToNodeIdsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_TranslateBrowsePathsToNodeIdsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_TranslateBrowsePathsToNodeIdsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisterNodesRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_RegisterNodesRequest})
    (:requestHeader, :nodesToRegisterSize, :nodesToRegister)
end
function Base.fieldnames(::Type{Ptr{UA_RegisterNodesRequest}})
    (:requestHeader, :nodesToRegisterSize, :nodesToRegister)
end

function Base.getproperty(x::Ptr{UA_RegisterNodesRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :nodesToRegisterSize && return Ptr{Csize_t}(x + 112)
    f === :nodesToRegister && return Ptr{Ptr{UA_NodeId}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RegisterNodesRequest, f::Symbol)
    r = Ref{UA_RegisterNodesRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RegisterNodesRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RegisterNodesRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RegisterNodesResponse
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_RegisterNodesResponse})
    (:responseHeader, :registeredNodeIdsSize, :registeredNodeIds)
end
function Base.fieldnames(::Type{Ptr{UA_RegisterNodesResponse}})
    (:responseHeader, :registeredNodeIdsSize, :registeredNodeIds)
end

function Base.getproperty(x::Ptr{UA_RegisterNodesResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :registeredNodeIdsSize && return Ptr{Csize_t}(x + 136)
    f === :registeredNodeIds && return Ptr{Ptr{UA_NodeId}}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RegisterNodesResponse, f::Symbol)
    r = Ref{UA_RegisterNodesResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RegisterNodesResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RegisterNodesResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UnregisterNodesRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_UnregisterNodesRequest})
    (:requestHeader, :nodesToUnregisterSize, :nodesToUnregister)
end
function Base.fieldnames(::Type{Ptr{UA_UnregisterNodesRequest}})
    (:requestHeader, :nodesToUnregisterSize, :nodesToUnregister)
end

function Base.getproperty(x::Ptr{UA_UnregisterNodesRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :nodesToUnregisterSize && return Ptr{Csize_t}(x + 112)
    f === :nodesToUnregister && return Ptr{Ptr{UA_NodeId}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_UnregisterNodesRequest, f::Symbol)
    r = Ref{UA_UnregisterNodesRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_UnregisterNodesRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_UnregisterNodesRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UnregisterNodesResponse
    data::NTuple{136, UInt8}
end

Base.fieldnames(::Type{UA_UnregisterNodesResponse}) = (:responseHeader,)
Base.fieldnames(::Type{Ptr{UA_UnregisterNodesResponse}}) = (:responseHeader,)

function Base.getproperty(x::Ptr{UA_UnregisterNodesResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_UnregisterNodesResponse, f::Symbol)
    r = Ref{UA_UnregisterNodesResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_UnregisterNodesResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_UnregisterNodesResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end
const UA_Counter = UA_UInt32

const UA_OpaqueNumericRange = UA_String

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EndpointConfiguration
    operationTimeout::UA_Int32
    useBinaryEncoding::UA_Boolean
    maxStringLength::UA_Int32
    maxByteStringLength::UA_Int32
    maxArrayLength::UA_Int32
    maxMessageSize::UA_Int32
    maxBufferSize::UA_Int32
    channelLifetime::UA_Int32
    securityTokenLifetime::UA_Int32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QueryDataDescription
    relativePath::UA_RelativePath
    attributeId::UA_UInt32
    indexRange::UA_String
end

struct UA_NodeTypeDescription
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_NodeTypeDescription})
    (:typeDefinitionNode, :includeSubTypes, :dataToReturnSize, :dataToReturn)
end
function Base.fieldnames(::Type{Ptr{UA_NodeTypeDescription}})
    (:typeDefinitionNode, :includeSubTypes, :dataToReturnSize, :dataToReturn)
end

function Base.getproperty(x::Ptr{UA_NodeTypeDescription}, f::Symbol)
    f === :typeDefinitionNode && return Ptr{UA_ExpandedNodeId}(x + 0)
    f === :includeSubTypes && return Ptr{UA_Boolean}(x + 48)
    f === :dataToReturnSize && return Ptr{Csize_t}(x + 56)
    f === :dataToReturn && return Ptr{Ptr{UA_QueryDataDescription}}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_NodeTypeDescription, f::Symbol)
    r = Ref{UA_NodeTypeDescription}(x)
    ptr = Base.unsafe_convert(Ptr{UA_NodeTypeDescription}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_NodeTypeDescription}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QueryDataSet
    data::NTuple{112, UInt8}
end

function Base.fieldnames(::Type{UA_QueryDataSet})
    (:nodeId, :typeDefinitionNode, :valuesSize, :values)
end
function Base.fieldnames(::Type{Ptr{UA_QueryDataSet}})
    (:nodeId, :typeDefinitionNode, :valuesSize, :values)
end

function Base.getproperty(x::Ptr{UA_QueryDataSet}, f::Symbol)
    f === :nodeId && return Ptr{UA_ExpandedNodeId}(x + 0)
    f === :typeDefinitionNode && return Ptr{UA_ExpandedNodeId}(x + 48)
    f === :valuesSize && return Ptr{Csize_t}(x + 96)
    f === :values && return Ptr{Ptr{UA_Variant}}(x + 104)
    return getfield(x, f)
end

function Base.getproperty(x::UA_QueryDataSet, f::Symbol)
    r = Ref{UA_QueryDataSet}(x)
    ptr = Base.unsafe_convert(Ptr{UA_QueryDataSet}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_QueryDataSet}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_NodeReference
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_NodeReference})
    (:nodeId, :referenceTypeId, :isForward, :referencedNodeIdsSize, :referencedNodeIds)
end
function Base.fieldnames(::Type{Ptr{UA_NodeReference}})
    (:nodeId, :referenceTypeId, :isForward, :referencedNodeIdsSize, :referencedNodeIds)
end

function Base.getproperty(x::Ptr{UA_NodeReference}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :referenceTypeId && return Ptr{UA_NodeId}(x + 24)
    f === :isForward && return Ptr{UA_Boolean}(x + 48)
    f === :referencedNodeIdsSize && return Ptr{Csize_t}(x + 56)
    f === :referencedNodeIds && return Ptr{Ptr{UA_NodeId}}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_NodeReference, f::Symbol)
    r = Ref{UA_NodeReference}(x)
    ptr = Base.unsafe_convert(Ptr{UA_NodeReference}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_NodeReference}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ElementOperand
    index::UA_UInt32
end
function Base.getproperty(x::Ptr{UA_ElementOperand}, f::Symbol)
    f === :index && return Ptr{UA_UInt32}(x + 0)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ElementOperand}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_LiteralOperand
    value::UA_Variant
end
function Base.getproperty(x::Ptr{UA_LiteralOperand}, f::Symbol)
    f === :value && return Ptr{UA_Variant}(x + 0)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_LiteralOperand}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AttributeOperand
    data::NTuple{80, UInt8}
end

function Base.fieldnames(::Type{UA_AttributeOperand})
    (:nodeId, :alias, :browsePath, :attributeId, :indexRange)
end
function Base.fieldnames(::Type{Ptr{UA_AttributeOperand}})
    (:nodeId, :alias, :browsePath, :attributeId, :indexRange)
end

function Base.getproperty(x::Ptr{UA_AttributeOperand}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :alias && return Ptr{UA_String}(x + 24)
    f === :browsePath && return Ptr{UA_RelativePath}(x + 40)
    f === :attributeId && return Ptr{UA_UInt32}(x + 56)
    f === :indexRange && return Ptr{UA_String}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AttributeOperand, f::Symbol)
    r = Ref{UA_AttributeOperand}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AttributeOperand}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AttributeOperand}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ContentFilterElementResult
    statusCode::UA_StatusCode
    operandStatusCodesSize::Csize_t
    operandStatusCodes::Ptr{UA_StatusCode}
    operandDiagnosticInfosSize::Csize_t
    operandDiagnosticInfos::Ptr{UA_DiagnosticInfo}
end
function Base.getproperty(x::Ptr{UA_ContentFilterElementResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :operandStatusCodesSize && return Ptr{Csize_t}(x + 8)
    f === :operandStatusCodes && return Ptr{Ptr{UA_StatusCode}}(x + 16)
    f === :operandDiagnosticInfosSize && return Ptr{Csize_t}(x + 24)
    f === :operandDiagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 32)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ContentFilterElementResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ContentFilterResult
    elementResultsSize::Csize_t
    elementResults::Ptr{UA_ContentFilterElementResult}
    elementDiagnosticInfosSize::Csize_t
    elementDiagnosticInfos::Ptr{UA_DiagnosticInfo}
end
function Base.getproperty(x::Ptr{UA_ContentFilterResult}, f::Symbol)
    f === :elementResultsSize && return Ptr{Csize_t}(x + 0)
    f === :elementResults && return Ptr{Ptr{UA_ContentFilterElementResult}}(x + 8)
    f === :elementDiagnosticInfosSize && return Ptr{Csize_t}(x + 16)
    f === :elementDiagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 24)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ContentFilterResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ParsingResult
    statusCode::UA_StatusCode
    dataStatusCodesSize::Csize_t
    dataStatusCodes::Ptr{UA_StatusCode}
    dataDiagnosticInfosSize::Csize_t
    dataDiagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QueryFirstRequest
    data::NTuple{192, UInt8}
end

function Base.fieldnames(::Type{UA_QueryFirstRequest})
    (:requestHeader, :view, :nodeTypesSize, :nodeTypes,
        :filter, :maxDataSetsToReturn, :maxReferencesToReturn)
end
function Base.fieldnames(::Type{Ptr{UA_QueryFirstRequest}})
    (:requestHeader, :view, :nodeTypesSize, :nodeTypes,
        :filter, :maxDataSetsToReturn, :maxReferencesToReturn)
end

function Base.getproperty(x::Ptr{UA_QueryFirstRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :view && return Ptr{UA_ViewDescription}(x + 112)
    f === :nodeTypesSize && return Ptr{Csize_t}(x + 152)
    f === :nodeTypes && return Ptr{Ptr{UA_NodeTypeDescription}}(x + 160)
    f === :filter && return Ptr{UA_ContentFilter}(x + 168)
    f === :maxDataSetsToReturn && return Ptr{UA_UInt32}(x + 184)
    f === :maxReferencesToReturn && return Ptr{UA_UInt32}(x + 188)
    return getfield(x, f)
end

function Base.getproperty(x::UA_QueryFirstRequest, f::Symbol)
    r = Ref{UA_QueryFirstRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_QueryFirstRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_QueryFirstRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QueryFirstResponse
    data::NTuple{232, UInt8}
end

function Base.fieldnames(::Type{UA_QueryFirstResponse})
    (:responseHeader, :queryDataSetsSize, :queryDataSets,
        :continuationPoint, :parsingResultsSize, :parsingResults,
        :diagnosticInfosSize, :diagnosticInfos, :filterResult)
end
function Base.fieldnames(::Type{Ptr{UA_QueryFirstResponse}})
    (:responseHeader, :queryDataSetsSize, :queryDataSets,
        :continuationPoint, :parsingResultsSize, :parsingResults,
        :diagnosticInfosSize, :diagnosticInfos, :filterResult)
end

function Base.getproperty(x::Ptr{UA_QueryFirstResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :queryDataSetsSize && return Ptr{Csize_t}(x + 136)
    f === :queryDataSets && return Ptr{Ptr{UA_QueryDataSet}}(x + 144)
    f === :continuationPoint && return Ptr{UA_ByteString}(x + 152)
    f === :parsingResultsSize && return Ptr{Csize_t}(x + 168)
    f === :parsingResults && return Ptr{Ptr{UA_ParsingResult}}(x + 176)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 184)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 192)
    f === :filterResult && return Ptr{UA_ContentFilterResult}(x + 200)
    return getfield(x, f)
end

function Base.getproperty(x::UA_QueryFirstResponse, f::Symbol)
    r = Ref{UA_QueryFirstResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_QueryFirstResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_QueryFirstResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QueryNextRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_QueryNextRequest})
    (:requestHeader, :releaseContinuationPoint, :continuationPoint)
end
function Base.fieldnames(::Type{Ptr{UA_QueryNextRequest}})
    (:requestHeader, :releaseContinuationPoint, :continuationPoint)
end

function Base.getproperty(x::Ptr{UA_QueryNextRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :releaseContinuationPoint && return Ptr{UA_Boolean}(x + 112)
    f === :continuationPoint && return Ptr{UA_ByteString}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_QueryNextRequest, f::Symbol)
    r = Ref{UA_QueryNextRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_QueryNextRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_QueryNextRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_QueryNextResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_QueryNextResponse})
    (:responseHeader, :queryDataSetsSize, :queryDataSets, :revisedContinuationPoint)
end
function Base.fieldnames(::Type{Ptr{UA_QueryNextResponse}})
    (:responseHeader, :queryDataSetsSize, :queryDataSets, :revisedContinuationPoint)
end

function Base.getproperty(x::Ptr{UA_QueryNextResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :queryDataSetsSize && return Ptr{Csize_t}(x + 136)
    f === :queryDataSets && return Ptr{Ptr{UA_QueryDataSet}}(x + 144)
    f === :revisedContinuationPoint && return Ptr{UA_ByteString}(x + 152)
    return getfield(x, f)
end

function Base.getproperty(x::UA_QueryNextResponse, f::Symbol)
    r = Ref{UA_QueryNextResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_QueryNextResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_QueryNextResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadRequest
    data::NTuple{144, UInt8}
end

function Base.fieldnames(::Type{UA_ReadRequest})
    (:requestHeader, :maxAge, :timestampsToReturn, :nodesToReadSize, :nodesToRead)
end
function Base.fieldnames(::Type{Ptr{UA_ReadRequest}})
    (:requestHeader, :maxAge, :timestampsToReturn, :nodesToReadSize, :nodesToRead)
end

function Base.getproperty(x::Ptr{UA_ReadRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :maxAge && return Ptr{UA_Double}(x + 112)
    f === :timestampsToReturn && return Ptr{UA_TimestampsToReturn}(x + 120)
    f === :nodesToReadSize && return Ptr{Csize_t}(x + 128)
    f === :nodesToRead && return Ptr{Ptr{UA_ReadValueId}}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReadRequest, f::Symbol)
    r = Ref{UA_ReadRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReadRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReadRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_ReadResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_ReadResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_ReadResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_DataValue}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReadResponse, f::Symbol)
    r = Ref{UA_ReadResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReadResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReadResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryReadValueId
    data::NTuple{80, UInt8}
end

function Base.fieldnames(::Type{UA_HistoryReadValueId})
    (:nodeId, :indexRange, :dataEncoding, :continuationPoint)
end
function Base.fieldnames(::Type{Ptr{UA_HistoryReadValueId}})
    (:nodeId, :indexRange, :dataEncoding, :continuationPoint)
end

function Base.getproperty(x::Ptr{UA_HistoryReadValueId}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :indexRange && return Ptr{UA_String}(x + 24)
    f === :dataEncoding && return Ptr{UA_QualifiedName}(x + 40)
    f === :continuationPoint && return Ptr{UA_ByteString}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryReadValueId, f::Symbol)
    r = Ref{UA_HistoryReadValueId}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryReadValueId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryReadValueId}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryReadResult
    data::NTuple{72, UInt8}
end

function Base.fieldnames(::Type{UA_HistoryReadResult})
    (:statusCode, :continuationPoint, :historyData)
end
function Base.fieldnames(::Type{Ptr{UA_HistoryReadResult}})
    (:statusCode, :continuationPoint, :historyData)
end

function Base.getproperty(x::Ptr{UA_HistoryReadResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :continuationPoint && return Ptr{UA_ByteString}(x + 8)
    f === :historyData && return Ptr{UA_ExtensionObject}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryReadResult, f::Symbol)
    r = Ref{UA_HistoryReadResult}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryReadResult}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryReadResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadRawModifiedDetails
    isReadModified::UA_Boolean
    startTime::UA_DateTime
    endTime::UA_DateTime
    numValuesPerNode::UA_UInt32
    returnBounds::UA_Boolean
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadAtTimeDetails
    reqTimesSize::Csize_t
    reqTimes::Ptr{UA_DateTime}
    useSimpleBounds::UA_Boolean
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadAnnotationDataDetails
    reqTimesSize::Csize_t
    reqTimes::Ptr{UA_DateTime}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryData
    dataValuesSize::Csize_t
    dataValues::Ptr{UA_DataValue}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryReadRequest
    data::NTuple{184, UInt8}
end

function Base.fieldnames(::Type{UA_HistoryReadRequest})
    (:requestHeader, :historyReadDetails, :timestampsToReturn,
        :releaseContinuationPoints, :nodesToReadSize, :nodesToRead)
end
function Base.fieldnames(::Type{Ptr{UA_HistoryReadRequest}})
    (:requestHeader, :historyReadDetails, :timestampsToReturn,
        :releaseContinuationPoints, :nodesToReadSize, :nodesToRead)
end

function Base.getproperty(x::Ptr{UA_HistoryReadRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :historyReadDetails && return Ptr{UA_ExtensionObject}(x + 112)
    f === :timestampsToReturn && return Ptr{UA_TimestampsToReturn}(x + 160)
    f === :releaseContinuationPoints && return Ptr{UA_Boolean}(x + 164)
    f === :nodesToReadSize && return Ptr{Csize_t}(x + 168)
    f === :nodesToRead && return Ptr{Ptr{UA_HistoryReadValueId}}(x + 176)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryReadRequest, f::Symbol)
    r = Ref{UA_HistoryReadRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryReadRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryReadRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryReadResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_HistoryReadResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_HistoryReadResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_HistoryReadResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_HistoryReadResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryReadResponse, f::Symbol)
    r = Ref{UA_HistoryReadResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryReadResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryReadResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_WriteRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_WriteRequest})
    (:requestHeader, :nodesToWriteSize, :nodesToWrite)
end
function Base.fieldnames(::Type{Ptr{UA_WriteRequest}})
    (:requestHeader, :nodesToWriteSize, :nodesToWrite)
end

function Base.getproperty(x::Ptr{UA_WriteRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :nodesToWriteSize && return Ptr{Csize_t}(x + 112)
    f === :nodesToWrite && return Ptr{Ptr{UA_WriteValue}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_WriteRequest, f::Symbol)
    r = Ref{UA_WriteRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_WriteRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_WriteRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_WriteResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_WriteResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_WriteResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_WriteResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_WriteResponse, f::Symbol)
    r = Ref{UA_WriteResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_WriteResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_WriteResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryUpdateDetails
    data::NTuple{24, UInt8}
end

Base.fieldnames(::Type{UA_HistoryUpdateDetails}) = (:nodeId,)
Base.fieldnames(::Type{Ptr{UA_HistoryUpdateDetails}}) = (:nodeId,)

function Base.getproperty(x::Ptr{UA_HistoryUpdateDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryUpdateDetails, f::Symbol)
    r = Ref{UA_HistoryUpdateDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryUpdateDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryUpdateDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_HistoryUpdateType::UInt32 begin
    UA_HISTORYUPDATETYPE_INSERT = 1
    UA_HISTORYUPDATETYPE_REPLACE = 2
    UA_HISTORYUPDATETYPE_UPDATE = 3
    UA_HISTORYUPDATETYPE_DELETE = 4
    __UA_HISTORYUPDATETYPE_FORCE32BIT = 2147483647
end

@cenum UA_PerformUpdateType::UInt32 begin
    UA_PERFORMUPDATETYPE_INSERT = 1
    UA_PERFORMUPDATETYPE_REPLACE = 2
    UA_PERFORMUPDATETYPE_UPDATE = 3
    UA_PERFORMUPDATETYPE_REMOVE = 4
    __UA_PERFORMUPDATETYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UpdateDataDetails
    data::NTuple{48, UInt8}
end

function Base.fieldnames(::Type{UA_UpdateDataDetails})
    (:nodeId, :performInsertReplace, :updateValuesSize, :updateValues)
end
function Base.fieldnames(::Type{Ptr{UA_UpdateDataDetails}})
    (:nodeId, :performInsertReplace, :updateValuesSize, :updateValues)
end

function Base.getproperty(x::Ptr{UA_UpdateDataDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :performInsertReplace && return Ptr{UA_PerformUpdateType}(x + 24)
    f === :updateValuesSize && return Ptr{Csize_t}(x + 32)
    f === :updateValues && return Ptr{Ptr{UA_DataValue}}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_UpdateDataDetails, f::Symbol)
    r = Ref{UA_UpdateDataDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_UpdateDataDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_UpdateDataDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UpdateStructureDataDetails
    data::NTuple{48, UInt8}
end

function Base.fieldnames(::Type{UA_UpdateStructureDataDetails})
    (:nodeId, :performInsertReplace, :updateValuesSize, :updateValues)
end
function Base.fieldnames(::Type{Ptr{UA_UpdateStructureDataDetails}})
    (:nodeId, :performInsertReplace, :updateValuesSize, :updateValues)
end

function Base.getproperty(x::Ptr{UA_UpdateStructureDataDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :performInsertReplace && return Ptr{UA_PerformUpdateType}(x + 24)
    f === :updateValuesSize && return Ptr{Csize_t}(x + 32)
    f === :updateValues && return Ptr{Ptr{UA_DataValue}}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_UpdateStructureDataDetails, f::Symbol)
    r = Ref{UA_UpdateStructureDataDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_UpdateStructureDataDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_UpdateStructureDataDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteRawModifiedDetails
    data::NTuple{48, UInt8}
end

function Base.fieldnames(::Type{UA_DeleteRawModifiedDetails})
    (:nodeId, :isDeleteModified, :startTime, :endTime)
end
function Base.fieldnames(::Type{Ptr{UA_DeleteRawModifiedDetails}})
    (:nodeId, :isDeleteModified, :startTime, :endTime)
end

function Base.getproperty(x::Ptr{UA_DeleteRawModifiedDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :isDeleteModified && return Ptr{UA_Boolean}(x + 24)
    f === :startTime && return Ptr{UA_DateTime}(x + 32)
    f === :endTime && return Ptr{UA_DateTime}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteRawModifiedDetails, f::Symbol)
    r = Ref{UA_DeleteRawModifiedDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteRawModifiedDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteRawModifiedDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteAtTimeDetails
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{UA_DeleteAtTimeDetails}) = (:nodeId, :reqTimesSize, :reqTimes)
Base.fieldnames(::Type{Ptr{UA_DeleteAtTimeDetails}}) = (:nodeId, :reqTimesSize, :reqTimes)

function Base.getproperty(x::Ptr{UA_DeleteAtTimeDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :reqTimesSize && return Ptr{Csize_t}(x + 24)
    f === :reqTimes && return Ptr{Ptr{UA_DateTime}}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteAtTimeDetails, f::Symbol)
    r = Ref{UA_DeleteAtTimeDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteAtTimeDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteAtTimeDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DeleteEventDetails
    data::NTuple{40, UInt8}
end

Base.fieldnames(::Type{UA_DeleteEventDetails}) = (:nodeId, :eventIdsSize, :eventIds)
Base.fieldnames(::Type{Ptr{UA_DeleteEventDetails}}) = (:nodeId, :eventIdsSize, :eventIds)

function Base.getproperty(x::Ptr{UA_DeleteEventDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :eventIdsSize && return Ptr{Csize_t}(x + 24)
    f === :eventIds && return Ptr{Ptr{UA_ByteString}}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DeleteEventDetails, f::Symbol)
    r = Ref{UA_DeleteEventDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DeleteEventDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DeleteEventDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryUpdateResult
    statusCode::UA_StatusCode
    operationResultsSize::Csize_t
    operationResults::Ptr{UA_StatusCode}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryUpdateRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_HistoryUpdateRequest})
    (:requestHeader, :historyUpdateDetailsSize, :historyUpdateDetails)
end
function Base.fieldnames(::Type{Ptr{UA_HistoryUpdateRequest}})
    (:requestHeader, :historyUpdateDetailsSize, :historyUpdateDetails)
end

function Base.getproperty(x::Ptr{UA_HistoryUpdateRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :historyUpdateDetailsSize && return Ptr{Csize_t}(x + 112)
    f === :historyUpdateDetails && return Ptr{Ptr{UA_ExtensionObject}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryUpdateRequest, f::Symbol)
    r = Ref{UA_HistoryUpdateRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryUpdateRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryUpdateRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryUpdateResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_HistoryUpdateResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_HistoryUpdateResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_HistoryUpdateResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_HistoryUpdateResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_HistoryUpdateResponse, f::Symbol)
    r = Ref{UA_HistoryUpdateResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_HistoryUpdateResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_HistoryUpdateResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CallRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_CallRequest})
    (:requestHeader, :methodsToCallSize, :methodsToCall)
end
function Base.fieldnames(::Type{Ptr{UA_CallRequest}})
    (:requestHeader, :methodsToCallSize, :methodsToCall)
end

function Base.getproperty(x::Ptr{UA_CallRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :methodsToCallSize && return Ptr{Csize_t}(x + 112)
    f === :methodsToCall && return Ptr{Ptr{UA_CallMethodRequest}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CallRequest, f::Symbol)
    r = Ref{UA_CallRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CallRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CallRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_CallResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_CallResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_CallResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_CallResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_CallMethodResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_CallResponse, f::Symbol)
    r = Ref{UA_CallResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_CallResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_CallResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_DataChangeTrigger::UInt32 begin
    UA_DATACHANGETRIGGER_STATUS = 0
    UA_DATACHANGETRIGGER_STATUSVALUE = 1
    UA_DATACHANGETRIGGER_STATUSVALUETIMESTAMP = 2
    __UA_DATACHANGETRIGGER_FORCE32BIT = 2147483647
end

@cenum UA_DeadbandType::UInt32 begin
    UA_DEADBANDTYPE_NONE = 0
    UA_DEADBANDTYPE_ABSOLUTE = 1
    UA_DEADBANDTYPE_PERCENT = 2
    __UA_DEADBANDTYPE_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataChangeFilter
    trigger::UA_DataChangeTrigger
    deadbandType::UA_UInt32
    deadbandValue::UA_Double
end
function Base.getproperty(x::Ptr{UA_DataChangeFilter}, f::Symbol)
    f === :trigger && return Ptr{UA_DataChangeTrigger}(x + 0)
    f === :deadbandType && return Ptr{UA_UInt32}(x + 4)
    f === :deadbandValue && return Ptr{UA_Double}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_DataChangeFilter}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AggregateConfiguration
    useServerCapabilitiesDefaults::UA_Boolean
    treatUncertainAsBad::UA_Boolean
    percentDataBad::UA_Byte
    percentDataGood::UA_Byte
    useSlopedExtrapolation::UA_Boolean
end
function Base.getproperty(x::Ptr{UA_AggregateConfiguration}, f::Symbol)
    f === :useServerCapabilitiesDefaults && return Ptr{UA_Boolean}(x + 0)
    f === :treatUncertainAsBad && return Ptr{UA_Boolean}(x + 1)
    f === :percentDataBad && return Ptr{UA_Byte}(x + 2)
    f === :percentDataGood && return Ptr{UA_Byte}(x + 3)
    f === :useSlopedExtrapolation && return Ptr{UA_Boolean}(x + 4)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_AggregateConfiguration}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AggregateFilter
    data::NTuple{48, UInt8}
end

function Base.fieldnames(::Type{UA_AggregateFilter})
    (:startTime, :aggregateType, :processingInterval, :aggregateConfiguration)
end
function Base.fieldnames(::Type{Ptr{UA_AggregateFilter}})
    (:startTime, :aggregateType, :processingInterval, :aggregateConfiguration)
end

function Base.getproperty(x::Ptr{UA_AggregateFilter}, f::Symbol)
    f === :startTime && return Ptr{UA_DateTime}(x + 0)
    f === :aggregateType && return Ptr{UA_NodeId}(x + 8)
    f === :processingInterval && return Ptr{UA_Double}(x + 32)
    f === :aggregateConfiguration && return Ptr{UA_AggregateConfiguration}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_AggregateFilter, f::Symbol)
    r = Ref{UA_AggregateFilter}(x)
    ptr = Base.unsafe_convert(Ptr{UA_AggregateFilter}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_AggregateFilter}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EventFilterResult
    selectClauseResultsSize::Csize_t
    selectClauseResults::Ptr{UA_StatusCode}
    selectClauseDiagnosticInfosSize::Csize_t
    selectClauseDiagnosticInfos::Ptr{UA_DiagnosticInfo}
    whereClauseResult::UA_ContentFilterResult
end
function Base.getproperty(x::Ptr{UA_EventFilterResult}, f::Symbol)
    f === :selectClauseResultsSize && return Ptr{Csize_t}(x + 0)
    f === :selectClauseResults && return Ptr{Ptr{UA_StatusCode}}(x + 8)
    f === :selectClauseDiagnosticInfosSize && return Ptr{Csize_t}(x + 16)
    f === :selectClauseDiagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 24)
    f === :whereClauseResult && return Ptr{UA_ContentFilterResult}(x + 32)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EventFilterResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AggregateFilterResult
    revisedStartTime::UA_DateTime
    revisedProcessingInterval::UA_Double
    revisedAggregateConfiguration::UA_AggregateConfiguration
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SetMonitoringModeRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_SetMonitoringModeRequest})
    (:requestHeader, :subscriptionId, :monitoringMode,
        :monitoredItemIdsSize, :monitoredItemIds)
end
function Base.fieldnames(::Type{Ptr{UA_SetMonitoringModeRequest}})
    (:requestHeader, :subscriptionId, :monitoringMode,
        :monitoredItemIdsSize, :monitoredItemIds)
end

function Base.getproperty(x::Ptr{UA_SetMonitoringModeRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :monitoringMode && return Ptr{UA_MonitoringMode}(x + 116)
    f === :monitoredItemIdsSize && return Ptr{Csize_t}(x + 120)
    f === :monitoredItemIds && return Ptr{Ptr{UA_UInt32}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SetMonitoringModeRequest, f::Symbol)
    r = Ref{UA_SetMonitoringModeRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SetMonitoringModeRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SetMonitoringModeRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SetMonitoringModeResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_SetMonitoringModeResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_SetMonitoringModeResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_SetMonitoringModeResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SetMonitoringModeResponse, f::Symbol)
    r = Ref{UA_SetMonitoringModeResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SetMonitoringModeResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SetMonitoringModeResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SetTriggeringRequest
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_SetTriggeringRequest})
    (:requestHeader, :subscriptionId, :triggeringItemId,
        :linksToAddSize, :linksToAdd, :linksToRemoveSize, :linksToRemove)
end
function Base.fieldnames(::Type{Ptr{UA_SetTriggeringRequest}})
    (:requestHeader, :subscriptionId, :triggeringItemId,
        :linksToAddSize, :linksToAdd, :linksToRemoveSize, :linksToRemove)
end

function Base.getproperty(x::Ptr{UA_SetTriggeringRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :triggeringItemId && return Ptr{UA_UInt32}(x + 116)
    f === :linksToAddSize && return Ptr{Csize_t}(x + 120)
    f === :linksToAdd && return Ptr{Ptr{UA_UInt32}}(x + 128)
    f === :linksToRemoveSize && return Ptr{Csize_t}(x + 136)
    f === :linksToRemove && return Ptr{Ptr{UA_UInt32}}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SetTriggeringRequest, f::Symbol)
    r = Ref{UA_SetTriggeringRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SetTriggeringRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SetTriggeringRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SetTriggeringResponse
    data::NTuple{200, UInt8}
end

function Base.fieldnames(::Type{UA_SetTriggeringResponse})
    (:responseHeader, :addResultsSize, :addResults, :addDiagnosticInfosSize,
        :addDiagnosticInfos, :removeResultsSize, :removeResults,
        :removeDiagnosticInfosSize, :removeDiagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_SetTriggeringResponse}})
    (:responseHeader, :addResultsSize, :addResults, :addDiagnosticInfosSize,
        :addDiagnosticInfos, :removeResultsSize, :removeResults,
        :removeDiagnosticInfosSize, :removeDiagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_SetTriggeringResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :addResultsSize && return Ptr{Csize_t}(x + 136)
    f === :addResults && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :addDiagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :addDiagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    f === :removeResultsSize && return Ptr{Csize_t}(x + 168)
    f === :removeResults && return Ptr{Ptr{UA_StatusCode}}(x + 176)
    f === :removeDiagnosticInfosSize && return Ptr{Csize_t}(x + 184)
    f === :removeDiagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SetTriggeringResponse, f::Symbol)
    r = Ref{UA_SetTriggeringResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SetTriggeringResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SetTriggeringResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SetPublishingModeRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_SetPublishingModeRequest})
    (:requestHeader, :publishingEnabled, :subscriptionIdsSize, :subscriptionIds)
end
function Base.fieldnames(::Type{Ptr{UA_SetPublishingModeRequest}})
    (:requestHeader, :publishingEnabled, :subscriptionIdsSize, :subscriptionIds)
end

function Base.getproperty(x::Ptr{UA_SetPublishingModeRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :publishingEnabled && return Ptr{UA_Boolean}(x + 112)
    f === :subscriptionIdsSize && return Ptr{Csize_t}(x + 120)
    f === :subscriptionIds && return Ptr{Ptr{UA_UInt32}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SetPublishingModeRequest, f::Symbol)
    r = Ref{UA_SetPublishingModeRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SetPublishingModeRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SetPublishingModeRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SetPublishingModeResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_SetPublishingModeResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_SetPublishingModeResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_SetPublishingModeResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SetPublishingModeResponse, f::Symbol)
    r = Ref{UA_SetPublishingModeResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SetPublishingModeResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SetPublishingModeResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_NotificationMessage
    sequenceNumber::UA_UInt32
    publishTime::UA_DateTime
    notificationDataSize::Csize_t
    notificationData::Ptr{UA_ExtensionObject}
end
function Base.getproperty(x::Ptr{UA_NotificationMessage}, f::Symbol)
    f === :sequenceNumber && return Ptr{UA_UInt32}(x + 0)
    f === :publishTime && return Ptr{UA_DateTime}(x + 8)
    f === :notificationDataSize && return Ptr{Csize_t}(x + 16)
    f === :notificationData && return Ptr{Ptr{UA_ExtensionObject}}(x + 24)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_NotificationMessage}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MonitoredItemNotification
    data::NTuple{88, UInt8}
end

Base.fieldnames(::Type{UA_MonitoredItemNotification}) = (:clientHandle, :value)
Base.fieldnames(::Type{Ptr{UA_MonitoredItemNotification}}) = (:clientHandle, :value)

function Base.getproperty(x::Ptr{UA_MonitoredItemNotification}, f::Symbol)
    f === :clientHandle && return Ptr{UA_UInt32}(x + 0)
    f === :value && return Ptr{UA_DataValue}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MonitoredItemNotification, f::Symbol)
    r = Ref{UA_MonitoredItemNotification}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MonitoredItemNotification}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MonitoredItemNotification}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EventFieldList
    clientHandle::UA_UInt32
    eventFieldsSize::Csize_t
    eventFields::Ptr{UA_Variant}
end
function Base.getproperty(x::Ptr{UA_EventFieldList}, f::Symbol)
    f === :clientHandle && return Ptr{UA_UInt32}(x + 0)
    f === :eventFieldsSize && return Ptr{Csize_t}(x + 8)
    f === :eventFields && return Ptr{Ptr{UA_Variant}}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EventFieldList}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryEventFieldList
    eventFieldsSize::Csize_t
    eventFields::Ptr{UA_Variant}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StatusChangeNotification
    data::NTuple{64, UInt8}
end

Base.fieldnames(::Type{UA_StatusChangeNotification}) = (:status, :diagnosticInfo)
Base.fieldnames(::Type{Ptr{UA_StatusChangeNotification}}) = (:status, :diagnosticInfo)

function Base.getproperty(x::Ptr{UA_StatusChangeNotification}, f::Symbol)
    f === :status && return Ptr{UA_StatusCode}(x + 0)
    f === :diagnosticInfo && return Ptr{UA_DiagnosticInfo}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StatusChangeNotification, f::Symbol)
    r = Ref{UA_StatusChangeNotification}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StatusChangeNotification}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StatusChangeNotification}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SubscriptionAcknowledgement
    subscriptionId::UA_UInt32
    sequenceNumber::UA_UInt32
end
function Base.getproperty(x::Ptr{UA_SubscriptionAcknowledgement}, f::Symbol)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 0)
    f === :sequenceNumber && return Ptr{UA_UInt32}(x + 4)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_SubscriptionAcknowledgement}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishRequest
    data::NTuple{128, UInt8}
end

function Base.fieldnames(::Type{UA_PublishRequest})
    (:requestHeader, :subscriptionAcknowledgementsSize, :subscriptionAcknowledgements)
end
function Base.fieldnames(::Type{Ptr{UA_PublishRequest}})
    (:requestHeader, :subscriptionAcknowledgementsSize, :subscriptionAcknowledgements)
end

function Base.getproperty(x::Ptr{UA_PublishRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionAcknowledgementsSize && return Ptr{Csize_t}(x + 112)
    f === :subscriptionAcknowledgements &&
        return Ptr{Ptr{UA_SubscriptionAcknowledgement}}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishRequest, f::Symbol)
    r = Ref{UA_PublishRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishResponse
    data::NTuple{232, UInt8}
end

function Base.fieldnames(::Type{UA_PublishResponse})
    (:responseHeader, :subscriptionId, :availableSequenceNumbersSize,
        :availableSequenceNumbers, :moreNotifications, :notificationMessage,
        :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_PublishResponse}})
    (:responseHeader, :subscriptionId, :availableSequenceNumbersSize,
        :availableSequenceNumbers, :moreNotifications, :notificationMessage,
        :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_PublishResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 136)
    f === :availableSequenceNumbersSize && return Ptr{Csize_t}(x + 144)
    f === :availableSequenceNumbers && return Ptr{Ptr{UA_UInt32}}(x + 152)
    f === :moreNotifications && return Ptr{UA_Boolean}(x + 160)
    f === :notificationMessage && return Ptr{UA_NotificationMessage}(x + 168)
    f === :resultsSize && return Ptr{Csize_t}(x + 200)
    f === :results && return Ptr{Ptr{UA_StatusCode}}(x + 208)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 216)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 224)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishResponse, f::Symbol)
    r = Ref{UA_PublishResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RepublishRequest
    data::NTuple{120, UInt8}
end

function Base.fieldnames(::Type{UA_RepublishRequest})
    (:requestHeader, :subscriptionId, :retransmitSequenceNumber)
end
function Base.fieldnames(::Type{Ptr{UA_RepublishRequest}})
    (:requestHeader, :subscriptionId, :retransmitSequenceNumber)
end

function Base.getproperty(x::Ptr{UA_RepublishRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 112)
    f === :retransmitSequenceNumber && return Ptr{UA_UInt32}(x + 116)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RepublishRequest, f::Symbol)
    r = Ref{UA_RepublishRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RepublishRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RepublishRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RepublishResponse
    data::NTuple{168, UInt8}
end

Base.fieldnames(::Type{UA_RepublishResponse}) = (:responseHeader, :notificationMessage)
Base.fieldnames(::Type{Ptr{UA_RepublishResponse}}) = (:responseHeader, :notificationMessage)

function Base.getproperty(x::Ptr{UA_RepublishResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :notificationMessage && return Ptr{UA_NotificationMessage}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::UA_RepublishResponse, f::Symbol)
    r = Ref{UA_RepublishResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_RepublishResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_RepublishResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TransferResult
    statusCode::UA_StatusCode
    availableSequenceNumbersSize::Csize_t
    availableSequenceNumbers::Ptr{UA_UInt32}
end
function Base.getproperty(x::Ptr{UA_TransferResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :availableSequenceNumbersSize && return Ptr{Csize_t}(x + 8)
    f === :availableSequenceNumbers && return Ptr{Ptr{UA_UInt32}}(x + 16)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_TransferResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TransferSubscriptionsRequest
    data::NTuple{136, UInt8}
end

function Base.fieldnames(::Type{UA_TransferSubscriptionsRequest})
    (:requestHeader, :subscriptionIdsSize, :subscriptionIds, :sendInitialValues)
end
function Base.fieldnames(::Type{Ptr{UA_TransferSubscriptionsRequest}})
    (:requestHeader, :subscriptionIdsSize, :subscriptionIds, :sendInitialValues)
end

function Base.getproperty(x::Ptr{UA_TransferSubscriptionsRequest}, f::Symbol)
    f === :requestHeader && return Ptr{UA_RequestHeader}(x + 0)
    f === :subscriptionIdsSize && return Ptr{Csize_t}(x + 112)
    f === :subscriptionIds && return Ptr{Ptr{UA_UInt32}}(x + 120)
    f === :sendInitialValues && return Ptr{UA_Boolean}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_TransferSubscriptionsRequest, f::Symbol)
    r = Ref{UA_TransferSubscriptionsRequest}(x)
    ptr = Base.unsafe_convert(Ptr{UA_TransferSubscriptionsRequest}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_TransferSubscriptionsRequest}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TransferSubscriptionsResponse
    data::NTuple{168, UInt8}
end

function Base.fieldnames(::Type{UA_TransferSubscriptionsResponse})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end
function Base.fieldnames(::Type{Ptr{UA_TransferSubscriptionsResponse}})
    (:responseHeader, :resultsSize, :results, :diagnosticInfosSize, :diagnosticInfos)
end

function Base.getproperty(x::Ptr{UA_TransferSubscriptionsResponse}, f::Symbol)
    f === :responseHeader && return Ptr{UA_ResponseHeader}(x + 0)
    f === :resultsSize && return Ptr{Csize_t}(x + 136)
    f === :results && return Ptr{Ptr{UA_TransferResult}}(x + 144)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 152)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::UA_TransferSubscriptionsResponse, f::Symbol)
    r = Ref{UA_TransferSubscriptionsResponse}(x)
    ptr = Base.unsafe_convert(Ptr{UA_TransferSubscriptionsResponse}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_TransferSubscriptionsResponse}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_RedundancySupport::UInt32 begin
    UA_REDUNDANCYSUPPORT_NONE = 0
    UA_REDUNDANCYSUPPORT_COLD = 1
    UA_REDUNDANCYSUPPORT_WARM = 2
    UA_REDUNDANCYSUPPORT_HOT = 3
    UA_REDUNDANCYSUPPORT_TRANSPARENT = 4
    UA_REDUNDANCYSUPPORT_HOTANDMIRRORED = 5
    __UA_REDUNDANCYSUPPORT_FORCE32BIT = 2147483647
end

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

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_RedundantServerDataType
    serverId::UA_String
    serviceLevel::UA_Byte
    serverState::UA_ServerState
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EndpointUrlListDataType
    endpointUrlListSize::Csize_t
    endpointUrlList::Ptr{UA_String}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_NetworkGroupDataType
    serverUri::UA_String
    networkPathsSize::Csize_t
    networkPaths::Ptr{UA_EndpointUrlListDataType}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SamplingIntervalDiagnosticsDataType
    samplingInterval::UA_Double
    monitoredItemCount::UA_UInt32
    maxMonitoredItemCount::UA_UInt32
    disabledMonitoredItemCount::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
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
function Base.getproperty(x::Ptr{UA_ServerDiagnosticsSummaryDataType}, f::Symbol)
    f === :serverViewCount && return Ptr{UA_UInt32}(x + 0)
    f === :currentSessionCount && return Ptr{UA_UInt32}(x + 4)
    f === :cumulatedSessionCount && return Ptr{UA_UInt32}(x + 8)
    f === :securityRejectedSessionCount && return Ptr{UA_UInt32}(x + 12)
    f === :rejectedSessionCount && return Ptr{UA_UInt32}(x + 16)
    f === :sessionTimeoutCount && return Ptr{UA_UInt32}(x + 20)
    f === :sessionAbortCount && return Ptr{UA_UInt32}(x + 24)
    f === :currentSubscriptionCount && return Ptr{UA_UInt32}(x + 28)
    f === :cumulatedSubscriptionCount && return Ptr{UA_UInt32}(x + 32)
    f === :publishingIntervalCount && return Ptr{UA_UInt32}(x + 36)
    f === :securityRejectedRequestsCount && return Ptr{UA_UInt32}(x + 40)
    f === :rejectedRequestsCount && return Ptr{UA_UInt32}(x + 44)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ServerDiagnosticsSummaryDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ServerStatusDataType
    startTime::UA_DateTime
    currentTime::UA_DateTime
    state::UA_ServerState
    buildInfo::UA_BuildInfo
    secondsTillShutdown::UA_UInt32
    shutdownReason::UA_LocalizedText
end
function Base.getproperty(x::Ptr{UA_ServerStatusDataType}, f::Symbol)
    f === :startTime && return Ptr{UA_DateTime}(x + 0)
    f === :currentTime && return Ptr{UA_DateTime}(x + 8)
    f === :state && return Ptr{UA_ServerState}(x + 16)
    f === :buildInfo && return Ptr{UA_BuildInfo}(x + 24)
    f === :secondsTillShutdown && return Ptr{UA_UInt32}(x + 112)
    f === :shutdownReason && return Ptr{UA_LocalizedText}(x + 120)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ServerStatusDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SessionSecurityDiagnosticsDataType
    data::NTuple{144, UInt8}
end

function Base.fieldnames(::Type{UA_SessionSecurityDiagnosticsDataType})
    (:sessionId, :clientUserIdOfSession, :clientUserIdHistorySize,
        :clientUserIdHistory, :authenticationMechanism, :encoding,
        :transportProtocol, :securityMode, :securityPolicyUri, :clientCertificate)
end
function Base.fieldnames(::Type{Ptr{UA_SessionSecurityDiagnosticsDataType}})
    (:sessionId, :clientUserIdOfSession, :clientUserIdHistorySize,
        :clientUserIdHistory, :authenticationMechanism, :encoding,
        :transportProtocol, :securityMode, :securityPolicyUri, :clientCertificate)
end

function Base.getproperty(x::Ptr{UA_SessionSecurityDiagnosticsDataType}, f::Symbol)
    f === :sessionId && return Ptr{UA_NodeId}(x + 0)
    f === :clientUserIdOfSession && return Ptr{UA_String}(x + 24)
    f === :clientUserIdHistorySize && return Ptr{Csize_t}(x + 40)
    f === :clientUserIdHistory && return Ptr{Ptr{UA_String}}(x + 48)
    f === :authenticationMechanism && return Ptr{UA_String}(x + 56)
    f === :encoding && return Ptr{UA_String}(x + 72)
    f === :transportProtocol && return Ptr{UA_String}(x + 88)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 104)
    f === :securityPolicyUri && return Ptr{UA_String}(x + 112)
    f === :clientCertificate && return Ptr{UA_ByteString}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SessionSecurityDiagnosticsDataType, f::Symbol)
    r = Ref{UA_SessionSecurityDiagnosticsDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SessionSecurityDiagnosticsDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SessionSecurityDiagnosticsDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ServiceCounterDataType
    totalCount::UA_UInt32
    errorCount::UA_UInt32
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StatusResult
    data::NTuple{64, UInt8}
end

Base.fieldnames(::Type{UA_StatusResult}) = (:statusCode, :diagnosticInfo)
Base.fieldnames(::Type{Ptr{UA_StatusResult}}) = (:statusCode, :diagnosticInfo)

function Base.getproperty(x::Ptr{UA_StatusResult}, f::Symbol)
    f === :statusCode && return Ptr{UA_StatusCode}(x + 0)
    f === :diagnosticInfo && return Ptr{UA_DiagnosticInfo}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StatusResult, f::Symbol)
    r = Ref{UA_StatusResult}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StatusResult}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StatusResult}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SubscriptionDiagnosticsDataType
    data::NTuple{152, UInt8}
end

function Base.fieldnames(::Type{UA_SubscriptionDiagnosticsDataType})
    (:sessionId, :subscriptionId, :priority, :publishingInterval, :maxKeepAliveCount,
        :maxLifetimeCount, :maxNotificationsPerPublish, :publishingEnabled, :modifyCount,
        :enableCount, :disableCount, :republishRequestCount, :republishMessageRequestCount,
        :republishMessageCount, :transferRequestCount, :transferredToAltClientCount,
        :transferredToSameClientCount, :publishRequestCount, :dataChangeNotificationsCount,
        :eventNotificationsCount, :notificationsCount, :latePublishRequestCount,
        :currentKeepAliveCount, :currentLifetimeCount, :unacknowledgedMessageCount,
        :discardedMessageCount, :monitoredItemCount, :disabledMonitoredItemCount,
        :monitoringQueueOverflowCount, :nextSequenceNumber, :eventQueueOverFlowCount)
end
function Base.fieldnames(::Type{Ptr{UA_SubscriptionDiagnosticsDataType}})
    (:sessionId, :subscriptionId, :priority, :publishingInterval, :maxKeepAliveCount,
        :maxLifetimeCount, :maxNotificationsPerPublish, :publishingEnabled, :modifyCount,
        :enableCount, :disableCount, :republishRequestCount, :republishMessageRequestCount,
        :republishMessageCount, :transferRequestCount, :transferredToAltClientCount,
        :transferredToSameClientCount, :publishRequestCount, :dataChangeNotificationsCount,
        :eventNotificationsCount, :notificationsCount, :latePublishRequestCount,
        :currentKeepAliveCount, :currentLifetimeCount, :unacknowledgedMessageCount,
        :discardedMessageCount, :monitoredItemCount, :disabledMonitoredItemCount,
        :monitoringQueueOverflowCount, :nextSequenceNumber, :eventQueueOverFlowCount)
end

function Base.getproperty(x::Ptr{UA_SubscriptionDiagnosticsDataType}, f::Symbol)
    f === :sessionId && return Ptr{UA_NodeId}(x + 0)
    f === :subscriptionId && return Ptr{UA_UInt32}(x + 24)
    f === :priority && return Ptr{UA_Byte}(x + 28)
    f === :publishingInterval && return Ptr{UA_Double}(x + 32)
    f === :maxKeepAliveCount && return Ptr{UA_UInt32}(x + 40)
    f === :maxLifetimeCount && return Ptr{UA_UInt32}(x + 44)
    f === :maxNotificationsPerPublish && return Ptr{UA_UInt32}(x + 48)
    f === :publishingEnabled && return Ptr{UA_Boolean}(x + 52)
    f === :modifyCount && return Ptr{UA_UInt32}(x + 56)
    f === :enableCount && return Ptr{UA_UInt32}(x + 60)
    f === :disableCount && return Ptr{UA_UInt32}(x + 64)
    f === :republishRequestCount && return Ptr{UA_UInt32}(x + 68)
    f === :republishMessageRequestCount && return Ptr{UA_UInt32}(x + 72)
    f === :republishMessageCount && return Ptr{UA_UInt32}(x + 76)
    f === :transferRequestCount && return Ptr{UA_UInt32}(x + 80)
    f === :transferredToAltClientCount && return Ptr{UA_UInt32}(x + 84)
    f === :transferredToSameClientCount && return Ptr{UA_UInt32}(x + 88)
    f === :publishRequestCount && return Ptr{UA_UInt32}(x + 92)
    f === :dataChangeNotificationsCount && return Ptr{UA_UInt32}(x + 96)
    f === :eventNotificationsCount && return Ptr{UA_UInt32}(x + 100)
    f === :notificationsCount && return Ptr{UA_UInt32}(x + 104)
    f === :latePublishRequestCount && return Ptr{UA_UInt32}(x + 108)
    f === :currentKeepAliveCount && return Ptr{UA_UInt32}(x + 112)
    f === :currentLifetimeCount && return Ptr{UA_UInt32}(x + 116)
    f === :unacknowledgedMessageCount && return Ptr{UA_UInt32}(x + 120)
    f === :discardedMessageCount && return Ptr{UA_UInt32}(x + 124)
    f === :monitoredItemCount && return Ptr{UA_UInt32}(x + 128)
    f === :disabledMonitoredItemCount && return Ptr{UA_UInt32}(x + 132)
    f === :monitoringQueueOverflowCount && return Ptr{UA_UInt32}(x + 136)
    f === :nextSequenceNumber && return Ptr{UA_UInt32}(x + 140)
    f === :eventQueueOverFlowCount && return Ptr{UA_UInt32}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SubscriptionDiagnosticsDataType, f::Symbol)
    r = Ref{UA_SubscriptionDiagnosticsDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SubscriptionDiagnosticsDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SubscriptionDiagnosticsDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_ModelChangeStructureVerbMask::UInt32 begin
    UA_MODELCHANGESTRUCTUREVERBMASK_NODEADDED = 1
    UA_MODELCHANGESTRUCTUREVERBMASK_NODEDELETED = 2
    UA_MODELCHANGESTRUCTUREVERBMASK_REFERENCEADDED = 4
    UA_MODELCHANGESTRUCTUREVERBMASK_REFERENCEDELETED = 8
    UA_MODELCHANGESTRUCTUREVERBMASK_DATATYPECHANGED = 16
    __UA_MODELCHANGESTRUCTUREVERBMASK_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ModelChangeStructureDataType
    data::NTuple{56, UInt8}
end

Base.fieldnames(::Type{UA_ModelChangeStructureDataType}) = (:affected, :affectedType, :verb)
function Base.fieldnames(::Type{Ptr{UA_ModelChangeStructureDataType}})
    (:affected, :affectedType, :verb)
end

function Base.getproperty(x::Ptr{UA_ModelChangeStructureDataType}, f::Symbol)
    f === :affected && return Ptr{UA_NodeId}(x + 0)
    f === :affectedType && return Ptr{UA_NodeId}(x + 24)
    f === :verb && return Ptr{UA_Byte}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ModelChangeStructureDataType, f::Symbol)
    r = Ref{UA_ModelChangeStructureDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ModelChangeStructureDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ModelChangeStructureDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SemanticChangeStructureDataType
    data::NTuple{48, UInt8}
end

Base.fieldnames(::Type{UA_SemanticChangeStructureDataType}) = (:affected, :affectedType)
function Base.fieldnames(::Type{Ptr{UA_SemanticChangeStructureDataType}})
    (:affected, :affectedType)
end

function Base.getproperty(x::Ptr{UA_SemanticChangeStructureDataType}, f::Symbol)
    f === :affected && return Ptr{UA_NodeId}(x + 0)
    f === :affectedType && return Ptr{UA_NodeId}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SemanticChangeStructureDataType, f::Symbol)
    r = Ref{UA_SemanticChangeStructureDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SemanticChangeStructureDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SemanticChangeStructureDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_Range
    low::UA_Double
    high::UA_Double
end
function Base.getproperty(x::Ptr{UA_Range}, f::Symbol)
    f === :low && return Ptr{UA_Double}(x + 0)
    f === :high && return Ptr{UA_Double}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_Range}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EUInformation
    namespaceUri::UA_String
    unitId::UA_Int32
    displayName::UA_LocalizedText
    description::UA_LocalizedText
end
function Base.getproperty(x::Ptr{UA_EUInformation}, f::Symbol)
    f === :namespaceUri && return Ptr{UA_String}(x + 0)
    f === :unitId && return Ptr{UA_Int32}(x + 16)
    f === :displayName && return Ptr{UA_LocalizedText}(x + 24)
    f === :description && return Ptr{UA_LocalizedText}(x + 56)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EUInformation}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum UA_AxisScaleEnumeration::UInt32 begin
    UA_AXISSCALEENUMERATION_LINEAR = 0
    UA_AXISSCALEENUMERATION_LOG = 1
    UA_AXISSCALEENUMERATION_LN = 2
    __UA_AXISSCALEENUMERATION_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ComplexNumberType
    real::UA_Float
    imaginary::UA_Float
end
function Base.getproperty(x::Ptr{UA_ComplexNumberType}, f::Symbol)
    f === :real && return Ptr{UA_Float}(x + 0)
    f === :imaginary && return Ptr{UA_Float}(x + 4)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_ComplexNumberType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DoubleComplexNumberType
    real::UA_Double
    imaginary::UA_Double
end
function Base.getproperty(x::Ptr{UA_DoubleComplexNumberType}, f::Symbol)
    f === :real && return Ptr{UA_Double}(x + 0)
    f === :imaginary && return Ptr{UA_Double}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_DoubleComplexNumberType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_AxisInformation
    engineeringUnits::UA_EUInformation
    eURange::UA_Range
    title::UA_LocalizedText
    axisScaleType::UA_AxisScaleEnumeration
    axisStepsSize::Csize_t
    axisSteps::Ptr{UA_Double}
end
function Base.getproperty(x::Ptr{UA_AxisInformation}, f::Symbol)
    f === :engineeringUnits && return Ptr{UA_EUInformation}(x + 0)
    f === :eURange && return Ptr{UA_Range}(x + 88)
    f === :title && return Ptr{UA_LocalizedText}(x + 104)
    f === :axisScaleType && return Ptr{UA_AxisScaleEnumeration}(x + 136)
    f === :axisStepsSize && return Ptr{Csize_t}(x + 144)
    f === :axisSteps && return Ptr{Ptr{UA_Double}}(x + 152)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_AxisInformation}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_XVType
    x::UA_Double
    value::UA_Float
end
function Base.getproperty(x::Ptr{UA_XVType}, f::Symbol)
    f === :x && return Ptr{UA_Double}(x + 0)
    f === :value && return Ptr{UA_Float}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_XVType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ProgramDiagnosticDataType
    data::NTuple{200, UInt8}
end

function Base.fieldnames(::Type{UA_ProgramDiagnosticDataType})
    (:createSessionId, :createClientName, :invocationCreationTime, :lastTransitionTime,
        :lastMethodCall, :lastMethodSessionId, :lastMethodInputArgumentsSize,
        :lastMethodInputArguments, :lastMethodOutputArgumentsSize,
        :lastMethodOutputArguments, :lastMethodCallTime, :lastMethodReturnStatus)
end
function Base.fieldnames(::Type{Ptr{UA_ProgramDiagnosticDataType}})
    (:createSessionId, :createClientName, :invocationCreationTime, :lastTransitionTime,
        :lastMethodCall, :lastMethodSessionId, :lastMethodInputArgumentsSize,
        :lastMethodInputArguments, :lastMethodOutputArgumentsSize,
        :lastMethodOutputArguments, :lastMethodCallTime, :lastMethodReturnStatus)
end

function Base.getproperty(x::Ptr{UA_ProgramDiagnosticDataType}, f::Symbol)
    f === :createSessionId && return Ptr{UA_NodeId}(x + 0)
    f === :createClientName && return Ptr{UA_String}(x + 24)
    f === :invocationCreationTime && return Ptr{UA_DateTime}(x + 40)
    f === :lastTransitionTime && return Ptr{UA_DateTime}(x + 48)
    f === :lastMethodCall && return Ptr{UA_String}(x + 56)
    f === :lastMethodSessionId && return Ptr{UA_NodeId}(x + 72)
    f === :lastMethodInputArgumentsSize && return Ptr{Csize_t}(x + 96)
    f === :lastMethodInputArguments && return Ptr{Ptr{UA_Argument}}(x + 104)
    f === :lastMethodOutputArgumentsSize && return Ptr{Csize_t}(x + 112)
    f === :lastMethodOutputArguments && return Ptr{Ptr{UA_Argument}}(x + 120)
    f === :lastMethodCallTime && return Ptr{UA_DateTime}(x + 128)
    f === :lastMethodReturnStatus && return Ptr{UA_StatusResult}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ProgramDiagnosticDataType, f::Symbol)
    r = Ref{UA_ProgramDiagnosticDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ProgramDiagnosticDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ProgramDiagnosticDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ProgramDiagnostic2DataType
    data::NTuple{176, UInt8}
end

function Base.fieldnames(::Type{UA_ProgramDiagnostic2DataType})
    (:createSessionId, :createClientName, :invocationCreationTime,
        :lastTransitionTime, :lastMethodCall, :lastMethodSessionId,
        :lastMethodInputArgumentsSize, :lastMethodInputArguments,
        :lastMethodOutputArgumentsSize, :lastMethodOutputArguments,
        :lastMethodInputValuesSize, :lastMethodInputValues, :lastMethodOutputValuesSize,
        :lastMethodOutputValues, :lastMethodCallTime, :lastMethodReturnStatus)
end
function Base.fieldnames(::Type{Ptr{UA_ProgramDiagnostic2DataType}})
    (:createSessionId, :createClientName, :invocationCreationTime,
        :lastTransitionTime, :lastMethodCall, :lastMethodSessionId,
        :lastMethodInputArgumentsSize, :lastMethodInputArguments,
        :lastMethodOutputArgumentsSize, :lastMethodOutputArguments,
        :lastMethodInputValuesSize, :lastMethodInputValues, :lastMethodOutputValuesSize,
        :lastMethodOutputValues, :lastMethodCallTime, :lastMethodReturnStatus)
end

function Base.getproperty(x::Ptr{UA_ProgramDiagnostic2DataType}, f::Symbol)
    f === :createSessionId && return Ptr{UA_NodeId}(x + 0)
    f === :createClientName && return Ptr{UA_String}(x + 24)
    f === :invocationCreationTime && return Ptr{UA_DateTime}(x + 40)
    f === :lastTransitionTime && return Ptr{UA_DateTime}(x + 48)
    f === :lastMethodCall && return Ptr{UA_String}(x + 56)
    f === :lastMethodSessionId && return Ptr{UA_NodeId}(x + 72)
    f === :lastMethodInputArgumentsSize && return Ptr{Csize_t}(x + 96)
    f === :lastMethodInputArguments && return Ptr{Ptr{UA_Argument}}(x + 104)
    f === :lastMethodOutputArgumentsSize && return Ptr{Csize_t}(x + 112)
    f === :lastMethodOutputArguments && return Ptr{Ptr{UA_Argument}}(x + 120)
    f === :lastMethodInputValuesSize && return Ptr{Csize_t}(x + 128)
    f === :lastMethodInputValues && return Ptr{Ptr{UA_Variant}}(x + 136)
    f === :lastMethodOutputValuesSize && return Ptr{Csize_t}(x + 144)
    f === :lastMethodOutputValues && return Ptr{Ptr{UA_Variant}}(x + 152)
    f === :lastMethodCallTime && return Ptr{UA_DateTime}(x + 160)
    f === :lastMethodReturnStatus && return Ptr{UA_StatusCode}(x + 168)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ProgramDiagnostic2DataType, f::Symbol)
    r = Ref{UA_ProgramDiagnostic2DataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ProgramDiagnostic2DataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ProgramDiagnostic2DataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_Annotation
    message::UA_String
    userName::UA_String
    annotationTime::UA_DateTime
end

@cenum UA_ExceptionDeviationFormat::UInt32 begin
    UA_EXCEPTIONDEVIATIONFORMAT_ABSOLUTEVALUE = 0
    UA_EXCEPTIONDEVIATIONFORMAT_PERCENTOFVALUE = 1
    UA_EXCEPTIONDEVIATIONFORMAT_PERCENTOFRANGE = 2
    UA_EXCEPTIONDEVIATIONFORMAT_PERCENTOFEURANGE = 3
    UA_EXCEPTIONDEVIATIONFORMAT_UNKNOWN = 4
    __UA_EXCEPTIONDEVIATIONFORMAT_FORCE32BIT = 2147483647
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EndpointType
    endpointUrl::UA_String
    securityMode::UA_MessageSecurityMode
    securityPolicyUri::UA_String
    transportProfileUri::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedEventsDataType
    data::NTuple{56, UInt8}
end

function Base.fieldnames(::Type{UA_PublishedEventsDataType})
    (:eventNotifier, :selectedFieldsSize, :selectedFields, :filter)
end
function Base.fieldnames(::Type{Ptr{UA_PublishedEventsDataType}})
    (:eventNotifier, :selectedFieldsSize, :selectedFields, :filter)
end

function Base.getproperty(x::Ptr{UA_PublishedEventsDataType}, f::Symbol)
    f === :eventNotifier && return Ptr{UA_NodeId}(x + 0)
    f === :selectedFieldsSize && return Ptr{Csize_t}(x + 24)
    f === :selectedFields && return Ptr{Ptr{UA_SimpleAttributeOperand}}(x + 32)
    f === :filter && return Ptr{UA_ContentFilter}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishedEventsDataType, f::Symbol)
    r = Ref{UA_PublishedEventsDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishedEventsDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishedEventsDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubGroupDataType
    name::UA_String
    enabled::UA_Boolean
    securityMode::UA_MessageSecurityMode
    securityGroupId::UA_String
    securityKeyServicesSize::Csize_t
    securityKeyServices::Ptr{UA_EndpointDescription}
    maxNetworkMessageSize::UA_UInt32
    groupPropertiesSize::Csize_t
    groupProperties::Ptr{UA_KeyValuePair}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_WriterGroupDataType
    data::NTuple{256, UInt8}
end

function Base.fieldnames(::Type{UA_WriterGroupDataType})
    (:name, :enabled, :securityMode, :securityGroupId, :securityKeyServicesSize,
        :securityKeyServices, :maxNetworkMessageSize, :groupPropertiesSize,
        :groupProperties, :writerGroupId, :publishingInterval, :keepAliveTime,
        :priority, :localeIdsSize, :localeIds, :headerLayoutUri,
        :transportSettings, :messageSettings, :dataSetWritersSize, :dataSetWriters)
end
function Base.fieldnames(::Type{Ptr{UA_WriterGroupDataType}})
    (:name, :enabled, :securityMode, :securityGroupId, :securityKeyServicesSize,
        :securityKeyServices, :maxNetworkMessageSize, :groupPropertiesSize,
        :groupProperties, :writerGroupId, :publishingInterval, :keepAliveTime,
        :priority, :localeIdsSize, :localeIds, :headerLayoutUri,
        :transportSettings, :messageSettings, :dataSetWritersSize, :dataSetWriters)
end

function Base.getproperty(x::Ptr{UA_WriterGroupDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 20)
    f === :securityGroupId && return Ptr{UA_String}(x + 24)
    f === :securityKeyServicesSize && return Ptr{Csize_t}(x + 40)
    f === :securityKeyServices && return Ptr{Ptr{UA_EndpointDescription}}(x + 48)
    f === :maxNetworkMessageSize && return Ptr{UA_UInt32}(x + 56)
    f === :groupPropertiesSize && return Ptr{Csize_t}(x + 64)
    f === :groupProperties && return Ptr{Ptr{UA_KeyValuePair}}(x + 72)
    f === :writerGroupId && return Ptr{UA_UInt16}(x + 80)
    f === :publishingInterval && return Ptr{UA_Double}(x + 88)
    f === :keepAliveTime && return Ptr{UA_Double}(x + 96)
    f === :priority && return Ptr{UA_Byte}(x + 104)
    f === :localeIdsSize && return Ptr{Csize_t}(x + 112)
    f === :localeIds && return Ptr{Ptr{UA_String}}(x + 120)
    f === :headerLayoutUri && return Ptr{UA_String}(x + 128)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 144)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 192)
    f === :dataSetWritersSize && return Ptr{Csize_t}(x + 240)
    f === :dataSetWriters && return Ptr{Ptr{UA_DataSetWriterDataType}}(x + 248)
    return getfield(x, f)
end

function Base.getproperty(x::UA_WriterGroupDataType, f::Symbol)
    r = Ref{UA_WriterGroupDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_WriterGroupDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_WriterGroupDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SubscribedDataSetMirrorDataType
    parentNodeName::UA_String
    rolePermissionsSize::Csize_t
    rolePermissions::Ptr{UA_RolePermissionType}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SecurityGroupDataType
    name::UA_String
    securityGroupFolderSize::Csize_t
    securityGroupFolder::Ptr{UA_String}
    keyLifetime::UA_Double
    securityPolicyUri::UA_String
    maxFutureKeyCount::UA_UInt32
    maxPastKeyCount::UA_UInt32
    securityGroupId::UA_String
    rolePermissionsSize::Csize_t
    rolePermissions::Ptr{UA_RolePermissionType}
    groupPropertiesSize::Csize_t
    groupProperties::Ptr{UA_KeyValuePair}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubKeyPushTargetDataType
    applicationUri::UA_String
    pushTargetFolderSize::Csize_t
    pushTargetFolder::Ptr{UA_String}
    endpointUrl::UA_String
    securityPolicyUri::UA_String
    userTokenType::UA_UserTokenPolicy
    requestedKeyCount::UA_UInt16
    retryInterval::UA_Double
    pushTargetPropertiesSize::Csize_t
    pushTargetProperties::Ptr{UA_KeyValuePair}
    securityGroupsSize::Csize_t
    securityGroups::Ptr{UA_String}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadEventDetails
    numValuesPerNode::UA_UInt32
    startTime::UA_DateTime
    endTime::UA_DateTime
    filter::UA_EventFilter
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReadProcessedDetails
    startTime::UA_DateTime
    endTime::UA_DateTime
    processingInterval::UA_Double
    aggregateTypeSize::Csize_t
    aggregateType::Ptr{UA_NodeId}
    aggregateConfiguration::UA_AggregateConfiguration
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ModificationInfo
    modificationTime::UA_DateTime
    updateType::UA_HistoryUpdateType
    userName::UA_String
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryModifiedData
    dataValuesSize::Csize_t
    dataValues::Ptr{UA_DataValue}
    modificationInfosSize::Csize_t
    modificationInfos::Ptr{UA_ModificationInfo}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryEvent
    eventsSize::Csize_t
    events::Ptr{UA_HistoryEventFieldList}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UpdateEventDetails
    data::NTuple{80, UInt8}
end

function Base.fieldnames(::Type{UA_UpdateEventDetails})
    (:nodeId, :performInsertReplace, :filter, :eventDataSize, :eventData)
end
function Base.fieldnames(::Type{Ptr{UA_UpdateEventDetails}})
    (:nodeId, :performInsertReplace, :filter, :eventDataSize, :eventData)
end

function Base.getproperty(x::Ptr{UA_UpdateEventDetails}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :performInsertReplace && return Ptr{UA_PerformUpdateType}(x + 24)
    f === :filter && return Ptr{UA_EventFilter}(x + 32)
    f === :eventDataSize && return Ptr{Csize_t}(x + 64)
    f === :eventData && return Ptr{Ptr{UA_HistoryEventFieldList}}(x + 72)
    return getfield(x, f)
end

function Base.getproperty(x::UA_UpdateEventDetails, f::Symbol)
    r = Ref{UA_UpdateEventDetails}(x)
    ptr = Base.unsafe_convert(Ptr{UA_UpdateEventDetails}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_UpdateEventDetails}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataChangeNotification
    monitoredItemsSize::Csize_t
    monitoredItems::Ptr{UA_MonitoredItemNotification}
    diagnosticInfosSize::Csize_t
    diagnosticInfos::Ptr{UA_DiagnosticInfo}
end
function Base.getproperty(x::Ptr{UA_DataChangeNotification}, f::Symbol)
    f === :monitoredItemsSize && return Ptr{Csize_t}(x + 0)
    f === :monitoredItems && return Ptr{Ptr{UA_MonitoredItemNotification}}(x + 8)
    f === :diagnosticInfosSize && return Ptr{Csize_t}(x + 16)
    f === :diagnosticInfos && return Ptr{Ptr{UA_DiagnosticInfo}}(x + 24)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_DataChangeNotification}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_EventNotificationList
    eventsSize::Csize_t
    events::Ptr{UA_EventFieldList}
end
function Base.getproperty(x::Ptr{UA_EventNotificationList}, f::Symbol)
    f === :eventsSize && return Ptr{Csize_t}(x + 0)
    f === :events && return Ptr{Ptr{UA_EventFieldList}}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{UA_EventNotificationList}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_SessionDiagnosticsDataType
    data::NTuple{488, UInt8}
end

function Base.fieldnames(::Type{UA_SessionDiagnosticsDataType})
    (:sessionId, :sessionName, :clientDescription, :serverUri, :endpointUrl,
        :localeIdsSize, :localeIds, :actualSessionTimeout, :maxResponseMessageSize,
        :clientConnectionTime, :clientLastContactTime, :currentSubscriptionsCount,
        :currentMonitoredItemsCount, :currentPublishRequestsInQueue,
        :totalRequestCount, :unauthorizedRequestCount, :readCount,
        :historyReadCount, :writeCount, :historyUpdateCount, :callCount,
        :createMonitoredItemsCount, :modifyMonitoredItemsCount, :setMonitoringModeCount,
        :setTriggeringCount, :deleteMonitoredItemsCount, :createSubscriptionCount,
        :modifySubscriptionCount, :setPublishingModeCount, :publishCount,
        :republishCount, :transferSubscriptionsCount, :deleteSubscriptionsCount,
        :addNodesCount, :addReferencesCount, :deleteNodesCount, :deleteReferencesCount,
        :browseCount, :browseNextCount, :translateBrowsePathsToNodeIdsCount,
        :queryFirstCount, :queryNextCount, :registerNodesCount, :unregisterNodesCount)
end
function Base.fieldnames(::Type{Ptr{UA_SessionDiagnosticsDataType}})
    (:sessionId, :sessionName, :clientDescription, :serverUri, :endpointUrl,
        :localeIdsSize, :localeIds, :actualSessionTimeout, :maxResponseMessageSize,
        :clientConnectionTime, :clientLastContactTime, :currentSubscriptionsCount,
        :currentMonitoredItemsCount, :currentPublishRequestsInQueue,
        :totalRequestCount, :unauthorizedRequestCount, :readCount,
        :historyReadCount, :writeCount, :historyUpdateCount, :callCount,
        :createMonitoredItemsCount, :modifyMonitoredItemsCount, :setMonitoringModeCount,
        :setTriggeringCount, :deleteMonitoredItemsCount, :createSubscriptionCount,
        :modifySubscriptionCount, :setPublishingModeCount, :publishCount,
        :republishCount, :transferSubscriptionsCount, :deleteSubscriptionsCount,
        :addNodesCount, :addReferencesCount, :deleteNodesCount, :deleteReferencesCount,
        :browseCount, :browseNextCount, :translateBrowsePathsToNodeIdsCount,
        :queryFirstCount, :queryNextCount, :registerNodesCount, :unregisterNodesCount)
end

function Base.getproperty(x::Ptr{UA_SessionDiagnosticsDataType}, f::Symbol)
    f === :sessionId && return Ptr{UA_NodeId}(x + 0)
    f === :sessionName && return Ptr{UA_String}(x + 24)
    f === :clientDescription && return Ptr{UA_ApplicationDescription}(x + 40)
    f === :serverUri && return Ptr{UA_String}(x + 160)
    f === :endpointUrl && return Ptr{UA_String}(x + 176)
    f === :localeIdsSize && return Ptr{Csize_t}(x + 192)
    f === :localeIds && return Ptr{Ptr{UA_String}}(x + 200)
    f === :actualSessionTimeout && return Ptr{UA_Double}(x + 208)
    f === :maxResponseMessageSize && return Ptr{UA_UInt32}(x + 216)
    f === :clientConnectionTime && return Ptr{UA_DateTime}(x + 224)
    f === :clientLastContactTime && return Ptr{UA_DateTime}(x + 232)
    f === :currentSubscriptionsCount && return Ptr{UA_UInt32}(x + 240)
    f === :currentMonitoredItemsCount && return Ptr{UA_UInt32}(x + 244)
    f === :currentPublishRequestsInQueue && return Ptr{UA_UInt32}(x + 248)
    f === :totalRequestCount && return Ptr{UA_ServiceCounterDataType}(x + 252)
    f === :unauthorizedRequestCount && return Ptr{UA_UInt32}(x + 260)
    f === :readCount && return Ptr{UA_ServiceCounterDataType}(x + 264)
    f === :historyReadCount && return Ptr{UA_ServiceCounterDataType}(x + 272)
    f === :writeCount && return Ptr{UA_ServiceCounterDataType}(x + 280)
    f === :historyUpdateCount && return Ptr{UA_ServiceCounterDataType}(x + 288)
    f === :callCount && return Ptr{UA_ServiceCounterDataType}(x + 296)
    f === :createMonitoredItemsCount && return Ptr{UA_ServiceCounterDataType}(x + 304)
    f === :modifyMonitoredItemsCount && return Ptr{UA_ServiceCounterDataType}(x + 312)
    f === :setMonitoringModeCount && return Ptr{UA_ServiceCounterDataType}(x + 320)
    f === :setTriggeringCount && return Ptr{UA_ServiceCounterDataType}(x + 328)
    f === :deleteMonitoredItemsCount && return Ptr{UA_ServiceCounterDataType}(x + 336)
    f === :createSubscriptionCount && return Ptr{UA_ServiceCounterDataType}(x + 344)
    f === :modifySubscriptionCount && return Ptr{UA_ServiceCounterDataType}(x + 352)
    f === :setPublishingModeCount && return Ptr{UA_ServiceCounterDataType}(x + 360)
    f === :publishCount && return Ptr{UA_ServiceCounterDataType}(x + 368)
    f === :republishCount && return Ptr{UA_ServiceCounterDataType}(x + 376)
    f === :transferSubscriptionsCount && return Ptr{UA_ServiceCounterDataType}(x + 384)
    f === :deleteSubscriptionsCount && return Ptr{UA_ServiceCounterDataType}(x + 392)
    f === :addNodesCount && return Ptr{UA_ServiceCounterDataType}(x + 400)
    f === :addReferencesCount && return Ptr{UA_ServiceCounterDataType}(x + 408)
    f === :deleteNodesCount && return Ptr{UA_ServiceCounterDataType}(x + 416)
    f === :deleteReferencesCount && return Ptr{UA_ServiceCounterDataType}(x + 424)
    f === :browseCount && return Ptr{UA_ServiceCounterDataType}(x + 432)
    f === :browseNextCount && return Ptr{UA_ServiceCounterDataType}(x + 440)
    f === :translateBrowsePathsToNodeIdsCount &&
        return Ptr{UA_ServiceCounterDataType}(x + 448)
    f === :queryFirstCount && return Ptr{UA_ServiceCounterDataType}(x + 456)
    f === :queryNextCount && return Ptr{UA_ServiceCounterDataType}(x + 464)
    f === :registerNodesCount && return Ptr{UA_ServiceCounterDataType}(x + 472)
    f === :unregisterNodesCount && return Ptr{UA_ServiceCounterDataType}(x + 480)
    return getfield(x, f)
end

function Base.getproperty(x::UA_SessionDiagnosticsDataType, f::Symbol)
    r = Ref{UA_SessionDiagnosticsDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_SessionDiagnosticsDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_SessionDiagnosticsDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UABinaryFileDataType
    namespacesSize::Csize_t
    namespaces::Ptr{UA_String}
    structureDataTypesSize::Csize_t
    structureDataTypes::Ptr{UA_StructureDescription}
    enumDataTypesSize::Csize_t
    enumDataTypes::Ptr{UA_EnumDescription}
    simpleDataTypesSize::Csize_t
    simpleDataTypes::Ptr{UA_SimpleTypeDescription}
    schemaLocation::UA_String
    fileHeaderSize::Csize_t
    fileHeader::Ptr{UA_KeyValuePair}
    body::UA_Variant
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PublishedDataSetDataType
    data::NTuple{248, UInt8}
end

function Base.fieldnames(::Type{UA_PublishedDataSetDataType})
    (:name, :dataSetFolderSize, :dataSetFolder, :dataSetMetaData,
        :extensionFieldsSize, :extensionFields, :dataSetSource)
end
function Base.fieldnames(::Type{Ptr{UA_PublishedDataSetDataType}})
    (:name, :dataSetFolderSize, :dataSetFolder, :dataSetMetaData,
        :extensionFieldsSize, :extensionFields, :dataSetSource)
end

function Base.getproperty(x::Ptr{UA_PublishedDataSetDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :dataSetFolderSize && return Ptr{Csize_t}(x + 16)
    f === :dataSetFolder && return Ptr{Ptr{UA_String}}(x + 24)
    f === :dataSetMetaData && return Ptr{UA_DataSetMetaDataType}(x + 32)
    f === :extensionFieldsSize && return Ptr{Csize_t}(x + 184)
    f === :extensionFields && return Ptr{Ptr{UA_KeyValuePair}}(x + 192)
    f === :dataSetSource && return Ptr{UA_ExtensionObject}(x + 200)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PublishedDataSetDataType, f::Symbol)
    r = Ref{UA_PublishedDataSetDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PublishedDataSetDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PublishedDataSetDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DataSetReaderDataType
    data::NTuple{472, UInt8}
end

function Base.fieldnames(::Type{UA_DataSetReaderDataType})
    (:name, :enabled, :publisherId, :writerGroupId, :dataSetWriterId,
        :dataSetMetaData, :dataSetFieldContentMask, :messageReceiveTimeout,
        :keyFrameCount, :headerLayoutUri, :securityMode, :securityGroupId,
        :securityKeyServicesSize, :securityKeyServices, :dataSetReaderPropertiesSize,
        :dataSetReaderProperties, :transportSettings, :messageSettings, :subscribedDataSet)
end
function Base.fieldnames(::Type{Ptr{UA_DataSetReaderDataType}})
    (:name, :enabled, :publisherId, :writerGroupId, :dataSetWriterId,
        :dataSetMetaData, :dataSetFieldContentMask, :messageReceiveTimeout,
        :keyFrameCount, :headerLayoutUri, :securityMode, :securityGroupId,
        :securityKeyServicesSize, :securityKeyServices, :dataSetReaderPropertiesSize,
        :dataSetReaderProperties, :transportSettings, :messageSettings, :subscribedDataSet)
end

function Base.getproperty(x::Ptr{UA_DataSetReaderDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :publisherId && return Ptr{UA_Variant}(x + 24)
    f === :writerGroupId && return Ptr{UA_UInt16}(x + 72)
    f === :dataSetWriterId && return Ptr{UA_UInt16}(x + 74)
    f === :dataSetMetaData && return Ptr{UA_DataSetMetaDataType}(x + 80)
    f === :dataSetFieldContentMask && return Ptr{UA_DataSetFieldContentMask}(x + 232)
    f === :messageReceiveTimeout && return Ptr{UA_Double}(x + 240)
    f === :keyFrameCount && return Ptr{UA_UInt32}(x + 248)
    f === :headerLayoutUri && return Ptr{UA_String}(x + 256)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 272)
    f === :securityGroupId && return Ptr{UA_String}(x + 280)
    f === :securityKeyServicesSize && return Ptr{Csize_t}(x + 296)
    f === :securityKeyServices && return Ptr{Ptr{UA_EndpointDescription}}(x + 304)
    f === :dataSetReaderPropertiesSize && return Ptr{Csize_t}(x + 312)
    f === :dataSetReaderProperties && return Ptr{Ptr{UA_KeyValuePair}}(x + 320)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 328)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 376)
    f === :subscribedDataSet && return Ptr{UA_ExtensionObject}(x + 424)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataSetReaderDataType, f::Symbol)
    r = Ref{UA_DataSetReaderDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataSetReaderDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataSetReaderDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_TargetVariablesDataType
    targetVariablesSize::Csize_t
    targetVariables::Ptr{UA_FieldTargetDataType}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_StandaloneSubscribedDataSetDataType
    data::NTuple{232, UInt8}
end

function Base.fieldnames(::Type{UA_StandaloneSubscribedDataSetDataType})
    (:name, :dataSetFolderSize, :dataSetFolder, :dataSetMetaData, :subscribedDataSet)
end
function Base.fieldnames(::Type{Ptr{UA_StandaloneSubscribedDataSetDataType}})
    (:name, :dataSetFolderSize, :dataSetFolder, :dataSetMetaData, :subscribedDataSet)
end

function Base.getproperty(x::Ptr{UA_StandaloneSubscribedDataSetDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :dataSetFolderSize && return Ptr{Csize_t}(x + 16)
    f === :dataSetFolder && return Ptr{Ptr{UA_String}}(x + 24)
    f === :dataSetMetaData && return Ptr{UA_DataSetMetaDataType}(x + 32)
    f === :subscribedDataSet && return Ptr{UA_ExtensionObject}(x + 184)
    return getfield(x, f)
end

function Base.getproperty(x::UA_StandaloneSubscribedDataSetDataType, f::Symbol)
    r = Ref{UA_StandaloneSubscribedDataSetDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_StandaloneSubscribedDataSetDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_StandaloneSubscribedDataSetDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_DataTypeSchemaHeader
    namespacesSize::Csize_t
    namespaces::Ptr{UA_String}
    structureDataTypesSize::Csize_t
    structureDataTypes::Ptr{UA_StructureDescription}
    enumDataTypesSize::Csize_t
    enumDataTypes::Ptr{UA_EnumDescription}
    simpleDataTypesSize::Csize_t
    simpleDataTypes::Ptr{UA_SimpleTypeDescription}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReaderGroupDataType
    data::NTuple{192, UInt8}
end

function Base.fieldnames(::Type{UA_ReaderGroupDataType})
    (:name, :enabled, :securityMode, :securityGroupId,
        :securityKeyServicesSize, :securityKeyServices, :maxNetworkMessageSize,
        :groupPropertiesSize, :groupProperties, :transportSettings,
        :messageSettings, :dataSetReadersSize, :dataSetReaders)
end
function Base.fieldnames(::Type{Ptr{UA_ReaderGroupDataType}})
    (:name, :enabled, :securityMode, :securityGroupId,
        :securityKeyServicesSize, :securityKeyServices, :maxNetworkMessageSize,
        :groupPropertiesSize, :groupProperties, :transportSettings,
        :messageSettings, :dataSetReadersSize, :dataSetReaders)
end

function Base.getproperty(x::Ptr{UA_ReaderGroupDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :securityMode && return Ptr{UA_MessageSecurityMode}(x + 20)
    f === :securityGroupId && return Ptr{UA_String}(x + 24)
    f === :securityKeyServicesSize && return Ptr{Csize_t}(x + 40)
    f === :securityKeyServices && return Ptr{Ptr{UA_EndpointDescription}}(x + 48)
    f === :maxNetworkMessageSize && return Ptr{UA_UInt32}(x + 56)
    f === :groupPropertiesSize && return Ptr{Csize_t}(x + 64)
    f === :groupProperties && return Ptr{Ptr{UA_KeyValuePair}}(x + 72)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 80)
    f === :messageSettings && return Ptr{UA_ExtensionObject}(x + 128)
    f === :dataSetReadersSize && return Ptr{Csize_t}(x + 176)
    f === :dataSetReaders && return Ptr{Ptr{UA_DataSetReaderDataType}}(x + 184)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReaderGroupDataType, f::Symbol)
    r = Ref{UA_ReaderGroupDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReaderGroupDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReaderGroupDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConnectionDataType
    data::NTuple{232, UInt8}
end

function Base.fieldnames(::Type{UA_PubSubConnectionDataType})
    (:name, :enabled, :publisherId, :transportProfileUri, :address,
        :connectionPropertiesSize, :connectionProperties, :transportSettings,
        :writerGroupsSize, :writerGroups, :readerGroupsSize, :readerGroups)
end
function Base.fieldnames(::Type{Ptr{UA_PubSubConnectionDataType}})
    (:name, :enabled, :publisherId, :transportProfileUri, :address,
        :connectionPropertiesSize, :connectionProperties, :transportSettings,
        :writerGroupsSize, :writerGroups, :readerGroupsSize, :readerGroups)
end

function Base.getproperty(x::Ptr{UA_PubSubConnectionDataType}, f::Symbol)
    f === :name && return Ptr{UA_String}(x + 0)
    f === :enabled && return Ptr{UA_Boolean}(x + 16)
    f === :publisherId && return Ptr{UA_Variant}(x + 24)
    f === :transportProfileUri && return Ptr{UA_String}(x + 72)
    f === :address && return Ptr{UA_ExtensionObject}(x + 88)
    f === :connectionPropertiesSize && return Ptr{Csize_t}(x + 136)
    f === :connectionProperties && return Ptr{Ptr{UA_KeyValuePair}}(x + 144)
    f === :transportSettings && return Ptr{UA_ExtensionObject}(x + 152)
    f === :writerGroupsSize && return Ptr{Csize_t}(x + 200)
    f === :writerGroups && return Ptr{Ptr{UA_WriterGroupDataType}}(x + 208)
    f === :readerGroupsSize && return Ptr{Csize_t}(x + 216)
    f === :readerGroups && return Ptr{Ptr{UA_ReaderGroupDataType}}(x + 224)
    return getfield(x, f)
end

function Base.getproperty(x::UA_PubSubConnectionDataType, f::Symbol)
    r = Ref{UA_PubSubConnectionDataType}(x)
    ptr = Base.unsafe_convert(Ptr{UA_PubSubConnectionDataType}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_PubSubConnectionDataType}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConfigurationDataType
    publishedDataSetsSize::Csize_t
    publishedDataSets::Ptr{UA_PublishedDataSetDataType}
    connectionsSize::Csize_t
    connections::Ptr{UA_PubSubConnectionDataType}
    enabled::UA_Boolean
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_PubSubConfiguration2DataType
    publishedDataSetsSize::Csize_t
    publishedDataSets::Ptr{UA_PublishedDataSetDataType}
    connectionsSize::Csize_t
    connections::Ptr{UA_PubSubConnectionDataType}
    enabled::UA_Boolean
    subscribedDataSetsSize::Csize_t
    subscribedDataSets::Ptr{UA_StandaloneSubscribedDataSetDataType}
    dataSetClassesSize::Csize_t
    dataSetClasses::Ptr{UA_DataSetMetaDataType}
    defaultSecurityKeyServicesSize::Csize_t
    defaultSecurityKeyServices::Ptr{UA_EndpointDescription}
    securityGroupsSize::Csize_t
    securityGroups::Ptr{UA_SecurityGroupDataType}
    pubSubKeyPushTargetsSize::Csize_t
    pubSubKeyPushTargets::Ptr{UA_PubSubKeyPushTargetDataType}
    configurationVersion::UA_UInt32
    configurationPropertiesSize::Csize_t
    configurationProperties::Ptr{UA_KeyValuePair}
end

function UA_random_seed(seed)
    @ccall libopen62541.UA_random_seed(seed::UA_UInt64)::Cvoid
end

function UA_UInt32_random()
    @ccall libopen62541.UA_UInt32_random()::UA_UInt32
end

function UA_Guid_random()
    guid_dst = UA_Guid_new()
    guid_src = @ccall libopen62541.UA_Guid_random()::UA_Guid
    UA_Guid_copy(guid_src, guid_dst)
    return guid_dst
end

function UA_KeyValueMap_new()
    @ccall libopen62541.UA_KeyValueMap_new()::Ptr{UA_KeyValueMap}
end

function UA_KeyValueMap_clear(map)
    @ccall libopen62541.UA_KeyValueMap_clear(map::Ptr{UA_KeyValueMap})::Cvoid
end

function UA_KeyValueMap_delete(map)
    @ccall libopen62541.UA_KeyValueMap_delete(map::Ptr{UA_KeyValueMap})::Cvoid
end

function UA_KeyValueMap_isEmpty(map)
    @ccall libopen62541.UA_KeyValueMap_isEmpty(map::Ptr{UA_KeyValueMap})::UA_Boolean
end

function UA_KeyValueMap_contains(map, key)
    @ccall libopen62541.UA_KeyValueMap_contains(
        map::Ptr{UA_KeyValueMap}, key::UA_QualifiedName)::UA_Boolean
end

function UA_KeyValueMap_set(map, key, value)
    @ccall libopen62541.UA_KeyValueMap_set(map::Ptr{UA_KeyValueMap}, key::UA_QualifiedName,
        value::Ptr{UA_Variant})::UA_StatusCode
end

function UA_KeyValueMap_setScalar(map, key, p, type)
    @ccall libopen62541.UA_KeyValueMap_setScalar(
        map::Ptr{UA_KeyValueMap}, key::UA_QualifiedName,
        p::Ptr{Cvoid}, type::Ptr{UA_DataType})::UA_StatusCode
end

function UA_KeyValueMap_get(map, key)
    @ccall libopen62541.UA_KeyValueMap_get(
        map::Ptr{UA_KeyValueMap}, key::UA_QualifiedName)::Ptr{UA_Variant}
end

function UA_KeyValueMap_getScalar(map, key, type)
    @ccall libopen62541.UA_KeyValueMap_getScalar(
        map::Ptr{UA_KeyValueMap}, key::UA_QualifiedName, type::Ptr{UA_DataType})::Ptr{Cvoid}
end

function UA_KeyValueMap_remove(map, key)
    @ccall libopen62541.UA_KeyValueMap_remove(
        map::Ptr{UA_KeyValueMap}, key::UA_QualifiedName)::UA_StatusCode
end

function UA_KeyValueMap_copy(src, dst)
    @ccall libopen62541.UA_KeyValueMap_copy(
        src::Ptr{UA_KeyValueMap}, dst::Ptr{UA_KeyValueMap})::UA_StatusCode
end

function UA_KeyValueMap_merge(lhs, rhs)
    @ccall libopen62541.UA_KeyValueMap_merge(
        lhs::Ptr{UA_KeyValueMap}, rhs::Ptr{UA_KeyValueMap})::UA_StatusCode
end

function UA_parseEndpointUrl(endpointUrl, outHostname, outPort, outPath)
    @ccall libopen62541.UA_parseEndpointUrl(
        endpointUrl::Ptr{UA_String}, outHostname::Ptr{UA_String},
        outPort::Ptr{UA_UInt16}, outPath::Ptr{UA_String})::UA_StatusCode
end

function UA_parseEndpointUrlEthernet(endpointUrl, target, vid, pcp)
    @ccall libopen62541.UA_parseEndpointUrlEthernet(
        endpointUrl::Ptr{UA_String}, target::Ptr{UA_String},
        vid::Ptr{UA_UInt16}, pcp::Ptr{UA_Byte})::UA_StatusCode
end

function UA_readNumber(buf, buflen, number)
    @ccall libopen62541.UA_readNumber(
        buf::Ptr{UA_Byte}, buflen::Csize_t, number::Ptr{UA_UInt32})::Csize_t
end

function UA_readNumberWithBase(buf, buflen, number, base)
    @ccall libopen62541.UA_readNumberWithBase(
        buf::Ptr{UA_Byte}, buflen::Csize_t, number::Ptr{UA_UInt32}, base::UA_Byte)::Csize_t
end

function UA_RelativePath_parse(rp, str)
    @ccall libopen62541.UA_RelativePath_parse(
        rp::Ptr{UA_RelativePath}, str::UA_String)::UA_StatusCode
end

function UA_constantTimeEqual(ptr1, ptr2, length)
    @ccall libopen62541.UA_constantTimeEqual(
        ptr1::Ptr{Cvoid}, ptr2::Ptr{Cvoid}, length::Csize_t)::UA_Boolean
end

function UA_ByteString_memZero(bs)
    @ccall libopen62541.UA_ByteString_memZero(bs::Ptr{UA_ByteString})::Cvoid
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_UsernamePasswordLogin
    username::UA_String
    password::UA_String
end

# typedef UA_StatusCode ( * UA_UsernamePasswordLoginCallback ) ( const UA_String * userName , const UA_ByteString * password , size_t usernamePasswordLoginSize , const UA_UsernamePasswordLogin * usernamePasswordLogin , void * * sessionContext , void * loginContext )
const UA_UsernamePasswordLoginCallback = Ptr{Cvoid}

function UA_AccessControl_default(config, allowAnonymous, userTokenPolicyUri,
        usernamePasswordLoginSize, usernamePasswordLogin)
    @ccall libopen62541.UA_AccessControl_default(
        config::Ptr{UA_ServerConfig}, allowAnonymous::UA_Boolean,
        userTokenPolicyUri::Ptr{UA_ByteString}, usernamePasswordLoginSize::Csize_t,
        usernamePasswordLogin::Ptr{UA_UsernamePasswordLogin})::UA_StatusCode
end

function UA_AccessControl_defaultWithLoginCallback(
        config, allowAnonymous, userTokenPolicyUri, usernamePasswordLoginSize,
        usernamePasswordLogin, loginCallback, loginContext)
    @ccall libopen62541.UA_AccessControl_defaultWithLoginCallback(
        config::Ptr{UA_ServerConfig}, allowAnonymous::UA_Boolean,
        userTokenPolicyUri::Ptr{UA_ByteString}, usernamePasswordLoginSize::Csize_t,
        usernamePasswordLogin::Ptr{UA_UsernamePasswordLogin},
        loginCallback::UA_UsernamePasswordLoginCallback,
        loginContext::Ptr{Cvoid})::UA_StatusCode
end

@cenum UA_CertificateFormat::UInt32 begin
    UA_CERTIFICATEFORMAT_DER = 0
    UA_CERTIFICATEFORMAT_PEM = 1
end

function UA_CreateCertificate(
        logger, subject, subjectSize, subjectAltName, subjectAltNameSize,
        certFormat, params, outPrivateKey, outCertificate)
    @ccall libopen62541.UA_CreateCertificate(
        logger::Ptr{UA_Logger}, subject::Ptr{UA_String},
        subjectSize::Csize_t, subjectAltName::Ptr{UA_String},
        subjectAltNameSize::Csize_t, certFormat::UA_CertificateFormat,
        params::Ptr{UA_KeyValueMap}, outPrivateKey::Ptr{UA_ByteString},
        outCertificate::Ptr{UA_ByteString})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ConnectionManager
    eventSource::UA_EventSource
    protocol::UA_String
    openConnection::Ptr{Cvoid}
    sendWithConnection::Ptr{Cvoid}
    closeConnection::Ptr{Cvoid}
    allocNetworkBuffer::Ptr{Cvoid}
    freeNetworkBuffer::Ptr{Cvoid}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_InterruptManager
    eventSource::UA_EventSource
    registerInterrupt::Ptr{Cvoid}
    deregisterInterrupt::Ptr{Cvoid}
end

@cenum UA_TimerPolicy::UInt32 begin
    UA_TIMER_HANDLE_CYCLEMISS_WITH_CURRENTTIME = 0
    UA_TIMER_HANDLE_CYCLEMISS_WITH_BASETIME = 1
end

# typedef void ( * UA_Callback ) ( void * application , void * context )
const UA_Callback = Ptr{Cvoid}

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_DelayedCallback
    next::Ptr{UA_DelayedCallback}
    callback::UA_Callback
    application::Ptr{Cvoid}
    context::Ptr{Cvoid}
end

# typedef void ( * UA_ConnectionManager_connectionCallback ) ( UA_ConnectionManager * cm , uintptr_t connectionId , void * application , void * * connectionContext , UA_ConnectionState state , const UA_KeyValueMap * params , UA_ByteString msg )
const UA_ConnectionManager_connectionCallback = Ptr{Cvoid}

# typedef void ( * UA_InterruptCallback ) ( UA_InterruptManager * im , uintptr_t interruptHandle , void * interruptContext , const UA_KeyValueMap * instanceInfos )
const UA_InterruptCallback = Ptr{Cvoid}

function UA_EventLoop_new_POSIX(logger)
    @ccall libopen62541.UA_EventLoop_new_POSIX(logger::Ptr{UA_Logger})::Ptr{UA_EventLoop}
end

function UA_ConnectionManager_new_POSIX_TCP(eventSourceName)
    @ccall libopen62541.UA_ConnectionManager_new_POSIX_TCP(eventSourceName::UA_String)::Ptr{UA_ConnectionManager}
end

function UA_ConnectionManager_new_POSIX_UDP(eventSourceName)
    @ccall libopen62541.UA_ConnectionManager_new_POSIX_UDP(eventSourceName::UA_String)::Ptr{UA_ConnectionManager}
end

function UA_ConnectionManager_new_MQTT(eventSourceName)
    @ccall libopen62541.UA_ConnectionManager_new_MQTT(eventSourceName::UA_String)::Ptr{UA_ConnectionManager}
end

function UA_InterruptManager_new_POSIX(eventSourceName)
    @ccall libopen62541.UA_InterruptManager_new_POSIX(eventSourceName::UA_String)::Ptr{UA_InterruptManager}
end

@cenum UA_LogLevel::UInt32 begin
    UA_LOGLEVEL_TRACE = 100
    UA_LOGLEVEL_DEBUG = 200
    UA_LOGLEVEL_INFO = 300
    UA_LOGLEVEL_WARNING = 400
    UA_LOGLEVEL_ERROR = 500
    UA_LOGLEVEL_FATAL = 600
end

@cenum UA_LogCategory::UInt32 begin
    UA_LOGCATEGORY_NETWORK = 0
    UA_LOGCATEGORY_SECURECHANNEL = 1
    UA_LOGCATEGORY_SESSION = 2
    UA_LOGCATEGORY_SERVER = 3
    UA_LOGCATEGORY_CLIENT = 4
    UA_LOGCATEGORY_USERLAND = 5
    UA_LOGCATEGORY_SECURITYPOLICY = 6
    UA_LOGCATEGORY_EVENTLOOP = 7
    UA_LOGCATEGORY_PUBSUB = 8
    UA_LOGCATEGORY_DISCOVERY = 9
end

function UA_Log_Stdout_withLevel(minlevel)
    @ccall libopen62541.UA_Log_Stdout_withLevel(minlevel::UA_LogLevel)::UA_Logger
end

function UA_Log_Stdout_new(minlevel)
    @ccall libopen62541.UA_Log_Stdout_new(minlevel::UA_LogLevel)::Ptr{UA_Logger}
end

@cenum UA_ValueSource::UInt32 begin
    UA_VALUESOURCE_DATA = 0
    UA_VALUESOURCE_DATASOURCE = 1
end

mutable struct UA_MonitoredItem end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReferenceTypeSet
    bits::NTuple{4, UA_UInt32}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_LocalizedTextListEntry
    next::Ptr{UA_LocalizedTextListEntry}
    localizedText::UA_LocalizedText
end

struct __JL_Ctag_48
    data::NTuple{16, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_48}) = (:array, :tree)
Base.fieldnames(::Type{Ptr{__JL_Ctag_48}}) = (:array, :tree)

function Base.getproperty(x::Ptr{__JL_Ctag_48}, f::Symbol)
    f === :array && return Ptr{Ptr{UA_ReferenceTarget}}(x + 0)
    f === :tree && return Ptr{__JL_Ctag_49}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_48, f::Symbol)
    r = Ref{__JL_Ctag_48}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_48}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_48}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_NodeReferenceKind
    data::NTuple{32, UInt8}
end

function Base.fieldnames(::Type{UA_NodeReferenceKind})
    (:targets, :targetsSize, :hasRefTree, :referenceTypeIndex, :isInverse)
end
function Base.fieldnames(::Type{Ptr{UA_NodeReferenceKind}})
    (:targets, :targetsSize, :hasRefTree, :referenceTypeIndex, :isInverse)
end

function Base.getproperty(x::Ptr{UA_NodeReferenceKind}, f::Symbol)
    f === :targets && return Ptr{__JL_Ctag_48}(x + 0)
    f === :targetsSize && return Ptr{Csize_t}(x + 16)
    f === :hasRefTree && return Ptr{UA_Boolean}(x + 24)
    f === :referenceTypeIndex && return Ptr{UA_Byte}(x + 25)
    f === :isInverse && return Ptr{UA_Boolean}(x + 26)
    return getfield(x, f)
end

function Base.getproperty(x::UA_NodeReferenceKind, f::Symbol)
    r = Ref{UA_NodeReferenceKind}(x)
    ptr = Base.unsafe_convert(Ptr{UA_NodeReferenceKind}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_NodeReferenceKind}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_NodeHead
    data::NTuple{120, UInt8}
end

function Base.fieldnames(::Type{UA_NodeHead})
    (:nodeId, :nodeClass, :browseName, :displayName, :description, :writeMask,
        :referencesSize, :references, :context, :constructed, :monitoredItems)
end
function Base.fieldnames(::Type{Ptr{UA_NodeHead}})
    (:nodeId, :nodeClass, :browseName, :displayName, :description, :writeMask,
        :referencesSize, :references, :context, :constructed, :monitoredItems)
end

function Base.getproperty(x::Ptr{UA_NodeHead}, f::Symbol)
    f === :nodeId && return Ptr{UA_NodeId}(x + 0)
    f === :nodeClass && return Ptr{UA_NodeClass}(x + 24)
    f === :browseName && return Ptr{UA_QualifiedName}(x + 32)
    f === :displayName && return Ptr{Ptr{UA_LocalizedTextListEntry}}(x + 56)
    f === :description && return Ptr{Ptr{UA_LocalizedTextListEntry}}(x + 64)
    f === :writeMask && return Ptr{UA_UInt32}(x + 72)
    f === :referencesSize && return Ptr{Csize_t}(x + 80)
    f === :references && return Ptr{Ptr{UA_NodeReferenceKind}}(x + 88)
    f === :context && return Ptr{Ptr{Cvoid}}(x + 96)
    f === :constructed && return Ptr{UA_Boolean}(x + 104)
    f === :monitoredItems && return Ptr{Ptr{UA_MonitoredItem}}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::UA_NodeHead, f::Symbol)
    r = Ref{UA_NodeHead}(x)
    ptr = Base.unsafe_convert(Ptr{UA_NodeHead}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_NodeHead}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `immediate`

- `id`

- `expandedId`

- `node`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_NodePointer
    data::NTuple{8, UInt8}
end

Base.fieldnames(::Type{UA_NodePointer}) = (:immediate, :id, :expandedId, :node)
Base.fieldnames(::Type{Ptr{UA_NodePointer}}) = (:immediate, :id, :expandedId, :node)

function Base.getproperty(x::Ptr{UA_NodePointer}, f::Symbol)
    f === :immediate && return Ptr{Csize_t}(x + 0)
    f === :id && return Ptr{Ptr{UA_NodeId}}(x + 0)
    f === :expandedId && return Ptr{Ptr{UA_ExpandedNodeId}}(x + 0)
    f === :node && return Ptr{Ptr{UA_NodeHead}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::UA_NodePointer, f::Symbol)
    r = Ref{UA_NodePointer}(x)
    ptr = Base.unsafe_convert(Ptr{UA_NodePointer}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_NodePointer}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function UA_NodePointer_clear(np)
    @ccall libopen62541.UA_NodePointer_clear(np::Ptr{UA_NodePointer})::Cvoid
end

function UA_NodePointer_copy(in, out)
    @ccall libopen62541.UA_NodePointer_copy(
        in::UA_NodePointer, out::Ptr{UA_NodePointer})::UA_StatusCode
end

function UA_NodePointer_isLocal(np)
    @ccall libopen62541.UA_NodePointer_isLocal(np::UA_NodePointer)::UA_Boolean
end

function UA_NodePointer_order(p1, p2)
    @ccall libopen62541.UA_NodePointer_order(
        p1::UA_NodePointer, p2::UA_NodePointer)::UA_Order
end

function UA_NodePointer_fromNodeId(id)
    @ccall libopen62541.UA_NodePointer_fromNodeId(id::Ptr{UA_NodeId})::UA_NodePointer
end

function UA_NodePointer_fromExpandedNodeId(id)
    @ccall libopen62541.UA_NodePointer_fromExpandedNodeId(id::Ptr{UA_ExpandedNodeId})::UA_NodePointer
end

function UA_NodePointer_toExpandedNodeId(np)
    @ccall libopen62541.UA_NodePointer_toExpandedNodeId(np::UA_NodePointer)::UA_ExpandedNodeId
end

function UA_NodePointer_toNodeId(np)
    @ccall libopen62541.UA_NodePointer_toNodeId(np::UA_NodePointer)::UA_NodeId
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReferenceTarget
    data::NTuple{16, UInt8}
end

Base.fieldnames(::Type{UA_ReferenceTarget}) = (:targetId, :targetNameHash)
Base.fieldnames(::Type{Ptr{UA_ReferenceTarget}}) = (:targetId, :targetNameHash)

function Base.getproperty(x::Ptr{UA_ReferenceTarget}, f::Symbol)
    f === :targetId && return Ptr{UA_NodePointer}(x + 0)
    f === :targetNameHash && return Ptr{UA_UInt32}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReferenceTarget, f::Symbol)
    r = Ref{UA_ReferenceTarget}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReferenceTarget}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReferenceTarget}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_41
    left::Ptr{Cvoid} # left::Ptr{UA_ReferenceTargetTreeElem}
    right::Ptr{Cvoid} # right::Ptr{UA_ReferenceTargetTreeElem}
end

function Base.getproperty(x::__JL_Ctag_41, f::Symbol)
    f === :left && return Ptr{UA_ReferenceTargetTreeElem}(getfield(x, f))
    f === :right && return Ptr{UA_ReferenceTargetTreeElem}(getfield(x, f))
    return getfield(x, f)
end

struct __JL_Ctag_42
    left::Ptr{Cvoid} # left::Ptr{UA_ReferenceTargetTreeElem}
    right::Ptr{Cvoid} # right::Ptr{UA_ReferenceTargetTreeElem}
end

function Base.getproperty(x::__JL_Ctag_42, f::Symbol)
    f === :left && return Ptr{UA_ReferenceTargetTreeElem}(getfield(x, f))
    f === :right && return Ptr{UA_ReferenceTargetTreeElem}(getfield(x, f))
    return getfield(x, f)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReferenceTargetTreeElem
    data::NTuple{56, UInt8}
end

function Base.fieldnames(::Type{UA_ReferenceTargetTreeElem})
    (:target, :targetIdHash, :idTreeEntry, :nameTreeEntry)
end
function Base.fieldnames(::Type{Ptr{UA_ReferenceTargetTreeElem}})
    (:target, :targetIdHash, :idTreeEntry, :nameTreeEntry)
end

function Base.getproperty(x::Ptr{UA_ReferenceTargetTreeElem}, f::Symbol)
    f === :target && return Ptr{UA_ReferenceTarget}(x + 0)
    f === :targetIdHash && return Ptr{UA_UInt32}(x + 16)
    f === :idTreeEntry && return Ptr{Cvoid}(x + 24)
    f === :nameTreeEntry && return Ptr{Cvoid}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReferenceTargetTreeElem, f::Symbol)
    r = Ref{UA_ReferenceTargetTreeElem}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReferenceTargetTreeElem}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReferenceTargetTreeElem}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

# typedef void * ( * UA_NodeReferenceKind_iterateCallback ) ( void * context , UA_ReferenceTarget * target )
const UA_NodeReferenceKind_iterateCallback = Ptr{Cvoid}

function UA_NodeReferenceKind_iterate(rk, callback, context)
    @ccall libopen62541.UA_NodeReferenceKind_iterate(
        rk::Ptr{UA_NodeReferenceKind}, callback::UA_NodeReferenceKind_iterateCallback,
        context::Ptr{Cvoid})::Ptr{Cvoid}
end

function UA_NodeReferenceKind_findTarget(rk, targetId)
    @ccall libopen62541.UA_NodeReferenceKind_findTarget(rk::Ptr{UA_NodeReferenceKind},
        targetId::Ptr{UA_ExpandedNodeId})::Ptr{UA_ReferenceTarget}
end

function UA_NodeReferenceKind_switch(rk)
    @ccall libopen62541.UA_NodeReferenceKind_switch(rk::Ptr{UA_NodeReferenceKind})::UA_StatusCode
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ExternalValueCallback
    notificationRead::Ptr{Cvoid}
    userWrite::Ptr{Cvoid}
end

struct __JL_Ctag_39
    data::NTuple{96, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_39}) = (:data, :dataSource)
Base.fieldnames(::Type{Ptr{__JL_Ctag_39}}) = (:data, :dataSource)

function Base.getproperty(x::Ptr{__JL_Ctag_39}, f::Symbol)
    f === :data && return Ptr{__JL_Ctag_40}(x + 0)
    f === :dataSource && return Ptr{UA_DataSource}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_39, f::Symbol)
    r = Ref{__JL_Ctag_39}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_39}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_39}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `head`

- `dataType`

- `valueRank`

- `arrayDimensionsSize`

- `arrayDimensions`

- `valueBackend`

- `valueSource`

- `value`

- `accessLevel`

- `minimumSamplingInterval`

- `historizing`

- `isDynamic`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_VariableNode
    data::NTuple{400, UInt8}
end

function Base.fieldnames(::Type{UA_VariableNode})
    (:head, :dataType, :valueRank, :arrayDimensionsSize,
        :arrayDimensions, :valueBackend, :valueSource, :value,
        :accessLevel, :minimumSamplingInterval, :historizing, :isDynamic)
end
function Base.fieldnames(::Type{Ptr{UA_VariableNode}})
    (:head, :dataType, :valueRank, :arrayDimensionsSize,
        :arrayDimensions, :valueBackend, :valueSource, :value,
        :accessLevel, :minimumSamplingInterval, :historizing, :isDynamic)
end

function Base.getproperty(x::Ptr{UA_VariableNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :dataType && return Ptr{UA_NodeId}(x + 120)
    f === :valueRank && return Ptr{UA_Int32}(x + 144)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 152)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 160)
    f === :valueBackend && return Ptr{UA_ValueBackend}(x + 168)
    f === :valueSource && return Ptr{UA_ValueSource}(x + 272)
    f === :value && return Ptr{__JL_Ctag_39}(x + 280)
    f === :accessLevel && return Ptr{UA_Byte}(x + 376)
    f === :minimumSamplingInterval && return Ptr{UA_Double}(x + 384)
    f === :historizing && return Ptr{UA_Boolean}(x + 392)
    f === :isDynamic && return Ptr{UA_Boolean}(x + 393)
    return getfield(x, f)
end

function Base.getproperty(x::UA_VariableNode, f::Symbol)
    r = Ref{UA_VariableNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_VariableNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_VariableNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_50
    data::NTuple{96, UInt8}
end

Base.fieldnames(::Type{__JL_Ctag_50}) = (:data, :dataSource)
Base.fieldnames(::Type{Ptr{__JL_Ctag_50}}) = (:data, :dataSource)

function Base.getproperty(x::Ptr{__JL_Ctag_50}, f::Symbol)
    f === :data && return Ptr{__JL_Ctag_51}(x + 0)
    f === :dataSource && return Ptr{UA_DataSource}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_50, f::Symbol)
    r = Ref{__JL_Ctag_50}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_50}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_50}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `head`

- `dataType`

- `valueRank`

- `arrayDimensionsSize`

- `arrayDimensions`

- `valueBackend`

- `valueSource`

- `value`

- `isAbstract`

- `lifecycle`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_VariableTypeNode
    data::NTuple{400, UInt8}
end

function Base.fieldnames(::Type{UA_VariableTypeNode})
    (:head, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions,
        :valueBackend, :valueSource, :value, :isAbstract, :lifecycle)
end
function Base.fieldnames(::Type{Ptr{UA_VariableTypeNode}})
    (:head, :dataType, :valueRank, :arrayDimensionsSize, :arrayDimensions,
        :valueBackend, :valueSource, :value, :isAbstract, :lifecycle)
end

function Base.getproperty(x::Ptr{UA_VariableTypeNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :dataType && return Ptr{UA_NodeId}(x + 120)
    f === :valueRank && return Ptr{UA_Int32}(x + 144)
    f === :arrayDimensionsSize && return Ptr{Csize_t}(x + 152)
    f === :arrayDimensions && return Ptr{Ptr{UA_UInt32}}(x + 160)
    f === :valueBackend && return Ptr{UA_ValueBackend}(x + 168)
    f === :valueSource && return Ptr{UA_ValueSource}(x + 272)
    f === :value && return Ptr{__JL_Ctag_50}(x + 280)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 376)
    f === :lifecycle && return Ptr{UA_NodeTypeLifecycle}(x + 384)
    return getfield(x, f)
end

function Base.getproperty(x::UA_VariableTypeNode, f::Symbol)
    r = Ref{UA_VariableTypeNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_VariableTypeNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_VariableTypeNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_MethodNode
    data::NTuple{144, UInt8}
end

Base.fieldnames(::Type{UA_MethodNode}) = (:head, :executable, :method, :async)
Base.fieldnames(::Type{Ptr{UA_MethodNode}}) = (:head, :executable, :method, :async)

function Base.getproperty(x::Ptr{UA_MethodNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :executable && return Ptr{UA_Boolean}(x + 120)
    f === :method && return Ptr{UA_MethodCallback}(x + 128)
    f === :async && return Ptr{UA_Boolean}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::UA_MethodNode, f::Symbol)
    r = Ref{UA_MethodNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_MethodNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_MethodNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ObjectNode
    data::NTuple{128, UInt8}
end

Base.fieldnames(::Type{UA_ObjectNode}) = (:head, :eventNotifier)
Base.fieldnames(::Type{Ptr{UA_ObjectNode}}) = (:head, :eventNotifier)

function Base.getproperty(x::Ptr{UA_ObjectNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :eventNotifier && return Ptr{UA_Byte}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ObjectNode, f::Symbol)
    r = Ref{UA_ObjectNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ObjectNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ObjectNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ObjectTypeNode
    data::NTuple{144, UInt8}
end

Base.fieldnames(::Type{UA_ObjectTypeNode}) = (:head, :isAbstract, :lifecycle)
Base.fieldnames(::Type{Ptr{UA_ObjectTypeNode}}) = (:head, :isAbstract, :lifecycle)

function Base.getproperty(x::Ptr{UA_ObjectTypeNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 120)
    f === :lifecycle && return Ptr{UA_NodeTypeLifecycle}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ObjectTypeNode, f::Symbol)
    r = Ref{UA_ObjectTypeNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ObjectTypeNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ObjectTypeNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ReferenceTypeNode
    data::NTuple{184, UInt8}
end

function Base.fieldnames(::Type{UA_ReferenceTypeNode})
    (:head, :isAbstract, :symmetric, :inverseName, :referenceTypeIndex, :subTypes)
end
function Base.fieldnames(::Type{Ptr{UA_ReferenceTypeNode}})
    (:head, :isAbstract, :symmetric, :inverseName, :referenceTypeIndex, :subTypes)
end

function Base.getproperty(x::Ptr{UA_ReferenceTypeNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 120)
    f === :symmetric && return Ptr{UA_Boolean}(x + 121)
    f === :inverseName && return Ptr{UA_LocalizedText}(x + 128)
    f === :referenceTypeIndex && return Ptr{UA_Byte}(x + 160)
    f === :subTypes && return Ptr{UA_ReferenceTypeSet}(x + 164)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ReferenceTypeNode, f::Symbol)
    r = Ref{UA_ReferenceTypeNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ReferenceTypeNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ReferenceTypeNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct UA_DataTypeNode
    data::NTuple{128, UInt8}
end

Base.fieldnames(::Type{UA_DataTypeNode}) = (:head, :isAbstract)
Base.fieldnames(::Type{Ptr{UA_DataTypeNode}}) = (:head, :isAbstract)

function Base.getproperty(x::Ptr{UA_DataTypeNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :isAbstract && return Ptr{UA_Boolean}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::UA_DataTypeNode, f::Symbol)
    r = Ref{UA_DataTypeNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_DataTypeNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_DataTypeNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_ViewNode
    data::NTuple{128, UInt8}
end

Base.fieldnames(::Type{UA_ViewNode}) = (:head, :eventNotifier, :containsNoLoops)
Base.fieldnames(::Type{Ptr{UA_ViewNode}}) = (:head, :eventNotifier, :containsNoLoops)

function Base.getproperty(x::Ptr{UA_ViewNode}, f::Symbol)
    f === :head && return Ptr{UA_NodeHead}(x + 0)
    f === :eventNotifier && return Ptr{UA_Byte}(x + 120)
    f === :containsNoLoops && return Ptr{UA_Boolean}(x + 121)
    return getfield(x, f)
end

function Base.getproperty(x::UA_ViewNode, f::Symbol)
    r = Ref{UA_ViewNode}(x)
    ptr = Base.unsafe_convert(Ptr{UA_ViewNode}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{UA_ViewNode}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

"""

$(TYPEDEF)

Fields:

- `head`

- `variableNode`

- `variableTypeNode`

- `methodNode`

- `objectNode`

- `objectTypeNode`

- `referenceTypeNode`

- `dataTypeNode`

- `viewNode`

Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.
"""
struct UA_Node
    data::NTuple{400, UInt8}
end

function Base.fieldnames(::Type{UA_Node})
    (:head, :variableNode, :variableTypeNode, :methodNode, :objectNode,
        :objectTypeNode, :referenceTypeNode, :dataTypeNode, :viewNode)
end
function Base.fieldnames(::Type{Ptr{UA_Node}})
    (:head, :variableNode, :variableTypeNode, :methodNode, :objectNode,
        :objectTypeNode, :referenceTypeNode, :dataTypeNode, :viewNode)
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
const UA_NodestoreVisitor = Ptr{Cvoid}

function UA_Node_setAttributes(node, attributes, attributeType)
    @ccall libopen62541.UA_Node_setAttributes(node::Ptr{UA_Node}, attributes::Ptr{Cvoid},
        attributeType::Ptr{UA_DataType})::UA_StatusCode
end

function UA_Node_copy(src, dst)
    @ccall libopen62541.UA_Node_copy(src::Ptr{UA_Node}, dst::Ptr{UA_Node})::UA_StatusCode
end

function UA_Node_copy_alloc(src)
    @ccall libopen62541.UA_Node_copy_alloc(src::Ptr{UA_Node})::Ptr{UA_Node}
end

function UA_Node_addReference(
        node, refTypeIndex, isForward, targetNodeId, targetBrowseNameHash)
    @ccall libopen62541.UA_Node_addReference(node::Ptr{UA_Node}, refTypeIndex::UA_Byte,
        isForward::UA_Boolean, targetNodeId::Ptr{UA_ExpandedNodeId},
        targetBrowseNameHash::UA_UInt32)::UA_StatusCode
end

function UA_Node_deleteReference(node, refTypeIndex, isForward, targetNodeId)
    @ccall libopen62541.UA_Node_deleteReference(
        node::Ptr{UA_Node}, refTypeIndex::UA_Byte, isForward::UA_Boolean,
        targetNodeId::Ptr{UA_ExpandedNodeId})::UA_StatusCode
end

function UA_Node_deleteReferencesSubset(node, keepSet)
    @ccall libopen62541.UA_Node_deleteReferencesSubset(
        node::Ptr{UA_Node}, keepSet::Ptr{UA_ReferenceTypeSet})::Cvoid
end

function UA_Node_deleteReferences(node)
    @ccall libopen62541.UA_Node_deleteReferences(node::Ptr{UA_Node})::Cvoid
end

function UA_Node_clear(node)
    @ccall libopen62541.UA_Node_clear(node::Ptr{UA_Node})::Cvoid
end

function UA_Nodestore_HashMap(ns)
    @ccall libopen62541.UA_Nodestore_HashMap(ns::Ptr{UA_Nodestore})::UA_StatusCode
end

function UA_Nodestore_ZipTree(ns)
    @ccall libopen62541.UA_Nodestore_ZipTree(ns::Ptr{UA_Nodestore})::UA_StatusCode
end

function UA_PKI_decryptPrivateKey(privateKey, password, outDerKey)
    @ccall libopen62541.UA_PKI_decryptPrivateKey(
        privateKey::UA_ByteString, password::UA_ByteString,
        outDerKey::Ptr{UA_ByteString})::UA_StatusCode
end

function UA_CertificateVerification_AcceptAll(cv)
    @ccall libopen62541.UA_CertificateVerification_AcceptAll(cv::Ptr{UA_CertificateVerification})::Cvoid
end

function UA_CertificateVerification_Trustlist(
        cv, certificateTrustList, certificateTrustListSize,
        certificateIssuerList, certificateIssuerListSize,
        certificateRevocationList, certificateRevocationListSize)
    @ccall libopen62541.UA_CertificateVerification_Trustlist(
        cv::Ptr{UA_CertificateVerification}, certificateTrustList::Ptr{UA_ByteString},
        certificateTrustListSize::Csize_t, certificateIssuerList::Ptr{UA_ByteString},
        certificateIssuerListSize::Csize_t, certificateRevocationList::Ptr{UA_ByteString},
        certificateRevocationListSize::Csize_t)::UA_StatusCode
end

function UA_SecurityPolicy_None(policy, localCertificate, logger)
    @ccall libopen62541.UA_SecurityPolicy_None(
        policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString,
        logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_SecurityPolicy_Basic128Rsa15(policy, localCertificate, localPrivateKey, logger)
    @ccall libopen62541.UA_SecurityPolicy_Basic128Rsa15(
        policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString,
        localPrivateKey::UA_ByteString, logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_SecurityPolicy_Basic256(policy, localCertificate, localPrivateKey, logger)
    @ccall libopen62541.UA_SecurityPolicy_Basic256(
        policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString,
        localPrivateKey::UA_ByteString, logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_SecurityPolicy_Basic256Sha256(policy, localCertificate, localPrivateKey, logger)
    @ccall libopen62541.UA_SecurityPolicy_Basic256Sha256(
        policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString,
        localPrivateKey::UA_ByteString, logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_SecurityPolicy_Aes128Sha256RsaOaep(
        policy, localCertificate, localPrivateKey, logger)
    @ccall libopen62541.UA_SecurityPolicy_Aes128Sha256RsaOaep(
        policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString,
        localPrivateKey::UA_ByteString, logger::Ptr{UA_Logger})::UA_StatusCode
end

function UA_SecurityPolicy_Aes256Sha256RsaPss(
        policy, localCertificate, localPrivateKey, logger)
    @ccall libopen62541.UA_SecurityPolicy_Aes256Sha256RsaPss(
        policy::Ptr{UA_SecurityPolicy}, localCertificate::UA_ByteString,
        localPrivateKey::UA_ByteString, logger::Ptr{UA_Logger})::UA_StatusCode
end

@cenum MatchStrategy::UInt32 begin
    MATCH_EQUAL = 0
    MATCH_AFTER = 1
    MATCH_EQUAL_OR_AFTER = 2
    MATCH_BEFORE = 3
    MATCH_EQUAL_OR_BEFORE = 4
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryDataBackend
    context::Ptr{Cvoid}
    deleteMembers::Ptr{Cvoid}
    serverSetHistoryData::Ptr{Cvoid}
    getHistoryData::Ptr{Cvoid}
    getDateTimeMatch::Ptr{Cvoid}
    getEnd::Ptr{Cvoid}
    lastIndex::Ptr{Cvoid}
    firstIndex::Ptr{Cvoid}
    resultSize::Ptr{Cvoid}
    copyDataValues::Ptr{Cvoid}
    getDataValue::Ptr{Cvoid}
    boundSupported::Ptr{Cvoid}
    timestampsToReturnSupported::Ptr{Cvoid}
    insertDataValue::Ptr{Cvoid}
    replaceDataValue::Ptr{Cvoid}
    updateDataValue::Ptr{Cvoid}
    removeDataValue::Ptr{Cvoid}
end

function UA_HistoryDataBackend_Memory(initialNodeIdStoreSize, initialDataStoreSize)
    @ccall libopen62541.UA_HistoryDataBackend_Memory(initialNodeIdStoreSize::Csize_t,
        initialDataStoreSize::Csize_t)::UA_HistoryDataBackend
end

function UA_HistoryDataBackend_Memory_Circular(initialNodeIdStoreSize, initialDataStoreSize)
    @ccall libopen62541.UA_HistoryDataBackend_Memory_Circular(
        initialNodeIdStoreSize::Csize_t,
        initialDataStoreSize::Csize_t)::UA_HistoryDataBackend
end

function UA_HistoryDataBackend_Memory_clear(backend)
    @ccall libopen62541.UA_HistoryDataBackend_Memory_clear(backend::Ptr{UA_HistoryDataBackend})::Cvoid
end

@cenum UA_HistorizingUpdateStrategy::UInt32 begin
    UA_HISTORIZINGUPDATESTRATEGY_USER = 0
    UA_HISTORIZINGUPDATESTRATEGY_VALUESET = 1
    UA_HISTORIZINGUPDATESTRATEGY_POLL = 2
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistorizingNodeIdSettings
    historizingBackend::UA_HistoryDataBackend
    maxHistoryDataResponseSize::Csize_t
    historizingUpdateStrategy::UA_HistorizingUpdateStrategy
    pollingInterval::Csize_t
    userContext::Ptr{Cvoid}
end

"""
$(TYPEDEF)
Fields:
$(TYPEDFIELDS)
"""
struct UA_HistoryDataGathering
    context::Ptr{Cvoid}
    deleteMembers::Ptr{Cvoid}
    registerNodeId::Ptr{Cvoid}
    stopPoll::Ptr{Cvoid}
    startPoll::Ptr{Cvoid}
    updateNodeIdSetting::Ptr{Cvoid}
    getHistorizingSetting::Ptr{Cvoid}
    setValue::Ptr{Cvoid}
end

function UA_HistoryDataGathering_Default(initialNodeIdStoreSize)
    @ccall libopen62541.UA_HistoryDataGathering_Default(initialNodeIdStoreSize::Csize_t)::UA_HistoryDataGathering
end

function UA_HistoryDataGathering_Circular(initialNodeIdStoreSize)
    @ccall libopen62541.UA_HistoryDataGathering_Circular(initialNodeIdStoreSize::Csize_t)::UA_HistoryDataGathering
end

function UA_HistoryDatabase_default(gathering)
    @ccall libopen62541.UA_HistoryDatabase_default(gathering::UA_HistoryDataGathering)::UA_HistoryDatabase
end

struct __JL_Ctag_36
    typeId::UA_NodeId
    body::UA_ByteString
end
function Base.getproperty(x::Ptr{__JL_Ctag_36}, f::Symbol)
    f === :typeId && return Ptr{UA_NodeId}(x + 0)
    f === :body && return Ptr{UA_ByteString}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_36, f::Symbol)
    r = Ref{__JL_Ctag_36}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_36}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_36}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_37
    type::Ptr{UA_DataType}
    data::Ptr{Cvoid}
end
function Base.getproperty(x::Ptr{__JL_Ctag_37}, f::Symbol)
    f === :type && return Ptr{Ptr{UA_DataType}}(x + 0)
    f === :data && return Ptr{Ptr{Cvoid}}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_37, f::Symbol)
    r = Ref{__JL_Ctag_37}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_37}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_37}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_40
    value::UA_DataValue
    callback::UA_ValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_40}, f::Symbol)
    f === :value && return Ptr{UA_DataValue}(x + 0)
    f === :callback && return Ptr{UA_ValueCallback}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_40, f::Symbol)
    r = Ref{__JL_Ctag_40}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_40}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_40}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_45
    value::UA_DataValue
    callback::UA_ValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_45}, f::Symbol)
    f === :value && return Ptr{UA_DataValue}(x + 0)
    f === :callback && return Ptr{UA_ValueCallback}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_45, f::Symbol)
    r = Ref{__JL_Ctag_45}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_45}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_45}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_46
    value::Ptr{Ptr{UA_DataValue}}
    callback::UA_ExternalValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_46}, f::Symbol)
    f === :value && return Ptr{Ptr{Ptr{UA_DataValue}}}(x + 0)
    f === :callback && return Ptr{UA_ExternalValueCallback}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_46, f::Symbol)
    r = Ref{__JL_Ctag_46}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_46}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_46}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_49
    idRoot::Ptr{UA_ReferenceTargetTreeElem}
    nameRoot::Ptr{UA_ReferenceTargetTreeElem}
end
function Base.getproperty(x::Ptr{__JL_Ctag_49}, f::Symbol)
    f === :idRoot && return Ptr{Ptr{UA_ReferenceTargetTreeElem}}(x + 0)
    f === :nameRoot && return Ptr{Ptr{UA_ReferenceTargetTreeElem}}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_49, f::Symbol)
    r = Ref{__JL_Ctag_49}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_49}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_49}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_51
    value::UA_DataValue
    callback::UA_ValueCallback
end
function Base.getproperty(x::Ptr{__JL_Ctag_51}, f::Symbol)
    f === :value && return Ptr{UA_DataValue}(x + 0)
    f === :callback && return Ptr{UA_ValueCallback}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_51, f::Symbol)
    r = Ref{__JL_Ctag_51}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_51}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_51}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

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
const UA_WRITEMASK_ACCESSLEVELEX = Cuint(0x01) << Cuint(25)
const UA_VALUERANK_SCALAR_OR_ONE_DIMENSION = -3
const UA_VALUERANK_ANY = -2
const UA_VALUERANK_SCALAR = -1
const UA_VALUERANK_ONE_OR_MORE_DIMENSIONS = 0
const UA_VALUERANK_ONE_DIMENSION = 1
const UA_VALUERANK_TWO_DIMENSIONS = 2
const UA_VALUERANK_THREE_DIMENSIONS = 3
const UA_EVENTNOTIFIER_SUBSCRIBE_TO_EVENT = Cuint(0x01) << Cuint(0)
const UA_EVENTNOTIFIER_HISTORY_READ = Cuint(0x01) << Cuint(2)
const UA_EVENTNOTIFIER_HISTORY_WRITE = Cuint(0x01) << Cuint(3)

const UA_LOGLEVEL = 100
const UA_MULTITHREADING = 100

# Skipping MacroDefinition: UA_INLINE inline

# Skipping MacroDefinition: UA_EXPORT __attribute__ ( ( dllimport ) )

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

const UA_STATUSCODE_INFOTYPE_DATAVALUE = 0x00000400
const UA_STATUSCODE_INFOBITS_OVERFLOW = 0x00000080
const UA_STATUSCODE_GOOD = 0x00000000
const UA_STATUSCODE_UNCERTAIN = 0x40000000
const UA_STATUSCODE_BAD = 0x80000000
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
const UA_STATUSCODE_GOODRETRANSMISSIONQUEUENOTSUPPORTED = 0x00df0000
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
const UA_STATUSCODE_BADTICKETREQUIRED = 0x811f0000
const UA_STATUSCODE_BADTICKETINVALID = 0x81200000
const UA_STATUSCODE_GOODEDITED = 0x00dc0000
const UA_STATUSCODE_GOODPOSTACTIONFAILED = 0x00dd0000
const UA_STATUSCODE_UNCERTAINDOMINANTVALUECHANGED = 0x40de0000
const UA_STATUSCODE_GOODDEPENDENTVALUECHANGED = 0x00e00000
const UA_STATUSCODE_BADDOMINANTVALUECHANGED = 0x80e10000
const UA_STATUSCODE_UNCERTAINDEPENDENTVALUECHANGED = 0x40e20000
const UA_STATUSCODE_BADDEPENDENTVALUECHANGED = 0x80e30000
const UA_STATUSCODE_GOODEDITED_DEPENDENTVALUECHANGED = 0x01160000
const UA_STATUSCODE_GOODEDITED_DOMINANTVALUECHANGED = 0x01170000
const UA_STATUSCODE_GOODEDITED_DOMINANTVALUECHANGED_DEPENDENTVALUECHANGED = 0x01180000
const UA_STATUSCODE_BADEDITED_OUTOFRANGE = 0x81190000
const UA_STATUSCODE_BADINITIALVALUE_OUTOFRANGE = 0x811a0000
const UA_STATUSCODE_BADOUTOFRANGE_DOMINANTVALUECHANGED = 0x811b0000
const UA_STATUSCODE_BADEDITED_OUTOFRANGE_DOMINANTVALUECHANGED = 0x811c0000
const UA_STATUSCODE_BADOUTOFRANGE_DOMINANTVALUECHANGED_DEPENDENTVALUECHANGED = 0x811d0000
const UA_STATUSCODE_BADEDITED_OUTOFRANGE_DOMINANTVALUECHANGED_DEPENDENTVALUECHANGED = 0x811e0000
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
const UA_SBYTE_MIN = -128
const UA_SBYTE_MAX = 127
const UA_BYTE_MIN = 0
const UA_BYTE_MAX = 255
const UA_INT16_MIN = -32768
const UA_INT16_MAX = 32767
const UA_UINT16_MIN = 0
const UA_UINT16_MAX = 65535

const UA_DATETIME_USEC = Clonglong(10)
const UA_DATETIME_MSEC = UA_DATETIME_USEC * Clonglong(1000)
const UA_DATETIME_SEC = UA_DATETIME_MSEC * Clonglong(1000)
const UA_DATETIME_UNIX_EPOCH = Clonglong(11644473600) * UA_DATETIME_SEC

# Skipping MacroDefinition: UA_EMPTY_ARRAY_SENTINEL ( ( void * ) 0x01 )
const UA_DATATYPEKINDS = 31
const UA_TYPES_COUNT = 388
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
const UA_TYPES_NAMINGRULETYPE = 25
const UA_TYPES_ENUMERATION = 26
const UA_TYPES_IMAGEBMP = 27
const UA_TYPES_IMAGEGIF = 28
const UA_TYPES_IMAGEJPG = 29
const UA_TYPES_IMAGEPNG = 30
const UA_TYPES_AUDIODATATYPE = 31
const UA_TYPES_URISTRING = 32
const UA_TYPES_BITFIELDMASKDATATYPE = 33
const UA_TYPES_SEMANTICVERSIONSTRING = 34
const UA_TYPES_KEYVALUEPAIR = 35
const UA_TYPES_ADDITIONALPARAMETERSTYPE = 36
const UA_TYPES_EPHEMERALKEYTYPE = 37
const UA_TYPES_RATIONALNUMBER = 38
const UA_TYPES_THREEDVECTOR = 39
const UA_TYPES_THREEDCARTESIANCOORDINATES = 40
const UA_TYPES_THREEDORIENTATION = 41
const UA_TYPES_THREEDFRAME = 42
const UA_TYPES_OPENFILEMODE = 43
const UA_TYPES_IDENTITYCRITERIATYPE = 44
const UA_TYPES_IDENTITYMAPPINGRULETYPE = 45
const UA_TYPES_CURRENCYUNITTYPE = 46
const UA_TYPES_TRUSTLISTMASKS = 47
const UA_TYPES_TRUSTLISTDATATYPE = 48
const UA_TYPES_DECIMALDATATYPE = 49
const UA_TYPES_DATATYPEDESCRIPTION = 50
const UA_TYPES_SIMPLETYPEDESCRIPTION = 51
const UA_TYPES_PORTABLEQUALIFIEDNAME = 52
const UA_TYPES_PORTABLENODEID = 53
const UA_TYPES_UNSIGNEDRATIONALNUMBER = 54
const UA_TYPES_PUBSUBSTATE = 55
const UA_DATASETFIELDFLAGS_NONE = 0
const UA_DATASETFIELDFLAGS_PROMOTEDFIELD = 1
const UA_TYPES_DATASETFIELDFLAGS = 56
const UA_TYPES_CONFIGURATIONVERSIONDATATYPE = 57
const UA_TYPES_PUBLISHEDVARIABLEDATATYPE = 58
const UA_TYPES_PUBLISHEDDATAITEMSDATATYPE = 59
const UA_TYPES_PUBLISHEDDATASETCUSTOMSOURCEDATATYPE = 60
const UA_DATASETFIELDCONTENTMASK_NONE = 0
const UA_DATASETFIELDCONTENTMASK_STATUSCODE = 1
const UA_DATASETFIELDCONTENTMASK_SOURCETIMESTAMP = 2
const UA_DATASETFIELDCONTENTMASK_SERVERTIMESTAMP = 4
const UA_DATASETFIELDCONTENTMASK_SOURCEPICOSECONDS = 8
const UA_DATASETFIELDCONTENTMASK_SERVERPICOSECONDS = 16
const UA_DATASETFIELDCONTENTMASK_RAWDATA = 32
const UA_TYPES_DATASETFIELDCONTENTMASK = 61
const UA_TYPES_DATASETWRITERDATATYPE = 62
const UA_TYPES_NETWORKADDRESSDATATYPE = 63
const UA_TYPES_NETWORKADDRESSURLDATATYPE = 64
const UA_TYPES_OVERRIDEVALUEHANDLING = 65
const UA_TYPES_STANDALONESUBSCRIBEDDATASETREFDATATYPE = 66
const UA_TYPES_DATASETORDERINGTYPE = 67
const UA_UADPNETWORKMESSAGECONTENTMASK_NONE = 0
const UA_UADPNETWORKMESSAGECONTENTMASK_PUBLISHERID = 1
const UA_UADPNETWORKMESSAGECONTENTMASK_GROUPHEADER = 2
const UA_UADPNETWORKMESSAGECONTENTMASK_WRITERGROUPID = 4
const UA_UADPNETWORKMESSAGECONTENTMASK_GROUPVERSION = 8
const UA_UADPNETWORKMESSAGECONTENTMASK_NETWORKMESSAGENUMBER = 16
const UA_UADPNETWORKMESSAGECONTENTMASK_SEQUENCENUMBER = 32
const UA_UADPNETWORKMESSAGECONTENTMASK_PAYLOADHEADER = 64
const UA_UADPNETWORKMESSAGECONTENTMASK_TIMESTAMP = 128
const UA_UADPNETWORKMESSAGECONTENTMASK_PICOSECONDS = 256
const UA_UADPNETWORKMESSAGECONTENTMASK_DATASETCLASSID = 512
const UA_UADPNETWORKMESSAGECONTENTMASK_PROMOTEDFIELDS = 1024
const UA_TYPES_UADPNETWORKMESSAGECONTENTMASK = 68
const UA_TYPES_UADPWRITERGROUPMESSAGEDATATYPE = 69
const UA_UADPDATASETMESSAGECONTENTMASK_NONE = 0
const UA_UADPDATASETMESSAGECONTENTMASK_TIMESTAMP = 1
const UA_UADPDATASETMESSAGECONTENTMASK_PICOSECONDS = 2
const UA_UADPDATASETMESSAGECONTENTMASK_STATUS = 4
const UA_UADPDATASETMESSAGECONTENTMASK_MAJORVERSION = 8
const UA_UADPDATASETMESSAGECONTENTMASK_MINORVERSION = 16
const UA_UADPDATASETMESSAGECONTENTMASK_SEQUENCENUMBER = 32
const UA_TYPES_UADPDATASETMESSAGECONTENTMASK = 70
const UA_TYPES_UADPDATASETWRITERMESSAGEDATATYPE = 71
const UA_TYPES_UADPDATASETREADERMESSAGEDATATYPE = 72
const UA_JSONNETWORKMESSAGECONTENTMASK_NONE = 0
const UA_JSONNETWORKMESSAGECONTENTMASK_NETWORKMESSAGEHEADER = 1
const UA_JSONNETWORKMESSAGECONTENTMASK_DATASETMESSAGEHEADER = 2
const UA_JSONNETWORKMESSAGECONTENTMASK_SINGLEDATASETMESSAGE = 4
const UA_JSONNETWORKMESSAGECONTENTMASK_PUBLISHERID = 8
const UA_JSONNETWORKMESSAGECONTENTMASK_DATASETCLASSID = 16
const UA_JSONNETWORKMESSAGECONTENTMASK_REPLYTO = 32
const UA_TYPES_JSONNETWORKMESSAGECONTENTMASK = 73
const UA_TYPES_JSONWRITERGROUPMESSAGEDATATYPE = 74
const UA_JSONDATASETMESSAGECONTENTMASK_NONE = 0
const UA_JSONDATASETMESSAGECONTENTMASK_DATASETWRITERID = 1
const UA_JSONDATASETMESSAGECONTENTMASK_METADATAVERSION = 2
const UA_JSONDATASETMESSAGECONTENTMASK_SEQUENCENUMBER = 4
const UA_JSONDATASETMESSAGECONTENTMASK_TIMESTAMP = 8
const UA_JSONDATASETMESSAGECONTENTMASK_STATUS = 16
const UA_JSONDATASETMESSAGECONTENTMASK_MESSAGETYPE = 32
const UA_JSONDATASETMESSAGECONTENTMASK_DATASETWRITERNAME = 64
const UA_JSONDATASETMESSAGECONTENTMASK_REVERSIBLEFIELDENCODING = 128
const UA_TYPES_JSONDATASETMESSAGECONTENTMASK = 75
const UA_TYPES_JSONDATASETWRITERMESSAGEDATATYPE = 76
const UA_TYPES_JSONDATASETREADERMESSAGEDATATYPE = 77
const UA_TYPES_TRANSMITQOSPRIORITYDATATYPE = 78
const UA_TYPES_RECEIVEQOSPRIORITYDATATYPE = 79
const UA_TYPES_DATAGRAMCONNECTIONTRANSPORTDATATYPE = 80
const UA_TYPES_DATAGRAMCONNECTIONTRANSPORT2DATATYPE = 81
const UA_TYPES_DATAGRAMWRITERGROUPTRANSPORTDATATYPE = 82
const UA_TYPES_DATAGRAMWRITERGROUPTRANSPORT2DATATYPE = 83
const UA_TYPES_DATAGRAMDATASETREADERTRANSPORTDATATYPE = 84
const UA_TYPES_BROKERCONNECTIONTRANSPORTDATATYPE = 85
const UA_TYPES_BROKERTRANSPORTQUALITYOFSERVICE = 86
const UA_TYPES_BROKERWRITERGROUPTRANSPORTDATATYPE = 87
const UA_TYPES_BROKERDATASETWRITERTRANSPORTDATATYPE = 88
const UA_TYPES_BROKERDATASETREADERTRANSPORTDATATYPE = 89
const UA_PUBSUBCONFIGURATIONREFMASK_NONE = 0
const UA_PUBSUBCONFIGURATIONREFMASK_ELEMENTADD = 1
const UA_PUBSUBCONFIGURATIONREFMASK_ELEMENTMATCH = 2
const UA_PUBSUBCONFIGURATIONREFMASK_ELEMENTMODIFY = 4
const UA_PUBSUBCONFIGURATIONREFMASK_ELEMENTREMOVE = 8
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCEWRITER = 16
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCEREADER = 32
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCEWRITERGROUP = 64
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCEREADERGROUP = 128
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCECONNECTION = 256
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCEPUBDATASET = 512
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCESUBDATASET = 1024
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCESECURITYGROUP = 2048
const UA_PUBSUBCONFIGURATIONREFMASK_REFERENCEPUSHTARGET = 4096
const UA_TYPES_PUBSUBCONFIGURATIONREFMASK = 90
const UA_TYPES_PUBSUBCONFIGURATIONREFDATATYPE = 91
const UA_TYPES_PUBSUBCONFIGURATIONVALUEDATATYPE = 92
const UA_TYPES_DIAGNOSTICSLEVEL = 93
const UA_TYPES_PUBSUBDIAGNOSTICSCOUNTERCLASSIFICATION = 94
const UA_TYPES_ALIASNAMEDATATYPE = 95
const UA_PASSWORDOPTIONSMASK_NONE = 0
const UA_PASSWORDOPTIONSMASK_SUPPORTINITIALPASSWORDCHANGE = 1
const UA_PASSWORDOPTIONSMASK_SUPPORTDISABLEUSER = 2
const UA_PASSWORDOPTIONSMASK_SUPPORTDISABLEDELETEFORUSER = 4
const UA_PASSWORDOPTIONSMASK_SUPPORTNOCHANGEFORUSER = 8
const UA_PASSWORDOPTIONSMASK_SUPPORTDESCRIPTIONFORUSER = 16
const UA_PASSWORDOPTIONSMASK_REQUIRESUPPERCASECHARACTERS = 32
const UA_PASSWORDOPTIONSMASK_REQUIRESLOWERCASECHARACTERS = 64
const UA_PASSWORDOPTIONSMASK_REQUIRESDIGITCHARACTERS = 128
const UA_PASSWORDOPTIONSMASK_REQUIRESSPECIALCHARACTERS = 256
const UA_TYPES_PASSWORDOPTIONSMASK = 96
const UA_USERCONFIGURATIONMASK_NONE = 0
const UA_USERCONFIGURATIONMASK_NODELETE = 1
const UA_USERCONFIGURATIONMASK_DISABLED = 2
const UA_USERCONFIGURATIONMASK_NOCHANGEBYUSER = 4
const UA_USERCONFIGURATIONMASK_MUSTCHANGEPASSWORD = 8
const UA_TYPES_USERCONFIGURATIONMASK = 97
const UA_TYPES_USERMANAGEMENTDATATYPE = 98
const UA_TYPES_DUPLEX = 99
const UA_TYPES_INTERFACEADMINSTATUS = 100
const UA_TYPES_INTERFACEOPERSTATUS = 101
const UA_TYPES_NEGOTIATIONSTATUS = 102
const UA_TYPES_TSNFAILURECODE = 103
const UA_TYPES_TSNSTREAMSTATE = 104
const UA_TYPES_TSNTALKERSTATUS = 105
const UA_TYPES_TSNLISTENERSTATUS = 106
const UA_TYPES_PRIORITYMAPPINGENTRYTYPE = 107
const UA_TYPES_IDTYPE = 108
const UA_TYPES_NODECLASS = 109
const UA_PERMISSIONTYPE_NONE = 0
const UA_PERMISSIONTYPE_BROWSE = 1
const UA_PERMISSIONTYPE_READROLEPERMISSIONS = 2
const UA_PERMISSIONTYPE_WRITEATTRIBUTE = 4
const UA_PERMISSIONTYPE_WRITEROLEPERMISSIONS = 8
const UA_PERMISSIONTYPE_WRITEHISTORIZING = 16
const UA_PERMISSIONTYPE_READ = 32
const UA_PERMISSIONTYPE_WRITE = 64
const UA_PERMISSIONTYPE_READHISTORY = 128
const UA_PERMISSIONTYPE_INSERTHISTORY = 256
const UA_PERMISSIONTYPE_MODIFYHISTORY = 512
const UA_PERMISSIONTYPE_DELETEHISTORY = 1024
const UA_PERMISSIONTYPE_RECEIVEEVENTS = 2048
const UA_PERMISSIONTYPE_CALL = 4096
const UA_PERMISSIONTYPE_ADDREFERENCE = 8192
const UA_PERMISSIONTYPE_REMOVEREFERENCE = 16384
const UA_PERMISSIONTYPE_DELETENODE = 32768
const UA_PERMISSIONTYPE_ADDNODE = 65536
const UA_TYPES_PERMISSIONTYPE = 110
const UA_ACCESSLEVELTYPE_NONE = 0
const UA_ACCESSLEVELTYPE_CURRENTREAD = 1
const UA_ACCESSLEVELTYPE_CURRENTWRITE = 2
const UA_ACCESSLEVELTYPE_HISTORYREAD = 4
const UA_ACCESSLEVELTYPE_HISTORYWRITE = 8
const UA_ACCESSLEVELTYPE_SEMANTICCHANGE = 16
const UA_ACCESSLEVELTYPE_STATUSWRITE = 32
const UA_ACCESSLEVELTYPE_TIMESTAMPWRITE = 64
const UA_TYPES_ACCESSLEVELTYPE = 111
const UA_ACCESSLEVELEXTYPE_NONE = 0
const UA_ACCESSLEVELEXTYPE_CURRENTREAD = 1
const UA_ACCESSLEVELEXTYPE_CURRENTWRITE = 2
const UA_ACCESSLEVELEXTYPE_HISTORYREAD = 4
const UA_ACCESSLEVELEXTYPE_HISTORYWRITE = 8
const UA_ACCESSLEVELEXTYPE_SEMANTICCHANGE = 16
const UA_ACCESSLEVELEXTYPE_STATUSWRITE = 32
const UA_ACCESSLEVELEXTYPE_TIMESTAMPWRITE = 64
const UA_ACCESSLEVELEXTYPE_NONATOMICREAD = 256
const UA_ACCESSLEVELEXTYPE_NONATOMICWRITE = 512
const UA_ACCESSLEVELEXTYPE_WRITEFULLARRAYONLY = 1024
const UA_ACCESSLEVELEXTYPE_NOSUBDATATYPES = 2048
const UA_ACCESSLEVELEXTYPE_NONVOLATILE = 4096
const UA_ACCESSLEVELEXTYPE_CONSTANT = 8192
const UA_TYPES_ACCESSLEVELEXTYPE = 112
const UA_EVENTNOTIFIERTYPE_NONE = 0
const UA_EVENTNOTIFIERTYPE_SUBSCRIBETOEVENTS = 1
const UA_EVENTNOTIFIERTYPE_HISTORYREAD = 4
const UA_EVENTNOTIFIERTYPE_HISTORYWRITE = 8
const UA_TYPES_EVENTNOTIFIERTYPE = 113
const UA_ACCESSRESTRICTIONTYPE_NONE = 0
const UA_ACCESSRESTRICTIONTYPE_SIGNINGREQUIRED = 1
const UA_ACCESSRESTRICTIONTYPE_ENCRYPTIONREQUIRED = 2
const UA_ACCESSRESTRICTIONTYPE_SESSIONREQUIRED = 4
const UA_ACCESSRESTRICTIONTYPE_APPLYRESTRICTIONSTOBROWSE = 8
const UA_TYPES_ACCESSRESTRICTIONTYPE = 114
const UA_TYPES_ROLEPERMISSIONTYPE = 115
const UA_TYPES_STRUCTURETYPE = 116
const UA_TYPES_STRUCTUREFIELD = 117
const UA_TYPES_STRUCTUREDEFINITION = 118
const UA_TYPES_REFERENCENODE = 119
const UA_TYPES_ARGUMENT = 120
const UA_TYPES_ENUMVALUETYPE = 121
const UA_TYPES_ENUMFIELD = 122
const UA_TYPES_OPTIONSET = 123
const UA_TYPES_NORMALIZEDSTRING = 124
const UA_TYPES_DECIMALSTRING = 125
const UA_TYPES_DURATIONSTRING = 126
const UA_TYPES_TIMESTRING = 127
const UA_TYPES_DATESTRING = 128
const UA_TYPES_DURATION = 129
const UA_TYPES_UTCTIME = 130
const UA_TYPES_LOCALEID = 131
const UA_TYPES_TIMEZONEDATATYPE = 132
const UA_TYPES_INDEX = 133
const UA_TYPES_INTEGERID = 134
const UA_TYPES_APPLICATIONTYPE = 135
const UA_TYPES_APPLICATIONDESCRIPTION = 136
const UA_TYPES_REQUESTHEADER = 137
const UA_TYPES_RESPONSEHEADER = 138
const UA_TYPES_VERSIONTIME = 139
const UA_TYPES_SERVICEFAULT = 140
const UA_TYPES_SESSIONLESSINVOKEREQUESTTYPE = 141
const UA_TYPES_SESSIONLESSINVOKERESPONSETYPE = 142
const UA_TYPES_FINDSERVERSREQUEST = 143
const UA_TYPES_FINDSERVERSRESPONSE = 144
const UA_TYPES_SERVERONNETWORK = 145
const UA_TYPES_FINDSERVERSONNETWORKREQUEST = 146
const UA_TYPES_FINDSERVERSONNETWORKRESPONSE = 147
const UA_TYPES_APPLICATIONINSTANCECERTIFICATE = 148
const UA_TYPES_MESSAGESECURITYMODE = 149
const UA_TYPES_USERTOKENTYPE = 150
const UA_TYPES_USERTOKENPOLICY = 151
const UA_TYPES_ENDPOINTDESCRIPTION = 152
const UA_TYPES_GETENDPOINTSREQUEST = 153
const UA_TYPES_GETENDPOINTSRESPONSE = 154
const UA_TYPES_REGISTEREDSERVER = 155
const UA_TYPES_REGISTERSERVERREQUEST = 156
const UA_TYPES_REGISTERSERVERRESPONSE = 157
const UA_TYPES_MDNSDISCOVERYCONFIGURATION = 158
const UA_TYPES_REGISTERSERVER2REQUEST = 159
const UA_TYPES_REGISTERSERVER2RESPONSE = 160
const UA_TYPES_SECURITYTOKENREQUESTTYPE = 161
const UA_TYPES_CHANNELSECURITYTOKEN = 162
const UA_TYPES_OPENSECURECHANNELREQUEST = 163
const UA_TYPES_OPENSECURECHANNELRESPONSE = 164
const UA_TYPES_CLOSESECURECHANNELREQUEST = 165
const UA_TYPES_CLOSESECURECHANNELRESPONSE = 166
const UA_TYPES_SIGNEDSOFTWARECERTIFICATE = 167
const UA_TYPES_SESSIONAUTHENTICATIONTOKEN = 168
const UA_TYPES_SIGNATUREDATA = 169
const UA_TYPES_CREATESESSIONREQUEST = 170
const UA_TYPES_CREATESESSIONRESPONSE = 171
const UA_TYPES_USERIDENTITYTOKEN = 172
const UA_TYPES_ANONYMOUSIDENTITYTOKEN = 173
const UA_TYPES_USERNAMEIDENTITYTOKEN = 174
const UA_TYPES_X509IDENTITYTOKEN = 175
const UA_TYPES_ISSUEDIDENTITYTOKEN = 176
const UA_TYPES_RSAENCRYPTEDSECRET = 177
const UA_TYPES_ECCENCRYPTEDSECRET = 178
const UA_TYPES_ACTIVATESESSIONREQUEST = 179
const UA_TYPES_ACTIVATESESSIONRESPONSE = 180
const UA_TYPES_CLOSESESSIONREQUEST = 181
const UA_TYPES_CLOSESESSIONRESPONSE = 182
const UA_TYPES_CANCELREQUEST = 183
const UA_TYPES_CANCELRESPONSE = 184
const UA_TYPES_NODEATTRIBUTESMASK = 185
const UA_TYPES_NODEATTRIBUTES = 186
const UA_TYPES_OBJECTATTRIBUTES = 187
const UA_TYPES_VARIABLEATTRIBUTES = 188
const UA_TYPES_METHODATTRIBUTES = 189
const UA_TYPES_OBJECTTYPEATTRIBUTES = 190
const UA_TYPES_VARIABLETYPEATTRIBUTES = 191
const UA_TYPES_REFERENCETYPEATTRIBUTES = 192
const UA_TYPES_DATATYPEATTRIBUTES = 193
const UA_TYPES_VIEWATTRIBUTES = 194
const UA_TYPES_GENERICATTRIBUTEVALUE = 195
const UA_TYPES_GENERICATTRIBUTES = 196
const UA_TYPES_ADDNODESITEM = 197
const UA_TYPES_ADDNODESRESULT = 198
const UA_TYPES_ADDNODESREQUEST = 199
const UA_TYPES_ADDNODESRESPONSE = 200
const UA_TYPES_ADDREFERENCESITEM = 201
const UA_TYPES_ADDREFERENCESREQUEST = 202
const UA_TYPES_ADDREFERENCESRESPONSE = 203
const UA_TYPES_DELETENODESITEM = 204
const UA_TYPES_DELETENODESREQUEST = 205
const UA_TYPES_DELETENODESRESPONSE = 206
const UA_TYPES_DELETEREFERENCESITEM = 207
const UA_TYPES_DELETEREFERENCESREQUEST = 208
const UA_TYPES_DELETEREFERENCESRESPONSE = 209
const UA_ATTRIBUTEWRITEMASK_NONE = 0
const UA_ATTRIBUTEWRITEMASK_ACCESSLEVEL = 1
const UA_ATTRIBUTEWRITEMASK_ARRAYDIMENSIONS = 2
const UA_ATTRIBUTEWRITEMASK_BROWSENAME = 4
const UA_ATTRIBUTEWRITEMASK_CONTAINSNOLOOPS = 8
const UA_ATTRIBUTEWRITEMASK_DATATYPE = 16
const UA_ATTRIBUTEWRITEMASK_DESCRIPTION = 32
const UA_ATTRIBUTEWRITEMASK_DISPLAYNAME = 64
const UA_ATTRIBUTEWRITEMASK_EVENTNOTIFIER = 128
const UA_ATTRIBUTEWRITEMASK_EXECUTABLE = 256
const UA_ATTRIBUTEWRITEMASK_HISTORIZING = 512
const UA_ATTRIBUTEWRITEMASK_INVERSENAME = 1024
const UA_ATTRIBUTEWRITEMASK_ISABSTRACT = 2048
const UA_ATTRIBUTEWRITEMASK_MINIMUMSAMPLINGINTERVAL = 4096
const UA_ATTRIBUTEWRITEMASK_NODECLASS = 8192
const UA_ATTRIBUTEWRITEMASK_NODEID = 16384
const UA_ATTRIBUTEWRITEMASK_SYMMETRIC = 32768
const UA_ATTRIBUTEWRITEMASK_USERACCESSLEVEL = 65536
const UA_ATTRIBUTEWRITEMASK_USEREXECUTABLE = 131072
const UA_ATTRIBUTEWRITEMASK_USERWRITEMASK = 262144
const UA_ATTRIBUTEWRITEMASK_VALUERANK = 524288
const UA_ATTRIBUTEWRITEMASK_WRITEMASK = 1048576
const UA_ATTRIBUTEWRITEMASK_VALUEFORVARIABLETYPE = 2097152
const UA_ATTRIBUTEWRITEMASK_DATATYPEDEFINITION = 4194304
const UA_ATTRIBUTEWRITEMASK_ROLEPERMISSIONS = 8388608
const UA_ATTRIBUTEWRITEMASK_ACCESSRESTRICTIONS = 16777216
const UA_ATTRIBUTEWRITEMASK_ACCESSLEVELEX = 33554432
const UA_TYPES_ATTRIBUTEWRITEMASK = 210
const UA_TYPES_BROWSEDIRECTION = 211
const UA_TYPES_VIEWDESCRIPTION = 212
const UA_TYPES_BROWSEDESCRIPTION = 213
const UA_TYPES_BROWSERESULTMASK = 214
const UA_TYPES_REFERENCEDESCRIPTION = 215
const UA_TYPES_CONTINUATIONPOINT = 216
const UA_TYPES_BROWSERESULT = 217
const UA_TYPES_BROWSEREQUEST = 218
const UA_TYPES_BROWSERESPONSE = 219
const UA_TYPES_BROWSENEXTREQUEST = 220
const UA_TYPES_BROWSENEXTRESPONSE = 221
const UA_TYPES_RELATIVEPATHELEMENT = 222
const UA_TYPES_RELATIVEPATH = 223
const UA_TYPES_BROWSEPATH = 224
const UA_TYPES_BROWSEPATHTARGET = 225
const UA_TYPES_BROWSEPATHRESULT = 226
const UA_TYPES_TRANSLATEBROWSEPATHSTONODEIDSREQUEST = 227
const UA_TYPES_TRANSLATEBROWSEPATHSTONODEIDSRESPONSE = 228
const UA_TYPES_REGISTERNODESREQUEST = 229
const UA_TYPES_REGISTERNODESRESPONSE = 230
const UA_TYPES_UNREGISTERNODESREQUEST = 231
const UA_TYPES_UNREGISTERNODESRESPONSE = 232
const UA_TYPES_COUNTER = 233
const UA_TYPES_OPAQUENUMERICRANGE = 234
const UA_TYPES_ENDPOINTCONFIGURATION = 235
const UA_TYPES_QUERYDATADESCRIPTION = 236
const UA_TYPES_NODETYPEDESCRIPTION = 237
const UA_TYPES_FILTEROPERATOR = 238
const UA_TYPES_QUERYDATASET = 239
const UA_TYPES_NODEREFERENCE = 240
const UA_TYPES_CONTENTFILTERELEMENT = 241
const UA_TYPES_CONTENTFILTER = 242
const UA_TYPES_ELEMENTOPERAND = 243
const UA_TYPES_LITERALOPERAND = 244
const UA_TYPES_ATTRIBUTEOPERAND = 245
const UA_TYPES_SIMPLEATTRIBUTEOPERAND = 246
const UA_TYPES_CONTENTFILTERELEMENTRESULT = 247
const UA_TYPES_CONTENTFILTERRESULT = 248
const UA_TYPES_PARSINGRESULT = 249
const UA_TYPES_QUERYFIRSTREQUEST = 250
const UA_TYPES_QUERYFIRSTRESPONSE = 251
const UA_TYPES_QUERYNEXTREQUEST = 252
const UA_TYPES_QUERYNEXTRESPONSE = 253
const UA_TYPES_TIMESTAMPSTORETURN = 254
const UA_TYPES_READVALUEID = 255
const UA_TYPES_READREQUEST = 256
const UA_TYPES_READRESPONSE = 257
const UA_TYPES_HISTORYREADVALUEID = 258
const UA_TYPES_HISTORYREADRESULT = 259
const UA_TYPES_READRAWMODIFIEDDETAILS = 260
const UA_TYPES_READATTIMEDETAILS = 261
const UA_TYPES_READANNOTATIONDATADETAILS = 262
const UA_TYPES_HISTORYDATA = 263
const UA_TYPES_HISTORYREADREQUEST = 264
const UA_TYPES_HISTORYREADRESPONSE = 265
const UA_TYPES_WRITEVALUE = 266
const UA_TYPES_WRITEREQUEST = 267
const UA_TYPES_WRITERESPONSE = 268
const UA_TYPES_HISTORYUPDATEDETAILS = 269
const UA_TYPES_HISTORYUPDATETYPE = 270
const UA_TYPES_PERFORMUPDATETYPE = 271
const UA_TYPES_UPDATEDATADETAILS = 272
const UA_TYPES_UPDATESTRUCTUREDATADETAILS = 273
const UA_TYPES_DELETERAWMODIFIEDDETAILS = 274
const UA_TYPES_DELETEATTIMEDETAILS = 275
const UA_TYPES_DELETEEVENTDETAILS = 276
const UA_TYPES_HISTORYUPDATERESULT = 277
const UA_TYPES_HISTORYUPDATEREQUEST = 278
const UA_TYPES_HISTORYUPDATERESPONSE = 279
const UA_TYPES_CALLMETHODREQUEST = 280
const UA_TYPES_CALLMETHODRESULT = 281
const UA_TYPES_CALLREQUEST = 282
const UA_TYPES_CALLRESPONSE = 283
const UA_TYPES_MONITORINGMODE = 284
const UA_TYPES_DATACHANGETRIGGER = 285
const UA_TYPES_DEADBANDTYPE = 286
const UA_TYPES_DATACHANGEFILTER = 287
const UA_TYPES_EVENTFILTER = 288
const UA_TYPES_AGGREGATECONFIGURATION = 289
const UA_TYPES_AGGREGATEFILTER = 290
const UA_TYPES_EVENTFILTERRESULT = 291
const UA_TYPES_AGGREGATEFILTERRESULT = 292
const UA_TYPES_MONITORINGPARAMETERS = 293
const UA_TYPES_MONITOREDITEMCREATEREQUEST = 294
const UA_TYPES_MONITOREDITEMCREATERESULT = 295
const UA_TYPES_CREATEMONITOREDITEMSREQUEST = 296
const UA_TYPES_CREATEMONITOREDITEMSRESPONSE = 297
const UA_TYPES_MONITOREDITEMMODIFYREQUEST = 298
const UA_TYPES_MONITOREDITEMMODIFYRESULT = 299
const UA_TYPES_MODIFYMONITOREDITEMSREQUEST = 300
const UA_TYPES_MODIFYMONITOREDITEMSRESPONSE = 301
const UA_TYPES_SETMONITORINGMODEREQUEST = 302
const UA_TYPES_SETMONITORINGMODERESPONSE = 303
const UA_TYPES_SETTRIGGERINGREQUEST = 304
const UA_TYPES_SETTRIGGERINGRESPONSE = 305
const UA_TYPES_DELETEMONITOREDITEMSREQUEST = 306
const UA_TYPES_DELETEMONITOREDITEMSRESPONSE = 307
const UA_TYPES_CREATESUBSCRIPTIONREQUEST = 308
const UA_TYPES_CREATESUBSCRIPTIONRESPONSE = 309
const UA_TYPES_MODIFYSUBSCRIPTIONREQUEST = 310
const UA_TYPES_MODIFYSUBSCRIPTIONRESPONSE = 311
const UA_TYPES_SETPUBLISHINGMODEREQUEST = 312
const UA_TYPES_SETPUBLISHINGMODERESPONSE = 313
const UA_TYPES_NOTIFICATIONMESSAGE = 314
const UA_TYPES_MONITOREDITEMNOTIFICATION = 315
const UA_TYPES_EVENTFIELDLIST = 316
const UA_TYPES_HISTORYEVENTFIELDLIST = 317
const UA_TYPES_STATUSCHANGENOTIFICATION = 318
const UA_TYPES_SUBSCRIPTIONACKNOWLEDGEMENT = 319
const UA_TYPES_PUBLISHREQUEST = 320
const UA_TYPES_PUBLISHRESPONSE = 321
const UA_TYPES_REPUBLISHREQUEST = 322
const UA_TYPES_REPUBLISHRESPONSE = 323
const UA_TYPES_TRANSFERRESULT = 324
const UA_TYPES_TRANSFERSUBSCRIPTIONSREQUEST = 325
const UA_TYPES_TRANSFERSUBSCRIPTIONSRESPONSE = 326
const UA_TYPES_DELETESUBSCRIPTIONSREQUEST = 327
const UA_TYPES_DELETESUBSCRIPTIONSRESPONSE = 328
const UA_TYPES_BUILDINFO = 329
const UA_TYPES_REDUNDANCYSUPPORT = 330
const UA_TYPES_SERVERSTATE = 331
const UA_TYPES_REDUNDANTSERVERDATATYPE = 332
const UA_TYPES_ENDPOINTURLLISTDATATYPE = 333
const UA_TYPES_NETWORKGROUPDATATYPE = 334
const UA_TYPES_SAMPLINGINTERVALDIAGNOSTICSDATATYPE = 335
const UA_TYPES_SERVERDIAGNOSTICSSUMMARYDATATYPE = 336
const UA_TYPES_SERVERSTATUSDATATYPE = 337
const UA_TYPES_SESSIONSECURITYDIAGNOSTICSDATATYPE = 338
const UA_TYPES_SERVICECOUNTERDATATYPE = 339
const UA_TYPES_STATUSRESULT = 340
const UA_TYPES_SUBSCRIPTIONDIAGNOSTICSDATATYPE = 341
const UA_TYPES_MODELCHANGESTRUCTUREVERBMASK = 342
const UA_TYPES_MODELCHANGESTRUCTUREDATATYPE = 343
const UA_TYPES_SEMANTICCHANGESTRUCTUREDATATYPE = 344
const UA_TYPES_RANGE = 345
const UA_TYPES_EUINFORMATION = 346
const UA_TYPES_AXISSCALEENUMERATION = 347
const UA_TYPES_COMPLEXNUMBERTYPE = 348
const UA_TYPES_DOUBLECOMPLEXNUMBERTYPE = 349
const UA_TYPES_AXISINFORMATION = 350
const UA_TYPES_XVTYPE = 351
const UA_TYPES_PROGRAMDIAGNOSTICDATATYPE = 352
const UA_TYPES_PROGRAMDIAGNOSTIC2DATATYPE = 353
const UA_TYPES_ANNOTATION = 354
const UA_TYPES_EXCEPTIONDEVIATIONFORMAT = 355
const UA_TYPES_ENDPOINTTYPE = 356
const UA_TYPES_STRUCTUREDESCRIPTION = 357
const UA_TYPES_FIELDMETADATA = 358
const UA_TYPES_PUBLISHEDEVENTSDATATYPE = 359
const UA_TYPES_PUBSUBGROUPDATATYPE = 360
const UA_TYPES_WRITERGROUPDATATYPE = 361
const UA_TYPES_FIELDTARGETDATATYPE = 362
const UA_TYPES_SUBSCRIBEDDATASETMIRRORDATATYPE = 363
const UA_TYPES_SECURITYGROUPDATATYPE = 364
const UA_TYPES_PUBSUBKEYPUSHTARGETDATATYPE = 365
const UA_TYPES_ENUMDEFINITION = 366
const UA_TYPES_READEVENTDETAILS = 367
const UA_TYPES_READPROCESSEDDETAILS = 368
const UA_TYPES_MODIFICATIONINFO = 369
const UA_TYPES_HISTORYMODIFIEDDATA = 370
const UA_TYPES_HISTORYEVENT = 371
const UA_TYPES_UPDATEEVENTDETAILS = 372
const UA_TYPES_DATACHANGENOTIFICATION = 373
const UA_TYPES_EVENTNOTIFICATIONLIST = 374
const UA_TYPES_SESSIONDIAGNOSTICSDATATYPE = 375
const UA_TYPES_ENUMDESCRIPTION = 376
const UA_TYPES_UABINARYFILEDATATYPE = 377
const UA_TYPES_DATASETMETADATATYPE = 378
const UA_TYPES_PUBLISHEDDATASETDATATYPE = 379
const UA_TYPES_DATASETREADERDATATYPE = 380
const UA_TYPES_TARGETVARIABLESDATATYPE = 381
const UA_TYPES_STANDALONESUBSCRIBEDDATASETDATATYPE = 382
const UA_TYPES_DATATYPESCHEMAHEADER = 383
const UA_TYPES_READERGROUPDATATYPE = 384
const UA_TYPES_PUBSUBCONNECTIONDATATYPE = 385
const UA_TYPES_PUBSUBCONFIGURATIONDATATYPE = 386
const UA_TYPES_PUBSUBCONFIGURATION2DATATYPE = 387
const UA_PRINTF_STRING_FORMAT = "\"%.*s\""
const UA_LOGCATEGORIES = 10
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
const INITIAL_MEMORY_STORE_SIZE = 1000

const UA_STRING_NULL = UA_String(0, C_NULL)
const UA_GUID_NULL = UA_Guid(0, 0, 0, Tuple(zeros(UA_Byte, 8)))
const UA_NODEID_NULL = UA_NodeId(Tuple(zeros(UA_Byte, 24)))
const UA_EXPANDEDNODEID_NULL = UA_ExpandedNodeId(Tuple(zeros(UA_Byte, 48)))

#Julia number types that are built directly into open62541
#Does NOT include ComplexF32/64 - these have to be treated differently.
const UA_NUMBER_TYPES = Union{Bool, Int8, Int16, Int32, Int64, UInt8, UInt16,
    UInt32, UInt64, Float32, Float64}

include("const_NS0ID.jl")
include("generated_defs.jl")
include("helper_functions.jl")
include("types.jl")
include("callbacks.jl")
include("server.jl")
include("client.jl")
include("highlevel_types.jl")
include("highlevel_server.jl")
include("highlevel_client.jl")
include("attribute_generation.jl")
include("exceptions.jl")
include("init.jl")

# exports
const PREFIXES = ["UA_", "JUA_"]
for name in names(@__MODULE__; all = true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
