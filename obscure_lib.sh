#!/bin/bash

# obscure_lib.sh [ read a folder, generate an index file containing list of files with obscured file name to be encrypted; use the index file when decrypting ]
# MIT license (MIT)

: '
# Features
    - support 2 passwords during the process [pword_1 for enc/dec index file, pword_2 for enc/dec folder content]
    - use AES256 to generate the public key containing the encrypted index file.
    - optional - validate the checksum of files

# PROCESS : Encryption
    - 1 generating the index file based on given pword (pword_1)
    - 2 decrypt & read the index file
    - 3 encrypting the files listed on the index file based on the given pword (pword_2) and set output as obscured file name
    - 3 remove the decrypted index file.
    
# PROCESS : Decryption
    - 1 decrypt the the index file based on given pword (pword_1)
    - 2 Read the index file to decrypt the files listed on the index file based on the given pword (pword_2)
    - 3 remove the decrypted index file.  
'

source_path=$(pwd)
source "./efc_lib.sh"

obscure_file_name() {
    # generate a string containing : random_text ;-; md5sum ;-; file_name ;-;

    checksum=$(sha1sum "$1")
    checsum_data=(${checksum//;/ })
    random_name=$(xxd -l 12 -c 12 -p </dev/random)
    relative_path=$(
        cd "$(dirname "$1")"
        pwd -P
    )/$(basename "$1")
    #$(echo "$1" | cut -f2-)
    local obscured_text="$random_name ;-; ${checsum_data[0]} ;-; "$relative_path" ;-; "
    echo "$obscured_text"
}

encrpt_decrypt_index_file() {
    # $1 = source file - fq path
    # $2 = password (pword_1)
    # $3 = operation (e/d)

    if [ $3 == 'e' ]; then
        echo -e "INFO :: encrypting the index file into a PGP public key : $1.asc"
        gpg --quiet --yes --batch --passphrase "$2" -a --symmetric --cipher-algo AES256 "$1"
        echo -e "INFO :: removing the index file: $1"
        rm -rf "$1"
    else

        trap 'rm -f "$index_output"' EXIT
        temp_name=$(
            date +%s | sha256sum | base64 | head -c 8
            echo
        )
        index_output=$(mktemp -t efc_v4.XXXXX$temp_name) || exit 1
        echo -e "INFO :: decrypting the encrypted index file : $1 to : $index_output"
        gpg --output "$index_output" -quiet --yes --batch --passphrase "$2" -a --decrypt "$1" 2>>"$1_out"
        if [ -s "$1_out" ]; then
            echo -e ' \t' "invalid key/file is provided!, index file is ignored!"
            return 0
        else
            echo -e "INFO :: index file is decrypted to : $index_output"
            export INDEX="$index_output"
        fi

    fi

}

construct_index_file() {
    # $1 = source folder to search and generate the index file content
    # $2 = pword for the index file
    # $3 = index file destination
    # $4 = index file name (optional)

    index_file=""

    if [ -z "$4" ]; then
        # 1 create the index file.
        ts=$(date +%Y%m%d%H%M%S)
        echo -e "index file name is not provided, using a random file name : $ts"
    else
        echo -e "index file name is provided, using a the file name : $4"
    fi

    if [ -z "$3" ]; then
        echo -e "INFO :: index file destination not provided, creating the index file in the source folder : $1"
        index_file="$1/.$4"
    else
        echo -e "INFO :: index file destination provided, creating the index file in : $3"
        index_file="$3/.$4"
    fi
    fq_path=$(echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")")
    echo "$fq_path" >"$index_file"

    if test -f "$index_file"; then
        echo -e "INFO :: index file created : $index_file"
    else
        echo -e "ERROR :: unable to create index file : $index_file"
        exit
    fi

    file_count=0

    # 2 traverse the source folder and append file details (name, hash, obsecred file)
    find "$1" -print |
        {
            while read file; do
                echo "RESOURCE :: $file"

                if [[ -d $file ]]; then
                    echo -e "\t Insdie : DIR  $file"
                else
                    base_name=$(basename "${file}")

                    if [[ "$base_name" == .* ]]; then
                        echo -e ' \t' "ignoring hidden file $file"

                    else
                        echo -e ' \t' "Adding to Index :: file $file"
                        result=$(obscure_file_name "$file")
                        file_data=(${result//;-;/ })
                        obscred_file_name=$(echo ${file_data[0]} | sed 's/ *$//g')
                        checksum=$(echo "${file_data[1]}" | sed 's/ *$//g')

                        #DIR="$(dirname "${file}")"
                        #echo -e "obscre_file_name=$DIR/$obscred_file_name , checksum=$checksum , source_file="$file""
                        #mv "$file" "$DIR/$obscred_file_name"
                        echo "$result" >>"$index_file"
                        let file_count=file_count+1
                        echo "FILE COUNT : $file_count"

                    fi
                fi
            done

            echo -e "\nINFO :: total of $file_count files processed."

            encrpt_decrypt_index_file "$index_file" "$2" "e"
            echo "herex  $index_file"
            export INDEX="$index_file"
        }
}

reconstruct_index_file() {
    # $1 = path for a encyrpted-index file
    # $2 = pword for the index file

    fq_path=$(echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")")
    echo "xxxx $fq_path"

    if test -f "$fq_path"; then
        echo -e "INFO :: index file exists : $fq_path"
    else
        echo -e "ERROR :: unable to locate the index file on : $fq_path"
        exit
    fi

    # decrypt the index file
    #encrpt_decrypt_file "$1" "$password" "$1" "d"
    echo "re-constructing the index file ..."
    encrpt_decrypt_index_file "$1" "$2" "$1" "d"
    index_file="$1"
    rm -rf "$1"_out

}

decrypt_index_content() {
    # need to set the terminal level variable INDEX

    echo "$INDEX"

    if [ -z "${INDEX}" ]; then
        echo "no index file found, exiting"
        return
    fi

    # read file line by line
    while IFS= read -r line; do
        echo "read the line : $line"

        is_valid_line=$(echo "$line" | grep -o " ;-; " | wc -l)

        if [ $is_valid_line == 3 ]; then
            echo -e "\tdecrypting the file : $line"

            IFS=';' read -ra obscre_file_details <<<"$line"
            # random_text ;-; md5sum ;-; file_name ;-;

            DIR="$(dirname "${obscre_file_details[4]}")"
            echo -e "\t\t  obscre_file = $DIR/${obscre_file_details[0]}"
            echo -e "\t\t  md5sum = ${obscre_file_details[2]}"
            echo -e "\t\t  file_name = ${obscre_file_details[4]}"

            src=$(echo "$DIR/${obscre_file_details[0]}" | xargs)
            des=$(echo "${obscre_file_details[4]}" | xargs)

            #mv "$src" "$des"
            echo -e ' \t' "DEC :: file $file"
            #decrypt "$des" "$password" $isDelete

            #encrpt_decrypt_file "$src" "$password" "d"
            # $1 = source file - fq path
            # $2 = password
            # $3 = operation (e/d)

        else

            echo "ignoring the line due to content format : $line == $is_valid_line"
        fi

    done \
        <"${INDEX}"
}

encrypt_index_content() {
    # need to set the terminal level variable INDEX
    # $1 = password (pword_2)

    # read the index file,
    # apply encryption with the obsecred file name

    echo "$INDEX"

    if [ -z "${INDEX}" ]; then
        echo "no index file found, exiting"
        return
    fi

    if [ -z "${1}" ]; then
        echo "no encryption password provided, exiting"
        return
    fi

    # read file line by line
    while IFS= read -r line; do
        echo "read the line : $line"

        is_valid_line=$(echo "$line" | grep -o " ;-; " | wc -l)

        if [ $is_valid_line == 3 ]; then
            echo -e "\tencrypting the file : $line"

            IFS=';' read -ra obscre_file_details <<<"$line"
            # random_text ;-; md5sum ;-; file_name ;-;

            DIR="$(dirname "${obscre_file_details[4]}")"
            echo -e "\t\t  obscre_file = $DIR/${obscre_file_details[0]}"
            echo -e "\t\t  md5sum = ${obscre_file_details[2]}"
            echo -e "\t\t  file_name = ${obscre_file_details[4]}"

            src=$(echo "$DIR/${obscre_file_details[0]}" | xargs)
            des=$(echo "${obscre_file_details[4]}" | xargs)

            #mv "$src" "$des"
            echo -e ' \t' "ENC :: file $file"
        else
            echo "ignoring the line due to content format : $line == $is_valid_line"
        fi
    done \
        <"${INDEX}"
}

process_indexed_content() {
    # $1 = operation (e/d)
    # $2 = password (pword_2)

    # need to set the terminal level variable INDEX
    if [ -z "${INDEX}" ]; then
        echo "no index file found, exiting. please run the : reconstruct_index_file() prior to this step."
        return
    fi

    if [ -z "${1}" ]; then
        echo "no operation is provided, exiting"
        return
    elif [[ "$1" == "e" || "$1" == "d" ]]; then
        echo "valid operation is provided $1"
    else
        echo "no valid operation is provided, exiting"
        return
    fi

    if [ -z "${2}" ]; then
        echo "no encryption password provided, exiting"
        return
    fi

    echo -e "INFO :: processing the the index file content : $INDEX"
    fq_path=''
    file_count=0

    # read file line by line
    while IFS= read -r line; do
        echo -e "INFO :: readin the line : $line"

        is_valid_line=$(echo "$line" | grep -o " ;-; " | wc -l)

        if [ $is_valid_line == 3 ]; then

            IFS=';' read -ra obscre_file_details <<<"$line"

            DIR="$(dirname "${obscre_file_details[4]}")"
            echo -e "\t\t  obscre_file = $DIR/${obscre_file_details[0]}"
            echo -e "\t\t  md5sum = ${obscre_file_details[2]}"
            echo -e "\t\t  file_name = ${obscre_file_details[4]}"

            des=$(echo "/${obscre_file_details[0]}" | xargs)
            src=$(echo "${obscre_file_details[4]}" | xargs)

            if [ $1 == 'e' ]; then
                echo -e ' \t' "OBS :: file $src -> $fq_path$des"
                echo -e ' \t' "ENC :: file $file"

                encrypt "$src" "${2}" "yes" "$fq_path/$des"
                # $1 = fq file name
                # $2 = password
                # $3 = delete flag (yes/no)
                # $4 = output file name [optional]

                dir_path=$(dirname "$src")
                echo -e "\nINFO :: deleting the sub-folders :  $fq_path"
                find "$fq_path" -type d -empty -delete

            elif
                [ $1 == 'd' ]
            then
                echo -e ' \t' "OBS :: file $fq_path/$des -> $src"
                echo -e ' \t' "DEC :: file $file"

                decrypt "$fq_path$des" "${2}" "yes" "$src"
                # $1 = fq file name
                # $2 = password
                # $3 = delete flag (yes/no)
                # $4 = output file name [optional]
            fi

            let file_count=file_count+1
            echo "FILE COUNT : $file_count"

        else
            if [ -z "$fq_path" ]; then
                echo -e "INFO :: setting the FQ path to : $line"
                fq_path="$line"
            else
                echo -e "INFO :: ignoring the line due to content format : $line == $is_valid_line"
            fi
        fi

    done \
        < \
        \
        "${INDEX}"

    echo -e "\nINFO :: total of $file_count files processed."
    echo -e "\nINFO :: deleting the decrypted index file :  ${INDEX}"
    rm -rf "${INDEX}"

}
