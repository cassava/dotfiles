# pkgconfig_ubuntu.sh
#
# Use the following functions from package_manager.sh to define asset installation:
#
#     sudo_untar_tree1 FILE [ARGS...]
#     sudo_untar_bin0 FILE [NAMES...]
#     sudo_untar_bin1 FILE [NAMES...]
#     sudo_unzip_bin FILE [NAMES...]
#     sudo_copy_bin FILE [NAME]
#     sudo_copy_file FILE DEST
#     sudo_innstall_deb FILE
#     sudo_untar_fonts FILE
#
# Notes:
# - It's generally not necessary to provide an install function for .deb files.

declare -ax packages=(
    age
    autoconf
    automake
    calc
    cmake
    curl
    fasd
    g++
    gettext
    git
    git
    htop
    imagemagick
    inetutils-ping
    inetutils-telnet
    inetutils-tools
    lsof
    mc
    ripgrep
    pass
    python3-xdg
    silversearcher-ag
    tmux
    tmuxinator
    tree
    unzip
    universal-ctags
    xxd
    zsh

# {{ if not .is_headless }}
    flameshot
# {{ end }}
)

declare -Ax assets=(
    ["ast-grep"]='{{ gitHubLatestReleaseAssetURL "ast-grep/ast-grep" (printf "app-%s-unknown-linux-gnu.zip" .sys.uname_arch) }}'
    ["bat"]='{{ gitHubLatestReleaseAssetURL "sharkdp/bat" (printf "bat_*_%s.deb" .chezmoi.arch) }}'
    ["bazel"]='{{ gitHubLatestReleaseAssetURL "bazelbuild/bazel" (printf "bazel_*-linux-%s.deb" .sys.uname_arch) }}'
    ["binocle"]='{{ gitHubLatestReleaseAssetURL "sharkdp/binocle" (printf "binocle-musl_*_%s.deb" .chezmoi.arch) }}'
    ["bottom"]='{{ gitHubLatestReleaseAssetURL "clementtsang/bottom" (printf "bottom-musl_*_%s.deb" .chezmoi.arch) }}'
    ["buildifier"]='{{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildifier-linux-%s" .chezmoi.arch) }}'
    ["buildozer"]='{{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildozer-linux-%s" .chezmoi.arch) }}'
    ["delta"]='{{ gitHubLatestReleaseAssetURL "dandavison/delta" (printf "git-delta-musl_*_%s.deb" .chezmoi.arch) }}'
    ["diskus"]='{{ gitHubLatestReleaseAssetURL "sharkdp/diskus" (printf "diskus-musl_*_%s.deb" .chezmoi.arch) }}'
    ["fd"]='{{ gitHubLatestReleaseAssetURL "sharkdp/fd" (printf "fd-musl_*_%s.deb" .chezmoi.arch) }}'
    ["fzf"]='{{ gitHubLatestReleaseAssetURL "junegunn/fzf" (printf "fzf-*-linux_%s.tar.gz" .chezmoi.arch) }}'
    ["gojq"]='{{ gitHubLatestReleaseAssetURL "itchyny/gojq" (printf "gojq_*_linux_%s.tar.gz" .chezmoi.arch) }}'
    ["hexyl"]='{{ gitHubLatestReleaseAssetURL "sharkdp/hexyl" (printf "hexyl-musl_*_%s.deb" .chezmoi.arch) }}'
    ["hyperfine"]='{{ gitHubLatestReleaseAssetURL "sharkdp/hyperfine" (printf "hyperfine-musl_*_%s.deb" .chezmoi.arch) }}'
    ["lsd"]='{{ gitHubLatestReleaseAssetURL "lsd-rs/lsd" (printf "lsd-musl_*_%s.deb" .chezmoi.arch) }}'
    ["numbat"]='{{ gitHubLatestReleaseAssetURL "sharkdp/numbat" (printf "numbat-musl_*_%s.deb" .chezmoi.arch) }}'
    ["nvim"]='{{ gitHubLatestReleaseAssetURL "neovim/neovim" (printf "nvim-linux-%s.tar.gz" .sys.uname_arch) }}'
    ["ripgrep"]='{{ gitHubLatestReleaseAssetURL "burntsushi/ripgrep" (printf "ripgrep_*_%s.deb" .chezmoi.arch) }}'
    ["sd"]='{{ gitHubLatestReleaseAssetURL "chmln/sd" (printf "sd-*-%s-unknown-linux-musl.tar.gz" .sys.uname_arch) }}'
    ["serie"]='{{ gitHubLatestReleaseAssetURL "lusingander/serie" (printf "serie-*-%s-unknown-linux-musl.tar.gz" .sys.uname_arch) }}'
    ["tectonic"]='{{ gitHubLatestReleaseAssetURL "tectonic-typesetting/tectonic" (printf "tectonic-*-%s-unknown-linux-musl.tar.gz" .sys.uname_arch) }}'
    ["unused_deps"]='{{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "unused_deps-linux-%s" .chezmoi.arch) }}'
    ["uv"]='{{ gitHubLatestReleaseAssetURL "astral-sh/uv" (printf "uv-%s-unknown-linux-musl.tar.gz" .sys.uname_arch) }}'
    ["watchexec"]='{{ gitHubLatestReleaseAssetURL "watchexec/watchexec" (printf "watchexec-*-%s-unknown-linux-musl.deb" .sys.uname_arch) }}'

# {{ if not .is_headless }}
    ["wezterm"]='{{ gitHubLatestReleaseAssetURL "wezterm/wezterm" (printf "wezterm-*.%s%s.deb" .chezmoi.osRelease.name .chezmoi.osRelease.versionID) }}'
    ["firacode"]='{{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraCode.tar.xz" }}'
    ["firamono"]='{{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraMono.tar.xz" }}'
    ["inconsolata"]='{{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "Inconsolata.tar.xz" }}'
    ["victormono"]='{{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "VictorMono.tar.xz" }}'
# {{ end }}
)

install_ast-grep() { sudo_unzip_bin "$1" ast-grep sg; }
install_nvim() { sudo_untar_tree1 "$1"; }
install_fzf() { sudo_untar_bin0 "$1" fzf; }
install_gojq() { sudo_untar_bin1 "$1" gojq; }
install_serie() { sudo_untar_bin0 "$1" serie; }
install_tectonic() { sudo_untar_bin0 "$1" tectonic; }
install_sd() { sudo_untar_bin1 "$1" sd; }
install_uv() { sudo_untar_bin1 "$1" uv uvx; }
install_buildifier() { sudo_copy_bin "$1" buildifier; }
install_buildozer() { sudo_copy_bin "$1" buildozer; }
install_unused_deps() { sudo_copy_bin "$1" unused_deps; }
install_firacode() { sudo_untar_fonts "$1"; }
install_firamono() { sudo_untar_fonts "$1"; }
install_inconsolata() { sudo_untar_fonts "$1"; }
install_victormono() { sudo_untar_fonts "$1"; }
