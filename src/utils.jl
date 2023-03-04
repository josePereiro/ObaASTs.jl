# ------------------------------------------------------------------
function _hasmatch(r::Regex, str::AbstractString) 
    m = match(r, str)
    return !isnothing(m)
end

# ------------------------------------------------------------------
function _get_match(rmatch::RegexMatch, ksym::Symbol, dflt = nothing) 
    cap = rmatch[ksym]
    return isnothing(cap) ? dflt : string(cap)
end

# ------------------------------------------------------------------
function _match_pos(rm::RegexMatch) 
    i0 = rm.offset
    i1 = i0 + length(rm.match) - 1
    return i0:i1
end

# ------------------------------------------------------------------
function _preview(str::AbstractString, hlim::Int)
    hlim = max(40, floor(Int, hlim * 0.8))
    str = (length(str) <= hlim) ? str : string(first(str, hlim), "...")
    return escape_string(str)
end
_preview(io::IO, str::AbstractString) = _preview(str, displaysize(io)[2])

# ------------------------------------------------------------------
function _show_data_preview(f::Function, io::IO, col)
    vlim = max(20, displaysize(io)[1])
    for (i, dat) in enumerate(col)

        if i == vlim
            print(io, "\n[...]")
            break
        end

        ret = f(i, dat)
        ret === false && continue
        print(io, "\n", _preview(io, string(ret)))
    end
end

