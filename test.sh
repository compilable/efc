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
    index_file="$1/.$(date +%Y%m%d%H%M%S)"
    echo "$1" >"$index_file"
    echo "index file created : $index_file"
    
    # 2 append each file details
    find "$1" -print |
    while read file; do
        echo "RESOURCE :: $file"
        
        if [[ -d $file ]]; then
            echo -e "\t Insdie : DIR  $file"
        else
            
            if [[ $isEnrypt == 'e' ]]; then
                
                echo "ENC" "$file"
                result=$(obscure_file_name "$file")
                file_data=(${result//;-;/ })
                obscre_file_name=$(echo ${file_data[0]} | sed 's/ *$//g')
                checksum=$(echo "${file_data[1]}" | sed 's/ *$//g')
                echo -e "obscre_file_name=$obscre_file_name , checksum=$checksum , source_file="$file""
                
                
                echo "$result" >>$index_file
                
                base_name=$(basename "${file}")
                [[ "$base_name" = .* ]] && echo "ignoring hidden ..." || encrypt "$file" "$password" $isDelete
                
                #encrypt "$file" "$password" $isDelete
                #increase_count $?
            fi
            
            if [[ $isEnrypt == 'd' ]]; then
                echo "DEC" $file
                #decrypt "$file" "$password" $isDelete
            fi
        fi
        
    done
    
}


read_location_for_index_file(){
    
    # find the index file on the given dir. with the timestamp descending order into an array
    file_list=($(find "$1" -maxdepth 1 -name ".*[0-9]*" -printf "%f  \n"|sort -n -t _ -k 2 -r))
    length="${#file_list[@]}"
    latest_index=${file_list[0]}
    
    if [ "$length" == 0 ]; then
        echo -e ' \t' "no index files found, decrypting all the files.."
    elif [  "$length" == 1 ]; then
        echo -e ' \t' "index file found, using the file for decryption, $latest_index"
        
    else
        echo -e ' \t' "multiple index files found ($length), using the latest file for decryption =  $latest_index"
    fi



# TODO: 

# decrypt file
# encrpt with same file name
# gpg --output test/test_data/.20220218000221x --quiet --yes --batch --passphrase "123" -c test/test_data/.20220218000221 

# decrypt to temp storage
# gpg --output test/test_data/.20220218000221 --quiet --yes --batch --passphrase "123" --decrypt test/test_data/.20220218000221x

    
    # read file line by line 

}


password="123"
isDelete='no'
isEnrypt='e'

#process_all_files_in_dir $1
#read_location_for_index_file "$1"


#obscure_file_name "test\test_data\folder name spaces @ ! test ) (\approve-file-16x16-1214257.png"


while IFS= read -r line; do
                printf '%s\n' "$line"

                result=$line
                file_data=(${result//;-;/ })
                obscre_file_name=$(echo ${file_data[0]} | sed 's/ *$//g')
                checksum=$(echo "${file_data[1]}" | sed 's/ *$//g')
                source_file=$(echo "${file_data[2]}" | sed 's/ *$//g')
                echo -e "obscre_file_name=$obscre_file_name , checksum=$checksum , source_file="$source_file" \n"

done < "$1"