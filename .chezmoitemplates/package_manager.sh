# Option variables:
verbose=false
cache_dir="$HOME/.cache/chezmoi/packages"
state_dir="$HOME/.local/state/chezmoi"
dest_dir="/usr/local" # or $HOME/.local
mark_file="$state_dir/installed_packages.txt"
manifest_dir="$state_dir/installed_files/"

declare -a packages=()
declare -A assets=()

# For sudo_extract_deb:
declare -a extract_deb_exclude=(
    ^usr/share/applications
    ^usr/share/doc
    ^usr/share/fish
    ^usr/share/icons
    ^usr/share/metainfo
    ^usr/share/nautilus-python
)
declare -a extract_deb_include=(
    ^etc
    ^usr/bin
    ^usr/share
)
declare -a extract_deb_rewrite=(
    's@usr/@@'
    's@share/zsh/.*/(_[^/]+)$@share/zsh/site-functions/\1@'
)

# Helper functions for installing assets:
sudo_untar_tree1() {
    maybe_sudo tar -C "${dest_dir}" --strip-components=1 -xf "${1:?FILE unset}" "${@:2}"
}

sudo_untar_bin0() {
    maybe_sudo tar -C "${dest_dir}/bin" -xf "${1:?FILE unset}" --no-anchored "${@:2}"
}

sudo_untar_bin1() {
    maybe_sudo tar -C "${dest_dir}/bin" --strip-components=1 -xf "${1:?FILE unset}" --no-anchored "${@:2}"
}

sudo_unzip_bin() {
    maybe_sudo unzip -q -o -j -d "${dest_dir}/bin" "${1:?FILE unset}" "${@:2}"
    for file in "${@:2}"; do
        maybe_sudo chmod +x "${dest_dir}/bin/$file"
    done
}

sudo_gunzip_bin() {
    local archive="${1:?FILE unset}"
    local dest="${dest_dir}/bin/${2:?DEST unset}"
    maybe_sudo_validate
    gunzip -c "${archive}" | maybe_sudo tee "${dest}" >/dev/null
    maybe_sudo chmod +x "${dest}"
}

# Usage
sudo_copy_bin() {
    maybe_sudo install -m755 "${1:?FILE unset}" "${dest_dir}/bin/${2:-$1}"
}

# Usage: sudo_copy_file FILE [DEST]
sudo_copy_file() {
    maybe_sudo install -m644 "${1:?FILE unset}" "${dest_dir}/${2:?DEST unset}"
}

# Usage: sudo_install_deb FILE
sudo_install_deb() {
    sudo dpkg -i "${1:?FILE unset}" >/dev/null
}

# Usage: sudo_extract_deb FILE
sudo_extract_deb() {
    local package="${1:?FILE unset}"
    local manifest="${manifest_dir}/$(basename "${package}").txt"
    local tmpdir
    tmpdir=$(mktemp -d)
    dpkg-deb -x "$package" "$tmpdir"
    (
        cd "$tmpdir"
        rm -f "$manifest"
        mkdir -p "${manifest_dir}"
        find . -type f,l | while read -r file; do
            extract_deb_file "$manifest" "$file"
        done
    )
    rm -rf "$tmpdir"
}

# Usage: sudo_untar_fonts FILE
sudo_untar_fonts() {
    local file="${1:?FILE unset}"
    local font_dir=${dest_dir}/share/fonts

    maybe_sudo mkdir -p "$font_dir"
    local extract_pattern="*.ttf"
    if tar -tf "$file" | grep -q '.*\.otf$'; then
        extract_pattern="*.otf"
    fi
    maybe_sudo tar -C "$font_dir" -xf "$file" --wildcards "$extract_pattern" || return
    fc-cache -f "$font_dir"
}

# Implementation functions:
maybe_sudo() {
    if [[ -w "$dest_dir" ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

maybe_sudo_validate() {
    if ! [[ -w "$dest_dir" ]]; then
        sudo --validate
    fi
}

extract_deb_file() {
    local manifest="$1"
    local source="${2/.\//}"

    for regex in "${extract_deb_exclude[@]}"; do
        if echo "$source" | grep -qE "$regex"; then
            if $verbose; then echo "skip: $source (excluded)"; fi
            return
        fi
    done

    file_ok=false
    for regex in "${extract_deb_include[@]}"; do
        if echo "$source" | grep -qE "$regex"; then
            file_ok=true
            break
        fi
    done
    if ! $file_ok; then
        if $verbose; then echo "skip: $source (not included)"; fi
        return
    fi

    local target=$source
    for regex in "${extract_deb_rewrite[@]}"; do
        target=$(echo "$target" | sed -r "$regex")
    done
    if [[ -z "$target" ]]; then
        echo "error: path rewrite is broken for $source"
        return
    fi

    echo "$dest_dir/$target" >> "$manifest"
    maybe_sudo install -D -T "$source" "$dest_dir/$target" || true
}

asset_is_marked() {
    test -f "$mark_file" && grep --line-regexp --fixed-strings --quiet "$1" "$mark_file"
}

asset_set_mark() {
    echo "$1" >> "$mark_file"
}

asset_filename() {
    local key="$1"
    local url="$2"
    local sum="$(echo "$url" | sha1sum - | cut -b -8)"
    local base="$(basename "$url")"
    printf "%s_%s_%s" "$key" "$sum" "$base"
}

asset_download() {
    local key="$1"
    local url="$2"
    local basename="$(basename "$url")"
    local filename="$(asset_filename "$key" "$url")"
    local dest="$cache_dir/$filename"

    if [[ -f "$dest" ]]; then
        echo "found: $filename" >&2
    else
        echo "downloading: $filename" >&2
        wget -q -O "$dest" "$url" >&2
    fi
    echo "$dest"
}

# Usage: Define packages array and then call this function.
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

# Usage: Define assets array and then call this function.
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

        file="$(asset_download "$key" "$url")"
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
