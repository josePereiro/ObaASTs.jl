
# ------------------------------------------------------------------
# Types and Scope
const INIT_SCOPE = :INIT
const GLOBAL_SCOPE = :GLOBAL
const YAML_BLOCK = :YAML_BLOCK
const COMMENT_BLOCK = :COMMENT_BLOCK
const LATEX_BLOCK = :LATEX_BLOCK
const CODE_BLOCK = :CODE_BLOCK
const HEADER = :HEADER
const TEXT_LINE = :TEXT_LINE
const EMPTY_LINE = :EMPTY_LINE

# ------------------------------------------------------------------
# This assume a per-line compatible file. Obsidian is more flexible.
# The main restriction is that no block element is started in a midline. 
# TODO: write error code to detect it
function _parse_lines(lines)

    AST = ObaAST(Vector{AbstractObaAST}())
    scope = INIT_SCOPE
    block_obj = nothing

    for (li, line) in enumerate(lines)
        line = string(line)

        # @info "-" line scope

        # ----------------------------------------------------------------
        # yaml section start
        rmatch = match(YAML_BLOCK_START_LINE_REGEX, line)
        if scope === INIT_SCOPE && !isnothing(rmatch)
            # @info "At YAML_BLOCK_START_LINE_REGEX"
            block_obj = YamlBlockAST(
                #= parent =# AST, 
                #= line =# li, 
                #= src =# [line], 
                #= dat =# Dict{String, Any}()
            )

            push!(AST, block_obj)
            scope = YAML_BLOCK
            continue
        end

        # yaml section content/end
        if scope === YAML_BLOCK
            push!(block_obj.src, line)
            rmatch = match(YAML_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # @info "At YAML_BLOCK_END_LINE_REGEX"
                scope = GLOBAL_SCOPE
                block_obj = nothing
            end
            # @info "At YAML_BLOCK"
            continue
        end

        # ----------------------------------------------------------------
        # unvalidate INIT_SCOPE
        rmatch = match(BLANK_LINE_REGEX, line)
        if scope === INIT_SCOPE && isnothing(rmatch)
            scope = GLOBAL_SCOPE
        end

        # ----------------------------------------------------------------
        # header
        rmatch = match(HEADER_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            line_obj = HeaderLineAST(
                #= parent =# AST,
                #= line =# li,
                #= src =# line,
                #= title =# "",
                #= lvl =# -1
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
                #= line =# li,
                #= src =# [line],
                #= txt =# ""
            )
            push!(AST, obj)
            continue
        end

        # multiline
        rmatch = match(COMMENT_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            block_obj = CommentBlockAST(
                #= parent =# AST,
                #= line =# li,
                #= src =# [line],
                #= txt =# ""
            )
            # enter block
            push!(AST, block_obj)
            scope = COMMENT_BLOCK
            continue
        end

        # comment block section content/end
        if scope === COMMENT_BLOCK
            push!(block_obj.src, line)
            rmatch = match(COMMENT_BLOCK_END_LINE_REGEX, line)
            
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj = nothing
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
                #= line =# li,
                #= src =# [line],
                #= txt =# "",
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
                #= line =# li,
                #= src =# [line],
                #= txt =# "",
                #= tag =# nothing
            )

            # enter block
            push!(AST, block_obj)
            scope = LATEX_BLOCK
            continue
        end

        # latex block section content/end
        if scope === LATEX_BLOCK
            push!(block_obj.src, line)
            rmatch = match(LATEX_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj = nothing
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
                #= line =# li, 
                #= src =# [line], 
                #= lang =# nothing, 
                #= code =#  "" 
            )
            push!(AST, obj)
            continue
        end

        # multiline
        rmatch = match(CODE_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            block_obj = CodeBlockAST(
                #= parent =# AST, 
                #= line =# li, 
                #= src =# [line], 
                #= lang =# nothing, 
                #= code =#  "" 
            )

            # enter block
            push!(AST, block_obj)
            scope = CODE_BLOCK
            continue
        end

        # code block section content/end
        if scope === CODE_BLOCK
            push!(block_obj.src, line)
            rmatch = match(CODE_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                block_obj = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # Text line
        rmatch = match(BLANK_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && isnothing(rmatch)
            obj = TextLineAST(
                #= parent =# AST,
                #= line =# li,
                #= src =# line,
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
                #= line =# li,
                #= src =# line
            )
            push!(AST, obj)
            continue
        end

    end

    # Check closing objects
    scope !== GLOBAL_SCOPE && !isnothing(block_obj) && error(
        "Parsing failed, block ", scope, " starting at line ", block_obj[:line], " unclosed!"
    )

    return reparse!(AST)
end

# ------------------------------------------------------------------
# api
parse_lines(lines::Base.EachLine) = _parse_lines(lines)
parse_lines(lines::Vector) = _parse_lines(lines)
parse_file(path::AbstractString) = parse_lines(eachline(path))
parse_string(src::AbstractString) = parse_lines(split(src))
