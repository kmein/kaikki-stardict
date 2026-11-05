LANGUAGES = Hindi Urdu Old_Church_Slavonic Egyptian Old_Norse Old_High_German Gothic Old_English Tocharian_A Tocharian_B Proto-Indo-European Proto-Germanic Proto-West_Germanic Proto-Slavic Proto-Celtic Proto-Brythonic Proto-Italic Hebrew Arabic Persian Danish Turkish

.PHONY: all
all: $(addsuffix .zip,$(LANGUAGES))

# keep downloads across rebuilds; drop half-written targets
.SECONDARY:
.DELETE_ON_ERROR:

# kaikki paths use the language name with spaces; file names drop spaces and hyphens
%.jsonl:
	curl --fail --silent --show-error --location --output "$@" "https://kaikki.org/dictionary/$(subst _,%20,$*)/kaikki.org-dictionary-$(subst -,,$(subst _,,$*)).jsonl"

%.tsv: %.jsonl generate-tabfile.jq
	{ printf '##name\t%s\n' "$(subst _, ,$*)"; \
	  printf '##description\tEnglish Wiktionary, extracted by kaikki.org on %s. CC BY-SA 4.0 and GFDL.\n' "$$(date -u -r "$<" +%F)"; \
	  jq --null-input --raw-output --from-file generate-tabfile.jq "$<"; } > "$@"

%.zip: %.tsv
	rm -rf "$*.stardict" "$@"
	pyglossary --no-progress-bar --read-format=Tabfile --write-format=Stardict --write-options='dictzip=True;sametypesequence=x' "$<" "$*.stardict/$*.ifo"
	zip --junk-paths "$@" "$*.stardict"/*

# github pages: the zips and a plain index linking them
.PHONY: site
site: all
	rm -rf site && mkdir site
	cp $(addsuffix .zip,$(LANGUAGES)) site/
	{ printf '%s\n' '<!doctype html>' '<meta charset="utf-8">' '<title>Offline Wiktionaries</title>' '<h1>Offline Wiktionaries</h1>'; \
	  printf '<p>StarDict dictionaries of English Wiktionary, extracted by <a href="https://kaikki.org/">kaikki.org</a>, built on %s. CC BY-SA 4.0 and GFDL.\n' "$$(date -u +%F)"; \
	  printf '%s\n' '<p>Unzip one into its own directory under <code>~/.stardict/dic/</code>, e.g. <code>mkdir -p ~/.stardict/dic &amp;&amp; unzip Gothic.zip -d ~/.stardict/dic/Gothic</code>, and look words up with <code>sdcv</code>.' '<ul>'; \
	  for l in $(LANGUAGES); do \
	    printf '<li><a href="%s.zip">%s</a>, %s entries\n' "$$l" "$$(sed -n 's/^bookname=//p' "$$l.stardict/$$l.ifo")" "$$(sed -n 's/^wordcount=//p' "$$l.stardict/$$l.ifo")"; \
	  done; \
	  printf '%s\n' '</ul>' '<p><a href="https://github.com/kmein/kaikki-stardict">Source</a>'; } > site/index.html
