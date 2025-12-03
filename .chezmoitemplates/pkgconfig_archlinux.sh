# pkgconfig_archlinux.sh
#
# Use the following functions from package_manager.sh to define asset installation:
#
#     sudo_untar_tree1 FILE [ARGS...]
#     sudo_untar_bin0 FILE [NAMES...]
#     sudo_untar_bin1 FILE [NAMES...]
#     sudo_unzip_bin FILE [NAMES...]
#     sudo_copy_bin FILE [NAME]
#     sudo_gunzip_bin FILE DEST
#     sudo_copy_file FILE DEST
#     sudo_install_deb FILE
#     sudo_extract_deb FILE
#     sudo_untar_fonts FILE

declare -ax packages=(
    asciinema
    ast-grep
    base-devel
    bat
    bat-extras
    binocle
    bottom
    calc
    cmake
    direnv
    difftastic
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
    mergiraf
    mlocate
    neovim
    npm
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
    tree-sitter
    uv
    watchexec
    yq
    zellij
    zsh

# {{ if not .is_headless }}
    otf-firamono-nerd
    ttf-firacode-nerd
    ttf-victor-mono-nerd
    wezterm
    flameshot
# {{ end }}
)

declare -Ax assets=(
    ["asciinema-agg"]='{{ gitHubLatestReleaseAssetURL "asciinema/agg" (printf "agg-%s-unknown-linux-musl" .sys.uname_arch) }}'
)

install_asciinema-agg() { sudo_copy_bin "$1" asciinema-agg; }
