function _parse_text_line!(parser::LineParser, line, li)

    # short circuit
    parser.scope === GLOBAL_SCOPE || return false

    rmatch = match(BLANK_LINE_REGEX, line)
    if isnothing(rmatch)
        obj = TextLineAST(
            #= parent =# parser.AST,
            #= src =# line,
            #= line =# li
        )
        push!(parser.AST, obj)
        return true
    end
    
    return false
    
end