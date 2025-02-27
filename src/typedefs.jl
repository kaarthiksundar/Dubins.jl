export
    DubinsPathType, SegmentType, DubinsPath,
    LSL, LSR, RSL, RSR, RLR, LRL,
    EDUBOK, EDUBCOCONFIGS, EDUBPARAM, EDUBBADRHO, EDUBNOPATH, EDUBBADINPUT

@enum DubinsPathType LSL LSR RSL RSR RLR LRL
@enum SegmentType L_SEG S_SEG R_SEG

# DIRDATA = Dict{Int,SVector{3, SegmentType}}(
#                                         Int(LSL) => (@SVector [L_SEG, S_SEG, L_SEG]),
#                                         Int(LSR) => (@SVector [L_SEG, S_SEG, R_SEG]),
#                                         Int(RSL) => (@SVector [R_SEG, S_SEG, L_SEG]),
#                                         Int(RSR) => (@SVector [R_SEG, S_SEG, R_SEG]),
#                                         Int(RLR) => (@SVector [R_SEG, L_SEG, R_SEG]),
#                                         Int(LRL) => (@SVector [L_SEG, R_SEG, L_SEG])
const DIRDATA = Dict{DubinsPathType,SVector{3, SegmentType}}(
                                        LSL => (@SVector [L_SEG, S_SEG, L_SEG]),
                                        LSR => (@SVector [L_SEG, S_SEG, R_SEG]),
                                        RSL => (@SVector [R_SEG, S_SEG, L_SEG]),
                                        RSR => (@SVector [R_SEG, S_SEG, R_SEG]),
                                        RLR => (@SVector [R_SEG, L_SEG, R_SEG]),
                                        LRL => (@SVector [L_SEG, R_SEG, L_SEG])
                                       )                       

"""
The data structure that holds the full dubins path.

Its data fields are as follows:

* the initial configuration, ``q_i``,
* the params vector that contains the length of each segment, params,
* the turn-radius, ``\\rho``, and,
* the Dubins path type given by the @enum DubinsPathType
"""
struct DubinsPath{F}
    qi::SVector{3, F}            # the initial configuration
    params::SVector{3, F}        # the lengths of the three segments
    ρ::F                     # turn radius
    path_type::DubinsPathType   # the path type
end

function DubinsPath(qi::VF1, params::VF2, ρ::F, path_type) where {F, VF1 <: AbstractVector{F}, VF2 <: AbstractVector{F}}
    @assert length(qi) == 3
    @assert length(params) == 3
    
    return DubinsPath(SVector{3, F}(qi), SVector{3, F}(params), ρ, path_type)
end

"""
Empty constructor for the DubinsPath type
"""
DubinsPath{F}() where {F} = DubinsPath(SVector{3, F}(0,0,0), SVector{3, F}(0,0,0), zero(F), LSL)

"""
This data structure holds the information to compute the Dubins path
in the transformed coordinates where the initial ``(x,y)`` is translated to the
origin, the final the coordinate axis is rotated to make the x-axis aligned with
the line joining the two points. The variable names follow the convention used
in the paper "Classification of the Dubins set" by Andrei M. Shkel and Vladimir Lumelsky
"""
struct DubinsIntermediateResults{F}
    α::F                  # transformed α
    β::F                  # transformed β
    d::F                  # transformed d
    sa::F                 # sin(α)
    sb::F                 # sin(β)
    ca::F                 # cos(α)
    cb::F                 # cos(β)
    c_ab::F               # cos(α-β)
    d_sq::F               # d²
end

"""
Empty constructor for the DubinsIntermediateResults data type
"""
function DubinsIntermediateResults(q0::VF, q1::VF, ρ::F) where {F, VF<:AbstractVector{F}}
    
    # TODO: input size checking

    # ir = DubinsIntermediateResults(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.)

    dx = q1[1] - q0[1]
    dy = q1[2] - q0[2]
    D = sqrt(dx*dx + dy*dy)
    d = D / ρ
    Θ = 0

    # test required to prevent domain errors if dx=0 and dy=0
    (d > 0) && (Θ = mod2pi(atan(dy, dx)))
    α = mod2pi(q0[3] - Θ)
    β = mod2pi(q1[3] - Θ)
    d = d
    sa = sin(α)
    sb = sin(β)
    ca = cos(α)
    cb = cos(β)
    c_ab = cos(α-β)
    d_sq = d*d

    ir = DubinsIntermediateResults(α, β,d,sa,sb,ca,cb,c_ab,d_sq)

    return ir
end

const EDUBOK = 0                # no error
const EDUBCOCONFIGS = 1         # colocated configurations
const EDUBPARAM = 2             # path parameterization error
const EDUBBADRHO = 3            # the rho value is invalid
const EDUBNOPATH = 4            # no connection between configurations with this word
const EDUBBADINPUT = 5          # uninitialized inputs to functions
TOL = 1e-10                     # tolerance
