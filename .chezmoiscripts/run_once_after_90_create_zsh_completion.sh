#!/bin/bash
#

destdir=~/.local/share/zsh/functions
mkdir -p $destdir

hash chezmoi && (chezmoi completion zsh > $destdir/_chezmoi)
hash uv && (uv --generate-shell-completion zsh > $destdir/_uv)
hash uvx && (uvx --generate-shell-completion zsh > $destdir/_uvx)
