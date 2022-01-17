#!/bin/bash

# efc_single [ encrypt / decrypt a single file]
# MIT license (MIT)

# Util script to symmetrically encrypt / decrypt individual file or given folder using the gpg lib.
: '
Features:
- Accept user given path to a folder or a file.
- Request user to enter a password.
- Encrypt/Decrypt file(s).
- User can choose the delete the source files.
'

# Script version
VERSION=1.0.4

# Load the util functions
dependencies_loaded=0

load_dependencies(){
    # check dependencies exists in current folder, yes -> set variable, no -> read from env. location
    source_path=$(pwd)
    lib_location="$source_path/efc_lib.sh"
    
    if [ ! -f "$lib_location" ]; then
        
        # check for the folder path in bash profile
        if [ -z "$EFC_PATH" ]; then
            echo "WARNING: missing the environmen variable EFC_PATH on local bash profile."
            elif [ ! -f "$EFC_PATH/efc_lib.sh" ]; then
            echo "WARNING: invalid source is provided in the EFC_PATH. It should be the source location."
        else
            echo "INFO: reading the EFC_PATH from local bash profile : $EFC_PATH"
            source "$EFC_PATH/efc_lib.sh"
            dependencies_loaded=1
        fi
    else
        # setting the EFC_PATH location to execution folder
        export EFC_PATH="$source_path/"
        echo "INFO: setting the EFC_PATH to current location : $EFC_PATH"
        source "$EFC_PATH/efc_lib.sh"
        dependencies_loaded=1
    fi
}


ts=$(date +%s)

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
                echo -e ' \t' "all the files will be Encrypted!"
                
                if [[ -d $1 ]]; then
                    
                    read -p "Do you want to zip folders found found in the path ? (yes/no) [no] : " zipFolders
                    
                    if [ -z "$zipFolders" ] && [ "$zipFolders" != 'yes' ]; then
                        echo -e ' \t' "content will be encrypted as seperate files."
                    else
                        echo -e ' \t' "content will be archived and before the encryption."
                    fi
                    
                fi
                
                break
            ;;
            
            [dD]*)
                echo -e ' \t' "all the files will be Decrypted!"
                break
            ;;
            
            *) echo -e ' \t' "please enter e for Encrypt  or d for Decrypt." ;;
        esac
    done
    
    echo -n "Provide the password for the operation : "
    read -s password
    
    if [ -z "$password" ]; then
        echo "provided password is empty, exiting."
        exit
    else
        echo -e ' \n\t' "starting the operation using the provided password."
    fi
    
}

process_all_files_in_dir() {
    find "$1" -print |
    while read file; do
        echo "FILE :: $file"
        
        if [[ -d $file ]]; then
            echo "Insdie : DIR  $file"
        else
            
            if [[ $isEnrypt == 'e' ]]; then
                #encrypt "$file" "$password" $isDelete
                echo "ENC" $file
                encrypt "$file" "$password" $isDelete
                #increase_count $?
                ((counter++))
            fi
            
            if [[ $isEnrypt == 'd' ]]; then
                
                echo "DEC" $file
                decrypt "$file" "$password" $isDelete
                ((counter++))
            fi
        fi
        
    done
    
}

process_file() {
    
    if [[ $isEnrypt == 'e' ]]; then
        encrypt "$1" "$password" $isDelete
    fi
    
    if [[ $isEnrypt == 'd' ]]; then
        decrypt "$1" "$password" $isDelete
    fi
    
}

print_version_info() {
    echo -e "efc version : $VERSION \n"
    printf "bash version : %s\n" $BASH_VERSION
    echo -e "gpg version : " $(gpg --version | sed -n 1p)
    echo -e "libgcrypt version : " $(gpg --version | sed -n 2p)
    echo -e "tar version : " $(tar --version | sed -n 1p)
    echo -e "\nThere is NO WARRANTY, to the extent permitted by law; licensed under  MIT license (MIT)"
    echo -e "Written by compilable"
}

zip_folder() {
    if [ "$zipFolders" == 'yes' ]; then
        echo "Start archiving process..."
        zip_all_folders "$1" $isDelete
    fi
}

start_process() {
    if [ $# -eq 0 ]; then
        echo "No folder/file provided, exiting."
        exit 1
        
        elif [[ "$1" == '--version' ]]; then
        print_version_info
        exit 1
        elif [[ -d "$1" ]]; then
        echo "Using the directory : $1"
        user_input "$1"
        echo -e "\n"
        zip_folder "$1"
        echo -e "\n"
        process_all_files_in_dir "$1"
        elif [[ -f $1 ]]; then
        echo "Using the file : $1"
        user_input $1
        process_file "$1"
    else
        echo -e '\n' "invalid input, must be a folder or a file : $1"
    fi
}


load_dependencies

if [ $dependencies_loaded -eq 0 ]; then
    echo -e '\n' "ERROR: missing dependencies, try the compressed efc script to run without loading dependencies."
else
    start_process "$1"
fi


