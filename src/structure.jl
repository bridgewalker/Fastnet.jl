
struct QNode
      firstlink::Int64
end

struct QLink
      f::Int64
      t::Int64
      nf::Int64
      nt::Int64
end

struct QNet <: AbstractGraph{Int64}
      S ::Int64            #NodeStates
      s ::Int64            #Link States 0 if not initialized
      noderep::Repo{QNode}
      linkrep::Repo{QLink}
end
