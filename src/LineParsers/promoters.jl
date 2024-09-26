# A set of functions which promote childs after the basic ones had been parsed
# see ObaScriptBlockAST promoters as example
#   CodeBlockAST ar CommentBlockAST can be promoted to ObaScriptBlockAST

# ------------------------------------------------------------------
# PROMOTERS_BOOK
const PROMOTERS_BOOK = Dict{DataType, Vector{Function}}()

function register_promoter!(f::Function, T::DataType) 
    reg = get!(() -> Vector{Function}(), PROMOTERS_BOOK, T)
    return push!(reg, f)
end

# Run the promoters till the type reach an steady state
function run_promoters!(ast::ObaAST)
    for i in eachindex(ast.children)
        ch = ast.children[i]
        did_promote = false
        for _ in 1:100
            T0 = typeof(ch)
            haskey(PROMOTERS_BOOK, T0) || break
            for p! in PROMOTERS_BOOK[T0]
                ch = p!(ch)
                did_promote = !(ch isa T0)
                did_promote && break # try again
            end
            did_promote || break # break if stable
            ast.children[i] = ch
        end
    end
    return ast
end

run_promoters!(parser::LineParser) = run_promoters!(parser.AST)
