
"""
    nullgraph!(net)

Remove all nodes and links from the network. 

The first argument *net* is a FastNet structure that is be used in the simulation. 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,1,[])
Network of 0 nodes and 0 links

julia> randomgraph!(net)
Network of 1000 nodes and 2000 links

julia> nullgraph!(net)
Network of 0 nodes and 0 links
```
"""
function nullgraph!(net::FastNet)
    while countnodes_f(net)>0
        destroynode_f!(net,net.nid[1])
    end
    net
end

"""
    randomgraph!(net;<keyword arguments>)

Create an ER random graph in the network *net*. 

The network isn't guaranteed to be a simple graph, but in large sparse 
networks it is simple with high probability. 

By default all nodes and links that the network can accommodate will be used and 
all nodes will be set to state one. This behavior can be controlled by the following 
keyword arguments:

- N : The number of nodes that will be used in the creation of the random graph.
  All other nodes will be removed from the network. 
- K : The number of links that will be used in the creation of the random graph.
  All other links will be removed from the network. 
- S : The state of the nodes. All nodes will be set to this state. 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,1,[])
Network of 0 nodes and 0 links

julia> randomgraph!(net)
Network of 1000 nodes and 2000 links

julia> nullgraph!(net)
Network of 0 nodes and 0 links

julia> randomgraph!(net,N=100,K=10)
Network of 100 nodes and 10 links
```
"""
function randomgraph!(net::FastNet; N::Int=0,K::Int=0,S::Int=1)
    nullgraph!(net)
    n=N;
    k=K;
    s=S;
    if n===0
        n=net.N
    end 
    if k===0
        k=net.K
    end
    if n<1 && k>0
        throw(ArgumentError("In order to create links the net has to have at least one node"))
    end
    if n>net.N
        throw(ArgumentError("Trying to create more nodes than maximum allowed by the net"))
    end
    if k>net.K
        throw(ArgumentError("Trying to create more links than maximum allowed by the net"))
    end
    if s<1 || s>net.C-1
        msg="The net passed to randomgraph! only supports node states between 1 and $(net.C-1),"
        msg*=" but you are asking it to set nodes to state $s."
        throw(ArgumentError(msg))
    end
    makenodes!(net,n,s)
    for i=1:k
        src=randomnode_f(net,s)
        dst=randomnode_f(net,s)
        makelink_f!(net,src,dst)
    end
    net
end
