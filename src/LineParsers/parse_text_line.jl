function _parse_text_line!(parser::LineParser)

    # short circuit
    parser.scope === GLOBAL_SCOPE || return false

    rmatch = match(BLANK_LINE_REGEX, parser.line)
    if isnothing(rmatch)
        obj = TextLineAST(
            #= parent =# parser.AST,
            #= src =# parser.line,
            #= line =# parser.li
        )
        push!(parser.AST, obj)
        return true
    end
    
    return false
    
end