#!/bin/bash




list_files_with_space(){
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    # set me
    FILES="$1/*"
    for f in $FILES
    do
        echo "$f"
    done
}


list_files_with_space "../Neil Yuen/Neil Yuen/"



test_decrypt(){
    shopt -s globstar
    
    gpg --quiet --yes --batch --passphrase "$2" "$1"  2>> "$1_out"
    
    
    if grep -q failed "$1_out"; then
        echo "faild"
    fi
    
    rm -f -- "$1_out"
}
