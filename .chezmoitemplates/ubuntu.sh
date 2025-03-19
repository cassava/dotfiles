#!/bin/bash

set -e

cache_dir="{{ .chezmoi.cacheDir }}/scripts"
install_dir=/usr/local
font_dir=~/.local/share/fonts

apt_packages=(
    age
    autoconf
    automake
    cmake
    curl
    fasd
    fzf
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
    pass
    silversearcher-ag
    tmate
    tmux
    tmuxinator
    tree
    unzip
    zsh

# {{ if not .is_headless }}
    flameshot
# / {{ end }}
)

github_debs=(
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
    {{ gitHubLatestReleaseAssetURL "watchexec/watchexec" (printf "watchexec-*-%s-unknown-linux-musl.deb" "x86_64") }}
)

github_tarballs=(
    {{ gitHubLatestReleaseAssetURL "neovim/neovim" (printf "nvim-linux-%s.tar.gz" "x86_64") }}
)

github_binballs=(
    # {{ gitHubLatestReleaseAssetURL "itchyny/gojq" (printf "gojq_*_linux_%s.tar.gz" .chezmoi.arch) }}
    # {{ gitHubLatestReleaseAssetURL "chmln/sd" (printf "sd-*-%s-unknown-linux-musl.tar.gz" "x86_64") }}
    # {{ gitHubLatestReleaseAssetURL "astral-sh/uv" (printf "uv-%s-unknown-linux-musl.tar.gz" "x86_64") }}
)
github_binballs_want=(
    gojq
    uv
    uvx
    sd
)

github_binfiles=(
    # {{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildifier-linux-%s" .chezmoi.arch) }}
    # {{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "buildozer-linux-%s" .chezmoi.arch) }}
    # {{ gitHubLatestReleaseAssetURL "bazelbuild/buildtools" (printf "unused_deps-linux-%s" .chezmoi.arch) }}
)

github_fonts=(
# {{ if not .is_headless }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraCode.tar.xz" }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "FiraMono.tar.xz" }}
    {{ gitHubLatestReleaseAssetURL "ryanoasis/nerd-fonts" "Inconsolata.tar.xz" }}
# {{ end }}
)

package_debs=()
package_tarballs=()
binary_tarballs=()
binary_files=()
font_tarballs=()

download_asset() {
    local list="$1"
    local url="$2"

    local filename="$(basename "$url")"
    local dest="$cache_dir/$filename"

    if [[ -f "$dest" ]]; then
	echo "found: $filename"
    else
        echo "downloading: $filename"
        wget -O "$dest" "$url"
    fi
    eval "$list+=('$dest')"
}

download_assets() {
    for url in "${github_debs[@]}"; do download_asset package_debs "$url"; done
    for url in "${github_tarballs[@]}"; do download_asset package_tarballs "$url"; done
    for url in "${github_binballs[@]}"; do download_asset binary_tarballs "$url"; done
    for url in "${github_binaries[@]}"; do download_asset binary_files "$url"; done
    for url in "${github_fonts[@]}"; do download_asset font_tarballs "$url"; done
}

install_assets() {
    # Install packages
    echo "installing: ${apt_packages[@]}"
    sudo apt install -y "${apt_packages[@]}"

    # Install debs
    echo "installing: ${package_debs[@]}"
    sudo dpkg -i "${package_debs[@]}"

    # Install tarballs
    for file in "${package_tarballs[@]}"; do
        echo "extracting: ${file}"
        sudo tar -C "$install_dir" --strip-components=1 -xf "$file"
    done

    # Install binballs
    for file in "${binary_tarballs[@]}"; do
        echo "extracting: ${file}"
        sudo tar -C "$install_dir/bin" --strip-components=1 -xf "$file" "${github_binballs_wants[@]}"
    done

    # Install binaries
    for file in "${binary_files[@]}"; do
        echo "copying: ${binary_files[@]}"
        sudo install -m755 "$file" "$install_dir/bin/"
    done

    # Install fonts
    if {{ not .is_headless }}; then
        mkdir -p ~/.local/share/fonts
        for file in "${font_tarballs[@]}"; do
            echo "extracting font: $file"
            local extract_pattern="*.ttf"
            if tar -tf "$file" | grep -q '.*\.otf$'; then
                extract_pattern="*.otf"
            fi
            tar -C "$font_dir" -xf "$file" --wildcards "$extract_pattern"
        done
        fc-cache -fv "$font_dir"
    fi
}

download_assets
install_assets
