standard_type_docstring = "\"\"\"\n\$(TYPEDEF)\nFields:\n\$(TYPEDFIELDS)\n\"\"\""
docstrings_types_ignore_keywords = ["_", "static", "aa"] #types for which we don't make a docstring, because they are normally not to be accessed by a user

#union type types that just have "data" fields (for which we need to write our own docstrings)
docstrings_types_special = ["UA_NodeId" "\$(TYPEDEF)\n\nFields:\n\n- `nameSpaceIndex`\n\n- `identifierType`\n\n- `identifier`\n";
                            "UA_DataTypeMember" "\n\$(TYPEDEF)\n\nFields:\n\n- `memberName`\n\n- `memberType`\n- `padding`\n- `isArray`\n- `isOptional`\n"
                            "UA_DataType" "\n\$(TYPEDEF)\n\nFields:\n\n- `typeName`\n\n- `typeId`\n\n- `binaryEncodingId`\n\n- `memSize`\n\n- `typeKind`\n\n- `pointerFree`\n\n- `overlayable`\n\n- `membersSize`\n\n- `members`\n"
                            "UA_ValueBackend" "\n\$(TYPEDEF)\n\nFields:\n\n- `backendType`\n\n- `backend`\n"
                            "UA_ExtensionObject" "\n\$(TYPEDEF)\n\nFields:\n\n- `encoding`\n\n- `content`\n"
                            "UA_DiagnosticInfo" "\n\$(TYPEDEF)\n\nFields:\n\n- `hasSymbolicId`\n\n- `hasNamespaceUri`\n\n- `hasLocalizedText`\n\n- `hasLocale`\n\n- `hasAdditionalInfo`\n\n- `hasInnerStatusCode`\n\n- `hasInnerDiagnosticInfo`\n\n- `symbolicId`\n\n- `namespaceUri`\n\n- `localizedText`\n\n- `locale`\n\n- `additionalInfo`\n\n- `innerStatusCode`\n\n- `innerDiagnosticInfo`\n"
                            "UA_NodePointer" "\n\$(TYPEDEF)\n\nFields:\n\n- `immediate`\n\n- `id`\n\n- `expandedId`\n\n- `node`\n"
                            "UA_VariableNode" "\n\$(TYPEDEF)\n\nFields:\n\n- `head`\n\n- `dataType`\n\n- `valueRank`\n\n- `arrayDimensionsSize`\n\n- `arrayDimensions`\n\n- `valueBackend`\n\n- `valueSource`\n\n- `value`\n\n- `accessLevel`\n\n- `minimumSamplingInterval`\n\n- `historizing`\n\n- `isDynamic`\n"
                            "UA_VariableTypeNode" "\n\$(TYPEDEF)\n\nFields:\n\n- `head`\n\n- `dataType`\n\n- `valueRank`\n\n- `arrayDimensionsSize`\n\n- `arrayDimensions`\n\n- `valueBackend`\n\n- `valueSource`\n\n- `value`\n\n- `isAbstract`\n\n- `lifecycle`\n"
                            "UA_Node" "\n\$(TYPEDEF)\n\nFields:\n\n- `head`\n\n- `variableNode`\n\n- `variableTypeNode`\n\n- `methodNode`\n\n- `objectNode`\n\n- `objectTypeNode`\n\n- `referenceTypeNode`\n\n- `dataTypeNode`\n\n- `viewNode`\n"
                            "UA_AsyncOperationRequest" "\n\$(TYPEDEF)\n\nFields:\n\n- `callMethodRequest`\n"
                            "UA_AsyncOperationResponse" "\n\$(TYPEDEF)\n\nFields:\n\n- `callMethodResult`\n"]

uniontype_warning = "Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.\n"
#splice docstrings into Open62541.jl
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
data = read(f, String)
close(f)

typenames = getfield.(collect(eachmatch(r"struct (\S*)\n", data)), :captures) #gets all typenames within Open62541.jl
for type in typenames
    @show type[1]
    if !any(startswith.(type[1], docstrings_types_ignore_keywords)) &&
       !any(contains.(type[1], docstrings_types_special)) #standard docstring
        global data = replace(
            data, "struct $(type[1])\n" => "$standard_type_docstring\nstruct $(type[1])\n")
    elseif any(contains.(type[1], docstrings_types_special[:, 1]))
        i = findfirst(t -> t == type[1], docstrings_types_special[:, 1])
        if !isnothing(i)
            data = replace(data,
                "struct $(type[1])\n" => "\"\"\"\n$(docstrings_types_special[i,2])\n$uniontype_warning\"\"\"\nstruct $(type[1])\n")
        end
    end
end

fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "w")
write(f, data)
close(f)
