# ------------------------------------------------------------------
# YamlBlockAST
function reparse!(ast::YamlBlockAST)
    src = src_str(ast)
    merge!(ast.dat, YAML.load(src))
    return ast
end

# ------------------------------------------------------------------
# HeaderLineAST
function reparse!(ast::HeaderLineAST)
    src = src_str(ast)
    rmatch = match(HEADER_LINE_PARSER_REGEX, src)
    ast.title = rmatch[:title]
    ast.lvl = length(rmatch[:lvl])
    return ast
end

# ------------------------------------------------------------------
# BlockLinkLineAST
function reparse!(ast::BlockLinkLineAST)
    src = src_str(ast)
    rmatch = match(BLOCK_LINK_PARSER_REGEX, src)
    ast.link = rmatch[:link]
    return ast
end

# ------------------------------------------------------------------
# CommentBlockAST
function reparse!(ast::CommentBlockAST)
    src = src_str(ast)
    rmatch = match(COMMENT_BLOCK_PARSER_REGEX, src)
    ast.txt = rmatch[:txt]
    return ast
end

# ------------------------------------------------------------------
# CodeBlockAST
function reparse!(ast::CodeBlockAST)
    src = src_str(ast)
    rmatch = match(CODE_BLOCK_PARSER_REGEX, src)
    ast.lang = rmatch[:lang]
    ast.code = rmatch[:code]
    return ast
end

# ------------------------------------------------------------------
# TextLineAST
function reparse!(ast::TextLineAST)
    src = src_str(ast)
    dig = src

    # links
    empty!(ast.inlinks)
    for rmatch in eachmatch(INTERNAL_LINK_PARSE_REGEX, src)
        link_src_ = rmatch[:src]
        link_ = InternalLinkAST(
            #= parent =# ast,
            #= pos =# _match_pos(rmatch),
            #= src =# link_src_,
            #= file =# rmatch[:file],
            #= header =# haskey(rmatch, :header) ? rmatch[:header] : nothing,
            #= alias =# haskey(rmatch, :alias) ? rmatch[:alias] : nothing
        )
        push!(ast.inlinks, link_)
        
        # digest starting for the links (To avoid tags-like headers)
        dig = replace(dig, link_src_ => "~"^length(link_src_))
    end

    # tags
    empty!(ast.tags)
    for rmatch in eachmatch(TAG_PARSE_REGEX, dig)
        tag_ = TagAST(
            #= parent =# ast,
            #= pos =# _match_pos(rmatch),
            #= src =# rmatch[:src],
            #= labels =# string.(split(rmatch[:label], "/"))
        )
        push!(ast.tags, tag_)
    end
    
    return ast
end


# ------------------------------------------------------------------
# LatexBlockAST
function reparse!(ast::LatexBlockAST)
    src = src_str(ast)

    # latex
    rmatch = match(LATEX_BLOCK_PARSER_REGEX, src)
    ast.latex = rmatch[:latex]

    # tag
    rmatch = match(LATEX_TAG_PARSE_REGEX, src)
    if !isnothing(rmatch)
        ast.tag = LatexTagAST(
            #= parent =# ast,
            #= pos =# _match_pos(rmatch),
            #= src =# rmatch[:src],
            #= label =# rmatch[:label]
        )
    end

    return ast
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