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

source_file(ch::ObaAST) = ch.file
source_file(ch::AbstractObaASTChild) = source_file(parent_ast(ch))
source_file(ch::AbstractObaASTObj) = source_file(parent_ast(ch))

reparse_counter(ch::ObaAST) = ch.reparse_counter

# ------------------------------------------------------------------
function yaml_ast(ch::ObaAST)
    length(ch) == 0 && return nothing
    ch0 = first(ch)
    isyamlblock(ch0) || return nothing
    return ch0
end

function yaml_dict(ch::ObaAST)
    ch = yaml_ast(ch)
    isnothing(ch) && return Dict()
    return yaml_dict(ch)
end

yaml_dict(ch::YamlBlockAST) = get(ch, :yaml, Dict())

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
function collect_parsed(ast::ObaAST, key::Symbol; 
        T::DataType = Any, 
        reduce = (x) -> isa(x, Vector)
    )
    objs = T[]
    for ch in ast
        obj_ = get(ch, key, nothing)
        isnothing(obj_) && continue 
        reduce(obj_) ? push!(objs, obj_...) : push!(objs, obj_)
    end
    return objs
end

function foreach_parsed(f::Function, ast::ObaAST, key::Symbol)
    for ch in ast
        objs = get(ch, key, nothing)
        isnothing(objs) && continue
        for obj in objs
            f(obj) === true && return nothing
        end
    end
    return nothing
end

function find_parsed(f::Function, ast::ObaAST, key::Symbol)
    flag = false
    foreach_parsed(ast, key) do obj
        flag = f(obj); return flag
    end
    return flag
end

# ------------------------------------------------------------------
# TagAST
tags(ast::ObaAST) = collect_parsed(ast, :tags; T = TagAST)
foreach_tag(f::Function, ast::ObaAST) = foreach_parsed(f, ast, :tags)
hastag(f::Function, ast::ObaAST) = find_parsed(f, ast, :tags)
hastag(ast::ObaAST, label::String) = hastag((tag) -> tag[:label] == label, ast)
hastag(ast::ObaAST, reg::Regex) = hastag((tag) -> _hasmatch(reg, tag[:label]), ast)

# ------------------------------------------------------------------
# WikiLinkAST
wikilinks(ast::ObaAST) = collect_parsed(ast, :wikilinks; T = WikiLinkAST)
foreach_wikilinks(f::Function, ast::ObaAST) =  foreach_parsed(f, ast, :wikilinks)
hasinlink(f::Function, ast::ObaAST) = find_parsed(f, ast, :wikilinks)
hasinlink(ast::ObaAST, file::String) = hasinlink((wikilinks) -> wikilinks[:file] == file, ast)
hasinlink(ast::ObaAST, reg::Regex) = hasinlink((wikilinks) -> _hasmatch(reg, wikilinks[:file]), ast)

# ------------------------------------------------------------------
# ObaScriptBlockAST
function find_byid(new_ast::ObaAST, id0::AbstractString)
    for (idx, ch) in enumerate(new_ast)
        isscriptblock(ch) || continue
        id1 = get_param(ch, "id", nothing)
        isnothing(id1) && continue
        id1 == id0 && return idx
    end
    return nothing
end

function find_byid(new_ast::ObaAST, script_ast::ObaScriptBlockAST)
    id0 = get_param(script_ast, "id", nothing)
    isnothing(id0) && return nothing
    return find_byid(new_ast, id0)
end

find_byid(::ObaAST, ::AbstractObaASTChild) = nothing