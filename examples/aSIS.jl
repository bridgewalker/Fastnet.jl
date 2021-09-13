
# This file implements the adaptive SIS model from :
#
#      Gross, Dommar, Blasius: "Epidemic dynamics on an adaptive network"
#      Physical Review Letters 96, 208701, 2006
#      doi: 10.1103/PhysRevLett.96.208701

using Fastnet

const S=1                   # Node state 1: Susceptible node
const I=2                   # Node state 2: Infected node
const SI=1                  # Link state 1: Susceptible-Infected link 

p=0.004                     # Infection rate (per SI-link)
r=0.002                     # Recovery rate (per I-node)
w=0.2                       # Rewiring rate (per SI-link)

SI_link=LinkType(S,I)     # This describes what we mean by SI-link 

# Lets make a network of 100k nodes and 400k links, 2 node states, that keeps track of SI links
net=FastNet(100000,1000000,2,[SI_link]; nodealias=["S","I"], linkalias=["SI"])

randomgraph!(net)           # Initialize as ER-random graph (all nodes will be in state 1: S)

for i=1:96000               # Infect 20 nodes at random 
    node=randomnode(net,S)
    nodestate!(net,node,I)
end

function rates!(rates,t)    # This functins computes the rates of processes
    infected=countnodes_f(net,I)        # count the infected nodes
    activelinks=countlinks_f(net,SI)    # count the SI links
    infrate=p*activelinks               # compute total infection rate
    recrate=r*infected                  # compute total recovery rate
    rewrate=w*activelinks               # compute total rewiring rate
    rates[1]=infrate                    # Return the values by filling the rates array
    rates[2]=recrate
    rates[3]=rewrate
    nothing
end

function recovery!()        # This is what we do when the recovery process is triggered
    inode=randomnode_f(net,I)                   # Find a random infected node
    nodestate_f!(net,inode,S)                   # Set the state of the node to susceptible
end

function infection!()       # This is what we do when the infection process is triggered
    alink=randomlink_f(net,SI)                   # Find a random SI link
    nodestate_f!(net,linksrc_f(net,alink),I)     # Set both endpoints of the link to infected
    nodestate_f!(net,linkdst_f(net,alink),I)    
end

function rewire!()         # This is what we do  when 
    lnk=randomlink_f(net,SI)                    # Find a random SI link
    src=linksrc_f(net,lnk)
    dst=linkdst_f(net,lnk)
    sus=randomnode_f(net,S)
    destroylink_f!(net,lnk)
    if nodestate_f(net,src)==S
        makelink_f!(net,src,sus)
    else
        makelink_f!(net,sus,dst)
    end    
end

sim=FastSim(net,rates!,[infection!,recovery!,rewire!])   # initialize the simulation 

@time runsim!(sim,500,20)                       # Run for 60 timeunits (reporting every 5)

