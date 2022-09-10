# Line Regex
# To match a single line element
const YAML_BLOCK_START_LINE_REGEX        = r"\A-{3}\Z"
const YAML_BLOCK_END_LINE_REGEX          = r"\A-{3}\Z"

const BLOCK_LINK_LINE_REGEX              = r"\A\^[\-a-zA-Z0-9]+\h*\Z"

const HEADER_LINE_REGEX                  = r"\A\#{1,}(?:(?:\h*)|(?:\h+\N*))\Z"

const COMMENT_BLOCK_INLINE_REGEX         = r"\A\h*\%{2}(?:(?!\%{2}).)*\%{2}\h*\Z"
const COMMENT_BLOCK_START_LINE_REGEX     = r"\A\h*\%{2}(?:(?!\%{2}).)*\Z"
const COMMENT_BLOCK_END_LINE_REGEX       = r"\A\h*(?:(?!\%{2}).)*\%{2}\h*\Z"

const OBA_SCRIPT_BLOCK_START_LINE_REGEX  = r"\A\h*\%{2}\h*\#\!Oba(?:(?!\%{2}).)*\Z"
const OBA_SCRIPT_BLOCK_END_LINE_REGEX    = r"\A\h*(?:(?!\%{2}).)*\%{2}\h*\Z"

const OBA_SCRIPT_HEAD_LONG_FLAG_REGEX    = r"(?<src>\-\-(?<key>\w+(?:\-\w+)*)(?:\=(?<value>(?:\w+)|(?:\'[^\']*\')|(?:\"[^\"]*\")))?(?:\h|\n|\Z))"
const OBA_SCRIPT_HEAD_SHORT_FLAG_REGEX   = r"(?<src>\h\-(?<flags>[a-zA-Z]+)(?:\h|\n|\Z))"

const CODE_BLOCK_INLINE_REGEX            = r"\A\h*`{3}(?:(?!`{3}).)*`{3}\h*\Z"
const CODE_BLOCK_START_LINE_REGEX        = r"\A\h*`{3}(?:(?!`{3}).)*\Z"
const CODE_BLOCK_END_LINE_REGEX          = r"\A\h*(?:(?!`{3}).)*`{3}\h*\Z"

const LATEX_BLOCK_INLINE_REGEX           = r"\A\h*\${2}(?:(?!\${2}).)*\${2}\h*\Z"
const LATEX_BLOCK_START_LINE_REGEX       = r"\A\h*\${2}(?:(?!\${2}).)*\Z"
const LATEX_BLOCK_END_LINE_REGEX         = r"\A\h*(?:(?!\${2}).)*\${2}\h*\Z"

const BLANK_LINE_REGEX                   = r"\A\h*\Z"

# ------------------------------------------------------------------
# Types and Scope
const GLOBAL_SCOPE = :GLOBAL
const YAML_BLOCK = :YAML_BLOCK
const COMMENT_BLOCK = :COMMENT_BLOCK
const OBA_SCRIPT_BLOCK = :OBA_SCRIPT_BLOCK
const LATEX_BLOCK = :LATEX_BLOCK
const CODE_BLOCK = :CODE_BLOCK