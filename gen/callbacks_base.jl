#Purpose: File will be used to define callbacks (via @cfunction) used across open62541
#includes generator functions and very simple prototypes as illustrations.

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
```
"""
function UA_NodeTypeLifecycle_constructor_generate(constructor::Function)
    input_argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}})
    if hasmethod(constructor, input_argtuple)
        callback = @cfunction($constructor,
            UA_StatusCode,
            (Ptr{UA_Server},
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
```
"""
function UA_NodeTypeLifecycle_destructor_generate(destructor::Function)
    input_argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}})
    if hasmethod(destructor, input_argtuple)
        callback = @cfunction($destructor,
            Cvoid,
            (Ptr{UA_Server},
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
UA_MethodCallback_generate(method::Function)
```
creates a `UA_MethodCallback` that can be attached to a method node using
`UA_Server_addMethodNode`.

`method` must be a Julia function with the following signature:
```method(server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId}), sessionContext::Ptr{Cvoid}`,  methodId::Ptr{UA_NodeId}, methodContext::Ptr{Cvoid}, objectId::Ptr{UA_NodeId},  objectContext::Ptr{Cvoid}, inputSize::Csize_t, input::Ptr{UA_Variant},  outputSize::Csize_t, output::Ptr{UA_Variant})::UA_StatusCode```
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

#TODO: Callbacks for which no generators have been implemented yet:
# struct UA_ValueCallback
#     onRead::Ptr{Cvoid}
#     onWrite::Ptr{Cvoid}
# end
# void (*onWrite)(UA_Server *server, const UA_NodeId *sessionId,
#                     void *sessionContext, const UA_NodeId *nodeId,
#                     void *nodeContext, const UA_NumericRange *range,
#                     const UA_DataValue *data);

# void (*onRead)(UA_Server *server, const UA_NodeId *sessionId,
# void *sessionContext, const UA_NodeId *nodeid,
# void *nodeContext, const UA_NumericRange *range,
# const UA_DataValue *value);


# struct UA_DataSource
#     read::Ptr{Cvoid}
#     write::Ptr{Cvoid}
# end
# UA_StatusCode (*write)(UA_Server *server, const UA_NodeId *sessionId,
#                            void *sessionContext, const UA_NodeId *nodeId,
#                            void *nodeContext, const UA_NumericRange *range,
#                            const UA_DataValue *value);
# UA_StatusCode (*read)(UA_Server *server, const UA_NodeId *sessionId,
# void *sessionContext, const UA_NodeId *nodeId,
# void *nodeContext, UA_Boolean includeSourceTimeStamp,
# const UA_NumericRange *range, UA_DataValue *value);

# typedef void ( * UA_ServerCallback ) ( UA_Server * server , void * data )
# typedef void ( * UA_ClientCallback ) ( UA_Client * client , void * data )

# # typedef void ( * UA_Server_AsyncOperationNotifyCallback ) ( UA_Server * server )
# # typedef UA_Connection ( * UA_ConnectClientConnection ) ( UA_ConnectionConfig config , UA_String endpointUrl , UA_UInt32 timeout , const UA_Logger * logger )

# # typedef void ( * UA_NodestoreVisitor ) ( void * visitorCtx , const UA_Node * node )

# # typedef UA_StatusCode ( * UA_NodeIteratorCallback ) ( UA_NodeId childId , UA_Boolean isInverse , UA_NodeId referenceTypeId , void * handle )
# # typedef void ( * UA_Server_DataChangeNotificationCallback ) ( UA_Server * server , UA_UInt32 monitoredItemId , void * monitoredItemContext , const UA_NodeId * nodeId , void * nodeContext , UA_UInt32 attributeId , const UA_DataValue * value )
# # typedef void ( * UA_Server_EventNotificationCallback ) ( UA_Server * server , UA_UInt32 monId , void * monContext , size_t nEventFields , const UA_Variant * eventFields )
# # typedef void ( * UA_ClientAsyncServiceCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , void * response )
# # typedef UA_Boolean ( * UA_HistoricalIteratorCallback ) ( UA_Client * client , const UA_NodeId * nodeId , UA_Boolean moreDataAvailable , const UA_ExtensionObject * data , void * callbackContext )
# # typedef void ( * UA_Client_DeleteSubscriptionCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext )
# # typedef void ( * UA_Client_StatusChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_StatusChangeNotification * notification )
# # typedef void ( * UA_Client_DeleteMonitoredItemCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext )
# # typedef void ( * UA_Client_DataChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , UA_DataValue * value )
# # typedef void ( * UA_Client_EventNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , size_t nEventFields , UA_Variant * eventFields )
# # typedef void ( * UA_ClientAsyncReadCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_ReadResponse * rr )
# # typedef void ( * UA_ClientAsyncWriteCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_WriteResponse * wr )
# # typedef void ( * UA_ClientAsyncBrowseCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_BrowseResponse * wr )
# # typedef void ( * UA_ClientAsyncOperationCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , void * result )
# # typedef void ( * UA_ClientAsyncCallCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_CallResponse * cr )
# # typedef void ( * UA_ClientAsyncAddNodesCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_AddNodesResponse * ar )
# # typedef UA_StatusCode ( * UA_UsernamePasswordLoginCallback ) ( const UA_String * userName , const UA_ByteString * password , size_t usernamePasswordLoginSize , const UA_UsernamePasswordLogin * usernamePasswordLogin , void * * sessionContext , void * loginContext )
