using ObaASTs
using Test

## ------------------------------------------------------------------
@testset "ObaASTs.jl" begin

    # test file
    fn = joinpath(@__DIR__, "test_file.md")
    # keep this sync with test file
    file_content_types = [
        YamlBlockAST, EmptyLineAST, HeaderLineAST, EmptyLineAST, TextLineAST, EmptyLineAST, HeaderLineAST, EmptyLineAST, CommentBlockAST, EmptyLineAST, ObaScriptBlockAST, EmptyLineAST, LatexBlockAST, EmptyLineAST, LatexBlockAST, EmptyLineAST, CodeBlockAST, EmptyLineAST, ObaScriptBlockAST, EmptyLineAST, TextLineAST, EmptyLineAST, TextLineAST, EmptyLineAST, BlockLinkLineAST
    ]
    
    AST = parse_file(fn)
    file0 = source_file(AST)
    @test true # no error
    @test file0 == fn

    # Test AST parsing
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
    # test parent stability
    AST0 = deepcopy(AST)
    for ch in AST0
        @test objectid(AST0) === objectid(parent_ast(ch))
    end
    reparse!(AST0)
    for ch in AST0
        @test objectid(AST0) === objectid(parent_ast(ch))
    end

    for (i, (ch, ch0)) in enumerate(zip(AST, AST0))
        # @info("Testing line $(ch.line): $(typeof(ch))")
        @test typeof(ch) === typeof(ch0)
        @test ch.line == ch0.line
        @test ch.src == ch0.src
    end

    # full reparse
    @test source(parse_string(source(AST))) == source(AST)

    # test modification
    len0 = length(AST0)
    tlAST = findfirst((ch) -> isa(ch, TextLineAST), AST0)
    @assert !isnothing(tlAST)
    AST0[tlAST].src = "Text line with two\nlines"
    @test len0 == length(AST0)
    reparse!(AST0)
    @test len0 + 1 == length(AST0)
    for ch in AST0
        @test objectid(AST0) === objectid(parent_ast(ch))
    end
    
    # resource!
    tlAST = findfirst((ch) -> isa(ch, TextLineAST), AST0)
    @assert !isnothing(tlAST) 
    resource!(AST0[tlAST], "Text line with two\nlines")
    @test file0 == source_file(AST0)
    @test len0 + 2 == length(AST0)
    for ch in AST0
        @test objectid(AST0) === objectid(parent_ast(ch))
    end

    # TODO: Test individual children parsed labels
    # Use 'parse_string("A text [[wikilink]] #tag \$1+1\$")[1].parsed'
    # test cases
    
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
