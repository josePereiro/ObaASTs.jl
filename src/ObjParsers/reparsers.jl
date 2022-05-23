## ------------------------------------------------------------------
# Extract Regex
# To extract from a src text (possible several lines)
const TAG_PARSE_REGEX                 = r"(?<src>\#(?<label>[A-Za-z_][A-Za-z0-9_/]*))"
const INTERNAL_LINK_PARSE_REGEX       = r"(?<src>\[\[(?<file>[^\|\#\n]*?)(?:\#(?<header>[^\|\n]*?))?(?:\|(?<alias>[^\n]*?))?\]\])"
const HEADER_LINE_PARSER_REGEX        = r"(?<src>(?<lvl>\#+)\h+(?<title>.*))"
const CODE_BLOCK_PARSER_REGEX         = r"(?<src>`{3}\h*(?<lang>\N*)\n(?<body>(?:\n?\N*)*)\n`{3}\h*)"
const COMMENT_BLOCK_PARSER_REGEX      = r"(?<src>\h*\%{2}(?<body>(?:.*\n?)*)\%{2}\h*)"
const LATEX_BLOCK_PARSER_REGEX        = r"(?<src>\h*\${2}(?<body>(?:.*\n?)*)\${2}\h*)"
const LATEX_TAG_PARSE_REGEX           = r"(?<src>\\tag\{(?<label>\N+)\})"
const BLOCK_LINK_PARSER_REGEX         = r"(?<src>\^(?<link>[\-a-zA-Z0-9]+)\h*)\Z"
const OBA_SCRIPT_BLOCK_PARSER_REGEX   = r"(?<src>\h*\%{2}\h*(?<head>\#\!Oba\N*)\n(?<body>(?:```\N*\n)?(?<script>(?:.*\n?)*?)(?:```\h*\n)?)\%{2}\h*)"

# ------------------------------------------------------------------
# YamlBlockAST
function reparse!(ast::YamlBlockAST)
    src = ast.src
    merge!(ast.dict, YAML.load(src))
    return ast
end

# ------------------------------------------------------------------
# HeaderLineAST
function reparse!(ast::HeaderLineAST)
    src = ast.src
    rmatch = match(HEADER_LINE_PARSER_REGEX, src)
    ast.title = _get_match(rmatch, :title)
    ast.lvl = length(_get_match(rmatch, :lvl))
    return ast
end

# ------------------------------------------------------------------
# BlockLinkLineAST
function reparse!(ast::BlockLinkLineAST)
    src = ast.src
    rmatch = match(BLOCK_LINK_PARSER_REGEX, src)
    ast.link = _get_match(rmatch, :link)
    return ast
end

# ------------------------------------------------------------------
# CommentBlockAST
function reparse!(ast::CommentBlockAST)
    src = ast.src
    rmatch = match(COMMENT_BLOCK_PARSER_REGEX, src)
    ast.body = _get_match(rmatch, :body)
    return ast
end

# ------------------------------------------------------------------
# ObaScriptBlockAST
function reparse!(ast::ObaScriptBlockAST)
    src = ast.src
    rmatch = match(OBA_SCRIPT_BLOCK_PARSER_REGEX, src)
    ast.body = _get_match(rmatch, :body)
    ast.head = _get_match(rmatch, :head)
    ast.script = _get_match(rmatch, :script)
    return ast
end

# ------------------------------------------------------------------
# CodeBlockAST
function reparse!(ast::CodeBlockAST)
    src = ast.src
    rmatch = match(CODE_BLOCK_PARSER_REGEX, src)
    ast.lang = _get_match(rmatch, :lang, "")
    ast.body = _get_match(rmatch, :body)
    return ast
end

# ------------------------------------------------------------------
# TextLineAST
function reparse!(ast::TextLineAST)
    src = ast.src
    dig = src # digest

    # links
    empty!(ast.inlinks)
    for rmatch in eachmatch(INTERNAL_LINK_PARSE_REGEX, src)
        link_src_ = _get_match(rmatch, :src)
        link_ = InternalLinkAST(
            #= parent =# ast,
            #= src =# link_src_,
            #= pos =# _match_pos(rmatch),
            #= file =# _get_match(rmatch, :file, nothing),
            #= header =# _get_match(rmatch, :header, nothing),
            #= alias =# _get_match(rmatch, :alias, nothing)
        )
        push!(ast.inlinks, link_)
        
        # digest starting for the links (To avoid tags-like headers)
        # (On duplicated links) This works because the links are searched in `src` not in `dig`.
        dig = replace(dig, link_src_ => "~"^length(link_src_))
    end

    # tags
    empty!(ast.tags)
    for rmatch in eachmatch(TAG_PARSE_REGEX, dig)
        tag_ = TagAST(
            #= parent =# ast,
            #= src =# _get_match(rmatch, :src),
            #= pos =# _match_pos(rmatch),
            #= label =# _get_match(rmatch, :label)
        )
        push!(ast.tags, tag_)
    end

    # TODO: extract inline latexs
    
    # TODO: extract external links

    
    return ast
end


# ------------------------------------------------------------------
# LatexBlockAST
function reparse!(ast::LatexBlockAST)
    src = ast.src

    # latex
    rmatch = match(LATEX_BLOCK_PARSER_REGEX, src)
    ast.body = _get_match(rmatch, :body)

    # tag
    rmatch = match(LATEX_TAG_PARSE_REGEX, src)
    if !isnothing(rmatch)
        ast.tag = LatexTagAST(
            #= parent =# ast,
            #= src =# _get_match(rmatch, :src),
            #= pos =# _match_pos(rmatch),
            #= label =# _get_match(rmatch, :label)
        )
    end

    return ast
end

# ------------------------------------------------------------------
# EmptyLineAST
reparse!(ast::EmptyLineAST) = ast

# ------------------------------------------------------------------
# ObaAST
function reparse!(ast::ObaAST)

    # TODO: find a better lazy split
    ch = Channel{SubString}(100) do ch_
        for child in ast
            for line in split(source(child), "\n")
                put!(ch_, line)
            end
        end
    end
    _new_ast = parse_lines(ch)
    empty!(ast.children)
    append!(ast.children, _new_ast.children)
    return ast
end