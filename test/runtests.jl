using Dubins
using Memento

using Compat.Test

setlevel!(getlogger(Dubins), "error")


@testset "Dubins" begin
    include("test_api.jl")
    include("test_path.jl")
end
