
@testset "test shortest path" begin
    path = DubinsPath()
    errcode = dubins_shortest_path(path, zeros(3), [1., 0., 0.], 1.)
    @test errcode == EDUBOK
end

@testset "test invalid ρ" begin
    path = DubinsPath()
    errcode = dubins_shortest_path(path, zeros(3), [1., 0., 0.], -1.)
    @test errcode == EDUBBADRHO
end

@testset "test no path" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [10., 0., 0.], 1., LRL)
    @test errcode == EDUBNOPATH
end

@testset "test path length" begin
    path = DubinsPath()
    errcode = dubins_shortest_path(path, zeros(3), [4., 0., 0.], 1., LRL)
    @test errcode == EDUBNOPATH
    path_length = dubins_path_length(path)
    @test isapprox(path_length, 4., atol=1e-3)
end

@testset "test simple path" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [1., 0., 0.], 1., LSL)
    @test errcode == EDUBOK
end

@testset "test segment lengths" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK
    @test dubins_segment_length_normalized(path, 0) == Inf
    @test dubins_segment_length_normalized(path, 1) == 0.
    @test dubins_segment_length_normalized(path, 2) == 4.
    @test dubins_segment_length_normalized(path, 3) == 0.
    @test dubins_segment_length_normalized(path, 4) == Inf
end 

@testset "test sample" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK

    qsamp = zeros(3)
    errcode = dubins_path_sample(path, 0., qsamp)
    @test errcode == EDUBOK
    @test qsamp == zeros(3)

    errcode = dubins_path_sample(path, 0., qsamp)
    @test errcode == EDUBOK
    @test qsamp == [4., 0., 0.]
end 

@testset "test sample out of bounds" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK

    qsamp = zeros(3)
    errcode = dubins_path_sample(path, -1., qsamp)
    @test errcode == EDUBPARAM

    errcode = dubins_path_sample(path, 5., qsamp)
    @test errcode == EDUBPARAM
end 

@testset "test sample many LSL" begin
    path = DubinsPath()
    errcode = dubins_path(path, [0., 0., π/2], [4., 0., -π/2], 1., LSL)
    @test errcode == EDUBOK

    nop_cb(q::Vector{Float64}, x::Float64; kwargs...) = 0
    errcode = dubins_path_sample_many(path, 1., nop_cb)
    @test errcode == 0
end 

@testset "test sample many RLR" begin
    path = DubinsPath()
    errcode = dubins_path(path, [0., 0., π/2], [4., 0., -π/2], 1., RLR)
    @test errcode == EDUBOK

    nop_cb(q::Vector{Float64}, x::Float64; kwargs...) = 0
    errcode = dubins_path_sample_many(path, 1., nop_cb)
    @test errcode == 0
end 

@testset "test sample many opt-out early" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK

    opt_out_early_cb(q::Vector{Float64}, x::Float64; count = 0, kwargs...) = (count > 0) ? 1 : 0
    errcode = dubins_path_sample_many(path, 1., opt_out_early_cb; count = 1)
    @test errcode == 1
end

@testset "test path type" begin
    path = DubinsPath()
    for i in 0:5
        path_type::DubinsPathType = (DubinsPathType)(i)
        errcode = dubins_path(path, zeros(3), [1., 0., 0.], 1., path_type)
        (errcode == EDUBOK) && (@test dubins_path_type(path) == path_type)
    end
end 

@testset "test end point" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK
    
    qsamp = zeros(3)
    errcode = dubins_path_endpoint(path, qsamp)
    @test isapprox(qsamp, [4., 0., 0.], atol=10e-8)
end 

@testset "test extract sub-path" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK
    
    subpath = DubinsPath()
    errcode = dubins_extract_subpath(path, 2., subpath)
    @test errcode == EDUBOK
    
    qsamp = zeros(3)
    errcode = dubins_path_endpoint(path, qsamp)
    @test isapprox(qsamp, [2., 0., 0.], atol=10e-8)
end 

@testset "test extract invalid sub-path" begin
    path = DubinsPath()
    errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)
    @test errcode == EDUBOK
    
    subpath = DubinsPath()
    errcode = dubins_extract_subpath(path, 8., subpath)
    @test errcode == EDUBPARAM   
end 

