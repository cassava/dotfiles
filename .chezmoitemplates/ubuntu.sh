#!/bin/bash

set -e

cache_dir="${XDG_CACHE_DIR-$HOME/.cache}/chezmoi"
install_dir=/usr/local

apt_packages=(
    age
    fasd
    git
    htop
    inetutils-ping
    inetutils-telnet
    inetutils-tools
    lsof
    mc
    mlocate
    ripgrep
    silversearcher-ag
    tmate
    tmux
    tmuxinator
    tree
    zsh
    pass
# {{ if .opts.with_gui }}
    ghostty
    alacritty
    flameshot
# / {{ end }}
)

github_debs=(
    {{ gitHubLatestReleaseAssetURL "sharkdp/bat" (printf "bat-musl_*-%s.deb" .chezmoi.arch) }}
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
    {{ gitHubLatestReleaseAssetURL "watchexec/watchexec" (printf "watchexec-*-%s-unknown-linux-musl.deb" "x86_64") }}
)

github_tarballs=(
    {{ gitHubLatestReleaseAssetURL "junegunn/fzf" (printf "fzf-*-linux_%s.tar.gz" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "neovim/neovim" (printf "nvim-linux-%s.tar.gz" "x86_64") }}
    {{ gitHubLatestReleaseAssetURL "itchyny/gojq" (printf "gojq_*_linux_%s.tar.gz" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "chmln/sd" (printf "sd-*-%s-unknown-linux-musl.tar.gz" "x86_64") }}
    {{ gitHubLatestReleaseAssetURL "astral-sh/uv" (printf "uv-%s-unknown-linux-musl.tar.gz" "x86_64") }}
)

github_binaries=(
    {{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildifier-linux-%s" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildozer-linux-%s" .chezmoi.arch) }}
    {{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "unused_deps-linux-%s" .chezmoi.arch) }}
)

github_fonts=(
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraCode.tar.xz" }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraMono.tar.xz" }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "Inconsolata.tar.xz" }}
)

download_asset() {
    local list="$1"
    local url="$2"

    local filename="$(basename "$url")"
    local dest="$cache_dir/$filename"

    if [[ ! -f "$dest" ]]; then
        return
    fi

    wget -O "$dest" "$url"
    declare "$list+=("$filename")"
}

package_debs=()
package_tarballs=()
binary_files=()
font_tarballs=()
download_assets() {
    for url in "${github_debs[@]}"; do download_asset package_debs "$url"; done
    for url in "${github_tarballs[@]}"; do download_asset package_tarballs "$url"; done
    for url in "${github_binaries[@]}"; do download_asset binary_files "$url"; done
    for url in "${github_fonts[@]}"; do download_asset font_tarballs "$url"; done
}

install_assets() {
    # Intall packages
    sudo apt install -y "${apt_packages[@]}"

    # Install debs
    sudo dpkg -i "${package_debs[@]}"

    # Install tarballs
    (
        cd /usr/local || exit 1
        for file in "${package_tarballs[@]}"; do
            sudo tar xf --strip-components=1 "$file"
        done
    )

    # Install binaries
    (
        for file in "${binary_files[@]}"; do
            sudo install -m755 "$file" /usr/local/bin/
        done
    )

    # Install fonts
    (
        # TODO
    )
}

download_assets
