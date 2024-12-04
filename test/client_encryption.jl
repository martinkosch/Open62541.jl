using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using Open62541
    using Test
    using Pkg
end

# Create a new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
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
    retval0 = UA_KeyValueMap_setScalar(kvm, JUA_QualifiedName(0, "expires-in-days"),
        Ref(expiresIn), UA_TYPES_PTRS[UA_TYPES_UINT16])
    retval1 = UA_CreateCertificate(
        UA_Log_Stdout_new(UA_LOGLEVEL_FATAL), subject.ptr, lenSubject, subjectAltName.ptr, lenSubjectAltName,
        UA_CERTIFICATEFORMAT_DER, kvm, privateKey, certificate)

    #configure server
    server = JUA_Server()
    config = JUA_ServerConfig(server)
    retval2 = JUA_ServerConfig_setDefault(config)
    retval3 = JUA_ServerConfig_addSecurityPolicyBasic256Sha256(config, certificate,
        privateKey)
    retval4 = JUA_ServerConfig_addAllEndpoints(config)
    config.securityPolicyNoneDiscoveryOnly = true

    #check
    @test retval0 == UA_STATUSCODE_GOOD
    @test retval1 == UA_STATUSCODE_GOOD
    @test retval2 == UA_STATUSCODE_GOOD
    @test retval3 == UA_STATUSCODE_GOOD
    @test retval4 == UA_STATUSCODE_GOOD

    #clean up 
    UA_KeyValueMap_delete(kvm)
    UA_ByteString_delete(privateKey)
    UA_ByteString_delete(certificate)

    #run it
    JUA_Server_runUntilInterrupt(server)
end

#client code
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
retval0 = UA_KeyValueMap_setScalar(kvm, JUA_QualifiedName(0, "expires-in-days"),
    Ref(expiresIn), UA_TYPES_PTRS[UA_TYPES_UINT16])
retval1 = UA_CreateCertificate(
    UA_Log_Stdout_new(UA_LOGLEVEL_FATAL), subject.ptr, lenSubject, subjectAltName.ptr, lenSubjectAltName,
    UA_CERTIFICATEFORMAT_DER, kvm, privateKey, certificate)
revocationList = UA_ByteString_new()
revocationListSize = 0
trustList = UA_ByteString_new()
trustListSize = 0

retval2 = UA_ClientConfig_setDefaultEncryption(config, certificate, privateKey,
    trustList, trustListSize,
    revocationList, revocationListSize)

#clean up
UA_ByteString_delete(revocationList)
UA_ByteString_delete(trustList)
UA_ByteString_delete(privateKey)
UA_ByteString_delete(certificate)
UA_KeyValueMap_delete(kvm)

#set a few values manually
UA_CertificateVerification_AcceptAll(config.certificateVerification) #accept any server certificate
config.securityMode = UA_MESSAGESECURITYMODE_SIGNANDENCRYPT
config.clientDescription.applicationUri = UA_String_fromChars("urn:open62541.client.application")

#check
@test retval0 == UA_STATUSCODE_GOOD
@test retval1 == UA_STATUSCODE_GOOD
@test retval2 == UA_STATUSCODE_GOOD

#now connect it
max_duration = 90.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval = JUA_Client_connect(client, "opc.tcp://localhost:4840")
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end

# Read nodeid from server
nodeid = JUA_NodeId(0, UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION)
open62541_version_server = JUA_Client_readValueAttribute(client, nodeid)

vn2string(vn::VersionNumber) = "$(vn.major).$(vn.minor).$(vn.patch)"
@static if VERSION < v"1.9"
    pkgdir_old(m::Core.Module) = abspath(Base.pathof(Base.moduleroot(m)), "..", "..")
    function pkgproject_old(m::Core.Module)
        Pkg.Operations.read_project(Pkg.Types.projectfile_path(pkgdir_old(m)))
    end
    pkgversion_old(m::Core.Module) = pkgproject_old(m).version
    open62541_version_julia = pkgversion_old(open62541_jll)
else
    open62541_version_julia = pkgversion(open62541_jll)
end
open62541_version_julia = vn2string(open62541_version_julia)
@test open62541_version_server == open62541_version_julia

JUA_Client_disconnect(client)

#now try connecting unencrypted
client = JUA_Client()
retval4 = JUA_ClientConfig_setDefault(JUA_ClientConfig(client))
retval5 = JUA_Client_connect(client, "opc.tcp://localhost:4840")

@test retval4 == UA_STATUSCODE_GOOD
@test retval5 == UA_STATUSCODE_BADSECURITYPOLICYREJECTED

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
