#Client service request error
struct ClientServiceRequestError <: Exception
    err::String
end

function Base.showerror(io::IO, e::ClientServiceRequestError)
    print(io, e.err)
end

#Attribute error (server and client)
struct AttributeReadWriteError <: Exception
    action::String
    mode::String
    side::String
    attributename::String
    statuscode::UInt32
end

function Base.showerror(io::IO, e::AttributeReadWriteError)
    print(io,
        "$(e.action) ´$(e.attributename)´ by UA_$(e.side) failed with statuscode \"$(UA_StatusCode_name_print(e.statuscode))\".")
end

#Attribute copy error
struct AttributeCopyError <: Exception
    statuscode::UInt32
end

function Base.showerror(io::IO, e::AttributeCopyError)
    print(io,
        "Copying attribute object failed with statuscode \"$(UA_StatusCode_name_print(e.statuscode))\".")
end
