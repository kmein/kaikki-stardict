# vi: ft=jq
map(
  (
    [.word] + (
      .forms // []
      | map(
        select(
          .source == "declension"
          and .tags != ["inflection-template"]
          and .tags != ["table-tags"]
          and .tags != ["class"]
        )
        | .form
      )
    )
    | unique
  ) as $forms
  | (.pos // "") as $pos
  | (.descendants // [] | map(.text | gsub("\n"; " › ")) | join("<br>")) as $descendants
  | (.etymology_text // "" | gsub("\n"; "<br>")) as $etymology
  | (
    .senses
    | map(
      (.glosses // [] | join("; "))
      + (.tags // [] | join(", ") | " (\(.))")
    )
    | join("; ")
    | gsub("\n"; "<br>")
  ) as $meanings
  | "\($forms | join("|"))\n\(.head_templates // []|map(.expansion)|join(",")|gsub("\n"; "<br>")) — \($pos) — \($etymology)<br><br>\($meanings)<br><br>\($descendants)\n"
) | join("\n")
