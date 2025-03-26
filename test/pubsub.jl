# Purpose: Tests basic publish/subscribe (Pubsub) functionality

#based on: https://www.open62541.org/doc/v1.4.10/tutorial_pubsub_publish.html
#and       https://www.open62541.org/doc/v1.4.10/tutorial_pubsub_subscribe.html

using Open62541, Test

#first part, based on: https://www.open62541.org/doc/v1.4.10/tutorial_pubsub_publish.html
#create server
server = UA_Server_new()

#add a pubsubconnection
ref = Ref{UA_PubSubConnectionConfig}()
connectionConfig = convert(Ptr{UA_PubSubConnectionConfig}, pointer_from_objref(ref))
UA_init(connectionConfig)

connectionConfig.name = UA_STRING("UDP-UADP Connection 1")
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

#add published dataset
ref = Ref{UA_PublishedDataSetConfig}()
publishedDataSetConfig = convert(Ptr{UA_PublishedDataSetConfig}, pointer_from_objref(ref))
UA_init(connectionConfig)
publishedDataSetConfig.publishedDataSetType = UA_PUBSUB_DATASET_PUBLISHEDITEMS
publishedDataSetConfig.name = UA_STRING("Demo PDS")
publishedDataSetIdentifier = UA_NodeId_new()
res = UA_Server_addPublishedDataSet(server, publishedDataSetConfig, publishedDataSetIdentifier)
@test res.addResult == UA_STATUSCODE_GOOD

#add dataset field
dataSetFieldIdentifier = UA_NodeId_new()
ref = Ref{UA_DataSetFieldConfig}()
dataSetFieldConfig = convert(Ptr{UA_DataSetFieldConfig}, pointer_from_objref(ref))
UA_init(dataSetFieldConfig)
dataSetFieldConfig.dataSetFieldType = UA_PUBSUB_DATASETFIELD_VARIABLE
dataSetFieldConfig.field.variable.fieldNameAlias = UA_STRING("Server localtime")
dataSetFieldConfig.field.variable.promotedField = UA_FALSE
dataSetFieldConfig.field.variable.publishParameters.publishedVariable =
    UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)
dataSetFieldConfig.field.variable.publishParameters.attributeId = UA_ATTRIBUTEID_VALUE
res = UA_Server_addDataSetField(server, publishedDataSetIdentifier,
                            dataSetFieldConfig, dataSetFieldIdentifier) 
@test res.result == UA_STATUSCODE_GOOD

#add writer group
writerGroupIdentifier = UA_NodeId_new()
ref = Ref{UA_WriterGroupConfig}()
writerGroupConfig = convert(Ptr{UA_WriterGroupConfig}, pointer_from_objref(ref))
UA_init(writerGroupConfig)
writerGroupConfig.name = UA_STRING("Demo WriterGroup")
writerGroupConfig.publishingInterval = 100
writerGroupConfig.enabled = UA_FALSE
writerGroupConfig.writerGroupId = 100
writerGroupConfig.encodingMimeType = UA_PUBSUB_ENCODING_UADP
writerGroupConfig.messageSettings.encoding             = UA_EXTENSIONOBJECT_DECODED
writerGroupConfig.messageSettings.content.decoded.type = UA_TYPES_PTRS[UA_TYPES_UADPWRITERGROUPMESSAGEDATATYPE]
writerGroupMessage  = UA_UadpWriterGroupMessageDataType_new()
writerGroupMessage.networkMessageContentMask = UA_UADPNETWORKMESSAGECONTENTMASK_PUBLISHERID | UA_UADPNETWORKMESSAGECONTENTMASK_GROUPHEADER | UA_UADPNETWORKMESSAGECONTENTMASK_WRITERGROUPID | UA_UADPNETWORKMESSAGECONTENTMASK_PAYLOADHEADER
writerGroupConfig.messageSettings.content.decoded.data = writerGroupMessage
retval2 = UA_Server_addWriterGroup(server, connectionIdentifier, writerGroupConfig, writerGroupIdentifier)
@test retval2 == UA_STATUSCODE_GOOD
retval3 = UA_Server_setWriterGroupOperational(server, writerGroupIdentifier)
@test retval3 == UA_STATUSCODE_GOOD

#add data set writer
dataSetWriterIdentifier = UA_NodeId_new()
ref = Ref{UA_DataSetWriterConfig}()
dataSetWriterConfig = convert(Ptr{UA_DataSetWriterConfig}, pointer_from_objref(ref))
UA_init(dataSetWriterConfig)
dataSetWriterConfig.name = UA_STRING("Demo DataSetWriter")
dataSetWriterConfig.dataSetWriterId = 62541
dataSetWriterConfig.keyFrameCount = 10
retval4 = UA_Server_addDataSetWriter(server, writerGroupIdentifier, publishedDataSetIdentifier,
                            dataSetWriterConfig, dataSetWriterIdentifier)
@test retval4 == UA_STATUSCODE_GOOD 

#second part, based on: https://www.open62541.org/doc/v1.4.10/tutorial_pubsub_subscribe.html

#add readergroup 
readerGroupIdentifier = UA_NodeId_new()
ref = Ref{UA_ReaderGroupConfig}()
readerGroupConfig = convert(Ptr{UA_ReaderGroupConfig}, pointer_from_objref(ref))
UA_init(readerGroupConfig)
readerGroupConfig.name = UA_STRING("ReaderGroup1")
retval5 = UA_Server_addReaderGroup(server, connectionIdentifier, readerGroupConfig,
                                       readerGroupIdentifier)
@test retval5 == UA_STATUSCODE_GOOD
retval6 = UA_Server_setReaderGroupOperational(server, readerGroupIdentifier)
@test retval6 == UA_STATUSCODE_GOOD

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
retval7a = UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_DATETIME].typeId,
                arr[1].dataType)
@test retval7a == UA_STATUSCODE_GOOD
arr[1].builtInType = UA_NS0ID_DATETIME
arr[1].name =  UA_String_fromChars("DateTime")
arr[1].valueRank = -1 # scalar

# Int32 DataType 
UA_FieldMetaData_init(arr[2])
retval7b = UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_INT32].typeId,
                arr[2].dataType)
@test retval7b == UA_STATUSCODE_GOOD
arr[2].builtInType = UA_NS0ID_INT32
arr[2].name =  UA_String_fromChars("Int32")
arr[2].valueRank = -1 # scalar

# Int64 DataType
UA_FieldMetaData_init(arr[3])
UA_NodeId_copy(UA_TYPES_PTRS[UA_TYPES_INT32].typeId,
                arr[3].dataType)
arr[3].builtInType = UA_NS0ID_INT32
arr[3].name =  UA_String_fromChars("Int64")
arr[3].valueRank = -1 # scalar

# Boolean DataType
UA_FieldMetaData_init(&arr[4]);
UA_NodeId_copy (&UA_TYPES[UA_TYPES_BOOLEAN].typeId,
                &arr[4].dataType);
arr[4].builtInType = UA_NS0ID_BOOLEAN;
arr[4].name =  UA_STRING("BoolToggle");
arr[4].valueRank = -1; # scalar

retval8 = UA_Server_addDataSetReader(server, readerGroupIdentifier, readerConfig,
    readerIdentifier)
@test retval8 == UA_STATUSCODE_GOOD

#add Object to server
dataSetReaderId = UA_NodeId_new()
folderId = UA_NodeId_new()
displayname = "Subscribed Variables"
description = "Subscribed Variables"
oAttr = JUA_ObjectAttributes(displayname = displayname, description = description)
folderBrowseName = JUA_QualifiedName(1, displayname)
retval9 = JUA_Server_addNode(server, JUA_NodeId(), JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER), 
    JUA_NodeId(0, UA_NS0ID_ORGANIZES), folderBrowseName, oAttr, 
    JUA_NodeId(0, UA_NS0ID_BASEOBJECTTYPE), C_NULL, folderId)
@test retval9 == UA_STATUSCODE_GOOD

#TODO: from here on still work to do
/* Create the TargetVariables with respect to DataSetMetaData fields */
UA_FieldTargetVariable *targetVars = (UA_FieldTargetVariable *)
        UA_calloc(readerConfig.dataSetMetaData.fieldsSize, sizeof(UA_FieldTargetVariable));
for(size_t i = 0; i < readerConfig.dataSetMetaData.fieldsSize; i++) {
    /* Variable to subscribe data */
    UA_VariableAttributes vAttr = UA_VariableAttributes_default;
    UA_LocalizedText_copy(&readerConfig.dataSetMetaData.fields[i].description,
                          &vAttr.description);
    vAttr.displayName.locale = UA_STRING("en-US");
    vAttr.displayName.text = readerConfig.dataSetMetaData.fields[i].name;
    vAttr.dataType = readerConfig.dataSetMetaData.fields[i].dataType;

    UA_NodeId newNode;
    retval |= UA_Server_addVariableNode(server, UA_NODEID_NUMERIC(1, (UA_UInt32)i + 50000),
                                       folderId,
                                       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
                                       UA_QUALIFIEDNAME(1, (char *)readerConfig.dataSetMetaData.fields[i].name.data),
                                       UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
                                       vAttr, NULL, &newNode);

    /* For creating Targetvariables */
    UA_FieldTargetDataType_init(&targetVars[i].targetVariable);
    targetVars[i].targetVariable.attributeId  = UA_ATTRIBUTEID_VALUE;
    targetVars[i].targetVariable.targetNodeId = newNode;
}

retval = UA_Server_DataSetReader_createTargetVariables(server, dataSetReaderId,
                                                       readerConfig.dataSetMetaData.fieldsSize, targetVars);
for(size_t i = 0; i < readerConfig.dataSetMetaData.fieldsSize; i++)
    UA_FieldTargetDataType_clear(&targetVars[i].targetVariable);

#UA_free(targetVars);
#UA_free(readerConfig.dataSetMetaData.fields);


#memory clean up; TODO: complete this section.
UA_UadpWriterGroupMessageDataType_delete(writerGroupMessage) 
