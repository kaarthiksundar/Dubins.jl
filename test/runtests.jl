using Dubins
using Memento

setlevel!(getlogger(Dubins), "error")

using Base.Test

@testset "Dubins" begin
    include("test_api.jl")
end
