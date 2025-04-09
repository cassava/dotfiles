#!/bin/bash

set -e

cache_dir="{{ .chezmoi.cacheDir }}/packages"
state_dir="{{ .chezmoi.homeDir }}/.local/state/chezmoi"
install_list="$state_dir/installed_packages.txt"
install_dir=/usr/local
font_dir=~/.local/share/fonts

declare -a apt_packages=(
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
    inetutils-ping
    inetutils-telnet
    inetutils-tools
    lsof
    mc
    ripgrep
    pass
    python3-xdg
    silversearcher-ag
    tmate
    tmux
    tmuxinator
    tree
    unzip
    universal-ctags
    zsh

# {{ if not .is_headless }}
    flameshot
# {{ end }}
)

declare -a deb_packages=(
    {{ gitHubLatestReleaseAssetURL "sharkdp/bat" (printf "bat_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "sharkdp/fd" (printf "fd-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "sharkdp/numbat" (printf "numbat-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "sharkdp/hyperfine" (printf "hyperfine-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "sharkdp/hexyl" (printf "hexyl-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "sharkdp/diskus" (printf "diskus-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "sharkdp/binocle" (printf "binocle-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "burntsushi/ripgrep" (printf "ripgrep-*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "clementtsang/bottom" (printf "bottom-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "lsd-rs/lsd" (printf "lsd-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "dandavison/delta" (printf "git-delta-musl_*_%s.deb" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "watchexec/watchexec" (printf "watchexec-*-%s-unknown-linux-musl.deb" .sys.uname_arch) }}
# {{ if not .is_headless }}
    {{ gitHubLatestReleaseAssetURL "wezterm/wezterm" (printf "wezterm-*.%s%s.deb" .chezmoi.osRelease.name .chezmoi.osRelease.versionID) }}
# {{ end }}
)

declare -A tarball_packages=(
    ["nvim"]={{ gitHubLatestReleaseAssetURL "neovim/neovim" (printf "nvim-linux-%s.tar.gz" .sys.uname_arch) }}
    ["fzf"]={{ gitHubLatestReleaseAssetURL "junegunn/fzf" (printf "fzf-*-linux_%s.tar.gz" .chezmoi.arch) }}
    ["gojq"]={{ gitHubLatestReleaseAssetURL "itchyny/gojq" (printf "gojq_*_linux_%s.tar.gz" .chezmoi.arch) }}
    ["sd"]={{ gitHubLatestReleaseAssetURL "chmln/sd" (printf "sd-*-%s-unknown-linux-musl.tar.gz" .sys.uname_arch) }}
    ["uv"]={{ gitHubLatestReleaseAssetURL "astral-sh/uv" (printf "uv-%s-unknown-linux-musl.tar.gz" .sys.uname_arch) }}
    ["buildifier"]={{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildifier-linux-%s" .chezmoi.arch) }}
    ["buildozer"]={{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildozer-linux-%s" .chezmoi.arch) }}
    ["unused_deps"]={{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "unused_deps-linux-%s" .chezmoi.arch) }}
)

declare -a font_tarballs=(
# {{ if not .is_headless }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraCode.tar.xz" }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraMono.tar.xz" }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "Inconsolata.tar.xz" }}
# {{ end }}
)

install_nvim() { extract_usr_local "$1" 1; }
install_fzf() { extract_usr_local "$1" 0 fzf; }
install_gojq() { extract_usr_local "$1" 1 --no-anchored gojq; }
install_sd() { extract_usr_local "$1" 1 --no-anchored sd; }
install_uv() { extract_usr_local "$1" 1 --no-anchored uv uvx; }
install_buildifier() { copy_usr_local_bin "$1"; }
install_buildozer() { copy_usr_local_bin "$1"; }
install_unused_deps() { copy_usr_local_bin "$1"; }

extract_usr_local() {
    local file="$1"
    local strip="${2-0}"
    shift 2

    echo "extracting: ${file}" >&2
    sudo tar -C "$install_dir/bin" --strip-components=${strip} -xf "$file" "$@"
}

copy_usr_local_bin() {
    local file="$1"

    echo "copying: ${file}" >&2
    sudo install -m755 "$file" "$install_dir/bin/"
}

asset_filename() {
    local url="$1"
    local sum="$(echo "$url" | md5sum - | cut -f1 -d' ')"
    local base="$(basename "$url")"
    echo "$base" | sed -r "s/.*/${sum}_\\0/"
}

is_asset_marked() {
    grep --line-regexp --fixed-strings --quiet "$1" "$install_list"
}

mark_asset() {
    echo "$1" >> "$install_list"
}

download_asset() {
    local url="$1"

    local basename="$(basename "$url")"
    local filename="$(asset_filename "$url")"
    local dest="$cache_dir/$filename"

    if [[ -f "$dest" ]]; then
        echo "found: $filename" >&2
    else
        echo "downloading: $filename" >&2
        wget -q -O "$dest" "$url" >&2
    fi
    echo "$dest"
}

install_packages() {
    # Install apt packages all in one go, so figure out here
    # what we need to install and what not.
    local filtered_packages=()
    for pkg in "${apt_packages[@]}"; do
        if ! is_asset_marked "$pkg"; then
            filtered_packages+=("$pkg")
            echo "installing: ${pkg}" >&2
        fi
    done

    if [[ ${#filtered_packages[@]} -gt 0 ]]; then
        sudo apt-get -qq install -y "${filtered_packages[@]}"
        for pkg in "${filtered_packages[@]}"; do
            mark_asset "$pkg"
        done
    fi
}

install_debs() {
    for url in "${deb_packages[@]}"; do
        if is_asset_marked "$url"; then
            echo "skipping: $(asset_filename "$url")" >&2
            continue
        fi
        file="$(download_asset "$url")"
        echo "installing: $file" >&2
        sudo dpkg -i "$file" >/dev/null || continue
        mark_asset "$url"
    done
}

install_tarballs() {
    for key in "${!tarball_packages[@]}"; do
        url="${tarball_packages[$key]}"
        if is_asset_marked "$url"; then
            echo "skipping: $(asset_filename "$url")" >&2
            continue
        fi
        file="$(download_asset "$url")"
        if install_$key "$file"; then
            mark_asset "$url"
        fi
    done
}

install_fonts() {
    mkdir -p ~/.local/share/fonts
    for url in "${font_tarballs[@]}"; do
        if is_asset_marked "$url"; then
            echo "skipping: $(asset_filename "$url")" >&2
            continue
        fi

        file="$(download_asset "$url")"
        echo "extracting font: $file" >&2
        local extract_pattern="*.ttf"
        if tar -tf "$file" | grep -q '.*\.otf$'; then
            extract_pattern="*.otf"
        fi
        tar -C "$font_dir" -xf "$file" --wildcards "$extract_pattern" || continue
        mark_asset "$url"
    done
    fc-cache -f "$font_dir"
}

mkdir -p "$cache_dir"
mkdir -p "$state_dir"
touch "$install_list"
install_packages
install_debs
install_tarballs
if {{ not .is_headless }}; then
    install_fonts
fi
