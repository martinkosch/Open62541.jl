using open62541
using Dates
using Printf

client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
retval = UA_Client_connect(client, "opc.tcp://127.0.0.1:4840")

nodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME)

value = UA_Client_readValueAttribute(client, nodeid) # TODO: Implement inlined client functions
UA_Variant_hasScalarType(value, UA_TYPES_PTRS[UA_TYPES_DATETIME])
raw_date = unsafe_wrap(value)

dts = UA_DateTime_toStruct(raw_date)
Printf.@printf("date is: %u-%u-%u %u:%u:%u.%03u\n", dts.day, dts.month, dts.year, dts.hour, dts.min, dts.sec, dts.milliSec)

UA_Variant_clear(value)
UA_Variant_delete(value)