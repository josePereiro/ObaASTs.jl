# A set of functions which reparse childs after the basic ones had been parsed
# ------------------------------------------------------------------
# REPARSERS_BOOK
const REPARSERS_BOOK = Dict{DataType, Vector{Function}}()

export register_reparser!
function register_reparser!(f::Function, T::DataType) 
    reg = get!(() -> Vector{Function}(), REPARSERS_BOOK, T)
    return push!(reg, f)
end

# ------------------------------------------------------------------
# reparse childs
function reparse!(ast::AbstractObaAST)
    T = typeof(ast)
    haskey(REPARSERS_BOOK, T) || error("No reparser! registered for $(T). See `register_reparser!`")
    foreach((f!) -> f!(ast), REPARSERS_BOOK[T])
    return ast
end

# ------------------------------------------------------------------
# ObaAST
_reparent!(ch::AbstractObaASTChild, new_parent::ObaAST) = (ch.parent = new_parent)
function _reparent!(ast, new_parent::ObaAST)
    for ch in ast
        _reparent!(ch, new_parent)
    end
end

function reparse!(ast::ObaAST)

    # reparse
    _parser = LineParser()
    for child in ast
        _feed_parser!(_parser, split(source(child), "\n"))
    end
    _new_ast = _parser.AST
    foreach(reparse!, _new_ast)

    # up ast
    ast.reparse_counter += 1
    resize!(ast.children, length(_new_ast.children))
    ast.children .= _new_ast.children
    _reparent!(_new_ast.children, ast)

    return ast
end