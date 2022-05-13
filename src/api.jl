join_src(ast::AbstractObaAST, args...) = error("method join_src(", typeof(ast), ") not defined")
join_src(ast::AbstractObaASTBlock, args...) = join(ast.src, args...)
join_src(ast::AbstractObaASTLine, args...) = ast.src
join_src(ast::AbstractObaASTObj, args...) = ast.src

src_str(ast::AbstractObaAST) = join_src(ast, "\n")

is_emptyline(::AbstractObaASTBlock) = false
is_emptyline(::AbstractObaASTLine) = false
is_emptyline(::AbstractObaASTObj) = false
is_emptyline(::EmptyLineAST) = true