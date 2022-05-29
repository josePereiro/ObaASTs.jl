# ------------------------------------------------------------------
mutable struct LineParser
    AST::ObaAST
    scope::Symbol
    block_obj::Union{Nothing, AbstractObaASTChild}
    lines_buff::Union{Nothing, Vector{String}}
end

LineParser() = LineParser(
    #= AST =# ObaAST(nothing, Vector{AbstractObaAST}(), 1),
    #= scope =# INIT_SCOPE,
    #= block_obj =# nothing,
    #= lines_buff =# nothing
)
