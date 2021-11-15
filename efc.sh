#1/bin/bash

# efc_single [ encrypt / decrypt a single file]
# Version 1.0.1

# Atomated script to symmetrically encrypt / decrypt a single file.
# Features:
## Accept user given path to a folder.
## Request user to enter a password.
## Ceate a zip file of the given folder.
## Encrypt the zip file.
## Generate the MD5 of the ZIP file.
## Create a TXT file containing the MD5, Name and Password in user Home directory.
## User can choose the delete the source files.
## Provided password will be saved to a text file.

# Input parameters
## Folder/File path

ts=$(date +%s)

while test $# -gt 0; do
    case "$1" in
        -ed)
            shift
            
            if [ ! -d "$1" ]; then
                echo "folder doesn't exist."
                break
            fi
            
            
            sh efc_encrypt_all.sh "$1"
            
            # TODO ZIP folder & encrypt
            
            shift
        ;;
        -ef)
            shift
            
            if [ ! -f "$1" ]; then
                echo "file doesn't exist."
                break
            fi
            
            
            echo -n Password:
            read -s password
            
            
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
            
            FILE_PATH=$1
            basename "$FILE_PATH"
            FILE=$(basename -- "$FILE_PATH")
            FILE_NAME=$(basename -- "$FILE_PATH").gpg
            echo "Creating the secure file : $FILE_PATH"
            
            gpg --quiet --yes --batch --passphrase "$password" -c "$FILE_PATH"
            
            md5=`md5sum "$FILE_PATH"`
            
            echo "Generating Checksum : $md5"
            
            keyFile=~/"$FILE"_$ts.kye.efc
            
            echo "Password will be backup in : ~/$keyFile"
            echo "$md5 -> $password" > "$keyFile"
            
            echo "Removing the original..."
            
            
            if [ $isDelete == 'yes' ]
            then
                echo "removing the original file $1"
                rm -rf "$1"
            fi
            
            shift
        ;;
        -df)
            shift
            
            if [ ! -f "$1" ]; then
                echo "file doesn't exist."
                break
            fi
            
            
            echo -n Password:
            read -s password
            
            FILE_PATH=$1
            basename "$FILE_PATH"
            FILE=$(basename -- "$FILE_PATH")
            FILE_NAME=$(basename -- "$FILE_PATH").gpg
            echo "Decrypting the secure file : $FILE_NAME"
            
            gpg --quiet --yes --batch --passphrase "$password" "$FILE_PATH"
            
            
            echo "\n Delete the source file ? (yes/no)"
            
            read isDelete
            
            if [ $# -eq 0 ]
            then
                echo "No arguments provided, source is NOT deleted."
            fi
            
            
            if [ $# == 'yes' ]
            then
                echo "source file will be DELETED!"
            fi
            
            if [ $isDelete == 'yes' ]
            then
                echo "removing the original file $1"
                rm -rf "$1"
            fi
            
            
            shift
        ;;       
        -dd)
            shift
            
            if [ ! -d "$1" ]; then
                echo "folder doesn't exist."
                break
            fi
            
            
            sh ./efc_encrypt_all.sh "$1"
            
            
            shift
        ;;
        *)
            echo -e 'invalid options:
        \n\t -ed : encrypt directory
        \n\t -ef : encrypt individual file
            \n\t -df : decrypt file'
            exit
        ;;
    esac
done
