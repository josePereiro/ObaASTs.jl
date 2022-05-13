## ------------------------------------------------------------------
# Extract Regex
# To extract from a src text (possible several lines)
const TAG_PARSE_REGEX                 = r"(?<src>\#(?<label>[A-Za-z_][A-Za-z0-9_/]*))"
const INTERNAL_LINK_PARSE_REGEX       = r"(?<src>\[\[(?<file>[^\|\#\n]*?)(?:\#(?<header>[^\|\n]*?))?(?:\|(?<alias>[^\n]*?))?\]\])"
const HEADER_LINE_PARSER_REGEX        = r"(?<src>(?<lvl>\#+)\h+(?<title>.*))"
const COMMENT_BLOCK_PARSER_REGEX      = r"(?<src>\h*\%{2}(?<txt>(?:.*\n?)*)\%{2}\h*)"
const LATEX_BLOCK_PARSER_REGEX        = r"(?<src>\h*\${2}(?<latex>(?:.*\n?)*)\${2}\h*)"
const LATEX_TAG_PARSE_REGEX           = r"(?<src>\\tag\{(?<label>\N+)\})"
const CODE_BLOCK_PARSER_REGEX         = r"(?<src>\h*`{3}\h*(?<lang>\N*)\n?(?<code>(?:\N*\n?)*)\n?`{3}\h*)"
const BLOCK_LINK_PARSER_REGEX         = r"(?<src>\^(?<link>[\-a-zA-Z0-9]+)\h*)\Z"

# Line Regex
# To match a single line element
const YAML_BLOCK_START_LINE_REGEX     = r"\A-{3}\Z"
const YAML_BLOCK_END_LINE_REGEX       = r"\A-{3}\Z"
const BLOCK_LINK_LINE_REGEX           = r"\A\^[\-a-zA-Z0-9]+\h*\Z"
const HEADER_LINE_REGEX               = r"\A\h*\#{1,}\h\N*\Z"
const COMMENT_BLOCK_INLINE_REGEX      = r"\A\h*\%{2}(?:(?!\%{2}).)*\%{2}\h*\Z"
const COMMENT_BLOCK_START_LINE_REGEX  = r"\A\h*\%{2}(?:(?!\%{2}).)*\Z"
const COMMENT_BLOCK_END_LINE_REGEX    = r"\A\h*(?:(?!\%{2}).)*\%{2}\h*\Z"
const CODE_BLOCK_INLINE_REGEX         = r"\A\h*`{3}(?:(?!`{3}).)*`{3}\h*\Z"
const CODE_BLOCK_START_LINE_REGEX     = r"\A\h*`{3}(?:(?!`{3}).)*\Z"
const CODE_BLOCK_END_LINE_REGEX       = r"\A\h*(?:(?!`{3}).)*`{3}\h*\Z"
const LATEX_BLOCK_INLINE_REGEX        = r"\A\h*\${2}(?:(?!\${2}).)*\${2}\h*\Z"
const LATEX_BLOCK_START_LINE_REGEX    = r"\A\h*\${2}(?:(?!\${2}).)*\Z"
const LATEX_BLOCK_END_LINE_REGEX      = r"\A\h*(?:(?!\${2}).)*\${2}\h*\Z"
const BLANK_LINE_REGEX                = r"\A\h*\Z"
