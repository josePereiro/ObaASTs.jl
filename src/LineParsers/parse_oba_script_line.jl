## ------------------------------------------------------------------
const OBA_SCRIPT_BLOCK_IDER_REGEX = r"\A(?:\%{2}\h*\n)?(?:`{3})?julia\h+\#\!Oba\N*"

function _is_obascript(ast)
    rmatch = match(OBA_SCRIPT_BLOCK_IDER_REGEX, ast.src)
    return !isnothing(rmatch)
end

# Assume valid src!
function __obascript(ast::AbstractObaASTChild)
    _is_obascript(ast) || return ast
    
    scr_ast = ObaScriptBlockAST(
        #= parent =# ast.parent,
        #= src =# ast.src,
        #= line =# ast.line
    )
    return scr_ast
end

_obascript(ast::CodeBlockAST) = __obascript(ast)
_obascript(ast::CommentBlockAST) = __obascript(ast)
_obascript(ast) = ast

function _promote_obascripts!(ast::ObaAST)
    for i in eachindex(ast.children)
        ch = ast.children[i]
        ast.children[i] = _obascript(ch)
    end
    return ast
end

## ------------------------------------------------------------------
# function _parse_oba_script_line!(parser::LineParser, line, li)

#     # short circuit
#     parser.scope === GLOBAL_SCOPE || parser.scope === OBA_SCRIPT_BLOCK || return false 

#     # multiline
#     rmatch = match(OBA_SCRIPT_BLOCK_START_LINE_REGEX, line)
#     if parser.scope === GLOBAL_SCOPE && !isnothing(rmatch)
#         parser.block_obj = ObaScriptBlockAST(
#             #= parent =# parser.AST,
#             #= src =# "",
#             #= line =# li
#         )
#         # enter block
#         push!(parser.AST, parser.block_obj)
#         parser.lines_buff = String[line]
#         parser.scope = OBA_SCRIPT_BLOCK
#         return true
#     end

#     # comment block section content/end
#     if parser.scope === OBA_SCRIPT_BLOCK
#         push!(parser.lines_buff, line)
        
#         rmatch = match(OBA_SCRIPT_BLOCK_END_LINE_REGEX, line)
#         if !isnothing(rmatch)
#             # exit block
#             parser.scope = GLOBAL_SCOPE
#             parser.block_obj.src = join(parser.lines_buff, "\n")
#             parser.block_obj = nothing
#             parser.lines_buff = nothing
#         end
#         return true
#     end

#     return false
# end