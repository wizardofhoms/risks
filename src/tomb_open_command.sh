
resource="${args['resource']}"

identity.set "${args['identity']}"
hush.fail_device_unmounted

# Then derive the gpg pass phrase from it, with one-time use,
# needed for all tombs, no matter how many. Only ask for it
# if it is not yet in the GPG agent cache.
if ! gpg.passphrase_is_cached ; then
    GPG_PASS=$(crypt.passphrase "$GPG_TOMB_LABEL")
    echo -n "$GPG_PASS" | xclip -loops 1 -selection clipboard
    _warning "GPG passphrase copied to clipboard with one-time use only"
fi

_run tomb.open "$resource"
