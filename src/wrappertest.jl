mutable struct JUA_Server
    sptr::Ptr{UA_Server}  

    function JUA_Server()
        # note that N_VMake_Serial() creates N_Vector doesn't own the data,
        # so calling N_VDestroy_Serial() would not deallocate v
        s = new(UA_Server_new())
        finalizer(release_handle, s)
        return s
    end
end

release_handle(s::JUA_Server) = UA_Server_delete(s.sptr)