#!/bin/bash

#CONSTANTES
#Ruta del registro log
LOG=/home/octavio/Documentos/canvas-change/data.log
#Ruta del script
ROUTEDIR=/home/octavio/Documentos/canvas-change
#Ruta del interprete de comandos
SH=/bin/bash

#VARIABLES
#variable para la lista de archivos
list=()
#variable para el indice maximo
max=20
#variable para la ruta actual del screen
route=''
#variable para el resultado de la funcion split_string
result_split=()

#FUNCIONES
split_string(){
    string=$1
    IFS=$2
    read -a strarr <<< "$string"
    #${#strarr[*]}
    i=0
    for val in "${strarr[@]}";
    do
        result_split+=("$val")
        ((i++))
    done
    return $i
}

getscreen(){
    route=$(gsettings get org.gnome.desktop.background picture-uri)
}

setscreen(){
    PID=$(pgrep gnome-session)
    export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/6673/environ|cut -d= -f2-)
    # sessionfile=`find "${HOME}/.dbus/session-bus/" -type f`
    # export `grep "DBUS_SESSION_BUS_ADDRESS" "${sessionfile}" | sed '/^#/d'`
    gsettings set org.gnome.desktop.background picture-uri "'$1.$2'"
}

result_split=()
shlist="$($SH $ROUTEDIR/list.sh)"
split_string "$shlist" " "
list=()
templist=()

for e in ${result_split[@]}
do
    templist+=("$e")
done

i=0
for e in ${templist[@]}
do
    result_split=()
    split_string "$e" "."
    list+=(${result_split[$?-2]})
    ((i++))
done

max=${#list[*]}
((max=max-2))

# echo "result"
# for e in ${list[@]}
# do
#     echo $e
# done


getscreen

echo "LOG" >> "$LOG"
echo "max = $max"  >> "$LOG"
echo "route = $route"  >> "$LOG"

#limpiamos la ruta
result_split=()
split_string $route "'"
route=${result_split[$?-1]}

#obtenemos nombre del archivo con su extension
result_split=()
split_string $route '/'
filename=${result_split[$?-1]}

#obtenemos nombre del archivo sin extension
result_split=()
split_string $filename '.'
name=${result_split[$?-2]}
ext=${result_split[$?-1]}

#determinamos cual es el indice del siguiente elemento en ser seteado
current=-1
i=0
for e in ${list[@]}
do
    if [[ $e = $name ]]
    then
        current=$i
    fi
    ((i++))
done

#regresa al inicio de la lista
echo $current
echo $max
if test $current -eq $max;
then
    echo "then"
    current=-1
fi

# export DBUS_SESSION_BUS_ADDRESS environment variable

echo "$current $ROUTEDIR/image/${list[$current+1]}" >> "$LOG"
setscreen "file:///$ROUTEDIR/image/${list[$current+1]}" "jpg"


