# Read attribute functions
regex_client = r"^UA_Client_read(\w*)Attribute$"
client_funcs = Symbol[]
for f in inlined_funcs
    m = match(regex_client, f)
    if !isnothing(m)
        type = m.captures[1]
        return_type = "Variant" # TODO: This must be adaptive to real return_type
        return_type_sym = Symbol("UA_", return_type)
        type_ind_name = Symbol("UA_TYPES_", uppercase(return_type))
        attribute_name = Symbol("UA_ATTRIBUTEID_", uppercase(type))
        
        @eval begin 
            function $(Symbol(m.match))(client::Ptr{UA_Client}, nodeId::Ref{UA_NodeId})
                data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
                out = Ref{$(return_type_sym)}()
                retval = __UA_Client_readAttribute(client, nodeId, $(attribute_name), out, data_type_ptr)
                if retval == UA_STATUSCODE_GOOD
                    return out[]
                else
                    error("Reading attribute ´$(return_type_sym)´ from UA_Client failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
                end
            end

            function $(Symbol(m.match))(client::Ptr{UA_Client}, nodeId::UA_NodeId) 
                return $(Symbol(m.match))(client, Ref(nodeId))
            end
        end
    end
end