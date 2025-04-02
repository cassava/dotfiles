#!/bin/bash

set -e

cache_dir="{{ .chezmoi.cacheDir }}/packages"
state_dir="{{ .chezmoi.homeDir }}/.local/state/chezmoi"
install_list="$state_dir/installed_packages.txt"
install_dir=/usr/local
font_dir=~/.local/share/fonts

apt_packages=(
    age
    autoconf
    automake
    calc
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
# {{ end }}
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
# {{ if not .is_headless }}
    {{ gitHubLatestReleaseAssetURL "wezterm/wezterm" (printf "wezterm-*.%s%s.deb" .chezmoi.osRelease.name .chezmoi.osRelease.versionID) }}
# {{ end }}
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

asset_filename() {
    local url="$1"
    local sum="$(echo "$url" | md5sum - | cut -f1 -d' ')"
    local base="$(basename "$url")"
    echo "$base" | sed -r "s/.*/${sum}_\\0/"
}

download_asset() {
    local list="$1"
    local url="$2"

    local basename="$(basename "$url")"
    local filename="$(asset_filename "$url")"
    local dest="$cache_dir/$filename"

    if grep --fixed-strings --quiet "$filename" "$install_list"; then
        echo "skipping: $basename"
        return
    fi

    if [[ -f "$dest" ]]; then
        echo "found: $filename"
    else
        echo "downloading: $filename"
        wget -q -O "$dest" "$url"
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

install_packages() {
    local filtered_packages=()
    for pkg in "${apt_packages[@]}"; do
        if ! grep --quiet "^$pkg$" "$install_list"; then
            filtered_packages+=("$pkg")
            echo "installing: ${pkg}"
        fi
    done

    if [[ ${#filtered_packages[@]} -gt 0 ]]; then
        sudo apt-get -qq install -y "${filtered_packages[@]}"
        for pkg in "${filtered_packages[@]}"; do
            echo "${pkg}" >> "$install_list"
        done
    fi
}

install_debs() {
    for file in "${package_debs[@]}"; do
        echo "installing: ${file}"
        sudo dpkg -i "${file}" >/dev/null || continue
        echo "${file}" >> "$install_list"
    done
}

install_tarballs() {
    # Install tarballs
    for file in "${package_tarballs[@]}"; do
        echo "extracting: ${file}"
        sudo tar -C "$install_dir" --strip-components=1 -xf "$file" || continue
        echo "${file}" >> "$install_list"
    done

    # Install binballs
    for file in "${binary_tarballs[@]}"; do
        echo "extracting: ${file}"
        sudo tar -C "$install_dir/bin" --strip-components=1 -xf "$file" "${github_binballs_wants[@]}" || continue
        echo "${file}" >> "$install_list"
    done

    # Install binaries
    for file in "${binary_files[@]}"; do
        echo "copying: ${binary_files[@]}"
        sudo install -m755 "$file" "$install_dir/bin/" || continue
        echo "${file}" >> "$install_list"
    done
}

install_fonts() {
    # Install fonts
    mkdir -p ~/.local/share/fonts
    for file in "${font_tarballs[@]}"; do
        echo "extracting font: $file"
        local extract_pattern="*.ttf"
        if tar -tf "$file" | grep -q '.*\.otf$'; then
            extract_pattern="*.otf"
        fi
        tar -C "$font_dir" -xf "$file" --wildcards "$extract_pattern" || continue
        echo "${file}" >> "$install_list"
    done
    fc-cache -f "$font_dir"
}

install_assets() {
    install_packages
    install_debs
    install_tarballs
    if {{ not .is_headless }}; then
        install_fonts
    fi
}

mkdir -p "$cache_dir"
mkdir -p "$state_dir"
touch "$install_list"
download_assets
install_assets
