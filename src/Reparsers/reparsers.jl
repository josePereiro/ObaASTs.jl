# ------------------------------------------------------------------
# REPARSERS_BOOK
const REPARSERS_BOOK = Dict{DataType, Vector{Function}}()

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

function _reparent!(dst_ast, new_parent::ObaAST)
    for ch in dst_ast
        ch.parent = new_parent
    end
end

function _merge_meta!(dst_ast::ObaAST, src_ast::ObaAST)
    dst_ast.reparse_counter = src_ast.reparse_counter + 1
    dst_ast.file = src_ast.file
    return dst_ast
end

function _transfer_children!(dst_ast::ObaAST, src_ast::ObaAST)
    # up dst_ast
    dst_ast.reparse_counter += 1
    resize!(dst_ast.children, length(src_ast.children))
    dst_ast.children .= src_ast.children
    _reparent!(dst_ast, dst_ast) # regain parenhood
    return nothing
end
