
if [ -z "$1" ]
then
    echo "No files to encrypt, exiting"
    exit
fi

if [[ ! -f  "$1" ]]
then
    echo "file does not exists, should be a file, no folders supported."
    exit
fi

echo "encrypting the file $1"

echo "Delete the source file ? (yes/no)"

read isDelete

echo $isDelete

if [ $# -eq 0 ]
then
    echo "No arguments provided, source is NOT deleted."
fi


if [ $# == 'yes' ]
then
    echo "source file will be DELETED!"
fi

gpg -c $1

echo "new file  : $1.gpg"


if [ $isDelete == 'yes' ]
then
    rm $1
fi

mv $1.gpg $1.gpg_$(date "+%Y.%m.%d-%H.%M.%S")

echo RELOADAGENT | gpg-connect-agent