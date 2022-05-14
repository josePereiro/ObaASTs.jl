# ------------------------------------------------------------------

source(ast::AbstractObaAST, args...) = error("method source(", typeof(ast), ") not defined")
source(ast::AbstractObaASTChild, args...) = ast.src
source(ast::AbstractObaASTObj, args...) = ast.src

function source(ast::ObaAST)
    srcs = map(source, ast)
    return join(srcs, "\n")
end

# ------------------------------------------------------------------
is_emptyline(::AbstractObaAST) = false
is_emptyline(::EmptyLineAST) = true

# ------------------------------------------------------------------
# api
parse_lines(lines::Base.EachLine) = _parse_lines(lines)
parse_lines(lines::Vector) = _parse_lines(lines)
parse_lines(lines::Base.Generator) = _parse_lines(lines)
parse_lines(lines::Channel) = _parse_lines(lines)
function parse_file(path::AbstractString) 
    AST = parse_lines(eachline(path))
    AST.file = abspath(path)
    return AST
end
parse_string(src::AbstractString) = parse_lines(split(src))