#Purpose: Tests attribute generation functionality and associated functions
using open62541
using Test
using Random

#UA_VALUERANK
@test UA_VALUERANK(1) == UA_VALUERANK_ONE_DIMENSION
@test UA_VALUERANK(2) == UA_VALUERANK_TWO_DIMENSIONS
@test UA_VALUERANK(3) == UA_VALUERANK_THREE_DIMENSIONS
@test UA_VALUERANK(0) == 0
@test UA_VALUERANK(-2) == -2

#UA_ACCESSLEVEL
@test UA_ACCESSLEVEL() == 0
@test UA_ACCESSLEVEL(write = true) == UA_ACCESSLEVELMASK_WRITE
@test UA_ACCESSLEVEL(write = true, read = true) ==
      UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
@test UA_ACCESSLEVEL(read = true, write = true, historyread = true, historywrite = true,
    semanticchange = true, timestampwrite = true, statuswrite = true) ==
      UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE |
      UA_ACCESSLEVELMASK_HISTORYREAD | UA_ACCESSLEVELMASK_HISTORYWRITE |
      UA_ACCESSLEVELMASK_SEMANTICCHANGE | UA_ACCESSLEVELMASK_STATUSWRITE |
      UA_ACCESSLEVELMASK_TIMESTAMPWRITE

#UA_USERACCESSLEVEL
@test UA_USERACCESSLEVEL() == 0
@test UA_USERACCESSLEVEL(write = true) == UA_ACCESSLEVELMASK_WRITE
@test UA_USERACCESSLEVEL(write = true, read = true) ==
      UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
@test UA_USERACCESSLEVEL(
    read = true, write = true, historyread = true, historywrite = true,
    semanticchange = true, timestampwrite = true, statuswrite = true) ==
      UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE |
      UA_ACCESSLEVELMASK_HISTORYREAD | UA_ACCESSLEVELMASK_HISTORYWRITE |
      UA_ACCESSLEVELMASK_SEMANTICCHANGE | UA_ACCESSLEVELMASK_STATUSWRITE |
      UA_ACCESSLEVELMASK_TIMESTAMPWRITE

#UA_WRITEMASK
@test UA_WRITEMASK() == 0
@test UA_WRITEMASK(; accesslevel = true, arraydimensions = true,
    browsename = true, containsnoloops = true, datatype = true,
    description = true, displayname = true, eventnotifier = true,
    executable = true, historizing = true, inversename = true,
    isabstract = true, minimumsamplinginterval = true, nodeclass = true,
    nodeid = true, symmetric = true, useraccesslevel = true,
    userexecutable = true, userwritemask = true, valuerank = true,
    writemask = true, valueforvariabletype = true) ==
      UA_WRITEMASK_ACCESSLEVEL | UA_WRITEMASK_ARRRAYDIMENSIONS |
      UA_WRITEMASK_BROWSENAME | UA_WRITEMASK_CONTAINSNOLOOPS | UA_WRITEMASK_DATATYPE |
      UA_WRITEMASK_DESCRIPTION | UA_WRITEMASK_DISPLAYNAME |
      UA_WRITEMASK_EVENTNOTIFIER | UA_WRITEMASK_EXECUTABLE |
      UA_WRITEMASK_HISTORIZING | UA_WRITEMASK_INVERSENAME |
      UA_WRITEMASK_ISABSTRACT | UA_WRITEMASK_MINIMUMSAMPLINGINTERVAL |
      UA_WRITEMASK_NODECLASS | UA_WRITEMASK_NODEID | UA_WRITEMASK_SYMMETRIC |
      UA_WRITEMASK_USERACCESSLEVEL | UA_WRITEMASK_USEREXECUTABLE |
      UA_WRITEMASK_USERWRITEMASK | UA_WRITEMASK_VALUERANK | UA_WRITEMASK_WRITEMASK |
      UA_WRITEMASK_VALUEFORVARIABLETYPE

#UA_WRITEMASK
@test UA_USERWRITEMASK() == 0
@test UA_USERWRITEMASK(; accesslevel = true, arraydimensions = true,
    browsename = true, containsnoloops = true, datatype = true,
    description = true, displayname = true, eventnotifier = true,
    executable = true, historizing = true, inversename = true,
    isabstract = true, minimumsamplinginterval = true, nodeclass = true,
    nodeid = true, symmetric = true, useraccesslevel = true,
    userexecutable = true, userwritemask = true, valuerank = true,
    writemask = true, valueforvariabletype = true) ==
      UA_WRITEMASK_ACCESSLEVEL | UA_WRITEMASK_ARRRAYDIMENSIONS |
      UA_WRITEMASK_BROWSENAME | UA_WRITEMASK_CONTAINSNOLOOPS | UA_WRITEMASK_DATATYPE |
      UA_WRITEMASK_DESCRIPTION | UA_WRITEMASK_DISPLAYNAME |
      UA_WRITEMASK_EVENTNOTIFIER | UA_WRITEMASK_EXECUTABLE |
      UA_WRITEMASK_HISTORIZING | UA_WRITEMASK_INVERSENAME |
      UA_WRITEMASK_ISABSTRACT | UA_WRITEMASK_MINIMUMSAMPLINGINTERVAL |
      UA_WRITEMASK_NODECLASS | UA_WRITEMASK_NODEID | UA_WRITEMASK_SYMMETRIC |
      UA_WRITEMASK_USERACCESSLEVEL | UA_WRITEMASK_USEREXECUTABLE |
      UA_WRITEMASK_USERWRITEMASK | UA_WRITEMASK_VALUERANK | UA_WRITEMASK_WRITEMASK |
      UA_WRITEMASK_VALUEFORVARIABLETYPE

#UA_EVENTNOTIFIER
@test UA_EVENTNOTIFIER() == 0
@test UA_EVENTNOTIFIER(subscribetoevent = true, historyread = true, historywrite = true) ==
      UA_EVENTNOTIFIER_SUBSCRIBE_TO_EVENT | UA_EVENTNOTIFIER_HISTORY_READ |
      UA_EVENTNOTIFIER_HISTORY_WRITE

#UA_VariableAttributes_generate
#define different sized input cases to test both scalar and array codes
array_sizes = [1, 2, (2, 3), (2, 3, 4)]
types = [Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32,
    UInt64, Float32, Float64, String, ComplexF32, ComplexF64]
inputs = Tuple(Tuple(type != String ? rand(type, array_size) :
                     reshape([randstring(Int64(rand(UInt8))) for i in 1:prod(array_size)],
                         array_size...) for array_size in array_sizes) for type in types)
valueranks = [-1, 1, 2, 3]
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
useraccesslevel = UA_ACCESSLEVEL(read = true, historyread = true)
minimumsamplinginterval = rand()
historizing = true
for i in eachindex(array_sizes)
    for j in eachindex(types)
        if length(inputs[j][i]) == 1
            v = inputs[j][i][1]
        else
            v = inputs[j][i]
        end
        attr = UA_VariableAttributes_generate(value = v, displayname = displayname,
            description = description, localization = localization,
            writemask = writemask, userwritemask = userwritemask,
            accesslevel = accesslevel, useraccesslevel = useraccesslevel,
            minimumsamplinginterval = minimumsamplinginterval,
            historizing = historizing)
        @test unsafe_string(unsafe_load(attr.displayName.text)) == displayname
        @test unsafe_string(unsafe_load(attr.displayName.locale)) == localization
        @test unsafe_string(unsafe_load(attr.description.text)) == description
        @test unsafe_string(unsafe_load(attr.description.locale)) == localization
        @test unsafe_load(attr.writeMask) == writemask
        @test unsafe_load(attr.userWriteMask) == userwritemask
        @test unsafe_load(attr.accessLevel) == accesslevel
        @test unsafe_load(attr.userAccessLevel) == useraccesslevel
        @test unsafe_load(attr.minimumSamplingInterval) == minimumsamplinginterval
        @test unsafe_load(attr.valueRank) == valueranks[i]
        @test unsafe_load(attr.historizing) == historizing
        #TODO: add test that checks dataType being correctly set.
        out = open62541.__get_juliavalues_from_variant(attr.value, Any)
        if types[j] <: Union{AbstractFloat, Complex}
            @test all(out .≈ v)
        else
            @test all(out == v)
        end
        UA_VariableAttributes_delete(attr)

        #now a test with the high level interface as well
        j = JUA_VariableAttributes(value = v, displayname = displayname,
            description = description, localization = localization,
            writemask = writemask, userwritemask = userwritemask,
            accesslevel = accesslevel, useraccesslevel = useraccesslevel,
            minimumsamplinginterval = minimumsamplinginterval,
            historizing = historizing)
        @test j isa JUA_VariableAttributes
    end
end

#UA_VariableTypeAttributes_generate
#define different sized input cases to test both scalar and array codes
array_sizes = [1, 2, (2, 3), (2, 3, 4)]
types = [Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32,
    UInt64, Float32, Float64, String, ComplexF32, ComplexF64]
inputs = Tuple(Tuple(type != String ? rand(type, array_size) :
                     reshape([randstring(Int64(rand(UInt8))) for i in 1:prod(array_size)],
                         array_size...) for array_size in array_sizes) for type in types)
valueranks = [-1, 1, 2, 3]
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
isabstract = true
for i in eachindex(array_sizes)
    for j in eachindex(types)
        if length(inputs[j][i]) == 1
            v = inputs[j][i][1]
        else
            v = inputs[j][i]
        end
        attr = UA_VariableTypeAttributes_generate(value = v, displayname = displayname,
            description = description, localization = localization,
            writemask = writemask, userwritemask = userwritemask,
            isabstract = isabstract)
        @test unsafe_string(unsafe_load(attr.displayName.text)) == displayname
        @test unsafe_string(unsafe_load(attr.displayName.locale)) == localization
        @test unsafe_string(unsafe_load(attr.description.text)) == description
        @test unsafe_string(unsafe_load(attr.description.locale)) == localization
        @test unsafe_load(attr.writeMask) == writemask
        @test unsafe_load(attr.userWriteMask) == userwritemask
        @test unsafe_load(attr.valueRank) == valueranks[i]
        @test unsafe_load(attr.isAbstract) == isabstract
        out = open62541.__get_juliavalues_from_variant(attr.value, Any)
        if types[j] <: Union{AbstractFloat, Complex}
            @test all(out .≈ v)
        else
            @test all(out == v)
        end
        UA_VariableTypeAttributes_delete(attr)

        #high level interface
        j = JUA_VariableTypeAttributes(value = v, displayname = displayname,
            description = description, localization = localization,
            writemask = writemask, userwritemask = userwritemask,
            isabstract = isabstract)
        @test j isa JUA_VariableTypeAttributes
    end
end

#now test case with no value specified (tests different branches)
def = UA_VariableTypeAttributes_default[]

## use only mandatory keywords
attr = UA_VariableTypeAttributes_generate(displayname = displayname,
    description = description, localization = localization)
@test unsafe_string(unsafe_load(attr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(attr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(attr.description.text)) == description
@test unsafe_string(unsafe_load(attr.description.locale)) == localization
@test unsafe_load(attr.writeMask) == def.writeMask
@test unsafe_load(attr.userWriteMask) == def.userWriteMask
@test unsafe_load(attr.valueRank) == def.valueRank
@test unsafe_load(attr.isAbstract) == def.isAbstract
UA_VariableTypeAttributes_delete(attr)

## use optional keywords as well
valuerank = 1
attr = UA_VariableTypeAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    isabstract = isabstract, valuerank = valuerank)

@test unsafe_string(unsafe_load(attr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(attr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(attr.description.text)) == description
@test unsafe_string(unsafe_load(attr.description.locale)) == localization
@test unsafe_load(attr.writeMask) == writemask
@test unsafe_load(attr.userWriteMask) == userwritemask
@test unsafe_load(attr.valueRank) == valuerank
@test unsafe_load(attr.isAbstract) == isabstract
UA_VariableTypeAttributes_delete(attr)

#UA_ObjectAttributes_generate
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
eventnotifier = UA_EVENTNOTIFIER(subscribetoevent = true, historyread = true)

objattr = UA_ObjectAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    eventnotifier = eventnotifier)

@test unsafe_string(unsafe_load(objattr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(objattr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(objattr.description.text)) == description
@test unsafe_string(unsafe_load(objattr.description.locale)) == localization
@test unsafe_load(objattr.writeMask) == writemask
@test unsafe_load(objattr.userWriteMask) == userwritemask
@test unsafe_load(objattr.eventNotifier) == eventnotifier
UA_ObjectAttributes_delete(objattr)

#UA_ObjectTypeAttributes_generate
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
isabstract = true

objtypeattr = UA_ObjectTypeAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    isabstract = isabstract)

@test unsafe_string(unsafe_load(objtypeattr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(objtypeattr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(objtypeattr.description.text)) == description
@test unsafe_string(unsafe_load(objtypeattr.description.locale)) == localization
@test unsafe_load(objtypeattr.writeMask) == writemask
@test unsafe_load(objtypeattr.userWriteMask) == userwritemask
@test unsafe_load(objtypeattr.isAbstract) == isabstract
UA_ObjectTypeAttributes_delete(objtypeattr)

#UA_method_attributes
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
executable = true
userexecutable = true

methodattr = UA_MethodAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    executable = executable, userexecutable = userexecutable)

@test unsafe_string(unsafe_load(methodattr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(methodattr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(methodattr.description.text)) == description
@test unsafe_string(unsafe_load(methodattr.description.locale)) == localization
@test unsafe_load(methodattr.writeMask) == writemask
@test unsafe_load(methodattr.userWriteMask) == userwritemask
@test unsafe_load(methodattr.executable) == executable
@test unsafe_load(methodattr.userExecutable) == userexecutable
UA_MethodAttributes_delete(methodattr)

#UA_view_attributes
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
containsnoloops = true
eventnotifier = UA_EVENTNOTIFIER(subscribetoevent = true, historyread = true)

viewattr = UA_ViewAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    containsnoloops = containsnoloops, eventnotifier = eventnotifier)

@test unsafe_string(unsafe_load(viewattr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(viewattr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(viewattr.description.text)) == description
@test unsafe_string(unsafe_load(viewattr.description.locale)) == localization
@test unsafe_load(viewattr.writeMask) == writemask
@test unsafe_load(viewattr.userWriteMask) == userwritemask
@test unsafe_load(viewattr.containsNoLoops) == containsnoloops
@test unsafe_load(viewattr.eventNotifier) == eventnotifier
UA_ViewAttributes_delete(viewattr)

#UA_datatype_attributes
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
isabstract = true

datatypeattr = UA_DataTypeAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    isabstract = isabstract)

@test unsafe_string(unsafe_load(datatypeattr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(datatypeattr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(datatypeattr.description.text)) == description
@test unsafe_string(unsafe_load(datatypeattr.description.locale)) == localization
@test unsafe_load(datatypeattr.writeMask) == writemask
@test unsafe_load(datatypeattr.userWriteMask) == userwritemask
@test unsafe_load(datatypeattr.isAbstract) == isabstract
UA_DataTypeAttributes_delete(datatypeattr)

#UA_referencetype_attributes
displayname = "whatever"
description = "this is a whatever variable"
localization = "en-GB"
writemask = UA_WRITEMASK(accesslevel = true, valuerank = true, writemask = true)
userwritemask = UA_WRITEMASK(accesslevel = true, valuerank = false, writemask = true)
isabstract = true
symmetric = true
inversename = "invname"

referencetypeattr = UA_ReferenceTypeAttributes_generate(displayname = displayname,
    description = description, localization = localization,
    writemask = writemask, userwritemask = userwritemask,
    isabstract = isabstract, symmetric = symmetric, inversename = inversename)

@test unsafe_string(unsafe_load(referencetypeattr.displayName.text)) == displayname
@test unsafe_string(unsafe_load(referencetypeattr.displayName.locale)) == localization
@test unsafe_string(unsafe_load(referencetypeattr.description.text)) == description
@test unsafe_string(unsafe_load(referencetypeattr.description.locale)) == localization
@test unsafe_string(unsafe_load(referencetypeattr.inverseName.text)) == inversename
@test unsafe_string(unsafe_load(referencetypeattr.inverseName.locale)) == localization
@test unsafe_load(referencetypeattr.writeMask) == writemask
@test unsafe_load(referencetypeattr.userWriteMask) == userwritemask
@test unsafe_load(referencetypeattr.isAbstract) == isabstract
@test unsafe_load(referencetypeattr.symmetric) == symmetric
UA_ReferenceTypeAttributes_delete(referencetypeattr)
