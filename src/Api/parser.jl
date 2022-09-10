# ------------------------------------------------------------------
# parser
parse_lines(lines::Base.EachLine) = _parse_lines(lines)
parse_lines(lines::Vector) = _parse_lines(lines)
parse_lines(lines::Base.Generator) = _parse_lines(lines)
parse_lines(lines::Channel) = _parse_lines(lines)
function parse_file(path::AbstractString) 
    AST = parse_lines(eachline(path))
    AST.file = abspath(path)
    return AST
end
parse_string(src::AbstractString) = parse_lines(split(src, "\n"))
