using Pkg
#update packages by default
#Pkg.update()

using Clang.Generators
using open62541_jll
using JuliaFormatter
using OffsetArrays

#change dir
cd(@__DIR__)

# Load options from generator.toml
options = load_options(joinpath(@__DIR__, "generator.toml"))

# Extract all inlined functions and move them to codegen ignorelist; leads to out of memory
# error on low memory machines. Implemented Post-Clang.jl removal using Regexp (see below), which is lower
# memory requirement
# append!(options["general"]["output_ignorelist"], extract_inlined_funcs(headers))

# Add compiler flags
args = get_default_args()
push!(args, "-Iheaders")
push!(args, "-std=c99")

include_dir = joinpath(open62541_jll.artifact_dir, "include") |> normpath

#copy header files to new directory
Base.Filesystem.cptree(include_dir, "headers", force = true)
chmod("headers", 0o777; recursive = true)
headers = String[]
for (root, dirs, files) in walkdir("headers")
    for file in files
        push!(headers, joinpath(root, file)) # path to files
    end
end
headers = filter(x -> endswith(x, ".h"), headers) #just in case there are non .h files around...

#comment out two lines in util.h; 
#these caused errors since open62541_jll is compiled without amalgamation (reason not clear to me)
fn = joinpath(@__DIR__, "./headers/open62541/common.h")
f = open(fn, "r")
util_content = read(f, String)
close(f)
orig = "struct UA_ServerConfig;
typedef struct UA_ServerConfig UA_ServerConfig;"
new = "//struct UA_ServerConfig;
    //typedef struct UA_ServerConfig UA_ServerConfig;"
util_content = replace(util_content, orig => new)
f = open(fn, "w")
write(f, util_content)
close(f)

# Create context
ctx = create_context(headers, args, options)

# Run generator
build!(ctx)

function write_generated_defs(generated_defs_dir::String,
        headers,
        TYPE_NAMES,
        JULIA_TYPES)
    JULIA_TYPES = replace("$JULIA_TYPES", Regex("Main\\.Open62541\\.") => "")
    types_ambiguous_ignorelist = TYPE_NAMES[1:end .∉ [UNIQUE_JULIA_TYPES_IND]]
    type_string = """
    # Vector of all UA types
    const TYPE_NAMES = $TYPE_NAMES

    # Julia types corresponding to the UA types in vector TYPE_NAMES
    const JULIA_TYPES = $JULIA_TYPES

    # Unique julia types
    const UNIQUE_JULIA_TYPES_IND = unique(i -> JULIA_TYPES[i], eachindex(JULIA_TYPES))

    # Vector of types that are ambiguously defined via typedef and are not to be used as default type
    types_ambiguous_ignorelist = TYPE_NAMES[1:end .∉ [UNIQUE_JULIA_TYPES_IND]]

    """

    inlined_funcs = """
    # Vector of all inlined function names listed in the open62541 header files
    const inlined_funcs = $(extract_inlined_funcs(headers))
    """
    
    client_write = extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_write(\w*)Attribute)\((?:[\s\S]*?,\s*){2}const\s(\S*)", headers)
    push!(client_write, ["UA_Client_writeUserAccessLevelAttribute", "UserAccessLevel", "UA_Byte"])
    push!(client_write, ["UA_Client_writeValueAttribute_scalar", "Value", "UA_DataType"])
    push!(client_write, ["UA_Client_writeValueAttributeEx", "Value", "UA_DataValue"])
    data_UA_Client = """
    # UA_Client_ functions data 
    const attributes_UA_Client_Service = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_Service_(\w*))\((?:[\s\S]*?)\)(?:[\s\S]*?)UA_\S*", headers))
    const attributes_UA_Client_read = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_read(\w*)Attribute)\((?:[\s\S]*?,\s*){2}(\S*)", headers))
    const attributes_UA_Client_write = $(client_write)
    const attributes_UA_Client_read_async = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_read(\w*)Attribute_async)\([\s\S]+?\)[\s\S]+?{[\s\S]+?__UA_Client_readAttribute_async\s*\([\s\S]+?&UA_TYPES\[([\S]+?)\]", headers))
    const attributes_UA_Client_write_async = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_write(\w*)Attribute_async)\s*\(\s*UA_Client\s*\*client,\s*const\s*UA_NodeId\s*nodeId,\s*const\s*(\S*)", headers))
    """

    #Get rid of unnecessary type unions
    data_UA_Client = replace(data_UA_Client,
        "Vector{Union{Nothing, SubString{String}}}" => "Vector{String}")

    data_UA_Server = """
        # UA_Server_ functions data
        const attributes_UA_Server_read = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Server_read(\w*))\s*\(UA_Server\s*\*server,\s*const\s*UA_NodeId\s*nodeId,\s*(\S*)", headers))
        const attributes_UA_Server_write = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}(UA_Server_write(\w*))\s*\(UA_Server\s*\*server,\s*const\s*UA_NodeId\s*nodeId,\s*const (\S*)", headers))
        """
    #Get rid of unnecessary type unions
    data_UA_Server = replace(data_UA_Server,
        "Vector{Union{Nothing, SubString{String}}}" => "Vector{String}")

    open(generated_defs_dir, "w") do f
        write(f, type_string)
        write(f, inlined_funcs)
        write(f, data_UA_Client)
        write(f, data_UA_Server)
    end
end

function extract_inlined_funcs(headers)
    regex_inlined = r"UA_INLINE[\s]+(?:[\w\*]+[\s]*[\s\S]){0,3}((?:__)?UA_[\w]+)\("
    regex_inlined2 = r"UA_INLINABLE\(\s*\S*\s*(\S*)\("
    inlined_funcs = String[]
    for i in eachindex(headers)
        open(headers[i], "r") do f
            data = read(f, String)
            append!(inlined_funcs,
                vcat(getfield.(collect(eachmatch(regex_inlined, data)), :captures)...)) # Extract inlined functions from header file
            append!(inlined_funcs,
                vcat(getfield.(collect(eachmatch(regex_inlined2, data)), :captures)...)) # Extract inlined functions from header file
        end
    end
    return inlined_funcs
end

function extract_header_data(regex::Regex, headers)
    all_headers = ""
    for i in eachindex(headers)
        f = open(headers[i], "r")
        data = read(f, String)
        close(f)
        all_headers = all_headers * data
    end
    all_data = getfield.(collect(eachmatch(regex, all_headers)), :captures) # Extract inlined functions from header file
    return all_data
end

fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
data = read(f, String)
close(f)

#remove inlined functions
inlined_funcs = extract_inlined_funcs(headers)
for i in eachindex(inlined_funcs) 
    @show i
    r = Regex("function $(inlined_funcs[i])\\(.*\\)\n(.*)\nend\n\n")
    global data = replace(data, r => "")
end

#alternative1: removes docstrings of just the inlined functions
# for i in eachindex(inlined_funcs) 
#     @show i
#     r = Regex("\"\"\"([\\s\\S]){2,20}$(inlined_funcs[i])([\\s\\S]*?)\"\"\"")
#     data = replace(data, r => "")
# end 

#alternative2: automatically generated docstrings aren't really informative; removes them ALL.
r = Regex("\"\"\"([\\s\\S])*?\"\"\"")
data = replace(data, r => "")

fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "w")
write(f, data)
close(f)

#Bring back simple docstrings for structs
include("docstrings_types.jl")

#replace a specific function to make data handling more transparent
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
data = read(f, String)
close(f)

orig = "function UA_Guid_random()
    @ccall libopen62541.UA_Guid_random()::UA_Guid
end"
new = "function UA_Guid_random()
guid_dst = UA_Guid_new()
guid_src = @ccall libopen62541.UA_Guid_random()::UA_Guid
UA_Guid_copy(guid_src, guid_dst)
return guid_dst
end"
data = replace(data, orig=>new)

#need to remove some buggy lines
replacestring = "const UA_INT32_MIN = int32_t - Clonglong(2147483648)

const UA_INT32_MAX = Clong(2147483647)

const UA_UINT32_MIN = 0

const UA_UINT32_MAX = Culong(4294967295)

const UA_FLOAT_MIN = \$(Expr(:toplevel, :FLT_MIN))

const UA_FLOAT_MAX = \$(Expr(:toplevel, :FLT_MAX))

const UA_DOUBLE_MIN = \$(Expr(:toplevel, :DBL_MIN))

const UA_DOUBLE_MAX = \$(Expr(:toplevel, :DBL_MAX))"

data = replace(data, replacestring=>"")

#need to remove some buggy lines
replacestring = "const UA_INT32_MIN = int32_t - Clonglong(2147483648)

const UA_INT32_MAX = Clong(2147483647)

const UA_UINT32_MIN = 0

const UA_UINT32_MAX = Culong(4294967295)

const UA_FLOAT_MIN = \$(Expr(:toplevel, :FLT_MIN))

const UA_FLOAT_MAX = \$(Expr(:toplevel, :FLT_MAX))

const UA_DOUBLE_MIN = \$(Expr(:toplevel, :DBL_MIN))

const UA_DOUBLE_MAX = \$(Expr(:toplevel, :DBL_MAX))"

data = replace(data, replacestring=>"")

#replace version number code (make the constants express the version of the _jll 
#rather than hard coded numbers)
version_regex = r"const UA_OPEN62541_VER_MAJOR = \d+\n
const UA_OPEN62541_VER_MINOR = \d+\n
const UA_OPEN62541_VER_PATCH = \d+\n
const UA_OPEN62541_VER_LABEL = \"\S*\"\n
const UA_OPEN62541_VER_COMMIT = \"\S*\"\n
const UA_OPEN62541_VERSION = \"\S*\""
data = replace(data, version_regex => "")

#write new content down
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "w")
write(f, data)
close(f)


@warn "If errors occur at this stage, check start section of Open62541.jl for system-dependent symbols; may have to resolve manually."
@show "loading module"
include("../src/Open62541.jl")

# Get UA type names
UA_TYPES = Ref{Ptr{Open62541.UA_DataType}}(0)
UA_TYPES[] = cglobal((:UA_TYPES, libopen62541), Open62541.UA_DataType)
UA_TYPES_PTRS = OffsetVector{Ptr{Open62541.UA_DataType}}(undef,
    0:(Open62541.UA_TYPES_COUNT - 1))
UA_TYPES_MAP = Vector{DataType}(undef, Open62541.UA_TYPES_COUNT) # Initialize vector of mapping between UA_TYPES and Julia types as undefined and write values during __init__

for i in eachindex(UA_TYPES_PTRS)
    UA_TYPES_PTRS[i] = UA_TYPES[] + sizeof(Open62541.UA_DataType) * i
    typename = "UA_" * unsafe_string(unsafe_load(UA_TYPES_PTRS[i]).typeName)
    UA_TYPES_MAP[i + 1] = getglobal(Open62541, Symbol(typename))
end

TYPE_NAMES = [Symbol("UA_", unsafe_string(unsafe_load(type_ptr).typeName))
              for type_ptr in UA_TYPES_PTRS]

# Get corresponding Julia Types
function juliadatatype(p, start, UA_TYPES_MAP)
    ind = Int(Int((p - start)) / sizeof(Open62541.UA_DataType))
    return UA_TYPES_MAP[ind + 1]
end
JULIA_TYPES = [juliadatatype(type_ptr, UA_TYPES_PTRS[0], UA_TYPES_MAP)
               for type_ptr in UA_TYPES_PTRS]

# Write static definitions to file generated_defs.jl
write_generated_defs(joinpath(@__DIR__, "../src/generated_defs.jl"),
    headers,
    TYPE_NAMES,
    JULIA_TYPES)

# Now let's get the epilogue into the Open62541.jl filter
# 1. Read original file content
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
orig_content = read(f, String)
orig_content = replace(orig_content, "end # module" => "")
close(f)

# 2. Read epilogue file content
fn = joinpath(@__DIR__, "./epilogue.jl")
f = open(fn, "r")
epilogue_content = read(f, String)
close(f)

# 3. Write overall content to the file
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "w")
write(f, orig_content * "\n" * epilogue_content * "\nend # module")
close(f)

#remove double new lines on each "const xxx = ..." line
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
orig_content = read(f, String)
close(f)
new_content = replace(orig_content, "\n\nconst" => "\nconst")
f = open(fn, "w")
write(f, new_content)
close(f)

#The wrapper has now some flexibility in terms of accepting different patch versions.
#open62541_jll versions that are compatible with the same wrapper include: 
#1.3.9, 1.3.10, 1.3.11 (and presumably future patch versions on 1.3 branch)
#1.4.0, 1.4.1 (and presumably future patch versions on 1.4 branch)

# #set compat bound in Project.toml automatically to version that the generator ran on.
# fn = joinpath(@__DIR__, "../Project.toml")
# vn2string(vn::VersionNumber) = "$(vn.major).$(vn.minor).$(vn.patch)"
# f = open(fn, "r")
# orig_content = read(f, String)
# close(f)
# reg = r"open62541_jll = \"=[0-9]+\.[0-9]+\.[0-9]+\""
# open62541_version = vn2string(pkgversion(open62541_jll))
# new_content = replace(orig_content, reg => "open62541_jll = \"=$open62541_version\"")
# f = open(fn, "w")
# write(f, new_content)
# close(f)

@warn "Check compat bounds for open62541_jll in Project.toml manually."

#also run the callbacks_generator
include("callbacks_generator.jl")

# automated formatting
format(joinpath(@__DIR__, "../src/Open62541.jl"))
format(joinpath(@__DIR__, "../src/callbacks.jl"))

#delete headers directory
Base.Filesystem.rm("headers", recursive = true)

