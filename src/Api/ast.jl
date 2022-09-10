# ------------------------------------------------------------------
# AST Interface
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
    srcs = map(_source, astv)
    return join(srcs, "\n")
end

parent_ast(ast::ObaAST) = ast
parent_ast(ast::AbstractObaAST) = ast.parent

parsed_dict(ast::AbstractObaASTChild) = ast.parsed
parsed_dict(ast::AbstractObaASTObj) = ast.parsed

parent_file(ch::ObaAST) = ch.file
parent_file(ch::AbstractObaASTChild) = parent_file(parent_ast(ch))
parent_file(ch::AbstractObaASTObj) = parent_file(parent_ast(ch))
export parent_file

reparse_counter(ch::ObaAST) = ch.reparse_counter
export reparse_counter

# ------------------------------------------------------------------
# Type utils
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

isscriptblock(::AbstractObaAST) = false
isscriptblock(::ObaScriptBlockAST) = true

islatexblock(::AbstractObaAST) = false
islatexblock(::LatexBlockAST) = true

iscodeblock(::AbstractObaAST) = false
iscodeblock(::CodeBlockAST) = true

isyamlblock(::AbstractObaAST) = false
isyamlblock(::YamlBlockAST) = true

# ------------------------------------------------------------------
function get_tags(ast::ObaAST)
    tags = TagAST[]
    for ch in ast
        tags_ = get(ch, :tags, nothing)
        !isnothing(tags_) && push!(tags, tags_...)
    end
    return tags
end
export get_tags

function foreach_tag(f::Function, ast::ObaAST)
    for ch in ast
        tags = get(ch, :tags, nothing)
        isnothing(tags) && continue
        for tag in tags
            f(tag) === true && return nothing
        end
    end
    return nothing
end
export foreach_tag

function hastag(f::Function, ast::ObaAST)
    flag = false
    foreach_tag(ast) do tag
        flag = f(tag)
    end
    return flag
end
hastag(ast::ObaAST, label::String) = hastag((tag) -> tag[:label] == label, ast)
hastag(ast::ObaAST, reg::Regex) = hastag((tag) -> _hasmatch(reg, tag[:label]), ast)
export hastag