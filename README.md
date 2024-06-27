# About
This project contains a collection of shell scripts that are designed to assist in the development of projects written in ShellScript. 

These scripts provide various utilities and functions that can be used to streamline the development process and enhance the functionality of ShellScript projects. The core feature is the file new.sh, that allow object orientation programmin in ShellScript.

# New.sh
The `new.sh` file is a crucial component of this project. It enables object-oriented-like programming in ShellScripting. The `new_f` function takes a filename and an object name as parameters. It treats the file as a class and creates an object based on it.

Internally, `new_f` replaces all occurrences of 'this->' with the object name, generating a whole set of variables and functions with the same prefix (object name), simulating objects.

## the new function
`new.sh` file also contains the `new` function, that receives only the `filename`, withtout the path. You can even omit the .sh, informing only the classname. The new function automatically find the file of the informed class and instantiate it (internally, the new_f function is called).

If you have more than one file with same name in your project, the `new` function will instantiate the first class it finds. It can cause erros when instantiating the wrong class. In these cases, you can pass partial paths togheter your class name:

    for this structure of files:
    my project
        |
        +---- Common
        |        |
        |        +----> utils.sh
        |
        +---- Services
        |        |
        |        +----> MyService1.sh
        |        +----> MyService2
        |                    |
        |                    +----> MyService2.sh
        |                    +----> utils.sh
       ...

    if you just try to create a instance of "utils", the `new` propably will instantiate the file 'my project/Common/utils.sh'

    To have a deterministic behaviour, you need to provide part of the path along with the class name:

```shell script
#file use_utils.sh

#this 'if - fi' code loads the 'new.sh' sh and treat this file as a classe, creating a new 'instance' of this and automatically calling its initialization method (this->init)
if [ "$1" != "new" ]; then
    source "shellscript_utils/new.sh"
    new_f "$0" __app__ "" 1
    exit $?
fi

#creating instance of "my project/Common/utils.sh":
    new "Common/utils" "utils"
    #or
    new "my project/Common/utils" "utils"

#creating instance of "my project/Services/MyService2/utils.sh":
    new "MyService2/utils" "utils"
    #or
    new "Services/MyService2/utils" "utils"
    #or
    new "my project/Services/MyService2/utils" "utils"
    
```



# Writing classes

To write classes, you just need to treat the .sh files as you class. The class name is your .sh file name. Inside the .sh files, you can use 'this->[prop or function anme]' to write your class properties and functions. One important method to implement is 'init' (this->init), that is treated as your constructor/inicialization method. See an example bellow:

```shell script
#file outputs.sh

this->init(){
    this->commandCount=0
}

this->echo(){
    this->commandCount=$(( this->commandCount+1 ))
    echo "$this->commandCount: $1"
}

this->echoRed(){
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    this->commandCount=$(( this->commandCount+1 ))
    printf "$this->commandCount: ${RED}$1${NC}\n"
}

```

Using the class
```shell script
#file main.sh

#this 'if - fi' code loads the 'new.sh' sh and treat this file as a classe, creating a new 'instance' of this and automatically calling its initialization method (this->init)
if [ "$1" != "new" ]; then
    source "shellscript_utils/new.sh"
    new_f "$0" __app__ "" 1
    exit $?
fi


this->init(){
    new outputs "outs"

    outs->echo "look this tesxt. It have the normal terminal color"
    outs->echoRed "and now look at this!! Is in another color"
    return 0
}

```



```
todo:
    [ ] use a mutex (var lock/unlock) in eventbus
    [ ] user a mute (var lock/unlock) in queue
```