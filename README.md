
# Symmetrically Encrypt File/Folder Content. (EFC)

## About EFC:
Utility script written in Bash to encrypt/decrypt file(s) or folder(s) using opensource `gpg encryption`. 

## Features:
* Recursively encrypt/decrypt folder content or single file.
* Allow intractive and script (silent) mode to be called from other scripts.
* Supports folder archiving using `tar`.
* Allow password files over the network.
* Compatible with Windows/Mac/Linux.

### Intractive Mode:
By simply giving a folder or file location as the only parameter, you can start the intractive shell which obtain input from the user.

```bash
efc /home/user/secret/
```

![Intractive Mode](https://raw.githubusercontent.com/timothy-asp/efc/readme-update/test/test_data/intractive.png)



### Silent Mode (Script Mode):
By passing valid parameters, you can start the efc utility. Useful when calling inside another script or from another application.

```bash
efc -s /home/user/secret/ -t e -p https://file.io/7rSEmRMLB0B6 -d yes -z no
```
![Silent Mode](https://raw.githubusercontent.com/timothy-asp/efc/readme-update/test/test_data/silent.png)


### Silent Mode Parameters:

| Option        | Description   | Example       | Default |
| ------------- | ------------- |-------------  |------------- |
| -s  | source file/folder to encrypt/decrypt  | test/file.sec  | N/A  |
| -o  | output file name or folder location  | test/file.sec.gpg  | N/A  |
| -t  | task to perform either encrypt or decrypt  | e / d  | N/A  |
| -p  | file path or URL to a remote file containing the passphrase for the operation (only 1st line will be read) MAX 100 chars  | pass.txt / https://file.io/7rSEmRMLB0B6 | N/A  |
| -d  | delete the source file once the task is completed  | yes  | no  |
| -z  | when encrypting compress the subfolders | no  | no  |



## Running Tests:
Use the files inside the `test` folder.

### Intractive mode:
```bash
efc test/test_data
```

### Silent mode:
```bash
efc -s test/test_data -t e -p test/password.txt -d yes -z no
```

## Examples:

#### Silent Mode : Recursively encrypt folder content using a password file.

```bash
efc -s test/test_data/ -o test/output_folder -t e -p test/local.passphrase.txt -d yes -z no
```
#### Silent Mode : Recursively decrypt folder content using a password file.

```bash
efc -s test/output_folder -o test/test_data/ -t d -p test/local.passphrase.txt -d yes -z no
```

#### Silent Mode : Encrypt folder content using a password file from a URL.

```bash
efc -s test/test_data/ -o test/output_folder -t e -p https://raw.githubusercontent.com/compilable/efc/main/test/local.passphrase.txt -d yes -z no
```
#### Silent Mode : Decrypt folder content using a password file from a URL.

```bash
efc -s test/output_folder/ -o test/test_data -t d -p https://raw.githubusercontent.com/compilable/efc/main/test/local.passphrase.txt -d yes
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

4. Check how to use the program by running `efc --help` on a gitbash terminal.


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
