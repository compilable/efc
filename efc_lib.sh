#!/bin/bash

# efc_lib.sh [ encrypt / decrypt files.]
# Version 1.1
# MIT license (MIT)

# functions using the gpg lib to symmetrically encrypt / decrypt individual file.

shopt -s globstar

decrypt() {
    echo -e ' \t' "decrypting the file: $1"

    local return_status=0

    # capture the output to a temp. file.
    gpg --quiet --yes --batch --passphrase "$2" "$1" 2>>"$1_out"

    if grep -q failed "$1_out"; then
        echo -e ' \t' "invalid key/file is provided!, file is ignored!"
    else

        if [ $3 == 'yes' ]; then
            echo -e ' \t' "removing the original file $1"
            rm -rf "$1"
        fi
        return_status=1
    fi

    rm -rf "$1_out"

    return $return_status
}

encrypt() {

    echo -e ' \t' "encrypting the file: $1"

    gpg --quiet --yes --batch --passphrase "$2" -c "$1"

    if [ $3 == 'yes' ]; then
        echo -e ' \t' "removing the original file: $1"
        rm -rf "$1"
    fi

    return 1
}
