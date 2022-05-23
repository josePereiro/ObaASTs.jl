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
    
    global AST = parse_file(fn)
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

    # TODO: Test individual childs
    

end
