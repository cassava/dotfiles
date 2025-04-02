#!/bin/bash

remove_packages=()
install_packages=(
    base-devel
    bat
    bat-extras
    binocle
    bottom
    calc
    cmake
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
    serie
    sd
    the_silver_searcher
    tmate
    tmux
    tree
    uv
    watchexec
    yq
    zsh

# {{ if not .is_headless }}
    otf-firamono-nerd
    ttf-firacode-nerd
    wezterm
    flameshot
# {{ end }}
)

sudo pacman -Sy --needed --noconfirm "${install_packages[@]}"
