
## ------------------------------------------------------------------
# Abstracts
abstract type AbstractObaAST end
abstract type AbstractObaASTChild <: AbstractObaAST end
abstract type AbstractObaASTObj <: AbstractObaAST end

function Base.show(io::IO, ast:: AbstractObaAST)
    print(io, nameof(typeof(ast)), " \"", _preview(io, source(ast, "\\n")), "\"")
end


## ------------------------------------------------------------------
# ObaAST
mutable struct ObaAST
    file::Union{String, Nothing}
    childs::Vector{AbstractObaASTChild}
end

Base.length(ast::ObaAST) = length(ast.childs)
Base.size(ast::ObaAST, args...) = size(ast.childs, args...)
Base.getindex(ast::ObaAST, key) = getindex(ast.childs, key)
Base.setindex!(ast::ObaAST, obj::AbstractObaASTChild, key) = setindex!(ast.childs, obj, key)
Base.iterate(ast::ObaAST) = iterate(ast.childs)
Base.iterate(ast::ObaAST, state) = iterate(ast.childs, state)
Base.push!(ast::ObaAST, obj::AbstractObaASTChild) = push!(ast.childs, obj)
Base.firstindex(ast::ObaAST) = firstindex(ast.childs)
Base.lastindex(ast::ObaAST) = lastindex(ast.childs)
Base.pairs(ast::ObaAST) = pairs(ast.childs)

function Base.show(io::IO, ast::ObaAST)

    nchilds = length(ast)
    print(io, "ObaAST with ", nchilds, " child(s)")

    # data
    if nchilds > 0
        print(io, "\nchild(s):")
        _show_data_preview(io, ast) do chidx, child
            child isa EmptyLineAST && return false # ignore empty
            print(io, "\n[", chidx, "] ")
            show(io, child)
            return false
        end
    end

    return nothing
end

## ------------------------------------------------------------------
# InternalLinkAST
struct InternalLinkAST <: AbstractObaASTObj
    # source meta
    parent::AbstractObaASTChild
    src::String
    pos::UnitRange{Int}
    # parsed
    file::Union{String, Nothing}
    header::Union{String, Nothing}
    alias::Union{String, Nothing}
end

## ------------------------------------------------------------------
# TagAST
struct TagAST <: AbstractObaASTObj
    # source meta
    parent::AbstractObaASTChild
    src::String
    pos::UnitRange{Int}
    # parsed
    label::String
end

## ------------------------------------------------------------------
# TextLineAST
mutable struct TextLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    inlinks::Vector{InternalLinkAST}
    tags::Vector{TagAST}
end

## ------------------------------------------------------------------
# BlockLinkLineAST
mutable struct BlockLinkLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    link::String
end

## ------------------------------------------------------------------
# EmptyLineAST
mutable struct EmptyLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
end

## ------------------------------------------------------------------
# HeaderLineAST
mutable struct HeaderLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    title::String
    lvl::Int
end

## ------------------------------------------------------------------
# CommentBlockAST
mutable struct CommentBlockAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    body::String
end

## ------------------------------------------------------------------
# LatexTagAST
struct LatexTagAST <: AbstractObaASTObj
    # source meta
    parent::AbstractObaASTChild
    src::String
    pos::UnitRange{Int}
    # parsed
    label::String
end

## ------------------------------------------------------------------
# LatexBlockAST
mutable struct LatexBlockAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    body::String
    tag::Union{LatexTagAST, Nothing}
end

## ------------------------------------------------------------------
# CodeBlockAST
mutable struct CodeBlockAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    lang::String
    body::String
end

## ------------------------------------------------------------------
# YamlBlockAST
mutable struct YamlBlockAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST
    src::String
    line::Int
    # parsed
    dict::Dict{String, Any}
end
