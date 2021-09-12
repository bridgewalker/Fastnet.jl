

function checklinkid(net::FastNet,kid,task)
    if kid<1 || kid>net.K  
        throw(ArgumentError("$task, but $kid is not a valid link id"))  
    end
end

function checklinkstate(net::FastNet,cls,task)
    if cls<1 || cls>net.L-1  
        throw(ArgumentError("$task, but $cls is not a valid link state"))  
    end
end

function checklinkexists(net::FastNet,kid,task)
    if net.kstate[kid]==net.L  
        throw(ArgumentError("$task, but link $kid is not in the network (it has been deleted or hasn't been created yet)"))  
    end
end

function checknonempty(net::FastNet,task)
    if countlinks_f(net)===0  
        throw(ArgumentError("$task, but the network does not contain any links"))  
    end
end

function checknonempty(net::FastNet,cls,task)
    if countlinks_f(net,cls)===0  
        throw(ArgumentError("$task, but the network does not contain any links of state $cls"))  
    end
end

function checknodeid(net::FastNet,nid,task)
    if nid<1 || nid>net.N  
        throw(ArgumentError("$task, but $nid is not a valid node id"))  
    end
end

function checknodestate(net::FastNet,cls,task)
    s=0
    try 
        s=convert(Int,cls)
    catch e
        throw(ArgumentError("$task, but the provided node state does not seem to be an integer value")) 
    end
    if s<1 || s>net.C  
        throw(ArgumentError("$task, but $s is not a valid node state"))  
    end
    s
end

function checknodeexists(net::FastNet,nid,task)
    if net.nstate[nid]==net.C  
        throw(ArgumentError("$task, but node $nid is not in the network (it has been deleted or hasn't been created yet)"))  
    end
end

function checknonnull(net::FastNet,task)
    if countnodes_f(net)===0  
        throw(ArgumentError("$task, but the network does not contain any nodes"))  
    end
end

function checknonnull(net::FastNet,cls,task)
    if countnodes_f(net,cls)===0  
        throw(ArgumentError("$task, but the network does not contain any nodes of state $cls"))  
    end
end

"""
    shownodes(net)

Print information on all nodes in FastNet *net*.

This function is mainly intended for testing/debugging. You might want to think twice before 
calling it for a large network. Having 10 million nodes printed to your REPL is much less fun than 
it sounds. 

See also [showlinks](#Fastnet.showlinks)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[]);

julia> makenodes!(net,5,1)

julia> makenodes!(net,5,2)

julia> shownodes(net)
id      state
1       1
2       1
3       1
4       1
5       1
6       2
7       2
8       2
9       2
10      2
"""
function shownodes(net::FastNet)
    println("id\tstate")
    @inbounds begin
        for i=1:net.N
            if (net.nstate[i]<net.C)
                println(i,'\t',net.nstate[i])
            end
        end
    end
end

"""
    showlinks(net)

Print information on all links in FastNet *net*.

This function is mainly intended for testing/debugging. Use it only for networks with few links.

See also [shownodes](#Fastnet.shownodes)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(1000,2000,2,[LinkType(1,1),LinkType(1,2),LinkType(2,2)]);

julia> makenodes!(net,5,1)

julia> makenodes!(net,5,2)

julia> makelink!(net,node(net,1,1),node(net,1,2));
1

julia> makelink!(net,node(net,1,1),node(net,2,1))
2

julia> makelink!(net,node(net,2,1),node(net,2,2))
3

julia> makelink!(net,node(net,2,2),node(net,1,2))
4

julia> showlinks(net)
id      src     dest    state
1       1       2       1
2       1       6       2
3       6       7       3
4       7       2       2 

"""
function showlinks(net::FastNet)
    println("id\tsrc\tdest\tstate")
    @inbounds begin
        for i=1:net.K
            if (net.kstate[i]<net.L)
                println(i,'\t',net.ksrc[i],'\t',net.kdst[i],'\t',net.kstate[i])
            end
        end
    end
end

function check_repositoryconsistency(net::FastNet)
    print("  Checking repository consistency ... ")
    error=false
    for nid=1:net.N                # check nodes
        pos=net.npos[nid]
        id=net.nid[pos]
        if id!=nid 
            error=true
            print("\n     + Node $nid is listed at position $pos but this position refers to node $id")
        end
    end
    for kid=1:net.K                # check links
        pos=net.kpos[kid]
        id=net.kid[pos]
        if id!=kid 
            error=true
            print("\n     + Link $kid is listed at position $pos but this position refers to link $id")
        end
    end

    if error 
        println("\n    THERE WERE ERRORS\n")
        false
    else
        println("OK")
        true
    end
end

function check_nodeaccounting(net::FastNet)
    print("  Checking node accounting ... ")
    error=false
    numnodes=0
    for c=1:net.C
        if net.ncstart[c]!=numnodes                        # Check that the state starts at the right place
            error=true
            print("\n     + Node state $c starts at position $(net.ncstart[c]) but I found $numnodes nodes prior to this state")
        end
        numnodes+=net.nclen[c]                             # Adding up nodes in states to see  
    end
    if numnodes!=net.N 
        error=true
        print("\n     + Only $numnodes out of $(net.N) are accounted for in node states")
    end
    if error 
        println("\n    THERE WERE ERRORS\n")
        false
    else
        println("OK")
        true
    end
end

function check_linkaccounting(net::FastNet)
    print("  Checking link accounting ... ")
    error=false
    numlinks=0
    for c=1:net.L
        if net.kcstart[c]!=numlinks                        # Check that the state starts at the right place
            error=true
            print("\n     + Link state $c starts at position $(net.kcstart[c]) but I found $numlinks links prior to this state")
        end
        numlinks+=net.kclen[c]                             # Adding up nodes in states to see  
    end
    if numlinks!=net.K 
        error=true
        print("\n     + Only $numnlinks out of $(net.K) are accounted for in link states")
    end
    if error 
        println("\n    THERE WERE ERRORS\n")
        false
    else
        println("OK")
        true
    end
end

function check_endpointconsistency(net::FastNet)
    print("  Checking endpoint consistency ... ")
    error=false
    for nid=1:net.N         #check from node perspective
        c=net.nstate[nid]               # Check outgoing
        cur=net.nout[nid]
        if cur!=0 && c==net.C           # Deleted nodes should not have links
            error=true
            print("\n     + Deleted node $nid has an outgoing link (id: $cur)")        
        end
        while (cur!=0)                     # Check source is correct
            src=net.ksrc[cur]
            if src!=nid
                error=true
                print("\n     + Node $nid has an outgoing link (id: $cur) which has node $src as source.")            
            end
            if net.kstate[cur]==net.L
                error=true
                print("\n     + Outgoing link $cur from node $nid looks like it has been deleted.")            
            end            
            cur=net.knexts[cur]
        end
        cur=net.nin[nid]                        # Check incoming
        if cur!=0 && c==net.C                       # Deleted nnodes should not have links
            error=true
            print("\n     + Deleted node $nid has an incoming link (id: $cur)")        
        end
        while (cur!=0)                             # Check link destination is correct
            dst=net.kdst[cur]
            if dst!=nid
                error=true
                print("\n     + Node $nid has an incoming link (id: $cur) which has node $dst as destination.")            
            end
            if net.kstate[cur]==net.L
                error=true
                print("\n     + Incoming link $cur to node $nid looks like it has been deleted.")            
            end                        
            cur=net.knextd[cur]
        end        
    end    

    for kid=1:net.K                             # Now checking from the link perspective
        if net.kstate[kid]<net.L                 # no need checking deleted links
            src=net.ksrc[kid]
            dst=net.kdst[kid]
            if net.nstate[src]==net.C             # Check that nodes actually exist
                error=true
                print("\n     + Link $kid starts at deleted node $src")            
            end
            if net.nstate[dst]==net.C
                error=true
                print("\n     + Link $kid ends at deleted node $dst")            
            end            
            cur=net.nout[src]                   # Check that it is listed as outgoing from source
            while cur!=0 && cur!=kid
                cur=net.knexts[cur]
            end
            if cur!=kid
                error=true
                print("\n     + Link $kid says it starts at $src but that node does not list it as an outgoing link.")            
            end
            cur=net.nin[dst]                   # Check that it is listed as incoming at dst
            while cur!=0 && cur!=kid
                cur=net.knextd[cur]
            end
            if cur!=kid
                error=true
                print("\n     + Link $kid says it ends at $dst but that node does not list it as an incoming link.")            
            end
        end
    end

    if error 
        println("\n    THERE WERE ERRORS\n")
        false
    else
        println("OK")
        true
    end
end


function check_nodestateification(net::FastNet)
    print("  Checking node stateification ... ")
    error=false
    for c=1:net.C                   # Check that state array is consistent with position in repo
        for r=1:net.nclen[c]
            nid=node(net,c,r)
            nc=net.nstate[nid]
            if nc<1 || nc>net.C 
                error=true
                print("\n     + The state of node $nid is listed as $nc which is out of range.")        
            end
            if nc!=c
                error=true
                print("\n     + Node $nid thinks it is in state $(net.nstate[nid]) but it's actually in state $c")        
            end
        end 
    end
    if error 
        println("\n    THERE WERE ERRORS\n")
        false
    else
        println("OK")
        true
    end
end

function check_linkstateification(net::FastNet)
    print("  Checking link stateification ... ")
    error=false
    for c=1:net.L
        for r=1:net.kclen[c]
            kid=link_f(net,c,r)           # Check that state array is consistent with position in repo
            kc=net.kstate[kid]
            if kc!=c        
                error=true
                print("\n     + Link $kid thinks it is in state $kc but it's actually in state $c")        
            end
            if kc<1 || kc>net.L 
                error=true
                print("\n     + The state of link $kid is listed as $kc which is out of range.")        
            end
            if (c<net.L)                  # if the link is not deleted also check if state is consistent with linked node states 
                src=net.ksrc[kid]
                dst=net.kdst[kid]
                sc=net.nstate[src]
                dc=net.nstate[dst]
                if sc<1 || dc<1 || sc>net.C || dc>net.C 
                    error=true
                    print("\n     + I can't check the stateification of link $kid as one of it's endpoints has a state that is out of range.")            
                else    
                    cc=net.ttable[sc,dc]
                    if cc!=c
                        error=true
                        print("\n     + Link $kid is in state $c but it connects node $src (state $sc) to $dst (state $dc) which means it schould be in state $cc")        
                    end
                end
            end
        end 
    end
    if error 
        println("\n    THERE WERE ERRORS\n")
        false
    else
        println("OK")
        true
    end
end

"""
    healthcheck(net)

Perform an internal consistencey check on a FastNet *net*.

To achieve the desired performance Fastnet engages in a certain amount of double bookeeping.
In an ideal world the FastNet structures should always stay internally consistent. However,
inconsistencies could arise from a number of sources including software bugs, CPU and memeory 
errors. This function checks the internal data stored in FastNet for consistency to make sure 
that everything is alright. 

The return value is true if all chacks have been passed, false otherwise. 

See also [link](#Fastnet.link)

# Examples 
```jldoctest
julia> using Fastnet

julia> net=FastNet(100,200,10,[])
Network of 0 nodes and 0 links

julia> healthcheck(net);
  Checking repository consistency ... OK
  Checking node accounting ... OK
  Checking link accounting ... OK
  Checking endpoint consistency ... OK
  Checking node stateification ... OK
  Checking link stateification ... OK
```
"""
function healthcheck(net::FastNet)
    ok=true
    ok=ok && check_repositoryconsistency(net) 
    ok=ok && check_nodeaccounting(net)
    ok=ok && check_linkaccounting(net)
    ok=ok && check_endpointconsistency(net)
    ok=ok && check_nodestateification(net)
    ok=ok && check_linkstateification(net)
end
