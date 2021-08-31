# Fastnet.jl

**Fastnet is a Julia package tht allows very fast (linear-time) simulation of discrete-state dynamical processes on networks, such as commonly studied models of epidemics**

Fastnet achieves linear-time performance by using an innovative data structure. The underlying netork is a potentially directed and potentially non-simple graph. 
The package provides a convenient syntax that allows to implement common model in a few simple lines of code. The simulations are done using using an event-driven (Gillespie) algortithm offering fast performance and excellent agreement with real world contious-time processes. Using fastnet models with millions of nodes can be run within minutes on a standard labtop. 

## Example

The followin file defines and runs an epidemiological SIS model:

```julia
using Fastnet

const S=1                               # Node state 1: Susceptible node
const I=2                               # Node state 2: Infected node
const SI=1                              # Link state 1: Susceptible-Infected link 

const p=0.05                            # Infection rate (per SI-link)
const r=0.1                             # Recovery rate (per I-node)

SI_link=LinkType(S,I)                   # This describes what we mean by SI-link 

# Let's make a network of 1M nodes and 4M links, 2 node states, that keeps track of SI links
net=FastNet(1000000,4000000,2,[SI_link]; nodealias=["S","I"], linkalias=["SI"])

randomgraph!(net)                       # Initialize as ER-random graph (all nodes will be in state 1: S)

for i=1:20                              # Infect 20 susceptible nodes at random 
    node=randomnode(net,S)
    nodestate!(net,node,I)
end

function rates!(rates,t)                # This functins computes the rates of processes
    infected=countnodes_f(net,I)                # count the infected nodes
    activelinks=countlinks_f(net,SI)            # count the SI links
    rates[1]=p*activelinks                       # compute total infection rate
    rates[2]=r*infected                          # compute total recovery rate 
    nothing
end

function recovery!()                    # This is what we do when the recovery process is triggered
    inode=randomnode_f(net,I)                   # Find a random infected node
    nodestate_f!(net,inode,S)                   # Set the state of the node to susceptible
end

function infection!()                   # This is what we do when the infection process is triggered
    alink=randomlink_f(net,SI)                   # Find a random SI link
    nodestate_f!(net,linksrc_f(net,alink),I)     # Set both endpoints of the link to infected
    nodestate_f!(net,linkdst_f(net,alink),I)    
end

sim=FastSim(net,rates!,[infection!,recovery!])   # initialize the simulation 

@time runsim!(sim,60.0,5.0)                      # Run for 60 timeunits (reporting every 5)
```

This produces the output: 
```julia
Time    S       I       SI     
0.0     999980      20      146
5.0     999927      73      570
10.0    999710     290     2199
15.0    998734    1266     9499
20.0    995152    4848    35743
25.0    982053   17947   130184
30.0    936454   63546   437860
35.0    807731  192269  1133438
40.0    585665  414335  1744756
45.0    402526  597474  1708492
50.0    319610  680390  1550403
55.0    291675  708325  1482735
60.0    281941  718059  1458951
 65.271643 seconds (806.64 M allocations: 12.244 GiB, 3.87% gc time, 0.04% compilation time)
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
**REGISTERATION IS IN PROGRESS, CONTACT ME IF YOU WANT THE PACKAGE**

## Documentation

Full documentation can be found here:
[https://bridgewalker.github.io/Fastnet.jl](https://bridgewalker.github.io/Fastnet.jl)

## Project Status

This package was tested on Julia 1.6.2 on Windows. This is still in an early version. 
More testing is necessary, so use with caution. I am still actively developing this package, 
so comments, feature requests etc. are very welcome. You can contact me via thilo2gross@gmail.com!

## Acknowledgements
The original development of Fastnet was supported by the Volkswagen foundation. The current implementation in Julia was developed at HIFMB, a collaboration between the Alfred-Wegener-Institute, Helmholtz-Center for Polar and Marine Research, and the Carl-von-Ossietzky University Oldenburg, initially funded by the Ministry for Science and Culture of Lower Saxony (MWK) and the Volkswagen Foundation through the “Nieders&auml;chsisches Vorab” grant program (grant number ZN3285).
 
