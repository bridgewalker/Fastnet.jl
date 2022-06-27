
# Pillai et al. style Meta-foodchain modified from original code by Sebastian Kusch

using Fastnet

na = ["Producer","Consumer","Predator","Empty"]

present1 = (1,2,3)
present2 = (2,3)
present3 = 3

L10=LinkType(1,4)
L20=LinkType(2,4)
L30=LinkType(3,4)
L21=LinkType(2,1)
L31=LinkType(3,1)
L32=LinkType(3,2)

linklist=[L10,L20,L30,L21,L31,L32]
la=["1-0","2-0","3-0","2-1","3-1","3-2"] 

routes1=(1,2,3)
routes2=(4,5)
routes3=6

# parameters
dispersal=[1.0, 0.5, 0.25] 
mortality=[1.0, 0.1, 0.01]  

#network
z=5 
n=10000
k=(n*z)÷2
net=FastNet(n,k,4,linklist; nodealias=na,linkalias=la)
randomgraph!(net)   
rand_init = rand(1:4,n)                          # generate random patch state
for i=1:n                                        # Assign patch state at random
    nodestate_f!(net,node_f(net,i),rand_init[i])
end

function rates!(rates,t)    # This function computes the rates of processes
    rates[1]=mortality[1]*countnodes(net,present1)             # species 1 death
    rates[2]=mortality[2]*countnodes(net,present2)                # species 2 death
    rates[3]=mortality[3]*countnodes(net,present3)                     # species 3 death
    rates[4]=dispersal[1]*countlinks(net,routes1)             # species 1 migration
    rates[5]=dispersal[2]*countlinks(net,routes2)                  # species 2 migration
    rates[6]=dispersal[3]*countlinks(net,routes3)                # species 3 migration
    nothing
end

function loss1()        # This is what we do when a primary producer dies
    nde=randomnode(net,present1)          # Find a random node of state 1,2 or 3
    nodestate_f!(net,nde,4)                  # Set the state of the node to empty patch
end

function loss2()        # This is what we do when a species of state 2 dies
    nde=randomnode(net,present2)             # Find a random node of state 2 or 3
    nodestate_f!(net,nde,1)                  # Set the state of the node to S1
end

function loss3()                     # This is what we do when a species of state 3 dies
    nde=randomnode(net,present3)                  # Find a random node of state 3
    nodestate!(net,nde,2)                  # Set the state of the node to S2
end

function disperse1()       # This is what we do when a species 1 migration process is triggered
    alink=randomlink(net,routes1)    # Find a random species 1 migration link
    src = linksrc(net,alink)
    dst = linkdst(net,alink)
    if nodestate(net,src) == 4    # determine migration destination in undirected link and update to S1
        nodestate!(net,src,1)
    else
        nodestate!(net,dst,1)
    end
end

function disperse2()       # This is what we do when a species 2 migration process is triggered
    alink=randomlink(net,routes2)         # Find a random species 2 migration link
    src = linksrc(net,alink)
    dst = linkdst(net,alink)
    if nodestate(net,src) == 1  # determine migration destination in undirected link and update to S2
        nodestate!(net,src,2)
    else
        nodestate!(net,dst,2)
    end
end

function disperse3()       # This is what we do when a species 3 migration process is triggered
    alink=randomlink(net,routes3)                # Find a random species 3 migration link
    src = linksrc(net,alink)
    dst = linkdst(net,alink)
    if nodestate(net,src) == 2 # determine migration destination in undirected link and update to S3
        nodestate!(net,src,3)
    else
        nodestate!(net,dst,3)
    end
end

# Simulation
sim=FastSim(net,rates!,[loss1,loss2,loss3,disperse1,disperse2,disperse3])   # initialize the simulation
@time runsim!(sim,10,2)

