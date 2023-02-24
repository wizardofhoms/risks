
resource="${args['resource']}"

_set_identity "${args['identity']}"

close_tomb "$resource"
exit $?
