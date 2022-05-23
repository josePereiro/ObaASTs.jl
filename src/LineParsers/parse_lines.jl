# ------------------------------------------------------------------
function _parse_lines(lines)

    parser = LineParser(
        #= AST =# ObaAST(nothing, Vector{AbstractObaAST}()),
        #= scope =# INIT_SCOPE,
        #= block_obj =# nothing,
        #= lines_buff =# nothing
    )

    # ----------------------------------------------------------------
    # WARNING: The order of the parsers calls is important
    for (li, line) in enumerate(lines)
        
        line = string(line)

        # ----------------------------------------------------------------
        # yaml section start
        _parse_yaml_line!(parser, line, li) && continue
        
        # ----------------------------------------------------------------
        # unvalidate INIT_SCOPE
        _invalidate_init_scope!(parser, line, li)

        # ----------------------------------------------------------------
        # HEADER LINE
        _parse_header_line!(parser, line, li) && continue

        # ----------------------------------------------------------------
        # BlockLinkLineAST
        _parse_block_link_line!(parser, line, li) && continue
        
        # ----------------------------------------------------------------
        # OBA SCRIPT BLOCK
        _parse_oba_script_line!(parser, line, li) && continue
       
        # ----------------------------------------------------------------
        # COMMENT BLOCK
        _parse_comment_block_line!(parser, line, li) && continue

        # ----------------------------------------------------------------
        # LATEX BLOCK
        _parse_latex_block_line!(parser, line, li) && continue

        # ----------------------------------------------------------------
        # CODE BLOCK
        _parse_code_block_line!(parser, line, li) && continue

        # ----------------------------------------------------------------
        # Text line
        _parse_text_line!(parser, line, li) && continue

        # ----------------------------------------------------------------
        # empty line
        _parse_empty_line!(parser, line, li) && continue

    end

    # Check closing objects
    parser.scope !== GLOBAL_SCOPE && !isnothing(parser.block_obj) && error(
        "Parsing failed, block ", parser.scope, " starting at line ", parser.block_obj.line, " unclosed!"
    )
    
    # ----------------------------------------------------------------
    # parsed part
    foreach(reparse!, parser.AST)

    return parser.AST
end

