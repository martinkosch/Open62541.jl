# Encrypted username/password authentication using basic access control

In this tutorial, we will showcase how authentication using a username and password can be
accomplished using Open62541.jl. Following up from [Username/password authentication using basic access control](@ref)
the server and client will now be configured to use encryption, so that usernames and
passwords are transmitted safely across the network.

## Configuring the server

Here we configure the server to accept a username/password combination. We will also set up
encryption and disallow anonymous logins. The code block is commented line by line.

```julia
using Open62541

#generate a basic server certificate
#generate a basic server certificate
certificate = UA_ByteString_new()
privateKey = UA_ByteString_new()
subject = UA_String_Array_new([UA_String_fromChars("C=DE"),
    UA_String_fromChars("O=SampleOrganization"),
    UA_String_fromChars("CN=Open62541Server@localhost")])
lenSubject = UA_UInt32(3)
subjectAltName = UA_String_Array_new([UA_String_fromChars("DNS:localhost"),
    UA_String_fromChars("URI:urn:open62541.server.application")])
lenSubjectAltName = UA_UInt32(2)
kvm = UA_KeyValueMap_new()
expiresIn = UA_UInt16(14)
retval0 = UA_KeyValueMap_setScalar(
    kvm, JUA_QualifiedName(0, "expires-in-days"), Ref(expiresIn),
    UA_TYPES_PTRS[UA_TYPES_UINT16])
retval1 = UA_CreateCertificate(
    UA_Log_Stdout_new(UA_LOGLEVEL_FATAL), subject.ptr, lenSubject,
    subjectAltName.ptr, lenSubjectAltName, UA_CERTIFICATEFORMAT_DER, kvm, privateKey,
    certificate)

#configure the open62541 server; we choose a default config on port 4840.
server = JUA_Server()
config = JUA_ServerConfig(server)
JUA_ServerConfig_setDefault(config)
JUA_ServerConfig_addSecurityPolicyBasic256Sha256(config, certificate,
    privateKey)
JUA_ServerConfig_addAllEndpoints(config)
config.securityPolicyNoneDiscoveryOnly = true
login = JUA_UsernamePasswordLogin("BruceWayne", "IamBatman") #specifies the user BruceWayne and his secret password.
allowAnonymous = false #disallow anonymous login
JUA_AccessControl_default(config, allowAnonymous, login) #set the access control inside the server config.

JUA_Server_runUntilInterrupt(server) #start the server, shut it down by pressing CTRL+C repeatedly once you are finished with it.
```

## Using the client

Start a new Julia session and run the program shown below. Once you are finished,
you may want to return to the first Julia session and stop the server (press
CTRL + C repeatedly). Again, the code block is commented line by line.

```julia
using Open62541

#initiate client, configure it and connect to server
client = JUA_Client()
config = UA_Client_getConfig(client)

#generate a client certificate
certificate = UA_ByteString_new()
privateKey = UA_ByteString_new()
subject = UA_String_Array_new([UA_String_fromChars("C=DE"),
    UA_String_fromChars("O=SampleOrganization"),
    UA_String_fromChars("CN=Open62541Client@localhost")])
lenSubject = UA_UInt32(3)
subjectAltName = UA_String_Array_new([UA_String_fromChars("DNS:localhost"),
    UA_String_fromChars("URI:urn:open62541.client.application")])
lenSubjectAltName = UA_UInt32(2)
kvm = UA_KeyValueMap_new()
expiresIn = UA_UInt16(14)
UA_KeyValueMap_setScalar(kvm, JUA_QualifiedName(0, "expires-in-days"),
    Ref(expiresIn), UA_TYPES_PTRS[UA_TYPES_UINT16])
UA_CreateCertificate(UA_Log_Stdout_new(UA_LOGLEVEL_FATAL), subject.ptr, lenSubject,
    subjectAltName.ptr, lenSubjectAltName, UA_CERTIFICATEFORMAT_DER, kvm, privateKey,
    certificate)
revocationList = UA_ByteString_new()
revocationListSize = 0
trustList = UA_ByteString_new()
trustListSize = 0

UA_ClientConfig_setDefaultEncryption(config, certificate, privateKey,
    trustList, trustListSize, revocationList, revocationListSize)

#set a few values manually
UA_CertificateVerification_AcceptAll(config.certificateVerification) #accept any server certificate
config.securityMode = UA_MESSAGESECURITYMODE_SIGNANDENCRYPT
config.clientDescription.applicationUri = UA_String_fromChars("urn:open62541.client.application")

retval1 = JUA_Client_connectUsername(client,
    "opc.tcp://localhost:4840",
    "BruceWayne",
    "IamBatman") #connect using the username and password
JUA_Client_disconnect(client) #disconnect

#now let us try to connect with the wrong login credentials.
retval2 = JUA_Client_connectUsername(client,
    "opc.tcp://localhost:4840",
    "PeterParker",
    "IamSpiderman") #try connecting using a wrong username/password

#now let us try connecting as an anonymous user
retval3 = JUA_Client_connect(client, "opc.tcp://localhost:4840")

#now let us try connecting without encryption
client = JUA_Client()
JUA_ClientConfig_setDefault(JUA_ClientConfig(client))
retval4 = JUA_Client_connectUsername(client,
    "opc.tcp://localhost:4840",
    "BruceWayne",
    "IamBatman") #try connecting using a wrong username/password
```

`retval1` should be `UA_STATUSCODE_GOOD` (= 0) indicating that authentication was sucessful,
whereas `retval2` and `retval3` should be `UA_STATUSCODE_BADUSERACCESSDENIED` (= 2149515264)
indicating that the second login and third login attempt were rejected (wrong user
credentials). The fourth login attempt returns `retval4`, which should be
`UA_STATUSCODE_BADIDENTITYTOKENREJECTED` (= 2149646336), because we tried using an
unencrypted connection to a server that demands an encrypted one. Therefore, the server has
rejected the identity token.
