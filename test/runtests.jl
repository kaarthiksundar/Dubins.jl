using Dubins
using StaticArrays
using Test

silence!()


@testset "Dubins" begin
    include("test_api.jl")
    include("test_path.jl")
    include("test_allocations.jl")
    include("test_mod2pi.jl")
end
