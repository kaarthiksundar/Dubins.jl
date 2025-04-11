module Dubins

using StaticArrays
import Logging
import LoggingExtras

# Setup Logging
include("logging.jl")
function __init__()
    global _DEFAULT_LOGGER = Logging.current_logger()
    global _LOGGER = Logging.ConsoleLogger(;
        meta_formatter = Dubins._dubins_metafmt,
    )
    return Logging.global_logger(_LOGGER)
end


include("typedefs.jl")
include("paths.jl")
include("path_fcns.jl")

end
