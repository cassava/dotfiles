#!/bin/bash

echo "Initializing neovim configuration..."
nvim --headless +"Lazy! sync" +qa
