#!/bin/bash

# efc_lib.sh [ encrypt / decrypt files.]
# MIT license (MIT)

# functions using the gpg lib to symmetrically encrypt / decrypt individual file.

shopt -s globstar

decrypt() {
    echo -e ' \t' "decrypting the file: $1"
    
    local return_status=0
    
    # capture the output to a temp. file.
    gpg --quiet --yes --batch --passphrase "$2" "$1" 2>>"$1_out"
    
    
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
    
    echo -e ' \t' "encrypting the file: $1"
    
    gpg --quiet --yes --batch --passphrase "$2" -c "$1"
    
    if [ $3 == 'yes' ]; then
        echo -e ' \t' "removing the original file: $1"
        rm -rf "$1"
    fi
    
    return 1
}



remove_zip_after_verify(){
    
    echo "$1"
    if ! tar tf "$1" &> /dev/null; then
        echo -e "\toriginal DIR won't be deleted, error in archive : $1"
    else
        echo -e "\toriginal DIR will be removed! : $2"
        rm -rf "$2"
    fi
}

zip_all_folders(){
    
    find "$1" -print |
    while read file; do
        
        if [[ -d "$file" ]] && [[  "$file" != "$1" ]]; then
            tar_name=$(basename "$file")
            tar_fq_name="$1/$tar_name.tar.gz"
            
            echo -e "Found : DIR  $file , archiving as : $tar_fq_name"
            tar -cvf "$tar_fq_name" "$file"
            
            remove_zip_after_verify "$tar_fq_name" "$file"
        fi
        
    done
}
