# ------------------------------------------------------------------
# YamlBlockAST
function reparse!(ast::YamlBlockAST)
    src = join_src(ast, "\n")
    merge!(ast.dat, YAML.load(src))
    return ast
end

# ------------------------------------------------------------------
# HeaderLineAST
function reparse!(ast::HeaderLineAST)
    src = join_src(ast, "\n")
    dat = _match_dict(HEADER_LINE_PARSER_REGEX, src)
    ast.title = dat["title"]
    ast.lvl = length(dat["lvl"])
    return ast
end

# ------------------------------------------------------------------
# CommentBlockAST
function reparse!(ast::CommentBlockAST)
    src = join_src(ast, "\n")
    dat = _match_dict(COMMENT_BLOCK_PARSER_REGEX, src)
    ast.txt = dat["txt"]
    return ast
end

# ------------------------------------------------------------------
# CodeBlockAST
function reparse!(ast::CodeBlockAST)
    src = join_src(ast, "\n")
    dat = _match_dict(CODE_BLOCK_PARSER_REGEX, src)
    ast.lang = dat["lang"]
    ast.code = dat["code"]
    return ast
end

# ------------------------------------------------------------------
# TextLineAST
function reparse!(ast::TextLineAST)
    src = join_src(ast, "\n")
    dig = src

    # links
    _eachmatch_plus_range(INTERNAL_LINK_PARSE_REGEX, src) do range, rmatch
        link_src_ = rmatch[:src]
        link_ = InternalLinkAST(
            #= parent =# ast,
            #= pos =# range,
            #= src =# link_src_,
            #= file =# rmatch[:file],
            #= header =# haskey(rmatch, :header) ? rmatch[:header] : nothing,
            #= alias =# haskey(rmatch, :alias) ? rmatch[:alias] : nothing
        )
        push!(ast.inlinks, link_)
        
        # digest starting for the links (To avoid tags-like headers)
        dig = replace(src, link_src_ => "")
    end

    # tags
    _eachmatch_plus_range(TAG_PARSE_REGEX, dig) do range, rmatch
        tag_ = TagAST(
            #= parent =# ast,
            #= pos =# range,
            #= src =# rmatch[:src],
            #= labels =# string.(split(rmatch[:label], "/"))
        )
        push!(ast.tags, tag_)
    end
    
    return ast
end

# ------------------------------------------------------------------
# LatexBlockAST
function parse_latex_block(src::AbstractString)
    dat_ = Dict{String, Any}()
    dat_["src"] = src
    dat_["tag"] = _match_dict(LATEX_TAG_PARSE_REGEX, src)
    return dat_
end

function reparse!(ast::LatexBlockAST)
    ast
end

# ------------------------------------------------------------------
# EmptyLineAST
reparse!(ast::EmptyLineAST) = ast

# ------------------------------------------------------------------
# EmptyLineAST
function reparse!(ast::ObaAST)
    for child in ast
        reparse!(child)
    end
    return ast
end