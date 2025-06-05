#!/bin/bash
set -e

verbose=false
cache_dir="{{ .chezmoi.cacheDir }}/packages"
state_dir="{{ .chezmoi.homeDir }}/.local/state/chezmoi"
mark_file="$state_dir/installed_packages.txt"

# Helper functions for installing assets:
sudo_untar_tree1() {
    sudo tar -C "/usr/local" --strip-components=1 -xf "$1" "${@:2}"
}

sudo_untar_bin0() {
    sudo tar -C "/usr/local/bin" -xf "$1" --no-anchored "${@:2}"
}

sudo_untar_bin1() {
    sudo tar -C "/usr/local/bin" --strip-components=1 -xf "$1" --no-anchored "${@:2}"
}

sudo_unzip_bin() {
    sudo unzip -q -o -j -d "/usr/local/bin" "$1" "${@:2}"
    for file in "${@:2}"; do
        sudo chmod +x "/usr/local/bin/$file"
    done
}

sudo_copy_bin() {
    sudo install -m755 "$1" "/usr/local/bin/$2"
}

sudo_install_deb() {
    sudo dpkg -i "$1" >/dev/null
}

sudo_untar_fonts() {
    local file="$1"
    local font_dir=/usr/local/share/fonts

    sudo mkdir -p "$font_dir"
    local extract_pattern="*.ttf"
    if tar -tf "$file" | grep -q '.*\.otf$'; then
        extract_pattern="*.otf"
    fi
    sudo tar -C "$font_dir" -xf "$file" --wildcards "$extract_pattern" || return
    fc-cache -f "$font_dir"
}

# Implementation functions:
asset_is_marked() {
    test -f "$mark_file" && grep --line-regexp --fixed-strings --quiet "$1" "$mark_file"
}

asset_set_mark() {
    echo "$1" >> "$mark_file"
}

asset_filename() {
    local url="$1"
    local sum="$(echo "$url" | md5sum - | cut -f1 -d' ')"
    local base="$(basename "$url")"
    echo "$base" | sed -r "s/.*/${sum}_\\0/"
}

asset_download() {
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
    mkdir -p "$cache_dir"
    mkdir -p "$state_dir"

    local filtered_packages=()
    for pkg in "${packages[@]}"; do
        if ! asset_is_marked "$pkg"; then
            filtered_packages+=("$pkg")
            echo "installing: ${pkg}" >&2
        fi
    done

    if [[ ${#filtered_packages[@]} -gt 0 ]]; then
        if hash apt-get 2>/dev/null; then
            sudo apt-get -qq install -y "${filtered_packages[@]}"
        elif hash pacman 2>/dev/null; then
            sudo pacman -Sy --needed --noconfirm "${filtered_packages[@]}"
        fi
        for pkg in "${filtered_packages[@]}"; do
            asset_set_mark "$pkg"
        done
    fi
}

install_assets() {
    mkdir -p "$cache_dir"
    mkdir -p "$state_dir"

    for key in "${!assets[@]}"; do
        url="${assets[$key]}"
        if [[ -z "$url" ]]; then
            echo "error: asset url is empty: $key"
            continue
        elif asset_is_marked "$url"; then
            $verbose && echo "skipping: $key" >&2
            continue
        fi

        file="$(asset_download "$url")"
        if [[ "$(type -t install_$key)" == "function" ]]; then
            echo "installing: $key" >&2
            install_$key "$file" || continue
        elif [[ "$file" =~ \.deb$ ]]; then
            echo "installing: $key" >&2
            sudo_install_deb "$file" || continue
        else
            echo "error: do not know how to install $key: '$file'" >&2
            continue
        fi
        asset_set_mark "$url"
    done
}
