function _parse_latex_block_line!(parser::LineParser, line, li)
    
    # short circuit
    parser.scope === GLOBAL_SCOPE || parser.scope === LATEX_BLOCK || return false

    # inline
    rmatch = match(LATEX_BLOCK_INLINE_REGEX, line)
    if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)
        obj = LatexBlockAST(
            #= parent =# parser.AST,
            #= src =# line,
            #= line =# li
        )
        push!(parser.AST, obj)
        
        return true
    end

    # multiline
    rmatch = match(LATEX_BLOCK_START_LINE_REGEX, line)
    if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)
        parser.block_obj = LatexBlockAST(
            #= parent =# parser.AST,
            #= src =# "",
            #= line =# li
        )

        # enter block
        push!(parser.AST, parser.block_obj)
        parser.lines_buff = String[line]
        parser.scope = LATEX_BLOCK
        
        return true
    end

    # latex block section content/end
    if parser.scope === LATEX_BLOCK
        push!(parser.lines_buff, line)
        rmatch = match(LATEX_BLOCK_END_LINE_REGEX, line)
        if !isnothing(rmatch)
            # exit block
            parser.scope = GLOBAL_SCOPE
            parser.block_obj.src = join(parser.lines_buff, "\n")
            parser.block_obj = nothing
            parser.lines_buff = nothing
        end
        return true
    end
    
    return false
end