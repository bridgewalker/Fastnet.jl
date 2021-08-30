# Fastnet.jl

**Fastnet is a Julia package tht allows very fast (linear-time) simulation of discrete-state dynamical processes on networks, such as commonly studied models of epidemics**

Fastnet achieves linear-time performance by using an innovative data structure. The underlying netork is a potentially directed and potentially non-simple graph. The package provides a convenient syntax that allows to implement common model in a few simple lines of code. The simulations are done using using an event-driven (Gillespie) algortithm offering fast performance and excellent agreement with real world contious-time processes. Using fastnet models with millions of nodes can be run within minutes on a standard labtop. 

## Publication
This Package is described also in the following publication
```
TBA
```

## Installation

Install with the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and

```
pkg> add Fastnet
```

Alternatively from Julia

```julia
julia> import Pkg

julia> Pkg.add("Fastnet")
```

## Getting started
- Check out this [tutorial](tutorial.md). 
- Further examples can be found in the [examples folder](https://github.com/bridgewalker/Fastnet.jl/tree/master/examples) on the github repository.
- To dive deeper it will be helpful to understand the [key concepts](concepts.md) of Fastnet. 

## Project Status
This package was tested using Julia 1.6.2 on windows and linux. This is still under active development and 
more testing needs to be done, so please use with caution. I would love to hear about bugs, user experience and 
feature requests. You can contact me via thilo2gross@gmail.com.

## Acknowledgements
The development of Fastnet was supported by the Volkswagen foundation. The current implementation in Julia was developed at HIFMB, a collaboration between the Alfred-Wegener-Institute, Helmholtz-Center for Polar and Marine Research, and the Carl-von-Ossietzky University Oldenburg, initially funded by the Ministry for Science and Culture of Lower Saxony (MWK) and the Volkswagen Foundation through the “Niedersächsisches Vorab” grant program (grant number ZN3285).
