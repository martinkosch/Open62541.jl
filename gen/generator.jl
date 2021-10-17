using Clang.Generators
using open62541_jll

cd(@__DIR__)

include_dir = joinpath(open62541_jll.artifact_dir, "include") |> normpath
open62541_header = joinpath(include_dir, "open62541.h") |> normpath
@assert isfile(open62541_header)

function write_generated_defs(generated_defs_dir::String, open62541_header::String)
    type_s = """
    # Vector of all UA types; Generated with: type_names = [Symbol("UA_", unsafe_string(unsafe_load(type_ptr).typeName)) for type_ptr in UA_TYPES_PTRS] TODO: Automate this step
    const type_names = Symbol[:UA_Boolean, :UA_SByte, :UA_Byte, :UA_Int16, :UA_UInt16, :UA_Int32, :UA_UInt32, :UA_Int64, :UA_UInt64, :UA_Float, :UA_Double, :UA_String, :UA_DateTime, :UA_Guid, :UA_ByteString, :UA_XmlElement, :UA_NodeId, :UA_ExpandedNodeId, :UA_StatusCode, :UA_QualifiedName, :UA_LocalizedText, :UA_ExtensionObject, :UA_DataValue, :UA_Variant, :UA_DiagnosticInfo, :UA_ViewAttributes, :UA_XVType, :UA_ElementOperand, :UA_VariableAttributes, :UA_EnumValueType, :UA_EventFieldList, :UA_MonitoredItemCreateResult, :UA_EUInformation, :UA_ServerDiagnosticsSummaryDataType, :UA_ContentFilterElementResult, :UA_LiteralOperand, :UA_MessageSecurityMode, :UA_UtcTime, :UA_UserIdentityToken, :UA_X509IdentityToken, :UA_MonitoredItemNotification, :UA_StructureType, :UA_ResponseHeader, :UA_SignatureData, :UA_ModifySubscriptionResponse, :UA_NodeAttributes, :UA_ActivateSessionResponse, :UA_EnumField, :UA_VariableTypeAttributes, :UA_CallMethodResult, :UA_MonitoringMode, :UA_SetMonitoringModeResponse, :UA_BrowseResultMask, :UA_RequestHeader, :UA_MonitoredItemModifyResult, :UA_CloseSecureChannelRequest, :UA_NotificationMessage, :UA_CreateSubscriptionResponse, :UA_EnumDefinition, :UA_AxisScaleEnumeration, :UA_BrowseDirection, :UA_CallMethodRequest, :UA_ReadResponse, :UA_TimestampsToReturn, :UA_NodeClass, :UA_ObjectTypeAttributes, :UA_SecurityTokenRequestType, :UA_CloseSessionResponse, :UA_SetPublishingModeRequest, :UA_IssuedIdentityToken, :UA_DeleteMonitoredItemsResponse, :UA_ApplicationType, :UA_BrowseNextRequest, :UA_ModifySubscriptionRequest, :UA_BrowseDescription, :UA_SignedSoftwareCertificate, :UA_BrowsePathTarget, :UA_WriteResponse, :UA_AddNodesResult, :UA_AddReferencesItem, :UA_DeleteReferencesResponse, :UA_RelativePathElement, :UA_SubscriptionAcknowledgement, :UA_TransferResult, :UA_CreateMonitoredItemsResponse, :UA_DeleteReferencesItem, :UA_WriteValue, :UA_DataTypeAttributes, :UA_TransferSubscriptionsResponse, :UA_AddReferencesResponse, :UA_DeadbandType, :UA_DataChangeTrigger, :UA_BuildInfo, :UA_FilterOperand, :UA_MonitoringParameters, :UA_DoubleComplexNumberType, :UA_DeleteNodesItem, :UA_ReadValueId, :UA_CallRequest, :UA_RelativePath, :UA_DeleteNodesRequest, :UA_MonitoredItemModifyRequest, :UA_UserTokenType, :UA_AggregateConfiguration, :UA_LocaleId, :UA_UnregisterNodesResponse, :UA_ContentFilterResult, :UA_UserTokenPolicy, :UA_DeleteMonitoredItemsRequest, :UA_SetMonitoringModeRequest, :UA_Duration, :UA_ReferenceTypeAttributes, :UA_GetEndpointsRequest, :UA_CloseSecureChannelResponse, :UA_ViewDescription, :UA_SetPublishingModeResponse, :UA_StatusChangeNotification, :UA_StructureField, :UA_NodeAttributesMask, :UA_EventFilterResult, :UA_MonitoredItemCreateRequest, :UA_ComplexNumberType, :UA_Range, :UA_DataChangeNotification, :UA_Argument, :UA_TransferSubscriptionsRequest, :UA_ChannelSecurityToken, :UA_ServerState, :UA_EventNotificationList, :UA_AnonymousIdentityToken, :UA_FilterOperator, :UA_AggregateFilter, :UA_RepublishResponse, :UA_DeleteSubscriptionsResponse, :UA_RegisterNodesRequest, :UA_StructureDefinition, :UA_MethodAttributes, :UA_UserNameIdentityToken, :UA_UnregisterNodesRequest, :UA_OpenSecureChannelResponse, :UA_SetTriggeringResponse, :UA_SimpleAttributeOperand, :UA_RepublishRequest, :UA_RegisterNodesResponse, :UA_ModifyMonitoredItemsResponse, :UA_DeleteSubscriptionsRequest, :UA_RedundancySupport, :UA_BrowsePath, :UA_ObjectAttributes, :UA_PublishRequest, :UA_FindServersRequest, :UA_ReferenceDescription, :UA_CreateSubscriptionRequest, :UA_CallResponse, :UA_DeleteNodesResponse, :UA_ModifyMonitoredItemsRequest, :UA_ServiceFault, :UA_PublishResponse, :UA_CreateMonitoredItemsRequest, :UA_OpenSecureChannelRequest, :UA_CloseSessionRequest, :UA_SetTriggeringRequest, :UA_BrowseResult, :UA_AddReferencesRequest, :UA_AddNodesItem, :UA_ServerStatusDataType, :UA_BrowseNextResponse, :UA_AxisInformation, :UA_ApplicationDescription, :UA_ReadRequest, :UA_ActivateSessionRequest, :UA_BrowsePathResult, :UA_AddNodesRequest, :UA_BrowseRequest, :UA_WriteRequest, :UA_AddNodesResponse, :UA_AttributeOperand, :UA_DataChangeFilter, :UA_EndpointDescription, :UA_DeleteReferencesRequest, :UA_TranslateBrowsePathsToNodeIdsRequest, :UA_FindServersResponse, :UA_CreateSessionRequest, :UA_ContentFilterElement, :UA_TranslateBrowsePathsToNodeIdsResponse, :UA_BrowseResponse, :UA_CreateSessionResponse, :UA_ContentFilter, :UA_GetEndpointsResponse, :UA_EventFilter]
    
    # Julia types corresponding to the UA types in vector type_names
    const julia_types = DataType[Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, UA_String, Int64, UA_Guid, UA_String, UA_String, UA_NodeId, UA_ExpandedNodeId, UInt32, UA_QualifiedName, UA_LocalizedText, UA_ExtensionObject, UA_DataValue, UA_Variant, UA_DiagnosticInfo, UA_ViewAttributes, UA_XVType, UA_ElementOperand, UA_VariableAttributes, UA_EnumValueType, UA_EventFieldList, UA_MonitoredItemCreateResult, UA_EUInformation, UA_ServerDiagnosticsSummaryDataType, UA_ContentFilterElementResult, UA_LiteralOperand, UA_MessageSecurityMode, Int64, UA_UserIdentityToken, UA_X509IdentityToken, UA_MonitoredItemNotification, UA_StructureType, UA_ResponseHeader, UA_SignatureData, UA_ModifySubscriptionResponse, UA_NodeAttributes, UA_ActivateSessionResponse, UA_EnumField, UA_VariableTypeAttributes, UA_CallMethodResult, UA_MonitoringMode, UA_SetMonitoringModeResponse, UA_BrowseResultMask, UA_RequestHeader, UA_MonitoredItemModifyResult, UA_CloseSecureChannelRequest, UA_NotificationMessage, UA_CreateSubscriptionResponse, UA_EnumDefinition, UA_AxisScaleEnumeration, UA_BrowseDirection, UA_CallMethodRequest, UA_ReadResponse, UA_TimestampsToReturn, UA_NodeClass, UA_ObjectTypeAttributes, UA_SecurityTokenRequestType, UA_CloseSessionResponse, UA_SetPublishingModeRequest, UA_IssuedIdentityToken, UA_DeleteMonitoredItemsResponse, UA_ApplicationType, UA_BrowseNextRequest, UA_ModifySubscriptionRequest, UA_BrowseDescription, UA_SignedSoftwareCertificate, UA_BrowsePathTarget, UA_WriteResponse, UA_AddNodesResult, UA_AddReferencesItem, UA_DeleteReferencesResponse, UA_RelativePathElement, UA_SubscriptionAcknowledgement, UA_TransferResult, UA_CreateMonitoredItemsResponse, UA_DeleteReferencesItem, UA_WriteValue, UA_DataTypeAttributes, UA_TransferSubscriptionsResponse, UA_AddReferencesResponse, UA_DeadbandType, UA_DataChangeTrigger, UA_BuildInfo, Ptr{Nothing}, UA_MonitoringParameters, UA_DoubleComplexNumberType, UA_DeleteNodesItem, UA_ReadValueId, UA_CallRequest, UA_RelativePath, UA_DeleteNodesRequest, UA_MonitoredItemModifyRequest, UA_UserTokenType, UA_AggregateConfiguration, UA_String, UA_UnregisterNodesResponse, UA_ContentFilterResult, UA_UserTokenPolicy, UA_DeleteMonitoredItemsRequest, UA_SetMonitoringModeRequest, Float64, UA_ReferenceTypeAttributes, UA_GetEndpointsRequest, UA_CloseSecureChannelResponse, UA_ViewDescription, UA_SetPublishingModeResponse, UA_StatusChangeNotification, UA_StructureField, UA_NodeAttributesMask, UA_EventFilterResult, UA_MonitoredItemCreateRequest, UA_ComplexNumberType, UA_Range, UA_DataChangeNotification, UA_Argument, UA_TransferSubscriptionsRequest, UA_ChannelSecurityToken, UA_ServerState, UA_EventNotificationList, UA_AnonymousIdentityToken, UA_FilterOperator, UA_AggregateFilter, UA_RepublishResponse, UA_DeleteSubscriptionsResponse, UA_RegisterNodesRequest, UA_StructureDefinition, UA_MethodAttributes, UA_UserNameIdentityToken, UA_UnregisterNodesRequest, UA_OpenSecureChannelResponse, UA_SetTriggeringResponse, UA_SimpleAttributeOperand, UA_RepublishRequest, UA_RegisterNodesResponse, UA_ModifyMonitoredItemsResponse, UA_DeleteSubscriptionsRequest, UA_RedundancySupport, UA_BrowsePath, UA_ObjectAttributes, UA_PublishRequest, UA_FindServersRequest, UA_ReferenceDescription, UA_CreateSubscriptionRequest, UA_CallResponse, UA_DeleteNodesResponse, UA_ModifyMonitoredItemsRequest, UA_ServiceFault, UA_PublishResponse, UA_CreateMonitoredItemsRequest, UA_OpenSecureChannelRequest, UA_CloseSessionRequest, UA_SetTriggeringRequest, UA_BrowseResult, UA_AddReferencesRequest, UA_AddNodesItem, UA_ServerStatusDataType, UA_BrowseNextResponse, UA_AxisInformation, UA_ApplicationDescription, UA_ReadRequest, UA_ActivateSessionRequest, UA_BrowsePathResult, UA_AddNodesRequest, UA_BrowseRequest, UA_WriteRequest, UA_AddNodesResponse, UA_AttributeOperand, UA_DataChangeFilter, UA_EndpointDescription, UA_DeleteReferencesRequest, UA_TranslateBrowsePathsToNodeIdsRequest, UA_FindServersResponse, UA_CreateSessionRequest, UA_ContentFilterElement, UA_TranslateBrowsePathsToNodeIdsResponse, UA_BrowseResponse, UA_CreateSessionResponse, UA_ContentFilter, UA_GetEndpointsResponse, UA_EventFilter]
    
    # Vector of types that are ambiguously defined via typedef and are not to be used as default type
    types_ambiguous_denylist = [:UA_Duration, :UA_ByteString, :UA_XmlElement, :UA_LocaleId, :UA_DateTime, :UA_UtcTime, :UA_StatusCode] 

    """
    
    inlined_funcs = """

    # Vector of all inlined function names listed in the amalgamated open62541 header file
    const inlined_funcs = $(extract_inlined_funcs(open62541_header))
    """

    data_UA_Client_read__attribute = """

    # UA_Client_ functions data
    const attributes_UA_Client_Service = $(extract_header_data(r"\s(UA_Client_Service_(\w*))\((?:[\s\S]*?)\)(?:[\s\S]*?)UA_\S*", open62541_header))
    
    const attributes_UA_Client_read = $(extract_header_data(r"\s(UA_Client_read(\w*)Attribute)\((?:[\s\S]*?,\s*){2}(\S*)", open62541_header))
    """

    open(generated_defs_dir, "w") do f
        write(f, type_s)
        write(f, inlined_funcs)
        write(f, data_UA_Client_read__attribute)
    end
end

function extract_inlined_funcs(open62541_header::String)
    regex_inlined = r"UA_INLINE[\s]+(?:[\w\*]+[\s]*[\s\S]){0,3}((?:__)?UA_[\w]+)\("
    inlined_funcs = String[]
    open(open62541_header, "r") do f
        data = read(f, String)
        append!(inlined_funcs, vcat(getfield.(collect(eachmatch(regex_inlined, data)), :captures)...)) # Extract inlined functions from header file
    end
    return inlined_funcs
end

function extract_header_data(regex::Regex, open62541_header::String)
    f = open(open62541_header, "r")
    data = read(f, String)
    close(f)
    all_data = getfield.(collect(eachmatch(regex, data)), :captures) # Extract inlined functions from header file
    return all_data
end

# Write static definitions to file generated_defs.jl
write_generated_defs(joinpath(@__DIR__, "../src/generated_defs.jl"), open62541_header)

# Load options from generator.toml
options = load_options(joinpath(@__DIR__, "generator.toml"))

# Extract all inlined functions and move them to codegen denylist
append!(options["general"]["printer_denylist"], extract_inlined_funcs(open62541_header))

# Add compiler flags
args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "-std=c99")

# Create context
ctx = create_context([open62541_header], args, options)

# Run generator
build!(ctx)