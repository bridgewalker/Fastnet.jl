module QuickNet

using LightGraphs: AbstractGraph

include("structure.jl")

function QNet(N::Int,K::Int)
      firststub=zeroes(Int64,N)
      stubs+Vector{Stub}(undef,2*K)
      return QNet(stubs,firststub)
end




export QNet


end
