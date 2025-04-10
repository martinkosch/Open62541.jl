# Purpose: Tests basic publish/subscribe (Pubsub) functionality

#based on: https://www.open62541.org/doc/v1.4.10/tutorial_pubsub_subscribe.html

using Open62541, Test

#create server
server = JUA_Server()

#add a pubsub connection
ref = Ref{UA_PubSubConnectionConfig}()
connectionConfig = convert(Ptr{UA_PubSubConnectionConfig}, pointer_from_objref(ref))
UA_init(connectionConfig)

connectionConfig.name = UA_STRING("UDPMC Connection 1")
connectionConfig.transportProfileUri =
    UA_STRING("http://opcfoundation.org/UA-Profile/Transport/pubsub-udp-uadp")
connectionConfig.enabled = true
networkAddressUrl = UA_NetworkAddressUrlDataType_new()
networkAddressUrl.networkInterface = UA_STRING_NULL
networkAddressUrl.url = UA_STRING("opc.udp://224.0.0.22:4840/")

UA_Variant_setScalar(connectionConfig.address, networkAddressUrl,
                        UA_TYPES_PTRS[UA_TYPES_NETWORKADDRESSURLDATATYPE])

connectionConfig.publisherIdType = UA_PUBLISHERIDTYPE_UINT32
connectionConfig.publisherId.uint32 = UA_UInt32_random()

connectionIdentifier = UA_NodeId_new()
retval1 = UA_Server_addPubSubConnection(server, connectionConfig, connectionIdentifier) 
@test retval1 == UA_STATUSCODE_GOOD

#add readergroup 
readerGroupIdentifier = UA_NodeId_new()
ref = Ref{UA_ReaderGroupConfig}()
readerGroupConfig = convert(Ptr{UA_ReaderGroupConfig}, pointer_from_objref(ref))
UA_init(readerGroupConfig)
readerGroupConfig.name = UA_STRING("ReaderGroup1")
retval2 = UA_Server_addReaderGroup(server, connectionIdentifier, readerGroupConfig,
                                       readerGroupIdentifier)
@test retval2 == UA_STATUSCODE_GOOD
retval3 = UA_Server_setReaderGroupOperational(server, readerGroupIdentifier)
@test retval3 == UA_STATUSCODE_GOOD

#add dataset reader
readerIdentifier = UA_NodeId_new()
ref = Ref{UA_DataSetReaderConfig}()
readerConfig = convert(Ptr{UA_DataSetReaderConfig}, pointer_from_objref(ref))
UA_init(readerConfig)
readerConfig.name = UA_STRING("DataSet Reader 1")
publisherId = JUA_Variant(UInt16(2234))
readerConfig.publisherId = unsafe_load(Open62541.Jpointer(publisherId))
readerConfig.writerGroupId = 100
readerConfig.dataSetWriterId = 62541

#setting up Meta data configuration in DataSetReader
pMetaData = readerConfig.dataSetMetaData
UA_DataSetMetaDataType_init(pMetaData)
pMetaData.name = UA_STRING("DataSet 1")

# Static definition of number of fields size to 4 to create four different
# targetVariables of distinct datatype
# Currently the publisher sends only DateTime data type
pMetaData.fieldsSize = 4
pMetaData.fields = UA_Array_new(unsafe_load(pMetaData.fieldsSize),
                        UA_TYPES_PTRS[UA_TYPES_FIELDMETADATA])

arr = UA_Array(unsafe_load(pMetaData.fields), 4)

# DateTime DataType
UA_FieldMetaData_init(arr[1])
retval4a = UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_DATETIME].typeId,
                arr[1].dataType)
@test retval4a == UA_STATUSCODE_GOOD
arr[1].builtInType = UA_NS0ID_DATETIME
arr[1].name =  UA_String_fromChars("DateTime")
arr[1].valueRank = -1 # scalar

# Int32 DataType 
UA_FieldMetaData_init(arr[2])
retval4b = UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_INT32].typeId,
                arr[2].dataType)
@test retval4b == UA_STATUSCODE_GOOD
arr[2].builtInType = UA_NS0ID_INT32
arr[2].name =  UA_String_fromChars("Int32")
arr[2].valueRank = -1 # scalar

# Int64 DataType
UA_FieldMetaData_init(arr[3])
retval5a = UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_INT64].typeId,
                arr[3].dataType)
@test retval5a == UA_STATUSCODE_GOOD
arr[3].builtInType = UA_NS0ID_INT64
arr[3].name =  UA_String_fromChars("Int64")
arr[3].valueRank = -1 # scalar

# Boolean DataType
UA_FieldMetaData_init(arr[4]);
retval5b = UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_BOOLEAN].typeId,
                arr[4].dataType)
@test retval5b == UA_STATUSCODE_GOOD
arr[4].builtInType = UA_NS0ID_BOOLEAN
arr[4].name =  UA_STRING("BoolToggle")
arr[4].valueRank = -1 # scalar

retval5 = UA_Server_addDataSetReader(server, readerGroupIdentifier, readerConfig,
    readerIdentifier)
@test retval6 == UA_STATUSCODE_GOOD

#add Object to server
folderId = UA_NodeId_new()
displayname = "Subscribed Variables"
description = "Subscribed Variables"
oAttr = JUA_ObjectAttributes(displayname = displayname, description = description)
folderBrowseName = JUA_QualifiedName(1, displayname)

retval7 = JUA_Server_addNode(server, JUA_NodeId(), JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER), 
    JUA_NodeId(0, UA_NS0ID_ORGANIZES), folderBrowseName, oAttr, C_NULL, folderId, 
    JUA_NodeId(0, UA_NS0ID_BASEOBJECTTYPE))
@test retval7 == UA_STATUSCODE_GOOD

# Create the TargetVariables with respect to DataSetMetaData fields
fieldSize = Int64(unsafe_load(readerConfig.dataSetMetaData.fieldsSize))
fields = UA_Array(unsafe_load(readerConfig.dataSetMetaData.fields), fieldSize)
ptr = Libc.malloc(fieldSize*sizeof(UA_FieldTargetVariable))
ptr_typed = convert(Ptr{UA_FieldTargetVariable}, ptr)
targetVars = UA_Array(ptr_typed, fieldSize)
UA_Array_init(targetVars)

for i in 1:fieldSize
    # Variable to subscribe data
    vAttr = UA_VariableAttributes_new()
    UA_VariableAttributes_copy(UA_VariableAttributes_default, vAttr)
    UA_LocalizedText_copy(fields[i].description, vAttr.description)
    vAttr.displayName.locale = UA_STRING("en-US")
    vAttr.displayName.text = fields[i].name
    vAttr.dataType = fields[i].dataType
    jvAttr = JUA_VariableAttributes(vAttr)

    newNode = JUA_NodeId(1, 50000+i)
    browseName = JUA_QualifiedName(1, unsafe_string(fields[i].name))
    retval7 = JUA_Server_addNode(server, newNode, folderId, 
        JUA_NodeId(0, UA_NS0ID_HASCOMPONENT), browseName, jvAttr, 
        JUA_NodeId(), JUA_NodeId(), JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE))
    @test retval7 == UA_STATUSCODE_GOOD

    #For creating Targetvariables
    targetVars[i].targetVariable.attributeId  = UA_ATTRIBUTEID_VALUE
    targetVars[i].targetVariable.targetNodeId = newNode
end

retval8 = UA_Server_DataSetReader_createTargetVariables(server, readerIdentifier, fieldSize, 
    targetVars)

for i in 1:fieldSize
    UA_FieldTargetDataType_clear(targetVars[i].targetVariable)
end

Libc.free(targetVars)
