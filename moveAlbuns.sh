#!/bin/bash

# Create artist list
function artistList() {
	ls './Music' > list.txt
	ls './Music-International' > list_international.txt
	ls './Music-National' > list_national.txt
}
artistList

# Create the artist's album list and call the 'setAlbum' function
function main() {
  exec 3< list.txt
   while read artist <&3; do
     echo "Artist --> $artist"
	 ls ./Music/"${artist}" > list_albuns.txt
	 setAlbum
   done
  exec 3<&-
}

# Select each artist album and call the function, moveNatio and moveInter
function setAlbum() {
  exec 4< list_albuns.txt
	while read album <&4; do
		moveNatio
		moveInter
	done
  exec 4<&-
}

# Moves the album to the artist's folder in 'Music-National'
function moveNatio() {
  exec 5< list_national.txt
	while read artistNatio <&5; do
		if [ "$artist" = "$artistNatio" ] ; then
		mv ./Music-Deezer/"$artist"/"$album" ./Music-National/"$artistNatio"
	echo "The album '$album' of '$artistNatio' has been moved to Music-National"
		fi
    done
   echo "Transfer complete!"	
  exe 5<&-
}

# Moves the album to the artist's folder in Music-International
function moveInter() {
  exec 6< list_international.txt
	while read artistInter <&6; do
		if [ "$artist" = "$artistInter" ] ; then
			mv ./Music-Deezer/"$artistDeezer"/"$album" ./Music-International/"$artistInter"
			echo "The album '$album' of '$artistInter' has been moved to Music-International"
		fi
	done
   echo "Transfer complete!"	
  exec 6<&-
}

main
