# ------------------------------------------------------------------
# set a new source for the child and reparse it
# TODO: think about the name, it is suggesting that `src` is recomputed from `parsed`
# which is not supported. A simple `setsource!` or even `source!` might be better

# ------------------------------------------------------------------
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
