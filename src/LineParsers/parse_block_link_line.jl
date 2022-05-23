function _parse_block_link_line!(parser::LineParser, line, li)

    parser.scope === GLOBAL_SCOPE || return false

    rmatch = match(BLOCK_LINK_LINE_REGEX, line)
    if !isnothing(rmatch)
        line_obj = BlockLinkLineAST(
            #= parent =# parser.AST,
            #= src =# line,
            #= line =# li
        )
        push!(parser.AST, line_obj)
        return true
    end
    return false
end