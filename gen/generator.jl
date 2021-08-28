using Clang.Generators
using open62541_jll

cd(@__DIR__)

include_dir = joinpath(open62541_jll.artifact_dir, "include") |> normpath
open62541_header = joinpath(include_dir, "open62541.h") |> normpath
@assert isfile(open62541_header)

options = load_options(joinpath(@__DIR__, "generator.toml"))

# Add compiler flags
args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "-std=c99")

# Create context
ctx = create_context([open62541_header], args, options)

# Run generator
build!(ctx)