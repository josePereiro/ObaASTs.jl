# ------------------------------------------------------------------
# base
Base.write(io::IO, ast::AbstractObaAST) = write(io, source(ast), "\n")
function Base.write(io::IO, astv::Vector{<:AbstractObaAST}) 
    b = 0
    for ast in astv
        b += write(io, source(ast), "\n")
    end
    return b
end

Base.write(io::IO, AST::ObaAST) = write(io, AST.children)

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
Base.eachindex(ast::ObaAST) = eachindex(ast.children)
Base.pairs(ast::ObaAST) = pairs(ast.children)
Base.collect(ast::ObaAST) = collect(ast.children)

Base.deleteat!(AST::ObaAST, i) = deleteat!(AST.children, child_idx(i))
Base.delete!(AST::ObaAST, ch::AbstractObaASTChild) = deleteat!(AST, ch)

function Base.show(io::IO, ast::ObaAST)

    nchildren = length(ast)
    print(io, "ObaAST with ", nchildren, " child(s)")
    if !isnothing(ast.file)
        print(io, "\nfile: ", ast.file)
    end

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

Base.filter(fun::Function, ast::ObaAST) = ObaAST(ast.file, filter(fun, ast.children), ast.reparse_counter)

Base.getindex(ast::AbstractObaASTChild, key::Symbol) = getindex(ast.parsed, key)
Base.getindex(ast::AbstractObaASTObj, key::Symbol) = getindex(ast.parsed, key)

Base.get(ast::AbstractObaASTChild, key::Symbol, dflt) = get(ast.parsed, key, dflt)
Base.get(f::Function, ast::AbstractObaASTChild, key::Symbol) = get(f, ast.parsed, key)
Base.get(ast::AbstractObaASTObj, key::Symbol, dflt) = get(ast.parsed, key, dflt)
Base.get(f::Function, ast::AbstractObaASTObj, key::Symbol) = get(f, ast.parsed, key)

Base.keys(ast::AbstractObaASTChild) = keys(ast.parsed)
Base.keys(ast::AbstractObaASTObj) = keys(ast.parsed)