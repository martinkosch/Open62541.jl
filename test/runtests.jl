using SafeTestsets
using Test

const MEMLEAK = get(ENV, "MEMLEAK", false)

@safetestset "Aqua" begin
    include("aqua.jl")
end

@safetestset "Statuscodes" begin
    include("statuscodes.jl")
end

@safetestset "Exceptions" begin
    include("exceptions.jl")
end

@safetestset "Callback generators" begin
    include("callbacks.jl")
end

@safetestset "Basic types and functions" begin
    include("basic_types_and_functions.jl")
end

@safetestset "High level types" begin
    include("highlevel_types.jl")
end

@safetestset "Basic data handling" begin
    include("data_handling.jl")
end

@safetestset "NodeIds" begin
    include("nodeids.jl")
end

@safetestset "Attribute generation" begin
    include("attribute_generation.jl")
end

@safetestset "Server configurations" begin
    include("server_config.jl")
end

@safetestset "Server Access Control" begin
    include("server_accesscontrol.jl")
end

@safetestset "Server Read Functions" begin
    include("server_read.jl")
end

@safetestset "Server Write Functions" begin
    include("server_write.jl")
end

@safetestset "Server Monitored Items" begin
    include("server_monitoreditems.jl")
end

@safetestset "Server Add Nodes" begin
    include("server_add_nodes.jl")
end

@safetestset "Server Add Nodes Highlevel Interface" begin
    include("server_add_nodes_highlevelinterface.jl")
end

if MEMLEAK == true
    @safetestset "Server Memory leaks" begin
        include("server_memoryleaks.jl")
    end
end

#Testsets below here use Distributed; normal testsets required
# !!! Leakage of variables must be assessed manually. !!!
#see: https://github.com/YingboMa/SafeTestsets.jl/issues/13

if MEMLEAK == true
    @testset "Client Memory Leaks" begin
        include("client_memoryleaks.jl")
    end
end

@testset "Simple Server/Client" begin
    include("client_simple.jl")
end

@testset "Client subscriptions" begin
    include("client_subscriptions.jl")
end

@testset "Client read functions" begin
    include("client_read.jl")
end

@testset "Client write functions" begin
    include("client_write.jl")
end

@testset "Client service functions" begin
    include("client_service.jl")
end

@testset "Client call method" begin
    include("client_callmethod.jl")
end

@testset "Client Add, read, change scalar variables" begin
    include("client_add_change_var_scalar.jl")
end

@testset "Client Add, read, change array variables" begin
    include("client_add_change_var_array.jl")
end

@testset "Client Username/password login & access control" begin
    include("client_username_password_login_accesscontrol.jl")
end

@testset "Encryption" begin
    include("client_encryption.jl")
end
