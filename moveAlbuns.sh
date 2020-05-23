#!/bin/bash


function main() {
	ls './Music-Deezer' > list_deezer.txt

	exec 3< list_deezer.txt
		while read artistDeezer <&3; do
			echo "Artist --> $artistDeezer"
			ls "./Music-Deezer/$artistDeezer" > list_albuns.txt
			setAlbum
			delFolder
		done   
	exec 3<&-
}

function setAlbum() {
	exec 4< list_albuns.txt
		while read album <&4; do
			callFolder
		done
	exec 4<&-
}

function callFolder() {
	pathArtist=`find ./Music-National -type d -iname *"$artistDeezer"*`
	
	if [ ! -e "$pathArtist" ]; then		
		pathArtist=`find ./Music-International -type d -iname *"$artistDeezer"*`
	fi

	if [ -e "$pathArtist" ]; then		
		pathAlbum=`find "$pathArtist" -type d -iname "$album"`
		moveFolder
	fi
	echo "The artist wasn't found in the destination folder!"
}

# Move the album to the artist's folder
function moveFolder() {
	if [ -e "$pathArtist" -a ! -e "$pathAlbum" ]; then    
		mv "./Music-Deezer/$artistDeezer/$album" "$pathArtist"
		echo "The album '$album' of artist '$artistDeezer' was moved to $pathArtist"
	elif [ -e "$pathArtist" -a -e "$pathAlbum" ]; then		
		moveMusic
	fi
}

# Move only the songs if the album already exists
function moveMusic() {
	find "./Music-Deezer/$artistDeezer/$album" -type f -iname *.mp3 -o -iname *.flac > list_music.txt

	exec 5< list_music.txt
		while read music <&5; do
			pathMusic=`find "$pathAlbum" -type f -iname *"${music##*/}"*`
			if [ ! -e "$pathMusic" ]; then	      
				echo "The music '${music##*/}' has been moved."
				mv "$music" "$pathAlbum"        
			fi
		done
	exec 5<&-
	echo "./Music-Deezer/$artistDeezer/$album has been removed!"
	rm -rf "./Music-Deezer/$artistDeezer/$album"
}

# Delete empty folders
function delFolder() {
	if [ -z "$(ls -A ./Music-Deezer/"$artistDeezer")" ]; then
		echo "The artist folder '$artistDeezer' has been removed!"
		rm -d "./Music-Deezer/$artistDeezer"
	else
		echo "Caution! The folder '$artistDeezer' not is empty!"
	fi
}

main