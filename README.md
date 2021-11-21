# Bash Script to symmetrically Encrypt the Files/Folder Content. (EFC)

## Run the script:
Utility script to encrypt/decrypt a single file of a folder tree using standard gpg lib.

`./efc.sh <FOLDER/FILE/PATH>`

## Windows configuration using gitbash

Need to add the folder location to the path.

1. Create a bash profile.
`nano ~/.profile`

2. Add the path of the efc folder to the $PATH
`export PATH=$PATH:"LOCATION/EFC"`

3. Close and open a new bash shell.

## Dependencies:
- gpg (GnuPG) 2.2.19
- libgcrypt 1.8.5

## Reference:
- [Capture gpg outcome into a file](https://lists.gnupg.org/pipermail/gnupg-users/2003-February/017167.html  "test")
- [gnupg - official](https://www.gnupg.org/download/ "gnupg - official")


## License:
- MIT license (MIT)