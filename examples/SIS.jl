
# This is an epidemiological SIS model. Each node is in either of two states susceptible (S) or it is infected (I).
# The system changes in time due to two processes. First, for every link that connects an infected to a susceptible node (SI-link)
# there is a chance that the disease is transmitted to the susceptible node. Such transmissions occur at a rate p per SI-link. 
# Second, infected nodes recover in time, returning to the susceptible state (there is no period of immunity after recovery). 
# Such recovery events occur at the rate r per infected node. 

using Fastnet

const S=1                   # Node state 1: Susceptible node
const I=2                   # Node state 2: Infected node
const SI=1                  # Link state 1: Susceptible-Infected link 

const p=0.05                # Infection rate (per SI-link)
const r=0.1                 # Recovery rate (per I-node)

SI_link=LinkType(S,I,2)     # This describes what we mean by SI-link 

# Lets make a network of 1M nodes and 4M links, 2 node states, that keeps track of SI links
net=FastNet(1000000,4000000,2,[SI_link]; nodealias=["S","I"], linkalias=["SI"])

randomgraph!(net)           # Initialize as ER-random graph (all nodes will be in state 1: S)

for i=1:20                  # Infect 20 nodes at random 
    node=randomnode(net,S)
    nodestate!(net,node,I)
end

function rates!(rates,t)    # This functins computes the rates of processes
    infected=countnodes_f(net,I)        # count the infected nodes
    activelinks=countlinks_f(net,SI)    # count the SI links
    infrate=p*activelinks               # compute total infection rate
    recrate=r*infected                  # compute total recovery rate 
    rates[1]=infrate                    # Return the values by filling the rates array
    rates[2]=recrate
    nothing
end

function recovery!()        # This is what we do when the recovery process is triggered
    inode=randomnode_f(net,I)           # Find a random infected node
    nodestate_f!(net,inode,S)           # Set the state of the node to susceptible
end

function infection!()       # This is what we do when the infection process is triggered
    alink=randomlink_f(net,SI)          # Find a random SI link
    src=linksrc_f(net,alink)            # Find the endpoints of the link
    dst=linkdst_f(net,alink)
    nodestate_f!(net,src,I)             # Set both endpoints of the link to infected
    nodestate_f!(net,dst,I)              # this is quicker than finding who's infected 
end

sim=FastSim(net,rates!,[infection!,recovery!], saveas="result.csv")   # initialize the simulation 

@time runsim(sim,60,5)                      # Run for 60 timeunits (reporting every 5)

