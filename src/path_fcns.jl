
export
    dubins_shortest_path, dubins_path,
    dubins_path_length, dubins_segment_length,
    dubins_segment_length_normalized,
    dubins_path_type, dubins_path_sample,
    dubins_path_sample_many, dubins_path_endpoint,
    dubins_extract_subpath

"""
Generate a path from an initial configuration to a target configuration with a specified maximum turning radius

A configuration is given by ``[x, y, \\theta]``, where ``\\theta`` is in radians,

* ``q_0``        - a configuration specified by a 3-element vector ``[x, y, \\theta]``
* ``q_1``        - a configuration specified by a 3-element vector ``[x, y, \\theta]``
* ``\\rho``      - turning radius of the vehicle
* return    - tuple (error code, dubins path). If error code != 0, then `nothing` is returned as the second argument
"""
function dubins_shortest_path(q0::VF, q1::VF, ρ::F) where {F, VF <: AbstractVector{F}}

    # input checking
    @assert length(q0) == 3
    @assert length(q1) == 3
    (ρ <= 0) && (return EDUBBADRHO, DubinsPath{F}())


    best_cost = Inf
    best_word = -1
    best_params = SVector{3, F}(0,0,0) 
    intermediate_results = DubinsIntermediateResults(q0, q1, ρ)
    best_path_type = LSL

    for i in 0:5
        path_type = DubinsPathType(i)
        errcode, params = dubins_word(intermediate_results, path_type)
        if errcode == EDUBOK
            cost = sum(params)
            if cost < best_cost
                best_word = i
                best_cost = cost
                best_params = params
                best_path_type = path_type
            end
        end
    end

    # exit if no best word
    (best_word == -1) && (return EDUBNOPATH, DubinsPath{F}())

    # construct the best path
    path = DubinsPath(q0, best_params, ρ, best_path_type)

    return EDUBOK, path
end

"""
Generate a path with a specified word from an initial configuratioon to a target configuration, with a specified turning radius

* ``q_0``       - a configuration specified by a 3-element vector ``x``, ``y``, ``\\theta``
* ``q_1``       - a configuration specified by a 3-element vector ``x``, ``y``, ``\\theta``
* ``\\rho``     - turning radius of the vehicle
* path_type - the specified path type to use
* return    - tuple (error code, dubins path). If error code != 0, then `nothing` is returned as the second argument
"""
function dubins_path(q0::VF, q1::VF, ρ::F, path_type::DubinsPathType) where {F, VF<:AbstractVector{F}}

    # input checking
    @assert length(q0) ==  3
    @assert length(q1) == 3
    (ρ <= 0) && (return EDUBBADRHO, DubinsPath{F}())


    intermediate_results = DubinsIntermediateResults(q0, q1, ρ)

    errcode, params = dubins_word(intermediate_results, path_type)
    if errcode == EDUBOK
        path = DubinsPath(q0, params, ρ, path_type)
        return EDUBOK, path
    end
    (errcode != EDUBOK) && (return errcode, DubinsPath{F}())
end


"""
Calculate the length of an initialized path

* path      - path to find the length of
* return    - path length
"""
dubins_path_length(path::DubinsPath) = sum(path.params)*path.ρ


"""
Calculate the length of a specific segment of  an initialized path

* path      - path to find the length of
* ``i``     - the segment for which the length is required (1-3)
* return    - segment length
"""
dubins_segment_length(path::DubinsPath, i::Int) = (i<1 || i>3) ? (return Inf) : (return path.params[i]*path.ρ)

"""
Calculate the normalized length of a specific segment of  an initialized path

* path      - path to find the length of
* ``i``     - the segment for which the length is required (1-3)
* return    - normalized segment length
"""
dubins_segment_length_normalized(path::DubinsPath, i::Int) = (i<1 || i>3) ? (return Inf) : (return path.params[i])

"""
Extract the integer that represents which path type was used

* path      - an initialized path
* return    - one of LSL-0, LSR-1, RSL-2, RSR-3, RLR-4, LRL-5
"""
dubins_path_type(path::DubinsPath) = path.path_type

"""
Operators that transform an arbitrary point ``q_i``, ``[x, y, \\theta]``, into an image point given a parameter ``t`` and segment type

The three operators correspond to ``L``, ``R``, and ``S``

 * ``L(x, y, \\theta, t) = [x, y, \\theta] + [ \\sin(\\theta + t) - \\sin(\\theta), -\\cos(\\theta + t) + \\cos(\\theta),  t]``
 * ``R(x, y, \\theta, t) = [x, y, \\theta] + [-\\sin(\\theta - t) + \\sin(\\theta),  \\cos(\\theta - t) - \\cos(\\theta), -t]``
 * ``S(x, y, \\theta, t) = [x, y, \\theta] + [ \\cos(\\theta) \\cdot t, \\sin(\\theta) \\cdot t, 0]``

 * return    -  the image point as a 3-element vector
"""
function dubins_segment(t::F, qi::VF, segment_type::SegmentType) where {F, VF <: AbstractVector{F}}

    st = sin(qi[3])
    ct = cos(qi[3])

    if segment_type == L_SEG
        qt1 = +sin(qi[3]+t) - st
        qt2 = -cos(qi[3]+t) + ct
        qt3 = t
        qt = SVector{3, F}(qt1, qt2, qt3)
    elseif segment_type == R_SEG
        qt1 = -sin(qi[3]-t) + st
        qt2 = +cos(qi[3]-t) - ct
        qt3 = -t
        qt = SVector{3, F}(qt1, qt2, qt3)
    elseif segment_type == S_SEG
        qt1 = ct * t
        qt2 = st * t
        qt3 = 0.0
        qt = SVector{3, F}(qt1, qt2, qt3)
    end

    return qt + qi # should return SVector even if qi is a Vector
end

"""
Calculate the configuration along the path, using the parameter t

 * path      - an initialized path
 * ``t``         - length measure where ``0 \\leq t <`` [`dubins_path_length`](@ref)(path)
 * return    - tuple containing non-zero error code if 't' is not in the correct range and the configuration result ``[x, y, \\theta]``
"""
function dubins_path_sample(path::DubinsPath{F}, t::F) where {F}
    
    (t < 0 || t > dubins_path_length(path)) && (return EDUBPARAM, path.qi)

    # tprime is the normalized variant of the parameter t
    tprime = t/path.ρ
    segment_types = DIRDATA[path.path_type]

    # initial configuration
    qi = SVector{3, F}(0, 0, path.qi[3])

    # generate target configuration
    p1 = path.params[1]
    p2 = path.params[2]
    q1 = dubins_segment(p1, qi, segment_types[1])
    q2 = dubins_segment(p2, q1, segment_types[2])
    if tprime < p1
        q = dubins_segment(tprime, qi, segment_types[1])
    elseif tprime < (p1+p2)
        q = dubins_segment(tprime-p1, q1, segment_types[2])
    else
        q = dubins_segment(tprime-p1-p2, q2, segment_types[3])
    end

    # scale the target configuration, translate back to the original starting point
    qs1 = q[1] * path.ρ + path.qi[1]
    qs2 = q[2] * path.ρ + path.qi[2]
    qs3 = mod2pi(q[3]);
    qs = SVector{3, F}(qs1, qs2, qs3)

    return EDUBOK, qs
end


"""
Walk along the path at a fixed sampling interval, calling the callback function at each interval

The sampling process continues until the whole path is sampled, or the callback returns a non-zero value

 * path         - the path to sample
 * step_size    - the distance along the path for subsequent samples

 * return       - tuple (error code, configuration vector). If error code != 0, then `nothing` is returned as the second argument
 """
function dubins_path_sample_many(path::DubinsPath{F}, step_size::F) where {F}

    configurations = SVector{3, F}[]

    L = dubins_path_length(path)
    (step_size < 0 || step_size > L) && (return EDUBPARAM, configurations)

    x = zero(F)


    while x < L
        errcode, q = dubins_path_sample(path, x)
        push!(configurations, q)
        (errcode != 0) && (return errcode, configurations)
        x += step_size
    end

    return EDUBOK, configurations
end

"""
Convenience function to identify the endpoint of a path

 * path          - an initialized path
 * return        - tuple containing (zero on successful completion and the end configuration ``[x,y,\\theta]``)
"""
dubins_path_endpoint(path::DubinsPath{F}, tol=1e-9) where {F} = dubins_path_sample(path, dubins_path_length(path) - tol)

"""
Convenience function to extract a sub-path

 * path          - an initialized path
 * ``t``             - a length measure, where ``0 < t <`` [`dubins_path_length`](@ref)(path)
 * return        - zero on successful completion and the subpath
"""
function dubins_extract_subpath(path::DubinsPath{F}, t::F) where {F}


    ((t < 0) || (t > dubins_path_length(path))) && (return EDUBPARAM, path)

    # calculate the true parameter
    tprime = t / path.ρ;

    # fix the parameters
    newpath_params1 = min(path.params[1], tprime)
    newpath_params2 = min(path.params[2], tprime - newpath_params1)
    newpath_params3 = min(path.params[3], tprime - newpath_params1 - newpath_params2)
    newpath_params = SVector{3, F}(newpath_params1, newpath_params2, newpath_params3)

    # construct the new path (mostly copy old params)
    newpath = DubinsPath(
        path.qi,
        newpath_params,
        path.ρ,
        path.path_type
    )

    return EDUBOK, newpath
end


"""
The function to call the corresponding Dubins path based on the path_type

* return        - tuple (error code, path length as a vector for corresponding path type)
"""
function dubins_word(intermediate_results::DubinsIntermediateResults{F}, path_type::DubinsPathType) where {F}

    if path_type == LSL
        result, out = dubins_LSL(intermediate_results)
    elseif path_type == RSL
        result, out = dubins_RSL(intermediate_results)
    elseif path_type == LSR
        result, out = dubins_LSR(intermediate_results)
    elseif path_type == RSR
        result, out = dubins_RSR(intermediate_results)
    elseif path_type == LRL
        result, out = dubins_LRL(intermediate_results)
    elseif path_type == RLR
        result, out = dubins_RLR(intermediate_results)
    else
        result, out = EDUBNOPATH, SVector{3,F}(0,0,0.)
    end

    return result, out
end

# """
# Reset tolerance value
# """
# function set_tolerance(ϵ::Float64)
#     TOL = ϵ
#     return
# end
