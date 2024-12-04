# Purpose: This testset checks whether JUA_AccessControl_default functions operate
# correctly 

using Open62541, Test

#start with defining server and configuration
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)

#define some access control features and username, password combinations
allowAnonymous = false
batmanlogin = JUA_UsernamePasswordLogin("BruceWayne", "IamBatman")
spidermanlogin = JUA_UsernamePasswordLogin("PeterParker", "IamSpiderman")
logins = [batmanlogin, spidermanlogin]

retval1 = JUA_AccessControl_default(config, allowAnonymous, batmanlogin)
retval2 = JUA_AccessControl_default(config, allowAnonymous, logins)
retval3 = JUA_AccessControl_default(config, allowAnonymous, batmanlogin, "http://test.org")
retval4 = JUA_AccessControl_default(config, allowAnonymous, logins, "http://test.org")

@test retval1 == UA_STATUSCODE_GOOD
@test retval2 == UA_STATUSCODE_GOOD
@test retval3 == UA_STATUSCODE_GOOD
@test retval4 == UA_STATUSCODE_GOOD
