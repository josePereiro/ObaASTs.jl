# ------------------------------------------------------------------
# AST
source(ast::AbstractObaAST) = error("method source(", typeof(ast), ") not defined")
source(ast::AbstractObaASTChild) = ast.src
source(ast::AbstractObaASTObj) = ast.src

function source(ast::ObaAST)
    srcs = map(source, ast)
    return join(srcs, "\n")
end

source(ast::ObaAST, idx::Int) = source(ast[idx])

function source(ast::ObaAST, idxs)
    srcs = String[]
    for i in idxs
        push!(srcs, source(ast[i]))
    end
    return join(srcs, "\n")
end

function source(ast::AbstractObaAST, asts::AbstractObaAST...)
    srcs = String[source(ast)]
    for asti in asts
        push!(srcs, source(asti))
    end
    return join(srcs, "\n")
end

# To avoid overflow
_source(ast::AbstractObaAST) = source(ast)

function source(astv)
    srcs = String[]
    for asti in astv
        push!(srcs, _source(asti))
    end
    return join(srcs, "\n")
end

parent_ast(ast::AbstractObaAST) = ast.parent
parent_ast(ast::ObaAST) = ast

parsed_dict(ast::AbstractObaASTChild) = ast.parsed
parsed_dict(ast::AbstractObaASTObj) = ast.parsed

# ------------------------------------------------------------------
istextline(::AbstractObaAST) = false
istextline(::TextLineAST) = true

isemptyline(::AbstractObaAST) = false
isemptyline(::EmptyLineAST) = true

isheaderline(::AbstractObaAST) = false
isheaderline(::HeaderLineAST) = true

isblocklinkline(::AbstractObaAST) = false
isblocklinkline(::BlockLinkLineAST) = true

iscommentblock(::AbstractObaAST) = false
iscommentblock(::CommentBlockAST) = true
iscommentblock(::ObaScriptBlockAST) = true

isscriptblock(::AbstractObaAST) = false
isscriptblock(::ObaScriptBlockAST) = true

islatexblock(::AbstractObaAST) = false
islatexblock(::LatexBlockAST) = true

iscodeblock(::AbstractObaAST) = false
iscodeblock(::CodeBlockAST) = true

isyamlblock(::AbstractObaAST) = false
isyamlblock(::YamlBlockAST) = true

