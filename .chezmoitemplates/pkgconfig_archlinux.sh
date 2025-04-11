# pkgconfig_archlinux.sh
#
# Use the following functions from package_manager.sh to define asset installation:
#
#     sudo_untar_tree1 FILE [ARGS...]
#     sudo_untar_bin0 FILE [NAMES...]
#     sudo_untar_bin1 FILE [NAMES...]
#     sudo_unzip_bin FILE [NAMES...]
#     sudo_copy_bin FILE [NAME]
#     sudo_innstall_deb FILE
#     sudo_untar_fonts FILE

declare -a packages=(
    ast-grep
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
    ttf-victor-mono-nerd
    wezterm
    flameshot
# {{ end }}
)

declare -A assets=(
    ["ast-grep"]={{ gitHubLatestReleaseAssetURL "ast-grep/ast-grep" (printf "app-%s-unknown-linux-gnu.zip" .sys.uname_arch) }}
)

install_ast-grep() { sudo_unzip_bin "$1" ast-grep sg; }
