
# Bash Script to symmetrically Encrypt the Files/Folder Content. (EFC)

## Usage:
Utility script to encrypt/decrypt a single file(s) or folder tree using standard gpg lib. Supports folder archiving using `tar`.

```bash
./efc.sh <FOLDER/FILE/PATH>
```

## Running Tests:
Use the files inside the `test` folder.

```bash
 ./efc.sh test
```

## Windows configuration using Git for Windows (Git SCM):

Need to install the `Git for Windows` which provides a BASH emulation that comes with GnuPG pre-installed.

## To run the `efc` script from outside the source location: 

1. Create a bash profile.
```bash
nano ~/.profile

or 

vim ~/.profile
```

2. Create a path variable named `EFC_PATH` pointing to the the EFC source location and append to the `PATH` variable:
```bash
export EFC_PATH="LOCATION_TO_SOURCE_FOLDER"
export PATH=$PATH:$EFC_PATH
```

3. Close and open a new bash shell.

4. Check the instalation by running `efc.sh --version` on a gitbash terminal.

## Dependencies:
- gpg (GnuPG) [2.2.19, 2.2.27]
- libgcrypt [1.8.5 , 1.9.2]
- tar (GNU tar) [1.34]


## Reference:
- [gnupg - official website](https://www.gnupg.org/download/ "gnupg - official")
- [Git for Windows](https://gitforwindows.org/ "Git for Windows")
- [Capture gpg outcome into a file](https://lists.gnupg.org/pipermail/gnupg-users/2003-February/017167.html  "Capture gpg outcome")

## License:
- MIT license (MIT)