#!/bin/bash

pathOrigin='./Music-Deezer'
pathDestin=('./Music-National' './Music-International')
fileType=('*.mp3' '*.flac')
log=${0##*/}
logFile="${log%.*}_`date +%d-%m-%Y`".log
timeStamp="| `date +%d-%m-%Y' | '%H:%M:%S' |'`"

if [ ! -e $logFile ]; then
    echo -e "|-------TIME STAMP------|" |& tee $logFile
fi
exec 1> >(tee -a "$logFile")
exec 2>&1


function main() {
	ls $pathOrigin > list_deezer.txt

	exec 3< list_deezer.txt
		while read artistDeezer <&3; do			
			echo -e "$timeStamp--> Artist --> $artistDeezer"
			ls "$pathOrigin/$artistDeezer" > list_albuns.txt
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
	pathArtist=`find ${pathDestin[0]} -type d -iname *"$artistDeezer"*`
	
	if [ ! -e "$pathArtist" ]; then		
		pathArtist=`find ${pathDestin[1]} -type d -iname *"$artistDeezer"*`
	fi

	if [ -e "$pathArtist" ]; then		
		pathAlbum=`find "$pathArtist" -type d -iname "$album"`
		moveFolder
	else
		echo -e "$timeStamp--> Not found: The artist wasn't found in the destination folder!"
	fi	
}

# Move the album to the artist's folder
function moveFolder() {
	if [ -e "$pathArtist" -a ! -e "$pathAlbum" ]; then    
		mv "$pathOrigin/$artistDeezer/$album" "$pathArtist"
		echo -e "$timeStamp--> Moved: The album '$album' of artist '$artistDeezer' was moved to $pathArtist"
	elif [ -e "$pathArtist" -a -e "$pathAlbum" ]; then		
		moveMusic
	fi
}

# Move only the songs if the album already exists
function moveMusic() {
	find "$pathOrigin/$artistDeezer/$album" -type f -iname ${fileType[0]} -o -iname ${fileType[1]} > list_music.txt

	exec 5< list_music.txt
		while read music <&5; do
			pathMusic=`find "$pathAlbum" -type f -iname *"${music##*/}"*`
			if [ ! -e "$pathMusic" ]; then				
				echo -e "$timeStamp--> Moved: The music '${music##*/}' has been moved."
				mv "$music" "$pathAlbum"
			fi
		done
	exec 5<&-
	echo -e "$timeStamp--> Removed: The album '$album' has been removed!"
	rm -rf "$pathOrigin/$artistDeezer/$album"
}

# Delete empty folders
function delFolder() {
	if [ -z "$(ls -A "$pathOrigin/$artistDeezer")" ]; then		
		echo -e "$timeStamp--> Removed: The artist folder '$artistDeezer' has been removed!"
		rm -d "$pathOrigin/$artistDeezer"
	else
		echo -e "$timeStamp--> Not removed: The artist folder '$artistDeezer' not is empty to be removed!"
	fi
	rm -f *.txt
}

main

exec 1>&-
exec 2>&-