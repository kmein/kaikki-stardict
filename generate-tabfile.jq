# vi: ft=jq
# one pyglossary tabfile line per wiktextract entry: "headword|alternative…<TAB>xdxf article"
# sdcv strips the xdxf tags (colouring b, i, abr, ex with --color) and decodes only &lt; &gt; &amp; &quot; &apos;

def distinct: reduce .[] as $x ([]; if index([$x]) then . else . + [$x] end);
def esc: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;") | gsub("\t"; " ");
def term: gsub("[\t\n]"; " ") | gsub("\\\\"; "\\\\") | gsub("\\|"; "\\|");
# romanizations (persian's and hebrew's, mostly) mark stress with an acute that nobody types,
# also on top of another diacritic: precomposed (ấ) or combining (ā́)
def unstressed:
  gsub("\u0301"; "")
  | gsub("(?<v>[áéíóúÁÉÍÓÚấếḗốṓ])"; {"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U", "ấ": "â", "ế": "ê", "ḗ": "ē", "ố": "ô", "ṓ": "ō"}[.v]);
# no-break spaces survive html renderers that collapse ordinary ones
def indent($depth): [range($depth) | "\u00a0\u00a0"] | join("");

def descendant($depth):
  ( [ (.lang // empty | esc + ":"),
      (.word // empty | esc),
      ([.roman // empty, (.sense // empty | "“\(.)”")] | select(length > 0) | "(\(map(esc) | join(", ")))"),
      ((.raw_tags // []) + (.tags // []) | select(length > 0) | "<i>\(map(esc) | join(", "))</i>")
    ] | join(" ")
  ) as $label
  | [indent($depth) + $label, (.descendants // [] | .[] | descendant($depth + 1))]
  | join("\n");

def example:
  [ (.text // empty | esc),
    (.roman // empty | "(\(esc))"),
    (.translation // .english // empty | "– \(esc)")
  ] as $parts
  | "<ex>\($parts | join(" "))</ex>" + ([.ref // empty | " [\(esc)]"] | join(""));

def sense($n):
  # wiktextract-internal markers, already evident from the headword or gloss
  ([.qualifier // empty] + (.raw_tags // []) + (.tags // []) - ["reconstruction", "form-of", "alt-of"]) as $labels
  # subsenses repeat the parent gloss, which often ends in a colon
  | (reduce .glosses[] as $g (""; if . == "" then $g elif endswith(":") then "\(.) \($g)" else "\(.); \($g)" end)) as $gloss
  | [ ( [ "\($n).",
          ($labels | select(length > 0) | "(<abr>\(map(esc) | join(", "))</abr>)"),
          ($gloss | esc)
        ] | join(" ")
      ),
      ((.examples // [])[:1][] | indent(2) + example)
    ] | join("\n");

def entry:
  ((.original_title // "") | startswith("Reconstruction:")) as $reconstruction
  | (if $reconstruction then "*" + .word else .word end) as $headword
  | [ (select($reconstruction) | $headword),
      ( .forms // []
        | .[]
        # drop wiktextract's table metadata and the "-" placeholders of empty table cells
        | select(.tags // [] | any(. == "table-tags" or . == "inflection-template" or . == "class") | not)
        | (.form | strings),
          ((.roman | strings), (select(.tags // [] | any(. == "romanization")) | .form | strings) | ., unstressed)
        | select(test("\\p{L}"))
      )
    ] as $alternatives
  | ([.word] + (($alternatives | unique) - [.word]) | map(term) | join("|")) as $terms
  | ([.head_templates // [] | .[].expansion | strings | esc] | distinct | if length > 0 then join(", ") else ($headword | esc) end) as $head
  | [ ( [ "<b>\($head)</b>" + ([.pos // empty | " <i>\(esc)</i>"] | join("")),
          ([.senses // [] | .[] | select(.glosses | length > 0)] | to_entries[] | (.key + 1) as $n | .value | sense($n))
        ] | join("\n")
      ),
      (.etymology_text // empty | select(. != "") | "<b>Etymology:</b> \(esc)"),
      (.descendants // [] | select(length > 0) | "<b>Descendants:</b>\n\(map(descendant(1)) | join("\n"))")
    ]
  | "\($terms)\t\(join("\n\n") | gsub("\\\\"; "\\\\") | gsub("\n"; "\\n"))";

# run with --null-input: one error aborts the whole run with status 5, whereas
# jq's per-input mode only reports the status of the last input
inputs | entry
