#!/bin/bash
#
# Check that neovim version is >= to version_min.
# If not, then try to build and install neovim.

set -o

version_min="0.10.0"
build_neovim=true

nvim_version() {
    (
        PATH="${PATH}:/usr/local/bin:$HOME/.local/bin"
        if command -v nvim >/dev/null; then
            nvim --version 2>/dev/null | sed -rn 's/^NVIM v([0-9]+\.[0-9]+\.[0-9]+).*$/\1/p'
        else
            echo 0.0.0
        fi
    )
}

version_cur=$(nvim_version)

is_ubuntu() {
    command -v apt-get >/dev/null
}

is_arch() {
    command -v pacman >/dev/null
}

install_ubuntu_deps() {
    sudo apt-get update
    sudo apt-get install -y \
        autoconf \
        automake \
        cmake \
        curl \
        doxygen \
        g++ \
        gettext \
        git \
        libtool \
        libtool-bin \
        ninja-build \
        pkg-config \
        unzip
}

install_arch_deps() {
    sudo pacman -Sy --needed --noconfirm \
        base-devel \
        cmake \
        curl \
        git \
        ninja \
        tree-sitter \
        unzip
}

build_neovim() {
    local srcdir="${HOME}/.local/src/neovim"
    mkdir -p "$(dirname "$srcdir")"
    git clone "https://github.com/neovim/neovim" "$srcdir"
    cd "$srcdir" || exit 1
    make CMAKE_BUILD_TYPE=Release
    sudo make install
}

# Check version
if [[ "${version_cur}" == "0.0.0" ]]; then
    echo "error, nvim not installed"
elif [[ "${version_cur}" == "${version_min}" ]]; then
    echo "ok, nvim ${version_cur} == ${version_min}"
    exit 0
else
    lower=$(echo -e "${version_cur}\n${version_min}" | sort -V | head -1)
    if [[ "${lower}" != "${version_min}" ]]; then
        echo "error, nvim ${version_cur} < ${version_min}"
    else
        echo "ok, nvim ${version_cur} > ${version_min}"
        exit 0
    fi
fi

if ! ${build_neovim}; then
    echo "building neovim disabled"
    exit 0
fi

# Build neovim
if is_ubuntu; then
    install_ubuntu_deps
    build_neovim
elif is_arch; then
    install_arch_deps
    build_neovim
else
    echo "Error: unknown system, aborting." >&2
    exit 1
fi
