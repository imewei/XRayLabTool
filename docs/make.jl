using Documenter
using XRayLabTool

makedocs(
    sitename = "XRayLabTool.jl",
    modules = [XRayLabTool],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://imewei.github.io/XRayLabTool",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Physics Background" => "physics.md",
        "API Reference" => "api.md",
        "Migration Guide" => "migration.md",
        "Changelog" => "changelog.md",
    ],
    checkdocs = :exports,
    warnonly = true,
)

deploydocs(repo = "github.com/imewei/XRayLabTool.git", devbranch = "main")
