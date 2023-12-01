#Mappings of valid (readable/writable) attributes for different node types:
@enumx UA_VARIABLENODE_ATTRIBUTES begin
    NodeId
    NodeClass
    BrowseName
    DisplayName
    Description
    WriteMask
    AccessLevel
    MinimumSamplingInterval
    Historizing
    DataType
    ValueRank
    ArrayDimensionsSize
    ArrayDimensions
    Value
end

@enumx UA_VARIABLETYPENODE_ATTRIBUTES begin
    NodeId
    NodeClass
    BrowseName
    DisplayName
    Description
    WriteMask
    AccessLevel
    MinimumSamplingInterval
    Historizing
    DataType
    ValueRank
    ArrayDimensionsSize
    ArrayDimensions
    Value
    IsAbstract
end

#further node types to look at:
# UA_NODECLASS_UNSPECIFIED = 0
#     UA_NODECLASS_OBJECT = 1
#     UA_NODECLASS_METHOD = 4
#     UA_NODECLASS_OBJECTTYPE = 8
#     UA_NODECLASS_REFERENCETYPE = 32
#     UA_NODECLASS_DATATYPE = 64
#     UA_NODECLASS_VIEW = 128

# struct UA_NodeHead {
#     UA_NodeId nodeId;
#     UA_NodeClass nodeClass;
#     UA_QualifiedName browseName;
#     UA_LocalizedText displayName;
#     UA_LocalizedText description;
#     UA_UInt32 writeMask;
# };

include("generated_defs.jl")
include("helper_functions.jl")

const UA_STRING_NULL = UA_String(0, C_NULL)
const UA_GUID_NULL = UA_Guid(0, 0, 0, Tuple(zeros(UA_Byte, 8)))
const UA_NODEID_NULL = UA_NodeId(0,
    UA_NodeIdType(0),
    anonymous_struct_tuple(UInt32(0), fieldtype(UA_NodeId, :identifier)))
const UA_EXPANDEDNODEID_NULL = UA_ExpandedNodeId(UA_NODEID_NULL, UA_STRING_NULL, 0)

include("types.jl")
include("server.jl")
include("client.jl")
include("exceptions.jl")
include("init.jl")

# exports
const PREFIXES = ["UA_", "__UA_"]
for name in names(@__MODULE__; all = true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end
