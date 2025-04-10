standard_type_docstring = "\"\"\"\n\$(TYPEDEF)\nFields:\n\$(TYPEDFIELDS)\n\"\"\""
docstrings_types_ignore_keywords = ["_", "static", "aa"] #types for which we don't make a docstring, because they are normally not to be accessed by a user


uniontype_warning = "Note that this type is defined as a union type in C; therefore, setting fields of a Ptr of this type requires special care.\n"
#splice docstrings into Open62541.jl
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "r")
data = read(f, String)
close(f)

#union type types that just have "data" fields (for which we need to write our own docstrings)
r = Regex("struct ([a-zA-Z_0-9]*)\n[\\s\\S]{0,50}?data::NTuple\\{[0-9]{1,3}, UInt8\\}\nend")
unionstructnames = collect(String[m.captures[1] for m in eachmatch(r, data)])

typenames = getfield.(collect(eachmatch(r"struct (\S*)\n", data)), :captures) #gets all typenames within Open62541.jl
for type in typenames
    if !any(startswith.(type[1], docstrings_types_ignore_keywords)) && !in(type[1], unionstructnames) #standard docstring
        global data = replace(data, "struct $(type[1])\n" => "$standard_type_docstring\nstruct $(type[1])\n")
    elseif in(type[1], unionstructnames) && !any(startswith.(type[1], docstrings_types_ignore_keywords))
        #import Open62541
        rbits = Regex("struct $(type[1])\n[\\s]{1,50}?data::NTuple\\{([0-9]+), UInt8\\}\nend")
        mbits = match(rbits, data)
        nbits = parse(Int64, mbits.captures[1])
        x = getfield(Open62541, Symbol(type[1]))(Tuple(zeros(UInt8, nbits)))
        t = join(propertynames(x), "`\n\n- `")
        t = "\n\$(TYPEDEF)\n\nFields:\n\n- `"*t*"`\n"
        data = replace(data,
            "struct $(type[1])\n" => "\"\"\"\n$(t)\n$uniontype_warning\"\"\"\nstruct $(type[1])\n")
    end
end
fn = joinpath(@__DIR__, "../src/Open62541.jl")
f = open(fn, "w")
write(f, data)
close(f)
