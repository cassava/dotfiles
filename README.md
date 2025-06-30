My Dotfiles
===========

Managed with [chezmoi](https://www.chezmoi.io/). Install manager and dotfiles with:

    sh -c "$(curl -fsLS chezmoi.io/getlb)" -- init --apply cassava

It is recommended to install `pass` before-hand and set `tokens/github.com`
in order to not run into rate-limiting from github.

If you are starting from scratch, here is what you have to do:

    gpg --expert --full-gen-key --verbose --batch input-file
    pass init $email
    echo token | pass insert tokens/github.com

Ensure that you have at least git 2.37, or disable `core.fsMonitor` option.
