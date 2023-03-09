
resource="${args['resource']}"

identity.set "${args['identity']}"

tomb.close "$resource"
exit $?
