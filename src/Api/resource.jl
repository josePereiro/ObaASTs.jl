# ------------------------------------------------------------------
# resource means that the new new source is external

function resource(ast::ObaAST, src::AbstractString)
    _new_ast = parse_string(src)
    _merge_meta!(ast, _new_ast)
    return _new_ast
end

function resource!(ast::ObaAST, src::AbstractString)
    _new_ast = resource(ast, src)
    _transfer_children!(ast, _new_ast)
    return ast
end

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
# reparse
# A set of functions which reparse childs after the basic ones had been parsed
# - reparsing means recompuing the parsed field of a child from its source.
# - this is needed after a modification to the `src` field of any child.
# - note that modifying a child might change all others (ex: line number)

# return a new AST from the source of the current input
# It is a kind of updated copy
function reparse(ast::ObaAST)
    _new_ast = _parse_batch(
        split(source(child), "\n")
        for child in ast
    )
    _merge_meta!(ast, _new_ast)
    return _new_ast
end

function reparse!(ast::ObaAST)
    _new_ast = reparse(ast)
    _transfer_children!(ast, _new_ast)
    return ast
end
