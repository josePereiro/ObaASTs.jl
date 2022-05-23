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

Base.length(ast::ObaAST) = length(ast.children)
Base.size(ast::ObaAST, args...) = size(ast.children, args...)
Base.getindex(ast::ObaAST, key) = getindex(ast.children, key)
Base.setindex!(ast::ObaAST, obj::AbstractObaASTChild, key) = setindex!(ast.children, obj, key)
Base.iterate(ast::ObaAST) = iterate(ast.children)
Base.iterate(ast::ObaAST, state) = iterate(ast.children, state)
Base.push!(ast::ObaAST, obj::AbstractObaASTChild) = push!(ast.children, obj)
Base.firstindex(ast::ObaAST) = firstindex(ast.children)
Base.lastindex(ast::ObaAST) = lastindex(ast.children)
Base.pairs(ast::ObaAST) = pairs(ast.children)
Base.collect(ast::ObaAST) = collect(ast.children)

function Base.show(io::IO, ast::ObaAST)

    nchildren = length(ast)
    print(io, "ObaAST with ", nchildren, " child(s)")

    # data
    if nchildren > 0
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

Base.filter(fun::Function, ast::ObaAST) = ObaAST(ast.file, filter(fun, ast.children))