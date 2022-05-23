# ------------------------------------------------------------------
mutable struct LineParser
    AST::ObaAST
    scope::Symbol
    block_obj::Union{Nothing, AbstractObaASTChild}
    lines_buff::Union{Nothing, Vector{String}}
end
