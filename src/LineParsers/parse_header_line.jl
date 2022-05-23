function _parse_header_line!(parser::LineParser, line, li)

    # short circuit
    parser.scope === GLOBAL_SCOPE || return false

    rmatch = match(HEADER_LINE_REGEX, line)
    if !isnothing(rmatch)
        line_obj = HeaderLineAST(
            #= parent =# parser.AST,
            #= src =# line,
            #= line =# li,
            #= title =# "",
            #= lvl =# 0
        )
        push!(parser.AST, line_obj)
        return true
    end

    return false
end