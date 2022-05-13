# ------------------------------------------------------------------
_has_match(reg::Regex, str::AbstractString) = !isnothing(match(reg, str))

function _match_dict(rmatch::RegexMatch)
    mdict = Dict{String, String}()
    for kstr in keys(rmatch)
        ksym = Symbol(kstr)
        str = rmatch[ksym]
        mdict[kstr] = isnothing(str) ? "" : str
    end
    return mdict
end

_match_dict(::Nothing) = Dict{Symbol, String}()

function _match_dict(reg::Regex, str::AbstractString)
    rmatch = match(reg, str)
    return _match_dict(rmatch)
end

# ------------------------------------------------------------------
function _eachmatch_plus_range(f::Function, reg::Regex, str::String)
    for rm in eachmatch(reg, str)
        i0 = rm.offset
        i1 = i0 + length(rm.match) - 1
        f(i0:i1, rm)
    end
end

# ------------------------------------------------------------------
function _extract_matches(reg::Regex, str::AbstractString)
    matchs = Dict{String, String}[]
    for rm in eachmatch(reg, str)
        mdict = _match_dict(rm)
        push!(matchs, mdict)
    end
    return unique!(matchs)
end

# ------------------------------------------------------------------
function _preview(io::IO, str, hlim = displaysize(io)[2])
    hlim = max(40, floor(Int, hlim * 0.8))
    (length(str) <= hlim) ? str : string(SubString(str, 1, hlim), "...")
end

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

