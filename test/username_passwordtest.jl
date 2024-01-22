using open62541
#follows Server side example here: https://github.com/open62541/open62541/blob/2c87f1ed06bf594103d6bf0b1d31267fa3e9d8cf/examples/access_control/server_access_control.c
server = UA_Server_new()
config = UA_Server_getConfig(server)
UA_ServerConfig_setDefault(config)
login = UA_UsernamePasswordLogin(UA_STRING("user"), UA_STRING("password"))
UA_AccessControl_default(config,
    false,
    C_NULL,
    Ref(unsafe_load(unsafe_load(config.securityPolicies)).policyUri),
    1,
    Ref(login))

#Client side: https://github.com/open62541/open62541/blob/2c87f1ed06bf594103d6bf0b1d31267fa3e9d8cf/examples/access_control/client_access_control.c
