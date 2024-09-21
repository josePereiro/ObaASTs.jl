# TODO: make all parsing sources/blocks coherent (mainly trailing \n)
## ------------------------------------------------------------------
# Extract Regex
# To extract from a src text (possible several lines)
const TAG_PARSE_REGEX                 = r"(?<src>\#(?<label>[A-Za-z_][A-Za-z0-9_/]*))"
const INTERNAL_LINK_PARSE_REGEX       = r"(?<src>\[\[(?<file>[^\|\#\n]*?)(?:\#(?<header>[^\|\n]*?))?(?:\|(?<alias>[^\n]*?))?\]\])"
const HEADER_LINE_PARSER_REGEX        = r"(?<src>(?<lvl>\#+)(?<title>(?:\h+\N*)|(?:\h*)))"
const CODE_BLOCK_PARSER_REGEX         = r"(?<src>`{3}\h*(?<lang>\N*)\n(?<body>(?:\n?\N*)*)\n*`{3}\h*)"
const COMMENT_BLOCK_PARSER_REGEX      = r"(?<src>\h*\%{2}(?<body>(?:.*\n?)*)\%{2}\h*)"
const LATEX_BLOCK_PARSER_REGEX        = r"(?<src>\h*\${2}(?<body>(?:.*\n?)*)\${2}\h*)"
const LATEX_TAG_PARSE_REGEX           = r"(?<src>\\tag\{(?<label>\N+?)\})"
const BLOCK_LINK_PARSER_REGEX         = r"(?<src>\^(?<label>[\-a-zA-Z0-9]+)\h*)\Z"
const OBA_SCRIPT_BLOCK_PARSER_REGEX   = r"(?<src>(?:\%{2})?\h*\n?(?:`{3})?julia\h*(?<head>\#\!Oba\N*)\n(?<body>(?:```\N*\n)?(?<script>(?:.*\n?)*?)(?:```\h*\n)?)(?:`{3})\h*\n?(?:\%{2})?\h*)"

# ------------------------------------------------------------------
# YamlBlockAST
function _oba_reparse!(ast::YamlBlockAST)
    src = ast.src
    ast.parsed[:yaml] = YAML.load(src)
    
    # Tags
    for (k, tags) in ast.parsed[:yaml]
        kstr = uppercase(k)
        kstr in ["TAG", "TAGS"] || continue
        tags = tags isa Vector ? tags : [tags]

        for dig in tags, rmatch in eachmatch(TAG_PARSE_REGEX, dig)
            tag_src = _get_match(rmatch, :src)
            tag_src != dig && error("Tag parsing faild. src: ", dig)
            get!(ast.parsed, :tags) do
                TagAST[]
            end
            tag_ast = TagAST(
                #= parent =# ast,
                #= src =# tag_src,
                #= pos =# _match_pos(rmatch)
            )
            tag_ast.parsed[:label] = _get_match(rmatch, :label)
            push!(ast.parsed[:tags], tag_ast)
        end
    end
    
    return ast
end

# ------------------------------------------------------------------
# HeaderLineAST
function _oba_reparse!(ast::HeaderLineAST)
    src = ast.src
    rmatch = match(HEADER_LINE_PARSER_REGEX, src)
    ast.parsed[:title] = string(strip(_get_match(rmatch, :title)))
    ast.parsed[:lvl] = length(_get_match(rmatch, :lvl))
    return ast
end

# ------------------------------------------------------------------
# BlockLinkLineAST
function _oba_reparse!(ast::BlockLinkLineAST)
    src = ast.src
    rmatch = match(BLOCK_LINK_PARSER_REGEX, src)
    ast.parsed[:label] = _get_match(rmatch, :label)
    return ast
end

# ------------------------------------------------------------------
# CommentBlockAST
function _oba_reparse!(ast::CommentBlockAST)
    src = ast.src
    rmatch = match(COMMENT_BLOCK_PARSER_REGEX, src)
    ast.parsed[:body] = _get_match(rmatch, :body)
    return ast
end

# ------------------------------------------------------------------
function _parse_script_head(ast::ObaScriptBlockAST, head_src::AbstractString)
    
    dig = head_src
    head_ast = ObaScriptHeadAST(
        #= parent =# ast,
        #= src =# head_src,
        #= pos =# findfirst(head_src, ast.src)
    )
    # long flags
    for rmatch in eachmatch(OBA_SCRIPT_HEAD_LONG_FLAG_REGEX, head_src)
        get!(head_ast.parsed, :params) do  
            Dict{String, Union{Nothing, String}}()
        end
        flag_src = _get_match(rmatch, :src)
        fkey = _get_match(rmatch, :key)
        fvalue = _get_match(rmatch, :value)
        head_ast.parsed[:params][fkey] = fvalue

        # digest
        dig = replace(dig, flag_src => "")
    end
    # short flags
    for rmatch in eachmatch(OBA_SCRIPT_HEAD_SHORT_FLAG_REGEX, dig)
        get!(head_ast.parsed, :flags, "")
        
        flag_src = _get_match(rmatch, :src)
        flags = _get_match(rmatch, :flags)
        head_ast.parsed[:flags] = string(head_ast.parsed[:flags], flags)

        # digest
        dig = replace(dig, flag_src => "")
    end

    # check diggest
    strip(dig) == "#!Oba" || error("The script head is not well structured. ObaScriptBlockAST at line: ", ast.line, ". Digest: ", dig)

    return head_ast
end

# ------------------------------------------------------------------
# ObaScriptBlockAST
function _oba_reparse!(ast::ObaScriptBlockAST)
    src = ast.src
    rmatch = match(OBA_SCRIPT_BLOCK_PARSER_REGEX, src)
    # ast.parsed[:body] = _get_match(rmatch, :body)
    ast.parsed[:script] = _get_match(rmatch, :script)
    
    # head
    head_src = _get_match(rmatch, :head)
    ast.parsed[:head] = _parse_script_head(ast, head_src)
    
    return ast
end

# ------------------------------------------------------------------
# CodeBlockAST
function _oba_reparse!(ast::CodeBlockAST)
    src = ast.src
    rmatch = match(CODE_BLOCK_PARSER_REGEX, src)
    ast.parsed[:lang] = _get_match(rmatch, :lang, "")
    ast.parsed[:body] = _get_match(rmatch, :body)
    return ast
end

# ------------------------------------------------------------------
# TextLineAST
function _oba_reparse!(ast::TextLineAST)
    src = ast.src
    dig = src # digest

    # links
    for rmatch in eachmatch(INTERNAL_LINK_PARSE_REGEX, src)
        get!(ast.parsed, :inlinks) do
            InternalLinkAST[]
        end

        link_src_ = _get_match(rmatch, :src)
        link_ast = InternalLinkAST(
            #= parent =# ast,
            #= src =# link_src_,
            #= pos =# _match_pos(rmatch)
        )
        link_ast.parsed[:file] = _get_match(rmatch, :file, nothing)
        link_ast.parsed[:header] = _get_match(rmatch, :header, nothing)
        link_ast.parsed[:alias] = _get_match(rmatch, :alias, nothing)
        push!(ast.parsed[:inlinks], link_ast)
        
        # digest starting for the links (To avoid tags-like headers)
        # (On duplicated links) This works because the links are searched in `src` not in `dig`.
        dig = replace(dig, link_src_ => "~"^length(link_src_))
    end

    # tags
    for rmatch in eachmatch(TAG_PARSE_REGEX, dig)
        get!(ast.parsed, :tags) do
            TagAST[]
        end
        tag_ast = TagAST(
            #= parent =# ast,
            #= src =# _get_match(rmatch, :src),
            #= pos =# _match_pos(rmatch)
        )
        tag_ast.parsed[:label] = _get_match(rmatch, :label)
        push!(ast.parsed[:tags], tag_ast)
    end

    # TODO: extract inline latexs
    
    # TODO: extract external links
    
    # TODO: extract markdown links

    
    return ast
end


# ------------------------------------------------------------------
# LatexBlockAST
function _oba_reparse!(ast::LatexBlockAST)
    src = ast.src

    # latex
    rmatch = match(LATEX_BLOCK_PARSER_REGEX, src)
    ast.parsed[:body] = _get_match(rmatch, :body)

    # tag
    rmatch = match(LATEX_TAG_PARSE_REGEX, src)
    if !isnothing(rmatch)
        tag_ast = LatexTagAST(
            #= parent =# ast,
            #= src =# _get_match(rmatch, :src),
            #= pos =# _match_pos(rmatch)
        )
        tag_ast.parsed[:label] = _get_match(rmatch, :label)
        ast.parsed[:tag] = tag_ast
    end

    return ast
end

# ------------------------------------------------------------------
# EmptyLineAST
_oba_reparse!(ast::EmptyLineAST) = ast

## ------------------------------------------------------------------
# Registry obsidian reparsers
function _register_oba_childs()
    for T in [
            TextLineAST, BlockLinkLineAST, EmptyLineAST, 
            HeaderLineAST, CommentBlockAST, ObaScriptBlockAST, 
            LatexBlockAST, CodeBlockAST, YamlBlockAST
        ]
            register_reparser!(_oba_reparse!, T)
    end
end