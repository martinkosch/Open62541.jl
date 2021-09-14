function __init__()
    global UA_TYPES
    global UA_TYPES_PTRS
    global UA_TYPES_MAP
    UA_TYPES[] = cglobal((:UA_TYPES, libopen62541), UA_DataType)

    for i = 0:UA_TYPES_COUNT-1
        UA_TYPES_PTRS[i] = UA_TYPES[] + sizeof(UA_DataType) * i
        
        typename = "UA_" * unsafe_string(unsafe_load(UA_TYPES_PTRS[i]).typeName)
        UA_TYPES_MAP[i+1] = eval(Symbol(typename))
    end
end