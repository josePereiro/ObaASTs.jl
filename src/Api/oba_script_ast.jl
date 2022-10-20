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

export add_flags!
function add_flags!(cmd_ast::ObaScriptBlockAST, flags::String)
    old_flags = get_flags(cmd_ast)
    params = get_params(cmd_ast)
    params = isnothing(params) ? Dict{String, Union{Nothing, String}}() : params
    flags = join(unique(string(old_flags, flags)))
    new_head = _build_head_src(flags, params)
    return set_head!(cmd_ast, new_head)
end

export hasflag
hasflag(ast::ObaScriptBlockAST, flag::String) = contains(get_flags(ast), flag)