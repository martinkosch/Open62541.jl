using open62541
using Documenter

DocMeta.setdocmeta!(open62541, :DocTestSetup, :(using open62541); recursive=true)

makedocs(;
    modules=[open62541],
    authors="Martin Kosch <martin.kosch@rwth-aachen.de> and contributors",
    repo="https://github.com/Martin Kosch/open62541.jl/blob/{commit}{path}#{line}",
    sitename="open62541.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Martin Kosch.github.io/open62541.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Martin Kosch/open62541.jl",
)
