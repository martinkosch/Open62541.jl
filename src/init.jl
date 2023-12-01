function __init__()
    UA_TYPES[] = cglobal((:UA_TYPES, libopen62541), UA_DataType)
    for i in 0:(UA_TYPES_COUNT - 1)
        UA_TYPES_PTRS[i] = UA_TYPES[] + sizeof(UA_DataType) * i
        typename = "UA_" * unsafe_string(unsafe_load(UA_TYPES_PTRS[i]).typeName)
        UA_TYPES_MAP[i + 1] = eval(Symbol(typename))
    end

    # Load default attribute definitions (extern variables are missed by Clang.jl)
    UA_VariableAttributes_default[] = unsafe_load(cglobal((:UA_VariableAttributes_default,
            libopen62541),
        UA_VariableAttributes))
    UA_VariableTypeAttributes_default[] = unsafe_load(cglobal((:UA_VariableTypeAttributes_default,
            libopen62541),
        UA_VariableTypeAttributes))
    UA_MethodAttributes_default[] = unsafe_load(cglobal((:UA_MethodAttributes_default,
            libopen62541),
        UA_MethodAttributes))
    UA_ObjectAttributes_default[] = unsafe_load(cglobal((:UA_ObjectAttributes_default,
            libopen62541),
        UA_ObjectAttributes))
    UA_ObjectTypeAttributes_default[] = unsafe_load(cglobal((:UA_ObjectTypeAttributes_default,
            libopen62541),
        UA_ObjectTypeAttributes))
    UA_ReferenceTypeAttributes_default[] = unsafe_load(cglobal((:UA_ReferenceTypeAttributes_default,
            libopen62541),
        UA_ReferenceTypeAttributes))
    UA_DataTypeAttributes_default[] = unsafe_load(cglobal((:UA_DataTypeAttributes_default,
            libopen62541),
        UA_DataTypeAttributes))
    UA_ViewAttributes_default[] = unsafe_load(cglobal((:UA_ViewAttributes_default,
            libopen62541),
        UA_ViewAttributes))
end
