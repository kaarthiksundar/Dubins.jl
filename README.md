# Dubins.jl

[![Continuous Integration (Unit Tests)][ci-unit-img]][ci-unit-url]  [![Documentation][docs-img]][docs-url]  [![Code Coverage][codecov-img]][codecov-url]                                           

[docs-img]: https://github.com/kaarthiksundar/Dubins.jl/workflows/Documentation/badge.svg "Documentation"
[docs-url]: https://kaarthiksundar.github.io/Dubins.jl/dev/
[ci-unit-img]: https://github.com/kaarthiksundar/Dubins.jl/actions/workflows/ci.yml/badge.svg?branch=master "Continuous Integration (Unit Tests)"
[ci-unit-url]: https://github.com/kaarthiksundar/Dubins.jl/actions/workflows/ci.yml
[codecov-img]: https://codecov.io/gh/kaarthiksundar/Dubins.jl/branch/master/graph/badge.svg "Code Coverage"
[codecov-url]: https://codecov.io/gh/kaarthiksundar/Dubins.jl/branch/master

Dubins.jl is a Julia package for computing the shortest path between two configurations for the Dubins' vehicle (see [Dubins, 1957](http://www.jstor.org/stable/2372560?seq=1#page_scan_tab_contents)). The shortest path algorithm, implemented in this package, uses the algebraic solution approach in the paper "[Classification of the Dubins set](https://www.sciencedirect.com/science/article/pii/S0921889000001275)" by Andrei M. Shkel and Vladimir Lumelsky.

All the unit tests and the data structures in this Julia implementation is borrowed from the [C implementation](https://github.com/AndrewWalker/Dubins-Curves) and its corresponding [python wrapper](https://github.com/AndrewWalker/pydubins).

## Bugs and support
Please report any issues or feature requests via the Github [issue tracker].

[issue tracker]: https://github.com/kaarthiksundar/Dubins.jl/issues

## Documentation
The detailed API documentation with examples can be found [here](https://kaarthiksundar.github.io/Dubins.jl/latest/).

## License
MIT License. See LICENSE file for details.
