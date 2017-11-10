#!/usr/bin/env zsh

function inreplace {
	local target=$1 from=$2 to=$3

	[[ ! -f $target ]] && { echo "file '${target}' is not found."; return 1 }

	perl -i -pe "s@${from}@${to}@g" $target
}

local target

target='iTerm2.xcodeproj/project.pbxproj'
inreplace $target '(?<=DEVELOPMENT_TEAM = )H7V7XYVQ7D' '""'
inreplace $target '(?<=CODE_SIGN_IDENTITY = ")(?:Mac Developer|Developer ID Application: GEORGE.+?)(?=")'

target='sources/NSCharacterSet+iTerm.m'
inreplace $target '.+0x2580, 0x258f - 0x2580 \+ 1.+\n'

target='sources/iTermInitialDirectory.h'
inreplace $target 'P(?=rofile.h)' 'p'
