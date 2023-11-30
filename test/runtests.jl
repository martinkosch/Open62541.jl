using SafeTestsets

@safetestset "Aqua" begin
    include("aqua.jl")
end

@safetestset "Exceptions" begin
    include("exceptions.jl")
end

@safetestset "Basic data handling" begin
    include("data_handling.jl")
end

@safetestset "Server Read Functions" begin
    include("server_read.jl")
end

@safetestset "Simple Server/Client" begin
    include("simple_server_client.jl") #XXX: works locally, but not on CI
end

@safetestset "Add, read, change scalar variables" begin
    include("add_change_var_scalar.jl")
end

@safetestset "Add, read, change array variables" begin
    include("add_change_var_array.jl")
end
