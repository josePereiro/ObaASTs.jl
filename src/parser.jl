
# ------------------------------------------------------------------
# Types and Scope
const INIT_SCOPE = :INIT
const GLOBAL_SCOPE = :GLOBAL
const YAML_BLOCK = :YAML_BLOCK
const COMMENT_BLOCK = :COMMENT_BLOCK
const LATEX_BLOCK = :LATEX_BLOCK
const CODE_BLOCK = :CODE_BLOCK

# ------------------------------------------------------------------
function _parse_lines(lines)

    AST = ObaAST(nothing, Vector{AbstractObaAST}())
    scope = INIT_SCOPE
    block_obj = nothing
    lines_buff = nothing

    # ----------------------------------------------------------------
    # source part

    for (li, line) in enumerate(lines)
        line = string(line)

        # @info "-" line scope

        # ----------------------------------------------------------------
        # yaml section start
        rmatch = match(YAML_BLOCK_START_LINE_REGEX, line)
        if scope === INIT_SCOPE && !isnothing(rmatch)
            block_obj = YamlBlockAST(
                #= parent =# AST, 
                #= src =# "", 
                #= line =# li, 
                #= dict =# Dict{String, Any}()
            )

            push!(AST, block_obj)
            lines_buff = String[line]
            scope = YAML_BLOCK
            continue
        end

        # yaml section content/end
        if scope === YAML_BLOCK
            push!(lines_buff, line)
            rmatch = match(YAML_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj.src = join(lines_buff, "\n")
                block_obj = nothing
                lines_buff = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # unvalidate INIT_SCOPE
        rmatch = match(BLANK_LINE_REGEX, line)
        if scope === INIT_SCOPE && isnothing(rmatch)
            scope = GLOBAL_SCOPE
        end

        # ----------------------------------------------------------------
        # HEADER LINE

        rmatch = match(HEADER_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            line_obj = HeaderLineAST(
                #= parent =# AST,
                #= src =# line,
                #= line =# li,
                #= title =# "",
                #= lvl =# 0
            )
            push!(AST, line_obj)
            continue
        end

        # ----------------------------------------------------------------
        # BlockLinkLineAST
        rmatch = match(BLOCK_LINK_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            line_obj = BlockLinkLineAST(
                #= parent =# AST,
                #= src =# line,
                #= line =# li,
                #= link =# ""
            )
            push!(AST, line_obj)
            continue
        end

        # ----------------------------------------------------------------
        # COMMENT BLOCK

        # inline
        rmatch = match(COMMENT_BLOCK_INLINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)

            obj = CommentBlockAST(
                #= parent =# AST,
                #= src =# line,
                #= line =# li,
                #= body =# ""
            )
            push!(AST, obj)
            continue
        end

        # multiline
        rmatch = match(COMMENT_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            block_obj = CommentBlockAST(
                #= parent =# AST,
                #= src =# "",
                #= line =# li,
                #= body =# ""
            )
            # enter block
            push!(AST, block_obj)
            lines_buff = String[line]
            scope = COMMENT_BLOCK
            continue
        end

        # comment block section content/end
        if scope === COMMENT_BLOCK
            push!(lines_buff, line)
            rmatch = match(COMMENT_BLOCK_END_LINE_REGEX, line)
            
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj.src = join(lines_buff, "\n")
                block_obj = nothing
                lines_buff = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # LATEX BLOCK

        # inline
        rmatch = match(LATEX_BLOCK_INLINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            obj = LatexBlockAST(
                #= parent =# AST,
                #= src =# line,
                #= line =# li,
                #= body =# "",
                #= tag =# nothing
            )
            push!(AST, obj)
            continue
        end

        # multiline
        rmatch = match(LATEX_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            block_obj = LatexBlockAST(
                #= parent =# AST,
                #= src =# "",
                #= line =# li,
                #= txt =# "",
                #= tag =# nothing
            )

            # enter block
            push!(AST, block_obj)
            lines_buff = String[line]
            scope = LATEX_BLOCK
            continue
        end

        # latex block section content/end
        if scope === LATEX_BLOCK
            push!(lines_buff, line)
            rmatch = match(LATEX_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj.src = join(lines_buff, "\n")
                block_obj = nothing
                lines_buff = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # CODE BLOCK

        # inline
        rmatch = match(CODE_BLOCK_INLINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            obj = CodeBlockAST(
                #= parent =# AST, 
                #= src =# line, 
                #= line =# li, 
                #= lang =# "", 
                #= body =#  "" 
            )
            push!(AST, obj)
            continue
        end

        # multiline
        rmatch = match(CODE_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            block_obj = CodeBlockAST(
                #= parent =# AST, 
                #= src =# "", 
                #= line =# li, 
                #= lang =# "", 
                #= body =#  "" 
            )

            # enter block
            push!(AST, block_obj)
            lines_buff = String[line]
            scope = CODE_BLOCK
            continue
        end

        # code block section content/end
        if scope === CODE_BLOCK
            push!(lines_buff, line)
            rmatch = match(CODE_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj.src = join(lines_buff, "\n")
                block_obj = nothing
                lines_buff = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # Text line
        rmatch = match(BLANK_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && isnothing(rmatch)
            obj = TextLineAST(
                #= parent =# AST,
                #= src =# line,
                #= line =# li,
                #= inlinks =# Vector{InternalLinkAST}(),
                #= tags =# Vector{TagAST}()
            )
            push!(AST, obj)
            continue
        end

        # ----------------------------------------------------------------
        # empty line
        rmatch = match(BLANK_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            obj = EmptyLineAST(
                #= parent =# AST,
                #= src =# line,
                #= line =# li
            )
            push!(AST, obj)
            continue
        end

    end

    # Check closing objects
    scope !== GLOBAL_SCOPE && !isnothing(block_obj) && error(
        "Parsing failed, block ", scope, " starting at line ", block_obj.line, " unclosed!"
    )
    
    # ----------------------------------------------------------------
    # parsed part
    foreach(reparse!, AST)

    return AST
end

