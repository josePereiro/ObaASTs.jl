# ObaASTs

[![Build Status](https://github.com/josePereiro/ObaASTs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/josePereiro/ObaASTs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/josePereiro/ObaASTs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/josePereiro/ObaASTs.jl)

A restricted parser for [Obsidian.md](https://obsidian.md/) files. It assumes a per-line compatible file, but Obsidian is more flexible.
The main restriction is that all 'children' elements must be defined within lines which contains no part of other 'child' elements. 

> **Note**: This same document is fully parsable.

> **Note**: At the time of writing, the parser is working with all the notes (> 500) in my vault with `Obsidian v0.14.6`

--- 
### Install

```julia
] registry add https://github.com/josePereiro/Pereiro_Registry.jl
] add ObaASTs
```

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

**Oba type**: `CommentBlockAST`
- `.parsed` keys: 
    - `:body` The comment text without `%%`s


#### Latex block
```txt
$$ single line block $$

$$
multiline block
$$
```

**Oba type**: `LatexBlockAST`,  
- `.parsed` keys: 
    - `:body` The latex code betwwen `$$`s
    - `:tag` Parse `\tag{eq-1}` statements


#### Code block

````txt

```julia
println("Hello Oba")
```

````

**Oba type**: `CodeBlockAST`,  
- `.parsed` keys: 
    - `:lang` The language name
    - `:body` Everything between ``` except the language


#### Yaml Block

```yaml
---
basic-note-template: v0.2.0
creation-date: "2022:03:16-03:35:58"
sr-due: 2022-07-26
sr-interval: 80
sr-ease: 250
TAGS: ["#TODO"]
---
```

**Oba type**: `YamlBlockAST`,  
- `.parsed` keys: 
    - `:yaml` the parsed yaml
    - `:tags` special section for tags


#### Header line

```

# This is a top header

```

**Oba type**: `HeaderLineAST`,  
- `.parsed` keys: 
    - `:title` The text after the `#`(s)
    - `:lvl` special section for tags

#### Bock link line

> **Note:** `Obsidian` allows placing such links either at the end of a line or in the next one. The former is ignored and the latter is the one supporter for the parser. 

```txt
Some text in the line above the link.
^any-id-123
```


**Oba type**: `BlockLinkLineAST`,  
- `.parsed` keys: 
    - `:label` The link id

#### Text line

```txt
A single line of text, including [[links]], $inline latex$ and #tags
```

**Oba type**: `TextLineAST`,  
- `.parsed` keys: 
    - `:wikilinks` found wikilinks
    - `:tags` found tags
    - `:latex` found inline latex (TODO)
    - `:highlights` found highlights expressions (TODO)

#### Empty line

Just an empty line

**Oba type**: `EmptyLineAST`


---

### ObaASTs vs Obsidian

All the follow examples are allowed in `Obsidian` but not necessarily parsable by `ObaASTs`.

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

**Not Allowed**
```txt
Text line ^blockid
```

All highlights or formating of text (**bold**, _italic_, etc) must occur in the same line.

**Allowed**

```txt
Text ==line== 
Text *line* 
Text _line_ 
```

**Not Allowed**
```txt
Text ==line
Text line
Text line==
Text line
```

## Usage

### ObaAST

The package export several parser methods `parse_lines`, `parse_file`, `parse_string`.

```julia
using ObaASTs

# parse a file
fn = abspath(joinpath(pathof(ObaASTs), "../..", "test", "test_file.md"))
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
AST[3][:lvl]
# 1
AST[3].src = "### Now you are level 3"
# "### Now you are level 3"
AST[3][:lvl]
# 1 <------ (NOTE: this is wrong!)
reparse!(AST[3])
# HeaderLineAST "### Now you are level 3"
AST[3][:lvl]
# 3
```

> **WARNING:** `reparse!` over a child will try to parse the new src conserving the type. It might fail, either loudly or quietly. To get a real re-parsing, `reparse!` the whole `ObaAST`. It will redo all the child's from scratch.

```julia
AST[5]
# TextLineAST "A line of text"

AST[5].src = "# Now a header, not a simple text line"
# "# Now a header, not a simple text line"

reparse!(AST[5])
# TextLineAST "# Now a header, not a simple text line" <------ (NOTE: this is wrong! It shouldn't be a TextLineAST)

reparse!(AST)
# ObaAST with 21 child(s)
# child(s):
# [1] YamlBlockAST "---\nBla: [\"Ble\", \"Bli\", \"Blu\"]\nBli: \"1213-1212312-312\"\nBlo: 12\n---"
# [3] HeaderLineAST "### Now you are level 3"
# [5] HeaderLineAST "# Now a header, not a simple text line" <------ (NOTE: Now is ok)
# [7] HeaderLineAST "## This is a level 2 header"
# [9] CommentBlockAST "%%julia\nprintln(\"Hi\")\n%%"
# [11] LatexBlockAST "$$ Inline $$"
# [13] LatexBlockAST "$$ \n\\tag{this-is-a-tag}\nMultiline\nMultiline\nMultiline\n$$"
# [15] CodeBlockAST "```julia\nprintln(\"Hi\")\n```"
# [17] TextLineAST "This is just text with a link [[file#header|alias]] [[file#header|alias]] and a #Tag."
# [19] TextLineAST "You can also link to specific headers in files\. Start typing a link like you would normally\. When the note you want is h"
# [...]
```

### resource!

A more secure interface for modifying `src`. It call `reparse!` automatically.
It can be called on a child or the whole ast. 

```julia
AST[3]
# HeaderLineAST "# This is a level 1 header"
source(AST[3])
# "# This is a level 1 header"
AST[3][:lvl]
# 1
resource!(AST[3], "### Now you are level 3")
# HeaderLineAST "### Now you are level 3"
AST[3][:lvl]
# 3 
```

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
