locale_conf="${XDG_CONFIG_HOME-$HOME/.config}/locale.conf"
if [[ -e "$locale_conf" ]]; then
    for line in $(cat "$locale_conf"); do
        export "$line"
    done
fi
