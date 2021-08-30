
function node_f(net::FastNet,c,rp)
    @inbounds nodepos=net.ncstart[c]+rp
    @inbounds net.nid[nodepos]   
end

function node_f(net::FastNet,rp)
    @inbounds net.nid[rp]
end

function nodestate_f(net::FastNet,nid)    
    @inbounds net.nstate[nid]
end

function nodestate_f!(net::FastNet,nid,cls)
    @inbounds begin  
        if net.nstate[nid]===cls 
            return nothing
        end 
        while net.nstate[nid]<cls
            upstate_node!(net,nid)
        end
        while  net.nstate[nid]>cls
            destate_node!(net,nid)
        end        
        cur=net.nout[nid]
        while cur!=0
            dst=net.kdst[cur]
            dc=net.nstate[dst]
            nlc=net.ttable[cls,dc]
            linkstate_f!(net,cur,nlc)
            cur=net.knexts[cur]
        end
        cur=net.nin[nid]
        while cur!=0
            src=net.ksrc[cur]
            sc=net.nstate[src]
            nlc=net.ttable[sc,cls]
            linkstate_f!(net,cur,nlc)
            cur=net.knextd[cur]
        end
    end        
    nothing
end

function makenode_f!(net::FastNet,cls)   
    nid=node_f(net,net.C,1)
    nodestate_f!(net,nid,cls)
    nid
end

function destroynode_f!(net::FastNet,nid)
    @inbounds begin
        cur=net.nout[nid]
        while (cur!=0)
            destroylink_f!(net,cur)
            cur=net.nout[nid]
        end
        cur=net.nin[nid]
        while (cur!=0)
            destroylink_f!(net,cur)
            cur=net.nin[nid]
        end
        nodestate_f!(net,nid,net.C)
    end
    nothing
end    

function countnodes_f(net::FastNet)
    ret=0
    nc=net.C-1
    for i=1:nc
        @inbounds ret+=net.nclen[i]
    end
    ret
end

function countnodes_f(net::FastNet,cls::Integer)
    @inbounds net.nclen[cls]
end

function nodecounts_f(net::FastNet)
    n=net.C-1
    @inbounds net.nclen[1:n]
end

function countnodes_f(net::FastNet,cls::Union{Vector,Tuple})
    ret=0
    for c in cls 
        @inbounds ret+=net.nclen[c]
    end
    ret
end

function firstlinkin_f(net::FastNet,nid)
    net.nin[nid]
end

function firstlinkout_f(net::FastNet,nid)
    net.nout[nid]
end

function degree_f(net::FastNet,nid)
    indegree_f(net,nid)+outdegree_f(net,nid)
end

function indegree_f(net::FastNet,nid)
    ret=0
    @inbounds begin
        cur=net.nin[nid]   
        while cur!=0
             ret+=1 
             cur=net.knextd[cur]
        end
    end
    ret
end

function outdegree_f(net::FastNet,nid)
    ret=0
    @inbounds begin
        cur=net.nout[nid]   
        while cur!=0
             ret+=1 
             cur=net.knexts[cur]
        end
    end
    ret
end

function nodeexists_f(net::FastNet,nid)
    @inbounds net.nstate[nid]!=net.C
end

function makenodes_f!(net::FastNet,N,cls)
    for n=1:N
        makenode!(net,cls)
    end
    nothing
end

function randomnode_f(net::FastNet)
    node_f(net,rand(net.rng,1:countnodes_f(net)))
end

function randomnode_f(net::FastNet,cls::Integer)
    node_f(net,cls,rand(net.rng,1:countnodes_f(net,cls)))
end

function randomnode_f(net::FastNet,cls::Union{Array,Tuple})
    tot=countnodes_f(net,cls)
    r=rand(net.rng,1:tot)
    old=r
    i=1
    cr=old-countnodes_f(net,cls[i])
    while cr>0
        i+=1
        old=cr
        cr=old-countnodes_f(net,cls[i])
    end
    node_f(net,i,old)     
end

function nodestate_f(net::FastNet,nid)
    @inbounds net.nstate[nid]
end

function adjacent_f(net::FastNet,nida,nidb)
    @inbounds begin
        link=net.firstlinkout[nida]
        while (link!==0)
            if net.kdst[link]===nidb 
                return link
            end
            link=net.knexts[link]
        end
    end
    link=net.firstlinkin[nida]
    while (link!==0)
        if net.ksrc[link]===nidb 
            return link
        end
        link=net.knextd[link]
    end
    0
end