module Dubins

using Memento

const LOGGER = getlogger(@__MODULE__)
Memento.setlevel!(LOGGER, "info")

__init__() = Memento.register(LOGGER)

"Suppresses information and warning messages output by Dubins, for fine grained control use the Memento package"
function silence()
    Memento.info(LOGGER, "Suppressing information and warning messages for the rest of this session.  Use the Memento package for more fine-grained control of logging.")
    Memento.setlevel!(Memento.getlogger(Dubins), "error")
end

"alows the user to set the logging level without the need to add Memento"
function logger_config!(level)
    Memento.config!(Memento.getlogger("Dubins"), level)
end


include("typedefs.jl")
include("paths.jl")
include("path_fcns.jl")

end
