
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


function configmodel!(net::FastNet,degreedist,N::Int=0,S::Int=1)
    nullgraph!(net)
    n=N
    if n==0
        n=net.N
    end
    zerop=1.0-sum(degreedist)
    zeron=Int(round(zerop*n))
    mx=length(degreedist)
    counts=[Int(round(degreedist[i]*n)) for i=1:mx]
    stubs=0
    for i=1:mx
        stubs+=i*counts[i]
    end
    if isodd(stubs)               # All this stuff is just for fixing odd numbers of nodes
        peak=(1,2)
        peakdel=-1.0
        diff=1.0
        for i=2:mx
            if (counts[i]==0)
                continue
            end
            for j=1:i-1 
                if (counts[j]==0)
                    continue
                end
                del=(counts[i]-degreedist[i]*n)-(counts[j]-degreedist[j]*n)  
                if abs(del)>peakdel
                    if del<0 
                        peakdel=-del
                        diff=-1
                    else
                        peakdel=del
                        diff=1
                    end
                    peakdel=del
                    peak=(i,j)
                end
            end
        end
        counts[peak[1]]-=diff
        counts[peak[2]]+=diff
    end
    totalnodes=zeron+sum(counts)
    totallinks=0
    for i=1:mx
        totallinks+=i*counts[i]
    end
    counts    #Still need to implement the actual config model
end


function hhtest(counts)
    c=copy(counts)
    last=length(c)
    adds=zeros(last)
    while last>1
        while c[last]>0

            for i=1:last
                print(c[i],' ')
            end
            println()
            c[last]-=1
            dist=last
            cur=last
            while dist>0
                if cur<1 
                    return false
                end 
                sub=dist
                if sub>c[cur]
                    sub=c[cur]
                end
                dist-=sub
                c[cur]-=sub
                if (cur>1) 
                    adds[cur-1]=sub
                end
                cur-=1
            end
            for i=1:last
                c[i]+=adds[i]
                adds[i]=0
            end
        end
        last-=1;
    end
    if iseven(c[1])
        true
    else
        false
    end    
end

