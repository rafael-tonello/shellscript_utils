# About
Shell script utils (SHU) contains a collection of shell scripts that allow object orientation in ShellScript. It is designed to assist in the development of projects written in ShellScript. 

These scripts provide various utilities and functions that can be used to streamline the development process and enhance the functionality of ShellScript projects. The core feature is the file new.sh, that allow object orientation programmin in ShellScript.

# TL;DR - Just let me use it

Ok, I understant you!!

### clone the project
SO, first of all, you need to clone the repository in your project folder:

```shell script
git clone https://github.com/rafael-tonello/shellscript_utils

```

### initing the library

After the library is cloned, you need to source the new.sh file in your main file (the file that will start your project). You can do it in the beginning of the file, like this:

```shell script
#file main.sh

source "shellscript_utils/new.sh"
```

### Use O.O. in ShellScript


After included and sourced, you just need to call "new" name of your files (names of classes are the names of the files) and the name of the object you want to create.

#### creating a class

So lets create a class...

```shell script
#file MyService.sh

this->init(){ local name="$1"; local otherValue="$2";
    this->name="$name"
    this->otherValue="$otherValue"
}

this->doSomething(){
    echo "doing something"
}

this->printNameAndOtherValue(){
    echo "name: $this->name"
    echo "otherValue: $this->otherValue"
}
```

... and create a instance of it ...

```shell script
#file main.sh
source "shellscript_utils/new.sh"

new "MyService" "objName"
objName->init
```

... and Call objects methods

Note: To call object methods, you need to use the '->' operator. The '->' operator is used to access the object properties and methods.

```shell script
#file main.sh
source "shellscript_utils/new.sh"

new "MyService" "objName"
objName->init "Jhon Doe" "another value to be printed"

objName->doSomething
#yeah! You should use '->' to acces internals of the object. May be I will try to change it in the future to use '.' (support for '->' will be maintained)

objName->printNameAndOtherValue
```

#### leting 'new' call the 'init' method for you
In the example above, we called the 'init' method after the creation of our objec. Bu you can let the 'new' function call the 'init' method for you. To do this, you need to create a 'init' method in your class file. The 'new' function have an argument that allo you to do it:

```shell script
#file main.sh
source "shellscript_utils/new.sh"

new "MyService" "objName" "" 1 "init arg1" "init arg2" "init arg ..."

```

explaining:

```shell script
    #call to the 'new' function
    new

    #name of the class/file
    "MyService"
    
    #name of object 
    "objName"
    
    #this argument allow you to write class using another key istead of 'this' to refer to the object. If you pass an empty string, the default key 'this' will be used
    ""
    
    # this is the argument that tell the 'new' function to call the 'init' method of the object.
    1 
    
    #arguments that will be passed to the 'init' method of the object
    "init arg1" "init arg2" "init arg ..." 
```

Ok, It is the basic of class creation, object instantiation and method calling. You can do more things with the 'new.sh' file. See the next sections to know more about it.

---
---

# The library

## New.sh
The `new.sh` file is a crucial component of this project. It enables object-oriented-like programming in ShellScripting. The `new_f` is the core function of new.sh and receives, as arguments, a filename and an object name. It treats the file as a class and creates an object based on it.

Internally, `new_f` replaces all occurrences of 'this->' with the object name, generating a whole set of variables and functions with the same prefix (object name), simulating objects.

## the new function
`new.sh` file also contains the `new` function, that receives the `filename`, withtout the path and. You can even omit the .sh, informing only the "classname". The new function automatically find the file of the informed class and instantiate it (internally, the new_f function is called).

If you have more than one file with same name in your project, the `new` function will instantiate the first class it finds. It can cause erros when instantiating the wrong class. In these cases, you can pass partial paths togheter your class name:

    for this structure of files:
    my project
        |
        +---- Common
        |        |
        |        +----> utils.sh
        |
        +---- Servic===>>> The `git_import` function will not work if the 'git' command is not installed in the computer.es
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

## more things about 'new' function
The `new` function is a wrapper for `new_f` that receives only the class name, without the path. It automatically finds the file of the class and instantiates it by calling the 'new_f' file with the complete file path. `new` function will automatically scan the project directory to find the file of the class. The scan will occur in the directory returned by pwd when `new` is called.

You can start the scan for classes manually in how many directories you want. You also can specify a 'direcoty folder' when 'sourcing' the new.sh file. In this both cases, `new` function will not scan folder by itself, and will work only with is found in the specified directories.

To start a sacan by your self, call the funciton scan_folder_for_classes or source the file 'new.sh' with a directory as paremeter
===>>> The `git_import` function will not work if the 'git' command is not installed in the computer.

### some examples
#### example: using the new.sh file
```shell script
#file main.sh
source "shellscript_utils/new.sh" #loads the new.sh file (do not scan any folder)

new "MyService" "objName" #creates a new instance of 'MyService'. Before instantiate the class, the 'new.sh' file will scan all files in the current directory. If the file 'MyService.sh' is found, it will be instantiated and referenced by the variable 'objName'
objName->init #calls the 'init' method of the 'objName' object (instance of 'MyService' class)
```

#### example: using the new.sh file
```shell script
#file main.sh
source "shellscript_utils/new.sh" "my project/Services" #loads the new.sh file and start the scan in the 'my project/Services' folder
new "MyService" "objName" #creates a new instance of 'MyService' class and store it in the variable 'objName'
objName->init #calls the 'init' method of the 'objName' object (instance of 'MyService' class)
```

#### example: using the new.sh file
```shell script
#file main.sh
source "shellscript_utils/new.sh" #loads the new.sh file (do not scan any folder)
scan_folder_for_classes "my project/Services" #start the scan in the 'my project/Services' folder

new "MyService" "objName"
objName->init
```

## Other cool things 
### git_import
The `new.sh` also contains the `git_import` function, that allows you to import files (call new, new_f, ...) from a git repository. The `git_import` function receives the repository URL and a parameter named '_portable_'. This function will, basically, clone the repositorie in a local folder and scan all .sh files of it.

If you pass the '_portable_' parameter with the value 1, the `git_import` will work in a portable way, that is, it will work in a local folder (.newshgitrepos) inside the project folder (the folder returned by 'pwd' when the new.sh file is sourced). If you pass the '_portable_' parameter with the value 0, the `git_import` will work in a global way, using  the folder "~/.newshgitrepos" folder.

#### Portable mode = 0
In this case, a global location will be used in the current computer (the folder "~/.newshgitrepos"). And the repos will be shared between all projects that use the `git_import` function. This is the default mode.

#### Portable mode = 1
In this case, a local location will be used in the current project (the folder ".newshgitrepos" inside the project folder). And the repos will be shared only between the files of the current project.

# Object Orientation

## Writing classes

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

## inheritance
yes, you can do a kind of inheritance using new.sh. When a new object is created, its file is 'sources' with some arguments:
- the first argument is the word 'new', indicating that the file is being 'sourced' by the new.sh file
- the second argument is the name of the class that is being instantiated
- the third argument is the name of the object that is being created

to make the inheritance, you need to instantiate the parent class in the beginning of the child class file.

```shell script
#file parent.sh
this->doSomething(){
    echo "doing something"
}

this->overrideThis(){
    echo "this is the parent"
}

#file child.sh
myName="$2"
new "parent.sh" myName

this->overrideThis(){
    echo "this is the child"
}

#main.sh
source "shellscript_utils/new.sh"
new "child" "obj"
obj->doSomething #will print "doing something"
obj->overrideThis #will print "this is the child"

```


# git_import
The `new.sh` also contains the `git_import` function, that allows you to import files (call new, new_f, ...) from a git repository. The `git_import` function receives the repository URL and a parameter named '_portable_'. This function will, basically, clone the repositorie in a local folder and scan all .sh files of it.

If you pass the '_portable_' parameter with the value 1, the `git_import` will work in a portable way, that is, it will work in a local folder (.newshgitrepos) inside the project folder (the folder returned by 'pwd' when the new.sh file is sourced). If you pass the '_portable_' parameter with the value 0, the `git_import` will work in a global way, using  the folder "~/.newshgitrepos" folder.

## Portable mode = 0
In this case, a global location will be used in the current computer (the folder "~/.newshgitrepos"). And the repos will be shared between all projects that use the `git_import` function. This is the default mode.

## Portable mode = 1
In this case, a local location will be used in the current project (the folder ".newshgitrepos" inside the project folder). And the repos will be shared only between the files of the current project.


---
---

# Embedded libraries
The `shellscript_utils` project also contains some embedded libraries that can be used in your projects. These libraries are:
## Logger

## Eventbus

## Eventstream

## SharedMemory

## Tests

## List

## PersisQueue

## SSHManager

## Translate

## GitObserver

## Utilitaries libraries
### StrUtils

### Utils

### NetworkUtils

## Threads





## TelegramSend

## Animations

---

# todos and tsklists:
```
    todo:
    [ ] use a mutex (var lock/unlock) in eventbus
    [ ] user a mute (var lock/unlock) in queue
```
