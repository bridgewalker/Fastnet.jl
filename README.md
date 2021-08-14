# Fastnet.jl

**Fastnet is a Julia package tht allows very fast (linear-time) simulation of discrete-state dynamical processes on networks, such as commonly studied models of epidemics**

Fastnet achieves linear-time performance by using an innovative data structure. The underlying netork is a potentially directed and potentially non-simple graph. 
The package provides a convenient syntax that allows to implement common model in a few simple lines of code. The simulations are done using using an event-driven (Gillespie) algortithm offering fast performance and excellent agreement with real world contious-time processes. Using fastnet models with millions of nodes can be run within minutes on a standard labtop. 

## Example

```julia
julia> using Repos

julia> a=["Pepsis grossa","Smilodon populator","Nothrotheriops texanus","Phoberomys pattersoni"]
4-element Array{String,1}:
 "Pepsis grossa"
 "Smilodon populator"
 "Nothrotheriops texanus"
 "Phoberomys pattersoni"

julia> animals=Repo(a,2)
Repository of 4 objects in 2 classes

julia> alive=class(animals,2)
Class of 0 objects

julia> setclass!(animals,1,2)

julia> print_repo(animals)
Repository of 2 classes
  Class 1
    1 - 4: Phoberomys pattersoni
    2 - 2: Smilodon populator
    3 - 3: Nothrotheriops texanus
  Class 2
    1 - 1: Pepsis grossa

julia> print_repo(alive)
Class of 1 objects
    1 - 1: Pepsis grossa

julia> alive[1]
"Pepsis grossa"
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
**ACTUALLY IT IS NOT REGISTERED YET, CONTACT ME IF YOU WANT THE PACKAGE**

## Documentation

Full documentation can be found here:
[https://bridgewalker.github.io/Fastnet.jl](https://bridgewalker.github.io/Fastnet.jl)

## Project Status

This package was tested on Julia 1.7.0 on Windows.

## Acknowledgements
The original development of Repo was supported by the Volkswagen foundation. The current implementation in Julia was developed at HIFMB, a collaboration between the Alfred-Wegener-Institute, Helmholtz-Center for Polar and Marine Research, and the Carl-von-Ossietzky University Oldenburg, initially funded by the Ministry for Science and Culture of Lower Saxony (MWK) and the Volkswagen Foundation through the “Nieders&auml;chsisches Vorab” grant program (grant number ZN3285).
