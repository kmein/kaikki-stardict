.PHONY: all
all: Old_Church_Slavonic.zip Egyptian.zip Old_Norse.zip Old_High_German.zip Gothic.zip Old_English.zip  Tocharian_A.zip Tocharian_B.zip Proto-Indo-European.zip Proto-Germanic.zip Proto-West_Germanic.zip Proto-Slavic.zip Proto-Celtic.zip Proto-Brythonic.zip Proto-Italic.zip Hebrew.zip Arabic.zip Persian.zip Danish.zip

%.babylon: %.jsonl
	jq --slurp --raw-output --from-file generate-babylon.jq "$<" > "$@"

%.zip: %.babylon
	babylon "$<"
	ls "$(basename $@)".* | grep -v '\.babylon\|\.json' | zip $(PWD)/"$@" --names-stdin

%.jsonl:
	curl https://kaikki.org/dictionary/$(basename $(subst _,%20,$@))/kaikki.org-dictionary-$(subst -,,$(subst _,,$@)) -o "$@"
