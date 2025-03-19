#!/bin/bash
#

destdir=/usr/local/share/zsh/site-functions
sudo mkdir -p $destdir

hash chezmoi && (chezmoi completion zsh | sudo tee $destdir/_chezmoi >/dev/null)
hash uv && (uv --generate-shell-completion zsh | sudo tee $destdir/_uv >/dev/null)
hash uvx && (uvx --generate-shell-completion zsh | sudo tee $destdir/_uvx >/dev/null)
