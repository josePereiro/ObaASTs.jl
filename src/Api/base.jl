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

