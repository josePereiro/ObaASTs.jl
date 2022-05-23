
## ------------------------------------------------------------------
# Abstracts
abstract type AbstractObaAST end
abstract type AbstractObaASTChild <: AbstractObaAST end
abstract type AbstractObaASTObj <: AbstractObaAST end

## ------------------------------------------------------------------
# AbstractObaASTChild help macro

"""
    Generate a AbstractObaASTChild object subtype
"""
macro ObaASTChild(name)
    isdefined(Main, name) && return :(nothing)
    return quote
        mutable struct $(name) <: AbstractObaASTChild
            # source meta
            parent::ObaAST
            src::String
            line::Int
            # parsed
            parsed::Dict{Symbol, Any}

            # Constructor
            function $(esc(name))(
                    parent::ObaAST, 
                    src::String, 
                    line::Int, 
                    parsed::Dict{Symbol, Any} = Dict{Symbol, Any}()
                )
                obj = new(parent, src, line, parsed)
            end

        end
 
    end # quote
end

## ------------------------------------------------------------------
# AbstractObaASTObj help macro
"""
    Generate a AbstractObaASTObj object subtype
"""
macro ObaASTObj(name)
    isdefined(Main, name) && return :(nothing)
    return quote
        mutable struct $(name) <: AbstractObaASTObj
            # source meta
            parent::AbstractObaASTChild
            src::String
            pos::UnitRange{Int}
            # parsed
            parsed::Dict{Symbol, Any}

            # Constructor
            function $(esc(name))(
                    parent::AbstractObaASTChild, 
                    src::String, 
                    pos::UnitRange{Int}, 
                    parsed::Dict{Symbol, Any} = Dict{Symbol, Any}()
                )
                obj = new(parent, src, pos, parsed)
            end

        end
 
    end # quote
end

## ------------------------------------------------------------------
# ObaAST
mutable struct ObaAST <: AbstractObaAST
    file::Union{String, Nothing}
    children::Vector{AbstractObaASTChild}
end

## ------------------------------------------------------------------
# Children
@ObaASTChild TextLineAST
@ObaASTChild BlockLinkLineAST
@ObaASTChild EmptyLineAST
@ObaASTChild HeaderLineAST
@ObaASTChild CommentBlockAST
@ObaASTChild ObaScriptBlockAST
@ObaASTChild LatexBlockAST
@ObaASTChild CodeBlockAST
@ObaASTChild YamlBlockAST

## ------------------------------------------------------------------
# Objects
@ObaASTObj InternalLinkAST
@ObaASTObj TagAST
@ObaASTObj LatexTagAST

