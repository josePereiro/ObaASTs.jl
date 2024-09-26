# ------------------------------------------------------------------
# utils
"""
    find_byline(AST, line::Int)

Find (or return `nothing`) the index of the child which contain the given line

"""
function find_byline(AST, line::Int)
    prevli = 1
    for (chidx, child) in enumerate(AST)
        nextli = child.line
        (prevli <= line <= nextli) && return chidx
        prevli = nextli
    end
    return nothing
end

# ------------------------------------------------------------------
"""
    child_idx(ch::AbstractObaASTChild)
    child_idx(idx::Integer) # A fallback

Find the first index of the given child in its parent AST
"""
child_idx(ast::ObaAST, ch::AbstractObaASTChild) = findfirst(isequal(ch), ast)
child_idx(::ObaAST, idx::Integer) = idx
child_idx(ch::AbstractObaASTChild) = child_idx(parent_ast(ch), ch)
child_idx(idx::Integer) = idx

# ------------------------------------------------------------------
"""
    iter_from(f::Function, AST::ObaAST, chidx::Integer, step::Integer, offset::Integer = 0)
    iter_from(f::Function, ch::AbstractObaASTChild, step::Integer, offset::Integer = 0)
    iter_from(f::Function, ch::AbstractObaASTChild; step::Integer = 1, offset::Integer = 0)

Iterate for each child of the top AST starting from a given index or child.
On each iteration the function `f(idx, child)` will be evaluated.
The return value of the function `f` acts as a flag to short circuit the iteration.
It is triggered at `f(idx, child) === true`.
Use `step` to control the iteration step (if it is negative it iterate toward the first child).
Use `offset` to move the starting point (usefull in cases where the starting point is a child object).
The method do not check for index corretness

# Examples
```julia
julia> iter_from((x...) -> nothing, child, 1, 0)
# Iterate from `child` to the end of its parent ast

julia> iter_from((x...) -> nothing, child, -1, 0)
# Iterate from `child` to the begining of its parent ast

julia> iter_from((x...) -> nothing, child, -1, -1)
# Iterate from `child` to the begining of its parent ast skipping `child` itself
```
"""
function iter_from(f::Function, AST::ObaAST, chidx::Integer, step::Integer, offset::Integer = 0)

    il, iu = firstindex(AST), lastindex(AST)
    i0 = chidx + offset
    i1 = step > 0 ? #= iter down =# iu : #= iter up =# il

    for i in i0:step:i1 
        f(i, AST[i]) === true && return
    end
    return

end

iter_from(f::Function, ch::AbstractObaASTChild, step::Integer, offset::Integer = 0) =
    iter_from(f, parent_ast(ch), child_idx(ch), step, offset)

iter_from(f::Function, ch::AbstractObaASTChild; 
    step::Integer = 1,
    offset::Integer = 0
) = iter_from(f, ch, step, offset)

# regex
match_src(reg::Regex, ch::AbstractObaASTChild) = match(reg, source(ch))
match_src(reg::Regex, ch::AbstractObaASTObj) = match(reg, source(ch))

# ------------------------------------------------------------------
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


# ------------------------------------------------------------------
function _exportall(filter::Function, mod::Module)
    for sym in names(mod; all = true, imported = true)
        filter(sym) == true || continue
        @eval mod export $(sym)
    end
end

macro _exportall_non_underscore()
    return quote
        _exportall($(__module__)) do sym
            sym == :eval && return false
            sym == :include && return false
            startswith(string(sym), r"@?[^_#]") && return true
            return false
        end
    end
end
