#Purpose: Tests that the fields of C union structs are correctly accessible.
#These are structs that are implemented by Clang.jl containing just a `data` field, but where
#the data in fact represents different quantities.

using Open62541
using Test

#get the names of structs in Open62541.jl that contain only a data field
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
filecontent = read(f, String)
close(f)
r = Regex("struct ([a-zA-Z_0-9]*)\n[\\s\\S]{0,50}?data::NTuple\\{([0-9]{1,3}), UInt8\\}\nend")
structnames = collect(String[m.captures[1] for m in eachmatch(r, filecontent)])
Nbits = collect(parse(Int64, m.captures[2]) for m in eachmatch(r, filecontent))

for (structname, Nbit) in zip(structnames, Nbits)
    #generate a zeroed struct of this type.
    x = getfield(Open62541, Symbol(structname))(Tuple(zeros(UInt8, Nbit)))
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
end