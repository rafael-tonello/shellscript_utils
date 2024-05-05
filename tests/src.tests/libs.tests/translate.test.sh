#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "translate~>t should translate from english to portuguese" "this->testTranslateEnPt"
    "$testsObject"->registerTest "translate~>t should return original if no translation is found" "this->testTranslateEnPt_2"
    "$testsObject"->registerTest "translate~>t should replace placeholders in the tranlations " "this->testReplace"
    "$testsObject"->registerTest "translate~>t should replace placeholders in the original (if no translate found)" "this->testReplace_2"
    "$testsObject"->registerTest "translate~>t should create file with translations not found)" "this->testNotFoundsFile"
}

this->finalize(){
    :;
}

this->testTranslateEnPt(){
    mkdir -p "languages"
    echo "this is the original text=este é o texto original" > "languages/pt_BR"

    new "translate" tr "" 1 "languages/pt_BR"
    local result=$(tr->t "this is the original text")
    rm -rf languages
    if [ "$result" != "este é o texto original" ]; then
        _error="t did not return the expected result"
        _expected="este é o texto original"
        _returned="$result"
        return 1
    fi
    return 0
}

this->testTranslateEnPt_2(){
    mkdir -p "languages"
    echo "this is the original text=este é o texto original" > "languages/pt_BR"

    new "translate" tr "" 1 "languages/pt_BR"
    local result=$(tr->t "this text should not be translated")
    rm -rf languages
    if [ "$result" != "this text should not be translated" ]; then
        _error="t did not return the expected result"
        _expected="this is the original text 2"
        _returned="$result"
        return 1
    fi
    return 0
}

this->testReplace(){
    mkdir -p "languages"
    echo "this is the %% text=este é o texto %%" > "languages/pt_BR"

    new "translate" tr "" 1 "languages/pt_BR"

    local result=$(tr->t "this is the %% text" "original")
    rm -rf languages

    if [ "$result" != "este é o texto original" ]; then
        _error="t did not return the expected result"
        _expected="este é o texto original"
        _returned="$result"
        return 1
    fi
    return 0
}

this->testReplace_2(){
    mkdir -p "languages"
    echo "this is the %% text=este é o texto %%" > "languages/pt_BR"

    new "translate" tr "" 1 "languages/pt_BR"

    local result=$(tr->t "this text should not be %%." "translated")
    rm -rf languages

    if [ "$result" != "this text should not be translated." ]; then
        _error="t did not return the expected result"
        _expected="this text should not be translated."
        _returned="$result"
        return 1
    fi
    return 0
}

this->testNotFoundsFile(){
    mkdir -p "languages"
    echo "this is the %% text=este é o texto %%" > "languages/pt_BR"

    new "translate" tr "" 1 "languages/pt_BR"

    local result=$(tr->t "this text should not be translated")

    if [ ! -f "languages/pt_BR.notFound" ]; then
        _error="file pt_BR.notFound was not created"
        return 1
    fi

    #test the file content
    local content=$(cat "languages/pt_BR.notFound")
    rm -rf languages
    if [ "$content" != "this text should not be translated=" ]; then
        _error="file pt_BR.notFound does not have the expected content"
        _expected="this text should not be translated="
        _returned="$content"
        return 1
    fi
    return 0
}