#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

url='http://test.test.test/'
url=$(grep -oE '^[^/]+//[^/]+/' <<<"$url")
for i in $(find . -type f -regextype posix-egrep -iregex '^.*\.(htm|html)$'); do path=$(grep -o / <<<"$i" | tr -d '\n' | sed -e 's#/#../#g' -e 's#^\.##' -e 's#/$##'); content=$(sed "s#$(g_quote "$url")#$path/#ig" -- "$i"); cat >"$i" <<<"$content"; done

exit