using Dubins
using Memento
using StaticArrays

using Test

setlevel!(getlogger(Dubins), "error")


@testset "Dubins" begin
    include("test_api.jl")
    include("test_path.jl")
    include("test_allocations.jl")
    include("test_mod2pi.jl")
end
