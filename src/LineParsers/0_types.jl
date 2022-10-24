# ------------------------------------------------------------------
mutable struct LineParser
    AST::ObaAST
    scope::Symbol
    block_obj::Union{Nothing, AbstractObaASTChild}
    lines_buff::Union{Nothing, Vector{String}}
    line::String
    li::Int
end

LineParser() = LineParser(
    #= AST =# ObaAST(nothing, Vector{AbstractObaAST}(), 1),
    #= scope =# GLOBAL_SCOPE,
    #= block_obj =# nothing,
    #= lines_buff =# nothing,
    #= curr_line =# "",
    #= line number =# 0
)
