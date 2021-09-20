
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


"""
    configmodel!(net::FastNet,degreedist;<keyword arguments>)

Create a configuration model style network with prescribed degree distribution, *degreedist*.

The network in *net* is replaced with the new topology. The degree distribution is specified in  
terms of a vector of Float64 variables such that *degreedist[k]* is specifies, p<sub>k</sub>, the probability
that a randomly drawn node has degree k. If the elements of *degreedist* add up to less than 1.0 the 
remaining nodes will have degree zero.   
 
The network generation is fast and unbiased but isn't guaranteed to result in a simple graph. 
The algorithm will try to match the desired degree distribution as closely as possible,
but small discrepancies can appear if the degree distribution would result in an odd degree sum 
or non integer numbers of nodes of certain degrees. 

If there FastNet is not large enough to accomodate the desired number of links or nodes an argument error 
will be thrown. 

The keyword arguments are 
- N : The number of nodes that will be used in the creation of the network
- S : The state of the nodes. All nodes will be set to this state. 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> configmodel!(net,[0.5,0.25,0.25],N=200)
Network of 200 nodes and 175 links

julia> degreedist(net)
3-element Vector{Float64}:
 0.5
 0.25
 0.25

julia> configmodel!(net,[0.5,0.25],N=200)
Network of 200 nodes and 100 links

julia> degreedist(net)
2-element Vector{Float64}:
 0.5
 0.25
```
"""
function configmodel!(net::FastNet,degreedist;N=0,S=1)
    (counts,totalstubs)=_configmodelsetup!(net,degreedist,N,S)
    nn=sum(counts);
    l=length(counts)
    nde=Array{Int,1}(undef,totalstubs)
    curnode=1
    curstub=1
    for i=1:l
        for j=1:counts[i]
            for s=1:i
                nde[curstub]=curnode
                curstub+=1
            end
            curnode+=1
        end
    end
    cutoff=totalstubs
    rng=net.rng
    while cutoff>1
        stub=rand(rng,1:cutoff)
        src=node_f(net,nde[stub])
        nde[stub]=nde[cutoff]
        cutoff-=1
        stub=rand(rng,1:cutoff)
        dst=node_f(net,nde[stub])
        nde[stub]=nde[cutoff]
        cutoff-=1
        makelink_f!(net,src,dst)
    end
    net
end


"""
    regulargraph!(net::FastNet,deg;<keyword arguments>)

Create a regular graph with node degree *deg*. 

The network in *net* is replaced with the new topology in which all nodes have degree *deg*
and are randomly connected. If the number of nodes is not specified the function will
try to use all nodes allowed by net. 
 
The network generation is fast and unbiased, but isn't guaranteed to result in a simple graph. 

Note that finite regular graphs with odd node degree and odd number of nodes do not exist. Hence 
either *deg* or the number of nodes must be even. 

If there FastNet is not large enough to accomodate the desired number of links or nodes an argument error 
will be thrown. 

The keyword arguments are 
- N : The number of nodes that will be used in the creation of the network
- S : The state of the nodes. All nodes will be set to this state. 

# Examples 
```jldoctest
julia> using Fastnet

julia>  net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> regulargraph!(net,4)
Network of 1000 nodes and 2000 links

julia> degreedist(net)
4-element Vector{Float64}:
 0.0
 0.0
 0.0
 1.0
```
"""
function regulargraph!(net::FastNet,deg;N=0,S=1)
    s=0
    n=0
    d=0
    try 
        s=convert(Int,S)
    catch e
        throw(ArgumentError("regulargraph expects s to be an integer"))
    end
    try 
        n=convert(Int,N)
    catch e
        throw(ArgumentError("regulargraph expects N to be an integer"))
    end
    try 
        d=convert(Int,deg)
    catch e
        throw(ArgumentError("regulargraph expects deg to be an integer"))
    end
    if n==0
        n=net.N
    end
    checknodestate(net,s,"Trying to create regular graph")
    if n<1
        throw(ArgumentError("regulargraph expects number of nodes n to be positive"))
    end
    if d<0
        throw(ArgumentError("regulargraph expects nodedegree deg to be non-negative"))
    end
    if n>net.N
        throw(ArgumentError("Requested size for regulargraph exceeds max node count of underlyng FastNet"))
    end
    if (n*d)÷2>net.K
        throw(ArgumentError("Requested regulargraph exceeds max link count of underlyng FastNet"))
    end
    if isodd(n) && isodd(d)
        throw(ArgumentError("A regular graph of odd node degree must have an even number of nodes."))
    end
    nullgraph!(net)
    makenodes!(net,n,s)
    totalstubs=n*d
    nde=Array{Int,1}(undef,totalstubs)
    for i=1:totalstubs
        nde[i]=((i-1)÷deg)+1 
    end
    cutoff=totalstubs
    rng=net.rng
    while cutoff>0
        srcs=rand(rng,1:cutoff)         # pick the source
        src=node_f(net,nde[srcs])
        nde[srcs]=nde[cutoff]
        cutoff-=1
        dsts=rand(rng,1:cutoff)         # pick the source
        dst=node_f(net,nde[dsts])
        nde[dsts]=nde[cutoff]
        cutoff-=1
        makelink_f!(net,src,dst)
    end
    net
end

"""
    rectlattice!(net::FastNet,dims, <keyword arguments>)

Create a rectangular lattice with given dimensions *dims*. 

The network in *net* is replaced with the new topology, that is a lattice specified by dims.  
*dims* can be a number, in this case it indicates the number of nodes to be arranged into a 1D lattice. 
Alternatively, *dims* can be a vector of Ints. In this case the dimension of the lattice is identical to the 
length of *dims* and each element of *dims* specifies the length of the lattice in one of these dimensions. 

If there FastNet is not large enough to accomodate the desired number of nodes or links an argument error 
will be thrown. 

Keyword arguments are 
- periodic : If this argument is true the lattice is generated with periodic boundary conditions in all dimensions. 
  Alternatively a Vector of Bool of the same length as *dims* can be supplied. In this case the n'th argument of 
  the vector specifies if the lattice is periodic in the n'th dimension. 
- S : The state of the nodes. All nodes will be set to this state. 

# Examples 
```jldoctest
julia> using Fastnet

julia>  net=FastNet(2000,6000,2,[])
Network of 0 nodes and 0 links

julia> rectlattice!(net,[10,20,10],periodic=[true,false,true])
Network of 2000 nodes and 5900 links

julia> degreedist(net)
6-element Vector{Float64}:
 0.0
 0.0
 0.0
 0.0
 0.1
 0.9
```
"""
function rectlattice!(net::FastNet,dims::Union{Int,Tuple,AbstractVector};S=1,periodic=false)
    task="Trying to create a rectangular lattice"
    d=[dims...]
    nd=length(d)
    per=[false]
    if isa(periodic,Bool)
        per=fill(periodic,nd)
    else
        per=[periodic...]
    end
    if length(per)!=length(d)
        throw(ArgumentError(task*", but the number of values passed for parameter periodic does not agree with dims"))
    end
    for x in per
        if !isa(x,Bool)
            throw(ArgumentError(task*", but $x in periodic is not of type Bool"))
        end
    end
    n=1
    s=checknodestate(net,S,task)
    for i=1:nd
        n*=d[i]
    end
    nullgraph!(net)
    makenodes!(net,n,s)
    linksneeded=0
    for i=1:nd
        linksneeded+=n 
        if !per[i]
            linksneeded-=n÷d[i]
        end
    end    
    for i=1:n
        lowmult=1
        for j=1:nd
            if ((i-1)÷lowmult)%d[j]==d[j]-1
                if per[j]
                    src=node_f(net,i)
                    dst=node_f(net,i+lowmult-d[j]*lowmult)                    
                    makelink_f!(net,src,dst)
                end
            else
                src=node_f(net,i)
                dst=node_f(net,i+lowmult)
                makelink_f!(net,src,dst)
            end
            lowmult*=d[j]
        end    
    end
    net
end

function topologyfromlinklist(net::Fastnet,)
    

end

#WIP
function nodesfromfile(net::Fastnet,filename::String)
    try
        file=open(filename,"r")
    catch e
        throw(ArgumentError("Unable to open file $filename"))
    end
    nullgraph!(net)
end 


### WIP
function configmodel_DG!(net::FastNet,degreedist,N::Int=0,S::Int=1)
    (counts,totalstubs)=_configmodelsetup!(net,degreedist,N,S)

    

    println("On track")
end




