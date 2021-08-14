# Fastnet.jl

**Fastnet is a Julia package tht allows very fast (linear-time) simulation of discrete-state dynamical processes on networks, such as commonly studied models of epidemics**

Fastnet achieves linear-time performance by using an innovative data structure. The underlying netork is a potentially directed and potentially non-simple graph. 
The package provides a convenient syntax that allows to implement common model in a few simple lines of code. The simulations are done using using an event-driven (Gillespie) algortithm offering fast performance and excellent agreement with real world contious-time processes. 


