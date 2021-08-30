using Test


@testset "basic functionality" begin

    function testproc()
        lnk=randomlink(net,1)
        nd=linkdst(net,lnk)
        nodestate!(net,nd,3)
    end
    
    function testrates(r,t)
        r[1]=countlinks(net,1)
    end
    
    using Fastnet
    n=10
    m=5
    net=FastNet(1000,2000,5,[LinkType(3,1,1),LinkType(1,3,1),LinkType(2,2,2)])
    makenodes!(net,n,1)
    @test countnodes(net,1)==n
    nodes=[node(net,1,i) for i in 1:n]
    @test nodestate(net,randomnode(net,1))==1
    nodestate!(net,nodes[m],3)
    @test nodestate(net,nodes[m])==3
    for i=1:(n-1)
        makelink!(net,nodes[i],nodes[i+1])
    end 
    @test countlinks(net)==n-1
    lnk=firstlinkout(net,nodes[m])
    @test lnk!=0
    @test linkdst(net,lnk)==nodes[m+1]
    @test linksrc(net,lnk)==nodes[m]
    @test nextlinkout(net,lnk)==0
    @test linkstate(net,lnk)==1
    lnk=firstlinkin(net,nodes[m])
    @test linkdst(net,lnk)==nodes[m]
    @test linksrc(net,lnk)==nodes[m-1]
    @test nextlinkin(net,lnk)==0
    @test linkstate(net,lnk)==2
    sim=FastSim(net,testrates,[testproc],output=false)
    for i=1:3
        simstep!(sim)    
        for j=1:n
            if j<m
                @test nodestate(net,nodes[j])==1
            end
            if j>=m && j<=m+i 
                @test nodestate(net,nodes[j])==3
            end
            if j>m+i   
                @test nodestate(net,nodes[j])==1
            end            
        end
    end
    nothing
end




