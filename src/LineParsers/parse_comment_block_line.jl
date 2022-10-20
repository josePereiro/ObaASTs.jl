function _parse_comment_block_line!(parser::LineParser)

    # short circuit
    parser.scope === GLOBAL_SCOPE || parser.scope === COMMENT_BLOCK || return false

    # inline
    rmatch = match(COMMENT_BLOCK_INLINE_REGEX, parser.line)
    if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)

        obj = CommentBlockAST(
            #= parent =# parser.AST,
            #= src =# parser.line,
            #= line =# parser.li
        )
        push!(parser.AST, obj)
        return true
    end

    # multiline
    rmatch = match(COMMENT_BLOCK_START_LINE_REGEX, parser.line)
    if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)
        parser.block_obj = CommentBlockAST(
            #= parent =# parser.AST,
            #= src =# "",
            #= line =# parser.li
        )
        # enter block
        push!(parser.AST, parser.block_obj)
        parser.lines_buff = String[parser.line]
        parser.scope = COMMENT_BLOCK
        return true
    end

    # comment block section content/end
    if parser.scope === COMMENT_BLOCK
        push!(parser.lines_buff, parser.line)
        
        rmatch = match(COMMENT_BLOCK_END_LINE_REGEX, parser.line)
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