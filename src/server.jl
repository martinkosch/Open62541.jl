function UA_ServerConfig_setMinimal(
    config::Ref{UA_ServerConfig}, 
    portNumber::Integer, 
    certificate::Ref{<:Union{Nothing, UA_ByteString}},
)
    UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, 0, 0)
end

UA_ServerConfig_setDefault(config::Ref{UA_ServerConfig}) = UA_ServerConfig_setMinimal(config, 4840, C_NULL)


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
            retval = __UA_Server_read(server, nodeId, $(ua_attr_name), out)
            if retval == UA_STATUSCODE_GOOD
                return out[]
            else
                error("Reading ´$(attr_name)´ from UA_Server failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
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
        function $(fun_name)(server::Ptr{UA_Server}, nodeId::Ref{UA_NodeId}, new_val::$(attr_type))
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            retval = __UA_Server_write(server, nodeId, $(ua_attr_name), data_type_ptr, new_val)
            if retval == UA_STATUSCODE_GOOD
                return retval
            else
                error("Writing ´$(attr_name)´ on UA_Server failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
            end
        end

        function $(fun_name)(server::Ptr{UA_Server}, nodeId::UA_NodeId, new_val::$(attr_type)) 
            return $(fun_name)(server, Ref(nodeId), new_val)
        end
    end
end