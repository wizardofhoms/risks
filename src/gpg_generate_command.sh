local masterkey_available email uid key_algo expiry fingerprint expert

_set_identity ""
check_hush_mounted

if [[ "${args['--sign']}" -eq 0 ]] && [[ "${args['--encrypt']}" -eq 0 ]]; then
    _failure "You must specify either or both of --sign and --encrypt flags for GPG subkeys"
fi

## Parameters setup
key_algo="${args['--algo']-ed25519}"
expiry="$(_get_expiry "${args['expiry_date']}")"
uid=$(gpg -K | grep uid | head -n 1)
email=$(echo "$uid" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")
masterkey_available="$(get_master_key_status)"
fingerprint=$(gpg -K "${email}" | grep fingerprint | head -n 1 | cut -d= -f2 | sed 's/ //g')
[[ "${args['--expert']}" -eq 1 ]] && expert="--expert"
    
_info "Generating GPG subkey"
_info "Type: ${key_algo}"
_info "Signing: ${args['--sign']} | Encrypting: ${args['--encrypt']}"

_run risks_hush_rw_command

# Check master private in ring,
# If not, open tomb and import master key
if [[ "${masterkey_available}" != true ]]; then
    _info "No master key in keyring, importing from tomb"
    risks_private_import_command
fi

GPG_PASS=$(get_passphrase "$GPG_TOMB_LABEL")

if [[ "${args['--interactive']}" -eq 1 ]]; then
    # If user wants to do this interactively, start the GPG prompt.
    _info "Starting GPG prompt for key generation"
    _warning "Copying GPG passphrase to clipboard"
    echo -n "$GPG_PASS" | xclip -selection clipboard
    gpg --edit-key "${fingerprint}" "${expert}"
else
    # Or generate keys unattended
    generate_subkeys "${key_algo}" "${fingerprint}" "${expiry}"
fi

# Remove master key if was imported
if [[ $masterkey_available != true ]]; then
    _info "Removing master private key from keyring"
    risks_private_remove_command
fi

_run risks_hush_ro_command 

_info "Successfully generated GPG subkey(s)" && return
