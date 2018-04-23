using Dubins
using Memento

setlevel!(getlogger(Dubins), "error")

using Base.test

@testset "Dubins" begin
    include("test1.jl")
end
