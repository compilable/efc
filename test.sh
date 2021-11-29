#!/bin/bash

source "efc_lib.sh"

list_files_with_space() {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    # set me
    FILES="$1/*"
    for f in $FILES; do
        echo "$f"
    done
}

# list_files_with_space "../Neil Yuen/Neil Yuen/"

test_decrypt() {
    shopt -s globstar

    gpg --quiet --yes --batch --passphrase "$2" "$1" 2>>"$1_out"

    if grep -q failed "$1_out"; then
        echo "faild"
    fi

    rm -f -- "$1_out"
}

list_all_files_in_dir() {

    find "/home/aeronx/Desktop/Files/efc" -print |
        while read filename; do
            echo "FILE :: $filename"
        done
}

# list_all_files_in_dir

count=0
increase_count() {
    if [ $1 -eq 1 ]; then
        count=$((count + 1))
    fi
}

calculate_count() {

    encrypt "test/success.gif" "test123x" "no"
    increase_count $?
    encrypt "test/ASIC-pre-loader.gif" "test123x" "no"
    increase_count $?

    #decrypt "$1" "test123x" "no"
    #local res=$?
    echo -e "TTTTTT $count"
}

# calculate_count $1
