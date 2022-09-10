function _parse_block_link_line!(parser::LineParser)

    parser.scope === GLOBAL_SCOPE || return false

    rmatch = match(BLOCK_LINK_LINE_REGEX, parser.line)
    if !isnothing(rmatch)
        line_obj = BlockLinkLineAST(
            #= parent =# parser.AST,
            #= src =# parser.line,
            #= line =# parser.li
        )
        push!(parser.AST, line_obj)
        return true
    end
    return false
end