function _parse_header_line!(parser::LineParser)

    # short circuit
    parser.scope === GLOBAL_SCOPE || return false

    rmatch = match(HEADER_LINE_REGEX, parser.line)
    if !isnothing(rmatch)
        line_obj = HeaderLineAST(
            #= parent =# parser.AST,
            #= src =# parser.line,
            #= line =# parser.li
        )
        push!(parser.AST, line_obj)
        return true
    end

    return false
end