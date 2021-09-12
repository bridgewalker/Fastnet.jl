
"""
results(FastNet)        

Return a refernce to the results of *sim* as a DataFrame

# Example
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[]);

julia> makenodes!(net,12,1)

julia> makenodes!(net,34,2)

julia> sim=FastSim(net,(r,t)->nothing,[])
Simulation run, currently at time 0.0

julia> runsim!(sim,100,25)
Time     Node state 1    Node state 2
  0.0              12              34
 25.0              12              34
 50.0              12              34
 75.0              12              34
100.0              12              34

julia> results(sim)
5×3 DataFrame
 Row │ Time     Node state 1  Node state 2 
     │ Float64  Int64         Int64        
─────┼─────────────────────────────────────
   1 │     0.0            12            34
   2 │    25.0            12            34
   3 │    50.0            12            34
   4 │    75.0            12            34
   5 │   100.0            12            34 
```
"""
function results(sim::FastSim)
    sim.results
end    

"""
    listnodes(FastNet)    
    listnodes(FastNet,state)    

Return a vector of the IDs of all nodes in FastNet *net* or all nodes in state *state* in *net*.

The one-argument method of this function returns a Vector containing the IDs of all nodes that 
are in the network. The two-argument method creates a vector of all nodes in state *state*.  

See also [listneighbors](#Fastnet.listneighbors) 

# Example
```jldoctest
julia> using Fastnet

julia> net=FastNet(10,10,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,3,1)

julia> makenodes!(net,2,2)

julia> listnodes(net)
5-element Vector{Int64}:
 1
 2
 3
 4
 5

julia> listnodes(net,2)
2-element Vector{Int64}:
 4
 5
```
"""
function listnodes(net::FastNet)
    n=countnodes_f(net)
    ret=Vector{Int}(undef,n)
    cur=1
    nc=net.C-1
    for c=1:nc
        @inbounds nclen=net.nclen[c]
        for r=1:nclen
            @inbounds ret[cur]=node(net,c,r)
            cur+=1
        end
    end    
    ret
end

function listnodes(net::FastNet,state::Int)
    nclen=net.nclen[state]
    ret=Vector{Int}(undef,nclen)
    cur=1
    for r=1:nclen
        ret[cur]=node_f(net,state,r)
        cur+=1
    end    
    ret
end

"""
    listneighbors(FastNet,nid)        

Return a vector of the IDs of all nodes that are asjacent to node *nid* in FastNet *net*. 

This function is comparatively slow as it needs to allocate the vector. In your *rates!* 
and process functions it is preferable to iterate over the neighbors using firstlinkout,
firstlinkin, nexlinkout, nextlinkin. 

See also [listnodes](#Fastnet.listnodes) 

# Example
```jldoctest

julia> net=FastNet(10,10,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,3,1)

julia> makenodes!(net,2,2)

julia> listnodes(net)
5-element Vector{Int64}:
 1
 2
 3
 4
 5

 julia> listnodes(net,2)
 2-element Vector{Int64}:
 4
 5 
```
"""
function listneighbors(net::FastNet,node)
    nid=0
    try 
        nid=convert(Int,node)
    catch e
        throw(ArgumentError("listneighbors expects its second argument (node) to be an integer"))
    end    
    ret=Int[]
    cur=net.nout[nid]
    while cur!=0 
        push!(ret,net.kdst[cur])
        cur=net.knexts[cur]
    end
    cur=net.nin[nid]
    while cur!=0
        push!(ret,net.ksrc[cur])
        cur=net.knextd[cur]
    end
    ret
end

"""
    listlinks(net)        

Return an array that contains the source and destination of all links in *net*. 

The return value will be a two-dimensional array of dimensions (K,3), where 
K is the number of links in the network. Each row corresponds to one link. 
The contests of the array are

- First column: Identical to the linkid of the respective link
- Second column: Source node of the link
- Third column: Destination node of the link

Warning: Do not rely on the row index to be identical to the link ID

See also [savelinklist](#Fastnet.savelinklist) 

# Example
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,5,1)

julia> makelink!(net,1,2)
1

julia> makelink!(net,1,3)
2

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,5,1)

julia> makelink!(net,1,2)
1

julia> makelink!(net,2,3)
2

julia> makelink!(net,3,4)
3

julia> makelink!(net,4,5)
4

julia> makelink!(net,5,1)
5

julia> listlinks(net)
5×3 Matrix{Int64}:
 1  1  2
 2  2  3
 3  3  4
 4  4  5
 5  5  1
```
"""
function listlinks(net::FastNet) 
    K=countlinks(net)
    res=Array{Int,2}(undef,K,3)
    for i=1:K
        kid=link_f(net,i)
        res[i,1]=kid
        res[i,2]=linksrc_f(net,kid)
        res[i,3]=linkdst_f(net,kid)       
    end
    return res
end

"""
    listnodestates(net)        

Return an array that contains the ids and states of all nodes in *net*. 

The return value will be a two-dimensional array of dimension (K,2), where 
K is the number of nodes in the network. Each row corresponds to one node. 
The contests of the array ar

- First Column: ID of the respective node
- Second column: State of the node

Warning: Do not rely on the row index to be identical to the node ID

See also [listlinks](#Fastnet.listlinks) 

# Example
```jldoctest
julia> using Fastnet

julia> net=FastNet(100,100,3,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,2,1)

julia> makenodes!(net,2,2)

julia> makenodes!(net,3,3)

julia> listnodestates(net)
7×2 Matrix{Int64}:
 1  1
 2  1
 3  2
 4  2
 5  3
 6  3
 7  3
```
"""
function listnodestates(net::FastNet)
    N=countnodes(net)
    res=Array{Int,2}(undef,N,2)
    for i=1:N
        nid=node_f(net,i)
        res[i,1]=nid
        res[i,2]=nodestate_f(net,nid)       
    end
    res 
end 

"""
    savelinklist(net,filename)        

Save network link list of network *net* to file *filename*.

The file is written in text mode. Each line that is written correosponds to 
one link. The lines have the form 

    LINKID SOURCE DESTINATION

Where LINKID is the respective link, SOURCE is the node id of the source node and DESTINATION 
is the node id  of the destination node. The elemnts are separated by space. The line is ended by a line feed '\\n'.
 
See also [linklist](#Fastnet.linklist) 
"""
function savelinklist(net::FastNet,filename::String)
    fl=0
    try 
        fl=open(filename,"w+")
    catch e
        throw(ArgumentError("savelinklist was unable to open '$filename' for writing"))
    end
    K=countlinks(net)
    for i=1:K 
        kid=link_f(net,i)
        src=linksrc_f(net,kid)
        dst=linkdst_f(net,kid)
        print(fl,"$kid $src $dst \n")
    end
    close(fl)
    nothing
end

"""
    savenodeinfo(net,filename)        

Save information about the nodes to file *filename*.

The file is written in text mode. Each line that is written correosponds to 
one nodes. The lines have the form 

    NODEID STATE INDEGREE OUTDEGREE IN-NEIGHBORS OUT-NEIGBORS

Where NODEID is the ID of the node, STATE is the state of the node, in degree is the number of links that have the node as the 
destination, OUTDEGREE is the number of links that have the node as the source, IN-NEIGHBORS is a list of all nodes from which the 
focal node receives an incoming link, OUTNEIGHBORS is a list of the IDs of all nodes from which the focal node casts an outgoing link. 
All elements are separated by spaces The line is ended by a line feed '\\n'.
 
See also [linklist](#Fastnet.linklist) 
"""
function savenodeinfo(net::FastNet,filename)
    fl=0
    try 
        fl=open(filename,"w+")
    catch e
        throw(ArgumentError("savenodeinfo was unable to open '$filename' for writing"))
    end
    N=countnodes(net)
    for i=1:N
        nid=node_f(net,i)
        state=nodestate_f(net,nid)
        indeg=indegree_f(net,nid)
        outdeg=outdegree_f(net,nid)
        print(fl,"$nid $state $indeg $outdeg")
        curlink=firstlinkin_f(net,nid)
        while curlink!=0
            src=linksrc_f(net,curlink) 
            print(fl," $src")
            curlink=nextlinkin_f(net,curlink)
        end
        curlink=firstlinkout_f(net,nid)
        while curlink!=0
            dst=linkdst_f(net,curlink) 
            print(fl," $dst")
            curlink=nextlinkout_f(net,curlink)
        end
        print(fl,"\n")
    end
    close(fl)
    nothing
end


"""
    degreedist(net::FastNet)        

Return a vector of Float64 that specifies the networks degree distribution. 

The element k of the returned vector is the probability that the probability that the a randomly drawn node from the 
network has degree k. 

If the elements of the vector do not add up to 1.0, the remainder is the probability that a randomly drawn node has 
degree zero.  
  
# Example
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[])
Network of 0 nodes and 0 links

julia> makenodes!(net,4,1)

julia> makelink!(net,node(net,1),node(net,2));

julia> makelink!(net,node(net,2),node(net,3));

julia> degreedist(net)
2-element Vector{Float64}:
 0.5
 0.25
```

"""
function degreedist(net::FastNet)
    mxdegree=0
    N=countnodes_f(net)
    for i=1:N
        mxdegree=max(mxdegree,degree_f(net,node_f(net,i)))
    end
    dd=zeros(Float64,mxdegree)
    for i=1:N
        k=degree_f(net,node_f(net,i))
        if k>0
          dd[k]+=1.0
        end
    end
    for i=1:mxdegree
        dd[i]/=N
    end
    dd
end