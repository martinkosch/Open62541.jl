function __init__()
    global UA_TYPES
    global UA_TYPES_PTRS
    UA_TYPES[] = cglobal((:UA_TYPES, libopen62541), UA_DataType)

    for i = 0:UA_TYPES_COUNT-1
        UA_TYPES_PTRS[i] = UA_TYPES[] + sizeof(UA_DataType) * i
    end
end