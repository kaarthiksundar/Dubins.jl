export 
    DubinsPathType, SegmentType


@enum DubinsPathType LSL LSR RSL RSR RLR LRL
@enum SegmentType L_SEG S_SEG R_SEG

DIRDATA = Dict{Int,Vector{SegmentType}}(
                                        Int(LSL) => [L_SEG, S_SEG, L_SEG],
                                        Int(LSR) => [L_SEG, S_SEG, R_SEG],
                                        Int(RSL) => [R_SEG, S_SEG, L_SEG],
                                        Int(RSR) => [R_SEG, S_SEG, R_SEG],
                                        Int(RLR) => [R_SEG, L_SEG, R_SEG],
                                        Int(LRL) => [L_SEG, R_SEG, L_SEG]
                                       )


type DubinsPath
    qi::Vector{Float64}         # the initial configuration
    param::Vector{Float64}      # the lengths of the three segments
    ρ::Float64                  # turn radius
    path_type::DubinsPathType   # the path type described
end

DubinsPath() = DubinsPath(zeros(3), zeros(3), 1., LSL)

type DubinsIntermediateResults
    α::Float64                  # transformed α
    β::Float64                  # transformed β
    d::Float64                  # transformed d
    sa::Float64
    sb::Float64
    ca::Float64
    cb::Float64
    c_ab::Float64
    d_sq::Float64
end

DubinsIntermediateResults() = DubinsIntermediateResults(0.,0.,0.,0.,0.,0.,0.,0.,0.)

const EDUBOK = 0                # no error
const EDUBCOCONFIGS = 1         # colocated configurations
const EDUBPARAM = 2             # path parameterization error
const EDUBBADRHO = 3            # the rho value is invalid
const EDUBNOPATH = 4            # no connection between configurations with this word
const TOL = 10e-10              # tolerance


"""
Generate a path from an initial configuration to a target configuration with a specified maximum turning radius

A configuration (x, y, theta), where theta is in radians, with zero along the line x = 0, and counter-clockwise is positive

* path      - resultant path
* q0        - a configuration specified by a 3-element vector x, y, theta
* q1        - a configuration specified by a 3-element vector x, y, theta
* rho       - turning radius of the vehicle
* return    - non-zero value on error
"""
function dubins_shortest_path(path::DubinsPath, q0::Vector{Float64}, q1::Vector{Float64}, ρ::Float64)

    # input checking
    @assert length(q0) ==  3
    @assert length(q1) == 3
    (ρ <= 0) && (return EDUBBADRHO)

    intermediate_results = DubinsIntermediateResults();
    params = zeros(3)

    best_cost = Inf
    best_word = -1
    errcode = dubins_intermediate_results(intermediate_results, q0, q1, ρ)
    (errcode != EDUBOK) && (return errcode)

    path.qi[1] = q0[1]
    path.qi[2] = q0[2]
    path.qi[3] = q0[3]
    path.ρ = ρ

    for i in 0:5
        path_type = DubinsPathType(i)
        errcode = dubins_word(intermediate_results, path_type, params)
        if errcode == EDUBOK
            cost = sum(params)
            if cost < best_cost
                best_word = i
                best_cost = cost
                path.param[1] = params[1]
                path.param[2] = params[2]
                path.param[3] = params[3]
                path.path_type = path_type
            end
        end
        println(path)
    end
    println(path)
    (best_word == -1) && (return EDUBNOPATH)
    return EDUBOK
end

"""
Generate a path with a specified word from an initial configuratioon to a target configuration, with a specified turning radius

* path      - resultant path
* q0        - a configuration specified by a 3-element vector x, y, theta
* q1        - a configuration specified by a 3-element vector x, y, theta
* rho       - turning radius of the vehicle
* path_type - the specified path type to use
* return    - non-zero value on error
"""
function dubins_path(path::DubinsPath, q0::Vector{Float64}, q1::Vector{Float64}, rho::Float64, path_type::DubinsPathType)

    intermediate_results = DubinsIntermediateResults()
    errcode = dubins_intermediate_results(intermediate_results, q0, q1, rho);

    if errcode == EDUBOK
        params = zeros(3)
        errocode = dubins_word(intermediate_results, path_type, params)
        if errcode == EDUBOK
            path.param[1] = params[1]
            path.param[2] = params[2]
            path.param[3] = params[3]
            path.qi[1] = q0[1]
            path.qi[2] = q0[2]
            path.qi[3] = q0[3]
            path.rho = rho
            path.path_type = path_type
        end
    end

    return errcode
end


"""
Calculate the length of an initialized path

* path      - path to find the length of
* return    - path length
"""
dubins_path_length(path::DubinsPath) = sum(path.param)*path.ρ


"""
Calculate the length of a specific segment of  an initialized path

* path      - path to find the length of
* i         - the segment for which the length is required (1-3)
* return    - segment length
"""
dubins_segment_length(path::DubinsPath, i::Int) = (i<1 || i>3) ? (return Inf) : (return path.param[i]*path.ρ)

"""
Calculate the normalized length of a specific segment of  an initialized path

* path      - path to find the length of
* i         - the segment for which the length is required (1-3)
* return    - normalized segment length
"""
dubins_segment_length_normalized(path::DubinsPath, i::Int) = (i<1 || i>3) ? (return Inf) : (return path.param[i])

"""
Extract the integer that represents which path type was used

* path      - an initialized path
* return    - one of LSL, LSR, RSL, RSR, RLR, LRL
"""
dubins_path_type(path::DubinsPath) = path.path_type

"""
dubins_segment()
"""
function dubins_segment(t::Float64, qi::Vector{Float64}, qt::Vector{Float64}, segment_type::SegmentType)

    st = sin(qi[3])
    ct = cos(qi[3])

    if segment_type == L_SEG
        qt[1] = +sin(qi[3]+t) - st
        qt[2] = -cos(qi[3]+t) + ct
        qt[3] = t
    elseif segment_type == R_SEG
        qt[1] = -sin(qi[3]-t) + st
        qt[2] = +cos(qi[3]-t) - ct
        qt[3] = -t
    elseif segment_type == S_SEG
        qt[1] = ct * t
        qt[2] = st * t
        qt[3] = 0.0
    end
    qt = qt + qi

    return
end

"""
Calculate the configuration along the path, using the parameter t

* path      - an initialized path
* t         - length measure where 0 <= t < dubins_path_length(path)
* q         - the configuration result
* return    - non-zero if 't' is not in the correct range
"""
function dubins_path_sample(path::DubinsPath, t::Float64, q::Vector{Float64})

    # tprime is the normalised variant of the parameter t
    tprime = t/path.rho
    qi = zeros(3)
    q1 = zeros(3)
    q2 = zeros(3)
    segment_types = DIRDATA[Int(path.path_type)]

    (t < 0 || t > dubins_path_length(path)) && (return EDUBPARAM)

    # initial configuration
    qi = [0.0, 0.0, path.qi[3]]

    # generate target configuration
    p1 = path.param[1]
    p2 = path.param[2]
    dubins_segment(p1, qi, q1, segment_types[1])
    dubins_segment(p2, q1, q2, segment_types[2])
    if tprime < p1
        dubins_segment(tprime, q1, q, segment_types[1])
    elseif tprime < (p1+p2)
        dubins_segment(tprime-p1, q1, q, segment_types[2])
    else
        dubins_segment(tprime-p1-p2, q2, q, segment_types[3])
    end

    # scale the target configuration, translate back to the original starting point
    q[1] = q[1] * path.rho + path.qi[1];
    q[1] = q[1] * path.rho + path.qi[2];
    q[3] = mod2pi(q[3]);

    return EDUBOK;
end

"""
Walk along the path at a fixed sampling interval, calling the callback function at each interval

The sampling process continues until the whole path is sampled, or the callback returns a non-zero value

 * path         - the path to sample
 * step_size    - the distance along the path for subsequent samples
 * cb           - the callback function to call for each sample
 * user_data    - optional information to pass on to the callback
 * return       - zero on successful completion, or the result of the callback
 """
function dubins_path_sample_many(path::DubinsPath, step_size::Float64, cb_function; kwargs...)
    q = zeros(3)
    x = 0.0
    length = dubins_path_length(path)
    while x < length
        dubins_path_sample(path, x, q)
        retcode = cb_function(q, x; kwargs...)
        (retcode != 0) && (return retcode)
        x += step_size
    end
    return 0
end

"""
Convenience function to identify the endpoint of a path

* path          - an initialized path
* q             - the configuration result
* return        - zero on successful completion
"""
dubins_path_endpoint(path::DubinsPath, q::Vector{Float64}) = dubins_path_sample(path, dubins_path_length(path) - TOL, q)

"""
Convenience function to extract a subset of a path

* path          - an initialized path
* t             - a length measure, where 0 < t < dubins_path_length(path)
* newpath       - the resultant path
* return        - zero on successful completion
"""
function dubins_extract_subpath(path::DubinsPath, t::Float64, newpath::DubinsPath)

    # calculate the true parameter
    tprime = t / path.ρ;

    ((t < 0) || (t > dubins_path_length(path))) && (return EDUBPARAM)

    # copy most of the data
    newpath.qi[1] = path.qi[1]
    newpath.qi[2] = path.qi[2]
    newpath.qi[3] = path.qi[3]
    newpath.ρ = path.ρ
    newpath.path_type = path.path_type

    # fix the parameters
    newpath.param[1] = min(path.param[1], tprime)
    newpath.param[2] = min(path.param[2], tprime - newpath.param[1])
    newpath.param[3] = min(path.param[3], tprime - newpath.param[1] - newpath.param[2])
    return 0
end

"""
dubins path calculation
"""
function dubins_LSL(intermediate_results::DubinsIntermediateResults, out::Vector{Float64})

    tmp0 = intermediate_results.d + intermediate_results.sa - intermediate_results.sb
    p_sq = 2 + intermediate_results.d_sq - (2*intermediate_results.c_ab) +
            (2 * intermediate_results.d * (intermediate_results.sa - intermediate_results.sb))

    if p_sq >= 0
        tmp1 = atan2((intermediate_results.cb - intermediate_results.ca), tmp0)
        out[1] = mod2pi(tmp1 - intermediate_results.α)
        out[2] = sqrt(p_sq)
        out[3] = mod2pi(intermediate_results.β - tmp1)
        return EDUBOK
    end
    return EDUBNOPATH
end

function dubins_RSR(intermediate_results::DubinsIntermediateResults, out::Vector{Float64})

    tmp0 = intermediate_results.d - intermediate_results.sa + intermediate_results.sb
    p_sq = 2 + intermediate_results.d_sq - (2 * intermediate_results.c_ab) +
            (2 * intermediate_results.d * (intermediate_results.sb - intermediate_results.sa))

    if p_sq >= 0
        tmp1 = atan2((intermediate_results.ca - intermediate_results.cb), tmp0)
        out[1] = mod2pi(intermediate_results.α - tmp1)
        out[2] = sqrt(p_sq)
        out[3] = mod2pi(tmp1 -intermediate_results.β)
        return EDUBOK
    end
    return EDUBNOPATH
end

function dubins_LSR(intermediate_results::DubinsIntermediateResults, out::Vector{Float64})

    p_sq = -2 + (intermediate_results.d_sq) + (2 * intermediate_results.c_ab) +
                    (2 * intermediate_results.d * (intermediate_results.sa + intermediate_results.sb))

    if p_sq >= 0
        p = sqrt(p_sq)
        tmp0 = atan2((-intermediate_results.ca - intermediate_results.cb),
                    (intermediate_results.d + intermediate_results.sa + intermediate_results.sb)) - atan2(-2.0, p)
        out[1] = mod2pi(tmp0 - intermediate_results.α)
        out[2] = p
        out[3] = mod2pi(tmp0 - mod2pi(intermediate_results.β))
        return EDUBOK
    end
    return EDUBNOPATH
end

function dubins_RSL(intermediate_results::DubinsIntermediateResults, out::Vector{Float64})

    p_sq = -2 + intermediate_results.d_sq + (2 * intermediate_results.c_ab) -
            (2 * intermediate_results.d * (intermediate_results.sa + intermediate_results.sb))

    if p_sq >= 0
        p = sqrt(p_sq)
        tmp0 = atan2((intermediate_results.ca + intermediate_results.cb),
                        (intermediate_results.d - intermediate_results.sa - intermediate_results.sb)) - atan2(2.0, p)
        out[1] = mod2pi(intermediate_results.α - tmp0)
        out[2] = p
        out[3] = mod2pi(intermediate_results.β - tmp0)
        return EDUBOK
    end
    return EDUBNOPATH
end

function dubins_RLR(intermediate_results::DubinsIntermediateResults, out::Vector{Float64})

    tmp0 = (6. - intermediate_results.d_sq + 2*intermediate_results.c_ab +
            2*intermediate_results.d*(intermediate_results.sa - intermediate_results.sb)) / 8.
    phi  = atan2(intermediate_results.ca - intermediate_results.cb, intermediate_results.d - intermediate_results.sa + intermediate_results.sb)

    if abs(tmp0) <= 1
        p = mod2pi((2*π) - acos(tmp0))
        t = mod2pi(intermediate_results.α - phi + mod2pi(p/2.))
        out[1] = t
        out[2] = p
        out[3] = mod2pi(intermediate_results.α - intermediate_results.β - t + mod2pi(p))
        return EDUBOK
    end
    return EDUBNOPATH
end

function dubins_LRL(intermediate_results::DubinsIntermediateResults, out::Vector{Float64})

    tmp0 = (6. - intermediate_results.d_sq + 2*intermediate_results.c_ab +
            2*intermediate_results.d*(intermediate_results.sb - intermediate_results.sa)) / 8.
    phi = atan2(intermediate_results.ca - intermediate_results.cb, intermediate_results.d + intermediate_results.sa - intermediate_results.sb)

    if abs(tmp0) <= 1
        p = mod2pi(2*π - acos(tmp0))
        t = mod2pi(-intermediate_results.α - phi + p/2.)
        out[1] = t
        out[2] = p
        out[3] = mod2pi(mod2pi(intermediate_results.β) - intermediate_results.α - t + mod2pi(p))
        return EDUBOK
    end
    return EDUBNOPATH
end


"""
dubins_word function
"""
function dubins_word(intermediate_results::DubinsIntermediateResults, path_type::DubinsPathType, out::Vector{Float64})
    result::Int = 0
    if path_type == LSL
        result = dubins_LSL(intermediate_results, out)
    elseif path_type == RSL
        result = dubins_RSL(intermediate_results, out)
    elseif path_type == LSR
        result = dubins_LSR(intermediate_results, out)
    elseif path_type == RSR
        result = dubins_RSR(intermediate_results, out)
    elseif path_type == LRL
        result = dubins_LRL(intermediate_results, out)
    elseif path_type == RLR
        result = dubins_RLR(intermediate_results, out)
    else
        result = EDUBNOPATH
    end
    return result
end

"""
other mathematical helper functions
"""
fmodr(x::Float64, y::Float64) =  x-y*floor(x/y);
mod2pi(theta::Float64) = fmodr(theta, 2*π);

"""
dubins_intermediate_results
"""
function dubins_intermediate_results(intermediate_results::DubinsIntermediateResults, q0::Vector{Float64}, q1::Vector{Float64}, ρ::Float64)

    (ρ <= 0) && (return EDUBBADRHO)

    dx = q1[1] - q0[1]
    dy = q1[2] - q0[2]
    D = sqrt(dx*dx + dy*dy)
    d = D / ρ
    Θ = 0

    # test required to prevent domain errors if dx=0 and dy=0
    (d > 0) && (Θ = mod2pi(atan2(dy, dx)))
    α = mod2pi(q0[3] - Θ)
    β = mod2pi(q1[3] - Θ)
    intermediate_results.α = α
    intermediate_results.β = β
    intermediate_results.d = d
    intermediate_results.sa = sin(α)
    intermediate_results.sb = sin(β)
    intermediate_results.ca = cos(α)
    intermediate_results.cb = cos(β)
    intermediate_results.c_ab = cos(α-β)
    intermediate_results.d_sq = d*d

    return EDUBOK
end
