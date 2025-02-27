
# @testset "test allocations shortest path" begin
#     q0 = zeros(3)
#     q1 = [1.0, 0.0, 0.0]

#     m = @allocated dubins_shortest_path(q0, q1, 1.0)
#     println(m)
#     m = @allocated dubins_shortest_path(q0, q1, 1.0)
#     println(m)
# end

@testset "test allocations shortest path static" begin
    q0 = @SVector zeros(3)
    q1 = @SVector [1.0, 0.0, 0.0]

    # precompile
    dubins_shortest_path(q0, q1, 1.0)

    m = @allocated dubins_shortest_path(q0, q1, 1.0)
    @test m == 0
end




@testset "test allocations path length static" begin
    q0 = @SVector zeros(3)
    q1 = @SVector [4.0, 0.0, 0.0]
    errcode, path = dubins_shortest_path(q0, q1, 1.0)
    @test errcode == EDUBOK

    m = @allocated dubins_path_length(path)
    @test m == 0
end

@testset "test allocations simple path static" begin
    q0 = @SVector [0,0,0.0]
    q1 = @SVector [1.0, 0,0]

    m = @allocated  begin
    errcode, path = dubins_path(q0, q1, 1.0, LSL)
    end
    @test errcode == EDUBOK
    @test m == 0
end

@testset "test allocations segment lengths static" begin
    errcode, path = dubins_path(zeros(3), [4.0, 0.0, 0.0], 1.0, LSL)
    @test errcode == EDUBOK
    m0 = @allocated dubins_segment_length_normalized(path, 0)
    m1 = @allocated dubins_segment_length_normalized(path, 1)
    m2 = @allocated dubins_segment_length_normalized(path, 2)
    m3 = @allocated dubins_segment_length_normalized(path, 3)
    m4 = @allocated dubins_segment_length_normalized(path, 4)
    @test m0 == 0
    @test m1 == 0
    @test m2 == 0
    @test m3 == 0
    @test m4 == 0
end

@testset "test allocations sample static" begin
    errcode, path = dubins_path(zeros(3), [4.0, 0.0, 0.], 1.0, LSL)
    @test errcode == EDUBOK

    # precompile
    dubins_path_sample(path, 0.0)

    m0 = @allocated begin
        errcode, qsamp = dubins_path_sample(path, 0.0)
    end
    @test errcode == EDUBOK
    @test m0 == 0

    m1 = @allocated begin
        errcode, qsamp = dubins_path_sample(path, 4.0)
    end
    @test errcode == EDUBOK
    @test m1 == 0
end

@testset "test allocations end point static" begin
    q0 = SVector{3, Float64}(0,0,0)
    q1 = SVector{3, Float64}(4,0,0)
    errcode, path = dubins_path(q0, q1, 1.0, LSL)
    @test errcode == EDUBOK

    m = @allocated begin 
        errcode, qsamp = dubins_path_endpoint(path)
    end
    @test isapprox(qsamp, [4.0, 0.0, 0.0], atol=1e-8)
    @test m == 0 broken=true
end

@testset "test allocations extract sub-path static" begin
    errcode, path = dubins_path(zeros(3), [4.0, 0.0, 0.0], 1.0, LSL)
    @test errcode == EDUBOK

    m1 = @allocated begin
    errcode, subpath = dubins_extract_subpath(path, 3.0)
    end
    @test errcode == EDUBOK
    @test m1 == 0

    # precompile
    dubins_path_endpoint(subpath)
    m2 = @allocated begin
    errcode, qsamp = dubins_path_endpoint(subpath)
    end
    @test isapprox(qsamp, [3.0, 0.0, 0.0], atol=1e-8)
    @test m2 == 0 broken=true #TODO: need to fix
end
