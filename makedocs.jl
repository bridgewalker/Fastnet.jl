using Base: root_module
using Pkg
Pkg.activate("Fastnet.jl")
using Fastnet
using Documenter

makedocs(
    root="C://Users//Thilo//Documents//DVLP//FastnetDev//Fastnet//Fastnet.jl//docs",
    modules     = [Fastnet],
    format = Documenter.HTML(
        prettyurls = false,
        canonical = "https://bridgewalker.github.io/Fastnet.jl/stable/",
        assets = ["assets//favicon.ico","assets//myjs.js","assets/mystyle.css"],
    ),
    sitename    = "Fastnet.jl",
    pages       = Any[
        "Welcome"             => "index.md",
        "Tutorial"            => "tutorial.md",
#        "Examples"            => "example.md",
        "Key Concepts"        => "concepts.md",
        "Function Reference"  => "reference.md",
        "Background"          => "background.md",
        "FAQs"                => "faq.md",   
        "Customization"       => "customization.md",         
        "About"               => "about.md"  
    ]
)












