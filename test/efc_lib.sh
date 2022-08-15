#!/bin/bash

# efc_lib.sh [ encrypt / decrypt files.]
# MIT license (MIT)

# functions using the gpg lib to symmetrically encrypt / decrypt individual file.

shopt -s globstar

decrypt() {
    # $1 = fq file name
    # $2 = password
    # $3 = delete flag (yes/no)
    # $4 = output file name [optional]

    echo -e ' \t' "decrypting the file: $1"

    local return_status=0

    if [ -z "${4}" ]; then
        # decrypt to the same file name
        gpg --quiet --yes --batch --passphrase "$2" "$1" 2>>"$1_out"
    else
        # decrypt to a given file name
        gpg --quiet --yes --batch --output "$4" --passphrase "$2" "$1" 2>>"$1_out"
    fi

    if [ -s "$1_out" ]; then
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
    # $1 = fq file name
    # $2 = password
    # $3 = delete flag (yes/no)
    # $4 = output file name [optional]

    echo -e ' \t' "encrypting the file: $1"

    if [ -z "${4}" ]; then
        # encrypt to the same file name.gpg
        gpg --quiet --yes --batch --passphrase "$2" -c "$1"
    else
        # encrypt to a given file name
        gpg --quiet --yes --batch --output "$4" --passphrase "$2" -c "$1"
    fi

    if [ $3 == 'yes' ]; then
        echo -e ' \t' "removing the original file: $1"
        rm -rf "$1"
    fi

    return 1
}

remove_zip_after_verify() {

    echo "$1"
    if ! tar tf "$1" &>/dev/null; then
        echo -e "\toriginal DIR won't be deleted, error in archive : $1"
    else
        echo -e "\toriginal DIR will be removed! : $2"
        rm -rf "$2"
    fi
}

zip_all_folders() {

    find "$1" -print |
        while read file; do

            if [[ -d "$file" ]] && [[ "$file" != "$1" ]]; then
                tar_name=$(basename "$file")
                tar_fq_name="$1/$tar_name.tar.gz"

                echo -e "Found : DIR  $file , archiving as : $tar_fq_name"
                tar -cvf "$tar_fq_name" "$file"

                remove_zip_after_verify "$tar_fq_name" "$file"
            fi

        done
}

read_version() {
    while IFS= read -r line; do
        if [[ "$line" == ???EFC* ]]; then
            echo -e "\n$line"
            break
        fi
    done <CHANGELOG.md
}

print_version_info() {
    read_version
    echo -e "bash version : %s $BASH_VERSION"
    echo -e "gpg version : " $(gpg --version | sed -n 1p)
    echo -e "libgcrypt version : " $(gpg --version | sed -n 2p)
    echo -e "tar version : " $(tar --version | sed -n 1p)
    echo -e "\nThere is NO WARRANTY, to the extent permitted by law; licensed under  MIT license (MIT)"
    echo -e "Written by compilable."
}
