module QuickNet

using LightGraphs: AbstractGraph
using Repos

include("structure.jl")

function QNet(N::Int,K::Int,S::Int64)
      return QNet(
            S,
            0,                      #link states not initialized
            Repo{QNode}(N,S+1),
            Repo{QLink}(K,2)        # Two link states for topology setup
      )
end

function Base.show(io::IO, net::QNet)
      n=length(net.noderep)-length(class(net.noderep,1))
      k=length(net.linkrep)-length(class(net.linkrep,1))
      println(io,"Network ($n nodes, $k links, $(net.S) states)")
end

export QNet

end
