### INTERNAL FUNCTIONS ###

function padleft(str::String,n)
    out=str
    while length(out)<n
        out=" "*out
    end
    out
end

function padright(str::String,n)
    out=str
    while length(out)<n
        out*=" "
    end
    out
end

function showfloat(x::Float64,dec,n)
    y=x*10^dec
    y=Int(round(y))
    s=string(y)
    if dec<=0 
        return padleft(s,n)
    end
    while length(s)<dec+1
        s="0"*s
    end
    r=s[1:end-dec]*"."*s[end-dec+1:end]
    padleft(r,n)
end

function initsim(sim::FastSim,Tdur::Float64,Tout::Float64)
    Tend=sim.t+Tdur
    sim.Tend=Tend
    leaddigits=Int(ceil(log10(Tend)))+1
    decimals=Int(ceil(-log10(Tout)))
    if decimals<1
        decimals=1
    end
    if leaddigits<1
        leaddigits=1
    end
    sim.timedec=decimals
    sim.timedigits=max(leaddigits+decimals+1,4)
    nothing
end

function printlinktype(io::IO,lt::LinkType)
    from=lt.from
    to=lt.to
    if isa(from,Array)
        fromtext=reduce((x,y)->"$x/$y",from)
    else 
        if from===0
            fromtext="any"
        else
            fromtext=string(from)
        end
    end
    if isa(to,Array)
        totext=reduce((x,y)->"$x/$y",to)
    else 
        if to===0
            totext="any"
        else
            totext=string(to)
        end
    end
    if (lt.dir==2)
        print(io,"Links of the form:  ($fromtext) --- ($totext)" )
    else
        print(io,"Links of the form:  ($fromtext) --> ($totext)" )
    end
end    

function linkstate_f!(net::FastNet,kid::Int,cls::Int)
    @inbounds begin
        while net.kstate[kid]<cls
            upstate_link!(net,kid)
        end
        while net.kstate[kid]>cls
            destate_link!(net,kid)
        end
    end        
    nothing
end

function destate_node!(net::FastNet,nid) #This function won't check links
    @inbounds begin
        pos=net.npos[nid]
        cls=net.nstate[nid]
        firstpos=net.ncstart[cls]+1
        firstid=net.nid[firstpos]
        net.nid[firstpos]=nid
        net.nid[pos]=firstid
        net.npos[nid]=firstpos
        net.npos[firstid]=pos
        net.ncstart[cls]+=1
        net.nclen[cls]-=1
        net.nclen[cls-1]+=1
        net.nstate[nid]=cls-1
    end
    nothing
end

function upstate_node!(net::FastNet,nid) #This function won't check links
    @inbounds begin
        pos=net.npos[nid]
        cls=net.nstate[nid]
        lastpos=net.ncstart[cls]+net.nclen[cls]
        lastid=net.nid[lastpos]
        net.nid[lastpos]=nid
        net.nid[pos]=lastid
        net.npos[nid]=lastpos
        net.npos[lastid]=pos
        net.ncstart[cls+1]-=1
        net.nclen[cls]-=1
        net.nclen[cls+1]+=1
        net.nstate[nid]=cls+1
    end
    nothing
end

function destate_link!(net::FastNet,kid) 
    @inbounds begin
        pos=net.kpos[kid]
        cls=net.kstate[kid]
        firstpos=net.kcstart[cls]+1
        firstid=net.kid[firstpos]
        net.kid[firstpos]=kid
        net.kid[pos]=firstid
        net.kpos[kid]=firstpos
        net.kpos[firstid]=pos
        net.kcstart[cls]+=1
        net.kclen[cls]-=1
        net.kclen[cls-1]+=1
        net.kstate[kid]=cls-1
    end
    nothing
end

function upstate_link!(net::FastNet,kid)
    @inbounds begin
        pos=net.kpos[kid]
        cls=net.kstate[kid]
        lastpos=net.kcstart[cls]+net.kclen[cls]
        lastid=net.kid[lastpos]
        net.kid[lastpos]=kid
        net.kid[pos]=lastid
        net.kpos[kid]=lastpos
        net.kpos[lastid]=pos
        net.kcstart[cls+1]-=1
        net.kclen[cls]-=1
        net.kclen[cls+1]+=1
        net.kstate[kid]=cls+1
    end
    nothing
end

function fastprint(sim::FastSim,x...)
    if isa(sim.printresults,Bool)
        if sim.printresults
            print(x...)
        end
    else
        print(sim.printresults,x...)
    end
end