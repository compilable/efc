#!/bin/bash

# efc_loose_single [ encrypt / decrypt all the files in a given folder as SEPERATELY.]
# Version 1.0

# Atomated script to symmetrically encrypt / individual files on a folder.
# Features:
## Accept user given path to a folder.
## Request user to enter a password.
## Encrypt ALL the files found inside the folder and sub-folders as selerate.

# Input parameters
## Folder path

shopt -s globstar


decrypt ()
{
    echo "decrypting the file: $1"
    
    gpg --quiet --yes --batch --passphrase "$password" "$1"
    
    if [ $isDelete == 'yes' ]
    then
        echo "removing the original file $1"
        rm -rf "$1"
    fi
    count=$((count+1))
}

encrypt() {
    
    echo "encrypting the file: $1"
    
    gpg --quiet --yes --batch --passphrase "$password" -c "$1"
    
    if [ $isDelete == 'yes' ]
    then
        echo "removing the original file $1"
        rm -rf "$1"
    fi
    
    
    count=$((count+1))
}

count=0

echo "Delete the source file ? (yes/no)"

read isDelete

if [ $# -eq 0 ]
then
    echo "No arguments provided, source is NOT deleted."
fi


if [ $# == 'yes' ]
then
    echo "source file will be DELETED!"
fi



echo "Encrypt or Decrypt ? (e/d)"

read isEnrypt

if [ $# -eq 0 ]
then
    echo "No opration is provided, ignoring."
    exit 1
fi


if [ $isEnrypt == 'e' ]
then
    echo "all the files will be Encrypted!"
fi


if [ $isEnrypt == 'd' ]
then
    echo "all the files will be Decrypted!"
fi

if [ $isEnrypt != 'e' ] && [ $isEnrypt != 'd' ]
then
    echo "invalid operation!, existing"
    exit
fi



echo -n "Provide the password for the operation : ":
read -s password




for file in $1/**
do
    if [ -d "$file" ];then
        echo "dir: $file"
        elif [ -f "$file" ]; then
        
        if [ $isEnrypt == 'e' ]
        then
            encrypt "$file"
        fi
        
        if [ $isEnrypt == 'd' ]
        then
            decrypt "$file"
        fi
        
    fi
done

echo "/n total of $count files processed."

