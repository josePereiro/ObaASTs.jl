function _parse_code_block_line!(parser::LineParser, line, li)

    # short circuit
    parser.scope === GLOBAL_SCOPE || parser.scope === CODE_BLOCK || return false

    # inline
    rmatch = match(CODE_BLOCK_INLINE_REGEX, line)
    if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)
        obj = CodeBlockAST(
            #= parent =# parser.AST, 
            #= src =# line, 
            #= line =# li
        )
        push!(parser.AST, obj)
        
        return true
    end

    # multiline
    rmatch = match(CODE_BLOCK_START_LINE_REGEX, line)
    if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)
        parser.block_obj = CodeBlockAST(
            #= parent =# parser.AST, 
            #= src =# "", 
            #= line =# li
        )

        # enter block
        push!(parser.AST, parser.block_obj)
        parser.lines_buff = String[line]
        parser.scope = CODE_BLOCK
        
        return true
    end

    # code block section content/end
    if parser.scope === CODE_BLOCK
        push!(parser.lines_buff, line)
        rmatch = match(CODE_BLOCK_END_LINE_REGEX, line)
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