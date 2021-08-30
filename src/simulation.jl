

function showresults(sim::FastSim,head::Bool)
    net=sim.net
    nodes=nodecounts_f(net)
    links=linkcounts_f(net)
    push!(sim.results,[sim.t,nodes...,links...])
    ndig=sim.nodedigits
    ldig=sim.linkdigits
    tdig=sim.timedigits
    tdec=sim.timedec
    t=sim.t
    c=net.C-1
    l=net.L-2
    if head
        fastprint(sim,padright("Time",tdig))
        for i=1:c
            fastprint(sim,"    ",padright(net.nodealias[i],ndig))
        end
        for i=1:l
            fastprint(sim,"    ",padright(net.linkalias[i],ldig))
        end        
        fastprint(sim,"\n")
    end
    fastprint(sim,showfloat(t,tdec,tdig))   
    for i=1:c
        fastprint(sim,"    ",padleft(string(nodes[i]),ndig))
    end
    for i=1:l
        fastprint(sim,"    ",padleft(string(links[i]),ldig))
    end        
    fastprint(sim,"\n")
    if length(sim.filename)!==0
        fl=open(sim.filename,"a")
        if sim.Nout===0
            print(fl,"Time")
            for i=1:c
                print(fl,",",net.nodealias[i])
            end
            for i=1:l
                print(fl,",",net.linkalias[i])
            end        
            print(fl,"\n")
        end
        print(fl,t)   
        for i=1:c
            print(fl,",",nodes[i])
        end
        for i=1:l
            print(fl,",",links[i])
        end        
        print(fl,"\n")
        close(fl)
    end
end



"""
    simstep!(sim)

Simulate the next event in *sim*.

This function will always advance the sim by exactly one event. 
Output is generated at start time and directly after the event has occured. 

See also [FastSim](#Fastnet.FastSim),[simstep](#Fastnet.simstep) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(2,1,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,2);

julia> function rates!(r,t)
         r[1]=countnodes(net,2)
         end
rates! (generic function with 1 method)

julia> function simpleproc!()
         node=randomnode(net,2)
         nodestate!(net,node,1)
         end
simpleproc! (generic function with 1 method)

julia> sim=FastSim(net,rates!,[simpleproc!]; output=false)
Simulation run, currently at time 0.0

julia> simstep!(sim)

julia> nodecounts(net)
2-element Vector{Int64}:
 2
 0
```
"""
function simstep!(sim::FastSim)
    rates=MVector{sim.Nproc}(zeros(sim.Nproc))
    sim.ratefunc(rates,sim.t)
    tot=sum(rates)
    rng=sim.net.rng
    del=randexp(rng)/tot
    initsim(sim,del,del)
    sim.repfunc(sim,true)
    sim.t+=del
    r=rand(rng,0.0:tot)-rates[1]
    i=1
    while(r>=0 && i<sim.Nproc)
        i+=1
        r-=rates[i]
    end
    sim.procfunc[i]()
    sim.repfunc(sim,false)
end

"""
    runsim!(sim,dur,out=1.0)

Run the simulation *sim* for time *dur*, producing out at intervals *out*.

During the simulation the FastSim and its associated FastNet object will 
be updated to reflect the current state of the network (though see notes 
on the simulation time, [here](#Fastnet.FastSim)).  

This function simulates the FastSim **at least** for a certain time. If there 
are still events occuring in the simulation by the end of the simulation run 
the simulation will stop directly after the first event that happens after *dur*.
So the simulation time will always be greater than *dur*. In general the difference and 
the actual simulation time will be tiny, but in case events are extreley rare the
simulation may run significantly beyond *dur*. This behaviour is necessary to 
avoid a watchdog-paradox artifact when repeatedly starting short runs. 

Output is generated once at the start of the simulation and then at every multiple of out. 
For example, if the simulation time is *t=3.12* at the start of the run, *dur=10* and *out=5* then
outputs will be generated at times 3.12, 5 and 10. As a result the network will  
be left in a state that differs from the statistics in the last output. 

See also [FastSim](#Fastnet.FastSim),[simstep!](#Fastnet.simstep!) 

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(2,1,2,[])
Network of 0 nodes and 0 links

julia> n1=makenode!(net,1);

julia> n2=makenode!(net,2);

julia> function rates!(r,t)
         r[1]=countnodes(net,2)
         end
rates! (generic function with 1 method)

julia> function simpleproc!()
         node=randomnode(net,2)
         nodestate!(net,node,1)
         end
simpleproc! (generic function with 1 method)

julia> sim=FastSim(net,rates!,[simpleproc!]; output=false)
Simulation run, currently at time 0.0

julia> runsim!(sim,100)

julia> nodecounts(net)
2-element Vector{Int64}:
 2
 0
```
"""
function runsim!(sim::FastSim,dur,out=1.0)
    Tdur=Float64(dur)
    Tout=Float64(out)
    initsim(sim,Tdur,Tout)
    net=sim.net
    sim.repfunc(sim,true)
    Tend=sim.Tend
    t=sim.t
    Nproc=sim.Nproc
    rates=MVector{Nproc}(zeros(Nproc))
    nextout=(floor(t/Tout)+1.0)*Tout
    while(t<Tend)
        sim.ratefunc(rates,t)
        tot=sum(rates)
        if tot==0.0
            t=nextout
            sim.Nout+=1
            sim.t=nextout
            sim.repfunc(sim,false)
            nextout+=Tout
        else
            t+=randexp(net.rng)/tot           
            while(nextout<t)
                sim.Nout+=1
                sim.t=nextout
                sim.repfunc(sim,false)
                nextout+=Tout
            end
            r=rand(net.rng,0.0:tot)-rates[1]
            i=1
            while(r>=0 && i<Nproc)
                i+=1
                r-=rates[i]
            end
            sim.t=t
            sim.procfunc[i]()
        end 
    end
    nothing
end


