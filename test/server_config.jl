#this shall test access control configurations and basic server configurations

using open62541
using Test

server = UA_Server_new()
config = UA_Server_getConfig(server)

retval1 = UA_ServerConfig_setMinimalCustomBuffer(config,
    4842,
    C_NULL,
    0,
    0)
retval2 = UA_ServerConfig_setMinimal(config, 4842, C_NULL)
retval3 = UA_ServerConfig_setDefault(config)

@test retval1 == UA_STATUSCODE_GOOD
@test retval2 == UA_STATUSCODE_GOOD
@test retval3 == UA_STATUSCODE_GOOD
