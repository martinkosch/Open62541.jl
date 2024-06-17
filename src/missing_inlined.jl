using Open62541

missing_inlined_funcs = String[]
for func in Open62541.inlined_funcs
    if !isdefined(Open62541, Symbol(func))
        push!(missing_inlined_funcs, func)
    end
end
