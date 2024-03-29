## Config functions [@bashly-upgrade config]
## This file is a part of Bashly standard library
##
## Usage:
## - In your script, set the CONFIG_FILE variable. For rxample:
##   CONFIG_FILE=settings.ini.
##   If it is unset, it will default to 'config.ini'.
## - Use any of the functions below to access the config file.
##
## Create a new config file.
## There is normally no need to use this function, it is used by other
## functions as needed.
##
config_init() {
    RISKS_CONFIG_FILE=${RISKS_CONFIG_FILE-${RISKS_DIR}/config.ini}
    [[ -f "$RISKS_CONFIG_FILE" ]] || {
        _info "Writing default configuration file to ${RISKS_CONFIG_FILE}"

    cat << EOF > "$RISKS_CONFIG_FILE"
; RISKS Vault (domU) Configuration file

; You can either edit this file in place, set values
; through the 'risks config' commands.

; Device file path to the hush partition
SDCARD_ENC_PART=/dev/hush

; Name of LUKS mapper to hush partition
SDCARD_ENC_PART_MAPPER=hush

; Enable sound when hush device is mounted (0: enabled, 1: disabled)
SDCARD_QUIET=0

; Directory mount point for the hush device
HUSH_DIR=/home/user/.hush

; Directory where to store tomb files
GRAVEYARD=/home/user/.graveyard

; Name of LUKS mapper to backup partition
BACKUP_MAPPER=pendev

; Default timeout after which the clipboard is wiped after being filled with GPG passphrase.
GPGPASS_TIMEOUT=45

; The 'risks kv' commands will write to/read from this directory for the currently active identity.
KV_USER_DIR=/home/user/.tomb/mgmt/kv

EOF
    }
}

## Get a value from the config.
## Usage: result=$(config_get hello)
config_get() {

    local key=$1
    local regex="^$key *= *(.+)$"
    local value=""

    config_init

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ $regex ]]; then
            value="${BASH_REMATCH[2]}" # Changed to 2 because ZSH indexes start at 1
            break
        fi
    done < "$RISKS_CONFIG_FILE"

    echo "$value"
}

## Add or update a key=value pair in the config.
## Usage: config_set key value
config_set() {

    local key=$1
    shift
    local value="$*"

    config_init

    local regex="^($key) *= *.+$"
    local output=""
    local found_key=""
    local newline

    while IFS= read -r line || [ -n "$line" ]; do
        newline=$line
        if [[ $line =~ $regex ]]; then
            found_key="${BASH_REMATCH[2]}"
            newline="$key = $value"
            output="$output$newline\n"
        elif [[ $line ]]; then
            output="$output$line\n"
        fi
    done < "$RISKS_CONFIG_FILE"

    if [[ -z $found_key ]]; then
        output="$output$key = $value\n"
    fi

    printf "%b\n" "$output" > "$RISKS_CONFIG_FILE"
}

## Delete a key from the config.
## Usage: config_del key
config_del() {
    local key=$1

    local regex="^($key) *="
    local output=""

    config_init

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line ]] && [[ ! $line =~ $regex ]]; then
            output="$output$line\n"
        fi
    done < "$RISKS_CONFIG_FILE"

    printf "%b\n" "$output" > "$RISKS_CONFIG_FILE"
}

## Show the config file
config_show() {
    config_init
    cat "$RISKS_CONFIG_FILE"
}

## Return an array of the keys in the config file.
## Usage:
##
##   for k in $(config_keys); do
##     echo "- $k = $(config_get "$k")";
##   done
##
config_keys() {
    # zsh compat
    setopt local_options BASH_REMATCH

    local regex="^([a-zA-Z0-9_\-\/\.]+) *="

    config_init

    local keys=()
    local key

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ $regex ]]; then
            key="${BASH_REMATCH[1]}"
            key="${key//\=/}"
            [[ -n "$key" ]] && keys+=("$key")
        fi
    done < "$RISKS_CONFIG_FILE"
    echo "${keys[@]}"
}

## Returns true if the specified key exists in the config file.
## Usage:
##
##   if config_has_key "key" ; then
##     echo "key exists"
##   fi
##
config_has_key() {
    [[ $(config_get "$1") ]]
}
