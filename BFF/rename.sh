#!/bin/bash
fullpath="$1"
filename="${fullpath##*/}"                      # Strip longest match of */ from start
dir="${fullpath:0:${#fullpath} - ${#filename}}"

newname="ZOG${filename}"
newname="${newname/ZOGThree20/BFF}"
newname="${newname/ZOGTT/BFF}"
newname="${newname/ZOG/BFF}"
echo $newname
#rm ${dir}SIX40_${filename}
gsed  -e 's/Six40\/TT/BFF/g' -e 's/Six40\/Three20/BFF/g'  -e 's/Six40\//BFF/g' -e 's/\bTT/BFF/g'  "${fullpath}"  > "${dir}${newname}"
rm "${fullpath}"
