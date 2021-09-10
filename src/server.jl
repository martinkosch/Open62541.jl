function UA_ServerConfig_setMinimal(
    config::Ref{UA_ServerConfig}, 
    portNumber::Integer, 
    certificate::Ref{<:Union{Nothing, UA_ByteString}},
)
    UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, 0, 0)
end

UA_ServerConfig_setDefault(config::Ref{UA_ServerConfig}) = UA_ServerConfig_setMinimal(config, 4840, C_NULL)
