function Base.show(io::IO,::MIME"text/plain",net::FastNet)
    n=countnodes(net)
    k=countlinks(net) 
    print(io,"Network of $n nodes and $k links" )
end

function Base.show(io::IO,::MIME"text/html",net::FastNet)
    n=countnodes(net)
    k=countlinks(net) 
    print(io,"Network of $n nodes and $k links" )
end

function Base.show(io::IO,::MIME"text/plain",sim::FastSim)
    print(io,"Simulation run, currently at time $(sim.t)" )
end

function Base.show(io::IO,::MIME"text/html",sim::FastSim)
    print(io,"Simulation run, currently at time $(sim.t)" )
end

function Base.show(io::IO,::MIME"text/plain",lt::LinkType)
    printlinktype(io,lt)
end

function Base.show(io::IO,::MIME"text/html",lt::LinkType)
    printlinktype(io,lt)
end
