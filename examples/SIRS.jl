using Fastnet

const S=1                   # Node state 1: Susceptible node
const I=2                   # Node state 2: Infected node
const R=3
const SI=1                  # Link state 1: Susceptible-Infected link 

p=0.05                      # Infection rate (per SI-link)
r=0.1                       # Recovery rate (per I-node)
l=0.02                      # Loss of immunity rate (per R-node)

SI_link=LinkType(S,I)     # This describes what we mean by SI-link 

# Lets make a network of 100k nodes and 400k links, 2 node states, that keeps track of SI links
net=FastNet(100000,400000,3,[SI_link]; nodealias=["S","I","R"], linkalias=["SI"])

randomgraph!(net)           # Initialize as ER-random graph (all nodes will be in state 1: S)

for i=1:20                  # Infect 20 nodes at random 
    node=randomnode(net,S)
    nodestate!(net,node,I)
end

function rates!(rates,t)    # This function computes the rates of processes
    infected=countnodes_f(net,I)        # count the infected nodes
    recovered=countnodes_f(net,R)        # count the infected nodes    
    activelinks=countlinks_f(net,SI)    # count the SI links
    infrate=p*activelinks               # compute total infection rate
    recrate=r*infected                  # compute total recovery rate
    lossrate=l*recovered  
    rates[1]=infrate                    # Return the values by filling the rates array
    rates[2]=recrate
    rates[3]=lossrate
    nothing
end

function recovery!()        # This is what we do when the recovery process is triggered
    inode=randomnode_f(net,I)                   # Find a random infected node
    nodestate_f!(net,inode,R)                   # Set the state of the node to recovered
end

function lossofi!()        # This is what we do when a node loses immunity
    rnode=randomnode_f(net,R)                   # Find a node in the recovered state
    nodestate_f!(net,rnode,S)                   # Set the state of the node to susceptible
end

function infection!()       # This is what we do when the infection process is triggered
    alink=randomlink_f(net,SI)                   # Find a random SI link
    nodestate_f!(net,linksrc_f(net,alink),I)     # Set both endpoints of the link to infected
    nodestate_f!(net,linkdst_f(net,alink),I)    
end

sim=FastSim(net,rates!,[infection!,recovery!,lossofi!])   # initialize the simulation 

@time runsim!(sim,100,10)                      # Run for 100 timeunits (reporting every 10)
