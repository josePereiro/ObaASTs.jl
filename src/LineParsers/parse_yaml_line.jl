# ------------------------------------------------------------------
function _parse_yaml_line!(parser::LineParser, line, li)

    # short circuit
    parser.scope === INIT_SCOPE || parser.scope === YAML_BLOCK || return false

    rmatch = match(YAML_BLOCK_START_LINE_REGEX, line)
    if parser.scope === INIT_SCOPE && !isnothing(rmatch)
        parser.block_obj = YamlBlockAST(
            #= parent =# parser.AST, 
            #= src =# "", 
            #= line =# li
        )
        # enter block
        push!(parser.AST, parser.block_obj)
        parser.lines_buff = String[line]
        parser.scope = YAML_BLOCK
        return true
    end

    # yaml section content/end
    if parser.scope === YAML_BLOCK
        push!(parser.lines_buff, line)
        rmatch = match(YAML_BLOCK_END_LINE_REGEX, line)
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
