
## ------------------------------------------------------------------
# Abstracts
abstract type AbstractObaAST end
abstract type AbstractObaASTBlock <: AbstractObaAST end
abstract type AbstractObaASTLine <: AbstractObaAST end
abstract type AbstractObaASTObj <: AbstractObaAST end

join_src(ast::AbstractObaAST, args...) = error("method join_src(", typeof(ast), ") not defined")
join_src(ast::AbstractObaASTBlock, args...) = join(ast.src, args...)
join_src(ast::AbstractObaASTLine, args...) = ast.src
join_src(ast::AbstractObaASTObj, args...) = ast.src

function Base.show(io::IO, ast:: AbstractObaAST)
    print(io, nameof(typeof(ast)), " \"", _preview(io, join_src(ast, "\\n")), "\"")
end


## ------------------------------------------------------------------
# ObaAST
struct ObaAST
    childs::Vector{AbstractObaAST}
end

Base.length(ast::ObaAST) = length(ast.childs)
Base.size(ast::ObaAST) = size(ast.childs)
Base.getindex(ast::ObaAST, key) = getindex(ast.childs, key)
Base.setindex!(ast::ObaAST, obj::AbstractObaAST, key) = setindex!(ast.childs, obj, key)
Base.iterate(ast::ObaAST) = iterate(ast.childs)
Base.iterate(ast::ObaAST, state) = iterate(ast.childs, state)
Base.push!(ast::ObaAST, obj::AbstractObaAST) = push!(ast.childs, obj)
Base.firstindex(ast::ObaAST) = firstindex(ast.childs)
Base.lastindex(ast::ObaAST) = lastindex(ast.childs)

function Base.show(io::IO, ast::ObaAST)

    nchilds = length(ast)
    print(io, "ObaAST with ", nchilds, " child(s)")

    # data
    if nchilds > 0
        print(io, "\nchild(s):")
        _show_data_preview(io, ast) do child
            child isa EmptyLineAST && return false # ignore empty
            print(io, "\n[", child.line, "] ")
            show(io, child)
            return false
        end
    end

    return nothing
end

## ------------------------------------------------------------------
# InternalLinkAST
mutable struct InternalLinkAST <: AbstractObaASTObj
    parent::AbstractObaASTLine
    pos::UnitRange{Int64}
    src::String
    file::String
    header::Union{String, Nothing}
    alias::Union{String, Nothing}
end

## ------------------------------------------------------------------
# TagAST
mutable struct TagAST <: AbstractObaASTObj
    parent::AbstractObaASTLine
    pos::UnitRange{Int64}
    src::String
    labels::Vector{String}
end


## ------------------------------------------------------------------
# TextLineAST
mutable struct TextLineAST <: AbstractObaASTLine
    parent::ObaAST
    line::Int
    src::String
    inlinks::Vector{InternalLinkAST}
    tags::Vector{TagAST}
end

## ------------------------------------------------------------------
# EmptyLineAST
mutable struct EmptyLineAST <: AbstractObaASTLine
    parent::ObaAST
    line::Int
    src::String
end

## ------------------------------------------------------------------
# HeaderLineAST
mutable struct HeaderLineAST <: AbstractObaASTLine
    parent::ObaAST
    line::Int
    src::String
    title::String
    lvl::Int
end

## ------------------------------------------------------------------
# CommentBlockAST
mutable struct CommentBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    txt::String
end

## ------------------------------------------------------------------
# LatexTagAST
mutable struct LatexTagAST <: AbstractObaASTObj
    parent::AbstractObaASTBlock
    pos::UnitRange{Int64}
    src::String
    label::String
end

## ------------------------------------------------------------------
# LatexBlockAST
mutable struct LatexBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    txt::String
    tag::Union{LatexTagAST, Nothing}
end

## ------------------------------------------------------------------
# CodeBlockAST
mutable struct CodeBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    lang::Union{String, Nothing}
    code::String
end

## ------------------------------------------------------------------
# YamlBlockAST
mutable struct YamlBlockAST <: AbstractObaASTBlock
    parent::ObaAST
    line::Int
    src::Vector{String}
    dat::Dict{String, Any}
end
