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
                location=$(dirname "$file")
                tar_name=$(basename "$file")
                tar_fq_name="$location/$tar_name.tar.gz"

                echo -e "\tfound : DIR  $file , archiving as : $tar_fq_name"
                tar -cvf "$tar_fq_name" "$file"

                remove_zip_after_verify "$tar_fq_name" "$file"
            fi

        done

}

#zip_all_folders $1

check_path() {
    if [ $# -eq 0 ]; then
        echo "No folder/file provided, exiting."
    elif [[ -d "$1" ]]; then
        echo "Using the directory : $1"
    elif [[ -f $1 ]]; then
        echo "Using the file : $1"
    else
        echo "invalid input, must be a folder or a file : $1"
    fi
}

check_path "$1"
