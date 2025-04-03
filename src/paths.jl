function cleanup_loop(x::F, tol::F) where {F}
    if x >= 2π - tol
        return zero(F)
    else
        return x
    end
end

function dubins_LSL(intermediate_results::DubinsIntermediateResults{F}, loop_tol::F) where {F}

    tmp0 = intermediate_results.d + intermediate_results.sa - intermediate_results.sb
    p_sq =
        2 + intermediate_results.d_sq - (2 * intermediate_results.c_ab) +
        (2 * intermediate_results.d * (intermediate_results.sa - intermediate_results.sb))

    if p_sq >= 0
        tmp1 = atan((intermediate_results.cb - intermediate_results.ca), tmp0)
        out1 = cleanup_loop(mod2pi(tmp1 - intermediate_results.α), loop_tol)
        out2 = sqrt(p_sq)
        out3 = cleanup_loop(mod2pi(intermediate_results.β - tmp1), loop_tol)    
        out = SVector{3,F}(out1, out2, out3)
        return EDUBOK, out
    end

    return EDUBNOPATH, SVector{3,F}(0, 0, 0)
end

function dubins_RSR(intermediate_results::DubinsIntermediateResults{F}, loop_tol::F) where {F}

    tmp0 = intermediate_results.d - intermediate_results.sa + intermediate_results.sb
    p_sq =
        2 + intermediate_results.d_sq - (2 * intermediate_results.c_ab) +
        (2 * intermediate_results.d * (intermediate_results.sb - intermediate_results.sa))

    if p_sq >= 0
        tmp1 = atan((intermediate_results.ca - intermediate_results.cb), tmp0)
        out1 = cleanup_loop(mod2pi(intermediate_results.α - tmp1), loop_tol)
        out2 = sqrt(p_sq)
        out3 = cleanup_loop(mod2pi(tmp1 - intermediate_results.β), loop_tol)
        out = SVector{3,F}(out1, out2, out3)
        return EDUBOK, out
    end

    return EDUBNOPATH, SVector{3,F}(0, 0, 0)
end

function dubins_LSR(intermediate_results::DubinsIntermediateResults{F}, loop_tol::F) where {F}

    p_sq =
        -2 +
        (intermediate_results.d_sq) +
        (2 * intermediate_results.c_ab) +
        (2 * intermediate_results.d * (intermediate_results.sa + intermediate_results.sb))

    if p_sq >= 0
        p = sqrt(p_sq)
        tmp0 =
            atan(
                (-intermediate_results.ca - intermediate_results.cb),
                (
                    intermediate_results.d +
                    intermediate_results.sa +
                    intermediate_results.sb
                ),
            ) - atan(-2.0, p)
        out1 = cleanup_loop(mod2pi(tmp0 - intermediate_results.α), loop_tol)
        out2 = p
        out3 = cleanup_loop(mod2pi(tmp0 - mod2pi(intermediate_results.β)), loop_tol)
        out = SVector{3,F}(out1, out2, out3)
        return EDUBOK, out
    end

    return EDUBNOPATH, SVector{3,F}(0, 0, 0)
end

function dubins_RSL(intermediate_results::DubinsIntermediateResults{F}, loop_tol::F) where {F}


    p_sq =
        -2 + intermediate_results.d_sq + (2 * intermediate_results.c_ab) -
        (2 * intermediate_results.d * (intermediate_results.sa + intermediate_results.sb))

    if p_sq >= 0
        p = sqrt(p_sq)
        tmp0 =
            atan(
                (intermediate_results.ca + intermediate_results.cb),
                (
                    intermediate_results.d - intermediate_results.sa -
                    intermediate_results.sb
                ),
            ) - atan(2.0, p)
        out1 = cleanup_loop(mod2pi(intermediate_results.α - tmp0), loop_tol)
        out2 = p
        out3 = cleanup_loop(mod2pi(intermediate_results.β - tmp0), loop_tol)
        out = SVector{3,F}(out1, out2, out3)
        return EDUBOK, out
    end

    return EDUBNOPATH, SVector{3,F}(0, 0, 0)
end

function dubins_RLR(intermediate_results::DubinsIntermediateResults{F}, loop_tol::F) where {F}

    tmp0 =
        (
            6.0 - intermediate_results.d_sq +
            2 * intermediate_results.c_ab +
            2 * intermediate_results.d * (intermediate_results.sa - intermediate_results.sb)
        ) / 8.0
    phi = atan(
        intermediate_results.ca - intermediate_results.cb,
        intermediate_results.d - intermediate_results.sa + intermediate_results.sb,
    )

    if abs(tmp0) <= 1
        p = mod2pi((2 * π) - acos(tmp0))
        t = mod2pi(intermediate_results.α - phi + mod2pi(p / 2.0))
        out1 = cleanup_loop(t, loop_tol)
        out2 = cleanup_loop(p, loop_tol)
        out3 = mod2pi(intermediate_results.α - intermediate_results.β - t + mod2pi(p))
        out3 = cleanup_loop(out3, loop_tol)
        out = SVector{3,F}(out1, out2, out3)
        return EDUBOK, out
    end

    return EDUBNOPATH, SVector{3,F}(0, 0, 0)
end

function dubins_LRL(intermediate_results::DubinsIntermediateResults{F}, loop_tol::F) where {F}

    tmp0 =
        (
            6.0 - intermediate_results.d_sq +
            2 * intermediate_results.c_ab +
            2 * intermediate_results.d * (intermediate_results.sb - intermediate_results.sa)
        ) / 8.0
    phi = atan(
        intermediate_results.ca - intermediate_results.cb,
        intermediate_results.d + intermediate_results.sa - intermediate_results.sb,
    )

    if abs(tmp0) <= 1
        p = mod2pi(2 * π - acos(tmp0))
        t = mod2pi(-intermediate_results.α - phi + p / 2.0)
        out1 = cleanup_loop(t, loop_tol)
        out2 = cleanup_loop(p, loop_tol)
        out3 =
            mod2pi(
                mod2pi(intermediate_results.β) - intermediate_results.α - t + mod2pi(p),
            )
        out3 = cleanup_loop(out3, loop_tol)
        out = SVector{3,F}(out1, out2, out3)
        return EDUBOK, out
    end

    return EDUBNOPATH, SVector{3,F}(0, 0, 0)
end
