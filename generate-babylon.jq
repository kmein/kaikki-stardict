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
  | "\($forms | join("|"))\n\($pos) — \($etymology)<br><br>\($meanings)\n"
) | join("\n")
