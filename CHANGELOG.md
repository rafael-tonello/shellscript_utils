- Removed trash sed files
- Added miliseconds (optional) to logs
- Import_webFile (download a file to a local folder and make it available to the 'new' function)
- Bug fixes
- Auto name for objects. You can create object without specify its name (a random name will be generated and returned in the _r variable)
- Helper (in utils.sh) to work with 'named arguments' in functions (allow calls like 'my_function "arg=value" "arg2=value2"')
- Object finalization/free function in the 'new.sh'
- keyvaluestorage.sh: A key value storage system, that can use a prefix tree or a folder as database (is more proper to use ad database than sharedmemory.sh)git ta
- semaphore.sh: a couting semaphore that you can use to control access to resources, waiting processes and more
