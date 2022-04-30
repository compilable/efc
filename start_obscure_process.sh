#!/bin/bash

source "./efc_lib.sh"
source "./obscure_lib.sh"

print_input_error() {
  echo -e "\nERROR: missing requird inputs [invalid or empty input for $1], exiting. \nUsage:
         \n\t-o | --operation [e = encryption , d = decryption] * Required
         \n\t-s | --source [source folder or file to process] * Required
         \n\t-i | --index [index file to decrypt or location to create index file] 
         \n\t-v | --version [list version and list of dependencies.]
         "
  exit
}

start_process() {

  while [[ $# -gt 0 ]]; do
    case $1 in
    -v | --version)
      shift # past value
      print_version_info
      exit
      ;;
    -o | --operation)
      OPERATION="$2"
      shift # past value

      if [[ "$OPERATION" == "e" || "$OPERATION" == "E" || "$OPERATION" == "d" || "$OPERATION" == "D" ]]; then
        echo -e "\tINPUT: operatin = $OPERATION"
      else
        print_input_error "--operation"
        exit
      fi
      ;;
    -s | --source)
      LOCATION="$2"
      shift # past value

      if [[ -f "$LOCATION" || -d "$LOCATION" ]]; then
        echo -e "\tINPUT: valid source location recived = $LOCATION"
      else
        print_input_error "--source should be a folder or a file"
        exit
      fi
      ;;
    -i | --index)
      INDEX_OR_LOCATION="$2"
      shift # past value
      echo "index file / location = $INDEX_OR_LOCATION"
      ;;
    -* | --*)
      shift # past value
      echo "Unknown option $1"
      #exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
    esac
  done

  if [ -z "$OPERATION" ]; then
    print_input_error "--operation"
  elif [ -z "$LOCATION" ]; then
    print_input_error "--source"
  else

    # obtain the pword for the index file
    while true; do
      echo -n "provide the password to encrypt/decrypt the index file : "
      read -s INDEX_PASSWORD

      if [ -z "$INDEX_PASSWORD" ]; then
        echo -e '\n\t' "password can not be empty, please provide a valid password."
      else
        break
      fi
    done

    if [ "$OPERATION" == "e" ]; then

      if [ -z "$INDEX_OR_LOCATION" ]; then
        # set the current path to the index location
        INDEX_OR_LOCATION="$LOCATION"
      fi

      # construct the index file name
      index_file_name=$(date +%Y%m%d%H%M%S)

      # start index file process
      construct_index_file "$LOCATION" "$INDEX_PASSWORD" "$INDEX_OR_LOCATION" "$index_file_name"
      # constuct index file
      echo -e "\n"
      reconstruct_index_file "$INDEX_OR_LOCATION/.$index_file_name.asc" "$INDEX_PASSWORD"

    else

      if [ -z "$INDEX_OR_LOCATION" ]; then
        echo -e ' \n\t' "index file needs to be provided for the decryption, exiting"
        exit
      fi
      if [ ! -f "$INDEX_OR_LOCATION" ]; then
        echo -e ' \n\t' "index file needs to be an existing file, exiting"
        exit
      fi

      # constuct index file
      echo -e "\n"
      reconstruct_index_file "$INDEX_OR_LOCATION" "$INDEX_PASSWORD"

    fi

    # obtain the pword for the operation
    echo -e "\n"
    while true; do
      echo -n "provide the password to encrypt/decrypt the content : "
      read -s OPERATION_PASSWORD

      if [ -z "$OPERATION_PASSWORD" ]; then
        echo -e '\n\t' "password can not be empty, please provide a valid password."
      else
        break
      fi
    done

    process_indexed_content $OPERATION "$OPERATION_PASSWORD"
  fi

  if [ "$OPERATION" == "e" ]; then
    echo -e "\n INFO :: please store the index file : $LOCATION/.$index_file_name.asc since index file is REQUIRED to decrypt the content."
  fi

}

start_process "$1" "$2" "$3" "$4" "$5" "$6" "$7"