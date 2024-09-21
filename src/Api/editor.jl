# ------------------------------------------------------------------
export resource!
function resource!(ch::AbstractObaASTChild, src::AbstractString)
    ch.src = src
    reparse!(parent_ast(ch))
    return ch
end

function resource!(ch::YamlBlockAST, yaml::Dict)
    yaml_str = YAML.write(yaml)
    src = string("---\n", strip(yaml_str), "\n---")
    return resource!(ch, src)
end

# ------------------------------------------------------------------
import Base.replace!
function replace!(ast::AbstractObaAST, old_new::Pair...; kwargs...)
    new_src = replace(source(ast), old_new...; kwargs...)
    reparse!(ast, new_src)
    return ast
end

# ------------------------------------------------------------------
export write!!
write!!(io::IO, ast::ObaAST) = write(io, reparse!(ast))
write!!(file::AbstractString, ast::ObaAST) = write(file, reparse!(ast))
function write!!(ast::ObaAST)
    file = parent_file(ast)
    isnothing(file) && error("The ObaAST do not have a source file!")
    write(file, reparse!(ast))
end
write!!(ch::AbstractObaASTChild) = write!!(parent_ast(ch))

# ------------------------------------------------------------------
function cut_from!(ast::ObaAST, chidx::Int, step::Integer, offset::Integer) 
    
    il, iu = firstindex(ast), lastindex(ast)
    i0 = chidx + offset
    i1 = step > 0 ? #= iter down =# iu : #= iter up =# il
    
    return splice!(ast, i0:step:i1)
end
cut_from!(ast::ObaAST, chidx::Int; step::Integer = 1, offset::Integer = 1) = 
    cut_from!(ast, chidx, step, offset) 
cut_from!(ast::ObaAST, ch::AbstractObaASTChild, args...; kwargs...) = 
    cut_from!(ast, child_idx(ch), args...; kwargs...) 
cut_from!(ch::AbstractObaASTChild, args...; kwargs...) = 
    cut_from!(parent_ast(ch), ch, args...; kwargs...) 
export cut_from!