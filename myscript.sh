#!/bin/bash
function failed(){
echo "Status Failed"
rm -f $1
exit 1
}

function create(){
$opens bf -a -salt -in "$PWD/$2" -out "$PWD/$2.enc" -k $1;
echo
echo -n Remove:
read -s removeor
if [[ $removeor == "Y" || $removeor == "y" ]]; then
    rm -f "$PWD/$2";
fi

}

function scrambles()
{
    filenames="${2%.*}"
    tempf=`mktemp /tmp/tmp.XXXXXXX`
    $opens bf -a -d -salt -in "$PWD/$2" -out $tempf  -k $1 2> /dev/null

    grep -q robin $tempf
    if [[ $? -eq 0 ]]; then
        #    cat $tempf
        echo $3
        grep -i -q $3 $tempf
        if [[ $? -eq 0 ]]; then
            echo "Already Exists. Overwrite?"
            read -s question
            echo
            #cat $tempf
            if [[ $question == "y" || $question == "Y" ]]; then
                echo "Enter Pass"
                read -s pass
                echo "Enter Length"
                read len
                temp=`$PWD/genpassword  $pass $len`
                #echo $3
                perl -i -pe "s/($3:).*/\\1$temp/i" $tempf
                #rm -f "$PWD/$2"
                $opens bf -a -salt -in $tempf -out "$PWD/$2" -k $1;
                rm -f $tempf

            fi

        else 

            echo "Enter Pass"
            read -s pass
            echo "Enter Length"
            read len
            temp=`$PWD/genpassword  $pass $len`
            echo "$3:$temp" >>$tempf
            $opens bf -a -salt -in $tempf -out "$PWD/$2" -k $1;
            rm -f $tempf

        fi


    else
        # cat $tempf
        failed $tempf

    fi
    rm -f $tempf
}
function unscram(){
filenames="${2%.*}"
tempf=`mktemp /tmp/tmp.XXXXXXX`
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]];then
    clipc="/usr/bin/xsel -b"
elif
    [[ "$unamestr" == 'Darwin' ]];then
    clipc="pbcopy"
elif
    [[ "$unamestr" == 'CYGWIN_NT-6.1-WOW64' ]];then
    clipc="windows"


else
    echo "Unknown Platform"
    exit 1
fi
$opens bf -a -d -salt -in "$PWD/$2" -out $tempf  -k $1 2> /dev/null
grep -q robin $tempf
if [[ $? -eq 0 ]]; then
    #    cat $tempf
    echo
    #echo $4
    if [[ $clipc == 'windows' ]]; then
        grep -i -m 1 $3 $tempf| cut -f 2 -d ":"|tr -d ' ' >/dev/clipboard
    else
        grep -i -m 1 $3 $tempf| cut -f 2 -d ":"|tr -d ' '|$clipc
    fi
    grep -q $3 $tempf
    if [[ $? -ne 0 ]]; then
        echo "Nothing found"
        exit 1
    fi
else
    failed $tempf
fi
rm -f $tempf

}



opens=`which openssl`
whirlp=`which whirlpooldeep`
echo -n Username:
read -s username
echo 
usern=`echo $username|$whirlp|$whirlp|$whirlp|$whirlp`
echo -n Filename:
read filename
if [[ ! -e $PWD/$filename ]]; then
    echo "File does not exist";
    exit 1;
fi
echo -n What:
read -s scramble
echo
if [[ $scramble == "e" || $scramble == "E" ]]; then
    echo -n Serve:
    read -s servicep
    scrambles $usern $filename $servicep
    echo
elif
    [[ $scramble == "c" || $scramble == "C" ]]; then
    create $usern $filename
else
    echo -n Serve:
    read -s servicep
    unscram $usern $filename $servicep 
fi

trap "rm -f /tmp/tmp.*" EXIT
exit 0
