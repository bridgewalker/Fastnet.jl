module QuickNet

using LightGraphs
using Repos

include("structure.jl")


function QNet(N::Int,K::Int,S::Int64)
      return QNet(
            0,                      #We start in state 0
            S,
            0,                      #link states not initialized
            Repo{QNode}(N,S+1),
            Repo{QLink}(K,2)        # Two link states for topology setup
      )
end

function undirected(f::Int64,t::Int64)
      return QLink(f,t,-1,-1,1)
end

function LightGraphs.add_edge!(g::QNet,e::AbstractEdge)
      return src(e)
end

function Base.show(io::IO, net::QNet)
      n=length(net.noderep)-length(class(net.noderep,1))
      k=length(net.linkrep)-length(class(net.linkrep,1))
      println(io,"Network ($n nodes, $k links, $(net.S) node states)")
end


export QNet

end
