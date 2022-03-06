#!/bin/bash

source "./efc_lib.sh"

read_version() {
    while IFS= read -r line; do
        if [[ "$line" == ???EFC* ]]; then
            echo -e "$line"
            break
        fi
    done <CHANGELOG.md
}

obscure_file_name() {
    # generate a string containing : random_text ;-; md5sum ;-; file_name ;-;
    
    checksum=$(md5sum "$1")
    checsum_data=(${checksum//;/ })
    random_name=$(xxd -l 12 -c 12 -p </dev/random)
    local obscured_text="$random_name ;-; ${checsum_data[0]} ;-; $1 ;-; "
    echo "$obscured_text"
}

process_all_files_in_dir() {
    
    # 1 create a file based on . ts
    index_file="$1.$(date +%Y%m%d%H%M%S)"
    echo "$1" >"$index_file"
    echo -e "INFO :: index file created : $index_file"
    
    file_count=0
    
    # 2 append each file details
    find "$1" -print |
    {
        while read file; do
            echo "RESOURCE :: $file"
            
            if [[ -d $file ]]; then
                echo -e "\t Insdie : DIR  $file"
            else
                
                if [[ $isEnrypt == 'e' ]]; then
                    
                    
                    base_name=$(basename "${file}")
                    
                    if [[ "$base_name" == .* ]]; then
                        echo -e ' \t' "ignoring hidden file $file"
                        
                    else
                        echo -e ' \t' "ENC :: file $file"
                        result=$(obscure_file_name "$file")
                        file_data=(${result//;-;/ })
                        obscre_file_name=$(echo ${file_data[0]} | sed 's/ *$//g')
                        checksum=$(echo "${file_data[1]}" | sed 's/ *$//g')
                        echo -e "obscre_file_name=$obscre_file_name , checksum=$checksum , source_file="$file""
                        
                        echo "$result" >>$index_file
                        let file_count=file_count+1
                        echo "processing the $file_count file."
                        #encrypt "$file" "$password" $isDelete
                        
                    fi
                fi
                
                if [[ $isEnrypt == 'd' ]]; then
                    echo -e ' \t' "DEC :: file $file"
                    #decrypt "$file" "$password" $isDelete
                fi
                
            fi
            
        done
        
        echo -e "INFO :: total of $file_count files processed, encrypting the index file."
        
        # encrpt the index file with same file name
        #gpg --output test/test_data/.20220218000221x --quiet --yes --batch --passphrase "123" -c test/test_data/.20220218000221
        encrpt_decrypt_file "$index_file" "$password" "e"
    }
}

encrpt_decrypt_file(){
    # $1 = source file - fq path
    # $2 = password
    # $3 = operation (e/d)
    
    if [ $3 == 'e' ]; then
        echo -e "INFO :: encrypting the index file $1"
        gpg --quiet --yes --batch --passphrase "$2" -a --symmetric --cipher-algo AES256 "$1"
        echo -e "INFO :: removing the index file: $1"
        rm -rf "$1"
    else
        echo -e "INFO :: decrypting the encrypted index file: $1"
        index_output="$(dirname "${1}")/$(basename "${1%.*}")"
        gpg --output "$index_output" -quiet --yes --batch --passphrase "$2" -a --decrypt "$1" 2>>"$1_out"
        
        if [ -s "$1_out" ]; then
            echo -e ' \t' "invalid key/file is provided!, index file is ignored!"
        else           
            echo -e "INFO :: index file is decrypted to : $index_output"
        fi
        
    fi
    
}

start_decription_process(){
    
    if [[ -d "$1" ]]; then
        
        # find the index file on the given dir. with the timestamp descending order into an array
        file_list=($(find "$1" -maxdepth 1 -name ".*[0-9]*" -printf "%f  \n"|sort -n -t _ -k 2 -r))
        length="${#file_list[@]}"
        latest_index=${file_list[0]}
        
        echo -e "INFO :: reading the the location for index files : $1"
        
        if [ "$length" == 0 ]; then
            echo -e ' \t' "no index files found, decrypting all the files.."
            elif [  "$length" == 1 ]; then
            echo -e ' \t' "index file found, using the file for decryption, $latest_index"
            
        else
            echo -e ' \t' "multiple index files found ($length), using the latest file for decryption =  $latest_index"
        fi
        
        # decrypt the index file
        encrpt_decrypt_file "$1$latest_index" "$password" "d"
        
        elif [[ -f $1 ]]; then
        
        # decrypt the index file
        encrpt_decrypt_file "$1" "$password" "$1" "d"
        
    else
        echo -e '\n' "invalid input, must be a folder or a file : $1"
    fi
    
    
    
    
    
    
    # read file line by line
    
}


function load_file_list(){
    while IFS= read -r line; do
        printf '%s\n' "$line"
        
        result=$line
        file_data=(${result//;-;/ })
        obscre_file_name=$(echo ${file_data[0]} | sed 's/ *$//g')
        checksum=$(echo "${file_data[1]}" | sed 's/ *$//g')
        source_file=$(echo "${file_data[2]}" | sed 's/ *$//g')
        echo -e "obscre_file_name=$obscre_file_name , checksum=$checksum , source_file="$source_file" \n"
        
    done < "$1"
}


password="123x"
isDelete='no'
isEnrypt='e'

process_all_files_in_dir $1

start_decription_process "$1"


#obscure_file_name "test\test_data\folder name spaces @ ! test ) (\approve-file-16x16-1214257.png"

