#!/bin/bash

# This scripts reads all given .cue files one by one, extracts a disk image file
# name ands splits in on tracks. Despite its name, it works not only with
# flac+cue but with everything shntool(1) is capable of working with

musicDir="$(xdg-user-dir MUSIC)"

for cue in "${@}"
do
	# TODO cueprint or cuetag.sh? It still require further by-hand processing though
	# TODO Various Artists require by-track processing
	# TODO Multiple .flac references in a single .cue
	# awk does not 'just work' if .cue is CRLF line-ended, so crutch it
	tmpcue=$(mktemp -q --tmpdir XXXXXXXX.cue)
	dos2unix < "${cue}" | mac2unix > "${tmpcue}"
	artist="$(awk -F '"' '/^PERFORMER/ { print($2) }' "${tmpcue}")"
	album="$(awk -F '"' '/^TITLE/ { print($2) }' "${tmpcue}")"
	cuedir="$(dirname "${cue}")"
	flac="${cuedir}/$(awk -F '"' '/^FILE/ { print($2) }' "${tmpcue}")"
	# Non-standard but wide spread
	year=$(awk '/^REM DATE/ { print($3) }' "${tmpcue}")
	[ -z "${year}" ] && year=0000
	outputDir="${musicDir}/${artist}/${year} - ${album}"

	[ -d "${outputDir}" ] && {
		echo "Warning, ${outputDir} already exists, skipping ${cue}">&2
		continue
	}
	mkdir -v "${outputDir}"
	shntool split -d "${outputDir}" -f "${cue}" -o flac -t '%n - %p - %t' "${flac}"
	# Extra stuff
	rsync -av --exclude "*.flac" --exclude "*.cue" --exclude "*.log" "${cuedir}/" "${outputDir}"
	rm "${outputDir}/00 - ${artist} - pregap.flac" "${tmpcue}"
done
