
_set_identity "${args['identity']}"

_info "Closing PASS tomb ..."
_run close_tomb "$PASS_TOMB_LABEL"

_info "Closing SSH tomb ..."
_run close_tomb "$SSH_TOMB_LABEL"

_info "Closing Management tomb ..."
_run close_tomb "$MGMT_TOMB_LABEL"

# Finally, find all other tombs...
tombs=$(tomb list 2>&1 \
    | sed -n '0~4p' \
    | awk -F" " '{print $(3)}' \
    | rev | cut -c2- | rev | cut -c2-)

# ... and close them
while read -r tomb_name ; do
    if [[ -z $tomb_name ]]; then
        continue
    fi

    _info "Closing tomb $tomb_name ..."
    _run tomb close "$tomb_name"
done <<< "$tombs"

_info "Closing GPG coffin ..."
close_coffin
