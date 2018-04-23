isdefined(Base, :__precompile__) && __precompile__()

module Dubins

using Memento

const LOGGER = getlogger(@__MODULE__)
setlevel!(LOGGER, info)

__init__() = Memento.register(LOGGER)

include("helper.jl")

end
