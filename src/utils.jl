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
function _preview(io::IO, str, hlim = displaysize(io)[2])
    hlim = max(40, floor(Int, hlim * 0.8))
    (length(str) <= hlim) ? escape_string(str) : escape_string(SubString(str, 1, hlim), "...")
end

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

