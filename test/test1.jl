@testset "test dubins shortest path length" begin
    path = DubinsPath()
    errcode = dubins_shortest_path(path, q0=zeros(0), q1, ρ::Float64)
    @test errcode == 0
    path_length = dubins_path_length(path)
    @test isapprox(path_length, 8.2725, atol=1e-3)
end
