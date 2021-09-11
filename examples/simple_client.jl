using open62541
using Printf

client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
retval = UA_Client_connect(client, "opc.tcp://127.0.0.1:4840")

value = UA_Variant_new()
UA_init(value)

nodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)

retval = __UA_Client_readAttribute(client, Ref(nodeid), UA_ATTRIBUTEID_VALUE, value, UA_TYPES_PTRS[UA_TYPES_VARIANT]) # TODO: Implement inlined client functions
UA_Variant_hasScalarType(value, UA_TYPES_PTRS[UA_TYPES_DATETIME])
raw_date = unsafe_load(reinterpret(Ptr{UA_DateTime}, unsafe_load(value).data)) # TODO: Implement generic UA_Variant read function

dts = UA_DateTime_toStruct(raw_date)
Printf.@printf("date is: %u-%u-%u %u:%u:%u.%03u\n", dts.day, dts.month, dts.year, dts.hour, dts.min, dts.sec, dts.milliSec)

UA_Variant_clear(value)
UA_Variant_delete(value)