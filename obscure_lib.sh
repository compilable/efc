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

obscure_file_name() {
    # generate a string containing : random_text ;-; md5sum ;-; file_name ;-;

    checksum=$(sha1sum "$1")
    checsum_data=(${checksum//;/ })
    random_name=$(xxd -l 12 -c 12 -p </dev/random)
    local obscured_text="$random_name ;-; ${checsum_data[0]} ;-; $1 ;-; "
    echo "$obscured_text"
}

encrpt_decrypt_index_file() {
    # $1 = source file - fq path
    # $2 = password
    # $3 = operation (e/d)

    if [ $3 == 'e' ]; then
        echo -e "INFO :: encrypting the index file into a PGP public key : $1.asc"
        gpg --quiet --yes --batch --passphrase "$2" -a --symmetric --cipher-algo AES256 "$1"
        echo -e "INFO :: removing the index file: $1"
        rm -rf "$1"
    else

        echo -e "INFO :: decrypting the encrypted index file: $1"
        index_output="$(dirname "${1}")/$(basename "${1%.*}")"
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

generate_index_file() {

    # 1 create the index file based on current ts
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

                        echo "$result" >>$index_file
                        let file_count=file_count+1
                        echo "FILE COUNT : $file_count"
                        #encrypt "$DIR/$obscred_file_name" "$password" $isDelete

                    fi
                fi
            done

            echo -e "\nINFO :: total of $file_count files processed."

            encrpt_decrypt_index_file "$index_file" "$2" "e"
        }
}
