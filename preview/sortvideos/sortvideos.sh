#!/bin/bash
#
# Script to find and sort videos into a project
# 
# 

if [ -z "$2" ]; then
   echo "Syntax: $0 <project> <word1> [<word2+>]";
   echo "Ex: $0 Highlights_8 funny taser";
   exit 1;
fi

project="$1";
shift;
words="$@";

command="ls -a *_20* | grep 'mp4$'";
for word in $words; do
   command+="|grep ${word}";
done

files=$(eval ${command});
amount=$(echo ${files} | tr ' ' '\n' | wc -l);

if [ ! -d "${project}" ]; then
   mkdir -p ${project}
fi

echo "Matching files: ${amount}";
for file in $files; do
   echo " ";
   echo "====[ $file ]=============";
   while read -n1 -r -p "Add to ${project}? [Y]es | [N]o | [W]atch | [Q]uit: "; do
      case "${REPLY^^}" in
         Y) echo " -> Yes";
	    mv -v ${file} ${project}/
	    break;
	    ;;
	 N) echo " -> No";
	    break;
	    ;;
	 W) echo " -> Watch ";
	    filetime=$(ffmpeg -i "${file}" 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//);
	    min="${filetime:3:2}";
	    sec="${filetime:6:2}";
	    starttime=$(echo "${sec} + ( ${min} * 60 ) - 15" | bc);
	    vlc --start-time=${starttime} "${file}" >/dev/null;
	    ;;
	 Q) echo " -> Quit";
	    exit 0;
	    ;;
	 *) echo " -> What?";
	    ;;
      esac
   done
done
