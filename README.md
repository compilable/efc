# Bash Script to symmetrically encrypt the files/folder content with a given password.

# ./efc.sh
efc_single.sh : encrypt / decrypt a single file of a folder tree.

* -ed : encrypt directory
* -ef : encrypt individual file
* -d : decrypt file'


## Windows configuration using gitbash

Need to add the folder locaion to path.

1. Create a bash profile.
`nano ~/.profile`

2. Add the path of the efc folder to the $PATH
`export PATH=$PATH:"LOCATION/EFC"`

3. Close and open a new bash shell.

