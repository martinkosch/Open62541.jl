using open62541
using Test

#find all defined callbacks in open62541 (src/callbacks.jl file)
callbacks = filter(x -> occursin(r"Callback.*_generate", string(x)), names(open62541))

#test exception branch of all callbacks
for callback in callbacks
    a = () -> 0.0
    @test_throws open62541.CallbackGeneratorArgumentError eval(callback)(a)
end

#TODO: add a way of checking the main branch of all callbacks; 
#need to generate an appropriate function for each of the callbacks.