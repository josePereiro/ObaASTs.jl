# ObaASTs

[![Build Status](https://github.com/josePereiro/ObaASTs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/josePereiro/ObaASTs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/josePereiro/ObaASTs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/josePereiro/ObaASTs.jl)

A restricted parser for [Obsidian.md](https://obsidian.md/) files. It assumes a per-line compatible file, but Obsidian is more flexible.
The main restriction is that all 'children' elements must be defined within lines which contains no part of other 'child' elements. 

> **Note**: This same document is fully parsable.

--- 
### Children
#### Command block

**Syntax**: 
```txt
%% single line block %%

%%
multiline block
%%
```

**Oba type**: 
```julia
mutable struct CommentBlockAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST # The parent AST
    src::String # The source code
    line::Int # The line number
    # parsed
    body::String # Everything between both %%
end
```

#### Latex block
```txt
$$ single line block $$

$$
multiline block
$$
```

**Oba type**: 
```julia
mutable struct LatexBlockAST <: AbstractObaASTChild
	# source meta
	parent::ObaAST # The parent AST
	src::String # The source code
	line::Int # The line number
	# parsed
	body::String # Everything between $$
	tag::Union{LatexTagAST, Nothing} # A parsed \tag{ider} element
end
```

#### Code block

````txt

```[lang]
Code
```

````


**Oba type**: 
```julia
mutable struct CodeBlockAST <: AbstractObaASTChild
# source meta
	parent::ObaAST # The parent AST
	src::String # The source code
	line::Int # The line number
	# parsed
	lang::String # The language name
	body::String # Everything between ``` except the language
end
```


#### Yaml Block

```yaml
---
basic-note-template: v0.2.0
creation-date: "2022:03:16-03:35:58"
sr-due: 2022-07-26
sr-interval: 80
sr-ease: 250
---
```

**Oba type**: 
```julia
mutable struct YamlBlockAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST # The parent AST
	src::String # The source code
	line::Int # The line number
    # parsed
    dict::Dict{String, Any} # the parsed yaml
end
```


#### Header line

```

# This is a top header

```


**Oba type**: 
```julia
mutable struct HeaderLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST # The parent AST
	src::String # The source code
	line::Int # The line number
    # parsed
    title::String # The text after the #(s)
    lvl::Int # The number of #(s)
end
```

#### Bock link line

> **Note:** `Obsidian` allows placing such links either at the end of a line or in the next one. The former is ignored and the latter is the one supporter for the parser. 

```txt
^any-id-123
```

**Oba type**: 
```julia
mutable struct BlockLinkLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST # The parent AST
	src::String # The source code
	line::Int # The line number
    # parsed
    link::String # the link id
end
```


#### Text line

```txt
A single line of text, including [[links]], $inline latex$ and #tags
```

```julia
juliamutable struct TextLineAST <: AbstractObaASTChild
    # source meta
    parent::ObaAST # The parent AST
	src::String # The source code
	line::Int # The line number
    # parsed
    inlinks::Vector{InternalLinkAST} # the internal links 
    tags::Vector{TagAST} # the tags
end
```

#### Empty line

Just an empty line

---

### ObaASTs vs Obsidian

All the follow examples are allowed in `Obsidian` but not necessarily in `ObaASTs`.

**Allowed**
```txt
Text line
$$
1+1
$$
or text
$$ 1+1 $$
and more text
```

**Not Allowed**
```txt
Text line $$ Multiline latex block $$ more text
```

Similar with yaml, comment and code blocks.


**Allowed**

```txt
Text line 
^blockid
```

**Allowed**
```txt
Text line ^blockid
```

## Usage

### ObaAST

The package export several parser methods `parse_lines`, `parse_file`, `parse_string`.

```julia
using ObaASTs

# parse a file
fn = abspath(joinpath(pathof(ObaASTs), "../..", "test", "test_file.txt"))
AST = parse_file(fn)
# ObaAST with 21 child(s)
# child(s):
# [1] YamlBlockAST "---\nBla: [\"Ble\", \"Bli\", \"Blu\"]\nBli: \"1213-1212312-312\"\nBlo: 12\n---"
# [3] HeaderLineAST "# This is a level 1 header"
# [5] TextLineAST "A line of text"
# [7] HeaderLineAST "## This is a level 2 header"
# [9] CommentBlockAST "%%julia\nprintln(\"Hi\")\n%%"
# [11] LatexBlockAST "$$ Inline $$"
# [13] LatexBlockAST "$$ \n\\tag{this-is-a-tag}\nMultiline\nMultiline\nMultiline\n$$"
# [15] CodeBlockAST "```julia\nprintln(\"Hi\")\n```"
# [17] TextLineAST "This is just text with a link [[file#header|alias]] [[file#header|alias]] and a #Tag."
# [19] TextLineAST "You can also link to specific headers in files\. Start typing a link like you would normally\. When the note you want is h"
# [...]
```

The `ObaAST` implements the required methods of the `Iteration` and `Array` interfaces.

```julia
AST[1:3]
# 3-element Vector{AbstractObaASTChild}:
#  YamlBlockAST "---\nBla: ["Ble", "Bli", "Blu"]\nBli: "1213-1212312-312"\nBlo: 12\n-"
#  EmptyLineAST ""
#  HeaderLineAST "# This is a level 1 header"
```

### reparse!
To modify any child AST overwrite the `src::String` field and `reparse!` it.

```julia
AST[3]
# HeaderLineAST "# This is a level 1 header"
AST[3].src
# "# This is a level 1 header"
AST[3].lvl
# 1
AST[3].src = "### Now you are level 3"
# "### Now you are level 3"
AST[3].lvl
# 1
reparse!(AST[3])
# HeaderLineAST "### Now you are level 3"
AST[3].lvl
# 3
```

> **WARNING:** `reparse!` over a child will try to parse the new src conserving the type. It might fail, either loudly or quietly. To get a real re-parsing, `reparse!` the whole `ObaAST`. It will redo all the child's from scratch.

### source
The function `source` will return the `src` field in each child object and the correct combination of them for the full `ObaAST`. It can be used to create a new document after modification and `reparse!`.

```julia
source(AST[1]) == AST[1].src
# true

source(AST)
# "---\nBla: [\"Ble\", \"Bli\", \"Blu\"]\nBli: \"1213-1212312-312\"\nBlo: 12\n---\n\n# This is a level 1 header\n\nA line of text\n\n## This is a level 2 header\n\n%%julia\nprintln(\"Hi\")\n%%\n\n\$\$ Inline \$\$\n\n\$\$ \n\\tag{this-is-a-tag}\nMultiline\nMultiline\nMultiline\n\$\$\n\n```julia\nprintln(\"Hi\")\n```\n\nThis is just text with a link [[file#header|alias]] [[file#header|alias]] and a #Tag.\n\nYou can also link to specific headers in files. Start typing a link like you would normally. When the note you want is highlighted, press # instead of Enter and you'll see a list of headings in that file. Continue typing or navigate with arrow keys as before, press #again at each subheading you want to add, and Enter to complete the link. To make the link display different text than its real note name in Preview, use the vertical pipe (Shift+|) For example: Custom Link Name in Preview! This can be combined with linking to headers, as in Example of Folding.\n\n^blockid"
```


## TODO
- [ ] Improve documentation
- [ ] Add support for inline latex
- [ ] Add support for external link
- [ ] Add support for raw url
- [ ] Add more utils
- [ ] Add more error catching