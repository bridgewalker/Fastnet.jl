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

function _configmodelsetup!(net,degreedist,N,S)
    nullgraph!(net)
    n=0
    try
        n=convert(Int,N)
    catch e
        throw(ArgumentError("Configuration model expects the number of nodes N to be an integer."))
    end
    if n==0
        n=net.N
    end
    if n<1
        throw(ArgumentError("The number of nodes N specified for configuration model is too low"))
    end
    if n<0
        throw(ArgumentError("Configuration model expects the number of nodes, N, to be positive"))
    end
    if n>net.N
        throw(ArgumentError("The requested configuration model network exceeds the max nodecount for the underlying FastNet"))
    end
    checknodestate(net::FastNet,S,"Trying to create configuration model network")  
    counts=_countsfromdd(degreedist,n)
    isolated=N-sum(counts)
    totallinks=0
    mx=length(counts)
    for i=1:mx
        totallinks+=i*counts[i]
    end
    if totallinks÷2>net.K
        throw(ArgumentError("The requested configuration model exceeds the max linkcount allowed by the underlying FastNet"))
    end
    makenodes_f!(net,n,S)
    (counts,totallinks)
end

function _randindexdd(rng,list::Union{Array,Tuple})
    L=length(list)
    r=rand(rng)-list[1]
    ret=1
    while r>0.0 && ret<L
        ret+=1
        r-=list[ret]
    end
    if r>0.0 
        0
    else
        ret
    end
end

function _randindex(rng,list::Union{Array,Tuple})
    L=length(list)
    t=sum(list)
    r=rand(rng)*t-list[1]
    ret=1
    while r>0.0 && ret<L
        ret+=1
        r-=list[ret]
    end
    ret
end




function _countsfromdd(degreedist,n)
    if !(isa(degreedist,AbstractVector) || isa(degreedist,Tuple))
         throw(ArgumentError("The passed degree distribution needs to be a Vector of Floats"))
    end
    mx=length(degreedist)
    if mx<1
        throw(ArgumentError("The passed degree distribution needs to contain at least one element"))
    end
    dd=Array{Float64,1}(undef,mx)
    for i=1:mx
        try
            dd[i]=convert(Float64,degreedist[i])
        catch e
            throw(ArgumentError("Cannot interpret elment number $i of the degree distribution as a Float variable"))
        end        
        if dd[i]<0.0
            throw(ArgumentError("The degree distribution should contain non-negative elements, but element $i seems to be negative"))
        end
        if dd[i]>1.0
            throw(ArgumentError("The degree distribution should be probabilities, but element $i seems to be greater than 1"))
        end
    end
    if sum(dd)>1.0
        throw(ArgumentError("The specified degree distribution sums to more than 1.0"))        
    end
    zerop=1.0-sum(dd)
    counts=[Int(floor(dd[i]*n)) for i=1:mx]
    diffs=[dd[i]*n-Float64(counts[i]) for i=1:mx]
    nodessofar=sum(counts)
    nonisolated=Int(round(sum(dd)*n))
    while nodessofar<nonisolated
        (val,idx)=findmax(diffs)
        diffs[idx]=0.0
        nodessofar+=1
        counts[idx]+=1
    end  
    stubs=0
    for i=1:mx
        stubs+=i*counts[i]
    end
    if isodd(stubs)               # All this stuff is just for fixing odd numbers of stubs
        peak=(1,2)
        peakdel=-1.0
        diff=1.0
        for i=2:mx
            if (counts[i]==0)
                continue
            end
            for j=1:i-1 
                if (counts[j]==0)
                    continue
                end
                del=(counts[i]-dd[i]*n)-(counts[j]-dd[j]*n)  
                if abs(del)>peakdel
                    if del<0 
                        peakdel=-del
                        diff=-1
                    else
                        peakdel=del
                        diff=1
                    end
                    peakdel=del
                    peak=(i,j)
                end
            end
        end
        counts[peak[1]]-=diff
        counts[peak[2]]+=diff
    end
    stubs=0
    for i=1:mx
        stubs+=i*counts[i]
    end
    if isodd(stubs)
        idx=1
        while idx<mx && count[idx]==0                
            idx+=2
        end
        count[idx]-=1
    end
    counts
end

function hhtest(counts)
    c=copy(counts)
    last=length(c)
    adds=zeros(last)
    while last>1
        while c[last]>0
            c[last]-=1
            dist=last
            cur=last
            while dist>0
                if cur<1 
                    return false
                end 
                sub=dist
                if sub>c[cur]
                    sub=c[cur]
                end
                dist-=sub
                c[cur]-=sub
                if (cur>1) 
                    adds[cur-1]=sub
                end
                cur-=1
            end
            for i=1:last
                c[i]+=adds[i]
                adds[i]=0
            end
        end
        last-=1;
    end
    if iseven(c[1])
        true
    else
        false
    end    
end






