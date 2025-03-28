#!/bin/bash

remove_packages=()
install_packages=(
    bat
    bat-extras
    binocle
    bottom
    diskus
    duf
    exa
    fasd
    fd
    fzf
    git
    git-delta
    hexyl
    htop
    hyperfine
    inetutils
    jq
    lsd
    lsof
    mc
    mlocate
    neovim
    pass
    pv
    ripgrep
    ruff
    rustup
    sd
    the_silver_searcher
    tmate
    tmux
    tree
    uv
    watchexec
    yq
    zsh

# {{ if .opts.with_gui }}
    otf-firamono-nerd
    ttf-firacode-nerd
    ghostty
    alacritty
    flameshot
# {{ end }}
)

sudo pacman -Sy --needed --noconfirm "${install_packages[@]}"
