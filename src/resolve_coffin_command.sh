
identity.set "${args['identity']}"

coffin_filename=$(crypt.filename "${IDENTITY}-gpg.coffin")
print "${GRAVEYARD}/${coffin_filename}"
