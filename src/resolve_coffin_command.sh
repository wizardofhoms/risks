
_set_identity "${args[identity]}"

coffin_filename=$(_encrypt_filename "${IDENTITY}-gpg.coffin")
print "${coffin_filename}"