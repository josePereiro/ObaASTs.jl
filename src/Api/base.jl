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

Base.deleteat!(ast::ObaAST, i) = deleteat!(ast.children, child_idx(i))
Base.splice!(ast::ObaAST, index) = splice!(ast.children, index)
Base.splice!(ast::ObaAST, index, replacement) = 
    splice!(ast.children, index, replacement)
function Base.splice!(ast::ObaAST, index, replacement::AbstractString) 
    _src_ast = parse_string(replacement)
    _reparent!(_src_ast, ast)
    splice!(ast.children, index, _src_ast)
end
Base.insert!(ast::ObaAST, index, item::AbstractObaASTChild) = 
    insert!(ast.children, child_idx(index), item)
Base.insert!(ast::ObaAST, index, item) = 
    (i = child_idx(index); splice!(ast, i:i - 1, item))
Base.append!(ast::ObaAST, items...) = append!(ast.children, items...)
function Base.append!(ast::ObaAST, src::AbstractString)
    _src_ast = parse_string(src)
    _reparent!(_src_ast, ast)
    append!(ast, _src_ast.children)
end

function Base.show(io::IO, ast::ObaAST)

    nchildren = length(ast)
    print(io, "ObaAST with ", nchildren, " child(s)")
    if !isnothing(ast.file)
        print(io, "\nfile: ", ast.file)
    end

    # data
    if nchildren > 0
        print(io, "\nchild(s): idx/line/preview")
        _show_data_preview(io, ast) do chidx, child
            child isa EmptyLineAST && return false # ignore empty
            print(io, "\n[", chidx, "] :", child.line, " ")
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

function Base.isequal(ch1::AbstractObaASTChild, ch2::AbstractObaASTChild) 
    isequal(source(ch1), source(ch2)) || return false
    isequal(ch1.line, ch2.line) || return false
    return true
end

function Base.findnext(f::Function, ast::ObaAST, chidx::Integer)::Union{Int, Nothing}
    found = nothing
    iter_from(ast, chidx, 1, 1) do idx, ch
        if f(ch) === true
            found = idx
            return true
        end
        return false
    end
    return found
end

Base.findnext(f::Function, ch::AbstractObaASTChild) = findnext(f, parent_ast(ch), child_idx(ch))

# regex
import Base.match
Base.match(reg::Regex, ch::AbstractObaAST) = match(reg, source(ch))
Base.match(reg::Regex, ch::AbstractObaASTChild) = match(reg, source(ch))
Base.match(reg::Regex, ch::AbstractObaASTObj) = match(reg, source(ch))

function find_bysource(ast::AbstractObaAST, pt::Regex)
    for ch in ast
        _hasmatch(pt, source(ch)) && return ch
    end
    return nothing
end
