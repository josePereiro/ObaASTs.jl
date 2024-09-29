module ObaASTs

    import YAML
    import MassExport

    #! include Api
    include("Api/0_types.jl")
    include("Api/ast.jl")
    include("Api/base.jl")
    include("Api/editor.jl")
    include("Api/oba_script_ast.jl")
    include("Api/parser.jl")
    include("Api/resource.jl")
    include("Api/utils.jl")
    
    #! include LineParsers
    include("LineParsers/0_types.jl")
    include("LineParsers/constants.jl")
    include("LineParsers/parse_block_link_line.jl")
    include("LineParsers/parse_code_block_line.jl")
    include("LineParsers/parse_comment_block_line.jl")
    include("LineParsers/parse_empty_line.jl")
    include("LineParsers/parse_header_line.jl")
    include("LineParsers/parse_latex_block_line.jl")
    include("LineParsers/parse_lines.jl")
    include("LineParsers/parse_text_line.jl")
    include("LineParsers/parse_yaml_line.jl")
    include("LineParsers/promote_obascript.jl")
    include("LineParsers/promoters.jl")
    
    #! include Reparsers
    include("Reparsers/oba_reparsers.jl")
    include("Reparsers/reparsers.jl")
    
    #! include .
    include("utils.jl")

    MassExport.@exportall_non_underscore()

    function __init__()

        # register stuff
        _register_oba_childs()
        _register_obascript_promoter()

    end

end