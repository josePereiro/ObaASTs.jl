## ------------------------------------------------------------------
const OBA_SCRIPT_BLOCK_IDER_REGEX = r"\A(?:\%{2}\h*\n)?(?:`{3})?julia\h+\#\!Oba\N*"

function _is_obascript(ast)
    rmatch = match(OBA_SCRIPT_BLOCK_IDER_REGEX, ast.src)
    return !isnothing(rmatch)
end

# Assume valid src!
function __promote_obascripts(ast::AbstractObaASTChild)
    _is_obascript(ast) || return ast
    
    scr_ast = ObaScriptBlockAST(
        #= parent =# ast.parent,
        #= src =# ast.src,
        #= line =# ast.line
    )
    return scr_ast
end

_promote_obascripts(ast::CodeBlockAST) = __promote_obascripts(ast)
_promote_obascripts(ast::CommentBlockAST) = __promote_obascripts(ast)
_promote_obascripts(ast) = ast

function _register_obascript_promoter() 
    register_promoter!(_promote_obascripts, CodeBlockAST)
    register_promoter!(_promote_obascripts, CommentBlockAST)
end