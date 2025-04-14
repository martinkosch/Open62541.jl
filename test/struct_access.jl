#Purpose: Tests that the fields of C union structs are correctly accessible.
#These are structs that are implemented by Clang.jl containing just a `data` field, but where
#the data in fact represents different quantities.

using Open62541
using Test


fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
filecontent = read(f, String)
close(f)

#get the names and number of length of structs in Open62541.jl that contain only a data field
runionstruct = Regex("struct ([a-zA-Z_0-9]*)\n[\\s\\S]{0,50}?data::NTuple\\{([0-9]{1,3}), UInt8\\}\nend")
unionstructnames = collect(String[m.captures[1] for m in eachmatch(runionstruct, filecontent)])
Nbits = collect(parse(Int64, m.captures[2]) for m in eachmatch(runionstruct, filecontent))

#get all struct names in Open62541.jl
rallstruct = Regex("struct ([a-zA-Z_0-9]*)\n")
allstructnames = collect(String[m.captures[1] for m in eachmatch(rallstruct, filecontent)])
nonunionstructnames = setdiff(allstructnames, unionstructnames)

#check field access of union structs
for (unionstructname, Nbit) in zip(unionstructnames, Nbits)
    #generate a zeroed struct of this type.
    x = getfield(Open62541, Symbol(unionstructname))(Tuple(zeros(UInt8, Nbit)))
    #now do basic tests on propertynames
    propnames_public = propertynames(x, false)
    propnames_private = propertynames(x, true)
    privateonly = setdiff(propnames_public, propnames_private)
    for p in propnames_public
        @test getproperty(x, p) isa Any #simply checks whether this errors
    end
    for p in privateonly
        @test getproperty(x, p) isa Any
    end
    @test_throws ErrorException getproperty(x, gensym())
end

#check fields access (and creation and delete methods) of other structs
#TODO: some structs are missed here, because there isn't a UA_XXX_new and UA_XXX_delete method 
# making creating an instance harder.

#let's track which structs have a _new and _delete method defined in Open62541, but no field
#access method emitted for them. If array is not empty, it should be considered to add the 
#relevant struct to the `field_access_method_list` in the gen/generator.toml file.
missing_field_access = String[]

for nonunionstructname in nonunionstructnames
    _new = Symbol(nonunionstructname, "_new")
    _delete = Symbol(nonunionstructname, "_delete")
    if isdefined(Open62541, _new) && isdefined(Open62541, _delete)
        if length(methods(Base.getproperty, (Ptr{getfield(Open62541, Symbol(nonunionstructname))}, Symbol), Open62541)) > 0
            x = getfield(Open62541, _new)() #generates object with memory managed on C side
            props = propertynames(unsafe_load(x))
            for p in props
                @test getproperty(x, p) isa Any
            end 
            @test_throws ErrorException getproperty(x, gensym())
            getfield(Open62541, _delete)(x) #clean up memory
        else
            push!(missing_field_access, nonunionstructname)
            println("field access method for Ptr{$nonunionstructname} does not exist.")
        end            
    else
        println("creation/deletion not found for $nonunionstructname.")
    end
end

@show missing_field_access
