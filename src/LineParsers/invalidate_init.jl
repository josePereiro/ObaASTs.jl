function _invalidate_init_scope!(parser::LineParser, line, li)

    # short circuit
    parser.scope === INIT_SCOPE || return false

    rmatch = match(BLANK_LINE_REGEX, line)
    if isnothing(rmatch)
        parser.scope = GLOBAL_SCOPE
    end

    return false
end