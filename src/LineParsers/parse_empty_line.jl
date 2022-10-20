function _parse_empty_line!(parser::LineParser)

    rmatch = match(BLANK_LINE_REGEX, parser.line)
    if !isnothing(rmatch)
        obj = EmptyLineAST(
            #= parent =# parser.AST,
            #= src =# parser.line,
            #= line =# parser.li
        )
        push!(parser.AST, obj)
        return true
    end

    return false
end