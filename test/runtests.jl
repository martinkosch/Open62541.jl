using SafeTestsets

@safetestset "Aqua" begin
    include("aqua.jl")
end

@safetestset "Simple Server/Client" begin
    include("simple_server_client.jl")
end

@safetestset "Add, read, change scalar variables" begin
    include("add_change_var_scalar.jl")
end

@safetestset "Add, read, change array variables" begin
    include("add_change_var_array.jl")
end
