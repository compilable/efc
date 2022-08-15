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

# Load the util functions
dependencies_loaded=0

load_dependencies() {
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
        export EFC_PATH="$source_path"
        echo "INFO: setting the EFC_PATH to current location : $EFC_PATH"
        source "$EFC_PATH/efc_lib.sh"
        dependencies_loaded=1
    fi
}

ts=$(date +%s)

read_password_file() {
    password=$(head -n 1 $1)
}

accept_task_flag() {
    if [[ $1 = "e" ]]; then
        isEnrypt='e'
    elif [[ $1 = "d" ]]; then
        isEnrypt='d'
    else
        echo "[error] invalid task! should be e = for encrypt , d = for decrypt"
    fi
}

accept_zip_falg() {
    if [[ $1 = "yes" ]]; then
        zipFolders='yes'
    else
        zipFolders='no'
    fi
}

accept_delete_falg() {
    if [[ $1 = "yes" ]]; then
        isDelete='yes'
    else
        isDelete='no'
    fi
}

user_input() {

    read -p "Delete the source file ? (yes/no) [no] :" isDelete

    if [ -z "$isDelete" ]; then
        echo -e ' \t' "source file will NOT be deleted."
        isDelete='no'
    elif [ $isDelete == 'yes' ]; then
        echo -e ' \t' "source file will be DELETED!"
    fi

    while true; do
        read -p "Encrypt or Decrypt ? (e/d) : " isEnrypt

        case $isEnrypt in
        [eE]*)
            echo -e ' \t' "all the files will be Encrypted!"

            if [[ -d $1 ]]; then

                read -p "Do you want to zip folders found in the path ? (yes/no) [no] : " zipFolders

                if [ -z "$zipFolders" ] && [ "$zipFolders" != 'yes' ]; then
                    echo -e ' \t' "content will be encrypted as separate files."
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

    while true; do

        echo -n "Provide the password for the operation : "
        read -s password

        if [ -z "$password" ]; then
            echo -e '\n\t' "password can not be empty, please provide a valid password."
        else
            break
        fi

    done

    if [ "$isEnrypt" == "e" ]; then

        while true; do

            read -sp "Confirm the password :" password_confirmed

            if [ "$password" == "$password_confirmed" ]; then
                break
            else
                echo -e ' \n\t' "password does not match, please confirm the password."
            fi

        done
    fi

    echo -e ' \n\t' "starting the operation using the provided password." '\n'

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

zip_folder() {
    if [ "$zipFolders" == 'yes' ]; then
        echo "Start archiving process..."
        zip_all_folders "$1" $isDelete
    fi
}

print_help() {

    echo -e "\nUsage: efc [FILE/FOLDER] [OPTIONS...] :

Examples:
\t efc /data/to_encrypt \t# will prompt the user intractive mode.
\t efc -s /data/to_encrypt -t e -p password.txt -d yes -z no \t# will perfom the encryption task on the given folder.

Intractive mode:
\t efc [FILE/FOLDER] \t provide the folder path or file directly without other parameters.

Silent mode:
\t -s | source | source file/folder to encrypt/decrypt.
\t -o | output | output file name or folder location.
\t -t | task | task to perform either encrypt or decrypt.
\t -p | password_file | file containing the password (1st line will be read).
\t -d | delete_source | once the task is completed: yes, to delete the source file.
\t -z | zip_sub_folders | when encrypting yes to zip, the subfolders before that task no to avoid compressing."
}

start_process() {
    if [ $# -eq 0 ]; then
        echo "No folder/file provided, exiting."
        exit 1
    elif [[ "$1" == '--version' ]]; then
        print_version_info
        exit 1
    elif [[ "$1" == '--help' ]]; then
        print_help
        exit 1
    else

        if [[ -d "$1" ]]; then
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
    fi
}

file_has_mearged() { declare -F encrypt >/dev/null; }
dependencies_loaded=$(file_has_mearged && echo 1 || echo 0)

if [ $dependencies_loaded -eq 0 ]; then
    load_dependencies
fi

if [[ $# -gt 1 ]]; then

    while getopts s:o:t:p:d:z: opts; do
        case ${opts} in
        s) source="${OPTARG}" ;;
        o) output="${OPTARG}" ;;
        t) operation="${OPTARG}" ;;
        p) password_file="${OPTARG}" ;;
        d) delete_source="${OPTARG}" ;;
        z) zip_sub_folders="${OPTARG}" ;;
        *)
            echo -e "[error] invalid parameter, \ntry -help for more information"
            exit
            ;;
        esac
    done

    # TODO: implement destination file name change
    echo "$output"

    accept_task_flag "$operation"
    read_password_file "$password_file"
    accept_delete_falg "$delete_source"
    accept_zip_falg "$zip_sub_folders"

    echo "$source"
    echo "$password"
    echo "$isEnrypt"
    echo "$zipFolders"
    echo "$isDelete"

    if [[ -d "$source" ]]; then
        echo "Using the directory : $source"
        zip_folder "$source"
        process_all_files_in_dir "$source"
    elif [[ -f "$source" ]]; then
        echo "Using the file : $source"
        process_file "$source"
    else
        echo -e '\n' "invalid source, must be a folder or a file : $source"
    fi

else
    start_process "$1"
fi
