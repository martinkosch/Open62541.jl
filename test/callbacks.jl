using Open62541
using Test

if !Sys.isapple() #closures not supported on Apple M1 processors, LLVM limitation. 

    #find all defined callbacks in open62541 (src/callbacks.jl file)
    callbacks = filter(x -> occursin(r"Callback.*_generate", string(x)), names(Open62541))

    #initialized return type list - only callbacks with non-Nothing return types need 
    #to be added here
    callback_names = [
        :UA_MethodCallback_generate,
        :UA_NodeTypeLifecycleCallback_constructor_generate,
        :UA_DataSourceCallback_read_generate,
        :UA_DataSourceCallback_write_generate
    ]
    return_types = ["UA_UInt32(0)", "UA_UInt32(0)", "UA_UInt32(0)", "UA_UInt32(0)"]

    #test exception branch of all callbacks
    for callback in callbacks
        #checks exception branch of the callback
        a = () -> 0.0
        @test_throws Open62541.CallbackGeneratorArgumentError eval(callback)(a)

        #checks the main branch of the callback
        try
            eval(callback)(a)
        catch e
            i = findfirst(x -> x == callback, callback_names)
            if !isnothing(i)
                rettype = return_types[i]
            else
                rettype = nothing
            end

            args = e.argtuple
            str = "prot(::" * string(args[1])
            for i in 2:length(args)
                str = str * ", ::" * string(args[i])
            end
            str = str * ") = $rettype"
            eval(Meta.parse(str))
            @test !isa(eval(callback)(prot), Exception)
            Base.delete_method(getmethodindex(methods(prot), 1))
        end
    end
end