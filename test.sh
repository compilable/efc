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
    # generate a string containing : md5sum,file_name,random_text

    checksum=$(md5sum "$1")
    checsum_data=(${checksum//;/ })
    random_name=$(xxd -l 12 -c 12 -p </dev/random)
    local obscured_text="$random_name ;-; ${checsum_data[1]} ;-; ${checsum_data[0]}"
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
            echo "FILE :: $file"

            if [[ -d $file ]]; then
                echo "Insdie : DIR  $file"
            else

                if [[ $isEnrypt == 'e' ]]; then

                    echo "ENC" $file
                    result=$(obscure_file_name "$file")
                    file_data=(${result//;-;/ })
                    obscre_file_name=$(echo ${file_data[0]} | sed 's/ *$//g')
                    source_file=$(echo ${file_data[1]} | sed 's/ *$//g')
                    checksum=$(echo ${file_data[2]} | sed 's/ *$//g')
                    echo -e "obscre_file_name=$obscre_file_name , checksum=$checksum , source_file=$source_file"

                    echo $result >>$index_file

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

password="123"
isDelete='no'
isEnrypt='e'

process_all_files_in_dir $1
