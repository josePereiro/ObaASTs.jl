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
