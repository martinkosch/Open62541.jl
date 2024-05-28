# Simple checks whether addition of different node types was successful or not
# Closely follows https://www.open62541.org/doc/1.3/tutorial_server_variabletype.html

using open62541
using Test
using Pkg.BinaryPlatforms

#configure server
server = JUA_Server()
retval0 = JUA_ServerConfig_setMinimalCustomBuffer(JUA_ServerConfig(server),
    4842, C_NULL, 0, 0)
@test retval0 == UA_STATUSCODE_GOOD

## Variable nodes with scalar and array floats - other number types are tested 
## in add_change_var_scalar.jl and add_change_var_array.jl

#Variable node: scalar
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
input = rand(Float64)
attr = JUA_VariableAttributes(value = input,
    displayname = "scalar variable",
    description = "this is a scalar variable",
    accesslevel = accesslevel)
varnodeid = JUA_NodeId(1, "scalar variable")
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_ORGANIZES)
typedefinition = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = JUA_QualifiedName(1, "scalar variable")
nodecontext = JUA_NodeId()
outnewnodeid = JUA_NodeId()

#UA interface
retval1 = JUA_Server_addNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, attr, nodecontext, outnewnodeid, typedefinition)
#test whether adding node to the server worked    
@test retval1 == UA_STATUSCODE_GOOD
# Test whether the correct array is within the server (read from server)
output_server = JUA_Server_readValue(server, varnodeid, Float64)
@test all(isapprox(input, output_server))

#Variable node: array
input = rand(Float64, 2, 3, 4)
varnodetext = "array variable"
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
attr = JUA_VariableAttributes(value = input,
    displayname = varnodetext,
    description = "this is an array variable",
    accesslevel = accesslevel)
varnodeid = JUA_NodeId(1, varnodetext)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_ORGANIZES)
typedefinition = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = JUA_QualifiedName(1, varnodetext)
nodecontext = JUA_NodeId()
outnewnodeid = JUA_NodeId()
retval2 = JUA_Server_addNode(server, varnodeid, parentnodeid,
    parentreferencenodeid, browsename, attr, nodecontext, outnewnodeid, 
    typedefinition)
# Test whether adding node to the server worked
@test retval2 == UA_STATUSCODE_GOOD
# Test whether the correct array is within the server (read from server)
output_server = JUA_Server_readValue(server, varnodeid, Array{Float64, 3})
@test all(isapprox(input, output_server))

## VariableTypeNode - array
input = zeros(2)
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "2D point type"
description = "This is a 2D point type."
attr = JUA_VariableTypeAttributes(value = input,
    displayname = displayname,
    description = description)
requestednewnodeid = JUA_NodeId()
parentnodeid = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
referencetypeid = JUA_NodeId(0, UA_NS0ID_HASSUBTYPE)
browsename = JUA_QualifiedName(1, "2DPoint Type")
nodecontext = JUA_NodeId()
pointtypeid = JUA_NodeId()
typedefinition = JUA_NodeId()

retval3 = JUA_Server_addNode(server, requestednewnodeid, parentnodeid,
    referencetypeid, browsename, attr, nodecontext, pointtypeid, typedefinition)

# Test whether adding the variable type node to the server worked
@test retval3 == UA_STATUSCODE_GOOD

#now add a variable node based on the variabletype node that we just defined.
input = rand(2)
pointvariableid1 = JUA_NodeId()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "a 2D point variable"
description = "This is a 2D point variable."
attr = JUA_VariableAttributes(value = input,
    displayname = displayname,
    description = description)
varnodeid = JUA_NodeId(1, varnodetext)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_ORGANIZES)
typedefinition = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = JUA_QualifiedName(1, "2DPoint variable")
nodecontext = JUA_NodeId()

retval4 = JUA_Server_addNode(server, JUA_NodeId(), parentnodeid,
    parentreferencenodeid, browsename, attr, nodecontext, pointvariableid1, 
    pointtypeid)
# Test whether adding the variable type node to the server worked
@test retval4 == UA_STATUSCODE_GOOD

#now attempt to add a node with the wrong dimensions 
input = rand(2, 3)
pointvariableid2 = JUA_NodeId()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "not a 2d point variable"
description = "This should fail"
attr = JUA_VariableAttributes(value = input,
    displayname = displayname,
    description = description)
parentnodeid = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
referencetypeid = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)
requestednewnodeid = JUA_NodeId()
browsename = JUA_QualifiedName(1, "2DPoint variable - wrong")
retval5 = JUA_Server_addNode(server, requestednewnodeid, parentnodeid, referencetypeid,
    browsename, attr, JUA_NodeId(), pointvariableid2, pointtypeid)

# Test whether adding the variable type node to the server worked
@test retval5 == UA_STATUSCODE_BADTYPEMISMATCH

#and now we just want to change value rank (which again shouldn't be allowed)
@test_throws open62541.AttributeReadWriteError UA_Server_writeValueRank(server,
    pointvariableid1,
    UA_VALUERANK_ONE_OR_MORE_DIMENSIONS)

#variable type node - scalar
input = 42
scalartypeid = JUA_NodeId()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "scalar integer type"
description = "This is a scalar integer type."
attr = JUA_VariableTypeAttributes(value = input,
    displayname = displayname,
    description = description)
parentnodeid = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
referencetypeid = JUA_NodeId(0, UA_NS0ID_HASSUBTYPE)
browsename = JUA_QualifiedName(1, "scalar integer type")
requestednewnodeid = JUA_NodeId()
nodecontext = JUA_NodeId()
typedefinition = JUA_NodeId()
retval6 = JUA_Server_addNode(server, requestednewnodeid,
    parentnodeid, referencetypeid,
    browsename, attr, nodecontext, scalartypeid, typedefinition)

# Test whether adding the variable type node to the server worked
@test retval6 == UA_STATUSCODE_GOOD

#add object node
#follows this tutorial page: https://www.open62541.org/doc/1.3/tutorial_server_object.html
pumpid = JUA_NodeId()
displayname = "Pump (Manual)"
description = "This is a manually added pump."
oAttr = JUA_ObjectAttributes(displayname = displayname, description = description)
requestednewnodeid = JUA_NodeId()
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
referencetypeid = JUA_NodeId(0, UA_NS0ID_ORGANIZES)
browsename = JUA_QualifiedName(1, displayname)
typedefinition = JUA_NodeId(0, UA_NS0ID_BASEOBJECTTYPE)
nodecontext = JUA_NodeId()
retval7 = JUA_Server_addNode(
    server, requestednewnodeid, parentnodeid, referencetypeid,
    browsename, oAttr, nodecontext, pumpid, typedefinition)
@test retval7 == UA_STATUSCODE_GOOD

#Define the object type for "Device"
pumpTypeId = JUA_NodeId(1, 1001)
deviceTypeId = JUA_NodeId()
dtAttr = JUA_ObjectTypeAttributes(displayname = "DeviceType",
    description = "Object type for a device")
browsename = JUA_QualifiedName(1, "DeviceType")
requestednewnodeid = JUA_NodeId()
parentnodeid = JUA_NodeId(0, UA_NS0ID_BASEOBJECTTYPE)
parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_HASSUBTYPE)
nodecontext = JUA_NodeId()
retval8 = JUA_Server_addNode(server, requestednewnodeid,
    parentnodeid, parentreferencenodeid,
    browsename, dtAttr,
    nodecontext, deviceTypeId)
@test retval8 == UA_STATUSCODE_GOOD

#add manufacturer name to device
mnAttr = JUA_VariableAttributes(value = "",
    displayname = "ManufacturerName",
    description = "Name of the manufacturer")
manufacturerNameId = JUA_NodeId()
requestedNewNodeid = JUA_NodeId()
referenceTypeId = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)
browseName = JUA_QualifiedName(1, "ManufacturerName")
typeDefinition = JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE)
nodeContext = JUA_NodeId()
retval9 = JUA_Server_addNode(server, requestedNewNodeid, deviceTypeId, 
    referenceTypeId, browseName, mnAttr, nodeContext, manufacturerNameId, typeDefinition)
@test retval9 == UA_STATUSCODE_GOOD

#TODO: would need to introduce JUA_ExpandedNodeId in highlevel_types.jl before revising this
#Make the manufacturer name mandatory
retval9 = UA_Server_addReference(server, manufacturerNameId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
    UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY), true)
@test retval9 == UA_STATUSCODE_GOOD

#Add model name
modelAttr = JUA_VariableAttributes(value = "",
    displayname = "ModelName",
    description = "Name of the model")
retval10 = JUA_Server_addNode(server, JUA_NodeId(), deviceTypeId,
    JUA_NodeId(0, UA_NS0ID_HASCOMPONENT),
    JUA_QualifiedName(1, "ModelName"),
    modelAttr, C_NULL, C_NULL, JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE))
@test retval10 == UA_STATUSCODE_GOOD

#Define the object type for "Pump"
ptAttr = JUA_ObjectTypeAttributes(displayname = "PumpType",
    description = "Object type for a pump")
retval11 = JUA_Server_addNode(server, pumpTypeId,
    deviceTypeId, JUA_NodeId(0, UA_NS0ID_HASSUBTYPE),
    JUA_QualifiedName(1, "PumpType"), ptAttr,
    JUA_NodeId(), JUA_NodeId())
@test retval11 == UA_STATUSCODE_GOOD

statusAttr = JUA_VariableAttributes(value = false,
    displayname = "Status",
    description = "Status")
statusId = JUA_NodeId()
retval12 = JUA_Server_addNode(server, JUA_NodeId(), pumpTypeId,
    JUA_NodeId(0, UA_NS0ID_HASCOMPONENT),
    JUA_QualifiedName(1, "Status"),
    statusAttr, JUA_NodeId(), statusId, JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE))
@test retval12 == UA_STATUSCODE_GOOD

#TODO: would need to introduce JUA_ExpandedNodeId in highlevel_types.jl before revising this
# Make the status variable mandatory */
retval13 = UA_Server_addReference(server, open62541.Jpointer(statusId),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
    UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY), true)
@test retval13 == UA_STATUSCODE_GOOD

rpmAttr = JUA_VariableAttributes(displayname = "MotorRPM",
    description = "Pump speed in rpm", value = 0)
retval14 = JUA_Server_addNode(server, JUA_NodeId(), pumpTypeId,
    JUA_NodeId(0, UA_NS0ID_HASCOMPONENT),
    JUA_QualifiedName(1, "MotorRPMs"),
    rpmAttr, JUA_NodeId(), JUA_NodeId(), JUA_NodeId(0, UA_NS0ID_BASEDATAVARIABLETYPE))
@test retval14 == UA_STATUSCODE_GOOD

function addPumpObjectInstance(server, name, id)
    oAttr = JUA_ObjectAttributes(displayname = name, description = name)
    retval = JUA_Server_addNode(server, JUA_NodeId(),
        JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER),
        JUA_NodeId(0, UA_NS0ID_ORGANIZES),
        JUA_QualifiedName(1, name),
        oAttr, JUA_NodeId(), JUA_NodeId(), id)
    return retval
end

function pumpTypeConstructor(server, sessionId, sessionContext,
        typeId, typeContext, nodeId, nodeContext)
    #UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND, "New pump created")

    #/* Find the NodeId of the status child variable */
    rpe = UA_RelativePathElement_new()
    UA_RelativePathElement_init(rpe)
    rpe.referenceTypeId = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
    rpe.isInverse = false
    rpe.includeSubtypes = false
    rpe.targetName = UA_QUALIFIEDNAME(1, "Status")

    bp = UA_BrowsePath_new()
    UA_BrowsePath_init(bp)
    bp.startingNode = nodeId
    bp.relativePath.elementsSize = 1
    bp.relativePath.elements = rpe

    bpr = UA_Server_translateBrowsePathToNodeIds(server, bp)
    if bpr.statusCode != UA_STATUSCODE_GOOD || bpr.targetsSize < 1
        return bpr.statusCode
    end

    #Set the status value
    status = true
    value = UA_Variant_new()
    UA_Variant_setScalarCopy(value, Ref(status), UA_TYPES_PTRS[UA_TYPES_BOOLEAN])
    UA_Server_writeValue(server, bpr.targets.targetId.nodeId, value)

    #clean up
    UA_Variant_delete(value)
    UA_BrowsePath_delete(bp)
    #Don't free up rpe as well, because freeing up bp already does that. 

    return UA_STATUSCODE_GOOD
end

function addPumpTypeConstructor(server, id)
    c_pumpTypeConstructor = UA_NodeTypeLifecycleCallback_constructor_generate(pumpTypeConstructor)
    lifecycle = UA_NodeTypeLifecycle(c_pumpTypeConstructor, C_NULL)
    UA_Server_setNodeTypeLifecycle(server, id, lifecycle)
end

r1 = addPumpObjectInstance(server, "pump2", pumpTypeId) #should have status = false (constructor not in place yet)
r2 = addPumpObjectInstance(server, "pump3", pumpTypeId) #should have status = false (constructor not in place yet)
addPumpTypeConstructor(server, pumpTypeId)
r3 = addPumpObjectInstance(server, "pump4", pumpTypeId) #should have status = true
r4 = addPumpObjectInstance(server, "pump5", pumpTypeId) #should have status = true
@test  r1 == UA_STATUSCODE_GOOD
@test  r2 == UA_STATUSCODE_GOOD
@test  r3 == UA_STATUSCODE_GOOD
@test  r4 == UA_STATUSCODE_GOOD
#TODO: should actually check the status value and not just whether adding things went ok.

#add method node
#follows this: https://www.open62541.org/doc/1.3/tutorial_server_method.html

function helloWorld(server, sessionId, sessionHandle, methodId,
        methodContext, objectId, objectContext, inputSize, input, outputSize, output)
    inputstr = unsafe_string(unsafe_wrap(input))
    tmp = UA_STRING("Hello " * inputstr)
    UA_Variant_setScalarCopy(output, tmp, UA_TYPES_PTRS[UA_TYPES_STRING])
    UA_String_delete(tmp)
    return UA_STATUSCODE_GOOD
end

#TODO: code here is not yet part of the high level interface, but a mixture...
inputArgument = UA_Argument_new()
lt = UA_LOCALIZEDTEXT("en-US", "A String")
ua_s = UA_STRING("MyInput")
UA_LocalizedText_copy(lt, inputArgument.description)
UA_String_copy(ua_s, inputArgument.name)
inputArgument.dataType = UA_TYPES_PTRS[UA_TYPES_STRING].typeId
inputArgument.valueRank = UA_VALUERANK_SCALAR
UA_LocalizedText_delete(lt)
UA_String_delete(ua_s)

outputArgument = UA_Argument_new()
lt = UA_LOCALIZEDTEXT("en-US", "A String")
ua_s = UA_STRING("MyOutput")
UA_LocalizedText_copy(lt, outputArgument.description)
UA_String_copy(ua_s, outputArgument.name)
UA_LocalizedText_delete(lt)
UA_String_delete(ua_s)
outputArgument.dataType = UA_TYPES_PTRS[UA_TYPES_STRING].typeId
outputArgument.valueRank = UA_VALUERANK_SCALAR
helloAttr = JUA_MethodAttributes(description = "Say Hello World",
    displayname = "Hello World",
    executable = true,
    userexecutable = true)

methodid = JUA_NodeId(1, 62541)
parentnodeid = JUA_NodeId(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = JUA_NodeId(0, UA_NS0ID_HASCOMPONENT)
if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
    helloWorldMethodCallback = UA_MethodCallback_generate(helloWorld)
else #we are on Apple Silicon and can't use a closure in @cfunction, have to do more work.
    helloWorldMethodCallback = @cfunction(helloWorld, UA_StatusCode,
        (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
end
browsename = JUA_QualifiedName(1, "hello world")
retval = JUA_Server_addNode(server, methodid,
    parentnodeid, parentreferencenodeid, browsename,
    helloAttr, helloWorldMethodCallback,
    1, inputArgument, 1, outputArgument, JUA_NodeId(), JUA_NodeId())

@test retval == UA_STATUSCODE_GOOD

inputArguments = UA_Variant_new()
ua_s = UA_STRING("Peter")
UA_Variant_setScalar(inputArguments, ua_s, UA_TYPES_PTRS[UA_TYPES_STRING])
req = UA_CallMethodRequest_new()
req.objectId = parentnodeid
req.methodId = methodid
req.inputArgumentsSize = 1
req.inputArguments = inputArguments

answer = UA_CallMethodResult_new()
UA_Server_call(server, req, answer)
@test unsafe_load(answer.statusCode) == UA_STATUSCODE_GOOD
@test unsafe_string(unsafe_wrap(unsafe_load(answer.outputArguments))) == "Hello Peter"

#clean up
UA_Argument_delete(inputArgument)
UA_Argument_delete(outputArgument)
UA_CallMethodRequest_delete(req)
UA_CallMethodResult_delete(answer)
