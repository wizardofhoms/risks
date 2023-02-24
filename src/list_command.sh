
resource="${args['resource']}"

if [[ -z $resource ]]; then
    list_coffins
    echo
    _info "Tombs currently opened:"
    tomb list
    exit $?
fi

if [[ "${resource}" == "coffins" ]]; then
    list_coffins
    exit $?
fi

if [[ "${resource}" == "tombs" ]]; then
    _info "Tombs currently opened:"
    tomb list
    exit $?
fi

_failure "Unknown resource ${resource}"
