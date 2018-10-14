@_list:
	just -l

patch: _replace-range _replace

_replace-range: _range
	#!/usr/bin/env zsh
	tempfile=$(mktemp)
	ruby -e 'puts ARGF.read.gsub(/^(\s+sFullWidth9 = \[\[NSMutable.+?$).+?^(\s+\}\)\;)$/m, "\\1\n#{File.read(%(nsmakeranges.txt))}\\2")' sources/NSCharacterSet+iTerm.m \
		> $tempfile \
		&& mv $tempfile sources/NSCharacterSet+iTerm.m

_range: _fullwidth
	ruby -e 'puts ARGF.read.scan(/\{.+?\}/).join("\n").delete("{},").gsub(/0x/, "")' fullwidth.txt \
		| ./tools/range_to_range.py \
		| sed 's/set/sFullWidth9/' \
		| sed 's/^/        /' \
		> nsmakeranges.txt

_fullwidth: _wcwidth9
	ruby -e 'puts ARGF.read.scan(/static[^\n]+?wcwidth9_(?:double|emoji_)width.+?\};/m)' wcwidth9.h \
		> fullwidth.txt

_wcwidth9:
	curl --progress-bar -L -o wcwidth9.h \
		https://gist.githubusercontent.com/waltarix/7a36cc9f234a4a2958a24927696cf87c/raw/d4a38bc596f798b0344d06e9c831677f194d8148/wcwidth9.h

_replace:
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
	inreplace $target '.+sAmbiguousWidth9.+0x24eb, 0x254b - 0x24eb \+ 1.+\n'
	inreplace $target '.+sAmbiguousWidth9.+0x2580, 0x258f - 0x2580 \+ 1.+\n'
	inreplace $target '.+sAmbiguousWidth9.+0xe000, 0xf8ff - 0xe000 \+ 1.+\n' '        [sAmbiguousWidth9 addCharactersInRange:NSMakeRange(0xe000, 0xe09f - 0xe000 + 1)];\n        [sAmbiguousWidth9 addCharactersInRange:NSMakeRange(0xe0d8, 0xf8ff - 0xe0d8 + 1)];\n'
	
	target='sources/iTermInitialDirectory.h'
	inreplace $target 'P(?=rofile.h)' 'p'
