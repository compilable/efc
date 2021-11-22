#!/bin/bash

# efc_single [ encrypt / decrypt a single file]
# Version 1.0.2
# MIT license (MIT)

# Util script to symmetrically encrypt / decrypt individual file or given folder using the gpg lib.
: '
Features:
- Accept user given path to a folder or a file.
- Request user to enter a password.
- Encrypt/Decrypt file(s).
- User can choose the delete the source files.
'

# Load the util functions
source "efc_lib.sh"

ts=$(date +%s)
count=0

user_input() {
    
    read -p "Delete the source file ? (yes/no) : " isDelete
    
    if [ $isDelete == 'yes' ]; then
        echo -e ' \t' "source file will be DELETED!"
    fi
    
    while true; do
        read -p "Encrypt or Decrypt ? (e/d) : " isEnrypt
        
        # (2) handle the input we were given
        case $isEnrypt in
            [eE]*)
                echo -e ' \t'  "all the files will be Encrypted!"
                break
            ;;
            
            [dD]*)
                echo -e ' \t'  "all the files will be Decrypted!"
                break
            ;;
            
            *) echo -e ' \t'  "please enter e for Encrypt  or d for Decrypt." ;;
        esac
    done
    
    echo -n "Provide the password for the operation : "
    read -s password
    
    if [ -z "$password" ]; then
        echo "provided password is empty, exiting."
        exit
    else
        echo -e ' \n\t'  "starting the operation using the provided password."
    fi
    
}

process_folder() {
    
    
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    # set me
    FILES="$1/*"
    for file in $FILES
    do
        
        echo -e ' \n' "PROCESSING THE FILE : $file"
        if [[ $isEnrypt == 'e' ]]; then
            encrypt "$file" "$password" $isDelete
        fi
        
        if [[ $isEnrypt == 'd' ]]; then
            decrypt "$file" "$password" $isDelete
        fi
        
    done
    
    
    : 'echo "location : $1"
    for file in "$1/**"; do
        echo "XXX $file"
        if [[ -d "$file" ]]; then
            echo "reading the folder : $file"
        elif [[ -f "$file" ]]; then

            if [[ $isEnrypt == 'e' ]]; then
                encrypt "$file" "$password" $isDelete
            fi

            if [[ $isEnrypt == 'd' ]]; then
                decrypt "$file" "$password" $isDelete
            fi

        fi
    done '
}

process_file() {
    
    if [[ $isEnrypt == 'e' ]]; then
        encrypt "$1" "$password" $isDelete
    fi
    
    if [[ $isEnrypt == 'd' ]]; then
        decrypt "$1" "$password" $isDelete
    fi
    
}

if [ $# -eq 0 ]; then
    echo "No folder/file provided, exiting."
    exit 1
    elif [[ -d $1 ]]; then
    echo "Using the directory : $1"
    user_input
    process_folder "$1"
    elif [[ -f $1 ]]; then
    echo "Using the file : $1"
    user_input
    process_file "$1"
else
    echo "invalid input, must be a folder or a file : $1"
fi

echo -e ' \n' "TOTAL OF $count FILES PROCESSED."
