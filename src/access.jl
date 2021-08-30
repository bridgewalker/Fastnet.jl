
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
    nid=Int(node)
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


