#!/bin/bash

fileType=('*.mp3' '*.flac')
pathOrigin='./downloads/deezer/'
pathDestination=('./Music-Deezer' './Music-National' './Music-International')
pathLogs='./logs'
timeDelLogs=5
logName=${0##*/}
logFile="$pathLogs/${logName%.*}_`date +%d-%m-%Y`".log
timeStamp="| `date +%d-%m-%Y' | '%H:%M:%S' |'`"

if [ ! -e $pathLogs ]; then
	mkdir $pathLogs
fi

if [ ! -e $logFile ]; then
	echo -e "|-------TIME STAMP------|" |& tee $logFile
fi

function main() {
	ls -1 -d $pathOrigin*/ 2>/dev/null | cut -c${#pathOrigin}-100 | sed "s,/,,g" > "$pathLogs"/list_deezer.txt

	exec 3< "$pathLogs"/list_deezer.txt
		while read artistDeezer <&3; do
			echo -e "$timeStamp--> Artist --> $artistDeezer"
			ls "$pathOrigin$artistDeezer" > list_albuns.txt
			moveArtist
			delFolder
		done
	exec 3<&-

	if [ -z "$(tail -1 "$pathLogs"/list_deezer.txt)" ]; then
		rm -f "$pathLogs"/*.txt
		echo "$timeStamp--> Not found: No artists found"
	fi
}

# Move artist if not found in destination folder
function moveArtist() {
	for i in "${pathDestination[@]}"; do
		pathArtist=`find "$i" -type d -iname *"$artistDeezer"* 2>/dev/null | head -1`

		if [ -e "$pathArtist" ]; then			
			echo -e "$timeStamp--> Found: The artist was found in $i"
			moveAlbum
			break
		else
			echo -e "$timeStamp--> Not found: The artist wasn't found in $i"
		fi
	done

		if [ ! -e "$pathArtist" ]; then
			mv "$pathOrigin$artistDeezer" "${pathDestination[0]}"
			echo -e "$timeStamp--> Moved: The artist '$artistDeezer' was moved to ${pathDestination[0]}"
		fi
}

# Move the album to the artist's folder
function moveAlbum() {
	exec 4< list_albuns.txt
		while read album <&4; do
			pathAlbum=`find "$pathArtist"/* -type d -iname *"$album"* 2>/dev/null | tail -1`
				if [ -e "$pathArtist" -a ! -e "$pathAlbum" ]; then
					mv "$pathOrigin$artistDeezer/$album" "$pathArtist"
					echo -e "$timeStamp--> Moved: The album '$album' of artist '$artistDeezer' was moved to $pathArtist"
				elif [ -e "$pathArtist" -a -e "$pathAlbum" ]; then
					moveMusic
				fi
		done
	exec 4<&-
}

# Move only the songs if the album already exists
function moveMusic() {
	find "$pathOrigin$artistDeezer/$album" -type f -iname ${fileType[0]} -o -iname ${fileType[1]} > list_music.txt

	exec 5< list_music.txt
		while read music <&5; do
			pathMusic=`find "$pathAlbum"/* -type f -iname *"${music##*/}"* 2>/dev/null`
				
				if [ ! -e "$pathMusic" ]; then
					echo -e "$timeStamp--> Moved: The music '${music##*/}' has been moved."
					mv "$music" "$pathAlbum"
				fi
		done
	exec 5<&-

	echo -e "$timeStamp--> Removed: The album '$album' has been removed!"
	rm -rf "$pathOrigin$artistDeezer/$album"
}

# Delete empty folders
function delFolder() {
	if [ -e "$pathOrigin$artistDeezer" ]; then
		if [ -z "$(ls -A "$pathOrigin$artistDeezer")" ]; then
			echo -e "$timeStamp--> Removed: The artist folder '$artistDeezer' has been removed!"
			rm -d "$pathOrigin$artistDeezer"
		else
			echo -e "$timeStamp--> Not removed: The artist folder '$artistDeezer' not is empty to be removed!"
		fi
	fi
}

# Delete older logs
function delLog() {
	find "$pathLogs" -mtime +$timeDelLogs -iname *.log > "$pathLogs"/list_logs.txt

	exec 6< "$pathLogs"/list_logs.txt
		while read log <&6; do
			rm -f "$log"
			echo "$timeStamp--> Log deleted: ${log##*/}"
		done
	exec 6<&-
	rm -f "$pathLogs"/*.txt
}

main 2>&1 | tee -a $logFile
delLog 2>&1 | tee -a $logFile