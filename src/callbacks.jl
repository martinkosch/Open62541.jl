#TODO: file will be used to define cfunction callbacks used across open62541
#includes generator functions and simplified prototypes.

"""
```
UA_NodeTypeLifeCycle_constructor_generate(constructor::Function)
```
creates a function pointer for the `constructor` field of a `UA_NodeTypeLifeCycle` 
object.

`constructor` must be a Julia function with the following signature:
```constructor(server::Ptr{UA_Server}, sessionId:: Ptr{UA_NodeId}, 
       sessionContext::Ptr{Cvoid}, typeNodeId::Ptr{UA_NodeId}, typeNodeContext::Ptr{Cvoid}, 
       nodeId::Ptr{UA_NodeId}, nodeContext::Ptr{Ptr{Cvoid}})::UA_StatusCode```
"""
function UA_NodeTypeLifecycle_constructor_generate(constructor::Function)
    input_argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}})
    if hasmethod(constructor, input_argtuple)
        callback = @cfunction($constructor, UA_StatusCode, (Ptr{UA_Server}, 
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, 
            Ptr{Ptr{Cvoid}}))
        return Base.unsafe_convert(Ptr{Cvoid}, callback)
    else
        err = CallbackGeneratorArgumentError(method, input_argtuple)
        throw(err)
    end
end

"""
```
UA_NodeTypeLifeCycle_destructor_generate(destructor::Function)
```
creates a function pointer for the `destructor` field of a `UA_NodeTypeLifeCycle` 
object.

`destructor` must be a Julia function with the following signature:
```destructor(server::Ptr{UA_Server}, sessionId:: Ptr{UA_NodeId}, 
       sessionContext::Ptr{Cvoid}, typeNodeId::Ptr{UA_NodeId}, typeNodeContext::Ptr{Cvoid}, 
       nodeId::Ptr{UA_NodeId}, nodeContext::Ptr{Ptr{Cvoid}})::Cvoid```
"""
function UA_NodeTypeLifecycle_destructor_generate(destructor::Function)
    input_argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}})
    if hasmethod(destructor, input_argtuple)
        callback = @cfunction($destructor, Cvoid, (Ptr{UA_Server}, 
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, 
            Ptr{Ptr{Cvoid}}))
        return Base.unsafe_convert(Ptr{Cvoid}, callback)
    else
        err = CallbackGeneratorArgumentError(method, input_argtuple)
        throw(err)    
    end
end

# struct UA_ValueCallback
#     onRead::Ptr{Cvoid}
#     onWrite::Ptr{Cvoid}
# end

# struct UA_DataSource
#     read::Ptr{Cvoid}
#     write::Ptr{Cvoid}
# end

# typedef void ( * UA_ServerCallback ) ( UA_Server * server , void * data )
#const UA_ServerCallback = Ptr{Cvoid}

"""
```
UA_MethodCallback_generate(method::Function)
```
creates a `UA_MethodCallback` that can be attached to a method node using 
`UA_Server_addMethodNode`. 

`method` must be a Julia function with the following signature:
```method(server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId}), sessionContext::Ptr{Cvoid}`, 
       methodId::Ptr{UA_NodeId}, methodContext::Ptr{Cvoid}, objectId::Ptr{UA_NodeId}, 
       objectContext::Ptr{Cvoid}, inputSize::Csize_t, input::Ptr{UA_Variant}, 
       outputSize::Csize_t, output::Ptr{UA_Variant})::UA_StatusCode```
"""
function UA_MethodCallback_generate(method::Function)
    input_argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, 
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Csize_t, Ptr{UA_Variant}, 
        Csize_t, Ptr{UA_Variant})
    if hasmethod(method, input_argtuple)
        callback = @cfunction($method, UA_StatusCode, 
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, 
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, 
            Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant})) 
        return callback
    else
        err = CallbackGeneratorArgumentError(method, input_argtuple)
        throw(err)
    end
end

# # typedef void ( * UA_Server_AsyncOperationNotifyCallback ) ( UA_Server * server )
# const UA_Server_AsyncOperationNotifyCallback = Ptr{Cvoid}

# # typedef UA_Connection ( * UA_ConnectClientConnection ) ( UA_ConnectionConfig config , UA_String endpointUrl , UA_UInt32 timeout , const UA_Logger * logger )
# const UA_ConnectClientConnection = Ptr{Cvoid}

# # typedef void ( * UA_NodestoreVisitor ) ( void * visitorCtx , const UA_Node * node )
# const UA_NodestoreVisitor = Ptr{Cvoid}

# # typedef UA_StatusCode ( * UA_NodeIteratorCallback ) ( UA_NodeId childId , UA_Boolean isInverse , UA_NodeId referenceTypeId , void * handle )
# const UA_NodeIteratorCallback = Ptr{Cvoid}

# # typedef void ( * UA_Server_DataChangeNotificationCallback ) ( UA_Server * server , UA_UInt32 monitoredItemId , void * monitoredItemContext , const UA_NodeId * nodeId , void * nodeContext , UA_UInt32 attributeId , const UA_DataValue * value )
# const UA_Server_DataChangeNotificationCallback = Ptr{Cvoid}

# # typedef void ( * UA_Server_EventNotificationCallback ) ( UA_Server * server , UA_UInt32 monId , void * monContext , size_t nEventFields , const UA_Variant * eventFields )
# const UA_Server_EventNotificationCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncServiceCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , void * response )
# const UA_ClientAsyncServiceCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientCallback ) ( UA_Client * client , void * data )
# const UA_ClientCallback = Ptr{Cvoid}

# # typedef UA_Boolean ( * UA_HistoricalIteratorCallback ) ( UA_Client * client , const UA_NodeId * nodeId , UA_Boolean moreDataAvailable , const UA_ExtensionObject * data , void * callbackContext )
# const UA_HistoricalIteratorCallback = Ptr{Cvoid}

# # typedef void ( * UA_Client_DeleteSubscriptionCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext )
# const UA_Client_DeleteSubscriptionCallback = Ptr{Cvoid}

# # typedef void ( * UA_Client_StatusChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_StatusChangeNotification * notification )
# const UA_Client_StatusChangeNotificationCallback = Ptr{Cvoid}

# # typedef void ( * UA_Client_DeleteMonitoredItemCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext )
# const UA_Client_DeleteMonitoredItemCallback = Ptr{Cvoid}

# # typedef void ( * UA_Client_DataChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , UA_DataValue * value )
# const UA_Client_DataChangeNotificationCallback = Ptr{Cvoid}

# # typedef void ( * UA_Client_EventNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , size_t nEventFields , UA_Variant * eventFields )
# const UA_Client_EventNotificationCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_ReadResponse * rr )
# const UA_ClientAsyncReadCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncWriteCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_WriteResponse * wr )
# const UA_ClientAsyncWriteCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncBrowseCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_BrowseResponse * wr )
# const UA_ClientAsyncBrowseCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncOperationCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , void * result )
# const UA_ClientAsyncOperationCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_DataValue * attribute )
# const UA_ClientAsyncReadAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadValueAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_DataValue * value )
# const UA_ClientAsyncReadValueAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadDataTypeAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_NodeId * dataType )
# const UA_ClientAsyncReadDataTypeAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientReadArrayDimensionsAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Variant * arrayDimensions )
# const UA_ClientReadArrayDimensionsAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadNodeClassAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_NodeClass * nodeClass )
# const UA_ClientAsyncReadNodeClassAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadBrowseNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_QualifiedName * browseName )
# const UA_ClientAsyncReadBrowseNameAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadDisplayNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_LocalizedText * displayName )
# const UA_ClientAsyncReadDisplayNameAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadDescriptionAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_LocalizedText * description )
# const UA_ClientAsyncReadDescriptionAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadWriteMaskAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_UInt32 * writeMask )
# const UA_ClientAsyncReadWriteMaskAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadUserWriteMaskAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_UInt32 * writeMask )
# const UA_ClientAsyncReadUserWriteMaskAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadIsAbstractAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * isAbstract )
# const UA_ClientAsyncReadIsAbstractAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadSymmetricAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * symmetric )
# const UA_ClientAsyncReadSymmetricAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadInverseNameAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_LocalizedText * inverseName )
# const UA_ClientAsyncReadInverseNameAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadContainsNoLoopsAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * containsNoLoops )
# const UA_ClientAsyncReadContainsNoLoopsAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadEventNotifierAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Byte * eventNotifier )
# const UA_ClientAsyncReadEventNotifierAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadValueRankAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Int32 * valueRank )
# const UA_ClientAsyncReadValueRankAttributeCallback = Ptr{Cvoid}


# # typedef void ( * UA_ClientAsyncReadAccessLevelAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Byte * accessLevel )
# const UA_ClientAsyncReadAccessLevelAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadUserAccessLevelAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Byte * userAccessLevel )
# const UA_ClientAsyncReadUserAccessLevelAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Double * minimumSamplingInterval )
# const UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadHistorizingAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * historizing )
# const UA_ClientAsyncReadHistorizingAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadExecutableAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * executable )
# const UA_ClientAsyncReadExecutableAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncReadUserExecutableAttributeCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , UA_Boolean * userExecutable )
# const UA_ClientAsyncReadUserExecutableAttributeCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncCallCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_CallResponse * cr )
# const UA_ClientAsyncCallCallback = Ptr{Cvoid}

# # typedef void ( * UA_ClientAsyncAddNodesCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_AddNodesResponse * ar )
# const UA_ClientAsyncAddNodesCallback = Ptr{Cvoid}

# # typedef UA_StatusCode ( * UA_UsernamePasswordLoginCallback ) ( const UA_String * userName , const UA_ByteString * password , size_t usernamePasswordLoginSize , const UA_UsernamePasswordLogin * usernamePasswordLogin , void * * sessionContext , void * loginContext )
# const UA_UsernamePasswordLoginCallback = Ptr{Cvoid}
