using ObaASTs
using Test

@testset "ObaASTs.jl" begin

    # test file
    fn = joinpath(@__DIR__, "test_file.txt")
    # keep this sync with file
    file_content_types = [
        YamlBlockAST, EmptyLineAST, HeaderLineAST, EmptyLineAST, TextLineAST, EmptyLineAST, HeaderLineAST, EmptyLineAST, CommentBlockAST, EmptyLineAST, LatexBlockAST, EmptyLineAST, LatexBlockAST, EmptyLineAST, CodeBlockAST, EmptyLineAST, TextLineAST, EmptyLineAST, TextLineAST
    ]
    
    AST = parse_file(fn)
    @test true # no error

    # Test AST
    @test length(AST) == length(file_content_types)
    for (child, test_type) in zip(AST, file_content_types)
        @test child isa test_type
    end

end
