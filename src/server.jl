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
function UA_VALUERANK(N)
    N == 1 && return UA_VALUERANK_ONE_DIMENSION
    N == 2 && return UA_VALUERANK_TWO_DIMENSIONS
    N == 3 && return UA_VALUERANK_THREE_DIMENSIONS
    return N
end

function _generic_variable_attributes(displayname,
        description,
        accesslevel,
        type,
        localization = "en-US")
    attr_default = cglobal((:UA_VariableAttributes_default, libopen62541),
        UA_VariableAttributes)
    attr = UA_VariableAttributes_new()
    statuscode = UA_VariableAttributes_copy(attr_default, attr)
    if statuscode == UA_STATUSCODE_GOOD
        attr.displayName = UA_LOCALIZEDTEXT_ALLOC(localization, displayname)
        attr.description = UA_LOCALIZEDTEXT_ALLOC(localization, description)
        attr.accessLevel = accesslevel
        attr.dataType = unsafe_load(UA_TYPES_PTRS[juliatype2uaindicator(type)].typeId)
        return attr
    else
        err = AttributeCopyError(statuscode)
        throw(err)
    end
end

function UA_generate_variable_attributes(input::AbstractArray{T, N},
        displayname,
        description,
        accesslevel,
        valuerank = UA_VALUERANK(N)) where {T, N}
    attr = _generic_variable_attributes(displayname, description, accesslevel, T)
    attr.valueRank = valuerank
    arraydims = UA_UInt32_Array_new(reverse(size(input))) #implicit conversion to uint32
    attr.arrayDimensions = arraydims
    attr.arrayDimensionsSize = length(arraydims)
    #permutedims here to store julia array in native C format within server; the eval is of 
    #course very ugly, but seems typestable due to specialization
    UA_Array = eval(Symbol("UA_", juliatype2uaword(T), "_Array_new"))(vec(permutedims(input,
        reverse(1:N))))
    UA_Variant_setArray(attr.value,
        UA_Array.ptr,
        length(input),
        UA_TYPES_PTRS[juliatype2uaindicator(T)])
    attr.value.arrayDimensions = arraydims
    attr.value.arrayDimensionsSize = length(arraydims)
    return attr
end

function UA_generate_variable_attributes(input::T,
        displayname,
        description,
        accesslevel,
        valuerank = UA_VALUERANK_SCALAR) where {T <: Union{AbstractFloat, Integer}}
    UA_generate_variable_attributes(Ref(input),
        displayname,
        description,
        accesslevel,
        valuerank)
end

function UA_generate_variable_attributes(input::Ref{T},
        displayname,
        description,
        accesslevel,
        valuerank = UA_VALUERANK_SCALAR) where {T <: Union{AbstractFloat, Integer}}
    attr = _generic_variable_attributes(displayname, description, accesslevel, T)
    attr.valueRank = valuerank
    UA_Variant_setScalar(attr.value, input, UA_TYPES_PTRS[juliatype2uaindicator(T)])
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
        function $(fun_name)(server::Ptr{UA_Server}, nodeId::Ref{UA_NodeId})
            out = Ref{$(ret_type)}()
            statuscode = __UA_Server_read(server, nodeId, $(ua_attr_name), out)
            if statuscode == UA_STATUSCODE_GOOD
                return out[]
            else
                action = "Reading"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action, mode, side, $(String(attr_name)), statuscode)
                throw(err)
            end
        end

        function $(fun_name)(server::Ptr{UA_Server}, nodeId::UA_NodeId)
            return $(fun_name)(server, Ref(nodeId))
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
        function $(fun_name)(server::Ptr{UA_Server},
                nodeId::Ref{UA_NodeId},
                new_val)
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
                err = AttributeReadWriteError(action, mode, side, $(String(attr_name)), statuscode)
                throw(err)
            end
        end

        function $(fun_name)(server::Ptr{UA_Server},
                nodeId::UA_NodeId,
                new_val)
            return $(fun_name)(server, Ref(nodeId), new_val)
        end
    end
end
