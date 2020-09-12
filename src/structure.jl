

struct QStub
      target::Int64
      next::Int64
end

struct QNet <: AbstractGraph{Int64}
      stubs ::Vector{QStub}
      firststub ::Vector{Int64}
end
