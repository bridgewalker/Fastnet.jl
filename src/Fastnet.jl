#__precompile__(false) 

module Fastnet

using StaticArrays,Random,DataFrames,Formatting

export FastNet,FastSim,LinkType,
    node_f, node,           # Node functions
    nodestate_f, nodestate,  
    nodestate_f!, nodestate!,
    makenode_f!, makenode!,
    makenodes_f!, makenodes!,
    destroynode_f!, destroynode!,
    countnodes_f, countnodes,
    nodecounts_f, nodecounts,
    firstlinkin_f, firstlinkin,
    firstlinkout_f, firstlinkout,
    degree_f, degree,
    indegree_f, indegree,
    outdegree_f, outdegree,
    nodeexists_f,nodeexists,
    randomnode_f,randomnode,

    link_f, link,                   # link functions         
    linkstate_f, linkstate,
    makelink_f!, makelink!, 
    destroylink_f!, destroylink!,
    linksrc_f, linksrc,
    linkdst_f, linkdst,
    nextlinkout_f, nextlinkout,
    nextlinkin_f, nextlinkin,
    countlinks_f, countlinks,
    linkcounts_f, linkcounts,
    countlinksinstate_f, countlinksinstate,
    linkexists_f,linkexists,
    randomlink_f,randomlink,

    nullgraph!,             # networktools
    randomgraph!,
    configmodel!,
    emptygraph!,

    showlinks,shownodes,     # Debug Functions
    healthcheck,
    
    listnodes,               # Analaysis functions
    listlinks,
    listnodesinstate,
    listneighbors,
    listnodestates,
    results,
    savelinklist,
    savenodeinfo,

    runsim!,                  # Simulation 
    simstep!

include("helpers.jl")
include("structure.jl")
include("internal.jl")
include("access.jl")
include("node.jl")
include("link.jl")
include("safenode.jl")
include("safelink.jl")
include("simulation.jl")
include("nettools.jl")
include("debug.jl")
include("prettyprint.jl")

end # module
