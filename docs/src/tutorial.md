# Fastnet.jl Tutorial -- SIS Model

**In this tutorial we are going to build an epidemiological SIS model**

## The SIS Model
The SIS model describes the spreading of an epidemic disease across a social network. The network nodes represent individuals, whereas the links represent repeated contacts between individuals that allow the disease to spread.  
At all times each node is in either of two states: susceptible (S) or it is infected (I). 

The system changes in time due to two processes: 

1. For every link that connects an infected to a susceptible node (*SI*-link) there is a chance that the disease is transmitted to the susceptible node. Such transmissions occur at a rate *p* per SI-link. 
2. Infected nodes recover in time, returning to the susceptible state (there is no period of immunity after recovery). Such recovery events occur at the rate *r* per infected node. 

## Preparations
We now write a short program that simulates the SIS model using Fastnet. We start by invoking the package and defining some helpful constants

```julia 
using Fastnet

const S=1                   # Node state 1: Susceptible node
const I=2                   # Node state 2: Infected node
const SI=1                  # Link state 1: Susceptible-Infected link 

const p=0.05                # Infection rate (per SI-link)
const r=0.1                 # Recovery rate (per I-node)
```

The first line just tells Julia that we want to use the Fastnet package. The package will keep track of the network including the node and link states for us. However as developers we must remember which state is which. In the following node state 1 will mean that the node is susceptible and node state 2 means that the node is infected. To avoid having to remember this we just define two constants S and I. From now on we can use these to refer to the node states. 

In addition to nodes also links have states, which depend on the nodes they connect. We are only interested in one of these link states, the SI-links, so the links that connect a susceptible to an infected node. We say that such links are in state one, more about this in a moment, but we already define a constant *SI* to mean 1. 

The final block in the code above defines two constants for the infection rate and the recovery rate. Again, we don't actually have to do this, but it is good style as it allows you to change these parameters quickly and cleanly if you want to explore the models behavior for different parameter values. 

## Keeping Track of Links
Fastnet achieves linear-time performance by keeping track of links using an innovative data structure. To be able to do its job we need to tell the package which types of links it needs to keep track of specifically. We a describe links using the LinkType structure like this

```julia
SI_link=LinkType(S,I,2)     # This describes what we mean by SI-link 
```

The constructor of *LinkType* takes three parameters, the state of the node at the source of the link, the state of the node at the destination of the link, and whether the link should be considered as unidirectional or bidirectional.

Internally FastNet represents all links as directed links, as this does not incur any additional costs in terms of performance or memory. So we always refer to one endpoint as the source of the link and one endpoint as the destination. 

In our epidemic model the links are undirected so we tell Fastnet to ignore the directionality of the link, by passing 2 (= Bidirectional) as the third argument. The only other value that is allowed for this argument is 1 (= Unidirectional).

In summary, the code above describes what we mean by an SI_link: any link that connects a node in state S to an node in state I, regardless of direction of the link.  

## Making the network
We are now ready to set up the network which we create with the following code:

```julia
# Lets make a network of 1M nodes and 4M links, 2 node states, that keeps track of SI links
net=FastNet(1000000,4000000,2,[SI_link]; nodealias=["S","I"], linkalias=["SI"])
```

The initial command constructs the data structure for the network itself. The first two arguments tell it how many nodes and links we want to have in the network at most. Here we go with one million links and four million nodes. (Don't worry, Fastnet is fast, even with a million nodes the simulation finishes in about a minute on my laptop).
The thrid argument is the number of states that we allow for the nodes. 

The fourth argument is more interesting. It is an array of all the link types we want to keep track of. In our case this array contains only one link type, the SI_link type that we just defined. Because *SI_link* is the first entry in the array Fastnet will think of SI-links as link state 1.

The arguments discussed above are the only essential arguments for the network constructor. However, we include two more optional arguments to make the output prettier. These are implemented as named arguments. In Julia we can provide such named arguments in any order or not at all, but we have to state their name so that Julia knows which arguments we want to specify. One of the optional arguments is called nodealias, and it accepts a vector of strings. Fastnet will use these strings to refer to the node states in outputs. The second argument linkalias does the same job for links. So in summary the first command tells Julia that we want a network of up to 1M nodes, up to 4M links, where the nodes can be in either of two states, which want to be called S and I in outputs. We want Fastnet to keep track of links between nodes in state S and nodes in state I, and we want it to refer to those links as SI in outputs.    

## Setting up
Now we have a network, but so far it is a null graph; it doesn't contain any nodes and links. We can bring it to life with a few more lines of code

```julia
randomgraph!(net)           # Initialize as ER-random graph (all nodes will be in state 1: S)

for i=1:20                  # Infect 20 nodes at random 
    node=randomnode(net,S)
    nodestate!(net,node,I)
end
```

If we call *randomgraph!* like this, without further arguments, it creates the maximal number of nodes and links allowed in this network. The network is created as an Erdos-Renyi random graph, so all the links are placed at random. Initially all nodes will be in state one which in our model means that they are susceptible. Also note that Fastnet follows a Julia convention that says that all functions that change their arguments should have a name ending in an exclamation mark.

To get our epidemic going we will need some infected, so we use a simple for loop to infect 20 nodes at random. In the loop we use *randomnode* to pick a node in state S at random from the network. Due to the magic of Fastnet, picking a random node like this is done in constant time, i.e. the time needed for this operation does not scale with the size of the network or the number of states at all. 

Once we have picked a random node we use *nodestate!* to change the state of the node to infected. The time required for this command scales with the number of link states that we keep track of and the degree of the node, but not on the overall size of the network. 

## The rates! function 
Now that we have our network set up, it's time to get to the physics of the system, i.e. the rules that will drive the dynamics. A crucial part of an event-driven simulation is to calculate how fast the different processes run in the current state of the network (whatever that may be). In our SIS model we calculate these rate in the following function

```julia
function rates!(rates,t)    # This functins computes the rates of processes
    infected=countnodes(net,I)        # count the infected nodes
    activelinks=countlinks(net,SI)    # count the SI links
    infrate=p*activelinks               # compute total infection rate
    recrate=r*infected                  # compute total recovery rate 
    rates[1]=infrate                    # Return the values by filling the rates array
    rates[2]=recrate
    nothing
end
```

In a Fastnet simulation the rates function takes two arguments, a vector that needs to be filled with the rates and the current time. Note that the function does not need to return the computed rates but instead fills them into the vector that is provided as an argument. This is done for performance reasons. In the rates! function performance is crucial as this function will be called many, many times in the simulation. 

To compute the node the current rate at which infection and recovery events are happening we need to know how many infected nodes and how many SI-links there are in the network. We find these numbers with the *countnodes* and *countlinks* functions, respectively. Despite their names, these functions do not actually need to count anything, the net knows the answer already, so they both work in constant time. 

We then compute our total infection rate by multiplying the numeber of SI-links with the *p*, the infection rate per SI-link. Likewise we find the total recovery rate by multiplying the number of infected nodes by *r*, the recovery rate per infected node. 

Finally we fill the *rates* vector with the results. Here we chose to put the infection rate in the first place in the array and the recovery rate in the second. Up to this point the numbering of processes was undetermined, but from now on we have to be consistent, so infection will be process 1 and recovery will be process 2 from now on. 

The final *nothing* tells Julia that the function does not have a return value. 

(One may wonder whether it would be more efficient to squeeze the six lines of code into two lines and avoid the definition of intermediate variables. The answer is generally no. Julia is a compiled language and the compiler will take care of such small scale optimizations for us, so it won't make a difference in performance. In this case the longer form makes the code more readable and makes it easier to fnd bugs.)

## Implementing the processes
As the final piece of our model we need to define what happens when the processes occur we do this by defining two more functions 

```julia
function recovery!()        # This is what we do when the recovery process is triggered
    inode=randomnode(net,I)           # Find a random infected node
    nodestate!(net,inode,S)           # Set the state of the node to susceptible
end

function infection!()       # This is what we do when the infection process is triggered
    alink=randomlink(net,SI)          # Find a random SI link
    src=linksrc(net,alink)            # Find the endpoints of the link
    dst=linkdst(net,alink)
    nodestate!(net,src,I)             # Set both endpoints of the link to infected
    nodestate!(net,dst,I)              # this is quicker than finding who's infected 
end
```

If a recovery event occurs a random node recovers, so in our *recovery!* function we use *randomnode* to pick a node in state I at random. Then, we use *nodestate!* to set the state of that node to S. 

In an infection event the disease gets passed along a random SI-link, so we use *randomlink* to pick an SI link at random. Then we find the two endpoints of the link with *linksrc* and *linkdst*. We could then use an *if* statement to find out which one of the two endpoints is the susceptible node, but ifs create control hazards which aren't great for performance so its probably a bit quicker to set both of the endpoints to the infected state. (One of them was infected anyway and the other is the one that we need to infect.)

Again the fuctions used in our implementation of these processes run either in constant time (*randomnode*,*randomlink*,*linksrc*,*linkdst*), or they scale only with the degree of the affected node and the number of link states that we are tracking (*nodestate!*), hence the runtime required to simulate one event won't depend on the network size. Simulating a network for a finite time will still scale linearly with network size as larger networks have more nodes and links on which events can occur.  

### Simulation
Now that we have all the pieces, we can set up and run the simulation

```julia
sim=FastSim(net,rates!,[infection!,recovery!], saveas="result.csv")   # initialize the simulation 

@time runsim(sim,60,5)      # Run for 60 timeunits (reporting every 5)
```

The first of these lines actually sets up the simulation. The essential arguments of the simulation constructor are the network, our *rates!* function and a vector containing the functions that implement the processes. 

Note that the order of function in the third argument is not arbitrary. Recall that our *rates!* function returns the infection rate as the first elements of the *rates* vector. Therefore the *infection!* function also needs to be in the first spot in the argument.  

The *FastSim* constructor has a number of named arguments. Here we use *saveas* to tell the simulation to save its results in a file called *results.csv*. If we don't specify this argument then the results won't be saved, but we can still get them from the sim as a DataFrame using the *results* function. 

Finally we run the simulation using the *runsim* command. It's essential arguments are the simulation and the amount of time that we want to simulate. The third, optional, argument specifies the interval at which results should be reported. (Of course our primal instincts tell us to get as much data out as we possibly can, but its a good idea to resist these urges. If your aim is to get a nice plot of the results you will typically have a better results and a be a happier person if your result files contain 50 points rather than 500. Just sayin'.)

Before the *runsim* I have added Julia's *@time* macro which times the performance of the function. This is often useful information to have. If you find that the present code runs in about a minute or so, you might decide that you would like to run a simulation on 10M nodes and 40M links instead. Because everything else being the same your 10M node simulation should take about the 10 minutes, so enough time for a coffee if you are quick. 

But before we run really large simulations we should make one final improvement...

## Faster functions
To help with debugging, functions such as *nodestate!* carry out a number of checks and try to provide meaningful error message if their arguments look iffy. This comes at a price in terms of performance. Because your rates and process functions might be called billions of times in large simulations, you may want to avoid these extra checks. For this purpose Fastnet provides faster implementations for some of the key functions. The names of these functions are identical to the other function names with an added *_f* at the end, so in addion to *nodestate!* there is also 

```julia
nodestate_f!(net::FastNet,node,newstate)
```

This function is identical to *nodestate!* but avoids some of the safety checks. Likewise such fast implementations also exist for most of the other functions that you would use in your *rates!* and process functions. So once we are happy with our program and have run it a few times, we can speed it up a little bit by changing the *rates!* and process functions to   

```julia
function rates!(rates,t)                # This functins computes the rates of processes
    infected=countnodes_f(net,I)                # count the infected nodes
    activelinks=countlinks_f(net,SI)            # count the SI links
    infrate=p*activelinks                       # compute total infection rate
    recrate=r*infected                          # compute total recovery rate 
    rates[1]=infrate                            # Return the values by filling the rates array
    rates[2]=recrate
    nothing
end

function recovery!()                    # This is what we do when the recovery process is triggered
    inode=randomnode_f(net,I)                   # Find a random infected node
    nodestate_f!(net,inode,S)                   # Set the state of the node to susceptible
end

function infection!()                   # This is what we do when the infection process is triggered
    alink=randomlink_f(net,SI)                   # Find a random SI link
    nodestate_f!(net,linksrc_f(net,alink),I)     # Set both endpoints of the link to infected
    nodestate_f!(net,linkdst_f(net,alink),I)    
end
```

The performance increase is not huge (ca.~20%), so don't feel bad about using the functions without the _f at first, but in large simulations the form with the _f may save some time and energy. 

## Full example code 
The final version of the complete code looks like this 
```julia

using Fastnet

const S=1                               # Node state 1: Susceptible node
const I=2                               # Node state 2: Infected node
const SI=1                              # Link state 1: Susceptible-Infected link 

const p=0.05                            # Infection rate (per SI-link)
const r=0.1                             # Recovery rate (per I-node)

SI_link=LinkType(S,I,2)                 # This describes what we mean by SI-link 

# Let's make a network of 1M nodes and 4M links, 2 node states, that keeps track of SI links
net=FastNet(1000000,4000000,2,[SI_link]; nodealias=["S","I"], linkalias=["SI"])

randomgraph!(net)                       # Initialize as ER-random graph (all nodes will be in state 1: S)

for i=1:20                              # Infect 20 susceptible nodes at random 
    node=randomnode(net,S)
    nodestate!(net,node,I)
end

function rates!(rates,t)                # This functins computes the rates of processes
    infected=countnodes_f(net,I)                # count the infected nodes
    activelinks=countlinks_f(net,SI)            # count the SI links
    infrate=p*activelinks                       # compute total infection rate
    recrate=r*infected                          # compute total recovery rate 
    rates[1]=infrate                            # Return the values by filling the rates array
    rates[2]=recrate
    nothing
end

function recovery!()                    # This is what we do when the recovery process is triggered
    inode=randomnode_f(net,I)                   # Find a random infected node
    nodestate_f!(net,inode,S)                   # Set the state of the node to susceptible
end

function infection!()                   # This is what we do when the infection process is triggered
    alink=randomlink_f(net,SI)                   # Find a random SI link
    nodestate_f!(net,linksrc_f(net,alink),I)     # Set both endpoints of the link to infected
    nodestate_f!(net,linkdst_f(net,alink),I)    
end

sim=FastSim(net,rates!,[infection!,recovery!])   # initialize the simulation 

@time runsim!(sim,60.0,5.0)                      # Run for 60 timeunits (reporting every 5)

```

The code can also be found [here](https://github.com/bridgewalker/Fastnet.jl/blob/master/examples/SIS.jl).

Some more examples for other models can be found in the same [here](https://github.com/bridgewalker/Fastnet.jl/blob/master/examples).


## Running the example code

If you are new to Julia one of the simplest ways to get this code to work is 

1. Install Julia 
2. Install Fastnet from Julia (as described on the welcome page)
3. Exit Julia and download the SIS.jl

You can then run the SIS.jl either from your console using 

```shell
julia "SIS.jl"
```

or form Julia's REPL by executing 

```julia
include("SIS.jl")
``` 


