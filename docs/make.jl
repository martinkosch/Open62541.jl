using Open62541
using Documenter

DocMeta.setdocmeta!(Open62541, :DocTestSetup, :(using Open62541); recursive = true)

makedocs(;
    modules = [Open62541],
    authors = "Martin Kosch <martin.kosch@gmail.com> and contributors",
    repo = "https://github.com/martinkosch/Open62541.jl/blob/{commit}{path}#{line}",
    sitename = "Open62541.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://martinkosch.github.io/Open62541.jl",
        assets = String[],
        size_threshold = 8000 * 2^10,
        repolink = "https://github.com/martinkosch/Open62541.jl"
    ),
    pages = [
        "Introduction" => "index.md",
        "Tutorials" => [
            "tutorials/server_first_steps.md",
            "tutorials/client_first_steps.md",
            "tutorials/combined_variables.md",
            "tutorials/combined_username_password_login.md",
            "tutorials/combined_encrypted_un_pw_login.md",
            "tutorials/combined_methodnode.md",
            "tutorials/further_resources.md"
        ],
        "Manual" => [
            "manual/numbertypes.md",
            "manual/nodeid.md",
            "manual/attributegeneration.md",
            "manual/server.md",
            "manual/client.md"
        ],
        "Reference" => ["Low level interface" => "reference_lowlevel.md",
            "High level interface" => "reference_highlevel.md"]
    ],
    warnonly = Documenter.except(
        :autodocs_block,
        #:cross_references, 
        :docs_block,
        :doctest,
        :eval_block,
        :example_block,
        :footnote,
        :linkcheck_remotes,
        :linkcheck,
        :meta_block,
        #:missing_docs, 
        :parse_error,
        :setup_block
    )
)

deploydocs(;
    repo = "github.com/martinkosch/Open62541.jl",
    devbranch = "main")
