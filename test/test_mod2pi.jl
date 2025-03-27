@testset "test Daniels case" begin

    x0 = [92.78421589767785, 120.92422126258732, 6.047809299880998]
    x1 = [102.72481547719133, 124.15922600982667, 0.8646239927014123]

    errcode, path = Dubins.dubins_shortest_path(x0, x1, 10.0)

    @test errcode == EDUBOK

    # @show path

    @test abs(path.params[3]) < 0.1
end


# @testset "test_mod2pi" begin

#     x = 6.283185303630791

#     @show x
#     @show mod2pi(x)
#     # @show Dubins.mymod2pi(x)
#     @show atan(sin(x), cos(x))
# end
