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
iscommentblock(::ObaScriptBlockAST) = true

isscriptblock(::AbstractObaAST) = false
isscriptblock(::ObaScriptBlockAST) = true

islatexblock(::AbstractObaAST) = false
islatexblock(::LatexBlockAST) = true

iscodeblock(::AbstractObaAST) = false
iscodeblock(::CodeBlockAST) = true

isyamlblock(::AbstractObaAST) = false
isyamlblock(::YamlBlockAST) = true

# ------------------------------------------------------------------
# ObaAST
write!(io::IO, ast::ObaAST) = write(io, reparse!(ast))
function write!(ast::ObaAST) 
    file = parent_file(ast)
    isnothing(file) && error("The ObaAST do not have a source file!")
    write(file, reparse!(ast))
end
export write!

# ------------------------------------------------------------------
# ObaScriptBlockAST
function set_script!(cmd::ObaScriptBlockAST, new_script::AbstractString)
    old_script = cmd.parsed[:script]
    new_script = endswith(new_script, "\n") ? new_script : string(new_script, "\n")
    cmd.src = string(replace(cmd.src, old_script => new_script))
    reparse!(cmd)
    return cmd
end
export set_script!

function set_head!(cmd::ObaScriptBlockAST, new_head::AbstractString)
    old_head = source(cmd[:head])
    new_head = strip(new_head)
    cmd.src = string(replace(cmd.src, old_head => new_head))
    reparse!(cmd)
    return cmd
end
export set_head!

export get_params
get_params(ast::ObaScriptBlockAST, dflt = nothing) = get(ast[:head], :params, dflt)
   
function _build_head_src(flags::AbstractString, params) 
    flags_src = isempty(flags) ? "" : string("-", flags)
    params_src = ""
    if !isnothing(params)
        for (key, value) in params

            params_src = isnothing(value) ? 
                string("--", key, " ", params_src) : 
                string("--", key, "=", value, " ", params_src)
        end
    end
    src = string("#!Oba ", strip(params_src), " ", strip(flags_src))
    return string(strip(src))
end

export get_param
function get_param(ast::ObaScriptBlockAST, key::String, dflt = nothing)
    params = get_params(ast)
    isnothing(params) && return dflt
    return get(params, key, dflt)
end

export set_param!
function set_param!(cmd_ast::ObaScriptBlockAST, key::AbstractString, value)
    flags = get_flags(cmd_ast)
    params = get_params(cmd_ast)
    params = isnothing(params) ? Dict{String, Union{Nothing, String}}() : params
    params[key] = value
    @show flags params
    new_head = _build_head_src(flags, params)
    return set_head!(cmd_ast, new_head)
end

export hasparam
function hasparam(cmd_ast::ObaScriptBlockAST, key::AbstractString) 
    params = get_params(cmd_ast)
    return isnothing(params) ? false : haskey(params, key)
end

export get_flags
function get_flags(ast::ObaScriptBlockAST)
    return get(ast[:head], :flags, "")
end

export hasflag
hasflag(ast::ObaScriptBlockAST, flag::String) = contains(get_flags(ast), flag)