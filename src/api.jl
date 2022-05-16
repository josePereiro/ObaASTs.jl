# ------------------------------------------------------------------
# AST
source(ast::AbstractObaAST) = error("method source(", typeof(ast), ") not defined")
source(ast::AbstractObaASTChild) = ast.src
source(ast::AbstractObaASTObj) = ast.src

function source(ast::ObaAST)
    srcs = map(source, ast)
    return join(srcs, "\n")
end

source(ast::ObaAST, idx::Int) = source(ast[idx])

function source(ast::ObaAST, idxs)
    srcs = String[]
    for i in idxs
        push!(srcs, source(ast[i]))
    end
    return join(srcs, "\n")
end

function source(ast::AbstractObaAST, asts::AbstractObaAST...)
    srcs = String[source(ast)]
    for asti in asts
        push!(srcs, source(asti))
    end
    return join(srcs, "\n")
end

# To avoid overflow
_source(ast::AbstractObaAST) = source(ast)

function source(astv)
    srcs = String[]
    for asti in astv
        push!(srcs, _source(asti))
    end
    return join(srcs, "\n")
end

is_emptyline(::AbstractObaAST) = false
is_emptyline(::EmptyLineAST) = true

parent_ast(ast::AbstractObaAST) = ast.parent
parent_ast(ast::ObaAST) = ast

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
parse_string(src::AbstractString) = parse_lines(split(src))

# ------------------------------------------------------------------
# base
function Base.write(io::IO, AST::ObaAST)
    b = 0
    for ch in AST
        b += write(io, source(ch), "\n")
    end
    return b
end

Base.write(io::IO, ast::AbstractObaAST) = write(io, source(ast), "\n")

Base.read(io::IO, ::Type{ObaAST}) = parse_string(read(io, String))
Base.read(file::AbstractString, ::Type{ObaAST}) = parse_file(file)

Base.length(ast::ObaAST) = length(ast.childs)
Base.size(ast::ObaAST, args...) = size(ast.childs, args...)
Base.getindex(ast::ObaAST, key) = getindex(ast.childs, key)
Base.setindex!(ast::ObaAST, obj::AbstractObaASTChild, key) = setindex!(ast.childs, obj, key)
Base.iterate(ast::ObaAST) = iterate(ast.childs)
Base.iterate(ast::ObaAST, state) = iterate(ast.childs, state)
Base.push!(ast::ObaAST, obj::AbstractObaASTChild) = push!(ast.childs, obj)
Base.firstindex(ast::ObaAST) = firstindex(ast.childs)
Base.lastindex(ast::ObaAST) = lastindex(ast.childs)
Base.pairs(ast::ObaAST) = pairs(ast.childs)

function Base.show(io::IO, ast::ObaAST)

    nchilds = length(ast)
    print(io, "ObaAST with ", nchilds, " child(s)")

    # data
    if nchilds > 0
        print(io, "\nchild(s):")
        _show_data_preview(io, ast) do chidx, child
            child isa EmptyLineAST && return false # ignore empty
            print(io, "\n[", chidx, "] ")
            show(io, child)
            return false
        end
    end

    return nothing
end

function Base.show(io::IO, ast::AbstractObaAST)
    print(io, nameof(typeof(ast)), " \"", _preview(io, source(ast)), "\"")
end



# ------------------------------------------------------------------
# utils
function find_byline(AST, line::Int)
    prevli = 1
    for (chidx, child) in enumerate(AST)
        nextli = child.line
        (prevli <= line <= nextli) && return chidx
        prevli = nextli
    end
    return nothing
end
export find_byline

"""
Walk up the ObaAST from child to child till the begining from a given child AST (or child index).
Eval the fun `f(chidx, child)` each time (do not eval at the starting child).
If the function returns `true` it returns.
It always returns `nothing`
"""
function iterup_from(f::Function, AST::ObaAST, chidx::Int)
    chidx0 = firstindex(AST)
    for i in (chidx-1):-1:chidx0
        f(i, AST[i]) === true && return
    end
    return
end

function iterup_from(f::Function, ch::AbstractObaASTChild)
    AST = ch.parent
    chidx = find_byline(AST, ch.line)
    iterup_from(f, AST, chidx)
end
export iterup_from

"""
Walk down the ObaAST from child to child till the end from a given child AST (or child index).
Eval the fun `f(chidx, child)` each time (do not eval at the starting child).
If the function returns `true` it returns.
It always returns `nothing`
"""
function iterdown_from(f::Function, AST::ObaAST, chidx::Int)
    chidx1 = lastindex(AST)
    for i in (chidx + 1):chidx1
        f(i, AST[i]) === true && return
    end
    return
end

function iterdown_from(f::Function, ch::AbstractObaASTChild)
    AST = ch.parent
    chidx = find_byline(AST, ch.line)
    iterdown_from(f, AST, chidx)
end
export iterdown_from

# regex
match_src(reg::Regex, ch::AbstractObaASTChild) = match(reg, source(ch))
export match_src
