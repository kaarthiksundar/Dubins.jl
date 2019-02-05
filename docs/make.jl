using Documenter, Dubins

makedocs(
    modules = [Dubins],
    format = Documenter.HTML(),
    sitename = "Dubins",
    authors = "Kaarthik Sundar",
    pages = [
        "Home" => "index.md",
        "API Documentation" => "api.md",
        "Library" => "library.md"
    ]
)

deploydocs(
    repo = "github.com/kaarthiksundar/Dubins.jl.git"
)
