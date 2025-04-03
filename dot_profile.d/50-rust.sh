export CARGO_HOME="$HOME/.local/share/cargo"
export CARGO_INSTALL_ROOT="$HOME/.local"
if command -v rustc >/dev/null; then
    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi
