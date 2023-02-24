
resource="${args['resource']}"

_set_identity "${args['identity']}"
check_hush_mounted

# Then derive the gpg pass phrase from it, with one-time use,
# needed for all tombs, no matter how many. Only ask for it
# if it is not yet in the GPG agent cache.
if ! is_gpg_passphrase_cached ; then
    GPG_PASS=$(get_passphrase "$GPG_TOMB_LABEL")
    echo -n "$GPG_PASS" | xclip -loops 1 -selection clipboard
    _warning "GPG passphrase copied to clipboard with one-time use only"
fi

_run open_tomb "$resource"
