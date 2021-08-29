# Background - Event driven simulation
This section contains some background information about the way in which fastnet simulates networks. You won't need to know any of this to use Fastnet, but if you are interested what is under the hood, please read on. 

## How to simulate processes on networks
If we think about simulating processes on networks, the first idea that usualluy comes to mind are to update all nodes simulataneously in small time steps. This idea is attractive because it makes thinking about the simulation seemingly easier, however it entails a number of problemns

1. Update order -- How do we actually implement our timesteps? Do we update every node in every timestep? And if so in which order do we update them. If the order is always the same we will create artifacts (unrealistic artifical behavior), so we need to randomize. But such randomization can lead to further problems, for instance do we keep track of who has already been updated etc.  

2. Collisions -- What do we do if different events that occur in one timestep are contradictory? For example what if a node in an epidemic situation infects another node and recovers from the disease at the same time. Does the infection always go first? Or can the recovery occur first making the infection event impossible? 

3. Timeing artifacts -- Even if we find elegant solutions for event collisions and update order, we are still approximating a real-word system in which time flows continously by a model in which time proceeds in discrete steps. This in itself can cause some artifacts. For example it can lead to the formation of certain patterns which won't occur in the continuous time system.  

4. Efficiency -- The most common solution to the problems above is to make timesteps tiny. While this lessens the impact of the artifacts it does not prevent them altogether. Moreover, it comes at a high coast in terms of efficiency. We will need to simulate many timesteps to cover the desired stretch of time, and in each of these steps we will be checking a large number of nodes for possible updates. However, since out timesteps are now tiny the probability that a given node is affected by an event in a given timestep is tiny, often in below 1 in a million. This means we spent a lot of computation time to do updates on nodes in which nothing changes at all.  

Simulations that work with discrete timesteps can still be a good idea if the underlying system fundamentally works in discrete timesteps. However, in the vast majority of cases we can simulate systems better, faster, and more elgantly by not using timesteps at all...

## The Gillespie Algorithms
In 1976 Daniel T. Gillespie published the idea for an event-driven simulation algorithm

```
Gillespie (1976). "A General Method for Numerically Simulating the Stochastic Time Evolution of Coupled Chemical Reactions". Journal of Computational Physics. 22 (4): 403–434.
```

The basic idea is that the simulation code will consider the system and then determine (stochastically) which event will happen next in the system and at which time this event will occur. The simulation then jumps forward directly to the time point where the next event occurs and implements the consequences of this event. Once the model has been updated in this way the simulation considers it again to determine what the next event is, and so on. 

With Gillespie's algorithm events can never collide. Moreover there can be no articfacts due to timesteps, because there are no discrete timesteps. Also, the simulation is highly efficient because no time is wasted between events. 
As a result Gillespie-style event-driven simulations combine excellent performance with a high degree of realism. 

## Making it fast
The heart of any event driven simulation are a number of functions. One of these is used to calculate the rates at which processes occur given the state in the system (the *rates!* function). The others implement the individual processes that can occur in the system. 

The key to making event-driven simulations fast is to make sure that these core functions can run without needing to consider (e.g. without needing to iterate over all network nodes). Fastnet makes achieves this by clever bookkeeping that makes use of an innovative data structure. Using this bookkeeping, the tools one needs in a network simulation such as 
 - finding the number of nodes or links in a certain state, 
 - randomly picking a node of link in a certain state at random,  
 - creating or removing nodes or links
 - changing the state of nodes
can all be implemented such that their runtimes is independent of the number of nodes or links in the network. In Fastnet all of these functions either run in constant time, or scale only with the degree of the affected node and the number of states. 

The basic idea for the bookkeeping used in Fastnet was born while we were working on the following publication:
```
T. Gross, C.J. Dommar D’Lima and B. Blasius (2006) "Epidemic dynamics on an adaptive network." Phys. Rev. Lett. 96, 208701.
```
The underlying datastructure that makes the bookkeeping possible is also available in Julia, on its own in the [Repos package](https://github.com/bridgewalker/Repos.jl) Fastnet does not use this package but rather reimplements the Repos structure in an opimized way for its current application. 
