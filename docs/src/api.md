# API Documentation and Usage

Once the Dubins package is installed it can be imported using the command
```julia
using Dubins
```
The methods that can be used without the qualifier `Dubins.` include
```
dubins_shortest_path, dubins_path,
dubins_path_length, dubins_segment_length,
dubins_segment_length_normalized,
dubins_path_type, dubins_path_sample,
dubins_path_sample_many, dubins_path_endpoint,
dubins_extract_subpath
```
The constants and other variables that can be used without the qualifier `Dubins.` include
```
DubinsPathType, SegmentType, DubinsPath,
LSL, LSR, RSL, RSR, RLR, LRL,
EDUBOK, EDUBCOCONFIGS, EDUBPARAM,
EDUBBADRHO, EDUBNOPATH, EDUBBADINPUT
```

Any method in the Dubins package would return an error code. The error codes that are defined within the package are
```julia
const EDUBOK = 0                # no error
const EDUBCOCONFIGS = 1         # colocated configurations
const EDUBPARAM = 2             # path parameterization error
const EDUBBADRHO = 3            # the rho value is invalid
const EDUBNOPATH = 4            # no connection between configurations with this word
const EDUBBADINPUT = 5          # uninitialized inputs to functions
```

## Dubins paths/shortest Dubins path
Any call to the methods within the Dubins package begins by initializing a `DubinsPath` using
```julia
path = DubinsPath()
```

The shortest path between two configurations is computed using the method `dubins_shortest_path()` as
```julia
errcode = dubins_shortest_path(path, [0., 0., 0.], [1., 0., 0.], 1.)
```
Here, path is an object of type `DubinsPath`, `[0., 0., 0.]` is the initial configuration, `[1., 0., 0.]` is the final configuration and `1.` is the turn radius of the Dubins vehicle. A configuration is a 3-element vector with the x-coordinate, y-coordinate, and the heading angle.
The above code would return a non-zero error code in case of any errors.

A Dubins path of a specific type can be computed using
```julia
errcode = dubins_path(path, zeros(3), [10., 0., 0.], 1., RSL)
```
where, the last argument is the type of Dubins path; it can take any value in `LSL, LSR, RSL, RSR, RLR, LRL`.

The length of a Dubins path is computed after a function call to `dubins_shortest_path()` or `dubins_path()` as
```julia
val = dubins_path_length(path)
```

The length of each segment (1-3) in a Dubins path and the type of Dubins path can be queried using
```julia
val1 = dubins_segment_length(path, 1)
val2 = dubins_segment_length(path, 2)
val3 = dubins_segment_length(path, 3)
path_type = dubins_path_type(path)
```
The second argument in the method `dubins_segment_length()` is the segment number. If a segment number that is less than 1 or greater than 3 is used, the method will return `Inf`.

## Sub-path extraction
A sub-path of a given Dubins path can be extracted as
```julia
path = DubinsPath()
errcode = dubins_path(path, zeros(3), [4., 0., 0.], 1., LSL)

subpath = DubinsPath()
errcode = dubins_extract_subpath(path, 2., subpath)
```
The second argument of the function `dubins_extract_subpath()` is a parameter that has lie in the open interval `(0,dubins_path_length(path))`, failing which the function will return a `EDUBPARAM` error-code.  

After extracting a sub-path, the end-point of the sub-path can be queried using the method `dubins_path_endpoint(subpath, q)`, where `q = Vector{Float64}(3)`. This function returns `EDUBOK` on successful completion.

## Sampling a Dubins path
Sampling the configurations along a Dubins path is a useful feature that can aid in writing additional plotting features. To that end, the package includes two functions that can achieve the same goal of sampling in two different ways; they are `dubins_path_sample()` and `dubins_path_sample_many()`. The usage of the method `dubins_path_sample()` is illustrated by the following code snippet:
```julia
path = DubinsPath()
errcode = dubins_path(path, [0., 0., 0.], [4., 0., 0.], 1., LSL)

qsamp = Vector{Float64}(3)
errcode = dubins_path_sample(path, 0., qsamp)
# qsamp will take a value [0., 0., 0.], which is the initial configuration

qsamp = Vector{Float64}(3)
errcode = dubins_path_sample(path, 4., qsamp)
# qsamp will take a value [4., 0., 0.], which is the final configuration

qsamp = Vector{Float64}(3)
errcode = dubins_path_sample(path, 2., qsamp)
# qsamp will take a value [2., 0., 0.], the configuration of the vehicle after travelling for 2 units
```
The second argument of the function `dubins_path_sample()` is a parameter that has lie in the open interval `(0,dubins_path_length(path))`, failing which the function will return a `EDUBPARAM` error-code.  

As one can observe from the above code snippet, `dubins_path_sample()` samples the Dubins path only once. Sampling an entire Dubins path using a step size, can be achieved using the method `dubins_path_sample_many()`. The `dubins_path_sample_many()` takes in three arguments:

1. the Dubins path that needs to be sampled,
2. the step size denoting the distance along the path for subsequent samples, and
3. a callback function that takes in a configuration, a float, and other keyword arguments to do some operation (like print) with the samples; the callback function should always return a 0 when it has completed its operation.

The following code snippet samples a Dubins path using a step size and prints the configuration at each sample:
```julia
function callback_fcn(q::Vector{Float64}, x::Float64; kwargs...)
    println("x: $(q[1]), y: $(q[2]), Θ: $(q[3])")
    return 0
end

path = DubinsPath()
errcode = dubins_path(path, [0., 0., 0.], [4., 0., 0.], 1., LSL)
errcode = dubins_path_sample_many(path, 1., callback_fcn)
```

The output of the above code snippet is
```
x: 0.0, y: 0.0, Θ: 0.0
x: 1.0, y: 0.0, Θ: 0.0
x: 2.0, y: 0.0, Θ: 0.0
x: 3.0, y: 0.0, Θ: 0.0
```

The same behaviour can also be achieved by using the `dubins_path_sample()` multiple times, one for each step.
