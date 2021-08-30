### SAVE VERSION OF FUNCTIONS ###


"""
    node(net,rp)
    node(net,s,rp)
    node_f(net,rp)
    node_f(net,s,rp)

Determine node id from relative position and node state.

The node function provides a way to access nodes form a the set of nodes in certain states,
or from the set of all nodes in a simple way. The two-argument version returns the id of the 
node at poition *rp* in network *net*. The three-argument version returns the id of the node at 
poition *rp* within all nodes in state *s*.

All version of this function run in constant time, but fast (_f) verions sacrifice some safty 
checks for better performance. See [basic concepts](concepts.md) for details. 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> randomgraph!(net)
Network of 1000 nodes and 2000 links

julia> nodestate!(net,123,2)

julia> nodestate!(net,345,2)

julia> node(net,2,1)
345

julia> node(net,2,2)
123

julia> node(net,1)
1

julia> destroynode!(net,1)

julia> node(net,1)
998
```
"""
function node(net::FastNet,cls::Int,rp::Int)
    task="Trying to retrieve id of node number $rp in state $cls"
    checknodestate(net,cls,task)
    if rp<1 || rp>net.nclen[cls]  
        throw(ArgumentError("$task, but there is no relative position $rp in state $cls"))  
    end
    node_f(net,cls,rp)
end

function node(net::FastNet,rp::Int)
    task="Trying to retrieve id of node number $rp"
    if rp<1 || rp>countnodes_f(net)  
        throw(ArgumentError("$task, but there is no relative position $rp"))  
    end
    node_f(net,rp)
end

"""
    nodecounts(net)
    nodecounts_f(net)

Return an Array containing the number of nodes in the vairous node states. 

The time required for this function scales only with the number of node states
(it is independent of the number of nodes). 

The alternative (_f) version of this function is identical to nodecounts and is provided
only for convenience. 

See also [countnodes](#Fastnet.countnodes)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> randomgraph!(net)
Network of 1000 nodes and 2000 links

julia> for i=1:20
         n=node(net,1,1)
         nodestate!(net,n,2)
       end

julia> nodecounts(net)
2-element Vector{Int64}:
 980
  20
```
"""
function nodecounts(net::FastNet)
    nodecounts_f(net)
end

"""
    nodestate(net,nid)
    nodestate_f(net,nid)

Return the state of the node with id *nid* in network *net*. 

All version of this function run in constant time, but fast (_f) verions sacrifice some safty 
checks for better performance. See [basic concepts](concepts.md) for details. 
    
See also [nodestate!](#Fastnet.nodestate!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> randomgraph!(net)
Network of 1000 nodes and 2000 links

julia> nodestate(net,1)
1

julia> nodestate!(net,1,2)

julia> nodestate(net,1)
2
```
"""
function nodestate(net::FastNet,nid)  
    task="Trying to determine the state of node $nid"  
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)        
    nodestate_f(net,nid) 
end

"""
    nodestate!(net,nid,s)
    nodestate_f!(net,nid,s)

Set the node with id *nid* in net *net* to *s*.

Worst-case performance of both versions of this function is O(ks\\*k)+O(ns) where ks is the number of 
tracked link states, k is the degree of the affected node and ns is the number of node states.  

The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [nodestate](#Fastnet.nodestate)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> randomgraph!(net)
Network of 1000 nodes and 2000 links

julia> nodestate(net,1)
1

julia> nodestate!(net,1,2)

julia> nodestate(net,1)
2
```
"""
function nodestate!(net::FastNet,nid,cls)
    task="Trying to change the state of node $nid to $cls"    
    checknodestate(net,cls,task)
    checknodeexists(net,nid,task)        
    nodestate_f!(net,nid,cls) 
end

"""
    makenode!(net,s)
    makenode_f!(net,s)

Create a new node in state *s* in the network *net* and return it's id. 

Worst-case performance of both versions of this function scales only with the number of node states.  

The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [destroynode!](#Fastnet.destroynode!), [makenodes!](#Fastnet.makenodes!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenode!(net,2)
1

julia> net
Network of 1 nodes and 0 links

julia> nodestate(net,1)
2
```
"""
function makenode!(net::FastNet,cls)   
    task="Trying to make a node of state $cls"
    checknodestate(net,cls,task)
    if net.nclen[net.C]<1   
        throw(ArgumentError("Out of nodes -- Try creating a larger net"))  
    end
    makenode_f!(net,cls)
end

"""
    destroynode!(net,nid)
    destroynode_f!(net,nid)

Destroy the node with id *nid* in network *net*. 

Worst-case performance of both versions of this function is O(ks\\*k)+O(ns) where ks is the number of 
tracked link states, k is the degree of the affected node and ns is the number of node states.  

The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [makenode!](#Fastnet.makenode!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n=makenode!(net,1);

julia> net
Network of 1 nodes and 0 links

julia> destroynode!(net,n)

julia> net
Network of 0 nodes and 0 links
```
"""
function destroynode!(net::FastNet,nid)
    task="Trying to destroy node $nid"
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)
    destroynode_f!(net,nid)
end 

"""
    countnodes(net)
    countnodes(net,s)
    countnodes_f(net)
    countnodes_f(net,s)
   
Count the nodes in state *s*, or, if no state is provided, in the entire network.  

Instead of the state *s* also an Array or Tuple of states can be passed. 
In this case the total number of nodes in all of the listed states is returned. 

All versions of this function run in constant time. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
If performance is critical use this function rather than nodecounts.

See also [nodecounts](#Fastnet.nodecounts)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> for i=1:20
         makenode!(net,1)
         end

julia> for i=1:10
         makenode!(net,2)
         end

julia> countnodes(net)
30

julia> countnodes(net,1)
20

julia> countnodes(net,(1,2))
30
```
"""
function countnodes(net::FastNet)  
    countnodes_f(net)
end

function countnodes(net::FastNet,cls::Integer)
    task="Trying to count nodes in state $cls"
    checknodestate(net,cls,task)
    countnodes_f(net,cls)
end

function countnodes(net::FastNet,cls::Union{Vector,Tuple})
    ret=0
    for c in cls 
        ret+=countnodes(net,c)
    end
    ret
end

"""
    firstlinkin(net,nid)
    firstlinkin_f(net,nid)   

Return the link id of the first incoming link to the node with id *nid* in network *net*.  

If there are no incoming links then the return value is 0

All versions of this function run in constant time. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [firstlinkout](#Fastnet.firstlinkout), [nextlinkin](#Fastnet.nextlinkin) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> l1=makelink!(net,n1,n2);

julia> firstlink=firstlinkin(net,n2);

julia> firstlink==l1
true

julia> linksrc(net,firstlink)==n1
true

julia> linkdst(net,firstlink)==n2
true
```
"""
function firstlinkin(net::FastNet,nid)
    task="Trying to retrieve id of first incoming link to node $nid"
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)
    firstlinkin_f(net,nid)
end

"""
    firstlinkout(net,nid)
    firstlinkout_f(net,nid)   

Return the link id of the first outgoing link from the node with id *nid* in network *net*.  

If there are no outgoing links then the return value is 0

All versions of this function run in constant time. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [firstlinkout](#Fastnet.firstlinkin), [nextlinkin](#Fastnet.nextlinkout) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> l1=makelink!(net,n1,n2);

julia> firstlink=firstlinkout(net,n1);

julia> firstlink==l1
true

julia> linksrc(net,firstlink)==n1
true

julia> linkdst(net,firstlink)==n2
true
```
"""
function firstlinkout(net::FastNet,nid)
    task="Trying to retrieve id of first outgoing link from node $nid"
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)
    firstlinkout_f(net,nid)
end

"""
    degree(net,nid)
    degree_f(net,nid)

Return the degree of the node with id *nid* in network *net*.  

Here degree is interpreted as the number of times this node appears an an endpoint of a link,
hence self-loops contribute 2 to the degree of the node that they link to. 

The worst case performance scales only with the degree of the affected node. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [indegree](#Fastnet.indegree), [outdegree](#Fastnet.outdegree) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,1);

julia> makelink!(net,n1,n2);

julia> makelink!(net,n2,n3);

julia> degree(net,n1)
1

julia> degree(net,n2)
2
```
"""
function degree(net::FastNet,nid)
    task="Trying to calculate degree of node $nid"
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)
    degree_f(net,nid)
end

"""
    indegree(net,nid)
    indegree_f(net,nid)

Return the incoming degree of the node with id *nid* in network *net*.  

The worst case performance scales only with the indegree of the affected node. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [degree](#Fastnet.degree), [outdegree](#Fastnet.outdegree) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,1);

julia> makelink!(net,n1,n2);

julia> makelink!(net,n3,n2);

julia> indegree(net,n1)
0

julia> indegree(net,n2)
2
```
"""
function indegree(net::FastNet,nid)
    task="Trying to calculate in-degree of node $nid"
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)
    indegree_f(net,nid)
end

"""
    outdegree(net,nid)
    outdegree_f(net,nid)

Return the outgoing degree of the node with id *nid* in network *net*.  

The worst case performance scales only with the outdegree of the affected node. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [degree](#Fastnet.degree), [indegree](#Fastnet.indegree) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,1);

julia> makelink!(net,n1,n2);

julia> makelink!(net,n3,n2);

julia> outdegree(net,n1)
1

julia> outdegree(net,n2)
0
```
"""
function outdegree(net::FastNet,nid)
    task="Trying to calculate out-degree of node $nid"
    checknodeid(net,nid,task)
    checknodeexists(net,nid,task)
    outdegree_f(net,nid)
end

"""
    nodeexists(net,nid)
    nodeexists_f(net,nid)

Return if a node with id *nid* exists in *net*, false otherwise.  

This function runs in constant time. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [makenode!](#Fastnet.makenode!), [destroynode!](#Fastnet.destroynode!) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> nodeexists(net,n1)
true
```
"""
function nodeexists(net::FastNet,nid)
    if nid<1 || nid>net.N 
        throw(ArgumentError("Trying to check if node $nid is in the network but that id does not refer to a node"))
    end
    nodeexists_f(net,nid)
end

"""
    makenodes!(net,N,s)
    makenodes_f!(net,N,s)

Create *N* nodes in state *s* in the network *net.  

Worst case performance of this function scales only with the number of node states. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [makenode!](#Fastnet.makenode!), [destroynode!](#Fastnet.destroynode!) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,100,1);

julia> net
Network of 100 nodes and 0 links
```
"""
function makenodes!(net::FastNet,N,cls)
    task="Trying to create $N nodes of state $cls"
    checknodestate(net::FastNet,cls,task)
    N>net.nclen[net.C] ? throw(ArgumentError("$task, but this is more nodes than allowed by net")) :
    makenodes_f!(net,N,cls)
end

"""
    randomnode(net)
    randomnode(net,s)
    randomnode_f(net)
    randomnode_f(net,s)

Return the id of a random node drawn from *net*.

If the second argument *s* is not provided the node will be drawn uniformly from 
all nodes in the network. If *s* is an integer then the node will be drawn uniformly 
from the nodes in state *s*. If *s* is an Array or Tuple of Ints then the node will be 
drawn uniformly from the nodes in the states listed. 

This function runs in constant time if *s* is integer or omitted. If *s* is an Array or Tuple the 
worst case performance scales only with the number of node states.  
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

The safe versions of this function will throw an ArgumentError with an informative error message
when trying to pick a node from an empty set. With the fast (_f) version, trying to pick a node from 
an empty set will also result in an ArgumentError being thrown, but in this case the message will be 
something like "Range must be non-empty".  

See also [node](#Fastnet.node)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,100,1);

julia> makenodes!(net,100,2);

julia> nodestate(net,randomnode(net,1))
1
julia> nodestate(net,randomnode(net,2))
2
```
"""
function randomnode(net::FastNet)
    task="Trying to select random node"
    checknonnull(net,task)
    randomnode_f(net)
end

function randomnode(net::FastNet,cls::Integer)
    task="Trying to select random node from state $cls"
    checknodestate(net,cls,task)
    checknonnull(net,cls,task)
    randomnode_f(net,cls)
end

function randomnode(net::FastNet,cls::Union{Array,Tuple})
    task="Trying to select a random node from a set of states"
    for c in cls
        checknodestate(net,c,task)
    end
    tot=countnodes(net,cls)
    if tot===0
        throw(ArgumentError("Trying to select a random node from a set of states, but there isn't any node in any of the states."))
    end       
    randomnode_f(net,cls)
end

"""
    randomnode(net)
    randomnode(net,s)
    randomnode_f(net)
    randomnode_f(net,s)

Return the id of a random node ddrawn from *net*.

If the second argument *s* is not provided the node will be drawn uniformly from 
all nodes in the network. If *s* is an integer then the node will be drawn uniformly 
from the nodes in state *s*. If *s* is an Array or Tuple of Ints then the node will be 
drawn uniformly from the nodes in the states listed. 

This function runs in constant time if *s* is integer or omitted. If *s* is an Array or Tuple the 
worst case performance scales only with the number of node states.  
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

The safe versions of this function will throw an ArgumentError with an informative error message
when trying to pick a node from an empty set. With the fast (_f) version, trying to pick a node from 
an empty set will also result in an ArgumentError being thrown, but in this case the message will be 
something like "Range must be non-empty".  

See also [node](#Fastnet.node)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,100,1);

julia> net
Network of 100 nodes and 0 links
```
"""
function nodestate(net::FastNet,nid)
    task="Trying to determine state of node $nid,"
    checknodeid(net,nid,task)
    nodestate_f(net,nid)
end

"""
    adjacent(net,a,b)
    adjacent_f(net,a,b)

Check if nodes with the id's *a* and *b* are adjacent in network *net*. If they are 
return the id a of the link connecting them. Otherwise return 0.

If multiple links connect the nodes the function will return a link in the direction 
a->b if such a link exists. 

Calling adjacent(net,a,a) will return a self-loop on a if one exists. 

The worst case performance of this function scales with the degree of node a.
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
  
# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,100,1);

julia> net
Network of 100 nodes and 0 links
```
"""
function adjacent(net::FastNet,nida,nidb)
    task="Checking if there is a link connecting nodes $nida and $nidb,"
    checknodeid(net,nida,task)
    checknodeid(net,nidb,task)
    adjacent_f(netmnida,nidb)
end