
## ------------------------------------------------------------------
# Abstracts
abstract type AbstractObaAST end
abstract type AbstractObaASTChild <: AbstractObaAST end
abstract type AbstractObaASTObj <: AbstractObaAST end

## ------------------------------------------------------------------
# ObaAST
mutable struct ObaAST <: AbstractObaAST
    file::Union{String, Nothing}
    childs::Vector{AbstractObaASTChild}
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
