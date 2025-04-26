#!/usr/bin/env bash

wfdir=$(defaults read com.runningwithcrayons.Alfred-Preferences syncfolder)
wfdir_base=$(eval echo "$wfdir/Alfred.alfredpreferences/workflows")

_usage() {
	cat <<-EOF
	Display, push, or pull README between Alfred workflow and filesystem
	Usage: ${0##*/} <command> <uid/path|.>
	    -c,--compare   compare README.md <-> Alfred's config version
	    --copy         copy Alfred's readme to pasteboard
	    --push         copy README.md in → Alfred's readme
	    --pull         copy Alfred's readme out → README.md
	EOF
	exit
}

_getReadmeFromAlfred() {
	README_ALFRED=$(plutil -extract readme raw "$plist" 2>/dev/null)
}

_requireLocalReadme() {
	if [[ ! -r README.md ]]; then
		echo >&2 "there is no README.md file in $PWD"
		exit 1
	fi
}

_invalid_dir() {
	echo >&2 "$arg does not appear to be an Alfred workflow directory"
}

case $1 in
	-h|--help|'') _usage;;
esac
[[ -n $2 ]] || _usage

arg=$(realpath "${2:-.}")

[[ $arg =~ [A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12} ]]
if [[ ${BASH_REMATCH[0]} ]]; then
	wfd=$wfdir_base/user.workflow.${BASH_REMATCH}
else
	_invalid_dir
	exit 1
fi

plist=$wfd/info.plist
[[ -r $plist ]] || { _invalid_dir; exit 1; }

case $1 in
	--push)
		_requireLocalReadme
		if plutil -replace readme -string "$(<README.md)" "$plist"; then
			echo "$GC README.md copied into Alfred configuration"
		fi
		;;
	--pull)
		_getReadmeFromAlfred
		if [[ -e README.md ]]; then
			trash README.md
		fi
		if [[ -n $README_ALFRED ]]; then
			echo "$README_ALFRED" > README.md
			echo "$GC README from Alfred copied to README.md"
		fi
		;;
	--copy)
		_getReadmeFromAlfred
		if [[ -n $README_ALFRED ]]; then
			pbcopy <<< "$README_ALFRED"
			echo "$GC README from ${wfd/$HOME/\~} copied to pasteboard"
		fi
		;;
	-c|--compare)
		hash icdiff &>/dev/null || brew install --quiet icdiff
		_getReadmeFromAlfred
		if [[ -z $README_ALFRED ]]; then
			echo >&2 "README has not been defined in the workflow"
			exit 1
		fi
		f1="./README.md"
		f2="/tmp/README_${EPOCHSECONDS}.md"
		echo "$README_ALFRED" > "$f2"
		if icdiff --line-numbers --unified=0 --label="{path}" --label="{path} (Alfred)" "$f1" "$f2"; then
			echo "README.md and workflow configuration are identical"
		fi

		: <<-ALTERNATE_COMPARISON_TOOLS
		1) sdiff (builtin)
		   sdiff --suppress-common-lines "$f1" "$f2"
		2) ydiff (brew install ydiff)
		   ydiff --side-by-side "$f2" "$f1"
		3) Beyond Compare - https://www.scootersoftware.com
		   bcompare -fv='Text Compare' -title1="$README.md" -title2="ALFRED" "$f1" "$f2"
		4) delta (brew install git-delta)
		   delta --relative-paths --side-by-side "$f2" "$f1"
		ALTERNATE_COMPARISON_TOOLS
		;;
	-*) echo >&2 "invalid: $1"; exit 1;;
esac
