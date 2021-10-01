

const EPS=nextfloat(0.0)


"""
    LinkType(from,to,dir=2) 

Create a LinkType structure that describes the properties of a type of link in the network. 

Think of a LinkType as a set of criteria that describe a certain sort of link. The first two arguments 
specify the states of the nodes at the start and end of the link respectively. The third argument specified if the LinkType
can either be 1 or 2, where *dir=1* signifies that the link type should be interpreted as directed (unidirectional)
and *dir=2* signifies that it should be interpreted as undirected (bidirectional). 

The state of the node at the start and end of this type of link can be specified in different ways. 
A value of 0 or \\* for *from* or *to* means that the respective node can be in any state. An integer value corresponding
to a node state means that the node must be in the respective state. An Array or Tuple of Ints means that the 
node must be in one of the states listed.    

# Examples 
```jldoctest
julia> using Fastnet

julia> LinkType(3,4)
Links of the form:  (3) --- (4)

julia> LinkType(3,4,1)
Links of the form:  (3) --> (4)

julia> LinkType(3,4,2)
Links of the form:  (3) --- (4)

julia> LinkType("*",4)
Links of the form:  (any) --- (4)

julia> LinkType(4,0)
Links of the form:  (4) --- (any)

julia> LinkType((1,2),3)
Links of the form:  (1/2) --- (3)

julia> LinkType(4,[1,2],1)
Links of the form:  (4) --> (1/2)
```    

"""
struct LinkType 
    from 
    to
    dir::Int
    LinkType(from,to,dir) = begin
        (f,t,d)=verify_linktype!(from,to,dir)
        new(f,t,d)
    end
end

function LinkType(from,to)
    LinkType(from,to,2)
end


"""
    FastNet(n,k,c,tlist;<keyword arguments>) 

Create a FastNet object that represents a network structe.

Memory will be allocated for up to *n* nodes, up to *k* links. Nodes can be in one of *c* different states.

The argument tlist is an array or tuple of LinkType. This list tells the networks which types of links are 
important for you. For example in an epidemic simulation the we are particularly interested in links between 
infected and susceptible nodes. FastNet will do the necessary bookkeeping, to enable very fast counting, selection, etc.
of the links that are in a state listed in tlist. 

Note that the order of elements of tlist is not arbitrary. FastNet will think of links that match the first element 
of tlist as being in link state 1. The links that match the sceond type in link state 2, and so on. 

WARNING: Each link in the network can only be in any one state at any time passing a tlist that contains overlapping 
link types (e.g. [LinkType([1,2],3),LinkType(3,1)] )  will result in an ArgumentError being thrown. 

FastNet supports a number of optional keyword arguments:
- nodealias : a vector of strings that will be used as names of node states in outputs
- linkalias : a vector of strings that will be used as names of link states in outputs
- rng : specifies a custom random number generator

The network will initially be empty (i.e. a null graph)

# Examples 
```jldoctest
julia> using Fastnet

julia> FastNet(10,9,1,[])
Network of 0 nodes and 0 links

julia> FastNet(100,1000,3,[LinkType(1,2),LinkType(3,"*",1)])
Network of 0 nodes and 0 links

julia> using Random

julia> mt = MersenneTwister(1234);

julia> const S=1;

julia> const I=2;

julia> SI_link=LinkType(S,I)
Links of the form:  (1) --- (2)

julia> net=FastNet(10000,60000,2,[SI_link],nodealias=["S","I"],linkalias=["S-I"],rng=mt)
Network of 0 nodes and 0 links
```    
"""
mutable struct FastNet 
    rng::AbstractRNG
    N::Int
    K::Int
    C::Int
    L::Int
    nid::Vector
    npos::Vector
    nin::Vector
    nout::Vector
    nstate::Vector
    ncstart::Vector
    nclen::Vector
    kid::Vector
    kpos::Vector
    knexts::Vector
    knextd::Vector
    kstate::Vector
    ksrc::Vector
    kdst::Vector
    kcstart::Vector
    kclen::Vector
    ttable::Array
    nodealias::Vector
    linkalias::Vector
end 

function FastNet(n,k,c,tlist;nodealias=String[],linkalias=String[],rng=Random.GLOBAL_RNG)
    N=0
    K=0
    C=0
    try 
        N=convert(Int,n)
    catch e
        throw(ArgumentError("FastNet constructor expects the number of nodes to be of type Int"))
    end
    if N<0
        throw(ArgumentError("FastNet constructor expects the number of nodes to be positive"))
    end    
    try 
        K=convert(Int,k)
    catch e
        throw(ArgumentError("FastNet constructor expects the number of links to be of type Int"))
    end
    if K<0
        throw(ArgumentError("FastNet constructor expects the number of links to be positive"))
    end 
    try 
        C=convert(Int,c)+1
    catch e
        throw(ArgumentError("FastNet constructor expects the number of node states to be of type Int"))
    end
    if C<2 
        throw(ArgumentError("FastNet constructor expects the number of node states to be at least 1"))
    end
    if isa(tlist,Tuple)
        tlist=[tlist...]
    end
    if isa(nodealias,Tuple)
        nodealias=[nodealias...]
    end
    if isa(linkalias,Tuple)
        linkalias=[linkalias...]
    end    
    if isa(tlist,LinkType)
        tlist=[tlist]
    end
    if !isa(tlist,Array)
        msg="FastNet constructor expects the third argument to be an Array{LinkType}"
        throw(ArgumentError(msg))
    end
    if !(isa(tlist,Array{LinkType}) || isempty(tlist))  
        msg="FastNet constructor expects the third argument to be an Array{LinkType}"
        throw(ArgumentError(msg))
    end
    if isa(linkalias,String)
        linkalias=[linkalias]
    end
    if isa(nodealias,String)
        nodealias=[nodealias]
    end
    if !isa(linkalias,Array{String})
        msg="FastNet constructor expects linkalias to be an array of strings."
        throw(ArgumentError(msg))        
    end
    if !isa(nodealias,Array{String})
        msg="FastNet constructor expects nodealias to be an array of strings."
        throw(ArgumentError(msg))        
    end
    l=length(tlist)
    L=l+2 
    if length(nodealias)>c
        msg="Nodealias list passed to FastNet contains more elements than there are node types in the network"
        throw(ArgumentError(msg))        
    end
    if length(linkalias)>l
        msg="Linkalias list passed to FastNet contains more elements than there link types defined in tlist"
        throw(ArgumentError(msg))        
    end
    if !(isa(rng,AbstractRNG))
        msg="FastNet expects rng to be a random number generator (subtype of AbstractRNG)"
        throw(ArgumentError(msg))         
    end
    na=Vector{String}(undef,c)
    la=Vector{String}(undef,l)
    len=length(nodealias)
    for i=1:c
        i<=len ? na[i]=string(nodealias[i]) : na[i]="Node state $i" 
    end
    len=length(linkalias)
    for i=1:l
        i<=len ? la[i]=string(linkalias[i]) : la[i]="Link state $i" 
    end    
    nid=[1:N;]
    npos=[1:N;]
    nin=zeros(Int,N)
    nout=zeros(Int,N)
    nstate=fill(C,N)
    ncstart=zeros(Int,C)
    nclen=zeros(Int,C)
    kid=[1:K;]
    kpos=[1:K;]
    knexts=zeros(Int,K)
    knextd=zeros(Int,K)
    kstate=fill(L,K)
    ksrc=zeros(Int,K)
    kdst=zeros(Int,K)
    kcstart=zeros(Int,L)
    kclen=zeros(Int,L)
    ttable=SArray{Tuple{c,c}}(make_linkstate_table(tlist,c,L))  # Lookup table for tracked link states
    nclen[C]=N
    kclen[L]=K
    return FastNet(rng,N,K,C,L,nid,npos,nin,nout,nstate,ncstart,nclen,kid,kpos,knexts,knextd,kstate,ksrc,kdst,kcstart,kclen,ttable,na,la)
end

"""
    FastSim(net,rates!,processes;<keyword arguments>) 

Create a FastSim structure, representing a FastNet simulation run. 

The first argument *net* is a FastNet structure that is be used in the simulation. 

The second argument is the *rates!* function of the simulation. The rates function is a function 
that accepts two arguments. The first of these arguments is an MVector{Float64} 
(see StaticArrays Documentation for details). The second argument is a the current time in the simulation. 

When the *rates!* function is called it should compute the total rates of at which the different processes 
occur in the system, given the current state of the network. The rates functions returns these values by 
filling the array that was passed as the first argument. The rates! should not have a return value. 

Note that when rates are time dependent then the rates! function should use the time value passed to it rather 
than obtaining a time form the simulation structure. The simulation code assumes that the rates will remain 
constant until the next event. This should be harmless in almost all cases but can cause inaccuracy if your 
rates depend explicitely on time, the rates are very senstitive to time and events are rare. 

The third argument is a Vector of functions that implements the processes. The processes are functions 
without arguments when they are called they should implement effect of the respecive process running once.
Note that elemets of the process function vector should be in the same order as the corresponding rates computed by 
the *rates!* vector.

FastSim supports a number of optional keyword arguments:

- saveas : A String specifying the pathname where results should be saved. If unspecified results aren't saved but
  can be optained using the *results* function.

- output : a boolean variable that specifies if results should be printed on the console, by default this is true. 
  Alternatively also an IOStream can be provided to which results should be written. 

- repfunc : This argument can be used to specify an alternative function to generate outputs and store results. 
  See [custimization](customization.md) for details. 
  
# Examples 
```jldoctest
julia> using Fastnet

julia> const Bored=1; const Excited=2;

julia> net=FastNet(1000,5000,2,[LinkType(Excited,Bored,1)]);

julia> randomgraph!(net);

julia> function rates!(rates,t)
         rates[1]=countlinks(net,1)*0.1
         rates[2]=countnodes(net,Excited)*0.2
         rates[3]=countnodes(net,Bored)*0.001
         end;

julia> function excitement_spreads()
         link=randomlink(net,1)
         nodestate!(net,linkdst(net,link),Excited)
         end;

julia> function get_bored()
         node=randomnode(net,Excited)
         nodestate!(net,node,Bored)
         end;

julia> function great_idea()
         node=randomnode(net,Bored)
         nodestate!(net,node,Excited)
         end;

julia> sim=FastSim(net,rates!,[excitement_spreads,get_bored,great_idea])
Simulation run, currently at time 0.0
```
"""    
mutable struct FastSim
    net::FastNet
    Nproc::Int
    ratefunc::Function
    procfunc::Vector
    repfunc::Function
    Trep::Float64
    Trepcur::Float64
    t::Float64  
    Tend::Float64
    nodedigits::Int
    linkdigits::Int
    timedigits::Int
    timedec::Int
    Nout::Int
    results::DataFrame
    filename::String
    printresults::Union{Bool,IOStream}
end

function FastSim(net::FastNet,ratefunc,procfunc;repfunc=showresults,saveas="",output=true)
    if isa(procfunc,Function)                # Check process function array
        procfunc=[procfunc]
    end
    if isa(procfunc,Tuple) 
        procfunc=[procfunc...]
    end
    if !isa(procfunc,Array)
        msg="FastSim constructor expects the third argument to be an Array{Function}"
        throw(ArgumentError(msg))
    end
    procfunc=vec(reshape(procfunc,1,:))
    Nproc=length(procfunc)                  # Determin number of processes
    rates=MVector{Nproc}(zeros(Nproc))      # Check rates! function
    if !isa(ratefunc,Function)
        msg="FastSim constructor expects the second argument to be the rates! function,"
        msg*=" but the argument that was passed isn't a function."
        throw(ArgumentError(msg))
    end
    try 
        ratefunc(rates,0.0)
    catch e
        msg="FastSim constructor tried calling the rates! function provided as second argument,"
        msg*=" but encountered an error."
        throw(ArgumentError(msg))
    end
    for i=1:Nproc                                       # Check process functions
        if !applicable(procfunc[i]) 
            msg="FastSim constructor expects the third argument to be an array of functions that require no "
            msg*="arguments, but I was not able to call these function $i in this Array."
            throw(ArgumentError(msg))
        end
    end
    if !isa(saveas,String) 
        msg="FastSim constructor expects saveas to be a String"
        throw(ArgumentError(msg))
    end
    if !(isa(output,Bool) || isa(output,IOStream))
        msg="FastSim constructor expects output to be either of type Bool or of type IOStream"
        throw(ArgumentError(msg))
    end
    if isa(output,IOStream) && !iswritable(output)
        msg="The IOStream provided as output in FastSim is not writable."
        throw(ArgumentError(msg))
    end

    Tend=0.0
    nodedigits=Int(ceil(log10(net.N)))
    c=net.C-1
    for i=1:c
        len=length(net.nodealias[i])
        if len>nodedigits
            nodedigits=len
        end
    end
    linkdigits=Int(ceil(log10(net.K)))
    l=net.L-2
    for i=1:l
        len=length(net.linkalias[i])
        if len>linkdigits
            linkdigits=len
        end
    end    
    timedigits=5
    timedec=2
    Nout=0
    r=DataFrame()
    r[!,"Time"]=Float64[]
    for n in net.nodealias
       r[!,n]=Int[] 
    end
    for l in net.linkalias
        r[!,l]=Int[] 
    end
    if length(saveas)!==0
        fl=0
        try 
            fl=open(saveas,"w+")
        catch e
            throw(ArgumentError("FastSim Constructor was unable to open file $saveas for writing."))
        end
        close(fl)
    end
    sim=FastSim(net,Nproc,ratefunc,procfunc,repfunc,1.0,0.0,0.0,Tend,nodedigits,linkdigits,timedigits,timedec,Nout,r,saveas,output)
    if !applicable(repfunc,sim,true)
        msg="FastSim constructor expects repfunc to be a Function(FastSim,Bool),"
        msg*=" however the function provided does not accept the right arguments."
        throw(ArgumentError(msg))
    end
    sim
end    



