const UA_TYPES = Ref{Ptr{UA_DataType}}(0) # Initilize with C_NULL and initialize correct address at __init__

function __init__()
    global UA_TYPES
    UA_TYPES[] = cglobal((:UA_TYPES, libopen62541), UA_DataType)
end