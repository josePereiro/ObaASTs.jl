
## ------------------------------------------------------------------
# Abstracts
abstract type AbstractObaAST end
abstract type AbstractObaASTBlock <: AbstractObaAST end
abstract type AbstractObaASTLine <: AbstractObaAST end
abstract type AbstractObaASTObj <: AbstractObaAST end

## ------------------------------------------------------------------
## ObaAST
struct ObaAST
    asts::Vector{AbstractObaAST}
end

Base.push!(ast::ObaAST, obj::AbstractObaAST) = push!(ast.asts, obj)

## ------------------------------------------------------------------
mutable struct InternalLinkAST <: AbstractObaASTObj
    parent::AbstractObaASTLine
    pos::UnitRange{Int64}
    src::String
    file::String
    header::Union{String, Nothing}
    alias::Union{String, Nothing}
end

## ------------------------------------------------------------------
mutable struct TagAST <: AbstractObaASTObj
    parent::AbstractObaASTLine
    pos::UnitRange{Int64}
    src::String
    labels::Vector{String}
end

## ------------------------------------------------------------------
## TextLineAST
mutable struct TextLineAST <: AbstractObaASTLine
    parent::ObaAST
    line::Int
    src::String
    internal_links::Vector{InternalLinkAST}
    tags::Vector{TagAST}
end

## ------------------------------------------------------------------
## HeaderLineAST
mutable struct EmptyLineAST <: AbstractObaASTLine
    parent::ObaAST
    line::Int
    src::String
end

## ------------------------------------------------------------------
## HeaderLineAST
mutable struct HeaderLineAST <: AbstractObaASTLine
    parent::ObaAST
    line::Int
    src::String
    txt::String
    lvl::Int
end

## ------------------------------------------------------------------
mutable struct CommentBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    txt::String
end

## ------------------------------------------------------------------
mutable struct LatexTagAST <: AbstractObaASTObj
    parent::AbstractObaASTBlock
    pos::UnitRange{Int64}
    src::String
    label::String
end

## ------------------------------------------------------------------
mutable struct LatexBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    txt::String
    tag::Union{LatexTagAST, Nothing}
end

## ------------------------------------------------------------------
mutable struct CodeBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    lang::Union{String, Nothing}
    code::String
end

## ------------------------------------------------------------------
mutable struct YamlBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    dat::Dict{String, Any}
end
