#!/bin/bash

# Cria lista dos diretórios dos artistas existentes em cada caminho correspondente
function artistList() {
  ls './Music-Deezer' > list_deezer.txt
  ls './Music-International' > list_international.txt
  ls './Music-National' > list_national.txt
}
artistList

function main() {
  exec 3< list_deezer.txt
    while read artistDeezer <&3; do
      echo "Music-Deezer --> $artistDeezer"
      ls ./Music-Deezer/"${artistDeezer}" > list_albuns.txt
      setAlbum
    done
  exec 3<&-
}

function setAlbum() {
  exec 4< list_albuns.txt
    while read album <&4; do
      moveNatio
      moveInter
    done
  exec 4<&-
}

function moveNatio() {
  exec 5< list_national.txt
    while read artistNatio <&5; do
      if [ "$artistDeezer" = "$artistNatio" ] ; then
        mv ./Music-Deezer/"$artistDeezer"/"$album" ./Music-International/"$artistNatio"
        echo "O album '$album' de '$artistNatio' foi movido para Music-National"
      fi
    done
   echo "Transferência concluída!"
  exec 5<&-
}

function moveInter() {
  exec 6< list_international.txt
    while read artistInter <&6; do
      if [ "$artistDeezer" = "$artistInter" ] ; then
        mv ./Music-Deezer/"$artistDeezer"/"$album" ./Music-International/"$artistInter"
	echo "O album '$album' de '$artistInter' foi movido para Music-International"
      fi
    done
   echo "Transferência concluída!"
  exec 6<&-
}

main
