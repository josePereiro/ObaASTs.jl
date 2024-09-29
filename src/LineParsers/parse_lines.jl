function _feed_parser!(parser::LineParser, lines)

    # ----------------------------------------------------------------
    # WARNING: The order of the parsers calls is important
    for line in lines

        # ----------------------------------------------------------------
        # new line
        parser.li += 1
        parser.line = string(line)

        # ----------------------------------------------------------------
        # yaml section start
        _parse_yaml_line!(parser) && continue
        
        # ----------------------------------------------------------------
        # HEADER LINE
        _parse_header_line!(parser) && continue

        # ----------------------------------------------------------------
        # BlockLinkLineAST
        _parse_block_link_line!(parser) && continue
       
        # ----------------------------------------------------------------
        # COMMENT BLOCK
        _parse_comment_block_line!(parser) && continue

        # ----------------------------------------------------------------
        # LATEX BLOCK
        _parse_latex_block_line!(parser) && continue

        # ----------------------------------------------------------------
        # CODE BLOCK
        _parse_code_block_line!(parser) && continue

        # ----------------------------------------------------------------
        # Text line
        _parse_text_line!(parser) && continue

        # ----------------------------------------------------------------
        # empty line
        _parse_empty_line!(parser) && continue

    end

    # Check closing objects
    parser.scope !== GLOBAL_SCOPE && !isnothing(parser.block_obj) && error(
        "Parsing failed, block ", parser.scope, " starting at line ", parser.block_obj.line, " unclosed!"
    )

    # ----------------------------------------------------------------
    # promoters
    run_promoters!(parser)

    return nothing
end

# ------------------------------------------------------------------
function _parse_lines(lines)

    parser = LineParser()

    _feed_parser!(parser, lines)
    
    # parsed childs
    foreach(reparse!, parser.AST)

    return parser.AST
end

function _parse_batch(batch)

    parser = LineParser()

    for lines in batch
        _feed_parser!(parser, lines)
    end
    
    # parsed childs
    foreach(reparse!, parser.AST)

    return parser.AST
end

