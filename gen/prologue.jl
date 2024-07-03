using Dates
using OffsetArrays
using DocStringExtensions

const UA_INT64_MAX = typemax(Int64)
const UA_INT64_MIN = typemin(Int64)
const UA_UINT64_MAX = typemax(UInt64)
const UA_UINT64_MIN = typemin(UInt64)
const UA_FALSE = false
const UA_TRUE = true

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
