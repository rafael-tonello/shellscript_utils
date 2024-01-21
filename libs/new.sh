
#class_obj="
#    this_name=test;
#    this_age=20;
#    this_show(){ \
#        echo name is \$this_name and age is \$this_age; 
#    };
#    this_changeName(){ 
#        this_name=\$1;
#    }
#"
#
#main()
#{
#    new class_obj tmpobj
#    tmpobj_name=anotherName
#    tmpobj_show
#
#    tmpobj_changeName newName
#    tmpobj_show
#
#}
#
#main

#class,name

#newF new object from a class in the [className].sh file
#className, ObjectName
new_cf()
{
    class=$1
    name=$2
    fileName=$class.sh

    new_f $fileName $name
}

#new object from a class in a [fileName].sh file
#fileName, ObjectName
new_f()
{
    fileName=$1
    name=$2
    rm -f "$fileName.c.sh"
    awk "{gsub(/this/, \"$name\"); print}" $fileName > $fileName.c.sh

    chmod +x "$fileName.c.sh"

    source "$fileName.c.sh"
    rm "$fileName.c.sh"
}

#className, objectName
new_c()
{
    class=$1
    name=$2
    tmp=$(echo $tmp | sed "s/this/$name/g")
    eval $tmp
}

