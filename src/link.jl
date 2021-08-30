
function link_f(net::FastNet,c,rp)
    @inbounds linkpos=net.kcstart[c]+rp
    @inbounds net.kid[linkpos]   
end

function link_f(net::FastNet,rp)
    @inbounds net.kid[rp]   
end

function linkstate_f(net::FastNet,kid)    
    @inbounds net.kstate[kid]
end

function makelink_f!(net::FastNet,src,dst)
    @inbounds begin
        kid=link_f(net,net.L,1)
        net.ksrc[kid]=src
        net.kdst[kid]=dst
        cls=net.ttable[net.nstate[src],net.nstate[dst]]
        linkstate_f!(net,kid,cls)
        net.knexts[kid]=net.nout[src]
        net.knextd[kid]=net.nin[dst]
        net.nout[src]=kid
        net.nin[dst]=kid
    end
    kid
end

function destroylink_f!(net::FastNet,kid)
    lastsrc=0
    lastdst=0
    @inbounds begin
        srcn=net.ksrc[kid]
        dstn=net.kdst[kid]
        cur=net.nout[srcn]
        while cur!=kid
            lastsrc=cur
            cur=net.knexts[cur]
        end
        cur=net.nin[dstn]
        while cur!=kid
            lastdst=cur
            cur=net.knextd[cur]
        end 
        if lastsrc!=0
            net.knexts[lastsrc]=net.knexts[kid]  
        else
            net.nout[srcn]=net.knexts[kid]
        end
        if lastdst!=0
            net.knextd[lastdst]=net.knextd[kid]
        else
            net.nin[dstn]=net.knextd[kid]
        end    
        linkstate_f!(net,kid,net.L)
    end
    nothing
end

function linkexists_f(net::FastNet,kid)
    @inbounds net.kstate[kid]!=net.L
end

function linksrc_f(net::FastNet,kid)
    @inbounds net.ksrc[kid]
end

function linkdst_f(net::FastNet,kid)
    @inbounds net.kdst[kid]
end

function nextlinkout_f(net::FastNet,kid)
    @inbounds net.knexts[kid]
end

function nextlinkin_f(net::FastNet,kid)
    @inbounds net.knextd[kid]
end

function countlinks_f(net::FastNet)
    @inbounds net.K-net.kclen[net.L]
end

function countlinks_f(net::FastNet,cls::Integer)
    @inbounds net.kclen[cls]
end

function linkcounts_f(net::FastNet)
    n=net.L-2
    @inbounds net.kclen[1:n]
end

function countlinks_f(net::FastNet,cls::Union{Vector,Tuple})
    ret=0
    @inbounds begin 
        for c in cls
            ret+=net.kclen[c]
        end
    end
    ret
end

function randomlink_f(net::FastNet)
    link_f(net,rand(net.rng,1:countlinks_f(net)))
end

function randomlink_f(net::FastNet,cls::Integer)
    link_f(net,cls,rand(net.rng,1:countlinks_f(net,cls)))
end

function randomlink_f(net::FastNet,cls::Union{Array,Tuple})
    tot=countlinks_f(net,cls)
    r=rand(net.rng,1:tot)
    old=r
    i=1
    cr=old-countlinks_f(net,cls[i])
    while cr>0
        i+=1
        old=cr
        cr=old-countlinks_f(net,cls[i])
    end
    link_f(net,i,old)     
end


