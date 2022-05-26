using ObaASTs
using Test

## ------------------------------------------------------------------
@testset "ObaASTs.jl" begin

    # test file
    fn = joinpath(@__DIR__, "test_file.txt")
    # keep this sync with file
    file_content_types = [
        YamlBlockAST, EmptyLineAST, HeaderLineAST, EmptyLineAST, TextLineAST, EmptyLineAST, HeaderLineAST, EmptyLineAST, CommentBlockAST, EmptyLineAST, ObaScriptBlockAST, EmptyLineAST, LatexBlockAST, EmptyLineAST, LatexBlockAST, EmptyLineAST, CodeBlockAST, EmptyLineAST, TextLineAST, EmptyLineAST, TextLineAST, EmptyLineAST, BlockLinkLineAST
    ]
    
    AST = parse_file(fn)
    @test true # no error

    # Test AST
    @test length(AST) == length(file_content_types)
    for (child, test_type) in zip(AST, file_content_types)
        @test child isa test_type
    end

    # Test the line numbers
    ref_lines = readlines(fn)
    for child in AST
        ref_src = ref_lines[child.line]
        @test startswith(source(child), ref_src)
    end

    # test reparse!
    AST0 = deepcopy(AST)
    reparse!(AST0)
    for (ch, ch0) in zip(AST, AST0)
        @test typeof(ch) === typeof(ch0)
        @test ch.line == ch.line
        @test ch.src == ch.src
    end

    # test modification
    len0 = length(AST0)
    tlAST = findfirst((ch) -> isa(ch, TextLineAST), AST0)
    @assert !isnothing(tlAST)
    AST0[tlAST].src = "Text line with two\nlines"
    @assert len0 == length(AST0)
    reparse!(AST0)
    @assert len0 + 1 == length(AST0)

    # TODO: Test individual children
    
    # Utils
    # child_idx
    for (i, ch) in enumerate(AST)
        @test ObaASTs.child_idx(AST[i]) == i
    end

    # iter_from
    # down
    for offset in -2:2, step in -1:1, idx0 in eachindex(AST)
        iszero(step) && continue
        
        # Avoid index error
        firstindex(AST) <= idx0 + offset <= lastindex(AST) || continue
            
        c = 0
        iter_from(AST[idx0], step, offset) do i, ch
            c+=1
        end
        
        if step > 0
            # down
            @test length(AST) == c + ((idx0 + offset) - 1)
        elseif step < 0
            # down
            @test c == (idx0 + offset)
        end
    end

    # ObaScriptBlockAST utils
    script_ast_idx = findfirst((ch) -> ch isa ObaScriptBlockAST, AST)
    script_ast = AST[script_ast_idx]
    lflags = get_params(script_ast)
    @test !isnothing(lflags)
    @test lflags["key"] == "value"
    @test hasparam(script_ast, "key")

    sflags = get_flags(script_ast)
    @test sflags == "flags"
    @test all(hasflag.([script_ast], "flags"))

end
