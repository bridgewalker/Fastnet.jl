
"""
link(net,rp)
link(net,s,rp)
link_f(net,rp)
link_f(net,s,rp)

Determine link id from relative *rp*  position and node state *s*.

The link function provides a way to access links form the set of nodes in a certain link state,
or from the set of all links. The two-argument version returns the id of the 
link at poition *rp* in network *net*. The three-argument version returns the id of the link at 
poition *rp* within the set of links that are in state *s*.

All version of this function run in constant time, but fast (_f) verions sacrifice some safty 
checks for better performance. See [basic concepts](concepts.md) for details. 

See also [adjacent](#Fastnet.adjacent)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[LinkType(1,2),LinkType(1,1),LinkType(2,2)])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,2);

julia> makelink!(net,n1,n2);

julia> makelink!(net,n2,n3);

julia> makelink!(net,n3,n1);

julia> lid=link(net,2,1);

julia> linkdst(net,lid)==n2
true

julia> linksrc(net,lid)==n1
true
```
"""
function link(net::FastNet,cls,rp)
    task="Trying to retrieve id of link number $rp in state $cls"
    checklinkstate(net::FastNet,cls,task)
    if rp<1 || rp>net.kclen[cls]  
        throw(ArgumentError("$task, but position $rp does not exist in state $cls"))  
    end
    return link_f(net,cls,rp)
end

function link(net::FastNet,rp)
    task="Trying to retrieve id of link number $rp"
    if rp<1 || rp>countlinks_f(net) 
        throw(ArgumentError("$task, but position $rp does not exist"))  
    end
    return link_f(net,rp)
end

"""
    linkcounts(net)
    linkcounts_f(net)

Return an Array containing the number of link in the vairous link states. 

The elements of the array will show the counts in the same order in which the link types 
were passed to the FastNet Constructor. 

The time required for this function scales only with the number of link states
(it is independent of the number of links). 

The alternative (_f) version of this function is identical only provided for convenience. 

See also [countlinks](#Fastnet.countlinks)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[LinkType(1,2),LinkType(1,1),LinkType(2,2)])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);  

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,2);

julia> makelink!(net,n1,n2);

julia> makelink!(net,n2,n3);

julia> makelink!(net,n3,n1);

julia> linkcounts(net)
3-element Vector{Int64}:
 2
 1
 0
```
"""
function linkcounts(net::FastNet)
    linkcounts_f(net)
end

"""
    linkstate(net,kid)
    linkstate_f(net,kid)

Return the state of the link with id *kid* in network *net*. 

Note that the link states are numbered in the order in which they were passed to 
the FastNet Constructor. 

All version of this function run in constant time, but fast (_f) verion sacrifices some safty 
checks for better performance. See [basic concepts](concepts.md) for details. 
    
See also [nodestate!](#Fastnet.nodestate!), [FastNet](#FastNet.FastNet)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[LinkType(1,2),LinkType(1,1),LinkType(2,2)])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> lnk=makelink!(net,n1,n2);

julia> linkstate(net,lnk)
2
```
"""
function linkstate(net::FastNet,kid) 
    task="Trying to determine state of link $kid"
    checklinkid(net::FastNet,kid,task)
    checklinkexists(net::FastNet,kid,task)
    linkstate_f(net,kid)
end


"""
    makelink!(net,src,dst)
    makelink_f!(net,src,dst)

Create a new link from node *src* to node*dst* in the network *net* and return it's id. 

Worst-case performance of both versions of this function scales only with the number of tracked link states.  

The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [destroylink!](#Fastnet.destrolink!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> makelink!(net,n1,n2);

julia> net
Network of 2 nodes and 1 links
```
"""
function makelink!(net::FastNet,src,dst)
    task="Trying to create link from node $src to node $dst"
    checknodeid(net::FastNet,src,task)
    checknodeexists(net::FastNet,src,task)
    checknodeid(net::FastNet,dst,task)
    checknodeexists(net::FastNet,dst,task)    
    if net.kclen[net.L]<1   
        throw(ArgumentError("Out of links -- Try creating a larger net"))  
    end
    makelink_f!(net,src,dst)
end

"""
    destroylink!(net,kid)
    destroylink_f!(net,kid)

Destroy the link with id *kid* in network *net*. 

All versions of this function run in constant time. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [makelink!](#Fastnet.makelink!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,2);

julia> makelink!(net,n1,n2);

julia> net
Network of 2 nodes and 1 links

julia> lnk=randomlink(net);

julia> destroylink!(net,lnk)

julia> net
Network of 2 nodes and 0 links
```
"""
function destroylink!(net::FastNet,kid)
    task="Trying to destroy link $kid"
    checklinkid(net::FastNet,kid,task)
    checklinkexists(net::FastNet,kid,task)
    destroylink_f!(net,kid)
end

"""
    linksrc!(net,kid)
    linksrc_f!(net,kid)

Return the id of the node at the source of link *kid* in *net*. 

All versions of this function run in constant time. 
The fast (_f) verion sacrifices some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [makelink!](#Fastnet.makelink!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,2);

julia> k1=makelink!(net,n1,n2);

julia> linksrc(net,k1)==n1
true
```
"""
function linksrc(net::FastNet,kid)
    task="Trying to retrieve source of link $kid"
    checklinkid(net::FastNet,kid,task)
    checklinkexists(net::FastNet,kid,task)
    linksrc_f(net,kid)
end

"""
    linkdst!(net,kid)
    linkdst_f!(net,kid)

Return the id of the node at the destination of link *kid* in *net*. 

All versions of this function run in constant time. 
The fast (_f) verion sacrifices some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [makelink!](#Fastnet.makelink!)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,2);

julia> k1=makelink!(net,n1,n2);

julia> linkdst(net,k1)==n2
true
```
"""
function linkdst(net::FastNet,kid)
    task="Trying to retrieve destination of link $kid"    
    checklinkid(net::FastNet,kid,task)
    checklinkexists(net::FastNet,kid,task)
    linkdst_f(net,kid)
end

"""
    nextlinkout!(net,kid)
    nextlinkout_f!(net,kid)

Get the id of the next outgoing link from the node at the source of link *kid* in *net*. 

This function can be used to iterate over the outgoing links of a node. If *kid* is the nodes
last link the return value is zero. 

All versions of this function run in constant time. 
The fast (_f) verion sacrifices some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [firstlinkout](#Fastnet.firstlinkout), [nextlinkin](#Fastnet.nextlinkin)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,1);

julia> n4=makenode!(net,1);

julia> makelink!(net,n1,n2)
1

julia> makelink!(net,n1,n3)
2

julia> makelink!(net,n1,n4)
3

julia> k=firstlinkout(net,n1);

julia> while k!=0
           println(k)
           k=nextlinkout(net,k)
           end
3
2
1
```
"""
function nextlinkout(net::FastNet,kid)
    task="Trying to retrive next outgoing link from the same node as link $kid"
    checklinkid(net::FastNet,kid,task)
    checklinkexists(net::FastNet,kid,task)    
    nextlinkout_f(net,kid)
end

"""
    nextlinkin!(net,kid)
    nextlinkin_f!(net,kid)

Get the id of the next incoming link to the node at the destination of link *kid* in *net*. 

This function can be used to iterate over the incoming links of a node. If *kid* is the nodes
last link the return value is zero. 

All versions of this function run in constant time. 
The fast (_f) verion sacrifices some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
See also [firstlinkin](#Fastnet.firstlinkin), [nextlinkout](#Fastnet.nextlinkout)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> n3=makenode!(net,1);

julia> n4=makenode!(net,1);

julia> makelink!(net,n2,n1)
1

julia> makelink!(net,n3,n1)
2

julia> makelink!(net,n4,n1)
3

julia> k=firstlinkin(net,n1);

julia> while k!=0
           println(k)
           k=nextlinkin(net,k)
           end
3
2
1
```
"""
function nextlinkin(net::FastNet,kid)
    task="Trying to retrive next incoming link to the same node as link $kid"
    checklinkid(net::FastNet,kid,task)
    checklinkexists(net::FastNet,kid,task)
    nextlinkin_f(net,kid)
end

"""
    countlinks(net)
    countlinks(net,s)
    countlinks_f(net)
    countlinks_f(net,s)
   
Count the links in state *s*, or, if no state is provided, in the entire network.  

Instead of the state *s* also an Array or Tuple of states can be passed. 
In this case the total number of nodes in all of the listed states is returned. 

The links in a sincle class or the entire network are counted in constant time. 
For the tuples or array arguments the performance scales with the number of elements in the 
Tulps/Array. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 
    
If performance is critical use this function rather than linkcounts.

See also [linkcounts](#Fastnet.linkcounts)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[LinkType(1,2,1),LinkType(2,2,2)])
Network of 0 nodes and 0 links

julia> makenodes!(net,20,1)

julia> makenodes!(net,20,2)

julia> for i=1:20
         from=node(net,1,i)
         to=node(net,2,i)
         makelink!(net,from,to)
       end

julia> makelink!(net,node(net,2,1),node(net,2,2));

julia> countlinks(net)
21

julia> countlinks(net,1)
20

julia> countlinks(net,2)
1

julia> countlinks(net,[1,2])
21
```
"""
function countlinks(net::FastNet)
    countlinks_f(net)
end

function countlinks(net::FastNet,cls::Integer)    
    task="Trying to count links in state $cls"
    checklinkstate(net::FastNet,cls,task)
    countlinks_f(net,cls)
end

function countlinks(net::FastNet,cls::Union{Vector,Tuple})
    ret=0 
    for c in cls
        ret+=countlinks(net,c)
    end
    ret
end


"""
    linkexists(net,kid)
    linkexists_f(net,kid)

Return true node with id *kid* exists in *net*, false otherwise.  

This function runs in constant time. 
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

See also [makelink!](#Fastnet.makelink!) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,1);

julia> linkexists(net,7)
false

julia> k=makelink!(net,n1,n2);

julia> linkexists(net,k)
true
```
"""
function linkexists(net::FastNet,kid)
    task="Trying to determine if link $kid is in the network"
    checklinkid(net::FastNet,kid,task)
    linkexists_f(net,kid)
end


"""
    randomlink(net)
    randomlink(net,s)
    randomlink_f(net)
    randomlink_f(net,s)

Return the id of a random link drawn from *net*.

If the second argument *s* is not provided the link will be drawn uniformly from 
all links in the network. If *s* is an integer then the link will be drawn uniformly 
from the links in state *s*. If *s* is an Array or Tuple of Ints then the link will be 
drawn uniformly from the links in the states listed. 

This function runs in constant time if *s* is integer or omitted. If *s* is an Array or Tuple the 
worst case performance scales only with the number of tracked link states.  
The fast (_f) verions sacrifice some safty checks for better performance. 
See [basic concepts](concepts.md) for details. 

The safe versions of this function will throw an ArgumentError with an informative error message
when trying to pick a link from an empty set. With the fast (_f) version, trying to pick a link from 
an empty set will also result in an ArgumentError being thrown, but in this case the message will be 
something like "Range must be non-empty".  

See also [link](#Fastnet.link)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[LinkType(2,2,2)])
Network of 0 nodes and 0 links

julia> randomgraph!(net);

julia> for i=1:500
         nd=randomnode(net,1)
         nodestate!(net,nd,2)
       end

julia> lnk=randomlink(net,1);

julia> linkstate(net,lnk)
1
```
"""
function randomlink(net::FastNet)
    task="Trying to select random link"
    checknonempty(net,task)
    randomlink_f(net)
end

function randomlink(net::FastNet,cls::Integer)
    task="Trying to select random link from state $cls"
    checklinkstate(net,cls,task)
    checknonempty(net,cls,task)
    randomlink_f(net,cls)
end

function randomlink(net::FastNet,cls::Union{Array,Tuple})
    task="Trying to select a random link from a set of states"
    for c in cls
        checklinkstate(net,c,task)
    end
    tot=countlinks_f(net,cls)
    if tot===0
        throw(ArgumentError("$task, but there isn't any node in any of the states."))
    end     
    randomlink_f(net,cls)
end

