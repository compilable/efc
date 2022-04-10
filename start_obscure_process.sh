#!/bin/bash

source "./efc_lib.sh"
source "./obscure_lib.sh"

start_process() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -o | --operation)
      OPERATION="$2"
      shift # past value
      echo "operatin = $OPERATION"
      ;;
    -s | --source)
      LOCATION="$2"
      shift # past value
      echo "source location = $LOCATION"
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

  # obtain the pword for the index file
  while true; do
    echo -n "provide the password to encrypt the index file : "
    read -s INDEX_PASSWORD

    if [ -z "$INDEX_PASSWORD" ]; then
      echo -e '\n\t' "password can not be empty, please provide a valid password."
    else
      break
    fi
  done

  if [ "$OPERATION" == "e" ]; then

    while true; do

      read -sp "Confirm the password :" INDEX_PASSWORD_CONFIRMED

      if [ "$INDEX_PASSWORD" == "$INDEX_PASSWORD_CONFIRMED" ]; then
        break
      else
        echo -e ' \n\t' "password does not match, please confirm the password."
      fi

    done
  fi

  # construct the index file
  construct_index_file "$LOCATION" "$INDEX_PASSWORD" "$INDEX_OR_LOCATION"

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

  if [ "$OPERATION" == "e" ]; then

    while true; do

      read -sp "Confirm the encrypt/decrypt password :" OPERATION_PASSWORD_CONFIRMED

      if [ "$OPERATION_PASSWORD" == "$OPERATION_PASSWORD_CONFIRMED" ]; then
        break
      else
        echo -e ' \n\t' "encrypt/decrypt password does not match, please confirm the password."
      fi

    done
  fi

  # start the process
  echo -e "\n"  
  reconstruct_index_file "$LOCATION" "$INDEX_PASSWORD"
  process_indexed_content $OPERATION "$OPERATION_PASSWORD"
}

start_process "$1" "$2" "$3" "$4" "$5" "$6" "$7"

