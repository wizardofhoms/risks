
resource="${args['resource']}"

identity.set "${args['identity']}"

tomb.slam "$resource"
exit $?
