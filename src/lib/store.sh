
# print to stderr, red color
function kv.echo_err ()
{
    echo -e "\e[01;31m$@\e[0m" >&2
}

# Usage: kv.validate_key <key>
function kv.validate_key ()
{
    [[ "$1" =~ ^[0-9a-zA-Z._:-]+$  ]]
}

# Usage: kvget <key>
function kv.get ()
{
    key="$1"
    kv.validate_key "$key" || {
        _failure "db" 'invalid param "key"'
            return 1
        }
        kv_user_dir=${KV_USER_DIR:-$DEFAULT_KV_USER_DIR}
        value="$([ -f "$kv_user_dir/$key" ] && cat "$kv_user_dir/$key")"
        echo "$value"

        [ "$value" != "" ]
    }

# Usage: kvset <key> [value]
function kv.set ()
{
    key="$1"
    value="$2"
    kv.validate_key "$key" || {
        _failure "db" 'invalid param "key"'
            return 1
        }
        kv_user_dir=${KV_USER_DIR:-$DEFAULT_KV_USER_DIR}
        test -d "$kv_user_dir" || mkdir "$kv_user_dir"
        echo "$value" > "$kv_user_dir/$key"
        _info "${key} => ${value}"
    }

function kv.append ()
{
    key="$1"
    value="$2"
    kv.validate_key "$key" || {
        _failure "db" 'invalid param "key"'
            return 1
        }
        kv_user_dir=${KV_USER_DIR:-$DEFAULT_KV_USER_DIR}
        test -d "$kv_user_dir" || mkdir "$kv_user_dir"
        echo "$value" >> "$kv_user_dir/$key"
        _info "${key} => ${value}"
}

# Usage: kvdel <key>
function kv.del ()
{
    key="$1"
    kv.validate_key "$key" || {
        _failure "db" 'invalid param "key"'
            return 1
        }
        kv_user_dir=${KV_USER_DIR:-$DEFAULT_KV_USER_DIR}
        test -f "$kv_user_dir/$key" && rm -f "$kv_user_dir/$key"
        _info "Deleted key '${key}'"
    }

function kv.filter ()
{
    key="$1"
    shift
    local values=("$@")

    [[ -z "${key}" || -z "${values[*]}" ]] && return

    # Retrieve the existing key value, or skip.
    local existing_value
    existing_value="$(kv.get "${key}")"
    [[ -z "${existing_value}" ]] && return

    # And remove each key if found.
    for val in "${values[@]}"; do
        [[ -n "${val}" ]] || continue
        existing_value=$(sed /^"$val"\$/d <<<"${existing_value}")
    done

    # Either save the reduced value, or unset the key if empty.
    if [[ -z "${existing_value}" ]]; then
        kv.unset "${key}"
    else
        kv.set "${key}" "${existing_value}"
    fi
}

# list all key/value pairs to stdout
# Usage: kvlist
function kv.list ()
{
    kv_user_dir=${KV_USER_DIR:-$DEFAULT_KV_USER_DIR}
    for i in "$kv_user_dir/"*; do
        if [ -f "$i" ]; then
            key="$(basename "$i")"
            echo "$key" "$(kvget "$key")"
        fi
    done
}

# clear all key/value pairs in database
# Usage: kvclear
function kv.clear ()
{
    rm -rf "${KV_USER_DIR:-$DEFAULT_KV_USER_DIR}"
}
