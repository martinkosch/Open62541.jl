# Purpose: Tests basic publish/subscribe (Pubsub) functionality

#based on: https://www.open62541.org/doc/v1.4.10/tutorial_pubsub_publish.html

using Open62541, Test

#create server
server = JUA_Server()

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
