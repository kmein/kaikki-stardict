%.babylon: %.json
	jq --slurp --raw-output --from-file generate-babylon.jq "$<" > "$@"

%.zip: %.babylon
	babylon "$<"
	ls "$(basename $@)".* | grep -v '\.babylon\|\.json' | zip $(PWD)/"$@" --names-stdin

%.json:
	curl https://kaikki.org/dictionary/$(basename $(subst _,%20,$@))/kaikki.org-dictionary-$(subst -,,$(subst _,,$@)) -o "$@"
