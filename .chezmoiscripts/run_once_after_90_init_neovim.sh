#!/bin/bash
#
# nvim hash: {{ output "bash" "-c" "find -type f dot_config/nvim -exec sha256sum -b {} + | sort | sha256sum | cut -d\  -f1" }}

echo "Initializing neovim configuration..."
nvim --headless +"Lazy! sync" +qa
