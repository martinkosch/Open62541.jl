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
        "$(e.action) $(e.mode) ´$(e.attributename)´ by UA_$(e.side) failed with statuscode \"$(UA_StatusCode_name_print(e.statuscode))\".")
end

#Attribute copy error
struct AttributeCopyError <: Exception
    statuscode::UInt32
end

function Base.showerror(io::IO, e::AttributeCopyError)
    msg = "Copying attribute object failed with statuscode 
        \"$(UA_StatusCode_name_print(e.statuscode))\"."
    print(io, msg)
end

#Unsupported Number type
struct UnsupportedNumberTypeError <: Exception
    type::DataType
end

function Base.showerror(io::IO, e::UnsupportedNumberTypeError)
    msg = "The supplied number type ($(e.type)) is not supported within Open62541.jl
        (nor open62541 for that matter). Natively supported number types are: 
        $UA_NUMBER_TYPES, Complex{Float32}, Complex{Float64}, Rational{Int32}, Rational{UInt32}."
    print(io, msg)
end

#Callback generator argument error 
#fields intentionally kept abstract; no specialization needed.
struct CallbackGeneratorArgumentError <: Exception
    f::Any
    argtuple::Any
    returntype::Any
end

function Base.showerror(io::IO, e::CallbackGeneratorArgumentError)
    m = methods(e.f)
    if length(m) > 1
        msg = "The provided function ($(e.f)) has more than one method; it is 
        unclear which one should be used as basis of the callback."
    else
        args_in = fieldtypes(getmethodindex(methods(e.f), 1).sig)
        ret = Base.return_types(e.f, args_in[2:end])[1]
        msg = "Callback generator expected a method with f($(join([e.argtuple...], ", ")))::$(string(e.returntype)), 
            but received a method f($(join(args_in[2:end], ", ")))::$(string(ret))."
    end
    print(io, msg)
end

#valuerank, arraysize error
struct ValueRankArraySizeConsistencyError <: Exception
    valuerank::Int64
    arraydimensions::Any
end

function Base.showerror(io::IO, e::ValueRankArraySizeConsistencyError)
    vr = e.valuerank
    arrdim = e.arraydimensions
    if vr < -3 
        msg = "A valuerank of $vr has been provided, but valuerank must be >= -3. For further
            details see: https://reference.opcfoundation.org/Core/Part3/v105/docs/8.6"
    elseif vr >= -3 && vr <= 0
        if vr == -3
            t = " scalar or one-dimensional array"
        elseif vr == -2
            t = " scalar or an array of any dimensionality"
        elseif vr == -1 
            t = " scalar"
        else
            t = "n array of one OR more dimensions"
        end
        msg = "A valuerank of -3 has been provided, which indicates a$t. Therefore, no 
            array dimensions should be provided, but $arrdim has been provided."
    else
        msg = "A valuerank of $vr has been provided, which indicates a $vr-dimensional array. 
            Therefore, array dimensions should be a $vr-element vector, but $arrdim has been 
            provided."
    end
    print(io, msg)
end

#MethodNodeInputError
struct MethodNodeInputError <: Exception
    ninputsupplied::Int64
    ninputnode::Int64
end

function Base.showerror(io::IO, e::MethodNodeInputError)
    n1 = e.ninputsupplied
    n2 = e.ninputnode
    p1 = n1 > 1 ? "s" : ""
    p2 =  n2 > 1 ? "s have" : " has"
    msg = "MethodNode expects $n2 input$p2, but $n1 input$p1 been supplied."
    print(io, msg)
end
