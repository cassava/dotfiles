# When autocompleting with the vi command, don't suggest files I don't want
# to open: aux|bbl|bcf|blg|idx|ilg|ind|lof|lot|nlo|nls|out|run.xml|toc|log|pdf
# These endings come from latex projects.
zstyle ':completion:*:*:vi:*' file-patterns '^*.(aux|bbl|bcf|blg|fls|glo|idx|ilg|ind|lof|lot|nlo|nls|out|run.xml|toc|log|pdf):source-files' '*:all-files'
