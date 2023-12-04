# serverconfig functions
function UA_ServerConfig_setMinimal(config::Ref{UA_ServerConfig},
        portNumber::Integer,
        certificate::Ref{<:Union{Nothing, UA_ByteString}})
    UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, 0, 0)
end

function UA_ServerConfig_setDefault(config::Ref{UA_ServerConfig})
    UA_ServerConfig_setMinimal(config, 4840, C_NULL)
end

# attribute generation functions
function UA_VALUERANK(N::Integer)
    N == 1 && return UA_VALUERANK_ONE_DIMENSION
    N == 2 && return UA_VALUERANK_TWO_DIMENSIONS
    N == 3 && return UA_VALUERANK_THREE_DIMENSIONS
    return N
end

function _generic_variable_attributes(displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        type::DataType,
        localization::AbstractString = "en-US")
    attr = UA_VariableAttributes_new()
    retval = UA_VariableAttributes_copy(UA_VariableAttributes_default, attr)
    if retval == UA_STATUSCODE_GOOD
        attr.displayName = UA_LOCALIZEDTEXT_ALLOC(localization, displayname)
        attr.description = UA_LOCALIZEDTEXT_ALLOC(localization, description)
        attr.accessLevel = accesslevel
        attr.dataType = unsafe_load(ua_data_type_ptr_default(type).typeId)
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

function UA_generate_variable_attributes(input::AbstractArray{T, N},
        displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        valuerank::Integer = UA_VALUERANK(N),
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T, N}
    attr = _generic_variable_attributes(displayname, description, accesslevel, T)
    attr.valueRank = valuerank
    arraydims = UA_UInt32_Array_new(reverse(size(input))) #implicit conversion to uint32
    attr.arrayDimensions = arraydims
    attr.arrayDimensionsSize = length(arraydims)
    ua_arr = UA_Array_new(vec(permutedims(input, reverse(1:N))), type_ptr) # Allocate new UA_Array from input with C style indexing
    UA_Variant_setArray(attr.value,
        ua_arr,
        length(input),
        ua_data_type_ptr_default(T))
    attr.value.arrayDimensions = arraydims
    attr.value.arrayDimensionsSize = length(arraydims)
    return attr
end

function UA_generate_variable_attributes(input::T,
        displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        valuerank::Integer = UA_VALUERANK_SCALAR,
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{AbstractFloat, Integer}}
    UA_generate_variable_attributes(Ref(input),
        displayname,
        description,
        accesslevel,
        valuerank,
        type_ptr)
end

function UA_generate_variable_attributes(input::Ref{T},
        displayname::AbstractString,
        description::AbstractString,
        accesslevel::Integer,
        valuerank::Integer = UA_VALUERANK_SCALAR,
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{AbstractFloat, Integer}}
    attr = _generic_variable_attributes(displayname, description, accesslevel, T)
    attr.valueRank = valuerank
    UA_Variant_setScalarCopy(attr.value, input, type_ptr)
    return attr
end

# add node functions
function UA_Server_addVariableNode(server, requestedNewNodeId, parentNodeId,
        referenceTypeId,
        browseName, typeDefinition, attributes, nodeContext, outNewNodeId)
    return __UA_Server_addNode(server, UA_NODECLASS_VARIABLE, Ref(requestedNewNodeId),
        Ref(parentNodeId), Ref(referenceTypeId), browseName,
        Ref(typeDefinition), attributes, UA_TYPES_PTRS[UA_TYPES_VARIABLEATTRIBUTES],
        nodeContext, outNewNodeId)
end

## Read functions
for att in attributes_UA_Server_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3])
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(server::Ref{UA_Server}, nodeId::Ref{UA_NodeId})
            out = Ref{$(ret_type)}()
            statuscode = __UA_Server_read(server, nodeId, $(ua_attr_name), out)
            if statuscode == UA_STATUSCODE_GOOD
                return out[]
            else
                action = "Reading"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end

        function $(fun_name)(server, nodeId)
            return $(fun_name)(wrap_ref(server), wrap_ref(nodeId))
        end
    end
end

## Write functions
for att in attributes_UA_Server_write
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(server::Ref{UA_Server},
                nodeId::Ref{UA_NodeId},
                new_val::Ref{$attr_type})
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Server_write(server,
                nodeId,
                $(ua_attr_name),
                data_type_ptr,
                new_val)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(server, nodeId, new_val) 
        return ($fun_name)(wrap_ref(server),
            wrap_ref(nodeId),
            wrap_ref(new_val))
        end
    end
end
