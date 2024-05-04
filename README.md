# About
This project contains a collection of shell scripts that are designed to assist in the development of projects written in ShellScript. 

These scripts provide various utilities and functions that can be used to streamline the development process and enhance the functionality of ShellScript projects. The core feature is the file new.sh, that allow object orientation programmin in ShellScript.

# New.sh
The `new.sh` file is a crucial component of this project. It enables object-oriented-like programming in ShellScripting. The `new_f` function takes a filename and an object name as parameters. It treats the file as a class and creates an object based on it.

Internally, `new_f` replaces all occurrences of 'this->' with the object name, generating a whole set of variables and functions with the same prefix (object name), simulating objects.
