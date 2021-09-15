# Key concepts

## Accessing nodes and links
In Fastnet there are two ways to refer to a specific network node:

1. Node ID -- Every node has a unique ID number that never changes. The ID number may be recycled if a node is destroyed and later another node is created. All ID numbers are integers in the range 1:N, where N is the maximal node number that was passed to the FastNet constructor when the network was created. Node IDs are not necessarily consecutive so a network containing two nodes could contain the nodes with IDs 17 and 23 for example. 

2. Node state and position -- We can also identify nodes by saying "the n'th node in state x" where n is one of the allowed node states and x is the so-called positon in this state. So in the epidemic model from the tutorial we might say we want the first infected node. A state-position pair will not always refer to the same node, but the positions are always numbered consecutively, so if there are two infected nodes these will have the positions 1 and 2 in the infected state.

In general the FastNet functions expect you to refer to nodes by node ID. However, class and position is useful for example if you want to iterate over all nodes in a certain state. You can obtain the ID of a node at a certain position using the function 
```julia
node(net,ste,pos)
```
which returns the node ID for the node at position *pos* of state *ste* in the network *net*.

Links are addressed in the same way. In addition to the different link states specified in the network construction there is one additional link state that means "any other link". For example if you told Fastnet to track three particular link states, these will be states number 1 to 3 and any other link will be in state number 4. The ID of a link can be found by  
```julia
link(net,ste,pos)
``` 
which returns the link ID for the link at position *pos* of state *ste* in the network *net*.


## Network representation
Technically speaking the network described by Fastnet is a directed pseudograph.

We call the network a pseudograph because it is not a simple graph, i.e. it can contain self-loops and multi-links. 
So there can in principle be a link that connects a node to itself and a given pair of nodes can be connected by multiple links. 

The network has been implemented in this way mainly to improve the efficiency of models that should almost always remain simple graphs. Allowing the occasional multi-link or self-loop eliminates the need for constant checking if a given operation would make the graph non-simple. By contrast models that make extensive use of self-loops or multi-links are rare. As a result this feature presently remains a bit undertested, so use with caution.

In the underlying data structure of Fastnet, every link is represented as a directed link (an arc in math-speak).
This comes at no addional computational or memory cost and actually makes many nuances of the implementation easier. 
Nevertheless the package has been developed with undirected networks in mind and we can often simply ignore the underlying directedness of links. What this means is that Fastnet can be used to implement models that use directed links, models that use undirected (or bidirectional) links, and even models that mix the two types. 
 
One (mildly beneficial) effect of the directed nature of links is that there is a unique way to refer to the nodes at the end of the link. They can be determined by the functions 
```julia
linksrc(net,lnk)
linkdst(net,lnk)
```
which return the node IDs that are at the source and destination, respectively, of link with ID *lnk* in network *net*. 

## Slow and Fast functions
In programming there is always a certain extent to which simplicity and elegance of implementation benefit both the debuggability and performance of code. In Fastnet we go beyond this point in terms of debuggability. In an attempt to provide meaningful safety checks and error messages most functions carry out some additional checks that incur a performance cost. This is great for debugging (I sincerely hope), but if we want to run very large simulations we might wish that these extra checks were not done. For this purpose Fastnet provides an alternative implementation for many functions that forego the safety checks to achieve greater performance. 

The performance optimised functions are named in the same way as their corresponding partners with an additional _f appendend to the name. So for example the two functions 
```julia 
node(net,ste,pos)
node_f(net,ste,pos)
```
behave exactly identically, except that the former one carries out the additional checks. 

In Julia the names of functions that change their arguments typically end in an exclamation mark.
In this case the _f goes before the exclamation mark. The functions 
```julia
nodestate!(net,nde,s)
nodestate_f!(net,nde,s)
```
which are used to change the state of the node *nde* to state *s* and an example of such a pair.  

The speedup from using the fast functions is not huge (ca. 20%) but it can be worthwhile in large simulation runs, especially in your *rates!* and process functions (see [tutorial](tutorial.md)). The recommended workflow is to implement your model with the safe functions first and change some of the functions to fast versions once the code has run for a couple of times. 

Calling fast functions with the wrong arguments can lead to unexpected behavior and might in rare cases crash Julia.
