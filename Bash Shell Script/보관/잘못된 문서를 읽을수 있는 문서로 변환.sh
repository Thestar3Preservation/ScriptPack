#!/home/user/Home/.usersys/bashscriptrecode
source ~/Home/쉘스크립트/function.sh
IFS=$'\n'
for targe; do
	
done
exit

{
echo '=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+'
date

IFS='
'

if [ "$CAJA_SCRIPT_SELECTED_FILE_PATHS" ]
then
 echo "$CAJA_SCRIPT_SELECTED_FILE_PATHS"
 for i in `echo "$CAJA_SCRIPT_SELECTED_FILE_PATHS" | sed '$d'`
 do
  d=$(dirname "$i")
  f=$(basename "$i")
  if [ "`echo "$i" | grep -E '\.[^\.\s]+$'`" ]
  then
   f=$(echo "$f" | sed -r 's/\.([^\.\s]+)$/_변환.\1/' )
  else
   f=$(echo "${f}_변환")
  fi
  iconv -c "$i" -o "$d/$f"
 done
fi

#echo ''
} 2>&1 | tee -a ~/"Home/.usersys/Log_nautilus-scripts/$(basename "$0").log"

exit
