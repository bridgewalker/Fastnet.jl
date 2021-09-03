
# Customization
FastNet is designed to run the most common types of discrete-event network simulations efficiently. 
If what you need to do is very different from these typical use cases you will probably need a different tool. However, between these extremes there is a grey area where you may be able to achieve your goals by 
customizing Fastnet. 

## Custom Output Functions
If you all you need is a different output, you can pass your own reporting function to FastSim. For reference, the default reporting function is called *showresults* and can be found in the simulation.jl source file. 
The reporting function is a function of the form 
```julia
MyReportingFunction(sim::FastSim,head::Bool)
```
The first argument that is passed is a reference to the sim that should be reported on. The second argument is a bool that tells the function whether a header needs to be printed. For example the default reporting function prints first the column heads of the output table and then the network state if true is passed. It prints only the network state if false is passed.  

Once called your custom reporting function should handle all the neccessary printing, writing to disk, etc.  
Also your reporting function should push the node and link counts to the *sim.results* dataframe, if you want the 
results to be stored there. You can do this by including 
```julia
    net=sim.net
    nodes=nodecounts_f(net)
    links=linkcounts_f(net)
    push!(sim.results,[sim.t,nodes...,links...])
```
as the first lines of your reporting function.

Some useful information can be read from the first argument *sim*:

- *sim.net*  -- A reference to the FastNet object
- *sim.t* -- Current time of the simulation
- *sim.Tend* -- End time of the simulation
- *sim.nodedigits* -- The expected number of characters needed to display node counts
- *sim.linkdigits* -- The expected number of characters needed to display link counts
- *sim.timedigits* -- The expected number of characters needed to display the simulation time  
- *sim.timedec* -- The expected number of decimal places to needed to approximately show simulation time
- *sim.Nout* -- a counter containing the number of the current output
- *sim.results* -- the DataFrame where results should go
- *sim.filename* -- the savefilename passed to *sim* during creation. Empty string, if no name as passed.
- *sim.printresults* -- see below  

The *printresults* field contains either true, if output should be printed to the terminal, false if no output should be printed to the terminal or an IOStream to which terminal output should be redirected. 

Information about the network can be gained by calling the typeical functions (countnodes, etc.) on *sim.net*. In addition the FastNet object *sim.net* contains two fields that may be useful

- *sim.net.nodealias* -- A Vector of strings containing names for the node states
- *sim.net.linkalias* -- A Vector of strings containing names for the tracked link states

## FastNet without FastSim
If you want to change the nature of the simulation, e.g. to introduce events happing after fixed time delays 
or if you want fixed timesteps instead of the event-driven simulation you can't use FastSim, but you may still 
want to use FastNet to keep track of the network. Allowing this split was the main reason for having two structures 
instead of one. 

