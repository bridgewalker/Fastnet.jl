# Function Reference

## Constructors  

```@docs
LinkType
FastNet
FastSim
```

## Network Setup

```@docs
adjacency!
nullgraph!
randomgraph!
configmodel!
regulargraph!
rectlattice!
```

## Node Functions

```@docs
adjacent
countnodes
degree
destroynode!
firstlinkin
firstlinkout
indegree
makenode!
makenodes!
node
nodecounts
nodeexists
nodestate
nodestate!
outdegree
randomnode
```

## Link Functions

```@docs
countlinks
destroylink!
makelink!
nextlinkin
nextlinkout
link
linkcounts
linkdst
linkexists
linksrc
linkstate
randomlink
```

## Simulation
```@docs
simstep!
runsim!
```

## Debug & Analysis
```@docs
degreedist
healthcheck
listlinks
listnodes
listneighbors
listnodestates
results
savelinklist
savenodeinfo
showlinks
shownodes
```


