#!/bin/bash
#
# Normally, the LANG, LANGUAGE, and other LC_* variables are set system-wide in
# /etc/locale.conf. However, many operating systems allow these variables to be
# overriden by user configurations, such as ~/.config/locale.conf. Here we make
# sure that the locales we set there are available.
#

# Default options
locale_gen="/etc/locale.gen"
locale_conf="${XDG_CONFIG_HOME-$HOME/.config}/locale.conf"
generate=true
autofix=true

check_locales() {
    if [[ -f "$locale_conf" ]]; then
        echo "Reading user locales from: $locale_conf"

        local user_locales=$(cat "$locale_conf" | sed -nr 's/^.*="?(.*)"?$/\1/p' | sort | uniq)
        local generated_locales=$(locale -a 2>/dev/null)
        local missing_locales=()
        [[ ! -z "$user_locales" ]] && echo
        for locale in $user_locales; do
            local alt_locale=$(echo $locale | sed -r 's/UTF-8/utf8/')
            if echo $generated_locales | grep -qF -- $locale; then
                echo -e "  $locale\tOK"
            elif echo $generated_locales | grep -qF -- $alt_locale; then
                echo -e "  $locale\tOK"
            else
                missing_locales+=("$locale")
                echo -e "  $locale\tMISSING"
            fi
        done

        if [[ ${#missing_locales[*]} -gt 0 ]]; then
            echo
            echo "Warning: One or more locales required have not been generated!"
            echo "Generate the required locales with the following procedure:"
            echo
            echo "  1. Add missing locales to $locale_gen"
            echo "  2. Run sudo locale-gen to generate all locales."
            echo "  3. Confirm locales are available with locale -a"

            if [[ $generate == true ]]; then
                echo
                if [[ $autofix == true ]]; then
                    echo "Automatically fixing $locale_gen..."
                    sudo -v
                    for locale in ${missing_locales[*]}; do
                        local locale_line="$locale UTF-8"
                        if grep -qxF "$locale_line" -- $locale_gen; then
                            echo "  Skip $locale"
                        else
                            # Locale line is not in locale.gen
                            if grep -qxF "#$locale_line" -- $locale_gen; then
                                # Locale line is there, but commented out.
                                echo "  Uncomment $locale"
                                sudo sed -ri "s/^#$locale_line\$/$locale_line/" $locale_gen
                            else
                                echo "  Append $locale"
                                echo "$locale_line" | sudo tee -a $locale_gen >/dev/null
                            fi
                        fi
                    done
                    echo "Fixing complete."
                else
                    echo Press [Enter] to edit $locale_gen
                    read dummy
                    sudoedit $locale_gen
                fi
                echo
                sudo locale-gen
            fi
        else
            echo
            echo "Required locales available."
            exit 0
        fi
    fi
}

# Parse options
while [ $# -gt 0 ]; do
    case $1 in
        --no-generate)
            generate=false
            ;;
        --no-auto-fix)
            autofix=false
            ;;
        *)
            echo "Usage: $(basename "$0") [--generate] [--auto-fix]" >&2
            exit 1
            ;;
    esac
    shift
done

check_locales
