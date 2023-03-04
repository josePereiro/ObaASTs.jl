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
    foreach(f! -> f!(ast), REPARSERS_BOOK[T])
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

function _up_new_ast!(_new_ast::ObaAST, ast::ObaAST)
    _new_ast.reparse_counter = ast.reparse_counter + 1
    _new_ast.file = ast.file
    return _new_ast
end


function _up_childs!(ast::ObaAST, _new_ast::ObaAST)
    # up ast
    ast.reparse_counter += 1
    resize!(ast.children, length(_new_ast.children))
    ast.children .= _new_ast.children
    _reparent!(ast.children, ast)
end

function reparse(ast::ObaAST)
    _parser = LineParser()
    for child in ast
        _feed_parser!(_parser, split(source(child), "\n"))
    end
    _new_ast = _parser.AST
    foreach(reparse!, _new_ast)

    _up_new_ast!(_new_ast, ast)
end

function reparse(ast::ObaAST, src::AbstractString)
    _new_ast = parse_string(src)
    _up_new_ast!(_new_ast, ast)
end

function reparse!(ast::ObaAST)
    _new_ast = reparse(ast)
    _up_childs!(ast, _new_ast)
    return ast
end

function reparse!(ast::ObaAST, src::AbstractString)
    _new_ast = reparse(ast, src)
    _up_childs!(ast, _new_ast)

    return ast
end

