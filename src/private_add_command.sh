
local masterkey_available email uid
local key_algo expiry   # GPG parameters

# Hush and identity checks
if ! is_hush_mounted ; then
    _failure "The hush device is not mounted. Mount it first and rerun the command."
fi

_set_identity ""

if ! _identity_active ; then
    _failure "This command requires an identity to be active"
fi

## Parameters setup
key_algo="${args[--algo]-ed25519}"
expiry="$(_get_expiry "${args[expiry_date]}")"
uid=$(gpg -K | grep uid | head -n 1)
email=$(echo "$uid" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")
    

# If GPG, need access to GPG tomb, or verify that the master private key is in ring.
if [[ "${args[store]}" == "gpg" ]]; then
    masterkey_available="$(get_master_key_status)"

    if [[ "${args[--sign]}" -eq 0 ]] && [[ "${args[--encrypt]}" -eq 0 ]]; then
        _failure "You must specify either or both of --sign and --encrypt flags for GPG subkeys"
    fi
fi

# If GPG ===
if [[ "${args[store]}" == "gpg" ]]; then
    _message "Generating GPG subkey"
    _message "Type: ${key_algo}"
    _message "Signing: ${args[--sign]} | Encrypting: ${args[--encrypt]}"

    _run risks_hush_rw_command
    
    # Check master private in ring,
    # If not, open tomb and import master key
    if [[ "${masterkey_available}" != true ]]; then
        _message "No master key in keyring, importing from tomb"
        risks_private_import_command
    fi

    # Generate keys
    GPG_PASS=$(get_passphrase "$GPG_TOMB_LABEL")
    generate_subkeys "${key_algo}" "${email}" "${expiry}"

    # Remove master key if was imported
    if [[ $masterkey_available != true ]]; then
        _message "Removing master private key from keyring"
        risks_private_remove_command
    fi

    _run risks_hush_ro_command 

    _message "Successfully generated GPG subkey(s)" && return
fi
